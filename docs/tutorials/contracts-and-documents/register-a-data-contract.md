```{eval-rst}
.. tutorials-register-data-contract:
```

# Register a data contract

In this tutorial we will register a data contract.

## Prerequisites

* [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
* A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
* A configured client: [Setup SDK Client](../setup-sdk-client.md)
* A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

### Defining contract documents

As described in the [data contract explanation](../../explanations/platform-protocol-data-contract.md#structure), data contracts must include one or more developer-defined [documents](../../explanations/platform-protocol-document.md).

The most basic example below (tab 1) demonstrates a data contract containing a single document type (`note`) which has a single string property (`message`).

The second tab shows the same data contract with an index defined on the `$ownerId` field. This would allow querying for documents owned by a specific identity using a [where clause](../../reference/query-syntax.md#where-clause).

The third tab shows a data contract requiring the optional `$createdAt` and `$updatedAt` [base
fields](../../explanations/platform-protocol-document.md#base-fields). Using these fields enables
retrieving timestamps that indicate when a document was created or modified.

The fourth tab shows a data contract using a byte array. This allows a contract to store binary
data.

The fifth tab shows a data contract configured to store contract history. This allows all contract
revisions to be retrieved in the future as needed.

The sixth tab shows a data contract configured for creating NFTs. It allows documents to be deleted, transferred, or traded. It also limits document creation to the contract owner. See the [NFT explanation section](../../explanations/nft.md) for more details about NFTs on Dash Platform. **_Note: the JavaScript SDK supports NFT contract registration, but does not currently support trades or transfers._**

> 🚧
>
> Since Platform v0.25.16, each document property must assign `position` value to support [backwards compatibility](https://github.com/dashpay/platform/pull/1594) for contract updates.
>
> Since Platform v0.23, an index can [only use the ascending order](https://github.com/dashevo/platform/pull/435) (`asc`). Future updates will remove this restriction.

::::{tab-set}
:::{tab-item} 1. Minimal contract
:sync: minimal
```json
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string",
        "position": 0
      }
    },
    "additionalProperties": false
  }
}
```
:::

:::{tab-item} 2. Indexed
:sync: indexed
```json
{
  "note": {
    "type": "object",
    "indices": [
      {
        "name": "ownerId",
        "properties": [{ "$ownerId": "asc" }], "unique": false }
    ],
    "properties": {
      "message": {
        "type": "string",
        "position": 0
      }
    },
    "additionalProperties": false
  }
}

/*
An identity's documents are accessible via a query including a where clause like:
{
  where: [['$ownerId', '==', 'an identity id']],
}
*/
```
:::

:::{tab-item} 3. Timestamps
:sync: timestamp
```json
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string",
        "position": 0
      }
    },
    "required": ["$createdAt", "$updatedAt"],
    "additionalProperties": false
  }
}

/*
If $createdAt and/or $updatedAt are added to the list of required properties 
for a document, all documents of that type will store a timestamp indicating
when the document was created or modified. 

This information will be returned when the document is retrieved.
*/
```
:::

:::{tab-item} 4. Binary data
:sync: binary
```json
{
 "block": {
   "type": "object",
    "properties": {
      "hash": {
        "type": "array",
        "byteArray": true,
        "maxItems": 64,
        "description": "Store block hashes",
        "position": 0
      }
    },
    "additionalProperties": false
  }
}
 
/*
Setting `"byteArray": true` indicates that the provided data will be an 
array of bytes (e.g. a NodeJS Buffer).
*/
```
:::

:::{tab-item} 5. Contract with history
:sync: history
```json
// Identical to the minimal contract
// Contract history configuration is done in code and
// is not part of the contract itself.
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string",
        "position": 0
      }
    },
    "additionalProperties": false
  }
}
```
:::

:::{tab-item} 6. NFT Contract
:sync: nft
```json
// To use contract documents as NFTs, configure settings for modifying
// deleting, transferring, trading, or restricting creation as needed
{
  "card": {
    "type": "object",
    "documentsMutable": false,    // true = documents can be modified (replaced)
    "canBeDeleted": true,         // true = documents can be deleted
    "transferable": 1,            // 0 = transfers disabled; 1 = transfers enabled
    "tradeMode": 1,               // 0 = no trading; 1 = direct purchases
    "creationRestrictionMode": 1, // 0 = anyone can mint; 1 = only contract owner can mint
    "properties": {
      "name": {
        "type": "string",
        "description": "Name of the card",
        "minLength": 0,
        "maxLength": 63,
        "position": 0
      },
      "description": {
        "type": "string",
        "description": "Description of the card",
        "minLength": 0,
        "maxLength": 256,
        "position": 1
      },
      "attack": {
        "type": "integer",
        "description": "Attack power of the card",
        "position": 2
      },
      "defense": {
        "type": "integer",
        "description": "Defense level of the card",
        "position": 3
      }
    },
    "indices": [
      {
        "name": "owner",
        "properties": [
          {
            "$ownerId": "asc"
          }
        ]
      },
      {
        "name": "attack",
        "properties": [
          {
            "attack": "asc"
          }
        ]
      },
      {
        "name": "defense",
        "properties": [
          {
            "defense": "asc"
          }
        ]
      }
    ],
    "required": [
      "name",
      "attack",
      "defense"
    ],
    "additionalProperties": false
  }
}
```
:::
::::

> 📘
>
> Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.

### Registering the data contract

The following examples demonstrate the details of creating contracts using the features [described above](#defining-contract-documents). Also, note that the sixth tab shows a data contract with contract history enabled to store each contract revision so it can be retrieved as needed for future reference:

::::{tab-set}
:::{tab-item} 1. Minimal contract
:sync: minimal
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    note: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          "position": 0
        },
      },
      additionalProperties: false,
    },
  };

  const contract = await platform.contracts.create(contractDocuments, identity);
  console.dir({ contract: contract.toJSON() });

  // Sign and submit the data contract
  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::

:::{tab-item} 2. Indexed
:sync: indexed
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    note: {
      type: 'object',
      indices: [{
        name: 'ownerId',
        properties: [{ $ownerId: 'asc' }],
        unique: false,
      }],
      properties: {
        message: {
          type: 'string',
          "position": 0
        },
      },
      additionalProperties: false,
    },
  };

  const contract = await platform.contracts.create(contractDocuments, identity);
  console.dir({ contract: contract.toJSON() });

  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::

:::{tab-item} 3. Timestamps
:sync: timestamp
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    note: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          "position": 0
        },
      },
      required: ['$createdAt', '$updatedAt'],
      additionalProperties: false,
    },
  };

  const contract = await platform.contracts.create(contractDocuments, identity);
  console.dir({ contract: contract.toJSON() });

  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::

