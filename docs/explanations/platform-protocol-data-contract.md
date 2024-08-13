```{eval-rst}
.. _explanations-data-contract:
```

# Data Contract

## Overview

As described briefly in the [Dash Platform Protocol explanation](../explanations/platform-protocol.md#data-contract), Dash Platform uses data contracts to define the schema (structure) of data it stores. Therefore, an application must first register a data contract before using the platform to store its data. Then, when the application attempts to store or change data, the request will only succeed if the new data matches the data contract's schema.

The first two data contracts are the [DashPay wallet](https://www.dash.org/dashpay/) and [Dash Platform Name Service (DPNS)](../explanations/dpns.md). The concept of the social, username-based DashPay wallet served as the catalyst for development of the platform, with DPNS providing the mechanism to support usernames.

## Details

### Ownership

Data contracts are owned by the [identity](../explanations/identity.md) that registers them. Each identity may be used to create multiple data contracts and data contract updates can only be made by the identity that owns the contract.

### Structure

Each data contract must define several fields. When using the [reference implementation](https://github.com/dashpay/platform/tree/master/packages/rs-dpp) of the Dash Platform Protocol, some of these fields are automatically set to a default value and do not have to be explicitly provided. These include:

* The platform protocol schema it uses
* A contract ID (generated from a hash of the data contract's owner identity plus some entropy)
* One or more [documents](../explanations/platform-protocol-document.md)

For a practical example, see the [DashPay contract](#example-contract).

### Registration

Once a [Dash Platform Protocol](../explanations/platform-protocol.md) compliant data contract has been defined, it may be registered on the platform. Registration is completed by submitting a state transition containing the data contract to [DAPI](../explanations/dapi.md).

The drawing below illustrates the steps an application developer follows to complete registration.

```{eval-rst}
.. figure:: ../../img/data-contract.svg
   :class: no-scaled-link
   :align: center
   :width: 80%
   :alt: Data Contract Registration

   Data Contract Registration
```

### Updates

#### Contract revision history

Dash Platform v0.25 added optional contract revision history storage. Contracts using this feature maintain a record of contract revisions which can be retrieved and verified as needed.

#### Identity key binding

Dash Platform v0.25 added key access rules that enable adding an encryption or decryption identity key that can only be used for the specific contract (or document) designated when the key is added. This provides a more granular and secure approach to key management.

#### Contract updates

Dash Platform v0.22 added the ability to update existing data contracts in certain backwards-compatible ways. This includes adding new documents, adding new optional properties to existing documents, and adding non-unique indices for properties added in the update.

> 📘
>
> For more detailed information, see the [Platform Protocol Reference - Data Contract](../protocol-ref/data-contract.md) page.

## Example Contract

The [DashPay contract](https://github.com/dashpay/platform/blob/master/packages/dashpay-contract/schema/dashpay.schema.json) is included below for reference. It defines a `contact` document and a `profile` document. Each of these documents then defines the properties and indices they require:

```json
{
  "profile": {
    "type": "object",
    "indices": [
      {
        "name": "ownerId",
        "properties": [
          {
            "$ownerId": "asc"
          }
        ],
        "unique": true
      },
      {
        "name": "ownerIdAndUpdatedAt",
        "properties": [
          {
            "$ownerId": "asc"
          },
          {
            "$updatedAt": "asc"
          }
        ]
      }
    ],
    "properties": {
      "avatarUrl": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048,
        "position": 0
      },
      "avatarHash": {
        "type": "array",
        "byteArray": true,
        "minItems": 32,
        "maxItems": 32,
        "description": "SHA256 hash of the bytes of the image specified by avatarUrl",
        "position": 1
      },
      "avatarFingerprint": {
        "type": "array",
        "byteArray": true,
        "minItems": 8,
        "maxItems": 8,
        "description": "dHash the image specified by avatarUrl",
        "position": 2
      },
      "publicMessage": {
        "type": "string",
        "maxLength": 140,
        "position": 3
      },
      "displayName": {
        "type": "string",
        "maxLength": 25,
        "position": 4
      }
    },
    "required": [
      "$createdAt",
      "$updatedAt"
    ],
    "additionalProperties": false
  },
  "contactInfo": {
    "type": "object",
    "indices": [
      {
        "name": "ownerIdAndKeys",
        "properties": [
          {
            "$ownerId": "asc"
          },
          {
            "rootEncryptionKeyIndex": "asc"
          },
          {
            "derivationEncryptionKeyIndex": "asc"
          }
        ],
        "unique": true
      },
      {
        "name": "ownerIdAndUpdatedAt",
        "properties": [
          {
            "$ownerId": "asc"
          },
          {
            "$updatedAt": "asc"
          }
        ]
      }
    ],
    "properties": {
      "encToUserId": {
        "type": "array",
        "byteArray": true,
        "minItems": 32,
        "maxItems": 32,
        "position": 0
      },
      "rootEncryptionKeyIndex": {
        "type": "integer",
        "minimum": 0,
        "position": 1
      },
      "derivationEncryptionKeyIndex": {
        "type": "integer",
        "minimum": 0,
        "position": 2
      },
      "privateData": {
        "type": "array",
        "byteArray": true,
        "minItems": 48,
        "maxItems": 2048,
        "position": 3,
        "description": "This is the encrypted values of aliasName + note + displayHidden encoded as an array in cbor"
      }
    },
    "required": [
      "$createdAt",
      "$updatedAt",
      "encToUserId",
      "privateData",
      "rootEncryptionKeyIndex",
      "derivationEncryptionKeyIndex"
    ],
    "additionalProperties": false
  },
  "contactRequest": {
    "requiresIdentityEncryptionBoundedKey": 2,
    "requiresIdentityDecryptionBoundedKey": 2,
    "type": "object",
    "indices": [
      {
        "name": "ownerIdUserIdAndAccountRef",
        "properties": [
          {
            "$ownerId": "asc"
          },
          {
            "toUserId": "asc"
          },
          {
            "accountReference": "asc"
          }
        ],
        "unique": true
      },
      {
        "name": "ownerIdUserId",
        "properties": [
          {
            "$ownerId": "asc"
          },
          {
            "toUserId": "asc"
          }
        ]
      },
      {
        "name": "userIdCreatedAt",
        "properties": [
          {
            "toUserId": "asc"
          },
          {
            "$createdAt": "asc"
          }
        ]
      },
      {
        "name": "ownerIdCreatedAt",
        "properties": [
          {
            "$ownerId": "asc"
          },
          {
            "$createdAt": "asc"
          }
        ]
      }
    ],
    "properties": {
      "toUserId": {
        "type": "array",
        "byteArray": true,
        "minItems": 32,
        "maxItems": 32,
        "position": 0,
        "contentMediaType": "application/x.dash.dpp.identifier"
      },
      "encryptedPublicKey": {
        "type": "array",
        "byteArray": true,
        "minItems": 96,
        "maxItems": 96,
        "position": 1
      },
      "senderKeyIndex": {
        "type": "integer",
        "minimum": 0,
        "position": 2
      },
      "recipientKeyIndex": {
        "type": "integer",
        "minimum": 0,
        "position": 3
      },
      "accountReference": {
        "type": "integer",
        "minimum": 0,
        "position": 4
      },
      "encryptedAccountLabel": {
        "type": "array",
        "byteArray": true,
        "minItems": 48,
        "maxItems": 80,
        "position": 5
      },
      "autoAcceptProof": {
        "type": "array",
        "byteArray": true,
        "minItems": 38,
        "maxItems": 102,
        "position": 6
      },
      "coreHeightCreatedAt": {
        "type": "integer",
        "minimum": 1,
        "position": 7
      }
    },
    "required": [
      "$createdAt",
      "toUserId",
      "encryptedPublicKey",
      "senderKeyIndex",
      "recipientKeyIndex",
      "accountReference"
    ],
    "additionalProperties": false
  }
}
```

This is a visualization of the JSON data contract as UML class diagram for better understanding of the structure:

```{eval-rst}
.. figure:: ./img/dashpay-uml.png
   :class: no-scaled-link
   :align: center
   :width: 90%
   :alt: Dashpay Contract Diagram

   Dashpay Contract Diagram
```

View [a full-size copy of this diagram](./img/dashpay-uml.png).
