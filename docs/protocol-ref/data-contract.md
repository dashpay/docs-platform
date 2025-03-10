```{eval-rst}
.. _protocol-ref-data-contract:
```

# Data Contract

## Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts. All data contracts must define one or more [documents](#data-contract-documents) or tokens, whereas definitions are optional and may not be used for simple contracts.

### General Constraints

There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts.

#### Data Size

| Parameter | Size |
| - | - |
| Maximum serialized data contract size | [16384 bytes (16 KB)](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L4) |
| Maximum field value size | [5120 bytes (5 KB)](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L5) |
| Maximum state transition size | [20480 bytes (20 KB)](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L6) |

A document cannot exceed the maximum state transition size in any case. For example, although it is
possible to define a data contract with 10 document fields that each support the maximum field size
(5120), it is not possible to create a document where all 10 fields contain the full 5120 bytes.
This is because the overall document and state transition containing it would be too large (5120 *
10 = 51200 bytes).

#### Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined (including within document properties of type `object`).

Include the following at the same level as the `properties` keyword to ensure proper validation:

```json
"additionalProperties": false
```

## Data Contract Object

The data contract object consists of the following fields as defined in the Rust reference client ([rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/v1/data_contract.rs#L46-L75)):

| Property        | Type           | Required | Description |
| --------------- | -------------- | -------- | ----------- |
| $version | integer        | Yes      | The platform protocol version ([currently `8`](https://github.com/dashpay/platform/blob/v1.8.0/packages/rs-platform-version/src/version/mod.rs#L26)) |
| [$schema](#data-contract-schema) | string         | Yes      | A valid URL (default: <https://schema.dash.org/dpp-0-4-0/meta/data-contract>) |
| [id](#data-contract-id)         | array of bytes | Yes      | Contract ID generated from `ownerId` and entropy ([32 bytes; content media type: `application/x.dash.dpp.identifier`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L378-L384)) |
| [version](#data-contract-version) | integer        | Yes      | The data contract version |
| ownerId         | array of bytes | Yes      | [Identity](../protocol-ref/identity.md) that registered the data contract defining the document ([32 bytes; content media type: `application/x.dash.dpp.identifier`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L389-L395) |
| [documents](./data-contract-document.md) | object         | No \*    | Document definitions (see [Contract Documents](./data-contract-document.md) for details) |
| config | DataContractConfig | No | Internal configuration for the contract |
| $defs           | object         | No       | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with \<= 100 valid properties) |
| groups | Group | No | Groups that allow for specific multiparty actions on the contract |
| [tokens](./data-contract-token.md) | object         | No \*    | Token definitions (see [Contract Tokens](./data-contract-token.md) for details) |

\* The data contract object must define documents or tokens. It may include both documents and tokens.

### Data Contract id

The data contract `$id` is a hash of the `ownerId` and entropy as shown [here](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/generate_data_contract.rs).

```rust
// From the Rust reference implementation (rs-dpp)
// generate_data_contract.rs
/// Generate data contract id based on owner id and identity nonce
pub fn generate_data_contract_id_v0(
    owner_id: impl AsRef<[u8]>,
    identity_nonce: IdentityNonce,
) -> Identifier {
    let mut b: Vec<u8> = vec![];
    let _ = b.write(owner_id.as_ref());
    let _ = b.write(identity_nonce.to_be_bytes().as_slice());
    Identifier::from(hash_double(b))
}
```

### Data Contract version

The data contract `version` is an integer representing the current version of the contract. This  
property must be incremented if the contract is updated.

### Data Contract Documents

See the [data contract documents](./data-contract-document.md) page for details.

## Data Contract State Transition Details

There are two data contract-related state transitions: [data contract create](#data-contract-create) and [data contract update](#data-contract-update). Details are provided in this section.

### Data Contract Create

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract create state transition consisting of:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version        | unsigned integer | 32 bits | The platform protocol version (currently `1`) |
| type            | unsigned integer | 8 bits  | State transition type (`0` for data contract create)  |
| dataContract    | [data contract object](#data-contract-object) | Varies | Object containing the data contract details |
| identityNonce   | unsigned integer     | 64 bits | Identity nonce for this transition to prevent replay attacks |
| entropy         | array of bytes | 32 bytes | Entropy used to generate the data contract ID. Generated as [shown here](../protocol-ref/state-transition.md#entropy-generation). |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |
| signature            | array of bytes | 65 bytes | Signature of state transition data |

See the [data contract create implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_create_transition/v0/mod.rs#L37-L45) for more details.

### Data Contract Update

Existing data contracts can be updated in certain backwards-compatible ways. The following aspects
of a data contract can be updated:

- Adding a new document
- Adding a new optional property to an existing document
- Adding non-unique indices for properties added in the update

Data contracts are updated on the platform by submitting the modified [data contract  
object](#data-contract-object) in a data contract update state transition consisting of:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version        | unsigned integer | 32 bits | The platform protocol version (currently `1`) |
| type            | unsigned integer | 8 bits  | State transition type (`4` for data contract update)  |
| dataContract    | [data contract object](#data-contract-object) | Varies | Object containing the updated data contract details<br>**Note:** the data contract's [`version` property](#data-contract-version) must be incremented with each update |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |
| signature            | array of bytes | 65 bytes | Signature of state transition data |

See the [data contract update implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_update_transition/v0/mod.rs#L33-L45) for more details.

### Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract owner's identity. See the [state transition signing](./state-transition.md#state-transition-signing) page for full signing details.

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

data-contract-document
```
