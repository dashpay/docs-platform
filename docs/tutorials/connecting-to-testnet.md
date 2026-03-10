```{eval-rst}
.. tutorials-connect-to-network:
```

# Connect to a network

The purpose of this tutorial is to walk through the steps necessary to access the network.

## Overview

Platform services are provided via a combination of HTTP and gRPC connections to DAPI. The easiest approach is to use the [Dash Evo SDK](https://www.npmjs.com/package/@dashevo/evo-sdk), which handles connection management automatically.

## Prerequisites

- An installation of [NodeJS v20 or higher](https://nodejs.org/en/download/)

## Connect via Dash SDK

### 1. Install the Dash SDK

The JavaScript SDK package is available from npmjs.com and can be installed by running `npm install @dashevo/evo-sdk` from the command line:

```shell
npm install @dashevo/evo-sdk
```

### 2. Connect to Dash Platform

Create a file named `connect.mjs` with the following contents. Then run it by typing `node connect.mjs` from the command line:

```{code-block} javascript
:caption: connect.mjs

import { EvoSDK } from '@dashevo/evo-sdk';

try {
  const sdk = EvoSDK.testnetTrusted();
  await sdk.connect();
  const status = await sdk.system.status();
  console.log('Connected. System status:\n', status.toJSON());
} catch (e) {
  console.error('Failed to fetch system status:', e.message);
}
```

Once this returns successfully, you're ready to begin developing! See the [Quickstart](../tutorials/introduction.md#quickstart) for recommended next steps. For details on SDK methods, please refer to the [SDK documentation](https://dashpay.github.io/evo-sdk-website/docs.html).

## Connect to a Local Devnet

The SDK supports connecting to a local development network managed by [dashmate](https://github.com/dashpay/platform/tree/master/packages/dashmate). The `local` factory methods expect a dashmate-managed environment with a quorum sidecar running at `127.0.0.1:2444`.

```{code-block} javascript
:caption: localConnect.mjs

import { EvoSDK } from '@dashevo/evo-sdk';

try {
  const sdk = EvoSDK.localTrusted();
  await sdk.connect();
  const status = await sdk.system.status();
  console.log('Connected. System status:\n', status.toJSON());
} catch (e) {
  console.error('Failed to fetch system status:', e.message);
}
```

:::{note}
The WASM-based SDK currently only supports connecting to known networks (testnet, mainnet, local) via the built-in factory methods. Connecting to remote devnets with custom addresses is not yet supported.
:::

## Connect Directly to DAPI (Optional)

:::{attention}
Normally, the Dash SDK or another library should be used to interact with DAPI. Connecting directly may be helpful for debugging in some cases, but generally is not required.
:::

The example below demonstrates retrieving the hash of the best block hash directly from a DAPI node via command line and several languages:

::::{tab-set}
:::{tab-item} Curl
```shell
curl --request POST \
  --url https://seed-1.testnet.networks.dash.org:1443/ \
  --header 'content-type: application/json' \
  --data '{"method":"getBlockHash","id":1,"jsonrpc":"2.0","params":{"height": 100 }}'
```
:::

:::{tab-item} Python
```python
import requests

url = "https://seed-1.testnet.networks.dash.org:1443/"

payload = "{\"method\":\"getBlockHash\",\"id\":1,\"jsonrpc\":\"2.0\",\"params\":{\"height\":100}}"
headers = {'content-type': 'application/json'}

response = requests.request("POST", url, data=payload, headers=headers)

print(response.text)
```
:::

:::{tab-item} Ruby
```ruby
require 'uri'
require 'net/http'

url = URI("https://seed-1.testnet.networks.dash.org:1443/")

http = Net::HTTP.new(url.host, url.port)

request = Net::HTTP::Post.new(url)
request["content-type"] = 'application/json'
request.body = "{\"method\":\"getBlockHash\",\"id\":1,\"jsonrpc\":\"2.0\",\"params\":{\"height\":100}}"

response = http.request(request)
puts response.read_body
```
:::
::::
