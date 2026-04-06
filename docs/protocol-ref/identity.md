```{eval-rst}
.. _protocol-ref-identity:
```

# Identity

## Identity Overview

Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data. Please see the [Identity DIP](https://github.com/dashpay/dips/blob/master/dip-0011.md) for additional information.

Identities consist of multiple objects that are described in the following sections and listed in this summary table:

| Field           | Type           | Description                                 |
| --------------- | -------------- | ------------------------------------------- |
| [id](#identity-id) | array of bytes | The identity id (32 bytes)  |
| [publicKeys](#identity-publickeys) | array of keys  | Public key(s) associated with the identity |
| [balance](#identity-balance) | unsigned integer (64-bit) | Credit balance associated with the identity |
| revision        | integer        | Identity update revision                    |

See the [identity implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/v0/mod.rs#L36-L45) for more details.

**Example Identity**

```json
{
  "id":"6YfP6tT9AK8HPVXMK7CQrhpc8VMg7frjEnXinSPvUmZC",
  "publicKeys":[
    {
      "id":0,
      "type":0,
      "purpose":0,
      "securityLevel":0,
      "data":"AkWRfl3DJiyyy6YPUDQnNx5KERRnR8CoTiFUvfdaYSDS",
      "readOnly":false
    }
  ],
  "balance":0,
  "revision":0
}
```

### Identity id

The identity `id` is a unique identifier created from the double sha256 hash of the [outpoint](https://docs.dash.org/en/stable/docs/core/resources/glossary.html#outpoint) funding the identity creation. Typically it is displayed using Base58 encoding.

`id = base58(sha256(sha256(<identity create funding outpoint>)))`

:::{note}
The identity `id` uses the Dash Platform specific `application/x.dash.dpp.identifier` content media type. For additional information, please refer to the [js-dpp PR 252](https://github.com/dashevo/js-dpp/pull/252) that introduced it and [identifier.rs](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-platform-value/src/types/identifier.rs).
:::

See rs-dpp for examples of using [InstantSend](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/instant/instant_asset_lock_proof.rs#L146) or [ChainLocks](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/chain/chain_asset_lock_proof.rs#L54) to create the identity id.

### Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Multiple identities may use the same public key.

:::{note}
Each identity must have exactly one master key ([security level](#public-key-securitylevel) `0`) used for updating the identity. Having an additional key ([security level](#public-key-securitylevel) `1` or `2`) for signing state transitions is strongly recommended but not enforced by the protocol. The maximum number of keys is 15000 as [defined by rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/fields.rs#L7).
:::

Each item in the `publicKeys` array consists of an object containing:

| Field         | Type           | Description |
| ------------- | -------------- | ----------- |
| [id](#public-key-id) | integer        | The key id (all public keys must be unique) |
| [purpose](#public-key-purpose) | integer        | Public key purpose (`0` - Authentication, `1` - Encryption, `2` - Decryption, `3` - Transfer) |
| [securityLevel](#public-key-securitylevel) | integer        | Public key security level (`0` - Master, `1` - Critical, `2` - High, `3` - Medium) |
| contractBounds | object (optional) | Restricts this key to a specific data contract or document type context |
| [type](#public-key-type) | integer        | Type of key (default: `0` - ECDSA) |
| [readonly](#public-key-readonly) | boolean        | Identity public key can’t be modified with `readOnly` set to `true`. This can’t be changed after adding a key. |
| [data](#public-key-data)          | array of bytes | Public key (`0` - ECDSA: 33 bytes, `1` - BLS: 48 bytes, `2` - ECDSA Hash160: 20 bytes, `3` - [BIP13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) Hash160: 20 bytes, `4` - EDDSA_25519_HASH160: 20 bytes) |
| [disabledAt](#public-key-disabledat) | integer        | Timestamp indicating that the key was disabled at a specified time |
| signature     | array of bytes | Signature of the signable identity create or topup state transition by the private key associated with this public key |

See the [public key implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/identity_public_key/v0/mod.rs#L42-L53) for more details.

#### Public Key `id`

Each public key in an identity's `publicKeys` array must be assigned a unique index number (`id`).

#### Public Key `type`

The `type` field indicates the algorithm used to derive the key. Available key types [defined in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/identity_public_key/key_type.rs#L46-L53) include:

| Type | Size (bytes) | Description |
| :--: | :----------: | ----------- |
| `0`  | 33           | ECDSA Secp256k1 (default) |
| `1`  | 48           | BLS 12-381 |
| `2`  | 20           | ECDSA Secp256k1 Hash160 |
| `3`  | 20           | [BIP13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) pay-to-script-hash public key |
| `4`  | 20           | EDDSA 25519 Hash160 |

#### Public Key `data`

The `data` field contains the compressed public key.

#### Public Key `purpose`

The `purpose` field describes which operations are supported by the key. Please refer to [DIP11 - Identities](https://github.com/dashpay/dips/blob/master/dip-0011.md#keys) for additional information regarding this. Keys for some purposes must meet certain the security level criteria [defined by rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/public_key_in_creation/methods/validate_identity_public_keys_structure/v0/mod.rs#L22-L37) as detailed below:

| Type | Description    | Allowed Security Level(s) |
| :--: | -------------- | ------------------------- |
| `0`  | Authentication | Any security level        |
| `1`  | Encryption     | Medium                    |
| `2`  | Decryption     | Medium                    |
| `3`  | Transfer       | Critical                  |

The system automatically creates the following key types for masternodes and evonodes. They cannot
be created or updated manually:

| Type | Description    | Allowed Security Level |
| :--: | -------------- | ---------------------- |
| `4`  | System         | Critical               |
| `5`  | Voting         | High                   |
| `6`  | Owner          | Critical               |

#### Public Key `securityLevel`

The `securityLevel` field indicates how securely the key should be stored by clients. Please refer to [DIP11 - Identities](https://github.com/dashpay/dips/blob/master/dip-0011.md#keys) for additional information regarding this.

| Level | Description | Security Practice |
| :---: | ----------- | ----------------- |
|   0   | Master      | Should always require a user to authenticate when signing a transition. Can only be used to update an identity. |
|   1   | Critical    | Should always require a user to authenticate when signing a transition |
|   2   | High        | Should be available as long as the user has authenticated at least once during a session. Typically used to sign state transitions, but cannot be used for identity update transitions. |
|   3   | Medium      | Should not require user authentication but must require access to the client device |

#### Public Key `readOnly`

The `readOnly` field indicates that the public key can't be modified if it is set to `true`. The
value of this field cannot be changed after adding the key.

#### Public Key `disabledAt`

The `disabledAt` field indicates that the key has been disabled. Its value equals the timestamp when the key was disabled.

### Identity balance

Each identity has a balance of credits established by an [asset lock transaction](inv:user:std#ref-txs-assetlocktx) on the Core chain. This credit balance is used to pay the fees associated with state transitions.

## Identity Constants and Limits

The following constants and limits apply to identities:

| Constant | Value | Description |
|----------|-------|-------------|
| `IDENTITY_MAX_KEYS` | 15,000 | Maximum number of public keys per identity |
| `MAX_CREDITS` | 9,223,372,036,854,775,807 | Maximum credit balance (i64::MAX) |
| `max_public_keys_in_creation` | 6 | Maximum keys when creating an identity |
| `min_identity_funding_amount` | 200,000 credits | Minimum funding for address-based identity create and top-up transitions |
| `identity_create_base_cost` | 2,000,000 credits | Base fee for identity creation |
| `identity_key_in_creation_cost` | 6,500,000 credits | Fee per key during creation |
| `identity_topup_base_cost` | 500,000 credits | Base fee for identity top-up |

### Identity Creation Cost Calculation

The total cost to create an identity is:

```text
Total = identity_create_base_cost + (number_of_keys × identity_key_in_creation_cost)
```

**Examples:**

- 1 key: 2,000,000 + 6,500,000 = **8,500,000 credits** (0.000085 Dash)
- 2 keys: 2,000,000 + 13,000,000 = **15,000,000 credits** (0.00015 Dash)
- 6 keys: 2,000,000 + 39,000,000 = **41,000,000 credits** (0.00041 Dash)

### Minimum Funding Requirements

| Operation | Required Balance (credits) | Required Balance (Dash) |
|-----------|---------------------------|------------------------|
| Identity create (asset lock) | 200,000,000 | 0.002 |
| Identity top-up (asset lock) | 50,000,000 | 0.0005 |
| Address funding | 50,000,000 | 0.0005 |

:::{seealso}
For all protocol constants, see [Protocol Constants](protocol-constants.md).
:::

## Identity State Transition Details

There are five identity-related state transitions: [identity create](#identity-create), [identity topup](#identity-topup), [identity update](#identity-update), [identity credit transfer](#identity-credit-transfer), and [identity credit withdrawal](#identity-credit-withdrawal). Details are provided in this section including information about [asset locking](#asset-lock) and [signing](#identity-state-transition-signing) required for these state transitions.

:::{note}
Protocol Version 11 introduced additional address-based identity operations. See [Address-Based State Transitions](address-system.md) for:

- Identity Credit Transfer to Addresses (type 9)
- Identity Create from Addresses (type 10)
- Identity Top-Up from Addresses (type 11)
:::

### Identity Create

Identities are created on the platform by submitting the identity information in an identity create state transition.

| Field           | Type           | Description |
| --------------- | -------------- | ----------- |
| $version        | integer        | The state transition format version (currently `0`) |
| type            | integer        | State transition type (`2` for identity create) |
| publicKeys | array of [keys](#identity-publickeys) | Public key(s) associated with the identity |
| assetLockProof  | [proof object](#asset-lock) | Asset lock proof object proving the [asset lock transaction](inv:user:std#ref-txs-assetlocktx) exists on the Core chain and is locked |
| userFeeIncrease | integer        | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signature       | array of bytes | Signature of state transition data by the single-use key from the asset lock (65 bytes) |
| identityId      | array of bytes | An [identity id](#identity-id) for the identity being created (32 bytes). Computed from the asset lock proof outpoint and excluded from the serialized payload. |

See the [identity create implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_create_transition/v0/mod.rs#L47-L58) for more details.

### Identity TopUp

Identity credit balances are increased by submitting the topup information in an identity topup state transition.

| Field           | Type           | Description |
| --------------- | -------------- | ----------- |
| $version        | integer        | The state transition format version (currently `0`) |
| type            | integer        | State transition type (`3` for identity topup) |
| assetLockProof  | [proof object](#asset-lock) | Asset lock proof object proving the layer 1 locking transaction exists and is locked  |
| identityId      | array of bytes | An [identity id](#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |
| userFeeIncrease | integer        | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signature       | array of bytes | Signature of state transition data by the single-use key from the asset lock (65 bytes) |

See the [identity topup implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_topup_transition/v0/mod.rs#L43-L50) for more details.

### Identity Update

Identities are updated on the platform by submitting the identity information in an identity update state transition. This state transition requires either a set of one or more new public keys to add to the identity or a list of existing keys to disable.

| Field                | Type                 | Description |
| -------------------- | -------------------- | ----------- |
| $version             | integer              | The state transition format version (currently `0`) |
| type                 | integer              | State transition type (`5` for identity update) |
| identityId           | array of bytes       | The [identity id](#identity-id) (32 bytes) |
| revision             | integer              | Identity update revision |
| nonce                | unsigned integer (64 bits) | Identity nonce for this transition to prevent replay attacks |
| addPublicKeys        | array of public [keys](#identity-publickeys) | (Optional) Array of up to 6 new public keys to add to the identity. Required if adding keys. |
| disablePublicKeys    | array of integers    | (Optional) Array of up to 10 existing identity public key ID(s) to disable for the identity. Required if disabling keys. |
| userFeeIncrease | integer        | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | integer              | The ID of public key used to sign the state transition |
| signature            | array of bytes       | Signature of state transition data (65 bytes) |

See the [identity update implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_update_transition/v0/mod.rs#L43-L72) for more details.

### Identity Credit Transfer

Identities can transfer credits on the platform by submitting an identity credit transfer state transition. This state transition requires specifying the sender identity, recipient identity, transfer amount, and a signature for verification.

| Field                | Type           | Description |
| -------------------- | -------------- | ----------- |
| $version             | integer        | The state transition format version (currently `0`) |
| type                 | integer        | State transition type (`7` for identity credit transfer) |
| identityId           | array of bytes | The [identity id](#identity-id) of the sender (32 bytes) |
| recipientId          | array of bytes | The [identity id](#identity-id) of the recipient (32 bytes) |
| amount               | integer        | The credit amount to transfer |
| nonce                | unsigned integer (64 bits) | Identity nonce for this transition to prevent replay attacks |
| userFeeIncrease      | integer        | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | integer        | The ID of public key used to sign the state transition |
| signature            | array of bytes | Signature of state transition data (65 bytes) |

See the [identity credit transfer implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_transfer_transition/v0/mod.rs#L42-L53) for more details.

### Identity Credit Withdrawal

Credits can be withdrawn from an identity to an external Core wallet using an identity credit withdrawal state transition. This transition allows specifying the withdrawal amount, output script, and signing details.

| Field                | Type           | Description |
| -------------------- | -------------- | ----------- |
| $version             | integer        | The protocol version (currently `1`) |
| type                 | integer        | State transition type (`6` for identity credit withdrawal) |
| identityId           | array of bytes | An [identity id](#identity-id) (32 bytes) |
| amount               | integer        | The amount of credits to withdraw (64 bits) |
| coreFeePerByte       | integer        | Fee per byte for the transaction on Core (32 bits) |
| pooling              | integer        | Pooling mode for transaction batching |
| outputScript         | array of bytes | (Optional) The output script for receiving the withdrawal (if not set, defaults to Core address) |
| nonce                | unsigned integer (64 bits) | Identity nonce for this transition to prevent replay attacks |
| userFeeIncrease      | integer        | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | integer        | The ID of public key used to sign the state transition |
| signature            | array of bytes | Signature of state transition data (65 bytes) |

See the [identity credit withdrawal implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/v1/mod.rs#L35-L48) for more details.

### Asset Lock

The [identity create](#identity-create) and [identity topup](#identity-topup) state transitions both include an asset lock proof object. This object references the Core chain [asset lock transaction](inv:user:std#ref-txs-assetlocktx) and includes proof that the transaction is locked.

Currently there are two types of asset lock proofs [defined by rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/mod.rs#L135-L138): InstantSend and ChainLock. Transactions almost always receive InstantSend locks, so the InstantSend asset lock proof is the predominate type. See rs-dpp for examples of using [InstantSend](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/instant/instant_asset_lock_proof.rs) or [ChainLocks](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/chain/chain_asset_lock_proof.rs) as the asset lock proof.

#### InstantSend Asset Lock Proof

The InstantSend asset lock proof is used for transactions that have received an InstantSend lock. Asset locks using an InstantSend lock as proof must comply with this structure established in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/instant/instant_asset_lock_proof.rs#L38-L45).

| Field       | Type           | Description |
| ----------- | -------------- | ----------- |
| type        | integer        | The asset lock proof type (`0` for InstantSend locks) |
| instantLock | array of bytes | The InstantSend lock ([`islock`](https://docs.dash.org/en/stable/docs/core/reference/p2p-network-instantsend-messages.html#islock)) |
| transaction | array of bytes | The asset lock transaction |
| outputIndex | integer        | Index of the transaction output to be used |

#### ChainLock Asset Lock Proof

The ChainLock asset lock proof is used for transactions that have not received an InstantSend lock, but have been included in a block that has received a ChainLock. Asset locks using a ChainLock as proof must comply with this structure established in [rs-dpp](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-dpp/src/identity/state_transition/asset_lock_proof/chain/chain_asset_lock_proof.rs#L24-L29).

| Field                 | Type           | Description |
| --------------------- | -------------- | ----------- |
| type                  | integer        | The type of asset lock proof (`1` for ChainLocks) |
| coreChainLockedHeight | integer        | Height of the ChainLocked Core block containing the transaction |
| outPoint              | object         | The  [outpoint](https://docs.dash.org/en/stable/docs/core/resources/glossary.html#outpoint) being used as the asset lock |

### Identity State Transition Signing

:::{note}
The identity create and topup state transition signatures are unique in that they must be signed by the private key used in the layer 1 locking transaction. All other state transitions will be signed by a private key of the identity submitting them.
:::

The process to sign an identity create state transition consists of the following steps:

1. Create a canonical, signable version of the state transition encoded with [Bincode](https://github.com/bincode-org/bincode). The signable state transition excludes the following fields:
   - `identityId`
   - `signature` for all [public keys](#identity-publickeys)
   - `signature` for the overall state transition
2. Calculate the double SHA-256 hash of the encoded signable state transition
3. Sign the hash from the previous step using the private key associated with the asset lock transaction, then add the result to the state transition's `signature` field
4. For each public key being added to the identity, sign the hash from step 2 using the respective private key and add the result to the public key's `signature` field
5. Use Bincode to re-encode the state transition with all signatures and the identity id included
