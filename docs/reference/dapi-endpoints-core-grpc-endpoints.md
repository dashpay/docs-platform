# Core gRPC Endpoints

Please refer to the [gRPC Overview](../reference/dapi-endpoints-grpc-overview.md) for details regarding running the examples shown below, encoding/decoding the request/response data, and clients available for several languages.

## Endpoint Details

### broadcastTransaction

**Returns**: The transaction id (TXID) if successful  
**Parameters**:

| Name              | Type    | Required | Description                          |
| ----------------- | ------- | -------- | ------------------------------------ |
| `transaction`     | Bytes   | Yes      | A raw transaction                    |
| `allow_high_fees` | Boolean | No       | Enables bypassing the high fee check |
| `bypass_limits`   | Boolean | No       |                                      |

#### Example Request and Response

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');
const { Transaction } = require('@dashevo/dashcore-lib');

const client = new DAPIClient({
  seeds: [{
    host: 'seed-1.testnet.networks.dash.org',
    port: 1443,
  }],
});

// Replace the transaction hex below with your own transaction prior to running
const tx = Transaction('02000000022fd1c4583099109524b8216d712373bd837d24a502414fcadd8ae94753c3d87e010000006a47304402202cbdc560898ad389005fbe231fb345da503d838cfadab738a7d2f57bdd7ff77c02206e02b9f05c3dfb380d158949407372f26fa8ecc66956297792509c2f700723d1012103422fa857d5049000c22c3188e84557da5b783c2ef54b83a76a2933a0564c22dafeffffff07e987f3bb114c4370b937915e980657e2706135e21fbd8972a5534c804d5495000000006a473044022041a69c058035a2a8c88715c018efcb77a9ee3a08b72fd24afe8591364cee8dc002203026f115ac9c7206a985f71422ac38d451bde092d708bfb81ef35b2968f4ee34012102f0ce58f50515d04d4ff01a550a4d3246fbdc9d27031ef7d883e845b6b41f0e4efeffffff0269440f00000000001976a91465f6a3d634ba58247825c6fd55174ca72fdcdbd988ac00e1f505000000001976a9144139b147b5cef5fef5bcdb02fcdf55e426f74dbb88ac4d5b0600');

client.core.broadcastTransaction(tx.toBuffer())
  .then((response) => console.log(response));
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: {
    CorePromiseClient,
  },
} = require('@dashevo/dapi-grpc');
const { Transaction } = require('@dashevo/dashcore-lib');

const corePromiseClient = new CorePromiseClient('https://seed-1.testnet.networks.dash.org:1443');

// Replace the transaction hex below with your own transaction prior to running
const tx = Transaction('02000000022fd1c4583099109524b8216d712373bd837d24a502414fcadd8ae94753c3d87e010000006a47304402202cbdc560898ad389005fbe231fb345da503d838cfadab738a7d2f57bdd7ff77c02206e02b9f05c3dfb380d158949407372f26fa8ecc66956297792509c2f700723d1012103422fa857d5049000c22c3188e84557da5b783c2ef54b83a76a2933a0564c22dafeffffff07e987f3bb114c4370b937915e980657e2706135e21fbd8972a5534c804d5495000000006a473044022041a69c058035a2a8c88715c018efcb77a9ee3a08b72fd24afe8591364cee8dc002203026f115ac9c7206a985f71422ac38d451bde092d708bfb81ef35b2968f4ee34012102f0ce58f50515d04d4ff01a550a4d3246fbdc9d27031ef7d883e845b6b41f0e4efeffffff0269440f00000000001976a91465f6a3d634ba58247825c6fd55174ca72fdcdbd988ac00e1f505000000001976a9144139b147b5cef5fef5bcdb02fcdf55e426f74dbb88ac4d5b0600');

corePromiseClient.client.broadcastTransaction({ transaction: tx.toBuffer() })
  .then((response) => console.log(response));
```

::::

::::{tab-set-code}

```json
{
  "transactionId": "552eaf24a60014edcbbb253dbc4dd68766532cab3854b44face051cedcfd578f"
}
```

::::

### getStatus

**Returns**: Status information from the Core chain  
**Parameters**: None

#### Example Request and Response

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');

const client = new DAPIClient({
  seeds: [{
    host: 'seed-1.testnet.networks.dash.org',
    port: 1443,
  }],
});

client.core.getStatus()
  .then((response) => console.log(response));
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: {
    GetStatusRequest,
    CorePromiseClient,
  },
} = require('@dashevo/dapi-grpc');

const corePromiseClient = new CorePromiseClient('https://seed-1.testnet.networks.dash.org:1443');

corePromiseClient.client.getStatus(new GetStatusRequest())
  .then((response) => console.log(response));
```
```shell Request (gRPCurl)
# gRPCurl
# Run in the platform repository's `packages/dapi-grpc/` directory
grpcurl -proto protos/core/v0/core.proto \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Core/getStatus
```

