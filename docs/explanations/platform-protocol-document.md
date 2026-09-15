```{eval-rst}
.. _explanations-document:
```

# Document

## Overview

Dash Platform is based on [document-oriented database](https://en.wikipedia.org/wiki/Document-oriented_database) concepts and uses related terminology. In short, JSON documents are stored into document collections which can then be fetched back using a [query language](../reference/query-syntax.md) similar to common document-oriented databases like [MongoDB](https://www.mongodb.com/), [CouchDB](https://couchdb.apache.org/), or [Firebase](https://firebase.google.com/).

Documents are defined in an application's [Data Contract](../explanations/platform-protocol-data-contract.md) and represent the structure of application-specific data. Each document consists of one or more fields and the indices necessary to support querying.

## Details

Most document types store each document as a JSON body with the base fields described below. Since protocol version 14, a data contract can instead declare a document type as index-only: its documents are never stored as a body and exist only as entries in the type's indices, with reads reconstructed from those entries. In exchange, index-only documents are immutable, cannot be transferred or traded, keep no history, and have no revision. See the [data contract explanation](../explanations/platform-protocol-data-contract.md#structure) and [indexOnly document types](../reference/data-contracts.md#indexonly-document-types) in the data contract reference.

### Base Fields

Dash Platform Protocol (DPP) defines a set of base fields that may appear on documents. For the [reference implementation](https://github.com/dashpay/platform/tree/master/packages/rs-dpp), the base fields shown below are defined in the [document base fields](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/src/document/fields.rs).

| Field Name | Description |
| - | - |
| $id | The document ID (32 bytes) |
| $type | Document type defined in the referenced contract |
| $revision | Document revision (=>1) |
| $dataContractId | Data contract the document is associated with (32 bytes) |
| $ownerId | [Identity](../explanations/identity.md) of the user submitting the document (32 bytes) |
| $createdAt | Time (in milliseconds) the document was created |
| $updatedAt | Time (in milliseconds) the document was last updated |
| $transferredAt | Time (in milliseconds) the document was last transferred |
| $createdAtBlockHeight | Platform block height when the document was created |
| $updatedAtBlockHeight | Platform block height when the document was last updated |
| $transferredAtBlockHeight | Platform block height when the document was last transferred |
| $createdAtCoreBlockHeight | Core block height when the document was created |
| $updatedAtCoreBlockHeight | Core block height when the document was last updated |
| $transferredAtCoreBlockHeight | Core block height when the document was last transferred |
| $price | Current listing price in credits |
| $creatorId | [Identity](../explanations/identity.md) that originally created the document (32 bytes) |
| $contractVersion | Version of the data contract the document was last written under |

#### Field availability

Timestamp and block height fields are present only when included in the document type's [required properties](../reference/data-contracts.md#required-properties).

`$price` is present only while a document whose trade mode supports seller-set pricing is listed, and is cleared when the document is purchased or transferred. `$creatorId` is present on transferable or tradeable document types and is preserved when ownership changes.

Since protocol version 14, `$contractVersion` records which contract version supplied the document's required properties. This allows contract updates to add required properties without invalidating older documents.

`$type` and `$dataContractId` identify the document rather than being stored with its data. Platform supplies them when the document is fetched.

### Data Contract Fields

Each application defines its own fields via document definitions in its data contract. Details of the [DPNS data contract documents](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json) are described below as an example. This contract defines two document types (`preorder` and `domain`) and provides the functionality described in the [Name Service explanation](../explanations/dpns.md).

| Document Type | Field Name | Data Type |
| - | - | - |
| preorder | saltedDomainHash | array (32 bytes) |
| --- | --- | --- |
| domain | label | string |
| domain | normalizedLabel | string |
| domain | parentDomainName | string |
| domain | normalizedParentDomainName | string |
| domain | preorderSalt | array (bytes), [transient](../reference/data-contracts.md#transient-properties) (validated on submission but not stored) |
| domain | records | object |
| domain | records.identity | array (32 bytes) |
| domain | subdomainRules | object |
| domain | subdomainRules.allowSubdomains | boolean |

### Example Document

The following example shows the structure of a DPNS `domain` document as output from `JSON.stringify()`. Note the `$` prefix indicating the base fields. The `preorderSalt` property is transient, so it is submitted with the document but does not appear when the document is fetched.

```json
{
  "$id": "3AhZ5h63ZrFJXfE3YP3iEFVxyndYWPMxR9fSEaMo67QJ",
  "$type": "domain",
  "$dataContractId": "GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec",
  "$ownerId": "6TGHW8WBcNzFrWwAueGtqtAah7w98EELFZ7xdTHegnvH",
  "$creatorId": "6TGHW8WBcNzFrWwAueGtqtAah7w98EELFZ7xdTHegnvH",
  "$revision": 1,
  "$createdAt": 1712872800000,
  "$updatedAt": 1712872800000,
  "$transferredAt": 1712872800000,
  "label": "DQ-Jasen-82083",
  "normalizedLabel": "dq-jasen-82083",
  "normalizedParentDomainName": "dash",
  "parentDomainName": "dash",
  "records": {
    "identity": "UQTRY+wqPyL27V7YjJadJdyXVBETj6CfzvqUg5aY5E4="
  },
  "subdomainRules": {
    "allowSubdomains": false
  }
}
```

## Document Submission

Once a document has been created, it must be encapsulated in a Batch state transition to be sent to the platform. Batch state transitions (type `1`) bundle document and/or token transitions submitted together by the same identity. Although the format allows one or more transitions, Platform currently accepts exactly one transition per batch. For additional details, see the [State Transition](../explanations/platform-protocol-state-transition.md) explanation.

| Field Name | Description |
| - | - |
| type | State transition type (`1` for a Batch) |
| ownerId | Identity submitting the batch |
| transitions | Document and token transitions bundled in the batch (e.g. document `create`, `replace`, `delete`, `transfer`, `purchase`, `updatePrice`, and, from protocol version 14, `indexOnlyDelete`) |
| userFeeIncrease | Optional amount the submitter adds to the fee to raise the priority of the batch and improve its chance of timely inclusion |
| signaturePublicKeyId | The `id` of the identity public key that signed the state transition |
| signature | Signature of state transition data |

State transitions are versioned through their serialized enum representation rather than a top-level `protocolVersion` field.

### Document Transition Base

Every document transition in a batch shares a common base, regardless of the action it performs. The base identifies which document the transition targets - the document ID, its type, and the data contract that defines it - and adds two further elements:

- A per-identity, per-contract nonce that orders an identity's transitions against a given contract and prevents a transition from being replayed.
- Optional token payment information, used when the contract charges one of its tokens for the action rather than charging the submitter in credits. See the [Tokens](../explanations/tokens.md#token-based-fees) explanation for how token-based document fees are configured.

The sections below describe the fields each action adds on top of this shared base.

### Document Create

The document create transition is used to create a new document on Dash Platform. The document create transition extends the [transition base](#document-transition-base) to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $entropy | array (32 bytes) | Entropy used in creating the document ID |
| $prefundedVotingBalance | object | (Optional) Credits set aside to fund masternode voting when the document contests a unique index |

The transition does not carry timestamp or block height fields. Platform assigns those from the block in which the transition is processed, and they appear on the resulting document only when the data contract sets them as required for the document type.

Creating a document on a contested unique index requires setting aside a prefunded voting balance. Those credits fund the masternode vote that decides which of the competing identities receives the resource. This is the mechanism behind contested DPNS names - see the [Name Service explanation](../explanations/dpns.md) for how it applies to username registration.

### Document Replace

The document replace transition is used to update the data in an existing Dash Platform document. The document replace transition extends the [transition base](#document-transition-base) to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $revision | integer | Document revision (=> 1) |

If the data contract sets the updated at timestamp as required for the document type, Platform assigns the updated timestamp and block height from block info rather than accepting them from the caller.

### Document Delete

The document delete transition is used to delete an existing Dash Platform document. It only requires the fields found in the [transition base](#document-transition-base).

Documents of [index-only document types](#details) have no stored body to reference by ID. Since protocol version 14 they are instead removed with an index-only delete transition (`indexOnlyDelete`) that carries the property values identifying the index entry to remove.

### Document Transfer

The document transfer transition is used to transfer ownership of an existing document to another identity. It extends the [transition base](#document-transition-base) with the recipient identifier:

| Field | Type | Description |
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| recipientOwnerId | array (32 bytes) | The identity receiving ownership of the document |

Document transfers are only allowed for document types that are marked transferable in the data contract.

### Document Purchase

The document purchase transition is used to buy a document that the current owner has listed for sale. It extends the [transition base](#document-transition-base) with the agreed price:

| Field | Type | Description |
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| price | integer | Price (in credits) the buyer is paying, which must match the document's current listed price |

Document purchases are only allowed for document types whose trade mode permits sale.

### Document Update Price

The document update price transition is used by the current owner to list a document for sale (or change its listed price). It extends the [transition base](#document-transition-base) with the new price:

| Field | Type | Description |
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| $price | integer | New price (in credits) at which the document is offered for sale |

:::{note}
For more detailed information, see the [Platform Protocol Reference - Document](../protocol-ref/document.md) page.
:::
