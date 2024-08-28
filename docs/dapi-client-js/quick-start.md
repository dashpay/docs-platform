:::{attention}
This documentation is based on the [docs directory in the repository](https://github.com/dashpay/platform/tree/master/packages/js-dapi-client/docs) and may not always reflect recent code changes. For the most up-to-date information, please refer to the latest version of the code.
:::

# Quick start

## ES5/ES6 via NPM

In order to use this library in Node, you will need to add it to your project as a dependency.

Having [NodeJS](https://nodejs.org/) installed, just type in your terminal :

```sh
npm install @dashevo/dapi-client
```

## CDN Standalone

For browser usage, you can also directly rely on unpkg :

```
<script src="https://unpkg.com/@dashevo/dapi-client"></script>
```

You can see an [example usage here](https://github.com/dashpay/platform/blob/master/packages/js-dapi-client/examples/web/web.usage.html) .

## Initialization

```js
const DAPIClient = require('@dashevo/dapi-client');
const client = new DAPIClient();

(async () => {
  const bestBlockHash = await client.core.getBestBlockHash();
  console.log(bestBlockHash);
})();
```

## Quicknotes

This package allows you to fetch & send information from both the payment chain (layer 1) and the application chain (layer 2, a.k.a Platform chain).