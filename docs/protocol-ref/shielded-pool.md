```{eval-rst}
.. _protocol-ref-shielded-pool:
```

# Shielded Pool

:::{attention}
Shielded state transitions were [enabled in Protocol Version 12](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-platform-version/src/version/feature_initial_protocol_versions.rs#L4). They use the [Orchard](https://zips.z.cash/protocol/protocol.pdf) shielded protocol to move credits into, within, and out of a pool that hides amounts, senders, and recipients.

For the conceptual overview of how the pool works and when to use it, see [Shielded Pool](../explanations/shielded-pool.md).
:::

## Overview

The shielded pool is implemented through five state transition types that share a common Orchard bundle structure:

| Type | Name | Description |
| --- | --- | --- |
| 15 | [Shield](#shield) | Move credits from Platform addresses into the shielded pool |
| 16 | [Shielded Transfer](#shielded-transfer) | Move credits within the pool (no transparent surface) |
| 17 | [Unshield](#unshield) | Move credits from the pool to a Platform address |
| 18 | [Shield from Asset Lock](#shield-from-asset-lock) | Move credits from an L1 asset lock directly into the pool |
| 19 | [Shielded Withdrawal](#shielded-withdrawal) | Move credits from the pool back to Dash Core (L1) |

All five transitions share a common Orchard bundle (anchor, actions, proof, binding signature). Transitions that touch the transparent side (Shield, Unshield, Shield from Asset Lock, Shielded Withdrawal) layer the transparent fields on top of that bundle. Shielded Transfer has no transparent surface beyond the bundle itself.

## Common Components

### Orchard Bundle

Every shielded transition includes an Orchard bundle proving that a set of note spends and outputs is internally consistent. The bundle consists of:

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| actions | array | Varies | Orchard [actions](#actions) (spend-output pairs). Limited to [`max_shielded_transition_actions`](protocol-constants.md) per transition. |
| anchor | array of bytes | 32 bytes | Sinsemilla root of the note commitment tree at bundle creation time. Must match an [anchor](#anchors) the platform has previously recorded |
| proof | array of bytes | Varies | Halo 2 zero-knowledge proof that the actions are valid |
| bindingSignature | array of bytes | 64 bytes | RedPallas signature binding the bundle's actions to its net value balance |

See the [Orchard bundle primitives in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/shielded/mod.rs).

### Actions

Each Orchard action structurally contains one spend and one output. The spend consumes a previously created note (revealing its nullifier), while the output creates a new note (publishing its commitment). Although paired in the same struct, observers cannot link which prior note was spent or what value the new note holds — the zero-knowledge proof ensures privacy.

Each action publishes:

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| nullifier | array of bytes | 32 bytes | Unique tag derived from the spent note. Used to prevent double-spending |
| rk | array of bytes | 32 bytes | Randomized verification key for the action's spend authorization signature |
| cmx | array of bytes | 32 bytes | Extracted note commitment for the new note |
| encryptedNote | array of bytes | 216 bytes | Encrypted note payload — 32-byte ephemeral public key + 104-byte note ciphertext + 80-byte out-of-band ciphertext |
| cvNet | array of bytes | 32 bytes | Net value commitment (Pedersen commitment to the action's value contribution) |
| spendAuthSig | array of bytes | 64 bytes | Per-action spend authorization signature — see [Shielded Transition Signing](#shielded-transition-signing) |

Permanent storage cost per action is [312 bytes](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/shielded/mod.rs#L13-L16) (280 bytes in the note commitment tree + 32 bytes in the nullifier tree).

See the [serialized action implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/shielded/mod.rs).

### Anchors

An **anchor** is the Sinsemilla root of the note commitment tree at the time the bundle was constructed. Each shielded transition specifies the anchor it was built against; the platform validates that the anchor was previously published. Clients fetch anchors using [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors) or [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor).

### Platform Sighash

Transitions with transparent fields (Unshield, Shielded Withdrawal, etc.) bind those fields to the Orchard signatures via a platform sighash computed as:

```
SHA-256(SIGHASH_DOMAIN || bundle_commitment || extra_data)
```

This prevents replay attacks where an attacker substitutes transparent fields while reusing a valid Orchard bundle. See the [platform sighash implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/shielded/mod.rs#L20-L40).

## Shielded State Transition Details

### Shield

Move credits from one or more [Platform addresses](address-system.md#platform-address) into the shielded pool. The total contributed across address inputs must cover the value being shielded plus the transition fee; excess credits remain in the source addresses.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| inputs | map | Varies | Map of source [Platform addresses](address-system.md#platform-address) to (`AddressNonce`, max contribution in credits) pairs |
| actions | array | Varies | Orchard [actions](#actions) (output-only — Shield creates new notes without consuming prior ones) |
| amount | unsigned integer | 64 bits | Credits entering the shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| feeStrategy | array | Varies | [Fee deduction strategy](address-system.md#fee-strategy) for address inputs |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full |
| inputWitnesses | array | Varies | [Address witnesses](address-system.md#address-witness) for each input |

:::{note}
Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md). Address witness signatures are excluded from the signable bytes used by the platform sighash.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_transition/).

### Shielded Transfer

Move credits within the pool between notes. There is no transparent surface — to an outside observer, only the Orchard bundle is visible.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| actions | array | Varies | Orchard [actions](#actions) |
| valueBalance | unsigned integer | 64 bits | Net value balance — the fee amount extracted from the shielded pool for this transition |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

:::{note}
Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_transfer_transition/).

### Unshield

Move credits from the pool to a [Platform address](address-system.md#platform-address) the sender designates. The unshielded amount becomes spendable through normal address-based transitions.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| outputAddress | object | Varies | Destination [Platform address](address-system.md#platform-address) |
| actions | array | Varies | Orchard [actions](#actions) (spends consume shielded notes) |
| unshieldingAmount | unsigned integer | 64 bits | Total credits leaving the pool (recipient amount + fee) |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

:::{note}
The `outputAddress` is bound to the Orchard bundle through the [platform sighash](#platform-sighash) to prevent substitution attacks. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/unshield_transition/).

### Shield from Asset Lock

Move credits from a Dash Core (L1) asset-lock transaction directly into the shielded pool, without first funding a Platform address.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| assetLockProof | object | Varies | [Asset lock proof](identity.md#asset-lock) (InstantSend or ChainLock) authorizing the funds |
| actions | array | Varies | Orchard [actions](#actions) |
| valueBalance | unsigned integer | 64 bits | Credits entering the shielded pool from the asset lock |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| signature | array of bytes | 65 bytes | ECDSA signature over the signable bytes proving control of the asset-locked output |

:::{note}
`valueBalance` must be greater than zero and at most `i64::MAX`. The ECDSA signature is excluded from the signable bytes used by the platform sighash. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_from_asset_lock_transition/).

### Shielded Withdrawal

Move credits from the pool back to Dash Core (L1). The funds leave Platform entirely rather than landing in a Platform address.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| actions | array | Varies | Orchard [actions](#actions) (spends + change outputs) |
| unshieldingAmount | unsigned integer | 64 bits | Total credits leaving the pool (recipient amount + fee) |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| coreFeePerByte | unsigned integer | 32 bits | Core transaction fee rate for the L1 withdrawal transaction |
| pooling | unsigned integer | 8 bits | Withdrawal pooling strategy (see [Identity Credit Withdrawal](identity.md#identity-credit-withdrawal)) |
| outputScript | array of bytes | Varies | Core script of the L1 address receiving the withdrawn funds |

:::{note}
Transparent fields (`coreFeePerByte`, `pooling`, `outputScript`) are bound to the Orchard bundle through the [platform sighash](#platform-sighash). Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_withdrawal_transition/).

## Shielded Transition Signing

Shielded transitions are not signed by an identity public key. The 65-byte `signature` and the `signaturePublicKeyId` fields listed in the [common fields](state-transition.md#common-fields) for identity-signed transitions do not appear on Unshield, Shielded Transfer, or Shielded Withdrawal. Authorization is instead carried by cryptographic primitives attached to the Orchard bundle and, where applicable, to the transparent side of the transition.

### Orchard bundle signatures

Every shielded transition includes:

- **Per-action spend authorization signatures** (`spendAuthSig` on each [action](#actions)). Each is a 64-byte RedPallas signature, produced by the holder of the spent note over the randomized verification key `rk`. The proof binds `rk` to the original spending key, so verifying the signature against `rk` proves the spender is authorized.
- **Binding signature** (`bindingSignature` on the transition). A 64-byte RedPallas signature over the sum of the action value commitments, proving that the actions' net value balance matches the transition's declared value balance.

### Platform sighash

Transitions that include transparent fields (Shield, Unshield, Shield from Asset Lock, Shielded Withdrawal) bind those fields to the Orchard bundle through the [platform sighash](#platform-sighash). Any modification to the transparent fields invalidates the Orchard signatures, preventing replay attacks that substitute transparent fields while reusing a valid bundle.

### Transparent signatures (Shield, Shield from Asset Lock)

Two shielded transitions also carry transparent signatures over the transparent side of the transition:

- **Shield** includes an array of [address witnesses](address-system.md#address-witness) (`inputWitnesses`) — one per address input. Each witness proves control of its corresponding Platform address. Address witness signatures are excluded from the bytes that feed the platform sighash (they sign the platform sighash output, not vice-versa).
- **Shield from Asset Lock** includes a 65-byte ECDSA `signature` proving control of the L1 asset-locked output, in the same form used by [Identity Create](identity.md#identity-create). The signature is excluded from the bytes that feed the platform sighash.

Shielded Transfer, Unshield, and Shielded Withdrawal have no transparent signatures; the Orchard bundle signatures plus the platform sighash provide full authorization.

## Querying shielded state

DAPI exposes a set of read-only endpoints for clients that need to fetch anchors, scan encrypted notes, verify nullifier status, or sync incremental nullifier updates. See the [DAPI Platform endpoints reference](../reference/dapi-endpoints-platform-endpoints.md) for request and response shapes:

- [`getShieldedPoolState`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedpoolstate)
- [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors)
- [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor)
- [`getShieldedEncryptedNotes`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedencryptednotes)
- [`getShieldedNullifiers`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednullifiers)
- [`getNullifiersTrunkState`](../reference/dapi-endpoints-platform-endpoints.md#getnullifierstrunkstate)
- [`getNullifiersBranchState`](../reference/dapi-endpoints-platform-endpoints.md#getnullifiersbranchstate)
- [`getRecentNullifierChanges`](../reference/dapi-endpoints-platform-endpoints.md#getrecentnullifierchanges)
- [`getRecentCompactedNullifierChanges`](../reference/dapi-endpoints-platform-endpoints.md#getrecentcompactednullifierchanges)
