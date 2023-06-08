The quickest way to get started with Dash Platform is by completing these two simple steps:

1. Install the Dash SDK to interact with the Dash Platform decentralized API (DAPI)
2. Verify a successful API response to a DAPI test request

# 1. Install the Dash SDK

The quickest way to start developing on Dash Platform is to use the Dash SDK. Currently, the SDK is available in Javascript, Objective-C, and Java. After navigating to your project directory, you can install the Javascript SDK by issuing the following command in your terminal or command line:

```shell
npm install dash
```

Require the Dash SDK by adding the following code to your project’s index:

** add code to project index **

See the library source on [GitHub](https://github.com/dashevo/platform/tree/master/packages/js-dash-sdk).

# 2. Verify a successful API response

To confirm proper installation, use `dash` to send a request to DAPI and check for a valid response. The example shown here requests the current height of the Dash blockchain:

```javascript
const DAPIClient = require('@dashevo/dapi-client');

var client = new DAPIClient();

var blockHeight = client.getBestBlockHeight();
blockHeight.then(height => {
  console.log(`Best block height: ${height}`);
});
```

A live example of this code can be run [here on Repl.it](https://repl.it/@thephez/DAPI-Client-Basic-Example)

> 🚧 DAPI-Client Seed node(s)
>
> If using DAPI-Client in a devnet or testnet setting, at least one seed node must be provided in the constructor. For example,
> ```js
> var client = new DAPIClient({
>   seeds: [{
>     service: 'example.com:20001',
>     port: 3000
>   }],
> });
> ```

Once you have verified dapi-client requests are working, you can move on to exploring the available endpoints.