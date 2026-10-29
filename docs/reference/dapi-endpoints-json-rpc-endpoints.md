```{eval-rst}
.. _reference-dapi-endpoints-core-jsonrpc:
```

# JSON-RPC Endpoints

## Overview

The endpoints described on this page provide access to information from the Core chain (layer 1).

### Required Parameters

All valid JSON-RPC requests require the inclusion the parameters listed in the following table.

| Name      | Type    | Description                                                                           |
| --------- | ------- | ------------------------------------------------------------------------------------- |
| `method`  | String  | Name of the endpoint                                                                  |
| `id`      | Integer | Request id (returned in the response to differentiate results from the same endpoint) |
| `jsonrpc` | String  | JSON-RPC version ("2.0")                                                              |
| `params`  | Object, array, or string | Endpoint arguments. Optional for endpoints that take none. |

The shape `params` accepts varies by endpoint: [`getBlockHash`](#getblockhash) takes an object, while [`sendRawTransaction`](#sendrawtransaction) takes an array or a bare hex string. See each endpoint's parameters below.

Additional information may be found in the [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification#request_object).

## Endpoint Details

### getBestBlockHash

**Returns**: the block hash of the chaintip  
**Parameters**: none

#### Example Request and Response

::::{tab-set}
:::{tab-item} Curl
:sync: curl
```shell
curl -k --request POST \
  --url https://seed-1.testnet.networks.dash.org:1443/ \
  --header 'content-type: application/json' \
  --data '{
      "method":"getBestBlockHash",
      "id":1,
      "jsonrpc":"2.0",
      "params":{}
    }'
```
:::
:::{tab-item} JavaScript
:sync: javascript
```javascript
var request = require("request");

var options = {
  method: 'POST',
  url: 'https://seed-1.testnet.networks.dash.org:1443',
  headers: {'content-type': 'application/json'},
  body: '{"method":"getBestBlockHash","id":1,"jsonrpc":"2.0"}'
};

request(options, function (error, response, body) {
  if (error) throw new Error(error);

  console.log(body);
});
```
:::
:::{tab-item} NodeJS
```javascript
var XMLHttpRequest = require('xhr2');
var data = '{"method":"getBestBlockHash","id":1,"jsonrpc":"2.0"}';

var xhr = new XMLHttpRequest();

xhr.addEventListener("readystatechange", function () {
  if (this.readyState === this.DONE) {
    console.log(this.responseText);
  }
});

xhr.open("POST", "https://seed-1.testnet.networks.dash.org:1443");
xhr.setRequestHeader("content-type", "application/json");

xhr.send(data);
```
:::
:::{tab-item} Python
:sync: python
```python
import requests
import json

url = "https://seed-1.testnet.networks.dash.org:1443/"
headers = {'content-type': 'application/json'}

payload_json = {
    "method": "getBestBlockHash",
    "id": 1,
    "jsonrpc": "2.0",
    "params": {}
}

response = requests.request("POST", url, data=json.dumps(payload_json), headers=headers)

print(response.text)
```
:::
:::{tab-item} Ruby
:sync: ruby
```ruby
require 'uri'
require 'net/http'

url = URI("https://seed-1.testnet.networks.dash.org:1443/")
http = Net::HTTP.new(url.host, url.port)

request = Net::HTTP::Post.new(url)
request["content-type"] = 'application/json'

request.body = '{
    "method":"getBestBlockHash",
    "id":1,
    "jsonrpc":"2.0",
    "params":{ }
}'

response = http.request(request)
puts response.read_body
```
:::
::::

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0000009fd106a7aa7142925fcd311442790145a3351fa2508d9da2b3462086fd"
}
```

### getBlockHash

**Returns**:  the block hash for the given height  
**Parameters**:

| Name     | Type    | Required | Description  |
| -------- | ------- | -------- | ------------ |
| `height` | Integer | Yes      | Block height |

#### Example Request and Response

::::{tab-set}
:::{tab-item} Curl
:sync: curl
```shell
curl -k --request POST \
  --url https://seed-1.testnet.networks.dash.org:1443/ \
  --header 'content-type: application/json' \
  --data '{
      "method":"getBlockHash",
      "id":1,
      "jsonrpc":"2.0",
      "params": {
        "height": 1
       }
    }'
