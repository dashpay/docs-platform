```{eval-rst}
.. _protocol-ref-identity:
```

# Identity

## Identity Overview

Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data. Please see the [Identity DIP](https://github.com/dashpay/dips/blob/master/dip-0011.md) for additional information.

Identities consist of three components that are described in further detail in the following sections:

| Field           | Type           | Description                                 |
| --------------- | -------------- | ------------------------------------------- |
| protocolVersion | integer        | The protocol version                        |
| id              | array of bytes | The identity id (32 bytes)                  |
| publicKeys      | array of keys  | Public key(s) associated with the identity  |
| balance         | integer        | Credit balance associated with the identity |
| revision        | integer        | Identity update revision                    |

Each identity must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/identity.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 32,
      "uniqueItems": true
    },
    "balance": {
      "type": "integer",
      "minimum": 0
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "description": "Identity update revision"
  }
},
  "required": [
    "protocolVersion",
    "id",
    "publicKeys",
    "balance",
    "revision"
  ]
}
```

**Example Identity**

```json
{
  "protocolVersion":1,
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

The identity `id` is calculated by Base58 encoding the double sha256 hash of the [outpoint](https://docs.dash.org/projects/core/en/stable/docs/resources/glossary.html#outpoint) used to fund the identity creation.

`id = base58(sha256(sha256(<identity create funding output>)))`

**Note:** The identity `id` uses the Dash Platform specific `application/x.dash.dpp.identifier` content media type. For additional information, please refer to the [js-dpp PR 252](https://github.com/dashevo/js-dpp/pull/252) that introduced it and [identifier.rs](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-platform-value/src/types/identifier.rs).

### Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Multiple identities may use the same public key.

**Note:** Since v0.23, each identity must have at least two public keys: a primary key (security level `0`) that is only used when updating the identity and an additional one (security level `2`) used to sign state transitions.

Each item in the `publicKeys` array consists of an object containing:

| Field         | Type           | Description                                                                                                                                                                     |
| ------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id            | integer        | The key id (all public keys must be unique)                                                                                                                                     |
| type          | integer        | Type of key (default: 0 - ECDSA)                                                                                                                                                |
| data          | array of bytes | Public key (0 - ECDSA: 33 bytes, 1 - BLS: 48 bytes, 2 - ECDSA Hash160: 20 bytes, 3 - [BIP13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) Hash160: 20 bytes) |
| purpose       | integer        | Public key purpose (0 - Authentication, 1 - Encryption, 2 - Decryption, 3 - Withdraw)                                                                                           |
| securityLevel | integer        | Public key security level (0 - Master, 1 - Critical, 2 - High, 3 - Medium)                                                                                                      |
| readonly      | boolean        | Identity public key can't be modified with `readOnly` set to `true`. This can’t be changed after adding a key.                                                                  |
| disabledAt    | integer        | Timestamp indicating that the key was disabled at a specified time                                                                                                              |

Keys for some purposes must meet certain [security level criteria](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/identity/identity_public_key/security_level.rs#L62-L77) as detailed below:

| Key Purpose    | Allowed Security Level(s) |
| -------------- | ------------------------- |
| Authentication | Any security level        |
| Encryption     | Medium                    |
| Decryption     | Medium                    |
| Withdraw       | Critical                  |

Each identity public key must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/publicKey.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "minimum": 0,
      "description": "Public key ID",
      "$comment": "Must be unique for the identity. It can’t be changed after adding a key. Included when signing state transitions to indicate which identity key was used to sign."
    },
    "type": {
      "type": "integer",
      "enum": [
        0,
        1,
        2,
        3
      ],
      "description": "Public key type. 0 - ECDSA Secp256k1, 1 - BLS 12-381, 2 - ECDSA Secp256k1 Hash160, 3 - BIP 13 Hash160",
      "$comment": "It can't be changed after adding a key"
    },
    "purpose": {
      "type": "integer",
      "enum": [
        0,
        1,
        2,
        3
      ],
      "description": "Public key purpose. 0 - Authentication, 1 - Encryption, 2 - Decryption, 3 - Withdraw",
      "$comment": "It can't be changed after adding a key"
    },
    "securityLevel": {
      "type": "integer",
      "enum": [
        0,
        1,
        2,
        3
      ],
      "description": "Public key security level. 0 - Master, 1 - Critical, 2 - High, 3 - Medium",
      "$comment": "It can't be changed after adding a key"
    },
    "data": true,
    "readOnly": {
      "type": "boolean",
      "description": "Read only",
      "$comment": "Identity public key can't be modified with readOnly set to true. It can’t be changed after adding a key"
    },
    "disabledAt": {
      "type": "integer",
      "description": "Timestamp indicating that the key was disabled at a specified time",
      "minimum": 0
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "type": {
            "const": 0
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "type": "array",
            "byteArray": true,
            "minItems": 33,
            "maxItems": 33,
            "description": "Raw ECDSA public key",
            "$comment": "It must be a valid key of the specified type and unique for the identity. It can’t be changed after adding a key"
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "type": {
            "const": 1
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "type": "array",
            "byteArray": true,
            "minItems": 48,
            "maxItems": 48,
            "description": "Raw BLS public key",
            "$comment": "It must be a valid key of the specified type and unique for the identity. It can’t be changed after adding a key"
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "type": {
            "const": 2
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "type": "array",
            "byteArray": true,
            "minItems": 20,
            "maxItems": 20,
            "description": "ECDSA Secp256k1 public key Hash160",
            "$comment": "It must be a valid key hash of the specified type and unique for the identity. It can’t be changed after adding a key"
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "type": {
            "const": 3
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "type": "array",
            "byteArray": true,
            "minItems": 20,
            "maxItems": 20,
            "description": "BIP13 script public key",
            "$comment": "It must be a valid script hash of the specified type and unique for the identity"
          }
        }
      }
    }
  ],
  "required": [
    "id",
    "type",
    "data",
    "purpose",
    "securityLevel"
  ],
  "additionalProperties": false
}
```

#### Public Key `id`

Each public key in an identity's `publicKeys` array must be assigned a unique index number (`id`).

#### Public Key `type`

The `type` field indicates the algorithm used to derive the key.

| Type | Description                                                                                           |
| :--: | ----------------------------------------------------------------------------------------------------- |
|   0  | ECDSA Secp256k1 (default)                                                                             |
|   1  | BLS 12-381                                                                                            |
|   2  | ECDSA Secp256k1 Hash160                                                                               |
|   3  | [BIP13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) pay-to-script-hash public key |

#### Public Key `data`

The `data` field contains the compressed public key.

#### Public Key `purpose`

The `purpose` field describes which operations are supported by the key. Please refer to [DIP11 - Identities](https://github.com/dashpay/dips/blob/master/dip-0011.md#keys) for additional information regarding this.

| Type | Description    |
| :--: | -------------- |
|   0  | Authentication |
|   1  | Encryption     |
|   2  | Decryption     |
|   3  | Withdraw       |

#### Public Key `securityLevel`

The `securityLevel` field indicates how securely the key should be stored by clients. Please refer to [DIP11 - Identities](https://github.com/dashpay/dips/blob/master/dip-0011.md#keys) for additional information regarding this.

| Level | Description | Security Practice                                                                                                                                                                       |
| :---: | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   0   | Master      | Should always require a user to authenticate when signing a transition. Can only be used to update an identity.                                                                         |
|   1   | Critical    | Should always require a user to authenticate when signing a transition                                                                                                                  |
|   2   | High        | Should be available as long as the user has authenticated at least once during a session. Typically used to sign state transitions, but cannot be used for identity update transitions. |
|   3   | Medium      | Should not require user authentication but must require access to the client device                                                                                                     |

#### Public Key `readOnly`

The `readOnly` field indicates that the public key can't be modified if it is set to `true`. The  
value of this field cannot be changed after adding the key.

#### Public Key `disabledAt`

The `disabledAt` field indicates that the key has been disabled. Its value equals the timestamp when the key was disabled.

### Identity balance

Each identity has a balance of credits established by value locked via a layer 1 lock transaction. This credit balance is used to pay the fees associated with state transitions.

## Identity State Transition Details

There are three identity-related state transitions: [identity create](#identity-creation), [identity topup](#identity-topup), and [identity update](#identity-update). Details are provided in this section including information about [asset locking](#asset-lock) and [signing](#identity-state-transition-signing) required for these state transitions.

### Identity Creation

Identities are created on the platform by submitting the identity information in an identity create state transition.

| Field           | Type           | Description                                                                                         |
| --------------- | -------------- | --------------------------------------------------------------------------------------------------- |
| protocolVersion | integer        | The protocol version (currently `1`)                                                                |
| type            | integer        | State transition type (`2` for identity create)                                                     |
| assetLockProof  | object         | [Asset lock proof object](#asset-lock) proving the layer 1 locking transaction exists and is locked |
| publicKeys      | array of keys  | [Public key(s)](#identity-publickeys) associated with the identity                                  |
| signature       | array of bytes | Signature of state transition data by the single-use key from the asset lock (65 bytes)             |

Each identity must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/stateTransition/identityCreate.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "type": {
      "type": "integer",
      "const": 2
    },
    "assetLockProof": {
      "type": "object"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "uniqueItems": true
    },
    "signature": {
      "type": "array",
      "byteArray": true,
      "minItems": 65,
      "maxItems": 65,
      "description": "Signature made by AssetLock one time ECDSA key"
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "assetLockProof",
    "publicKeys",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion":1,
  "type":2,
  "signature":"IBTTgge+/VDa/9+n2q3pb4tAqZYI48AX8X3H/uedRLH5dN8Ekh/sxRRQQS9LaOPwZSCVED6XIYD+vravF2dhYOE=",
  "assetLockProof":{
    "type":0,
    "instantLock":"AQHDHQdekbFZJOQFEe1FnRjoDemL/oPF/v9IME/qphjt5gEAAAB/OlZB9p8vPzPE55MlegR7nwhXRpZC4d5sYnOIypNgzfdDRsW01v8UtlRoORokjoDJ9hA/XFMK65iYTrQ8AAAAGI4q8GxtK9LHOT1JipnIfwiiv8zW+C/sbokbMhi/BsEl51dpoeBQEUAYWT7KRiJ4Atx49zIrqsKvmU1mJQza0Y1YbBSS/b/IPO8StX04bItPpDuTp6zlh/G7YOGzlEoe",
    "transaction":"0300000001c31d075e91b15924e40511ed459d18e80de98bfe83c5feff48304feaa618ede6010000006b483045022100dd0e4a6c25b1c7ed9aec2c93133f6de27b4c695a062f21f0aed1a2999fccf01c0220384aaf84cd5fd1c741fd1739f5c026a492abbfc18cfde296c6d90e98304f2f76012102fb9e87840f7e0a9b01f955d8eb4d1d2a52b32c9c43c751d7a348482c514ad222ffffffff021027000000000000166a14ea15af58c614b050a3b2e6bcc131fe0e7de37b9801710815000000001976a9140ccc680f945e964f7665f57c0108cba5ca77ed1388ac00000000",
    "outputIndex":0
  },
  "publicKeys":[
    {
      "id":0,
      "type":0,
      "purpose":0,
      "securityLevel":0,
      "data":"AkWRfl3DJiyyy6YPUDQnNx5KERRnR8CoTiFUvfdaYSDS",
      "readOnly":false
    }
  ]
}
```

### Identity TopUp

Identity credit balances are increased by submitting the topup information in an identity topup state transition.

| Field           | Type           | Description                                                                                          |
| --------------- | -------------- | ---------------------------------------------------------------------------------------------------- |
| protocolVersion | integer        | The protocol version (currently `1`)                                                                 |
| type            | integer        | State transition type (`3` for identity topup)                                                       |
| assetLockProof  | object         | [Asset lock proof object](#asset-lock) proving the layer 1 locking transaction exists and is locked  |
| identityId      | array of bytes | An [Identity ID](#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |
| signature       | array of bytes | Signature of state transition data by the single-use key from the asset lock (65 bytes)              |

Each identity must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/stateTransition/identityTopUp.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "type": {
      "type": "integer",
      "const": 3
    },
    "assetLockProof": {
      "type": "object"
    },
    "identityId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "signature": {
      "type": "array",
      "byteArray": true,
      "minItems": 65,
      "maxItems": 65,
      "description": "Signature made by AssetLock one time ECDSA key"
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "assetLockProof",
    "identityId",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion":1,
  "type":3,
  "signature":"IEqOV4DsbVa+nPipva0UrT0z0ZwubwgP9UdlpwBwXbFSWb7Mxkwqzv1HoEDICJ8GtmUSVjp4Hr2x0cVWe7+yUGc=",
  "identityId":"6YfP6tT9AK8HPVXMK7CQrhpc8VMg7frjEnXinSPvUmZC",
  "assetLockProof":{
    "type":0,
    "instantLock":"AQF/OlZB9p8vPzPE55MlegR7nwhXRpZC4d5sYnOIypNgzQEAAAAm8edm9p8URNEE9PBo0lEzZ2s9nf4u1SV0MaZyB0JTRasiXu8QtTmfqZWjI3qVtOpUhGPu6r/2fV+0Ffi3AAAAhA77E0aScf+5PTYzgV5WR6VJ/EnjvXyAMmAcu222JyvA7M+5OoCzVF/IQs2IWaPOFsRl1n5C+dMxdvrxhpVLT8QfZJSl19wzybWrHbGRaHDw4iWHvfYdwyXN+vP8UwDz",
    "transaction":"03000000017f3a5641f69f2f3f33c4e793257a047b9f0857469642e1de6c627388ca9360cd010000006b483045022100d8c383b15a3738d13b029605d242f041bea874cb4d0def1303ca7cdf76092bf102201b1d401ae9e8cdc5efc061249d2a967960dadce53c66e34d249c42049b48b26701210335b684aa510a9b54a3a4f79283e64482a323190045c239fae5ecb0450c78f965ffffffff02e803000000000000166a14f5383f51784bc4a27e2040bdd6cd9aae7fe6814d31690815000000001976a9144a0511ec3362b35983d0a101f0572dd26abce2ee88ac00000000",
    "outputIndex":0
  }
}
```

### Identity Update

Identities are updated on the platform by submitting the identity information in an identity update state transition. This state transition requires either a set of one or more new public keys to add to the identity or a list of existing keys to disable.

| Field                | Type                 | Description                                                                                                              |
| -------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| protocolVersion      | integer              | The protocol version (currently `1`)                                                                                     |
| type                 | integer              | State transition type (`5` for identity update)                                                                          |
| identityId           | array of bytes       | The identity id (32 bytes)                                                                                               |
| signature            | array of bytes       | Signature of state transition data (65 bytes)                                                                            |
| revision             | integer              | Identity update revision                                                                                                 |
| publicKeysDisabledAt | integer              | (Optional) Timestamp when keys were disabled. Required if `disablePublicKeys` is present.                                |
| addPublicKeys        | array of public keys | (Optional) Array of up to 10 new public keys to add to the identity. Required if adding keys.                            |
| disablePublicKeys    | array of integers    | (Optional) Array of up to 10 existing identity public key ID(s) to disable for the identity. Required if disabling keys. |
| signaturePublicKeyId | integer              | The ID of public key used to sign the state transition                                                                   |

Each identity must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/stateTransition/identityUpdate.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "type": {
      "type": "integer",
      "const": 5
    },
    "identityId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "signature": {
      "type": "array",
      "byteArray": true,
      "minItems": 65,
      "maxItems": 96
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "description": "Identity update revision"
    },
    "publicKeysDisabledAt": {
      "type": "integer",
      "minimum": 0
    },
    "addPublicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "uniqueItems": true
    },
    "disablePublicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "uniqueItems": true,
      "items": {
        "type": "integer",
        "minimum": 0
      }
    },
    "signaturePublicKeyId": {
      "type": "integer",
      "minimum": 0
    }
  },
  "dependentRequired" : {
    "disablePublicKeys": ["publicKeysDisabledAt"],
    "publicKeysDisabledAt": ["disablePublicKeys"]
  },
  "anyOf": [
    {
      "type": "object",
      "required": ["addPublicKeys"],
      "properties": {
        "addPublicKeys": true
      }
    },
    {
      "type": "object",
      "required": ["disablePublicKeys"],
      "properties": {
        "disablePublicKeys": true
      }
    }
  ],
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "identityId",
    "signature",
    "revision",
    "signaturePublicKeyId"
  ]
}
```

### Asset Lock

The [identity create](#identity-creation) and [identity topup](#identity-topup) state transitions both include an asset lock proof object. This object references the layer 1 lock transaction and includes proof that the transaction is locked.

Currently there are two types of asset lock proofs: InstantSend and ChainLock. Transactions almost always receive InstantSend locks, so the InstantSend asset lock proof is the predominate type.

#### InstantSend Asset Lock Proof

The InstantSend asset lock proof is used for transactions that have received an InstantSend lock.

| Field       | Type           | Description                                                                                                                                  |
| ----------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| type        | integer        | The asset lock proof type (`0` for InstantSend locks)                                                                                        |
| instantLock | array of bytes | The InstantSend lock ([`islock`](https://docs.dash.org/projects/core/en/stable/docs/reference/p2p-network-instantsend-messages.html#islock)) |
| transaction | array of bytes | The asset lock transaction                                                                                                                   |
| outputIndex | integer        | Index of the transaction output to be used                                                                                                   |

Asset locks using an InstantSend lock as proof must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/stateTransition/assetLockProof/instantAssetLockProof.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "type": {
      "type": "integer",
      "const": 0
    },
    "instantLock": {
      "type": "array",
      "byteArray": true,
      "minItems": 165,
      "maxItems": 100000
    },
    "transaction": {
      "type": "array",
      "byteArray": true,
      "minItems": 1,
      "maxItems": 100000
    },
    "outputIndex": {
      "type": "integer",
      "minimum": 0
    }
  },
  "additionalProperties": false,
  "required": [
    "type",
    "instantLock",
    "transaction",
    "outputIndex"
  ]
}
```

#### ChainLock Asset Lock Proof

The ChainLock asset lock proof is used for transactions that have note received an InstantSend lock, but have been included in a block that has received a ChainLock.

| Field                 | Type           | Description                                                                                                                       |
| --------------------- | -------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| type                  | array of bytes | The type of asset lock proof (`1` for ChainLocks)                                                                                 |
| coreChainLockedHeight | integer        | Height of the ChainLocked Core block containing the transaction                                                                   |
| outPoint              | object         | The  [outpoint](https://docs.dash.org/projects/core/en/stable/docs/resources/glossary.html#outpoint) being used as the asset lock |

Asset locks using a ChainLock as proof must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/identity/stateTransition/assetLockProof/chainAssetLockProof.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "type": {
      "type": "integer",
      "const": 1
    },
    "coreChainLockedHeight":  {
      "type": "integer",
      "minimum": 1,
      "maximum": 4294967295
    },
    "outPoint": {
      "type": "array",
      "byteArray": true,
      "minItems": 36,
      "maxItems": 36
    }
  },
  "additionalProperties": false,
  "required": [
    "type",
    "coreChainLockedHeight",
    "outPoint"
  ]
}
```

### Identity State Transition Signing

**Note:** The identity create and topup state transition signatures are unique in that they must be signed by the private key used in the layer 1 locking transaction. All other state transitions will be signed by a private key of the identity submitting them.

The process to sign an identity create state transition consists of the following steps:

1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature`
2. Sign the encoded data with private key associated with a lock transaction public key
3. Set the state transition `signature` to the value of the signature created in the previous step

#### Code snipits related to signing

```rust
/// From rs-dpp
/// abstract_state_transition.rs
/// Signs data with the private key
fn sign_by_private_key(
    &mut self,
    private_key: &[u8],
    key_type: KeyType,
    bls: &impl BlsModule,
) -> Result<(), ProtocolError> {
    let data = self.to_buffer(true)?;
    match key_type {
        KeyType::BLS12_381 => self.set_signature(bls.sign(&data, private_key)?.into()),

        // https://github.com/dashpay/platform/blob/9c8e6a3b6afbc330a6ab551a689de8ccd63f9120/packages/js-dpp/lib/stateTransition/AbstractStateTransition.js#L169
        KeyType::ECDSA_SECP256K1 | KeyType::ECDSA_HASH160 => {
            let signature = signer::sign(&data, private_key)?;
            self.set_signature(signature.to_vec().into());
        }

        // the default behavior from
        // https://github.com/dashpay/platform/blob/6b02b26e5cd3a7c877c5fdfe40c4a4385a8dda15/packages/js-dpp/lib/stateTransition/AbstractStateTransition.js#L187
        // is to return the error for the BIP13_SCRIPT_HASH
        KeyType::BIP13_SCRIPT_HASH => {
            return Err(ProtocolError::InvalidIdentityPublicKeyTypeError(
                InvalidIdentityPublicKeyTypeError::new(key_type),
            ))
        }
    };
    Ok(())
}


/// From rust-dashcore
/// signer.rs
/// sign and get the ECDSA signature
pub fn sign(data: &[u8], private_key: &[u8]) -> Result<[u8; 65], anyhow::Error> {
    let data_hash = double_sha(data);
    sign_hash(&data_hash, private_key)
}

/// signs the hash of data and get the ECDSA signature
pub fn sign_hash(data_hash: &[u8], private_key: &[u8]) -> Result<[u8; 65], anyhow::Error> {
    let pk = SecretKey::from_slice(private_key)
        .map_err(|e| anyhow!("Invalid ECDSA private key: {}", e))?;

    let secp = Secp256k1::new();
    let msg = Message::from_slice(data_hash).map_err(anyhow::Error::msg)?;

    let signature = secp
        .sign_ecdsa_recoverable(&msg, &pk)
        .to_compact_signature(true);
    Ok(signature)
}
```
