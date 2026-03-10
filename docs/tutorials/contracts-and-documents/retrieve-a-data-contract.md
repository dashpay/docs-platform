```{eval-rst}
.. tutorials-retrieve-data-contract:
```

# Retrieve a data contract

In this tutorial we will retrieve the data contract created in the [Register a Data Contract tutorial](../../tutorials/contracts-and-documents/register-a-data-contract.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

```{code-block} javascript
:caption: contract-retrieve.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk } = await setupDashClient();

// Default tutorial contract (testnet). Replace or override via DATA_CONTRACT_ID.
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ??
  'FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4';

try {
  const contract = await sdk.contracts.fetch(DATA_CONTRACT_ID);
  console.log('Contract retrieved:\n', contract.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## Example Data Contract

The following example response shows a retrieved contract:

```json
{
  "$format_version": "1",
  "id": "FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4",
  "config": {
    "$format_version": "0",
    "canBeDeleted": false,
    "readonly": false,
    "keepsHistory": false,
    "documentsKeepHistoryContractDefault": false,
    "documentsMutableContractDefault": true,
    "documentsCanBeDeletedContractDefault": true,
    "requiresIdentityEncryptionBoundedKey": null,
    "requiresIdentityDecryptionBoundedKey": null
  },
  "version": 2,
  "ownerId": "CtnBVhWjGhtPihUHKS132b9f9zSKMxRHDA6wSDtjRofy",
  "schemaDefs": null,
  "documentSchemas": {
    "note": {
      "type": "object",
      "properties": ["Object"],
      "additionalProperties": false
    }
  },
  "createdAt": null,
  "updatedAt": null,
  "createdAtBlockHeight": null,
  "updatedAtBlockHeight": null,
  "createdAtEpoch": null,
  "updatedAtEpoch": null,
  "groups": {},
  "tokens": {},
  "keywords": [],
  "description": null
}
```

:::{note}
Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.
:::

## What's Happening

After we initialize the client, we call `sdk.contracts.fetch()` with a contract ID. After the contract is retrieved, it is displayed on the console.
