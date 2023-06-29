# Document

## Overview

Dash Platform is based on [document-oriented database](https://en.wikipedia.org/wiki/Document-oriented_database) concepts and uses related terminology. In short, JSON documents are stored into document collections which can then be fetched back using a [query language](reference-query-syntax) similar to common document-oriented databases like [MongoDB](https://www.mongodb.com/), [CouchDB](https://couchdb.apache.org/), or [Firebase](https://firebase.google.com/). 

Documents are defined in an application's [Data Contract](explanation-platform-protocol-data-contract) and represent the structure of application-specific data. Each document consists of one or more fields and the indices necessary to support querying.

## Details

### Base Fields

Dash Platform Protocol (DPP) defines a set of base fields that must be present in all documents. For the [`js-dpp` reference implementation](https://github.com/dashevo/platform/tree/master/packages/js-dpp), the base fields shown below are defined in the [document base schema](https://github.com/dashevo/platform/blob/master/packages/js-dpp/schema/document/documentBase.json).

| Field Name | Description |
| - | - |
| protocolVersion | The platform protocol version (currently `1`) |
| $id | The document ID (32 bytes) |
| $type | Document type defined in the referenced contract |
| $revision | Document revision (=>1) |
| $dataContractId | Data contract ID generated from the data contract's `ownerId` and `entropy` (32 bytes) |
| $ownerId | [Identity](explanation-identity) of the user submitting the document (32 bytes) |
| $createdAt | Time (in milliseconds) the document was created |
| $updatedAt | Time (in milliseconds) the document was last updated |

> 🚧 Timestamp fields
>
> Note: The `$createdAt` and `$updatedAt` fields will only be present in documents that add them to the list of [required properties](reference-data-contracts#required-properties-optional).

### Data Contract Fields

Each application defines its own fields via document definitions in its data contract. Details of the [DPNS data contract documents](https://github.com/dashevo/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json) are described below as an example. This contract defines two document types (`preorder` and `domain`) and provides the functionality described in the [Name Service explanation](explanation-dpns).

| Document Type | Field Name | Data Type |
| - | - | - |
| preorder | saltedDomainHash | string |
| --- | --- | --- |
| domain | label | string |
| domain | normalizedLabel | string |
| domain | normalizedParentvDomainName | string |
| domain | preorderSalt | array (bytes) |
| domain | records | object |
| domain | records.dashUniqueIdentityId | array (bytes) |
| domain | records.dashAliasIdentityId | array (bytes) |
| domain | subdomainRules | object |
| domain | subdomainRules.allowSubdomains | boolean |

### Example Document

The following example shows the structure of a DPNS `domain` document as output from `JSON.stringify()`. Note the `$` prefix indicating the base fields.

```json
{
  "$protocolVersion": 1,
  "$id": "5D8U1k6t6ax8TnyL6QGFFbtMhn39zsixrSMQaxZrYKf1",
  "$type": "domain",
  "$dataContractId": "GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec",
  "$ownerId": "9gU2ZnDhkakHgB4eLbqvEAwQPDBwhW12KD5xPZxybNjE",
  "$revision": 1,
  "label": "RT-Sylvan-71605",
  "normalizedLabel": "rt-sylvan-71605",
  "normalizedParentDomainName": "dash",
  "preorderSalt": "zKaLWLe+kKHiRoBXdfSd7TSU9HdIseeoOly1eTYZ670=",
  "records": {
    "dashUniqueIdentityId": "9gU2ZnDhkakHgB4eLbqvEAwQPDBwhW12KD5xPZxybNjE"
  },
  "subdomainRules": {
    "allowSubdomains": false
  }
}
``` 

## Document Submission

Once a document has been created, it must be encapsulated in a State Transition to be sent to the platform. The structure of a document state transition is shown below. For additional details, see the [State Transition](explanation-platform-protocol-state-transition) explanation.

| Field Name | Description |
| - | - | 
| protocolVersion | Dash Platform Protocol version (currently `0`) |
| type | State transition type (`1` for documents) |
| ownerId | Identity submitting the document(s) |
| transitions |  Document `create`, `replace`, or `delete` transitions (up to 10 objects) |
| signaturePublicKeyId | The `id` of the identity public key that signed the state transition |
| signature | Signature of state transition data |

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

> 📘
>
> For more detailed information, see the [Platform Protocol Reference - Document](platform-protocol-reference-document) page.