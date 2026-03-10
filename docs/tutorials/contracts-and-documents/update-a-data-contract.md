```{eval-rst}
.. tutorials-update-data-contract:
```

# Update a data contract

It is possible to update existing data contracts in certain backwards-compatible ways. This includes:

* Adding new documents
* Adding new optional properties to existing documents
* Adding _non-unique_ indices for properties added in the update.

In this tutorial we will update an existing data contract.

## Prerequisites

* [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
* A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
* A configured client: [Setup SDK Client](../setup-sdk-client.md)
* A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
* A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

The following examples demonstrate updating an existing contract to add a new property to an existing document. The second example shows how to update a contract that has contract history enabled:

::::{tab-set}
:::{tab-item} Minimal contract
```javascript
import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identityKey, signer } = await keyManager.getAuth();

// Edit these values for your environment
// Your contract ID from the Register a Data Contract tutorial
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ?? 'YOUR_DATA_CONTRACT_ID';
const DOCUMENT_TYPE = 'note';

if (!DATA_CONTRACT_ID || DATA_CONTRACT_ID === 'YOUR_DATA_CONTRACT_ID') {
  throw new Error(
    'Set DATA_CONTRACT_ID (env var or in code) to your contract ID from the Register a Data Contract tutorial',
  );
}

try {
  const existingContract = await sdk.contracts.fetch(DATA_CONTRACT_ID);

  // Increment the contract version
  existingContract.version += 1;

  // Clone schemas, then add a new "author" property to the DOCUMENT_TYPE schema
  const updatedSchemas = structuredClone(existingContract.schemas);
  updatedSchemas[DOCUMENT_TYPE].properties.author = {
    type: 'string',
    position: 1,
  };

  // Apply the updated schemas (enable full validation)
  existingContract.setSchemas(updatedSchemas, undefined, true, undefined);

  // Submit the update
  await sdk.contracts.update({
    dataContract: existingContract,
    identityKey,
    signer,
  });

  console.log('Contract updated:\n', existingContract.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```
:::

:::{tab-item} Contract with history

Note: This code includes a workaround for a known bug ([dashpay/platform#3165](https://github.com/dashpay/platform/issues/3165)) where `sdk.contracts.fetch()` returns undefined for contracts with `keepsHistory: true`. Instead, it uses `sdk.contracts.getHistory()` to retrieve the contract and takes the latest revision. It also calls `setConfig()` to enable history tracking on the contract before submitting the update.

```javascript
import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identityKey, signer } = await keyManager.getAuth();

// Edit these values for your environment
// Your contract ID from the Register a Data Contract tutorial
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ?? 'YOUR_DATA_CONTRACT_ID';
const DOCUMENT_TYPE = 'note';

if (!DATA_CONTRACT_ID || DATA_CONTRACT_ID === 'YOUR_DATA_CONTRACT_ID') {
  throw new Error(
    'Set DATA_CONTRACT_ID (env var or in code) to your contract ID from the Register a Data Contract tutorial',
  );
}

try {
  // Workaround: sdk.contracts.fetch() returns undefined for contracts with
  // keepsHistory: true due to a proof verification bug (dashpay/platform#3165).
  // Use getHistory() and take the latest version instead.
  // Note: for contracts with many revisions, history results may be paginated
  // and the last entry here may not be the true latest version.
  const history = await sdk.contracts.getHistory({
    dataContractId: DATA_CONTRACT_ID,
  });

  let existingContract;
  for (const [, contract] of history) {
    existingContract = contract;
  }

  if (!existingContract) {
    throw new Error(`Contract ${DATA_CONTRACT_ID} not found`);
  }

  // Increment the contract version
  existingContract.version += 1;

  // Clone schemas, then add a new "author" property to the DOCUMENT_TYPE schema
  const updatedSchemas = structuredClone(existingContract.schemas);
  updatedSchemas[DOCUMENT_TYPE].properties.author = {
    type: 'string',
    position: 1,
  };

  // Apply the updated schemas (enable full validation)
  existingContract.setSchemas(updatedSchemas, undefined, true, undefined);

  // Enable storing of contract history
  existingContract.setConfig({
    canBeDeleted: false,
    readonly: false,
    keepsHistory: true,
    documentsKeepHistoryContractDefault: false,
    documentsMutableContractDefault: true,
  });

  // Submit the update
  await sdk.contracts.update({
    dataContract: existingContract,
    identityKey,
    signer,
  });

  console.log('Contract updated:\n', existingContract.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```
:::
::::

:::{note}
Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.
:::

## What's Happening

After we initialize the client, we get the auth key signer from the key manager. We then fetch the existing contract and modify the contract's document schema (adding an `author` property to the `note` document schema).

We clone the existing schemas, add the new property, then apply them with `setSchemas()`. After incrementing the contract version, we call `sdk.contracts.update()` with the modified contract and signing credentials to submit the update to the network.
