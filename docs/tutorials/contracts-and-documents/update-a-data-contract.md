```{eval-rst}
.. tutorials-update-data-contract:
```

# Update a data contract

Since Dash Platform v0.22, it is possible to update existing data contracts in certain backwards-compatible ways. This includes:

* Adding new documents
* Adding new optional properties to existing documents
* Adding _non-unique_ indices for properties added in the update.

In this tutorial we will update an existing data contract.

## Prerequisites

* [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
* A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
* A configured client: [Setup SDK Client](../setup-sdk-client.md)
* A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
* A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

The following examples demonstrate updating an existing contract to add a new property to an existing document. The second example shows how to update a contract that has contract history enabled:

::::{tab-set}
:::{tab-item} Minimal contract
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const updateContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const existingDataContract = await platform.contracts.get('a contract ID goes here');
  const documentSchema = existingDataContract.getDocumentSchema('note');

  documentSchema.properties.author = {
    type: 'string',
    position: 1,
  };

  existingDataContract.setDocumentSchema('note', documentSchema);

  // Sign and submit the data contract
  await platform.contracts.update(existingDataContract, identity);
  return existingDataContract;
};

updateContract()
  .then((d) => console.log('Contract updated:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::

:::{tab-item} Contract with history
```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const updateContract = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const existingDataContract = await platform.contracts.get('a contract ID goes here');
  const documentSchema = existingDataContract.getDocumentSchema('note');

  documentSchema.properties.author = {
    type: 'string',
    position: 1,
  };

  existingDataContract.setDocumentSchema('note', documentSchema);
  existingDataContract.setConfig({
    keepsHistory: true, // Enable storing of contract history
  });

  // Sign and submit the data contract
  await platform.contracts.update(existingDataContract, identity);
  return existingDataContract;
};

updateContract()
  .then((d) => console.log('Contract updated:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
:::
::::

:::{note}
Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.
:::

## What's Happening

After we initialize the Client, we retrieve an existing contract owned by our identity. We then get the contract's document schema and modify a document (adding an `author` property to the `note` document in the example). The `setDocumentSchema` method takes two arguments: the name of the document schema to be updated and the object containing the updated document types.

Once the data contract has been updated, we still need to submit it to DAPI. The `platform.contracts.update` method takes a data contract and an identity parameter. Internally, it creates a State Transition containing the updated contract, signs the state transition, and submits the signed state transition to DAPI. A response will only be returned if an error is encountered.

:::{note}
:class: note
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::
