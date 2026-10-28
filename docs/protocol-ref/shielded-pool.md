```{eval-rst}
.. _protocol-ref-shielded-pool:
```

# Shielded Pool

:::{attention}
Shielded state transitions were [enabled in Protocol Version 12](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/feature_initial_protocol_versions.rs#L4). They use the [Orchard](https://zips.z.cash/protocol/protocol.pdf) shielded protocol to move credits into, within, and out of a pool that hides amounts, senders, and recipients.

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
| 26 | [Token Shielded Transfer With Shielded Fee](#token-shielded-transfer-with-shielded-fee) | Move tokens within a token's shielded pool, paying the fee from the credit shielded pool (protocol version 14+) |
| 27 | [Token Unshield With Shielded Fee](#token-unshield-with-shielded-fee) | Move tokens from a token's shielded pool to an identity's token balance, paying the fee from the credit shielded pool (protocol version 14+) |
| 28 | [Token Purchase From Shielded Pool](#token-purchase-from-shielded-pool) | Buy tokens at the direct purchase price and mint them into the token's shielded pool, paying from the credit shielded pool (protocol version 14+) |

All transitions share a common Orchard bundle (anchor, actions, proof, binding signature). Transitions that touch the transparent side (Shield, Unshield, Shield from Asset Lock, Shielded Withdrawal, Identity Create From Shielded Pool, Shield from Identity, Identity Top Up From Shielded Pool) layer the transparent fields on top of that bundle. Shielded Transfer has no transparent surface beyond the bundle itself.

Types 15-22 operate on the credit shielded pool. From protocol version 14, a token whose configuration sets [`hasShieldedPool`](data-contract-token.md#shielded-pool) also has its own shielded pool of that token, laid out like the credit pool. Types 26-28 carry two bundles: one in the token's pool and one in the credit pool that pays the fee, so no identity signs or pays. Identity-signed token pool operations are [batch token transitions](token.md#token-shielded-pool-transitions) instead. For the conceptual overview, see [Token Shielded Pools](../explanations/shielded-pool.md#token-shielded-pools).

## Common Components

### Orchard Bundle

Every shielded transition includes an Orchard bundle proving that a set of note spends and outputs is internally consistent. The bundle consists of:

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| actions | array | Varies | Orchard [actions](#actions) (spend-output pairs). Limited to [`max_shielded_transition_actions`](protocol-constants.md) per transition. In practice the effective limit is 6, since the Halo 2 proof grows with each action and the serialized transition must stay within the [maximum state transition size](protocol-constants.md). |
| anchor | array of bytes | 32 bytes | Sinsemilla root of the note commitment tree at bundle creation time. Must match an [anchor](#anchors) the platform has previously recorded |
| proof | array of bytes | Varies | Halo 2 zero-knowledge proof that the actions are valid |
| bindingSignature | array of bytes | 64 bytes | RedPallas signature binding the bundle's actions to its net value balance |

See the [Orchard bundle primitives in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/mod.rs).

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

Each action permanently stores [344 bytes](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v9.rs#L423-L425) (312 bytes in the note commitment tree + 32 bytes in the nullifier tree). The [minimum shielded fee](protocol-constants.md#shielded-fees) charges a per-action storage allowance of `shielded_storage_bytes_per_action` bytes at the storage rate: 344 bytes through protocol version 13, and [550 bytes](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v10.rs#L496) from protocol version 14 to cover tree framing overhead.

From protocol version 14, the nullifiers revealed by the dummy spends of outputs-only bundles (Shield, Shield from Asset Lock, Shield from Identity, and the token pool transitions that only create notes) are recorded like the nullifiers of real spends. A bundle that repeats one within itself or reuses one already recorded is rejected.

See the [serialized action implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/mod.rs).

### Anchors

An **anchor** is the Sinsemilla root of the note commitment tree at the time the bundle was constructed. Each shielded transition specifies the anchor it was built against; the platform validates that the anchor was previously published. Clients fetch anchors using [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors) or [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor).

Anchors are not retained indefinitely. Nodes keep a rolling window governed by [`shielded_anchor_retention_blocks` and `shielded_anchor_pruning_interval`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v10.rs#L471-L472), pruning anchors older than the retention window at each pruning boundary. A prover selecting an anchor must therefore choose one from the current window, not from arbitrary history.

### Platform Sighash

Every Orchard bundle is signed over a platform sighash computed as:

```
SHA-256(SIGHASH_DOMAIN || bundle_commitment || extra_data)
```

`SIGHASH_DOMAIN` is the ASCII string [`DashPlatformSighash`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L25-L26). The `extra_data` binds the bundle to the transition that carries it. For transitions with transparent fields it carries those fields, which prevents replay attacks where an attacker substitutes transparent fields while reusing a valid Orchard bundle. For outputs-only bundles, which have no spends and so are never checked against a pool's anchors, it carries a kind tag and whatever funds the bundle, so a third party cannot wrap a proved bundle in a transition of their own. See the [platform sighash implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L62-L90).

:::{versionchanged} 5.0.0
Protocol version 14 binds the outputs-only bundles of Shield and Shield from Asset Lock to a kind tag and their funding source. Earlier protocol versions use empty `extra_data` for both. Shield from Identity, added in the same version, is bound from the start.
:::

Protocol version 14 uses the following `extra_data` layouts (`||` is concatenation; integers are little-endian):

| Transition | `extra_data` |
| --- | --- |
| [Shield](#shield) | [Tag `0x84` \|\| SHA-256 of the input addresses](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L791-L819), each in its 21-byte [Platform address](address-system.md#platform-address) encoding, in `inputs` map order |
| [Shielded Transfer](#shielded-transfer) | Empty. The bundle spends notes, so its anchor and nullifiers already pin it to the pool |
| [Unshield](#unshield) | [`outputAddress` (21 bytes) \|\| `unshieldingAmount` (u64)](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L183-L188) |
| [Shield from Asset Lock](#shield-from-asset-lock) | [Tag `0x86` \|\| asset lock identifier](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L866-L882) (the double SHA-256 of the locked outpoint) |
| [Shielded Withdrawal](#shielded-withdrawal) | [`outputScript` \|\| `unshieldingAmount` (u64) \|\| `coreFeePerByte` (u32) \|\| `pooling` (u8)](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L142-L154) |
| [Identity Create From Shielded Pool](#identity-create-from-shielded-pool) | [`identityId` \|\| `denomination` (u64) \|\| `sendToAddressOnCreationFailure` \|\| the full public key set](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L288-L348) |
| [Shield from Identity](#shield-from-identity) | [Tag `0x85` \|\| `identityId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L832-L848) |
| [Identity Top Up From Shielded Pool](#identity-top-up-from-shielded-pool) | [`identityId` \|\| `topUpAmount` (u64)](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L218-L226) |
| [Token Shielded Transfer With Shielded Fee](#token-shielded-transfer-with-shielded-fee) | Token bundle: [type `26` (u8) \|\| `tokenId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L501-L509). Fee bundle: see below |
| [Token Unshield With Shielded Fee](#token-unshield-with-shielded-fee) | Token bundle: [type `27` (u8) \|\| `tokenId` \|\| `recipientId` \|\| `amount` (u64)](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L534-L547). Fee bundle: see below |
| [Token Purchase From Shielded Pool](#token-purchase-from-shielded-pool) | Token bundle: [type `28` (u8) \|\| `tokenId` \|\| `tokenCount` (u64) \|\| `totalAgreedPrice` (u64)](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L571-L584). Fee bundle: see below |

The credit pool fee bundle of types 26-28 binds [the transition type (u8) \|\| `tokenId` \|\| the SHA-256 digest of the token bundle's serialized actions](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L609-L621), so a fee bundle can only pay for the exact token bundle it was built with. The layouts of the batch token pool transitions are listed under [Token Shielded Pool Transitions](token.md#token-shielded-pool-transitions). A document [token cost](data-contract-document.md#token-costs) paid from a token's pool ([`$tokenPaymentInfo.shieldedPayment`](document.md#token-payment-info)) binds its spend bundle to [`tokenId` \|\| `ownerId` \|\| `dataContractId` \|\| `documentId` \|\| `amount` (u64)](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L465-L482).

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
Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md). Address witness signatures are excluded from the signable bytes used by the platform sighash. From protocol version 14, the bundle is bound to the input addresses through the [platform sighash](#platform-sighash).

**Constraints:** Minimum inputs: 1. Maximum inputs: `max_address_inputs`. Minimum per input: 100,000 credits. One witness per input. `amount` must be greater than zero and at most `i64::MAX`, and the input sum must cover the amount plus the minimum shielded fee. The fee strategy must be non-empty, contain no duplicate steps, and have at most `max_address_fee_strategies` steps.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_transition/v0/mod.rs#L41-L71).

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

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_transfer_transition/v0/mod.rs#L35-L50).

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

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/unshield_transition/v0/mod.rs#L36-L53).

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
`valueBalance` must be greater than zero and at most `i64::MAX`. The ECDSA signature is excluded from the signable bytes used by the platform sighash. From protocol version 14, the bundle is bound to the asset lock through the [platform sighash](#platform-sighash). Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).
:::

:::{versionchanged} 5.0.0
Protocol version 14 accepts only transition version 1 of Shield from Asset Lock, which has the same fields as version 0 but carries a bundle proved against the bound platform sighash. A version 0 transition is rejected when it is decoded, without a fee, and its asset lock remains unspent.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_from_asset_lock_transition/v1/mod.rs#L49-L74).

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

**Constraints:** Pooling must be `Never` (others not yet implemented). `coreFeePerByte` must be a non-zero Fibonacci number. Output script must be P2PKH or P2SH. Starting in protocol version 14, `coreFeePerByte` must be at most 6,765, and the Core transaction fee is deducted from the amount reserved for Core (`unshieldingAmount` minus the [shielded withdrawal fee](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/compute_minimum_shielded_fee/mod.rs#L56-L90)). The reserved amount must be at least the [min withdrawal amount](protocol-constants.md) plus the Core fee (190-byte asset unlock transaction × `coreFeePerByte` × 1,000 credits) and at most the [max withdrawal amount](protocol-constants.md) ([validation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_withdrawal_transition/v0/state_transition_validation/v1.rs#L24-L66)).
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/shielded_withdrawal_transition/v0/mod.rs#L37-L62).

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

Protocol version 13 added 0.03 and 0.25 DASH and retired 0.3 DASH. Protocol version 14 keeps the version 13 set unchanged. The protocol version 12 set is retained for chain replay. See the [denomination set in rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v10.rs#L506-L512).

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/identity_create_from_shielded_pool_transition/v0/mod.rs#L31-L68).

### Shield from Identity

:::{versionadded} 5.0.0
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
`signature` and `signaturePublicKeyId` are the only fields excluded from the signable bytes. The Orchard bundle is bound to the funding identity through the [platform sighash](#platform-sighash), and the identity signature binds the transition to this identity and nonce. Maximum actions per transition: [`max_shielded_transition_actions`](protocol-constants.md).

**Constraints:** `amount` must be greater than zero and at most `i64::MAX`. The identity balance must cover `amount` plus the minimum shielded fee for the action count plus a 20-byte balance write at the storage rate. At execution the identity pays the metered fee plus the shielded compute fee (proof verification and per-action processing). A bundle that fails verification charges the proof failure penalty and bumps the identity nonce.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/shield_from_identity_transition/v0/mod.rs#L48-L73).

### Identity Top Up From Shielded Pool

:::{versionadded} 5.0.0
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

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/identity_top_up_from_shielded_pool_transition/v0/mod.rs#L41-L58).

### Token Shielded Transfer With Shielded Fee

:::{versionadded} 5.0.0
Protocol version 14 added this transition.
:::

Move tokens within a token's shielded pool without involving any identity. The token bundle spends and recreates notes in the token pool with a value balance of zero, and a second bundle spends notes in the credit shielded pool to pay the fee.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| dataContractId | array of bytes | 32 bytes | The [data contract](data-contract.md) that defines the token |
| tokenContractPosition | unsigned integer | 16 bits | The token's position in the contract |
| tokenId | array of bytes | 32 bytes | The [token ID](token.md#token-id). Must equal the ID derived from `dataContractId` and `tokenContractPosition` |
| tokenActions | array | Varies | Orchard [actions](#actions) of the bundle in the token's shielded pool |
| tokenAnchor | array of bytes | 32 bytes | [Anchor](#anchors) of the token pool's note commitment tree |
| tokenProof | array of bytes | Varies | Halo 2 proof of the token bundle |
| tokenBindingSignature | array of bytes | 64 bytes | RedPallas binding signature of the token bundle |
| feeActions | array | Varies | Orchard [actions](#actions) of the spend bundle in the credit shielded pool that pays the fee |
| feeAnchor | array of bytes | 32 bytes | [Anchor](#anchors) of the credit pool's note commitment tree |
| feeProof | array of bytes | Varies | Halo 2 proof of the fee bundle |
| feeBindingSignature | array of bytes | 64 bytes | RedPallas binding signature of the fee bundle |
| creditAmount | unsigned integer | 64 bits | Credits leaving the credit pool (the fee bundle's value balance). This is the fee |

:::{note}
The token bundle and the fee bundle are each bound to this transition through the [platform sighash](#platform-sighash).

**Constraints:** Both bundles must pass the stateless checks every shielded bundle passes: at most [`max_shielded_transition_actions`](protocol-constants.md) actions, correctly sized encrypted notes, a non-empty proof, and a non-zero anchor. `tokenId` must match the contract and position. `creditAmount` must be greater than zero and at most `i64::MAX`. `creditAmount` must equal the [fee for both bundles](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/compute_minimum_shielded_fee/mod.rs#L262-L270) exactly. The token must have a [shielded pool](data-contract-token.md#shielded-pool) and must not be paused. The fee bundle's anchor must be recorded for the credit pool, its nullifiers must be unspent, and the credit pool must hold `creditAmount`. Each transition is unique by the nullifiers of both bundles. The token bundle's anchor must be recorded for the token pool and its nullifiers must be unspent there.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/token_shielded_transfer_with_shielded_fee_transition/v0/mod.rs#L45-L78) and the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/token_shielded_transfer_with_shielded_fee/transform_into_action/v0/mod.rs#L30-L79).

### Token Unshield With Shielded Fee

:::{versionadded} 5.0.0
Protocol version 14 added this transition.
:::

Move tokens from a token's shielded pool into an identity's token balance without a transition-level signature. The token bundle spends notes in the token pool (value balance `amount`), and a second bundle spends notes in the credit shielded pool to pay the fee.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| dataContractId | array of bytes | 32 bytes | The [data contract](data-contract.md) that defines the token |
| tokenContractPosition | unsigned integer | 16 bits | The token's position in the contract |
| tokenId | array of bytes | 32 bytes | The [token ID](token.md#token-id). Must equal the ID derived from `dataContractId` and `tokenContractPosition` |
| recipientId | array of bytes | 32 bytes | The [identity](identity.md#identity-id) whose token balance receives `amount` |
| amount | unsigned integer | 64 bits | Tokens leaving the token pool (the token bundle's value balance) |
| tokenActions | array | Varies | Orchard [actions](#actions) of the bundle in the token's shielded pool |
| tokenAnchor | array of bytes | 32 bytes | [Anchor](#anchors) of the token pool's note commitment tree |
| tokenProof | array of bytes | Varies | Halo 2 proof of the token bundle |
| tokenBindingSignature | array of bytes | 64 bytes | RedPallas binding signature of the token bundle |
| feeActions | array | Varies | Orchard [actions](#actions) of the spend bundle in the credit shielded pool that pays the fee |
| feeAnchor | array of bytes | 32 bytes | [Anchor](#anchors) of the credit pool's note commitment tree |
| feeProof | array of bytes | Varies | Halo 2 proof of the fee bundle |
| feeBindingSignature | array of bytes | 64 bytes | RedPallas binding signature of the fee bundle |
| creditAmount | unsigned integer | 64 bits | Credits leaving the credit pool (the fee bundle's value balance). This is the fee |

:::{note}
`recipientId` and `amount` are bound to the token bundle through the [platform sighash](#platform-sighash), so the tokens cannot be redirected.

**Constraints:** Both bundles must pass the stateless checks every shielded bundle passes: at most [`max_shielded_transition_actions`](protocol-constants.md) actions, correctly sized encrypted notes, a non-empty proof, and a non-zero anchor. `tokenId` must match the contract and position. `creditAmount` must be greater than zero and at most `i64::MAX`. `amount` must be from 1 to 2^48 - 1. `creditAmount` must equal the [fee for both bundles](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/compute_minimum_shielded_fee/mod.rs#L272-L291) exactly, which includes the storage for a new token balance whether or not the recipient already holds the token. The token must have a [shielded pool](data-contract-token.md#shielded-pool) and must not be paused. The fee bundle's anchor must be recorded for the credit pool, its nullifiers must be unspent, and the credit pool must hold `creditAmount`. Each transition is unique by the nullifiers of both bundles. The recipient identity must exist. The token pool must hold at least the token's [`minimumPoolNotesForOutgoing`](data-contract-token.md#shielded-pool) notes. The token bundle's anchor must be recorded for the token pool, its nullifiers must be unspent there, and the pool must hold `amount`.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/token_unshield_with_shielded_fee_transition/v0/mod.rs#L46-L83) and the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/token_unshield_with_shielded_fee/transform_into_action/v0/mod.rs#L34-L112).

### Token Purchase From Shielded Pool

:::{versionadded} 5.0.0
Protocol version 14 added this transition.
:::

Buy tokens at the token's [direct purchase price](token.md#token-set-purchase-price-transition) and mint them straight into the token's shielded pool, paid from the credit shielded pool. The token bundle is outputs-only (value balance `-tokenCount`). The credit bundle spends notes whose value covers the price plus the fee. The price is credited to the contract owner, and no identity signs.

| Field | Type | Size | Description |
| --- | --- | --- | --- |
| dataContractId | array of bytes | 32 bytes | The [data contract](data-contract.md) that defines the token |
| tokenContractPosition | unsigned integer | 16 bits | The token's position in the contract |
| tokenId | array of bytes | 32 bytes | The [token ID](token.md#token-id). Must equal the ID derived from `dataContractId` and `tokenContractPosition` |
| tokenCount | unsigned integer | 64 bits | Tokens bought and minted into the token pool |
| totalAgreedPrice | unsigned integer | 64 bits | Credits the buyer agrees to pay for `tokenCount`, paid to the contract owner |
| tokenActions | array | Varies | Orchard [actions](#actions) of the bundle in the token's shielded pool |
| tokenAnchor | array of bytes | 32 bytes | [Anchor](#anchors) of the token pool's note commitment tree |
| tokenProof | array of bytes | Varies | Halo 2 proof of the token bundle |
| tokenBindingSignature | array of bytes | 64 bytes | RedPallas binding signature of the token bundle |
| feeActions | array | Varies | Orchard [actions](#actions) of the spend bundle in the credit shielded pool that pays the fee |
| feeAnchor | array of bytes | 32 bytes | [Anchor](#anchors) of the credit pool's note commitment tree |
| feeProof | array of bytes | Varies | Halo 2 proof of the fee bundle |
| feeBindingSignature | array of bytes | 64 bytes | RedPallas binding signature of the fee bundle |
| creditAmount | unsigned integer | 64 bits | Credits leaving the credit pool (the fee bundle's value balance): `totalAgreedPrice` plus the fee |

:::{note}
`tokenCount` and `totalAgreedPrice` are bound to the token bundle through the [platform sighash](#platform-sighash).

**Constraints:** Both bundles must pass the stateless checks every shielded bundle passes: at most [`max_shielded_transition_actions`](protocol-constants.md) actions, correctly sized encrypted notes, a non-empty proof, and a non-zero anchor. `tokenId` must match the contract and position. `creditAmount` must be greater than zero and at most `i64::MAX`. `tokenCount` must be from 1 to 2^48 - 1, and `totalAgreedPrice` must not exceed `creditAmount`. `creditAmount` minus `totalAgreedPrice` must equal the [fee for both bundles](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/compute_minimum_shielded_fee/mod.rs#L293-L307) exactly. The token must have a [shielded pool](data-contract-token.md#shielded-pool) and must not be paused. The fee bundle's anchor must be recorded for the credit pool, its nullifiers must be unspent, and the credit pool must hold `creditAmount`. Each transition is unique by the nullifiers of both bundles. The token must have a direct purchase price, and `totalAgreedPrice` must cover the price for `tokenCount` under the current pricing schedule. The total supply plus `tokenCount` must not exceed `maxSupply` (or `i64::MAX` when no maximum is set). The token bundle's dummy nullifiers must not already be recorded in the token pool. Because the price leaves the credit pool for the contract owner, the credit pool must hold at least [250 notes](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/drive_abci_versions/drive_abci_validation_versions/v10.rs#L470), the same threshold other transitions that move value out of the credit pool must meet.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/shielded/token_purchase_from_shielded_pool_transition/v0/mod.rs#L46-L83) and the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/token_purchase_from_shielded_pool/transform_into_action/v0/mod.rs#L39-L174).

## Shielded Transition Signing

With one exception, shielded transitions are not signed by an identity public key, and the identity-signed `signature` and `signaturePublicKeyId` fields listed in the [common fields](state-transition.md#common-fields) do not appear on them. The exception is [Shield from Identity](#shield-from-identity), which the funding identity signs with a CRITICAL transfer key. Authorization is instead carried by cryptographic primitives attached to the Orchard bundle and, where applicable, to the transparent side of the transition. This includes the asset-lock ECDSA `signature` carried by [Shield from Asset Lock](#shield-from-asset-lock) described below.

### Orchard bundle signatures

Every shielded transition includes:

- **Per-action spend authorization signatures** (`spendAuthSig` on each [action](#actions)). Each is a 64-byte RedPallas signature, produced by the holder of the spent note over the randomized verification key `rk`. The proof binds `rk` to the original spending key, so verifying the signature against `rk` proves the spender is authorized.
- **Binding signature** (`bindingSignature` on the transition). A 64-byte RedPallas signature over the sum of the action value commitments, proving that the actions' net value balance matches the transition's declared value balance.

### Platform sighash

Unshield, Shielded Withdrawal, Identity Create From Shielded Pool, Identity Top Up From Shielded Pool, and the token bundles of types 26-28 bind their transparent fields to the Orchard bundle through the [platform sighash](#platform-sighash) (non-empty `extra_sighash_data`). Any modification to those transparent fields invalidates the Orchard signatures, preventing replay attacks that substitute transparent fields while reusing a valid bundle. From protocol version 14, Shield, Shield from Asset Lock, and Shield from Identity bind a kind tag and their funding source (input addresses, asset lock, or identity), so a bundle cannot be moved into another transition. Their transparent side is still authorized by address witnesses (Shield), the asset-lock ECDSA signature (Shield from Asset Lock), or the identity signature (Shield from Identity) over the signable bytes. Shielded Transfer is the only transition with empty `extra_sighash_data`.

### Transparent signatures

Several shielded transitions also carry transparent signatures over the transparent side of the transition:

- **Shield** includes an array of [address witnesses](address-system.md#address-witness) (`inputWitnesses`) — one per address input. Each witness proves control of its corresponding Platform address. Address witness signatures are excluded from the bytes that feed the platform sighash (they sign the platform sighash output, not vice-versa).
- **Shield from Asset Lock** includes a 65-byte ECDSA `signature` proving control of the L1 asset-locked output, in the same form used by [Identity Create](identity.md#identity-create). The signature is excluded from the bytes that feed the platform sighash.
- **Shield from Identity** includes an identity `signature` and `signaturePublicKeyId`, in the same form used by [identity credit transfer](identity.md#identity-credit-transfer). Both are excluded from the signable bytes; the signature covers the Orchard bundle together with the identity and nonce.

Shielded Transfer, Unshield, Shielded Withdrawal, Identity Top Up From Shielded Pool, and the token transitions of types 26-28 have no transparent signatures; the Orchard bundle signatures plus the platform sighash provide full authorization.

## Querying shielded state

DAPI exposes a set of read-only endpoints for clients that need to fetch anchors, scan encrypted notes, verify nullifier status, or track shielded sync progress. See the [DAPI Platform endpoints reference](../reference/dapi-endpoints-platform-endpoints.md) for request and response shapes:

- [`getShieldedPoolState`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedpoolstate)
- [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors)
- [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor)
- [`getShieldedEncryptedNotes`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedencryptednotes)
- [`getShieldedNotesCount`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednotescount)
- [`getShieldedNullifiers`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednullifiers)
