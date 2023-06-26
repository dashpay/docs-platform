# Document Submission

Documents are sent to the platform by submitting the them in a document batch state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `1`) |
| type | integer | State transition type (`1` for document batch) |
| ownerId | array | [Identity](platform-protocol-reference-identity) submitting the document(s) (32 bytes) |
| transitions | array of transition objects | Document `create`, `replace`, or `delete` transitions (up to 10 objects) |
| signaturePublicKeyId | number | The `id` of the [identity public key](platform-protocol-reference-identity#identity-publickeys) that signed the state transition |
| signature | array | Signature of state transition data (65 or 96 bytes) |

Each document batch state transition must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/document/stateTransition/documentsBatch.json):

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
      "const": 1
    },
    "ownerId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "transitions": {
      "type": "array",
      "items": {
        "type": "object"
      },
      "minItems": 1,
      "maxItems": 10
    },
    "signaturePublicKeyId": {
      "type": "integer",
      "minimum": 0
    },
    "signature": {
      "type": "array",
      "byteArray": true,
      "minItems": 65,
      "maxItems": 96
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "ownerId",
    "transitions",
    "signaturePublicKeyId",
    "signature"
  ]
}
```

## Document Base Transition

All document transitions in a document batch state transition are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| $id | array | The [document ID](#document-id) (32 bytes)|
| $type | string | Name of a document type found in the data contract associated with the `dataContractId` (1-64 characters) |
| $action | array of integers | [Action](#document-transition-action) the platform should take for the associated document |
| $dataContractId | array | Data contract ID [generated](platform-protocol-reference-data-contract#data-contract-id) from the data contract's `ownerId` and `entropy` (32 bytes) |

Each document transition must comply with the document transition [base schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/document/stateTransition/documentTransition/base.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "$id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$type": {
      "type": "string"
    },
    "$action": {
      "type": "integer",
      "enum": [0, 1, 3]
    },
    "$dataContractId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    }
  },
  "required": [
    "$id",
    "$type",
    "$action",
    "$dataContractId"
  ],
  "additionalProperties": false
}
```

### Document id

The document `$id` is created by hashing the document's `dataContractId`, `ownerId`, `type`, and `entropy` as shown in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/document/generate_document_id.rs).

```rust
// From the Rust reference implementation (rs-dpp)
// generate_document_id.rs
pub fn generate_document_id(
    contract_id: &Identifier,
    owner_id: &Identifier,
    document_type: &str,
    entropy: &[u8],
) -> Identifier {
    let mut buf: Vec<u8> = vec![];

    buf.extend_from_slice(&contract_id.to_buffer());
    buf.extend_from_slice(&owner_id.to_buffer());
    buf.extend_from_slice(document_type.as_bytes());
    buf.extend_from_slice(entropy);

    Identifier::from_bytes(&hash(&buf)).unwrap()
}
```

### Document Transition Action

| Action | Name | Description |
| :-: | - | - |
| 0 | Create | Create a new document with the provided data |
| 1 | Replace | Replace an existing document with the provided data |
| 2 | `RESERVED` | Unused action |
| 3 | Delete | Delete the referenced document |

## Document Create Transition

The document create transition extends the base schema to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $entropy | array | Entropy used in creating the [document ID](#document-id). Generated as [shown here](platform-protocol-reference-state-transition#entropy-generation). (32 bytes) |
| $createdAt | integer | (Optional)  | Time (in milliseconds) the document was created |
| $updatedAt | integer | (Optional)  | Time (in milliseconds) the document was last updated |

Each document create transition must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/document/stateTransition/documentTransition/create.json) (in addition to the document transition [base schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/document/stateTransition/documentTransition/base.json)) that is required for all document transitions):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "$entropy": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32
    },
    "$createdAt": {
      "type": "integer",
      "minimum": 0
    },
    "$updatedAt": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "$entropy"
  ],
  "additionalProperties": false
}
```

**Note:** The document create transition must also include all required properties of the document as defined in the data contract.

The following example document create transition and subsequent table demonstrate how the document transition base, document create transition, and data contract document definitions are assembled into a complete transition for inclusion in a [state transition](#document-submission):

```json
{
  "$action": 0,
  "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
  "$id": "6oCKUeLVgjr7VZCyn1LdGbrepqKLmoabaff5WQqyTKYP",
  "$type": "note",
  "$entropy": "yfo6LnZfJ5koT2YUwtd8PdJa8SXzfQMVDz",
  "message": "Tutorial Test @ Mon, 27 Apr 2020 20:23:35 GMT"
}
```

| Field | Required By |
| - | - |
| $action | Document [base transition](#document-base-transition) |
| $dataContractId | Document [base transition](#document-base-transition) |
| $id | Document [base transition](#document-base-transition) |
| $type | Document [base transition](#document-base-transition) |
| $entropy | Document [create transition](#document-create-transition) |
| message | Data Contract (the `message` document defined in the referenced data contract -`5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8`) |

## Document Replace Transition

The document replace transition extends the base schema to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| $updatedAt | integer | (Optional)  | Time (in milliseconds) the document was last updated |

Each document replace transition must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/document/stateTransition/documentTransition/replace.json) (in addition to the document transition [base schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/document/stateTransition/documentTransition/base.json)) that is required for all document transitions):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "$revision": {
      "type": "integer",
      "minimum": 1
    },
    "$updatedAt": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "$revision"
  ],
  "additionalProperties": false
}
```