::::

> 📘 
> 
> **Note:** The gRPCurl response `bestBlockHash`, `chainWork`, and `proTxHash` data is Base64 encoded.

::::{tab-set-code}

```json JSON
// Response (JavaScript)
{
  "version":{
    "protocol":70227,
    "software":190100,
    "agent":"/Dash Core:19.1.0(dcg-masternode-27)/"
  },
  "time":{
    "now":1684860969,
    "offset":0,
    "median":1684860246
  },
  "status":"READY",
  "syncProgress":0.9999992137956843,
  "chain":{
    "name":"test",
    "headersCount":892412,
    "blocksCount":892412,
    "bestBlockHash":"<Buffer 00 00 00 96 7b 75 05 9c ad ff 07 71 89 74 1b 0a 8f f1 77 62 1d 3e 6e 45 e9 32 02 55 19 fe df a9>",
    "difficulty":0.003254173843543036,
    "chainWork":"<Buffer 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 d6 8d 0c 89 2a 87 47>",
    "isSynced":true,
    "syncProgress":0.9999992137956843
  },
  "masternode":{
    "status":"READY",
    "proTxHash":"<Buffer 3b 27 b5 ea 14 6a d9 d1 ff 6b c7 14 7e f2 5e f7 33 01 df 98 cc 2c 77 23 67 3c 3a 0f 39 fd b0 7a>",
    "posePenalty":0,
    "isSynced":true,
    "syncProgress":1
  },
  "network":{
    "peersCount":145,
    "fee":{
      "relay":0.00001,
      "incremental":0.00001
    }
  }
}
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "version": {
    "protocol": 70227,
    "software": 190000,
    "agent": "/Dash Core:19.0.0/"
  },
  "time": {
    "now": 1684357132,
    "median": 1684356285
  },
  "status": "READY",
  "syncProgress": 0.9999996650927735,
  "chain": {
    "name": "test",
    "headersCount": 888853,
    "blocksCount": 888853,
    "bestBlockHash": "AAAAtZ1kS2uIxOX4u1CaHqEPQhOVs23wPK9TjBZnZAI=",
    "difficulty": 0.003153826459898978,
    "chainWork": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAtaNAXYoQDE=",
    "isSynced": true,
    "syncProgress": 0.9999996650927735
  },
  "masternode": {
    "status": "READY",
    "proTxHash": "vcAa/9GeHoyawgatmvVCbavRGA3uUtnDigwp7EqRyn0=",
    "isSynced": true,
    "syncProgress": 1
  },
  "network": {
    "peersCount": 147,
    "fee": {
      "relay": 1e-05,
      "incremental": 1e-05
    }
  }
}
```

::::

### getBlock

**Returns**: A raw block  
**Parameters**:

| Name                      | Type    | Required | Description                                         |
| ------------------------- | ------- | -------- | --------------------------------------------------- |
| **One of the following:** |         |          |                                                     |
| `hash`                    | Bytes   | No       | Return the block matching the block hash provided   |
| `height`                  | Integer | No       | Return the block matching the block height provided |

#### Example Request and Response

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');

const client = new DAPIClient({
  seeds: [{
    host: 'seed-1.testnet.networks.dash.org',
    port: 1443,
  }],
});

client.core.getBlockByHeight(1)
  .then((response) => console.log(response.toString('hex')));
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: {
    CorePromiseClient,
  },
} = require('@dashevo/dapi-grpc');

const corePromiseClient = new CorePromiseClient('https://seed-1.testnet.networks.dash.org:1443');

corePromiseClient.client.getBlock({ height: 1 })
  .then((response) => console.log(response.block.toString('hex')));
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: {
    CorePromiseClient,
  },
} = require('@dashevo/dapi-grpc');

const corePromiseClient = new CorePromiseClient('https://seed-1.testnet.networks.dash.org:1443');

