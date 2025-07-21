```{eval-rst}
.. _protocol-ref-document:
```

# Document

## Document Overview

Once a [data contract](./data-contract.md) has been created, data can be stored by submitting documents that comply with the document structure specified in the contract. Each document consists of one or more fields and the indices necessary to support querying. Documents are [created](#document-create-transition), [updated](#document-replace-transition), or [deleted](#document-delete-transition) by sending by submitting them to the platform in a [batch state transition](./state-transition.md#batch).

## Document State Transition Details

All document transitions include the [document base transition fields](#document-base-transition). Some document transitions (.e.g., [document create](#document-create-transition)) require additional fields to provide their functionality.

### Document Base Transition

The following fields are included in all document transitions:

| Field | Type | Size | Description|
| ----- | ---- | ---- | ---------- |
| [$id](#document-id) | array | 32 bytes | The [document ID](#document-id) |
| [$action](#document-transition-action) | array of integers | Varies | [Action](#document-transition-action) the platform should take for the associated document |
| $identityContractNonce | unsigned integer | 64 bits  | Identity contract nonce |
| $type | string | 1-64 characters | Name of a document type found in the data contract associated with the `dataContractId`|
| $dataContractId | array | 32 bytes | Data contract ID [generated](../protocol-ref/data-contract.md#data-contract-id) from the data contract's `ownerId` and `entropy` |

Each document transition must comply with the [document base transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_base_transition/v0/mod.rs#L43-L61).

#### Document id

The document `$id` is created by double sha256 hashing the document's `dataContractId`, `ownerId`, `type`, and `entropy` as shown in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/document/generate_document_id.rs).

```rust
// From the Rust reference implementation (rs-dpp)
// generate_document_id.rs
pub fn generate_document_id_v0(
    contract_id: &Identifier,
    owner_id: &Identifier,
    document_type_name: &str,
    entropy: &[u8],
) -> Identifier {
    let mut buf: Vec<u8> = vec![];

    buf.extend_from_slice(&contract_id.to_buffer());
    buf.extend_from_slice(&owner_id.to_buffer());
    buf.extend_from_slice(document_type_name.as_bytes());
    buf.extend_from_slice(entropy);

    Identifier::from_bytes(&hash_double_to_vec(&buf)).unwrap()
}
```

#### Document Transition Action

Document transition actions indicate what operation platform should perform with the provided transition data. Documents provide CRUD functionality, ownership transfer, and NFT features as [defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_transition_action_type.rs#L6-L14).

| Action | Name | Description |
| :-: | - | - |
| 0 | [Create](#document-create-transition) | Create a new document with the provided data |
| 1 | [Replace](#document-replace-transition) | Replace an existing document with the provided data |
| 2 | [Delete](#document-delete-transition) | Delete the referenced document |
| 3 | [Transfer](#document-transfer-transition) | Transfer the referenced document to a new owner |
| 4 | [Purchase](#document-purchase-transition) | Purchase the referenced document |
| 5 | [Update price](#document-update-price-transition) | Update the price for the document |

### Document Create Transition

The document create transition extends the [base transition](#document-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| - | - | - | - |
| $entropy | array | 32 bytes | Entropy used in creating the [document ID](#document-id). Generated as [shown here](../protocol-ref/state-transition.md#entropy-generation). |
| data | | Varies | Document data being submitted. |
| $prefundedVotingBalance | | Varies | (Optional) Prefunded amount of credits reserved for unique index conflict resolution voting (e.g., [premium DPNS name](../explanations/dpns.md#conflict-resolution)).|

Each document create transition must comply with the structure defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_create_transition/v0/mod.rs#L58-L82) (in addition to the [document base transition](#document-base-transition) that is required for all document transitions).

::: {note}
The document create transition data field must include all [required document properties](./data-contract-document.md#required-properties) specified in the data contract.
:::

The following example document create transition and subsequent table demonstrate how the document transition base, document create transition, and data contract document definitions are assembled into a complete transition for inclusion in a [state transition](#document-overview):

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

### Document Replace Transition

The document replace transition extends the [base transition](#document-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| - | - | - | - |
| $revision | unsigned integer | 64 bits | Document revision (=> 1) |
| data | | Varies | Document data being updated |

Each document replace transition must comply with the structure defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_replace_transition/v0/mod.rs#L35-L45) (in addition to the [document base transition](#document-base-transition) that is required for all document transitions).

::: {note}
The document replace transition data field must include all [required document properties](./data-contract-document.md#required-properties) specified in the data contract.
:::

The following example document create transition and subsequent table demonstrate how the document transition base, document create transition, and data contract document definitions are assembled into a complete transition for inclusion in a [state transition](#document-overview):

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

### Document Delete Transition

The document delete transition only requires the fields found in the [base document transition](#document-base-transition). See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_delete_transition/v0/mod.rs#L21-L24) for details.

### Document Transfer Transition

The document transfer transition allows a document owner to transfer document ownership directly to another identity without making it available for purchase. This transition extends the [base transition](#document-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| - | - | - | - |
| $revision | unsigned integer | 64 bits | Document revision (=> 1) |
| recipientOwnerId | array of bytes | 32 bytes | Identifier of the recipient (new owner). See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details. |

Each document transfer transition must comply with the structure defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_transfer_transition/v0/mod.rs#L33-L46) (in addition to the [document base transition](#document-base-transition) that is required for all document transitions).

### Document Purchase Transition

The document purchase transition allows an identity to purchase a document previously made available for sale by the current document owner. This transition extends the [document base transition](#document-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| - | - | - | - |
| $revision | unsigned integer | 64 bits | Document revision (=> 1) |
| price | unsigned integer | 64 bits | Number of credits being offered for the purchase. See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details. |

Each document purchase transition must comply with the structure defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_purchase_transition/v0/mod.rs#L23-L33) (in addition to the [document base transition](#document-base-transition) that is required for all document transitions).

### Document Update Price Transition

The document update price transition allows a document owner to set or update the minimum price they will accept in exchange for transferring document ownership to another party. This transition extends the [document base transition](#document-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| - | - | - | - |
| $revision | unsigned integer | 64 bits | Document revision (=> 1) |
| $price | unsigned integer | 64 bits | Updated price for the document. Can only be set by the current document owner. See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details. |

Each document update price transition must comply with the structure defined in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/document_update_price_transition/v0/mod.rs#L27-L40) (in addition to the [document base transition](#document-base-transition) that is required for all document transitions).

## Document Object

The document object represents the data provided by the platform in response to a query. Responses consist of an array of these objects containing the following fields as defined in the Rust reference client ([rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/document/v0/mod.rs#L35-L105)):

| Property | Type | Required | Description |
| - | - | - | - |
| protocolVersion | integer | Yes | The platform protocol version (currently `1`) |
| $id | array | Yes | The [document ID](#document-id) (32 bytes)|
| $type | string | Yes  | Document type defined in the referenced contract (1-64 characters) |
| $revision | unsigned integer (64 bits) | No | Document revision (=>1) if the document is mutable |
| $dataContractId | array | Yes | Data contract ID [generated](../protocol-ref/data-contract.md#data-contract-id) from the data contract's `ownerId` and `entropy` (32 bytes) |
| $ownerId | array | Yes | [Identity](../protocol-ref/identity.md) of the user submitting the document (32 bytes) |
| $createdAt | unsigned integer (64 bits) | No | Time (in milliseconds) at document creation, if required by the document type schema |
| $updatedAt | unsigned integer (64 bits) | No | Last document update time in milliseconds, if required by the document type schema |
|$transferredAt | unsigned integer (64 bits) | No | Last transferred time in milliseconds, if required by the document type schema |
| $createdAt<br>BlockHeight | unsigned integer (64 bits) |  No | Block height at document creation, if required by the schema |
| $updatedAt<br>BlockHeight | unsigned integer (64 bits) | No | Block height at the document's last update, if required by the schema |
| $transferredAt<br>BlockHeight | unsigned integer (64 bits) | No | Block height when document was last transferred, if required by the schema |
| $createdAt<br>CoreBlockHeight | unsigned integer (64 bits) | No | Core block height at document creation, if required by the schema |
| $updatedAt<br>CoreBlockHeight | unsigned integer (64 bits) | No |Core block height at the document's last update, if required by the schema |
| $transferredAt<br>CoreBlockHeight | unsigned integer (64 bits) | No |Core block height when document was last transferred, if required by the schema |

### Example Document Object

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
