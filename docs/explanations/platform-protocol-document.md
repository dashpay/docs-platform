```{eval-rst}
.. _explanations-document:
```

# Document

## Overview

Dash Platform is based on [document-oriented database](https://en.wikipedia.org/wiki/Document-oriented_database) concepts and uses related terminology. In short, JSON documents are stored into document collections which can then be fetched back using a [query language](../reference/query-syntax.md) similar to common document-oriented databases like [MongoDB](https://www.mongodb.com/), [CouchDB](https://couchdb.apache.org/), or [Firebase](https://firebase.google.com/).

Documents are defined in an application's [Data Contract](../explanations/platform-protocol-data-contract.md) and represent the structure of application-specific data. Each document consists of one or more fields and the indices necessary to support querying.

## Details

### Base Fields

Dash Platform Protocol (DPP) defines a set of base fields that must be present in all documents. For the [reference implementation](https://github.com/dashpay/platform/tree/master/packages/rs-dpp), the base fields shown below are defined in the [document base schema](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/src/schema/document/v0/documentBase.json).

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

:::{attention}
The timestamp and block height fields will only be present in documents that add them to the list of [required properties](../reference/data-contracts.md#required-properties).
:::

### Data Contract Fields

Each application defines its own fields via document definitions in its data contract. Details of the [DPNS data contract documents](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json) are described below as an example. This contract defines two document types (`preorder` and `domain`) and provides the functionality described in the [Name Service explanation](../explanations/dpns.md).

| Document Type | Field Name | Data Type |
| - | - | - |
| preorder | saltedDomainHash | array (32 bytes) |
| --- | --- | --- |
| domain | label | string |
| domain | normalizedLabel | string |
| domain | parentDomainName | string |
| domain | normalizedParentDomainName | string |
| domain | preorderSalt | array (bytes) |
| domain | records | object |
| domain | records.identity | array (32 bytes) |
| domain | subdomainRules | object |
| domain | subdomainRules.allowSubdomains | boolean |

### Example Document

The following example shows the structure of a DPNS `domain` document as output from `JSON.stringify()`. Note the `$` prefix indicating the base fields.

```json
{
  "$id": "3AhZ5h63ZrFJXfE3YP3iEFVxyndYWPMxR9fSEaMo67QJ",
  "$type": "domain",
  "$dataContractId": "GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec",
  "$ownerId": "6TGHW8WBcNzFrWwAueGtqtAah7w98EELFZ7xdTHegnvH",
  "$revision": 1,
  "$createdAt": 1712872800000,
  "$updatedAt": 1712872800000,
  "label": "DQ-Jasen-82083",
  "normalizedLabel": "dq-jasen-82083",
  "normalizedParentDomainName": "dash",
  "parentDomainName": "dash",
  "preorderSalt": "bcCSdtGqqZdXBQB4DDBIU2RPAwFDFt9tMr0LX6m5qCQ=",
  "records": {
    "identity": "UQTRY+wqPyL27V7YjJadJdyXVBETj6CfzvqUg5aY5E4="
  },
  "subdomainRules": {
    "allowSubdomains": false
  }
}
```

## Document Submission

Once a document has been created, it must be encapsulated in a Batch state transition to be sent to the platform. Batch state transitions (type `1`) bundle one or more document and/or token transitions submitted together by the same identity. For additional details, see the [State Transition](../explanations/platform-protocol-state-transition.md) explanation.

| Field Name | Description |
| - | - |
| type | State transition type (`1` for a Batch) |
| ownerId | Identity submitting the batch |
| transitions | Document and token transitions bundled in the batch (e.g. document `create`, `replace`, `delete`, `transfer`, `purchase`, `updatePrice`) |
| signaturePublicKeyId | The `id` of the identity public key that signed the state transition |
| signature | Signature of state transition data |

State transitions are versioned through their serialized enum representation rather than a top-level `protocolVersion` field.

### Document Create

The document create transition is used to create a new document on Dash Platform. The document create transition extends the [base schema](#base-fields) to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $entropy | array (32 bytes) | Entropy used in creating the document ID |
| $createdAt | integer | (Optional) Time (in milliseconds) the document was created |
| $updatedAt | integer | (Optional) Time (in milliseconds) the document was last updated |

### Document Replace

The document replace transition is used to update the data in an existing Dash Platform document. The document replace transition extends the [base schema](#base-fields) to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| $updatedAt | integer | (Optional) Time (in milliseconds) the document was last updated |

### Document Delete

The document delete transition is used to delete an existing Dash Platform document. It only requires the fields found in the base document transition.

### Document Transfer

The document transfer transition is used to transfer ownership of an existing document to another identity. It extends the [base schema](#base-fields) with the recipient identifier:

| Field | Type | Description |
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| recipientOwnerId | array (32 bytes) | The identity receiving ownership of the document |

Document transfers are only allowed for document types that are marked transferable in the data contract.

### Document Purchase

The document purchase transition is used to buy a document that the current owner has listed for sale. It extends the [base schema](#base-fields) with the agreed price:

| Field | Type | Description |
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| price | integer | Price (in credits) the buyer is paying, which must match the document's current listed price |

Document purchases are only allowed for document types whose trade mode permits sale.

### Document Update Price

The document update price transition is used by the current owner to list a document for sale (or change its listed price). It extends the [base schema](#base-fields) with the new price:

| Field | Type | Description |
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| price | integer | New price (in credits) at which the document is offered for sale |

:::{note}
For more detailed information, see the [Platform Protocol Reference - Document](../protocol-ref/document.md) page.
:::
