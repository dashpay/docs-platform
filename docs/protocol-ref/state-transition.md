```{eval-rst}
.. _protocol-ref-state-transition:
```

# State Transition

## State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:

- [Common fields](#common-fields) present in all state transitions
- Additional fields specific to the type of action the state transition provides (e.g., [creating an identity](../protocol-ref/identity.md#identity-create))

### Fees

State transition fees are paid via the credits established when an identity is created. Credits are created at a rate of [1000 credits/satoshi](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/balances/credits.rs#L37). Fees for actions vary based on parameters related to storage and computational effort that are defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs).

### Size

All serialized data (including state transitions) is limited to a maximum size of [16 KB](http://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/util/cbor_serializer.rs#L8).

### Common Fields

The list of common fields used by multiple state transitions is defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/common_fields.rs). All state transitions include the following fields:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version        | unsigned integer | 32 bits | The platform protocol version (currently `1`) |
| type            | unsigned integer | 8 bits  | State transition type:<br>`0` - [data contract create](../protocol-ref/data-contract.md#data-contract-create)<br>`1` - [batch](#batch)<br>`2` - [identity create](../protocol-ref/identity.md#identity-create)<br>`3` - [identity topup](identity.md#identity-topup)<br>`4` - [data contract update](data-contract.md#data-contract-update)<br>`5` - [identity update](identity.md#identity-update)<br>`6` - [identity credit transfer](identity.md#identity-credit-transfer)<br>`7` - [identity credit withdrawal](identity.md#identity-credit-withdrawal)<br>`8` - [masternode vote](#masternode-vote) |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signature       | array of bytes | 65 bytes |Signature of state transition data |

Additionally, all state transitions except the identity create and topup state transitions include:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- |----------- |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |

## State Transition Types

Dash Platform Protocol defines the [state transition types](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transition_types.rs#L21-L32) that perform identity, contract, document, and token operations. See the subsections below for details on each state transition type.

### Batch

| Field       | Type           | Size | Description |
| ----------- | -------------- | ---- | ----------- |
| ownerId     | array of bytes | 32 bytes | [Identity](../protocol-ref/identity.md) submitting the document(s) |
| transitions | array of transition objects | Varies | A  batch of [document](../protocol-ref/document.md#document-overview) or token actions (up to 10 objects) |

More detailed information about the `transitions` array can be found in the [document section](../protocol-ref/document.md). See the implementation in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/v1/mod.rs#L29-L37).

### Data Contract Create

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| dataContract | [data contract object](../protocol-ref/data-contract.md#data-contract-object) | Varies | Object containing valid [data contract](../protocol-ref/data-contract.md) details |
| entropy      | array of bytes    | 32 bytes | Entropy used to generate the data contract ID |

More detailed information about the `dataContract` object can be found in the [data contract section](../protocol-ref/data-contract.md).

#### Entropy Generation

Entropy is included in [Data Contracts](../protocol-ref/data-contract.md#data-contract-create) and [Documents](../protocol-ref/document.md#document-create-transition). Dash Platform using the following entropy generator found in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/util/entropy_generator.rs#L12-L16):

```rust
// From the Rust reference implementation (rs-dpp)
// entropyGenerator.js
fn generate(&self) -> anyhow::Result<[u8; 32]> {
  let mut buffer = [0u8; 32];
  getrandom(&mut buffer).context("generating entropy failed")?;
  Ok(buffer)
}
```

### Data Contract Update

| Field           | Type           | Description |
| --------------- | -------------- | ----------- |
| dataContract | [data contract object](../protocol-ref/data-contract.md#data-contract-object) | Object containing valid [data contract](../protocol-ref/data-contract.md) details |

More detailed information about the `dataContract` object can be found in the [data contract section](../protocol-ref/data-contract.md).

### Identity Create

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| assetLockProof | array of bytes | 36 bytes | Lock [outpoint](https://docs.dash.org/en/stable/docs/core/resources/glossary.html#outpoint) from the layer 1 locking transaction (36 bytes) |
| publicKeys     | array of keys  | Varies | [Public key(s)](../protocol-ref/identity.md#identity-publickeys) associated with the identity (maximum number of keys: `10`) |

More detailed information about the `publicKeys` object can be found in the [identity section](../protocol-ref/identity.md).

### Identity TopUp

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| assetLockProof | array of bytes | 36 bytes | Lock [outpoint](https://docs.dash.org/en/stable/docs/core/resources/glossary.html#outpoint) from the layer 1 locking transaction (36 bytes) |
| identityId     | array of bytes | 32 bytes | An [Identity ID](../protocol-ref/identity.md#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |

### Identity Update

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| identityId      | array of bytes       | 32 bytes | The [Identity ID](../protocol-ref/identity.md#identity-id) for the identity being updated |
| revision        | unsigned integer     | 64 bits | Identity update revision. Used for optimistic concurrency control. Incremented by one with each new update so that the update will fail if the underlying data is modified between reading and writing. |
| nonce           | unsigned integer     | 64 bits | Identity nonce for this transition to prevent replay attacks |
| addPublicKeys   | array of public keys | Varies | (Optional) Array of up to 10 new public keys to add to the identity. Required if adding keys. |
| disablePublicKeys | array of integers  | Varies | (Optional) Array of up to 10 existing identity public key ID(s) to disable for the identity. Required if disabling keys. |

### Identity Credit Transfer

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| identityId      | array of bytes | 32 bytes | An [Identity ID](../protocol-ref/identity.md#identity-id) for the identity sending the credits |
| recipientId     | array of bytes | 32 bytes | An [Identity ID](../protocol-ref/identity.md#identity-id) for the identity receiving the credits |
| amount          | unsigned integer | 64 bits | Number of credits being transferred |
| nonce           | unsigned integer | 64 bits | Identity nonce for this transition to prevent replay attacks |

See the implementation in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_transfer_transition/v0/mod.rs#L39-L50).

### Identity Credit Withdrawal

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| identityId      | array of bytes | 32 bytes | An [Identity ID](../protocol-ref/identity.md#identity-id) for the identity sending the credits |
| amount          | unsigned integer | 64 bits | Number of credits being transferred |
| coreFeePerByte  | unsigned integer | 32 bytes |  |
| pooling         | unsigned integer | 8 bytes | 0 = Never, 1 = If Available, 2 = Standard |
| outputScript    | script | Varies | If None, the withdrawal is sent to the address set by Core |
| nonce           | unsigned integer | 64 bits | Identity nonce for this transition to prevent replay attacks |

See the implementation in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/v1/mod.rs#L32-L45).

### Masternode Vote

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| proTxHash       | array of bytes | 32 bytes | An identifier based on a masternode or evonode's [provider registration transaction](inv:user:std#ref-txs-proregtx) hash |
| voterIdentityId | array of bytes | 32 bytes | The voter's [Identity ID](../protocol-ref/identity.md#identity-id). This will be a masternode identity based on the protx hash. |
| vote | [Vote](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/voting/votes/mod.rs#L20-L22) | Varies | Vote information |
| nonce           | unsigned integer | 64 bits | Identity nonce for this transition to prevent replay attacks |

See the implementation in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/masternode_vote_transition/v0/mod.rs#L40-L50).

## State Transition Signing

State transitions must be cryptographically signed to prove that an authorized party submitted them.
There are two ways to sign state transitions, with the difference being the source of the private
key used for signing. The following table specifies which signing method is used by each state
transition type:

| Signing Method | State Transitions |
| -------------- | ----------------- |
| [Identity](#signing-with-identity)     | Batch, Contract create, Contract update, Identity update, Identity credit transfer, Identity credit withdrawal, Masternode vote |
| [Asset lock](#signing-with-asset-lock) | Identity create, Identity topup                                                                       |

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

### Signing public keys

Public keys can be added to an identity by the identity create or identity update state transitions. Any new public keys must include a signature to prove that the associated private key is accessible. To sign new public keys:

1. **Get the double SHA-256 hash** of the encoded signable state transition from step 2 of the [signing with asset lock](#signing-with-asset-lock) or [signing with identity](#signing-with-identity) section.
2. **Sign each new public key**:
   - Use the private key that derived the public key to sign the hash.
   - Store the result in the public key's `signature` field.

### Non-signable Fields

This table shows the fields that must be excluded when creating state transition signatures. All transitions exclude the signature field. Some transitions contain other fields that must be excluded also. Click the state transition name to see the rs-dpp implementation for additional context.

| State transition | Signature | Signature public key ID | Identity ID | Identity public key signature(s) |
| - | :-: | :-: | :-: | :-: |
| [Batch](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/v1/mod.rs#L34-L37) | Exclude | Exclude | N/A | N/A |
| [Contract create](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_create_transition/v0/mod.rs#L41-L44) | Exclude | Exclude | N/A | N/A |
| [Contract update](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_update_transition/v0/mod.rs#L41-L44) | Exclude | Exclude | N/A | N/A |
| [Identity create](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_create_transition/v0/mod.rs#L50-L54) | Exclude | N/A | Exclude | [Exclude](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/public_key_in_creation/v0/mod.rs#L47-L48) |
| [Identity topup](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_topup_transition/v0/mod.rs#L45-L46)  | Exclude | N/A | N/A | N/A |
| [Identity update](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_update_transition/v0/mod.rs#L63-L68) | Exclude | Exclude | N/A | [Exclude for any keys being added by the state transition](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/public_key_in_creation/v0/mod.rs#L47-L48) |
| [Identity credit transfer](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_transfer_transition/v0/mod.rs#L46-L49) | Exclude | Exclude | N/A | N/A |
| [Identity credit withdrawal](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/v1/mod.rs#L41-L44) | Exclude | Exclude | N/A | N/A |
| [Masternode vote](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/masternode_vote_transition/v0/mod.rs#L46-L49) | Exclude | Exclude | N/A | N/A |
