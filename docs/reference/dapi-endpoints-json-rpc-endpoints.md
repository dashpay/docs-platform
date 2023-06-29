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

Additional information may be found in the [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification#request_object).

## Endpoint Details

### getBestBlockHash

**Returns**: the block hash of the chaintip  
**Parameters**: none

#### Example Request and Response

```curl Curl
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
```javascript JavaScript
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
```javascript Node
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
```python Python
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
```ruby Ruby
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

```shell Curl
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
```python Python
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
```ruby Ruby
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

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0000047d24635e347be3aaaeb66c26be94901a2f962feccd4f95090191f208c1"
}
```

### getMnListDiff

**Returns**: a masternode list diff for the provided block hashes  
**Parameters**:

| Name            | Type   | Required | Description                       |
| --------------- | ------ | -------- | --------------------------------- |
| `baseBlockHash` | String | Yes      | Block hash for the starting block |
| `blockHash`     | String | Yes      | Block hash for the ending block   |

#### Example Request and Response

```shell Curl
curl -k --request POST \
  --url https://seed-1.testnet.networks.dash.org:1443/ \
  --header 'content-type: application/json' \
  --data '{
      "method":"getMnListDiff",
      "id":1,
      "jsonrpc":"2.0",
      "params": {
        "baseBlockHash": "00000016b4d13db8395b31d87c76ca88824b26e03e54480d8c9ddf6f11857a7c",
        "blockHash": "0000002266d8e7836eb116fe467597d13d9862c6612e31bbd6161c35b6485493"
      }
    }'
```
```python Python
import requests
import json

url = "https://seed-1.testnet.networks.dash.org:1443/"
headers = {'content-type': 'application/json'}

payload_json = {
    "method":"getMnListDiff",
    "id":1,
    "jsonrpc":"2.0",
    "params": {
        "baseBlockHash": "00000016b4d13db8395b31d87c76ca88824b26e03e54480d8c9ddf6f11857a7c",
        "blockHash": "0000002266d8e7836eb116fe467597d13d9862c6612e31bbd6161c35b6485493"
    }
}  

response = requests.request("POST", url, data=json.dumps(payload_json), headers=headers)

print(response.text)
```
```ruby Ruby
require 'uri'
require 'net/http'

url = URI("https://seed-1.testnet.networks.dash.org:1443/")
http = Net::HTTP.new(url.host, url.port)

request = Net::HTTP::Post.new(url)
request["content-type"] = 'application/json'

request.body = '{
    "method":"getMnListDiff",
    "id":1,
    "jsonrpc":"2.0",
    "params": {
        "baseBlockHash": "00000016b4d13db8395b31d87c76ca88824b26e03e54480d8c9ddf6f11857a7c",
        "blockHash": "0000002266d8e7836eb116fe467597d13d9862c6612e31bbd6161c35b6485493"
    }
}'

response = http.request(request)
puts response.read_body
```

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "baseBlockHash": "00000016b4d13db8395b31d87c76ca88824b26e03e54480d8c9ddf6f11857a7c",
    "blockHash": "0000002266d8e7836eb116fe467597d13d9862c6612e31bbd6161c35b6485493",
    "cbTxMerkleTree": "0300000003795f4c55c12757f3783a81a804585545d1844660f0b59e25a93d332bdf98a1032552fe1c2eada657f6714b14e1746a8f09b3a526e88243831133a7e25c9afcde8800af04201e85dc0cffb817c5fe7b4972ccf2647503d3d45f41304b664e8cba0107",
    "cbTx": "03000500010000000000000000000000000000000000000000000000000000000000000000ffffffff1202e21b0e2f5032506f6f6c2d74444153482fffffffff04cb525b96010000001976a9144f79c383bc5d3e9d4d81b98f87337cedfa78953688ac26c4609a010000001976a914243f5bceb1ae0a580f5a9415f9a015ad38477e7188ac6e710504000000001976a914badadfdebaa6d015a0299f23fbc1fcbdd72ba96f88ac00000000000000002a6a289c7178341d0097998baa6098724d78fd01b46455890203d99413e86a55ebb610000000000700000000000000260100e21b0000f02004439b25d27e07bb9afbd07db7dfc71aa91338391cef46e08488fe66bfe9",
    "deletedMNs": [],
    "mnList": [
      {
        "proRegTxHash": "682b3e58e283081c51f2e8e7a7de5c7312a2e8074affaf389fafcc39c4805404",
        "confirmedHash": "00000018c824355520c6a850076c041b533d05cbe481f8187e541d7e2f856def",
        "service": "64.193.62.206:19999",
        "pubKeyOperator": "85f2269374676476f00068b7cb168d124b7b780a92e8564e18edf45d77497abd9debf186ee98001a0c9a6dfccbab7a0a",
        "votingAddress": "yid7uAsVJzvSLrEekHuGNuY3KWCqJopyJ8",
        "isValid": true,
        "nVersion": 2,
        "nType": 0
      },
      {
        "proRegTxHash": "c48a44a9493eae641bea36992bc8c27eaaa33adb1884960f55cd259608d26d2f",
        "confirmedHash": "000000237725f8fe7d78153ae9c11193ee0cda18f8b48141acff8e1ac713da5b",
        "service": "173.61.30.231:19013",
        "pubKeyOperator": "8700add55a28ef22ec042a2f28e25fb4ef04b3024a7c56ad7eed4aebc736f312d18f355370dfb6a5fec9258f464b227e",
        "votingAddress": "yTMDce5yEpiPqmgPrPmTj7yAmQPJERUSVy",
        "isValid": true,
        "nVersion": 2,
        "nType": 0
      },
      {
        "proRegTxHash": "9f4f9f83ecbcd5739d7f1479ee14b508f2414d044a717acba0960566c4e6091d",
        "confirmedHash": "0000000000000000000000000000000000000000000000000000000000000000",
        "service": "45.32.211.155:19999",
        "pubKeyOperator": "88e37b3fcba972fe0c2c0ea15f8285c8bfb262ad4d8a6741a530154f1abc4edd367a22abd0cb1934647f033913cca58a",
        "votingAddress": "ybAZoZ6iybhEwoCfb6utGfU753R1wcQSZT",
        "isValid": true,
        "nVersion": 2,
        "nType": 0
      }
    ],
    "nVersion": 2,
    "deletedQuorums": [],
    "newQuorums": [],
    "merkleRootMNList": "e9bf66fe8884e046ef1c393813a91ac7dfb77dd0fb9abb077ed2259b430420f0"
  }
}

```

## Deprecated Endpoints

There are no recently deprecated endpoint, but the previous version of documentation can be [viewed here](https://dashplatform.readme.io/v0.23.0/docs/reference-dapi-endpoints-json-rpc-endpoints).

## Code Reference

Implementation details related to the information on this page can be found in:

- The [DAPI repository](https://github.com/dashevo/platform/tree/master/packages/dapi) `lib/rpcServer/commands` folder