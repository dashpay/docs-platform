# Data Contract

## Overview

As described briefly in the [Dash Platform Protocol explanation](explanation-platform-protocol#data-contract), Dash Platform uses data contracts to define the schema (structure) of data it stores. Therefore, an application must first register a data contract before using the platform to store its data. Then, when the application attempts to store or change data, the request will only succeed if the new data matches the data contract's schema.

The first two data contracts are the [DashPay wallet](https://www.dash.org/dashpay/) and [Dash Platform Name Service (DPNS)](explanation-dpns). The concept of the social, username-based DashPay wallet served as the catalyst for development of the platform, with DPNS providing the mechanism to support usernames.

## Details

### Ownership

Data contracts are owned by the [identity](explanation-identity) that registers them. Each identity may be used to create multiple data contracts and data contract updates can only be made using the identity that owns it.

### Structure

Each data contract must define several fields. When using the [JavaScript implementation](https://github.com/dashevo/platform/tree/master/packages/js-dpp) of the Dash Platform Protocol, some of these fields are automatically set to a default value and do not have to be explicitly provided. These include:
 - The platform protocol schema it uses (default: defined by [js-dpp](https://github.com/dashevo/platform/blob/master/packages/js-dpp/lib/dataContract/DataContract.js#L352))
 - A contract ID (generated from a hash of the data contract's owner identity plus some entropy)
 - One or more documents

In the [example contract](#example-contract) shown below, a `contact` document and a `profile` document are defined. Each of these documents then defines the properties and indices it requires.

### Registration

Once a [Dash Platform Protocol](explanation-platform-protocol) compliant data contract has been defined, it may be registered on the platform. Registration is completed by submitting a state transition containing the data contract to [DAPI](explanation-dapi).

The drawing below illustrates the steps an application developer follows to complete registration.
[block:image]
{
  "images": [
    {
      "image": [
        "https://files.readme.io/b372cf0-Data_Contract.svg",
        "Data Contract.svg",
        673,
        531,
        "#d9ead3"
      ],
      "caption": "Data Contract Registration"
    }
  ]
}
[/block]
### Updates

Since Dash Platform v0.22, it is possible to update existing data contracts in certain backwards-compatible ways. This includes adding new documents, adding new optional properties to existing documents, and adding non-unique indices for properties added in the update.

> 📘
>
> For more detailed information, see the [Platform Protocol Reference - Data Contract](platform-protocol-reference-data-contract) page.

## Example Contract

An example contract for [DashPay](https://github.com/dashevo/platform/blob/master/packages/dashpay-contract/schema/dashpay.schema.json) is included below:

```json
{
  "profile": {
    "type": "object",
    "indices": [
      {
        "properties": [
          {
            "$ownerId": "asc"
          }
        ],
        "unique": true
      },
      {
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
        "format": "url",
        "maxLength": 2048
      },
      "avatarHash": {
        "type": "array",
        "byteArray": true,
        "minItems": 32,
        "maxItems": 32,
        "description": "SHA256 hash of the bytes of the image specified by avatarUrl"
      },
      "avatarFingerprint": {
        "type": "array",
        "byteArray": true,
        "minItems": 8,
        "maxItems": 8,
        "description": "dHash the image specified by avatarUrl"
      },
      "publicMessage": {
        "type": "string",
        "maxLength": 140
      },
      "displayName": {
        "type": "string",
        "maxLength": 25
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
        "maxItems": 32
      },
      "rootEncryptionKeyIndex": {
        "type": "integer",
        "minimum": 0
      },
      "derivationEncryptionKeyIndex": {
        "type": "integer",
        "minimum": 0
      },
      "privateData": {
        "type": "array",
        "byteArray": true,
        "minItems": 48,
        "maxItems": 2048,
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
    "type": "object",
    "indices": [
      {
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
        "contentMediaType": "application/x.dash.dpp.identifier"
      },
      "encryptedPublicKey": {
        "type": "array",
        "byteArray": true,
        "minItems": 96,
        "maxItems": 96
      },
      "senderKeyIndex": {
        "type": "integer",
        "minimum": 0
      },
      "recipientKeyIndex": {
        "type": "integer",
        "minimum": 0
      },
      "accountReference": {
        "type": "integer",
        "minimum": 0
      },
      "encryptedAccountLabel": {
        "type": "array",
        "byteArray": true,
        "minItems": 48,
        "maxItems": 80
      },
      "autoAcceptProof": {
        "type": "array",
        "byteArray": true,
        "minItems": 38,
        "maxItems": 102
      },
      "coreHeightCreatedAt": {
        "type": "integer",
        "minimum": 1
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

[block:image]
{
  "images": [
    {
      "image": [
        "https://files.readme.io/964c219-dashpay-plantuml.png",
        "dashpay-plantuml.png",
        962,
        755,
        "#f5f1e8"
      ],
      "caption": "Dashpay Contract Diagram"
    }
  ]
}
[/block]