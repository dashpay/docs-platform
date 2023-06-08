# Retrieve documents

In this tutorial we will retrieve some of the current data from a data contract. Data is stored in the form of documents as described in the Dash Platform Protocol [Document explanation](explanation-platform-protocol-document).

## Prerequisites
- [General prerequisites](tutorials-introduction#prerequisites) (Node.js / Dash SDK installed)
- A Dash Platform Contract ID: [Tutorial: Register a Data Contract](tutorial-register-a-data-contract) 

# Code

```javascript
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  apps: {
    tutorialContract: {
      contractId: '3iaEhdyAVbmSjd59CT6SCrqPjfAfMdPTc8ksydgqSaWE',
    },
  },
};
const client = new Dash.Client(clientOpts);

const getDocuments = async () => {
  return client.platform.documents.get('tutorialContract.note', {
    limit: 2, // Only retrieve 2 document
  });
};

getDocuments()
  .then((d) => {
    for (const n of d) {
      console.log('Document:\n', n.toJSON());
    }
  })
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
``` 

> 👍 Initializing the Client with a contract identity
>
> The example above shows how access to contract documents via `<contract name>.<contract document>` syntax (e.g. `tutorialContract.note`) can be enabled by passing a contract identity to the constructor. Please refer to the [Dash SDK documentation](https://github.com/dashevo/platform/blob/master/packages/js-dash-sdk/docs/getting-started/multiple-apps.md) for details.

## Queries

The example code uses a very basic query to return only one result. More extensive querying capabilities are covered in the [query syntax reference](reference-query-syntax).

# Example Document

The following examples show the structure of a `note` document (from the data contract registered in the tutorial) returned from the SDK when retrieved with various methods. 

The values returned by `.toJSON()` include the base document properties (prefixed with `$`) present in all documents along with the data contract defined properties.

> 📘
>
> Note: When using `.toJSON()`, binary data is displayed as a base64 string (since JSON is a text-based format).

The values returned by `.getData()` (and also shown in the console.dir() `data` property) represent _only_ the properties defined in the `note` document described by the [tutorial data contract](tutorial-register-a-data-contract#code).

```json .toJSON()
{
  '$protocolVersion': 0,
  '$id': '6LpCQhkXYV2vqkv1UWByew4xQ6BaxxnGkhfMZsN3SV9u',
  '$type': 'note',
  '$dataContractId': '3iaEhdyAVbmSjd59CT6SCrqPjfAfMdPTc8ksydgqSaWE',
  '$ownerId': 'CEPMcuBgAWeaCXiP2gJJaStANRHW6b158UPvL1C8zw2W',
  '$revision': 1,
  message: 'Tutorial CI Test @ Fri, 23 Jul 2021 13:12:13 GMT'
}
```
```json .getData()
{
  'Tutorial CI Test @ Fri, 23 Jul 2021 13:12:13 GMT'
}
```
```text .data.message
Tutorial CI Test @ Fri, 23 Jul 2021 13:12:13 GMT
```
```json console.dir(document)
Document {
  dataContract: DataContract {
    protocolVersion: 0,
    id: Identifier(32) [Uint8Array] [
       40,  93, 196, 112,  38, 188,  51, 122,
      149,  59,  21,  39, 147, 119,  87,  53,
      236,  60,  97,  42,  31,  82, 135, 120,
       68, 188,  55, 153, 226, 198, 181, 139
    ],
    ownerId: Identifier(32) [Uint8Array] [
      166, 222,  98,  87, 193,  19,  82,  37,
       50, 118, 210,  64, 103, 122,  28, 155,
      168,  21, 198, 134, 142, 151, 153, 136,
       46,  64, 223,  74, 215, 153, 158, 167
    ],
    schema: 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',
    documents: { note: [Object] },
    '$defs': undefined,
    binaryProperties: { note: {} },
    metadata: Metadata { blockHeight: 526, coreChainLockedHeight: 542795 }
  },
  entropy: undefined,
  protocolVersion: 0,
  id: Identifier(32) [Uint8Array] [
     79,  93, 213, 226,  76,  79, 205, 191,
    165, 190,  68,  28,   8,  83,  61, 226,
    222, 248,  48, 235, 147, 110, 181, 229,
      7,  66,  65, 230, 100, 194, 192, 156
  ],
  type: 'note',
  dataContractId: Identifier(32) [Uint8Array] [
     40,  93, 196, 112,  38, 188,  51, 122,
    149,  59,  21,  39, 147, 119,  87,  53,
    236,  60,  97,  42,  31,  82, 135, 120,
     68, 188,  55, 153, 226, 198, 181, 139
  ],
  ownerId: Identifier(32) [Uint8Array] [
    166, 222,  98,  87, 193,  19,  82,  37,
     50, 118, 210,  64, 103, 122,  28, 155,
    168,  21, 198, 134, 142, 151, 153, 136,
     46,  64, 223,  74, 215, 153, 158, 167
  ],
  revision: 1,
  data: { message: 'Tutorial CI Test @ Fri, 23 Jul 2021 13:12:13 GMT' },
  metadata: Metadata { blockHeight: 526, coreChainLockedHeight: 542795 }
}
```

# What's happening

After we initialize the Client, we request some documents. The `client.platform.documents.get` method takes two arguments: a record locator and a query object. The records locator consists of an app name (e.g. `tutorialContract`) and the top-level document type requested, (e.g. `note`).

> 📘 DPNS Contract
>
> Note: Access to the DPNS contract is built into the Dash SDK. DPNS documents may be accessed via the `dpns` app name (e.g. `dpns.domain`).

If you need more than the first 100 documents, you'll have to make additional requests with `startAt` incremented by 100 each time. In the future, the Dash SDK may return documents with paging information to make this easier and reveal how many documents are returned in total.