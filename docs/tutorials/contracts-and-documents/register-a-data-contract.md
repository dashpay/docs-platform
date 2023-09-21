# Register a data contract

In this tutorial we will register a data contract.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md) 

# Code

## Defining contract documents

As described in the [data contract explanation](../../explanations/platform-protocol-data-contract.md#structure), data contracts must include one or more developer-defined [documents](../../explanations/platform-protocol-document.md). 

The most basic example below (tab 1) demonstrates a data contract containing a single document type (`note`) which has a single string property (`message`). 

The second tab shows the same data contract with an index defined on the `$ownerId` field. This would allow querying for documents owned by a specific identity using a [where clause](../../reference/query-syntax.md#where-clause).

The third tab shows a data contract using the [JSON-Schema $ref feature](https://json-schema.org/understanding-json-schema/structuring.html#reuse) that enables reuse of defined objects. Note that the $ref keyword has been [temporarily disabled](https://github.com/dashevo/platform/pull/300) since Platform v0.22.

The fourth tab shows a data contract requiring the optional `$createdAt` and `$updatedAt` [base fields](../../explanations/platform-protocol-document.md#base-fields). Using these fields enables retrieving timestamps that indicate when a document was created or modified.

> 🚧 
> 
> Since Platform v0.23, an index can [only use the ascending order](https://github.com/dashevo/platform/pull/435) (`asc`). Future updates will remove this restriction.

::::{tab-set-code}

```json 1. Minimal contract
// 1. Minimal contract
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string"
      }
    },
    "additionalProperties": false
  }
}
```
```json 2. Indexed
//  2. Indexed
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
        "type": "string"
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
```json
//  3. References ($ref)
// NOTE: The `$ref` keyword is temporarily disabled for Platform v0.22.
{
  "customer": {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "billing_address": { "$ref": "#/$defs/address" },
      "shipping_address": { "$ref": "#/$defs/address" }
    },
    "additionalProperties": false
  }
}

/*
The contract document defined above is dependent on the following object 
being added to the contract via the contracts `.setDefinitions` method:

{
  address: {
    type: "object",
    properties: {
      street_address: { type: "string" },
      city:           { type: "string" },
      state:          { type: "string" }
    },
    required: ["street_address", "city", "state"],
    additionalProperties: false
  }
}
*/
```
```json
//  4. Timestamps
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string"
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
```json
// 5. Binary data
{
 "block": {
   "type": "object",
    "properties": {
      "hash": {
        "type": "array",
        "byteArray": true,
        "maxItems": 64,
        "description": "Store block hashes"
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

::::

> 📘 
> 
> Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.

## Registering the data contract

The following examples demonstrate the details of creating contracts using the features [described above](#defining-contract-documents):

::::{tab-set-code}

```javascript 1. Minimal contract
// 1. Minimal contract
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },    
  },
};
const client = new Dash.Client(clientOpts);

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    note: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
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
```javascript 2. Indexed
// 2. Indexed
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

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
```javascript 3. References ($ref)
// 3. References ($ref)
// NOTE: The `$ref` keyword is temporarily disabled for Platform v0.22.
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  // Define a reusable object
  const definitions = {
    address: {
      type: 'object',
      properties: {
        street_address: { type: 'string' },
        city: { type: 'string' },
        state: { type: 'string' },
      },
      required: ['street_address', 'city', 'state'],
      additionalProperties: false,
    },
  };

  // Create a document with properties using a definition via $ref
  const contractDocuments = {
    customer: {
      type: 'object',
      properties: {
        name: { type: 'string' },
        billing_address: { $ref: '#/$defs/address' },
        shipping_address: { $ref: '#/$defs/address' },
      },
      additionalProperties: false,
    },
  };
  
  const contract = await platform.contracts.create(contractDocuments, identity);

  // Add reusable definitions referred to by "$ref" to contract
  contract.setDefinitions(definitions);
  console.dir({ contract: contract.toJSON() });

  await platform.contracts.publish(contract, identity);
  return contract;
};

registerContract()
  .then((d) => console.log('Contract registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
```javascript 4. Timestamps
// 4. Timestamps
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

const registerContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const contractDocuments = {
    note: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
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
```javascript 5. Binary data
// 5. Binary data
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

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

::::

> 👍 
> 
> **Make a note of the returned data contract `id` as it will be used used in subsequent tutorials throughout the documentation.**

# What's Happening

After we initialize the Client, we create an object defining the documents this data contract requires (e.g. a `note` document in the example). The `platform.contracts.create` method takes two arguments: a contract definitions JSON-schema object and an identity. The contract definitions object consists of the document types being created (e.g. `note`). It defines the properties and any indices. 

Once the data contract has been created, we still need to submit it to DAPI. The `platform.contracts.publish` method takes a data contract and an identity parameter. Internally, it creates a State Transition containing the previously created contract, signs the state transition, and submits the signed state transition to DAPI. A response will only be returned if an error is encountered.

> 📘 Wallet Operations
> 
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
> 
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.