```
:::
:::{tab-item} Python
:sync: python
```python
import requests
import json

url = "https://seed-1.testnet.networks.dash.org:1443/"
headers = {'content-type': 'application/json'}

payload_json = {
    "method": "getBlockHash",
    "id": 1,
    "jsonrpc": "2.0",
    "params": {
        "height": 100
    }
}

response = requests.request("POST", url, data=json.dumps(payload_json), headers=headers)

print(response.text)
```
:::
:::{tab-item} Ruby
:sync: ruby
```ruby
require 'uri'
require 'net/http'

url = URI("https://seed-1.testnet.networks.dash.org:1443/")
http = Net::HTTP.new(url.host, url.port)

request = Net::HTTP::Post.new(url)
request["content-type"] = 'application/json'

request.body = '{
    "method":"getBlockHash",
    "id":1,
    "jsonrpc":"2.0",
    "params":{
        "height":100
    }
}'

response = http.request(request)
puts response.read_body
```
:::
::::

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0000047d24635e347be3aaaeb66c26be94901a2f962feccd4f95090191f208c1"
}
```

### getStatus

**Returns**: Platform status information. This is the JSON-RPC equivalent of the Platform
[`getStatus`](../reference/dapi-endpoints-platform-endpoints.md#getstatus) gRPC endpoint, and returns
the same response object.

**Parameters**: none

#### Example Request and Response

::::{tab-set}
:::{tab-item} Curl
:sync: curl
```shell
curl -k --request POST \
  --url https://seed-1.testnet.networks.dash.org:1443/ \
  --header 'content-type: application/json' \
  --data '{
      "method":"getStatus",
      "id":1,
      "jsonrpc":"2.0",
      "params":{}
    }'
```
:::
::::

### sendRawTransaction

:::{versionchanged} 5.0.0
DAPI decodes Dash Core v24 transactions, so version 3 provider transactions (ProRegTx and ProUpServTx), previously refused, are now accepted.
:::

**Returns**: the transaction id (TXID) of the submitted transaction

**Parameters**:

This method takes **positional** parameters. `params` must be either an array of the values below or a bare hex string carrying the raw transaction. An object such as `{"transaction": "..."}` is rejected with `-32602`.

Positional parameters have no names on the wire; the names below are for reference only.

| Position | Name | Type | Required | Description |
|-|-|-|-|-|
| 0 | `transaction` | String | Yes | The raw transaction, hex-encoded |
| 1 | `allowHighFees` | Boolean | No | Set to `true` to bypass the high-fee rejection check (default: `false`). Parsed but not forwarded to Core. |
| 2 | `bypassLimits` | Boolean | No | Set to `true` to bypass mempool rate limits (default: `false`). Parsed but not forwarded to Core. |

The transaction is validated before broadcast: it must be non-empty, must not exceed the standard transaction weight limit as a raw byte count on the wire, and must not exceed that same weight limit once parsed. All three are reported as `-32602` over JSON-RPC; the [gRPC equivalent](../reference/dapi-endpoints-core-grpc-endpoints.md#broadcasttransaction) returns `RESOURCE_EXHAUSTED` for the wire-size check and `INVALID_ARGUMENT` for the other two.

#### Example Request and Response

::::{tab-set}
:::{tab-item} Curl
:sync: curl
```shell
curl -k --request POST \
  --url https://seed-1.testnet.networks.dash.org:1443/ \
  --header 'content-type: application/json' \
  --data '{
      "method":"sendRawTransaction",
      "id":1,
      "jsonrpc":"2.0",
      "params": ["03000000019a2b1b2b...", false, false]
    }'
```
:::
::::

## Deprecated Endpoints

There are no recently deprecated endpoints. For older endpoints, see the [previous version of this documentation](https://docs.dash.org/projects/platform/en/4.1.0/docs/reference/dapi-endpoints-json-rpc-endpoints.html).

## Code Reference

Implementation details related to the information on this page can be found in:

- The [rs-dapi package](https://github.com/dashpay/platform/tree/master/packages/rs-dapi) `src/protocol/jsonrpc_translator` module