:::{tab-item} 4. Binary data
:sync: binary
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    block: {
      type: 'object',
      properties: {
        hash: {
          type: 'array',
          byteArray: true,
          maxItems: 64,
          description: 'Store block hashes',
          "position": 0
        },
      },
      additionalProperties: false,
    },
  };

  const contract = await platform.contracts.create(contractDocuments, identity);
  console.dir({ contract: contract.toJSON() }, { depth: 5 });

  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::

:::{tab-item} 5. Contract with history
:sync: history
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    note: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          "position": 0
        },
      },
      additionalProperties: false,
    },
  };

  const contract = await platform.contracts.create(contractDocuments, identity);
  contract.setConfig({
    canBeDeleted: false,
    readonly: false,    // Make contract read-only
    keepsHistory: true, // Enable storing of contract history
    documentsKeepHistoryContractDefault: false,
    documentsMutableContractDefault: true,
  })
  console.dir({ contract: contract.toJSON() });

  // Sign and submit the data contract
  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::

:::{tab-item} 6. NFT Contract
:sync: nft
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    card: {
      type: "object",
      documentsMutable: false,    // Documents cannot be modified/replaced
      canBeDeleted: true,         // Documents can be deleted
      transferable: 1,            // Transfers enabled
      tradeMode: 1,               // Direct purchase trades enabled
      creationRestrictionMode: 1, // Only the contract owner can mint      
      properties: {
        name: {
          type: "string",
          description: "Name of the card",
          minLength: 0,
          maxLength: 63,
          position: 0
        },
        description: {
          type: "string",
          description: "Description of the card",
          minLength: 0,
          maxLength: 256,
          position: 1
        },
        attack: {
          type: "integer",
          description: "Attack power of the card",
          position: 2
        },
        defense: {
          type: "integer",
          description: "Defense level of the card",
          position: 3
        }
      },
      indices: [
        {
          name: "owner",
          properties: [
            {
              $ownerId: "asc"
            }
          ]
        },
        {
          name: "attack",
          properties: [
            {
              attack: "asc"
            }
          ]
        },
        {
          name: "defense",
          properties: [
            {
              defense: "asc"
            }
          ]
        }
      ],
      required: [
        "name",
        "attack",
        "defense"
      ],
      additionalProperties: false
    }
  }

  const contract = await platform.contracts.create(contractDocuments, identity);
  console.dir({ contract: contract.toJSON() });

  // Sign and submit the data contract
  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::
::::

> 👍
>
> **Make a note of the returned data contract `id` as it will be used used in subsequent tutorials throughout the documentation.**

## What's Happening

After we initialize the Client, we create an object defining the documents this data contract requires (e.g. a `note` document in the example). The `platform.contracts.create` method takes two arguments: a contract definitions JSON-schema object and an identity. The contract definitions object consists of the document types being created (e.g. `note`). It defines the properties and any indices.

Once the data contract has been created, we still need to submit it to DAPI. The `platform.contracts.publish` method takes a data contract and an identity parameter. Internally, it creates a State Transition containing the previously created contract, signs the state transition, and submits the signed state transition to DAPI. A response will only be returned if an error is encountered.

> 📘 Wallet Sync
>
> Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