corePromiseClient.client.getBlock({
  hash: '0000047d24635e347be3aaaeb66c26be94901a2f962feccd4f95090191f208c1',
}).then((response) => {
  console.log(response.block.toString('hex'));
});
```
```shell Request (gRPCurl)
# gRPCurl
grpcurl -proto protos/core/v0/core.proto \
  -d '{
    "height":1
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Core/getBlock
```

::::

> 📘 Block Encoding
> 
> **Note:** The gRPCurl response block data is Base64 encoded

::::{tab-set-code}

```shell Response (JavaScript)
# Response (JavaScript)
020000002cbcf83b62913d56f605c0e581a48872839428c92e5eb76cd7ad94bcaf0b00007f11dcce14075520e8f74cc4ddf092b4e26ebd23b8d8665a1ae5bfc41b58fdb4c3a95e53ffff0f1ef37a00000101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0a510101062f503253482fffffffff0100743ba40b0000002321020131f38ae3eb0714531dbfc3f45491b4131d1211e3777177636388bb5a74c3e4ac00000000
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "block": "AgAAACy8+DtikT1W9gXA5YGkiHKDlCjJLl63bNetlLyvCwAAfxHczhQHVSDo90zE3fCStOJuvSO42GZaGuW/xBtY/bTDqV5T//8PHvN6AAABAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8KUQEBBi9QMlNIL/////8BAHQ7pAsAAAAjIQIBMfOK4+sHFFMdv8P0VJG0Ex0SEeN3cXdjY4i7WnTD5KwAAAAA"
}
```

::::

### getTransaction

**Returns**: A raw transaction  
**Parameters**:

| Name | Type   | Required | Description             |
| ---- | ------ | -------- | ----------------------- |
| `id` | String | Yes      | A transaction id (TXID) |

#### Example Request and Response

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');

const client = new DAPIClient({
  seeds: [{
    host: 'seed-1.testnet.networks.dash.org',
    port: 1443,
  }],
});

const txid = '4004d3f9f1b688f2babb1f98ea48e1472be51e29712f942fc379c6e996cdd308';
client.core.getTransaction(txid)
  .then((response) => console.dir(response, { length: 0 }));
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: {
    CorePromiseClient,
  },
} = require('@dashevo/dapi-grpc');

const corePromiseClient = new CorePromiseClient('https://seed-1.testnet.networks.dash.org:1443');

const txid = '4004d3f9f1b688f2babb1f98ea48e1472be51e29712f942fc379c6e996cdd308';

corePromiseClient.client.getTransaction({ id: txid })
  .then((response) => console.dir(response, { length: 0 }));
```
```shell Request (gRPCurl)
# gRPCurl
grpcurl -proto protos/core/v0/core.proto \
  -d '{
    "id":"4004d3f9f1b688f2babb1f98ea48e1472be51e29712f942fc379c6e996cdd308"
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Core/getTransaction
```

::::

> 📘 Transaction Encoding
> 
> **Note:** The gRPCurl response `transaction` and `blockHash` data are Base64 encoded

::::{tab-set-code}

```text Response (JavaScript)
# Response (JavaScript)
GetTransactionResponse {
  transaction: Buffer(196) [Uint8Array] [
      3,   0,   5,   0,   1,   0,   0,   0,   0,   0,   0,  0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  0,
      0, 255, 255, 255, 255,   6,   3, 194,  90,   6,   1,  9,
    255, 255, 255, 255,   2, 238, 252, 207,  49,   0,   0,  0,
      0,  25, 118, 169,  20, 126, 178,  93, 197, 175,  71, 45,
    107, 241, 154, 135, 122, 150, 240, 167,   7, 194, 198, 27,
    118, 136, 172, 101, 251, 183,  74,   0,   0,   0,   0, 25,
    118, 169,  20,  30,
    ... 96 more items
  ],
  blockHash: Buffer(32) [Uint8Array] [
      0,   0,   2,   9, 133, 199, 245,  83,
    191, 120, 191, 203, 109, 166,   9, 115,
    193, 152, 249,  11,   7, 245, 126,  31,
     55,  65,  10, 150, 205, 150, 131, 213
  ],
  height: 416450,
  confirmations: 386421,
  instantLocked: false,
  chainLocked: true
}
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "transaction": "AwAFAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8GA8JaBgEJ/////wLu/M8xAAAAABl2qRR+sl3Fr0cta/Gah3qW8KcHwsYbdoisZfu3SgAAAAAZdqkUHsXGbpeJxlWuBo01CItAczRf4LCIrAAAAABGAgDCWgYA3zSmucmdu7+CaY+6n4aGHySJHhbAxeiB3gNMGSIgYA1c6q3De0wxbi7HpAf4g4BgSUqhmkAxVflcQyddo+2zGA==",
  "blockHash": "AAACCYXH9VO/eL/LbaYJc8GY+QsH9X4fN0EKls2Wg9U=",
  "height": 416450,
  "confirmations": 472404,
  "isChainLocked": true
}
```

