```{eval-rst}
.. tutorials-retrieve-data-contract-history:
```

# Retrieve data contract history

In this tutorial we will retrieve the history of a data contract created in the [Register a Data
Contract tutorial](../../tutorials/contracts-and-documents/register-a-data-contract.md). Only
contracts that have enabled the `keepsHistory` option during contract creation will store revision
information.

## Prerequisites

* [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
* A configured client: [Setup SDK Client](../setup-sdk-client.md)
* A Dash Platform contract ID for a contract configured to keep history: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

```{code-block} javascript
:caption: retrieveContractHistory.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk } = await setupDashClient();

// Default tutorial contract with history (testnet). Replace or override via DATA_CONTRACT_ID.
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ??
  '5J4VPym1Bnc2Ap9bbo9wNw6fZLGsCzDM7ZScdzcggN1r';

try {
  const history = await sdk.contracts.getHistory({
    dataContractId: DATA_CONTRACT_ID,
  });

  for (const [timestamp, contract] of history) {
    console.log(`Version at ${timestamp}:`, contract.toJSON());
  }
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## Example data contract history

The following example response shows a retrieved contract history:

```text
Version at 1772722751435: {
  '$format_version': '1',
  id: '5J4VPym1Bnc2Ap9bbo9wNw6fZLGsCzDM7ZScdzcggN1r',
  config: {
    '$format_version': '1',
    canBeDeleted: false,
    readonly: false,
    keepsHistory: true,
    documentsKeepHistoryContractDefault: false,
    documentsMutableContractDefault: true,
    documentsCanBeDeletedContractDefault: true,
    requiresIdentityEncryptionBoundedKey: null,
    requiresIdentityDecryptionBoundedKey: null,
    sizedIntegerTypes: true
  },
  version: 1,
  ownerId: 'FKZZFDTfGdSWUmL2g7H9e46pMJMPQp9DHQcvjrsS6884',
  schemaDefs: null,
  documentSchemas: {
    note: {
      type: 'object',
      properties: [Object],
      additionalProperties: false
    }
  },
  createdAt: 1772722751435,
  updatedAt: null,
  createdAtBlockHeight: 273561,
  updatedAtBlockHeight: null,
  createdAtEpoch: 14269,
  updatedAtEpoch: null,
  groups: {},
  tokens: {},
  keywords: [],
  description: null
}
```

:::{note}
Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.
:::

## What's Happening

After we initialize the client, we request a contract's history. The contract ID defaults to a
testnet tutorial contract but can be overridden via the `DATA_CONTRACT_ID` environment variable. The
`sdk.contracts.getHistory` method takes an object with a `dataContractId` property. It returns a
`Map` where each key is a timestamp (`BigInt`) and each value is the contract at that revision.
After the contract history is retrieved, we iterate over the entries and display each revision on the
console.
