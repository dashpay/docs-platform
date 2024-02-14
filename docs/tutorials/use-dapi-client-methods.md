```{eval-rst}
.. tutorials-dapi-client-methods:
```

# Use DAPI client methods

In addition to the SDK methods for interacting with identities, names, contracts, and documents, the SDK also provides direct access to DAPI client methods.

## Prerequisites

- [General prerequisites](../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)

# Code

The following example demonstrates several of the Core DAPI client methods. DAPI client also has several Platform methods accessible via `getDAPIClient().platform.*`. The methods can be found here in the [js-dapi-client repository](https://github.com/dashevo/platform/tree/master/packages/js-dapi-client/lib/methods).

```javascript
const Dash = require('dash');

const client = new Dash.Client({ network: 'testnet' });

async function dapiClientMethods() {
  console.log(await client.getDAPIClient().core.getBlockHash(1));
  console.log(await client.getDAPIClient().core.getBestBlockHash());
  console.log(await client.getDAPIClient().core.getBlockByHeight(1));

  return client.getDAPIClient().core.getStatus();
}

dapiClientMethods()
  .then((d) => console.log('Core status:\n', d))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

> 📘
>
> Examples using DAPI client to access many of the DAPI endpoints can be found in the [DAPI Endpoint Reference section](../reference/dapi-endpoints.md).
