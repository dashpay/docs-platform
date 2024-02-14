```{eval-rst}
.. tutorials-retrieve-data-contract:
```

# Retrieve a data contract

In this tutorial we will retrieve the data contract created in the [Register a Data Contract tutorial](../../tutorials/contracts-and-documents/register-a-data-contract.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

### Retrieving a data contract

```javascript
const Dash = require('dash');

const client = new Dash.Client({ network: 'testnet' });

const retrieveContract = async () => {
  const contractId = '8cvMFwa2YbEsNNoc1PXfTacy2PVq2SzVnkZLeQSzjfi6';
  return client.platform.contracts.get(contractId);
};

retrieveContract()
  .then((d) => console.dir(d.toJSON(), { depth: 5 }))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

### Updating the client app list

> 📘
>
> In many cases it may be desirable to work with a newly retrieved data contract using the `<contract name>.<contract document>` syntax (e.g. `dpns.domain`). Data contracts that were created after the client was initialized or not included in the initial client options can be added via `client.getApps().set(...)`.

```javascript
const Dash = require('dash');
const { PlatformProtocol: { Identifier } } = Dash;

const myContractId = 'a contract ID';
const client = new Dash.Client();

client.platform.contracts.get(myContractId)
  .then((myContract) => {
    client.getApps().set('myNewContract', {
      contractId: Identifier.from(myContractId),
      contract: myContract,
    });
  });
```

## Example Data Contract

The following example response shows a retrieved contract:

```json
{
  "$format_version": "0",
  "id": "8cvMFwa2YbEsNNoc1PXfTacy2PVq2SzVnkZLeQSzjfi6",
  "config": {
    "$format_version": "0",
    "canBeDeleted": false,
    "readonly": false,
    "keepsHistory": false,
    "documentsKeepHistoryContractDefault": false,
    "documentsMutableContractDefault": true,
    "requiresIdentityEncryptionBoundedKey": null,
    "requiresIdentityDecryptionBoundedKey": null
  },
  "version": 1,
  "ownerId": "AsdMKouqE5NB7CeQFi4wr5oj8vFUYTtdSvxFtAvtCbhh",
  "schemaDefs": null,
  "documentSchemas": {
    "note": {
      "type": "object",
      "properties": { "message": { "type": "string" } },
      "additionalProperties": false
    }
  }
}
```

> 📘
>
> Please refer to the [data contract reference page](../../reference/data-contracts.md) for more comprehensive details related to contracts and documents.

## What's Happening

After we initialize the Client, we request a contract. The `platform.contracts.get` method takes a single argument: a contract ID. After the contract is retrieved, it is displayed on the console.

The second code example shows how the contract could be assigned a name to make it easily accessible without initializing an additional client.
