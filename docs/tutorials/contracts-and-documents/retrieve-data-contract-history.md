# Retrieve data contract history

In this tutorial we will retrieve the history of a data contract created in the [Register a Data
Contract tutorial](../../tutorials/contracts-and-documents/register-a-data-contract.md). Only
contracts that have enabled the `keepsHistory` option during contract creation will store revision
information.

## Prerequisites

* [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
* A Dash Platform contract ID for a contract configured to keep history: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

### Retrieving data contract history

```javascript
const Dash = require('dash');

const client = new Dash.Client({ network: 'testnet' });

const retrieveContractHistory = async () => {
  const contractId = '8cvMFwa2YbEsNNoc1PXfTacy2PVq2SzVnkZLeQSzjfi6'
  return await client.platform.contracts.history(contractId, 0, 10, 0);
};

retrieveContractHistory()
  .then((d) => {
    Object.entries(d).forEach(([key, value]) => {
      client.platform.dpp.dataContract
        .createFromObject(value)
        .then((contract) => console.dir(contract.toJSON(), { depth: 5 }));
    });
  })
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

## Example data contract history

The following example response shows a retrieved contract history:

```json
[
  {
    "$format_version": "0",
    "id": "BWgzcW4XRhmYKzup1xY8fMi3ZHGG1Hf8fD9Rm3e3bopm",
    "config": {
      "$format_version": "0",
      "canBeDeleted": false,
      "readonly": false,
      "keepsHistory": true,
      "documentsKeepHistoryContractDefault": false,
      "documentsMutableContractDefault": true,
      "requiresIdentityEncryptionBoundedKey": null,
      "requiresIdentityDecryptionBoundedKey": null
    },
    "version": 1,
    "ownerId": "DKFKmJ58ZTDddvviDJwDyCznDMxd9Y6bsJcBN5Xp8m5w",
    "schemaDefs": null,
    "documentSchemas": {
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
  },
  {
    "$format_version": "0",
    "id": "BWgzcW4XRhmYKzup1xY8fMi3ZHGG1Hf8fD9Rm3e3bopm",
    "config": {
      "$format_version": "0",
      "canBeDeleted": false,
      "readonly": false,
      "keepsHistory": true,
      "documentsKeepHistoryContractDefault": false,
      "documentsMutableContractDefault": true,
      "requiresIdentityEncryptionBoundedKey": null,
      "requiresIdentityDecryptionBoundedKey": null
    },
    "version": 2,
    "ownerId": "DKFKmJ58ZTDddvviDJwDyCznDMxd9Y6bsJcBN5Xp8m5w",
    "schemaDefs": null,
    "documentSchemas": {
      "note": {
        "type": "object",
        "properties": {
          "message": {
            "type": "string"
          },
          "author": {
            "type": "string"
          }
        },
        "additionalProperties": false
      }
    }
  }
]
```

> 📘
>
> Please refer to the [data contract reference page](../../reference/data-contracts.md) for more
> comprehensive details related to contracts and documents.

## What's Happening

After we initialize the Client, we request a contract's history. The `platform.contracts.history`
method takes four arguments: a contract ID, timestamp to start at, number of revisions to retrieve,
and a number to offset the start of the records. After the contract history is retrieved, it is
displayed on the console.
