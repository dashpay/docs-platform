# DashPay

## Overview

DashPay is one of the first applications of Dash Platform's [data contracts](explanation-platform-protocol-data-contract) . At its core DashPay is a data contract that enables a decentralized application that creates bidirectional [direct settlement payment channels](reference-glossary#direct-settlement-payment-channel-dspc) between [identities](explanation-identity).

> 📘
>
> For previews of an updated Dash mobile wallet UI based on the DashPay contract or to join the alpha test program, please visit the <a href="https://www.dash.org/dashpay/" target="_blank">DashPay landing page at dash.org</a>.

The DashPay contract enables an improved Dash wallet experience with features including:

- **User Centric Interaction**: DashPay brings users front and center in a cryptocurrency wallet. Instead of sending to an address, a user sends directly to another user. Users will have a username, a display name, an avatar and a quick bio/information message.

- **Easy Payments**: Once two users have exchanged contact requests, each can make payments to the other without manually sharing addresses via emails, texts or BIP21 QR codes. This is because every contact request contains the information (an encrypted extended public key) required to send payments to the originator of the request. When decrypted, this extended public key can be used by the recipient of the contact request to generate payment addresses for the originator of the contact request.

- **Payment History**: When a contact is established, a user can easily track the payments they have sent to another user and the payments that they have received from that other user. A user will have an extended private key to track payments that are received from the other user and an extended public key to track payments that are sent to that other user.

- **Payment Participant Protection**: The extended public keys in contact requests are encrypted in such a way that only the two users involved in a contact's two way relationship can decrypt those keys. This ensures that when any two users make payments in DashPay, only they know the sender and receiver while 3rd parties do not.

## Details

The contract defines three document types: `contactRequest`, `profile` and `contactInfo`. ContactRequest documents are the most important. They are used to establish relationships and payment channels between Dash identities. Profile documents are used to store public facing information about Dash identities including avatars and display names. ContactInfo documents can be used to store private information about other Dash identities.

### Establishing a Contact

1. Bob installs wallet software that supports DashPay.
2. Bob [registers an identity](tutorial-register-an-identity) and then [creates a username](tutorial-register-a-name-for-an-identity) through [DPNS](explanation-dpns).
3. Bob searches for Carol by her username. Behind the scenes this search returns the unique identifier for Carol's identity. An example of doing this can be seen in the [Retrieve a Name tutorial](doc:tutorial-retrieve-a-name).
4. Bob sends a contact request containing an encrypted extended public key to Carol. This establishes a one way relationship from Bob to Carol.
5. Carol accepts the request by sending a contact request containing an encrypted extended public key back to Bob. This establishes a one way relationship from Carol to Bob.
6. Bob and Carol are now contacts of one another and can make payments to each other by decrypting the extended public key received from the other party and deriving payment addresses from it. Since both have established one way relationships with each other, they now have a two way relationship. If Bob gets a new device, he can use his recovery phrase from step one and restore his wallet, contacts (including Carol) and payments to and from his contacts.

[block:image]
{
  "images": [
    {
      "image": [
        "https://files.readme.io/158594c-Frame-78-2.png",
        "Frame-78-2.png",
        866,
        750,
        "#98afbd"
      ],
      "sizing": "80",
      "caption": "Contact-based Wallet"
    }
  ]
}
[/block]
### Implementation

DashPay has many constraints as defined in the [DashPay data contract](https://github.com/dashevo/platform/blob/master/packages/dashpay-contract/schema/dashpay.schema.json). Additionally, the DashPay data triggers defined in [js-dpp](https://github.com/dashevo/platform/tree/master/packages/js-dpp/lib/dataTrigger/dashpayDataTriggers) enforce additional validation rules related to the `contactRequest` document.

> 👍 DashPay DIP
>
> Please refer to the [DashPay Dash Improvement Proposal (DIP)](https://github.com/dashpay/dips/blob/master/dip-0015.md) for more extensive background information and complete details about the data contract.

- <a href="https://github.com/dashpay/dips/blob/master/dip-0015.md#the-contact-request" target="_blank">Contact request details</a>
- <a href="https://github.com/dashpay/dips/blob/master/dip-0015.md#the-profile" target="_blank">Profile details</a>
- <a href="https://github.com/dashpay/dips/blob/master/dip-0015.md#contact-info" target="_blank">Contact Info details</a>

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