**Note:** The document create transition must also include all required properties of the document as defined in the data contract.

The following example document create transition and subsequent table demonstrate how the document transition base, document create transition, and data contract document definitions are assembled into a complete transition for inclusion in a [state transition](#document-submission):

```json
{
  "$action": 1,
  "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
  "$id": "6oCKUeLVgjr7VZCyn1LdGbrepqKLmoabaff5WQqyTKYP",
  "$type": "note",
  "$revision": 1,
  "message": "Tutorial Test @ Mon, 27 Apr 2020 20:23:35 GMT"
}
```

| Field | Required By |
| - | - |
| $action | Document [base transition](#document-base-transition) |
| $dataContractId | Document [base transition](#document-base-transition) |
| $id | Document [base transition](#document-base-transition) |
| $type | Document [base transition](#document-base-transition) |
| $revision | Document revision |
| message | Data Contract (the `message` document defined in the referenced data contract -`5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8`) |

## Document Delete Transition

The document delete transition only requires the fields found in the [base document transition](#document-base-transition).

## Example Document Batch State Transition

```json
{
  "protocolVersion": 1,
  "type": 1,
  "signature": "ICu/H7MoqxNUzznP9P2aTVEo91VVy0T8M3QWCH/7dg2UVokG98TbD4DQB4E8SD4GzHoRrBMycJ75SbT2AaF9hFc=",
  "signaturePublicKeyId": 0,
  "ownerId": "4ZJsE1Yg8AosmC4hAeo3GJgso4N9pCoa6eCTDeXsvdhn",
  "transitions": [
    {
      "$id": "8jm8iHsYE6ENENvFVeFVFMCwfgEqo5P1iR2q4KAYgpbS",
      "$type": "note",
      "$action": 1,
      "$dataContractId": "AnmBaYH13RyiuvBkBD6qkdc36H5DKt6ToMrkqgUnnywz",
      "message": "Updated document @ Mon, 26 Oct 2020 14:58:31 GMT",
      "$revision": 2
    }
  ]
}
```

# Document Object

The document object represents the data provided by the platform in response to a query. Responses consist of an array of these objects containing the following fields as defined in the Rust reference client ([rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/schema/document/documentExtended.json)):

| Property | Type | Required | Description |
| - | - | - | - |
| protocolVersion | integer | Yes | The platform protocol version (currently `1`) |
| $id | array | Yes | The [document ID](#document-id) (32 bytes)|
| $type | string | Yes  | Document type defined in the referenced contract (1-64 characters) |
| $revision | integer | No | Document revision (=>1) |
| $dataContractId | array | Yes | Data contract ID [generated](platform-protocol-reference-data-contract#data-contract-id) from the data contract's `ownerId` and `entropy` (32 bytes) |
| $ownerId | array | Yes | [Identity](platform-protocol-reference-identity) of the user submitting the document (32 bytes) |
| $createdAt | integer | (Optional)  | Time (in milliseconds) the document was created |
| $updatedAt | integer | (Optional)  | Time (in milliseconds) the document was last updated |

Each document object must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/schema/document/documentExtended.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "$protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "$id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$type": {
      "type": "string"
    },
    "$revision": {
      "type": "integer",
      "minimum": 1
    },
    "$dataContractId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$ownerId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$createdAt": {
      "type": "integer",
      "minimum": 0
    },
    "$updatedAt": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "$protocolVersion",
    "$id",
    "$type",
    "$revision",
    "$dataContractId",
    "$ownerId"
  ],
  "additionalProperties": false
}
```

## Example Document Object

```json
{
  "$protocolVersion": 1,
  "$id": "4mWnFcDDzCpeLExJqE8v7pfN4EERC8NE2xn4hw3VKriU",
  "$type": "note",
  "$dataContractId": "63au7XVDt8aHtPrsYKoHx2bnRTSenwH62pDN1BQ5n5m9",
  "$ownerId": "7TkaE5uhG3T9AhyEkAvYCqZvRH4pyBibhjuSYPReNfME",
  "$revision": 1,
  "message": "Tutorial Test @ Mon, 26 Oct 2020 15:54:35 GMT",
  "$createdAt": 1603727675072,
  "$updatedAt": 1603727675072
}
```