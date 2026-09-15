```{eval-rst}
.. _protocol-ref-shielded-pool:
```

# Shielded Pool

:::{attention}
Shielded state transitions were [enabled in Protocol Version 12](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/feature_initial_protocol_versions.rs#L4). They use the [Orchard](https://zips.z.cash/protocol/protocol.pdf) shielded protocol to move credits into, within, and out of a pool that hides amounts, senders, and recipients.

For the conceptual overview of how the pool works and when to use it, see [Shielded Pool](../explanations/shielded-pool.md).
:::

## Overview

The shielded pool is implemented through state transition types that share a common Orchard bundle structure:

| Type | Name | Description |
| --- | --- | --- |
| 15 | [Shield](#shield) | Move credits from Platform addresses into the shielded pool |
| 16 | [Shielded Transfer](#shielded-transfer) | Move credits within the pool (no transparent surface) |
| 17 | [Unshield](#unshield) | Move credits from the pool to a Platform address |
| 18 | [Shield from Asset Lock](#shield-from-asset-lock) | Move credits from an L1 asset lock directly into the pool |
| 19 | [Shielded Withdrawal](#shielded-withdrawal) | Move credits from the pool back to Dash Core (L1) |
| 20 | [Identity Create From Shielded Pool](#identity-create-from-shielded-pool) | Create a new identity funded from the shielded pool |
| 21 | [Shield from Identity](#shield-from-identity) | Move credits from an identity balance into the shielded pool (protocol version 14+) |
| 22 | [Identity Top Up From Shielded Pool](#identity-top-up-from-shielded-pool) | Move credits from the shielded pool to an existing identity's balance (protocol version 14+) |

All transitions share a common Orchard bundle (anchor, actions, proof, binding signature). Transitions that touch the transparent side (Shield, Unshield, Shield from Asset Lock, Shielded Withdrawal, Identity Create From Shielded Pool, Shield from Identity, Identity Top Up From Shielded Pool) layer the transparent fields on top of that bundle. Shielded Transfer has no transparent surface beyond the bundle itself.

## Common Components

### Orchard Bundle

Every shielded transition includes an Orchard bundle proving that a set of note spends and outputs is internally consistent. The bundle consists of:

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| actions | array | Varies | Orchard [actions](#actions) (spend-output pairs). Limited to [`max_shielded_transition_actions`](protocol-constants.md) per transition. In practice the effective limit is 6, since the Halo 2 proof grows with each action and the serialized transition must stay within the [maximum state transition size](protocol-constants.md). |
| anchor | array of bytes | 32 bytes | Sinsemilla root of the note commitment tree at bundle creation time. Must match an [anchor](#anchors) the platform has previously recorded |
| proof | array of bytes | Varies | Halo 2 zero-knowledge proof that the actions are valid |
| bindingSignature | array of bytes | 64 bytes | RedPallas signature binding the bundle's actions to its net value balance |

See the [Orchard bundle primitives in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/shielded/mod.rs).

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

Each action permanently stores [344 bytes](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v9.rs#L357) (312 bytes in the note commitment tree + 32 bytes in the nullifier tree). The minimum shielded fee charges a per-action storage allowance of `shielded_storage_bytes_per_action` bytes at the storage rate: 344 bytes through protocol version 13, and 550 bytes from protocol version 14 to cover tree framing overhead.

See the [serialized action implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/shielded/mod.rs).

### Anchors

An **anchor** is the Sinsemilla root of the note commitment tree at the time the bundle was constructed. Each shielded transition specifies the anchor it was built against; the platform validates that the anchor was previously published. Clients fetch anchors using [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors) or [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor).

Anchors are not retained indefinitely. Nodes keep a rolling window governed by [`shielded_anchor_retention_blocks` and `shielded_anchor_pruning_interval`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v1.rs#L297-L298), pruning anchors older than the retention window at each pruning boundary. A prover selecting an anchor must therefore choose one from the current window, not from arbitrary history.

### Platform Sighash

Transitions with transparent fields (Unshield, Shielded Withdrawal, etc.) bind those fields to the Orchard signatures via a platform sighash computed as:

```
SHA-256(SIGHASH_DOMAIN || bundle_commitment || extra_data)
```

This prevents replay attacks where an attacker substitutes transparent fields while reusing a valid Orchard bundle. See the [platform sighash implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/shielded/sighash.rs#L21-L41).

## Shielded State Transition Details

### Shield

Move credits from one or more [Platform addresses](address-system.md#platform-address) into the shielded pool. The total contributed across address inputs must cover the value being shielded plus the transition fee; excess credits remain in the source addresses.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| inputs | map | Varies | Map of source [Platform addresses](address-system.md#platform-address) to (`AddressNonce`, max contribution in credits) pairs |
| actions | array | Varies | Orchard [actions](#actions) (spend-output pairs). Shield brings value in from the transparent inputs, so its actions create new notes rather than consuming prior pool notes |
| amount | unsigned integer | 64 bits | Credits entering the shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| feeStrategy | array | Varies | [Fee deduction strategy](address-system.md#fee-strategy) for address inputs |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full |
| inputWitnesses | array | Varies | [Address witnesses](address-system.md#address-witness) for each input |

:::{note}
Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md). Address witness signatures are excluded from the signable bytes used by the platform sighash.

**Constraints:** Minimum inputs: 1. Maximum inputs: `max_address_inputs`. Minimum per input: 100,000 credits. One witness per input. `amount` must be greater than zero and at most `i64::MAX`, and the input sum must cover the amount plus the minimum shielded fee. The fee strategy must be non-empty, contain no duplicate steps, and have at most `max_address_fee_strategies` steps.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_transition/v0/mod.rs#L37-L63).

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

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_transfer_transition/v0/mod.rs#L31-L42).

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

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/unshield_transition/v0/mod.rs#L32-L45).

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
| surplusOutput | Platform address | Varies | (Optional) Platform address that receives the asset-lock surplus (`asset_lock_value − value_balance − fee`). When omitted, the surplus is added to the fee pools, capped at `shielded_implicit_fee_cap`. Bound to the ECDSA signature so it cannot be redirected |
| signature | array of bytes | 65 bytes | ECDSA signature over the signable bytes proving control of the asset-locked output |

:::{note}
`valueBalance` must be greater than zero and at most `i64::MAX`. The ECDSA signature is excluded from the signable bytes used by the platform sighash. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_from_asset_lock_transition/v0/mod.rs#L35-L60).

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

**Constraints:** Pooling must be `Never` (others not yet implemented). `coreFeePerByte` must be a non-zero Fibonacci number. Output script must be P2PKH or P2SH.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_withdrawal_transition/v0/mod.rs#L33-L54).

### Identity Create From Shielded Pool

Create a new identity funded directly from the shielded pool. The spend nullifiers fund a fixed exit denomination; any change re-enters the pool as an ordinary output note. The new identity carries the same public keys as an ordinary [Identity Create](identity.md#identity-create).

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| publicKeys | array | Varies | The public keys of the new identity (1..=`max_public_keys_in_creation`), carried exactly as in [Identity Create](identity.md#identity-create) |
| denomination | unsigned integer | 64 bits | The fixed exit denomination (in credits) leaving the pool. Must equal the Orchard bundle's value balance exactly and be a member of the versioned denomination set |
| actions | array | Varies | Orchard [actions](#actions) (spend-output pairs); the spend nullifiers fund the exit |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| sendToAddressOnCreationFailure | Platform address | Varies | Fallback [Platform address](address-system.md#platform-address) credited (minus a penalty) if identity creation fails a stateful check. The spend is still final — the denomination leaves the pool regardless |
| identityId | array of bytes | 32 bytes | The id of the new identity, derived as `double_sha256` over the sorted spend nullifiers, then re-derived and checked at consensus |

:::{note}
The new identity's id is derived from the sorted set of spend nullifiers, making it unique and single-use. The public keys, `denomination`, `sendToAddressOnCreationFailure`, and `identityId` are committed into the Orchard bundle (via `extra_sighash_data`), so the bundle cannot be redirected to a different identity. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

#### Exit denominations

:::{versionchanged} 4.1.0
Protocol version 13 revised the exit denomination set.
:::

The `denomination` field must exactly match one of the values accepted by the active protocol version. The set is replaced per protocol version rather than extended, so a denomination valid under one version may not be valid under the next. A denomination outside the active set is rejected with [`ShieldedInvalidDenominationError`](errors.md) (code 10827).

| Protocol version | Accepted denominations |
| --- | --- |
| 14 | 0.03 DASH (3,000,000,000 credits), 0.1 DASH (10,000,000,000), 0.25 DASH (25,000,000,000), 0.5 DASH (50,000,000,000), 1 DASH (100,000,000,000) |
| 12 | 0.1 DASH (10,000,000,000 credits), 0.3 DASH (30,000,000,000), 0.5 DASH (50,000,000,000), 1 DASH (100,000,000,000) |

Protocol version 13 added 0.03 and 0.25 DASH and retired 0.3 DASH. Protocol version 14 keeps the version 13 set unchanged. The protocol version 12 set is retained for chain replay. See the [denomination set in rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v10.rs#L386-L394).

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/identity_create_from_shielded_pool_transition/v0/mod.rs#L31-L64).

### Shield from Identity

:::{versionadded} 4.2.0
Protocol version 14 added this transition.
:::

Move credits from an identity's balance directly into the shielded pool. The transition is signed by the funding identity, like an [identity credit transfer](identity.md#identity-credit-transfer), and carries an outputs-only Orchard bundle like [Shield](#shield). The identity pays the fee plus the shielded amount.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| identityId | array of bytes | 32 bytes | The [identity](identity.md#identity-id) whose balance funds the shield |
| amount | unsigned integer | 64 bits | Credits leaving the identity balance and entering the pool (the absolute value of the bundle's value balance) |
| actions | array | Varies | Orchard [actions](#actions). Spends are disabled; the actions create new notes |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| nonce | unsigned integer | 64 bits | Identity nonce for this transition to prevent replay attacks |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the identity public key that signed the transition. Must be a CRITICAL key with the transfer purpose |
| signature | array of bytes | 65 or 96 bytes | Identity signature over the signable bytes: 65 bytes for ECDSA keys or 96 bytes for BLS keys |

:::{note}
`signature` and `signaturePublicKeyId` are the only fields excluded from the signable bytes. The Orchard bundle uses empty `extra_sighash_data`; the identity signature binds the bundle to this identity and nonce. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).

**Constraints:** `amount` must be greater than zero and at most `i64::MAX`. The identity balance must cover `amount` plus the minimum shielded fee for the action count plus a 20-byte balance write at the storage rate. At execution the identity pays the metered fee plus the shielded compute fee (proof verification and per-action processing). A bundle that fails verification charges the proof failure penalty and bumps the identity nonce.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_from_identity_transition/v0/mod.rs#L48-L69).

### Identity Top Up From Shielded Pool

:::{versionadded} 4.2.0
Protocol version 14 added this transition.
:::

Move credits from the shielded pool to an existing identity's balance. The spends consume shielded notes like [Unshield](#unshield), and the identity receives `topUpAmount` minus the fee. The fee is paid from the pool; there is no transition-level signature.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| identityId | array of bytes | 32 bytes | The existing [identity](identity.md#identity-id) whose balance receives the top-up |
| actions | array | Varies | Orchard [actions](#actions) (spends consume shielded notes) |
| topUpAmount | unsigned integer | 64 bits | Gross credits leaving the pool (the bundle's value balance). The identity is credited `topUpAmount` minus the fee |
| anchor | array of bytes | 32 bytes | [Anchor](#anchors) |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

:::{note}
`identityId` and `topUpAmount` are bound to the Orchard bundle through the [platform sighash](#platform-sighash), so the top-up cannot be redirected to another identity. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).

**Constraints:** `topUpAmount` must be greater than zero and at most `i64::MAX`, and the pool balance must cover it. The identity must exist; otherwise the transition fails with [`IdentityNotFoundError`](errors.md) (code 20000). The fee is the minimum shielded fee for the action count plus an 8-byte balance write at the storage rate.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/shielded/identity_top_up_from_shielded_pool_transition/v0/mod.rs#L41-L54).

## Shielded Transition Signing

With one exception, shielded transitions are not signed by an identity public key, and the identity-signed `signature` and `signaturePublicKeyId` fields listed in the [common fields](state-transition.md#common-fields) do not appear on them. The exception is [Shield from Identity](#shield-from-identity), which the funding identity signs with a CRITICAL transfer key. Authorization is instead carried by cryptographic primitives attached to the Orchard bundle and, where applicable, to the transparent side of the transition. This includes the asset-lock ECDSA `signature` carried by [Shield from Asset Lock](#shield-from-asset-lock) described below.

### Orchard bundle signatures

Every shielded transition includes:

- **Per-action spend authorization signatures** (`spendAuthSig` on each [action](#actions)). Each is a 64-byte RedPallas signature, produced by the holder of the spent note over the randomized verification key `rk`. The proof binds `rk` to the original spending key, so verifying the signature against `rk` proves the spender is authorized.
- **Binding signature** (`bindingSignature` on the transition). A 64-byte RedPallas signature over the sum of the action value commitments, proving that the actions' net value balance matches the transition's declared value balance.

### Platform sighash

Unshield, Shielded Withdrawal, Identity Create From Shielded Pool, and Identity Top Up From Shielded Pool bind their transparent fields to the Orchard bundle through the [platform sighash](#platform-sighash) (non-empty `extra_sighash_data`). Any modification to those transparent fields invalidates the Orchard signatures, preventing replay attacks that substitute transparent fields while reusing a valid bundle. Shield, Shield from Asset Lock, and Shield from Identity use empty `extra_sighash_data`; their transparent side is authorized by address witnesses (Shield), the asset-lock ECDSA signature (Shield from Asset Lock), or the identity signature (Shield from Identity) over the signable bytes instead.

### Transparent signatures

Several shielded transitions also carry transparent signatures over the transparent side of the transition:

- **Shield** includes an array of [address witnesses](address-system.md#address-witness) (`inputWitnesses`) — one per address input. Each witness proves control of its corresponding Platform address. Address witness signatures are excluded from the bytes that feed the platform sighash (they sign the platform sighash output, not vice-versa).
- **Shield from Asset Lock** includes a 65-byte ECDSA `signature` proving control of the L1 asset-locked output, in the same form used by [Identity Create](identity.md#identity-create). The signature is excluded from the bytes that feed the platform sighash.
- **Shield from Identity** includes an identity `signature` and `signaturePublicKeyId`, in the same form used by [identity credit transfer](identity.md#identity-credit-transfer). Both are excluded from the signable bytes; the signature binds the Orchard bundle to the identity and nonce.

Shielded Transfer, Unshield, Shielded Withdrawal, and Identity Top Up From Shielded Pool have no transparent signatures; the Orchard bundle signatures plus the platform sighash provide full authorization.

## Querying shielded state

DAPI exposes a set of read-only endpoints for clients that need to fetch anchors, scan encrypted notes, verify nullifier status, or track shielded sync progress. See the [DAPI Platform endpoints reference](../reference/dapi-endpoints-platform-endpoints.md) for request and response shapes:

- [`getShieldedPoolState`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedpoolstate)
- [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors)
- [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor)
- [`getShieldedEncryptedNotes`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedencryptednotes)
- [`getShieldedNotesCount`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednotescount)
- [`getShieldedNullifiers`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednullifiers)