::::

### subscribeToBlockHeadersWithChainLocks

This endpoint helps support simplified payment verification ([SPV](https://docs.dash.org/projects/core/en/stable/docs/guide/operating-modes-simplified-payment-verification-spv.html)) via DAPI by providing access to block headers which can then be used to verify transactions and simplified masternode lists.

**Returns**: streams the requested block header information  
**Parameters**:

| Name                      | Type    | Required | Description                                                                                       |
| ------------------------- | ------- | -------- | ------------------------------------------------------------------------------------------------- |
| ----------                |         |          |                                                                                                   |
| **One of the following:** |         |          |                                                                                                   |
| `from_block_hash`         | Bytes   | No       | Return records beginning with the block hash provided                                             |
| `from_block_height`       | Integer | No       | Return records beginning with the block height provided                                           |
| ----------                |         |          |                                                                                                   |
| `count`                   | Integer | No       | Number of blocks to sync. If set to 0 syncing is continuously sends new data as well (default: 0) |

** Example Request and Response **

::::{tab-set-code}

```shell
# gRPCurl
grpcurl -proto protos/core/v0/core.proto \
  -d '{
  "from_block_height": 1,
  "count": 1
}' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Core/subscribeToBlockHeadersWithChainLocks
```

::::

> 📘 
> 
> **Note:** The gRPCurl response `chainlock` and `headers` data is Base64 encoded

::::{tab-set-code}

```json
// Response (gRPCurl)
{
  "chainLock": "FZANAAJkZxaMU6888G2zlRNCD6EemlC7+OXEiGtLZJ21AAAAo7qvfeETyNxWVog47Yiyx9j9FSUCVkUWBrn0ZAfIbeU75kiccv4ilNmj1Peavv1oD+Ti9dqJYy9K8/MuDt7rYnVfmPWIUj03QYWKzQKr/PaMkavTaa+PCOrqQYxcLX/s"
}
{
  "blockHeaders": {
    "headers": [
      "AgAAACy8+DtikT1W9gXA5YGkiHKDlCjJLl63bNetlLyvCwAAfxHczhQHVSDo90zE3fCStOJuvSO42GZaGuW/xBtY/bTDqV5T//8PHvN6AAA="
    ]
  }
}
```

::::

### subscribeToTransactionsWithProofs

**Returns**: streams the requested transaction information  
**Parameters**:

| Name                         | Type    | Required | Description                                                                                              |
| ---------------------------- | ------- | -------- | -------------------------------------------------------------------------------------------------------- |
| `bloom_filter.v_data`        | Bytes   | Yes      | The filter itself is simply a bit field of arbitrary byte-aligned size. The maximum size is 36,000 bytes |
| `bloom_filter.n_hash_funcs`  | Integer | Yes      | The number of hash functions to use in this filter. The maximum value allowed in this field is 50        |
| `bloom_filter.n_tweak`       | Integer | Yes      | A random value to add to the seed value in the hash function used by the bloom filter                    |
| `bloom_filter.n_flags`       | Integer | Yes      | A set of flags that control how matched items are added to the filter                                    |
| ----------                   |         |          |                                                                                                          |
| **One of the following:**    |         |          |                                                                                                          |
| `from_block_hash`            | Bytes   | No       | Return records beginning with the block hash provided                                                    |
| `from_block_height`          | Integer | No       | Return records beginning with the block height provided                                                  |
| ----------                   |         |          |                                                                                                          |
| `count`                      | Integer | No       | Number of blocks to sync. If set to 0 syncing is continuously sends new data as well (default: 0)        |
| `send_transaction_hashes` \* | Boolean | No       |                                                                                                          |

** Example Request and Response **

::::{tab-set-code}

```shell Request (gRPCurl)
# gRPCurl
grpcurl -proto protos/core/v0/core.proto \
  -d '{
  "from_block_height": 1,
  "count": 1,
  "bloom_filter": {
    "n_hash_funcs": 11,
    "v_data": "",
    "n_tweak": 0,
    "n_flags": 0
  }
}' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Core/subscribeToTransactionsWithProofs
```

::::

> 📘 
> 
> **Note:** The gRPCurl response `transactions` and `rawMerkleBlock` data is Base64 encoded

::::{tab-set-code}

```json Response
// Response (gRPCurl)
{
  "rawTransactions": {
    "transactions": [
      "AQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8KUQEBBi9QMlNIL/////8BAHQ7pAsAAAAjIQIBMfOK4+sHFFMdv8P0VJG0Ex0SEeN3cXdjY4i7WnTD5KwAAAAA"
    ]
  }
}
{
  "rawMerkleBlock": "AgAAACy8+DtikT1W9gXA5YGkiHKDlCjJLl63bNetlLyvCwAAfxHczhQHVSDo90zE3fCStOJuvSO42GZaGuW/xBtY/bTDqV5T//8PHvN6AAABAAAAAX8R3M4UB1Ug6PdMxN3wkrTibr0juNhmWhrlv8QbWP20AQE="
}
```

::::

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<div></div>\n<!--\n\ngrpcurl -proto protos/transactions_filter_stream.proto -plaintext   -d '{\n  \"from_block_height\": 30000,\n  \"count\": 1,\n  \"bloom_filter\": {\n    \"n_hash_funcs\": 11,\n    \"v_data\": \"\",\n    \"n_tweak\": 0,\n    \"n_flags\": 0\n  }\n}'   localhost:2510   org.dash.platform.dapi.v0.TransactionsFilterStream/subscribeToTransactionsWithProofs\n{\n  \"rawTransactions\": {\n    \"transactions\": [\n      \"AwAFAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8FAjB1AQj/////AkAjDkMAAAAAGXapFBa5OjuRaKIGBcw82mL2E1o7qlMaiKxAIw5DAAAAABl2qRQWuTo7kWiiBgXMPNpi9hNaO6pTGoisAAAAAEYCADB1AAAPwA0VGVVRQSZSW013DrT+TU+AhULKbLNg+/rtgnzE5lca9JYY2DC/1hyqelAuIkJqqcby0zIroYyfLzuhjNso\"\n    ]\n  }\n}\n{\n  \"rawMerkleBlock\": \"AAAAIIGiClhX7zPY2s2DmwiDdlbUJSUpzBjclOIWcgggAwAAak7QtEqCigCc1+U3+R6ElSI/vQz4mXzn1bADpwg41MvxNjxeBaADHhuWAAACAAAAAi6VQ1ZA+oFPPtKYv7OuzUfdLqZ+ZwzAwpztIn0osooZAzrYFIkcfvpIDK6Mg9FgxH4eOkjvyMwXj6qwEqZCJPYBAw==\"\n}\n{\n  \"rawTransactions\": {\n    \"transactions\": [\n      \"AwAFAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8FAjF1AQH/////AkAjDkMAAAAAGXapFBa5OjuRaKIGBcw82mL2E1o7qlMaiKxAIw5DAAAAABl2qRQWuTo7kWiiBgXMPNpi9hNaO6pTGoisAAAAAEYCADF1AAAPwA0VGVVRQSZSW013DrT+TU+AhULKbLNg+/rtgnzE5lca9JYY2DC/1hyqelAuIkJqqcby0zIroYyfLzuhjNso\"\n    ]\n  }\n}\n{\n  \"rawMerkleBlock\": \"AAAAIKnRSfNm6oA5kqly1SG3FJ0a/v3hAh9GrFtyApQ+AQAAx/bTc5j8Ctlx0exLl3Xn+GvymqZBllMPdX5f5TuPsFjkNzxepXsDHoBCAAABAAAAAcf203OY/ArZcdHsS5d15/hr8pqmQZZTD3V+X+U7j7BYAQE=\"\n}\n{\n  \"rawTransactions\": {\n    \"transactions\": [\n      \"AwAFAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8FAjJ1AQT/////AkAjDkMAAAAAGXapFBa5OjuRaKIGBcw82mL2E1o7qlMaiKxAIw5DAAAAABl2qRQWuTo7kWiiBgXMPNpi9hNaO6pTGoisAAAAAEYCADJ1AAAPwA0VGVVRQSZSW013DrT+TU+AhULKbLNg+/rtgnzE5lca9JYY2DC/1hyqelAuIkJqqcby0zIroYyfLzuhjNso\"\n    ]\n  }\n}\n\n\n-->\n\n<style></style>"
  }
  [/block]
```

## Deprecated Endpoints

There are no recently deprecated endpoints, but the previous version of documentation can be [viewed here](https://dashplatform.readme.io/v0.23.0/docs/reference-dapi-endpoints-core-grpc-endpoints).

## Code Reference

Implementation details related to the information on this page can be found in:

- The [Platform repository](https://github.com/dashevo/platform/tree/master/packages/dapi) `packages/dapi/lib/grpcServer/handlers/core` folder
- The [Platform repository](https://github.com/dashevo/platform/tree/master/packages/dapi-grpc) `packages/dapi-grpc/protos` folder