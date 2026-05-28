```{eval-rst}
.. _protocol-ref-state-transition:
```

# State Transition

## State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:

- [Common fields](#common-fields) present in all state transitions
- Additional fields specific to the type of action the state transition provides (e.g., [creating an identity](../protocol-ref/identity.md#identity-create))

### Fees

State transition fees are paid via the credits established when an identity is created. Credits are created at a rate of [1000 credits/satoshi](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/balances/credits.rs#L42). Fees for actions vary based on parameters related to storage and computational effort that are defined in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/fee/default_costs/constants.rs).

### Size

State transitions are limited to a maximum size of [20 KB](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L6).

### Common Fields

The list of common fields used by multiple state transitions is defined in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/common_fields.rs). All state transitions include the following fields:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version        | unsigned integer | 16 bits | The state transition format version (FeatureVersion). Currently `0` for most transitions, `1` for Batch. This is not the global platform protocol version, which is negotiated separately. |
| type            | unsigned integer | 8 bits  | State transition type discriminator (defined in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transition_types.rs#L21)). See [State Transition Types](#state-transition-types) for the full list. |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signature       | array of bytes | 65 bytes |Signature of state transition data |

:::{note}
The [masternode vote](#masternode-vote) transition does not include the `userFeeIncrease` field.
:::

Additionally, all state transitions except the identity create and topup state transitions include:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- |----------- |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |

## State Transition Types

Dash Platform Protocol defines the following [state transition types](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transition_types.rs#L21-L43). Most are documented in detail on the protocol reference page for the feature they operate on. Batch and Masternode Vote do not have a dedicated feature page; their formats are documented inline below.

| Type | Name | Documented in |
| --- | --- | --- |
| 0 | Data Contract Create | [Data Contract Create](data-contract.md#data-contract-create) |
| 1 | Batch | [Batch](#batch) (below) |
| 2 | Identity Create | [Identity Create](identity.md#identity-create) |
| 3 | Identity TopUp | [Identity TopUp](identity.md#identity-topup) |
| 4 | Data Contract Update | [Data Contract Update](data-contract.md#data-contract-update) |
| 5 | Identity Update | [Identity Update](identity.md#identity-update) |
| 6 | Identity Credit Withdrawal | [Identity Credit Withdrawal](identity.md#identity-credit-withdrawal) |
| 7 | Identity Credit Transfer | [Identity Credit Transfer](identity.md#identity-credit-transfer) |
| 8 | Masternode Vote | [Masternode Vote](#masternode-vote) (below) |
| 9 | Identity Credit Transfer to Addresses | [Identity Credit Transfer to Addresses](address-system.md#identity-credit-transfer-to-addresses) |
| 10 | Identity Create from Addresses | [Identity Create from Addresses](address-system.md#identity-create-from-addresses) |
| 11 | Identity TopUp from Addresses | [Identity TopUp from Addresses](address-system.md#identity-top-up-from-addresses) |
| 12 | Address Funds Transfer | [Address Funds Transfer](address-system.md#address-funds-transfer) |
| 13 | Address Funding from Asset Lock | [Address Funding from Asset Lock](address-system.md#address-funding-from-asset-lock) |
| 14 | Address Credit Withdrawal | [Address Credit Withdrawal](address-system.md#address-credit-withdrawal) |
| 15 | Shield | [Shield](shielded-pool.md#shield) |
| 16 | Shielded Transfer | [Shielded Transfer](shielded-pool.md#shielded-transfer) |
| 17 | Unshield | [Unshield](shielded-pool.md#unshield) |
| 18 | Shield from Asset Lock | [Shield from Asset Lock](shielded-pool.md#shield-from-asset-lock) |
| 19 | Shielded Withdrawal | [Shielded Withdrawal](shielded-pool.md#shielded-withdrawal) |

### Batch

| Field       | Type           | Size | Description |
| ----------- | -------------- | ---- | ----------- |
| ownerId     | array of bytes | 32 bytes | [Identity](../protocol-ref/identity.md) submitting the document(s) or token action(s) |
| transitions | array of transition objects | Varies | A batch of [document](../protocol-ref/document.md#document-overview) or token actions (currently limited to [1 object per batch](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L7)) |

More detailed information about the `transitions` array can be found in the [document section](../protocol-ref/document.md). See the implementation in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/v1/mod.rs#L31-L39).

### Masternode Vote

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| proTxHash       | array of bytes | 32 bytes | An identifier based on a masternode or evonode's [provider registration transaction](inv:user:std#ref-txs-proregtx) hash |
| voterIdentityId | array of bytes | 32 bytes | The voter's [Identity ID](../protocol-ref/identity.md#identity-id). This will be a masternode identity based on the protx hash. |
| vote | [Vote](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/voting/votes/mod.rs#L25-L27) | Varies | Vote information |
| nonce           | unsigned integer | 64 bits | Identity nonce for this transition to prevent replay attacks |

See the implementation in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/masternode_vote_transition/v0/mod.rs#L43-L53).

## State Transition Signing

State transitions must be cryptographically signed to prove that an authorized party submitted them.
There are three ways to sign state transitions, with the difference being the source of the private
key used for signing. The following table specifies which signing method is used by each state
transition type:

| Signing Method | State Transitions |
| -------------- | ----------------- |
| [Identity](#signing-with-identity)     | Batch, Contract create, Contract update, Identity update, Identity credit transfer, Identity credit transfer to addresses, Identity credit withdrawal, Masternode vote |
| [Asset lock](#signing-with-asset-lock) | Identity create, Identity topup, Address funding from asset lock\*, Shield from asset lock\*\* |
| [Address witness](#signing-with-address-witness) | Identity create from addresses, Identity topup from addresses, Address funds transfer, Address credit withdrawal, Address funding from asset lock\*, Shield\*\* |
| [Shielded (Orchard)](shielded-pool.md#shielded-transition-signing) | Shield\*\*, Shielded transfer, Unshield, Shield from asset lock\*\*, Shielded withdrawal |

\* Address funding from asset lock requires both an asset lock signature and address witnesses (`input_witnesses`).

\*\* Shielded transitions are always authorized by Orchard bundle signatures (per-action `spendAuthSig` plus the transition-level `bindingSignature`). Shield additionally carries address witnesses for its transparent address inputs; Shield from asset lock additionally carries an asset-lock ECDSA signature.

:::{note}
Address-based state transitions (types 9-14) were introduced in Protocol Version 11. For detailed information on these transitions, see [Address-Based State Transitions](address-system.md).
:::

### Signing with Asset Lock

The identity create and topup state transition signatures are unique in that they must be signed by
the private key used in the Core chain asset lock transaction funding the identity. The signing
process consists of the following steps:

1. **Create a canonical, signable state transition** encoded using [Bincode](https://github.com/bincode-org/bincode).
   - Exclude the `signature` field and any other non-signable fields indicated in the [table below](#non-signable-fields).
2. **Calculate the double SHA-256 hash** of the encoded signable state transition.
3. **Sign the computed hash** using the private key associated with the asset lock transaction.
4. **Store the signature** in the state transition's `signature` field.
5. **For _identity create_ only, sign any public keys** as described in the [signing public keys](#signing-public-keys) section.
6. **Finalize the state transition** by re-encoding it with Bincode, including all previously excluded fields such as `signature`.

### Signing with Identity

Most state transitions must be signed by a private key associated with the identity creating the
state transition. Each identity must have at least two keys: a primary key ([security
level](./identity.md#public-key-securitylevel) `0`) that is only used when signing [identity
update](identity.md#identity-update) state transitions and an additional key ([security
level](./identity.md#public-key-securitylevel) `2`) that is used to sign all other state
transitions.

The process to sign state transitions using an identity consists of the following steps:

1. **Create a canonical, signable state transition** encoded using [Bincode](https://github.com/bincode-org/bincode).
   - Certain fields must excluded before signing. See the [non-signable fields table](#non-signable-fields) for details.
2. **Calculate the double SHA-256 hash** of the encoded signable state transition.
3. **Sign the computed hash** using the identity's relevant private key.
4. **Store the signature** in the state transition's `signature` field
5. **For _identity update_ only, sign any added public keys** as described in the [signing public keys](#signing-public-keys) section.
6. **Finalize the state transition** by re-encoding it with Bincode, including all previously excluded fields such as `signature`.

### Signing with Address Witness

Address-based state transitions (types 10-12, 14) use address witnesses to prove ownership of Platform addresses. Unlike identity-signed transitions, these do not require an existing identity. Instead, each input address requires a corresponding witness containing cryptographic proof of address ownership.

:::{note}
Identity credit transfer to addresses (type 9) is **not** signed with address witnesses — it uses identity signing because it requires an existing identity.
:::

The process to sign state transitions using address witnesses consists of the following steps:

1. **Create a canonical, signable state transition** encoded using [Bincode](https://github.com/bincode-org/bincode).
   - Exclude the `input_witnesses` field and any other non-signable fields.
2. **Calculate the double SHA-256 hash** of the encoded signable state transition.
3. **For each input address**, create an appropriate witness:
   - **P2PKH addresses**: Create a recoverable ECDSA signature (65 bytes) using the private key that derives the address.
   - **P2SH multisig addresses**: Collect the required number of signatures and include the redeem script.
4. **Store witnesses** in the state transition's `input_witnesses` field in the same order as inputs.
5. **Finalize the state transition** by re-encoding it with Bincode, including all previously excluded fields.

For detailed information on address witnesses and Platform addresses, see [Address-Based State Transitions](address-system.md#common-components).

### Signing public keys

Public keys can be added to an identity by the identity create or identity update state transitions. Any new public keys must include a signature to prove that the associated private key is accessible. To sign new public keys:

1. **Get the double SHA-256 hash** of the encoded signable state transition from step 2 of the [signing with asset lock](#signing-with-asset-lock) or [signing with identity](#signing-with-identity) section.
2. **Sign each new public key**:
   - Use the private key that derived the public key to sign the hash.
   - Store the result in the public key's `signature` field.

### Signing Shielded Transitions

Shielded transitions are not signed by an identity public key or an address private key at the transition level — they do not include `signature` or `signaturePublicKeyId` fields. Authorization is carried instead by Orchard primitives attached to each action and to the bundle as a whole. Shield additionally carries [address witnesses](#signing-with-address-witness) over its address inputs, and Shield from asset lock additionally carries an [asset-lock ECDSA signature](#signing-with-asset-lock). Both `input_witnesses` (on Shield) and `signature` (on Shield from asset lock) are omitted from the bytes that feed the platform sighash.

See [Shielded Transition Signing](shielded-pool.md#shielded-transition-signing) for the full signing model.

### Non-signable Fields

This table shows the fields that must be excluded when creating state transition signatures. All transitions exclude the signature field. Some transitions contain other fields that must be excluded also. Click the state transition name to see the rs-dpp implementation for additional context.

| State transition | Signature | Signature public key ID | Identity ID | Identity public key signature(s) |
| - | :-: | :-: | :-: | :-: |
| [Batch](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/v1/mod.rs#L35-L38) | Exclude | Exclude | N/A | N/A |
| [Contract create](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_create_transition/v0/mod.rs#L44-L47) | Exclude | Exclude | N/A | N/A |
| [Contract update](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_update_transition/v0/mod.rs#L43-L46) | Exclude | Exclude | N/A | N/A |
| [Identity create](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_create_transition/v0/mod.rs#L53-L57) | Exclude | N/A | Exclude | [Exclude](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/public_key_in_creation/v0/mod.rs#L50-L51) |
| [Identity topup](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_topup_transition/v0/mod.rs#L48-L49)  | Exclude | N/A | N/A | N/A |
| [Identity update](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_update_transition/v0/mod.rs#L67-L71) | Exclude | Exclude | N/A | [Exclude for any keys being added by the state transition](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/public_key_in_creation/v0/mod.rs#L50-L51) |
| [Identity credit transfer](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_transfer_transition/v0/mod.rs#L49-L52) | Exclude | Exclude | N/A | N/A |
| [Identity credit withdrawal](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/v1/mod.rs#L44-L47) | Exclude | Exclude | N/A | N/A |
| [Masternode vote](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/masternode_vote_transition/v0/mod.rs#L49-L52) | Exclude | Exclude | N/A | N/A |

:::{note}
The table above does not cover shielded transitions, which do not carry transition-level `signature` or `signaturePublicKeyId` fields. See [Signing Shielded Transitions](#signing-shielded-transitions).
:::
