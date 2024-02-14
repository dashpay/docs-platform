```{eval-rst}
.. _protocol-ref-state-transition:
```

# State Transition

## State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:

- [Common fields](#common-fields) present in all state transitions
- Additional fields specific to the type of action the state transition provides (e.g. [creating an identity](../protocol-ref/identity.md#identity-creation))

### Fees

State transition fees are paid via the credits established when an identity is created. Credits are created at a rate of [1000 credits/satoshi](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/identity/credits_converter.rs#L3). Fees for actions vary based on parameters related to storage and computational effort that are defined in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/state_transition/fee/constants.rs).

### Size

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/util/serializer.rs#L8).

### Common Fields

All state transitions include the following fields:

| Field           | Type           | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| --------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| protocolVersion | integer        | The platform protocol version (currently `1`)                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| type            | integer        | State transition type:<br>`0` - [data contract create](../protocol-ref/data-contract.md#data-contract-creation)<br>`1` - [documents batch](../protocol-ref/document.md#document-submission)<br>`2` - [identity create](../protocol-ref/identity.md#identity-creation)<br>`3` - [identity topup](identity.md#identity-topup)<br>`4` - [data contract update](data-contract.md#data-contract-update)<br>`5` - [identity update](identity.md#identity-update) |
| signature       | array of bytes | Signature of state transition data (65 bytes)                                                                                                                                                                                                                                                                                                                                                                                                                                         |

Additionally, all state transitions except the identity create and topup state transitions include:

| Field                | Type    | Description                                                                                                                               |
| -------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| signaturePublicKeyId | integer | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |

## State Transition Types

### Data Contract Create

| Field        | Type                                                                                   | Description                                                                                |
| ------------ | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| dataContract | [data contract object](../protocol-ref/data-contract.md#data-contract-object) | Object containing valid [data contract](../protocol-ref/data-contract.md) details |
| entropy      | array of bytes                                                                         | Entropy used to generate the data contract ID (32 bytes)                                   |

More detailed information about the `dataContract` object can be found in the [data contract section](../protocol-ref/data-contract.md).

#### Entropy Generation

Entropy is included in [Data Contracts](../protocol-ref/data-contract.md#data-contract-creation) and [Documents](../protocol-ref/document.md#document-create-transition).

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

| Field        | Type                                                                                   | Description                                                                                |
| ------------ | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| dataContract | [data contract object](../protocol-ref/data-contract.md#data-contract-object) | Object containing valid [data contract](../protocol-ref/data-contract.md) details |

More detailed information about the `dataContract` object can be found in the [data contract section](../protocol-ref/data-contract.md).

### Documents Batch

| Field       | Type                        | Description                                                                            |
| ----------- | --------------------------- | -------------------------------------------------------------------------------------- |
| ownerId     | array of bytes              | [Identity](../protocol-ref/identity.md) submitting the document(s) (32 bytes) |
| transitions | array of transition objects | Document `create`, `replace`, or `delete` transitions (up to 10 objects)               |

More detailed information about the `transitions` array can be found in the [document section](../protocol-ref/document.md).

### Identity Create

| Field          | Type           | Description                                                                                                                                          |
| -------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| assetLockProof | array of bytes | Lock [outpoint](https://docs.dash.org/projects/core/en/stable/docs/resources/glossary.html#outpoint) from the layer 1 locking transaction (36 bytes) |
| publicKeys     | array of keys  | [Public key(s)](../protocol-ref/identity.md#identity-publickeys) associated with the identity (maximum number of keys: `10`)                |

More detailed information about the `publicKeys` object can be found in the [identity section](../protocol-ref/identity.md).

### Identity TopUp

| Field          | Type           | Description                                                                                                                                          |
| -------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| assetLockProof | array of bytes | Lock [outpoint](https://docs.dash.org/projects/core/en/stable/docs/resources/glossary.html#outpoint) from the layer 1 locking transaction (36 bytes) |
| identityId     | array of bytes | An [Identity ID](../protocol-ref/identity.md#identity-id) for the identity receiving the topup (can be any identity) (32 bytes)             |

### Identity Update

| Field                | Type                 | Description                                                                                                                                                                                             |
| -------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| identityId           | array of bytes       | The [Identity ID](../protocol-ref/identity.md#identity-id) for the identity being updated (32 bytes)                                                                                           |
| revision             | integer              | Identity update revision. Used for optimistic concurrency control. Incremented by one with each new update so that the update will fail if the underlying data is modified between reading and writing. |
| addPublicKeys        | array of public keys | (Optional) Array of up to 10 new public keys to add to the identity. Required if adding keys.                                                                                                           |
| disablePublicKeys    | array of integers    | (Optional) Array of up to 10 existing identity public key ID(s) to disable for the identity. Required if disabling keys.                                                                                |
| publicKeysDisabledAt | integer              | (Optional) Timestamp when keys were disabled. Required if `disablePublicKeys` is present.                                                                                                               |

## State Transition Signing

State transitions must be signed by a private key associated with the identity creating the state transition. Since v0.23, each identity must have at least two keys: a primary key (security level `0`) that is only used when signing identity update state transitions and an additional key (security level `2`) that is used to sign all other state transitions.

The process to sign a state transition consists of the following steps:

1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the identity creating the state transition
3. Set the state transition `signature` to the value of the signature created in the previous step
4. For all state transitions _other than identity create or topup_, set the state transition`signaturePublicKeyId` to the [public key `id`](../protocol-ref/identity.md#public-key-id) corresponding to the key used to sign

### Signature Validation

The `signature` validation (see [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/unit/stateTransition/validation/validateStateTransitionIdentitySignatureFactory.spec.js)) verifies that:

1. The identity exists
2. The identity has a public key
3. The identity's public key is of type `ECDSA`
4. The state transition signature is valid

The example test output below shows the necessary criteria:

```text
validateStateTransitionIdentitySignatureFactory
  ✔ should pass properly signed state transition
  ✔ should return invalid result if owner id doesn't exist
  ✔ should return MissingPublicKeyError if the identity doesn't have a matching public key
  ✔ should return InvalidIdentityPublicKeyTypeError if type is not exist
  ✔ should return InvalidStateTransitionSignatureError if signature is invalid
  Consensus errors
    ✔ should return InvalidSignaturePublicKeySecurityLevelConsensusError if InvalidSignaturePublicKeySecurityLevelError was thrown
    ✔ should return PublicKeySecurityLevelNotMetConsensusError if PublicKeySecurityLevelNotMetError was thrown
    ✔ should return WrongPublicKeyPurposeConsensusError if WrongPublicKeyPurposeError was thrown
    ✔ should return PublicKeyIsDisabledConsensusError if PublicKeyIsDisabledError was thrown
    ✔ should return InvalidStateTransitionSignatureError if DPPError was thrown
    ✔ should throw unknown error
    ✔ should not verify signature on dry run
```
