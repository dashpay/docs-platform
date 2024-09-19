```{eval-rst}
.. _reference-dapi-endpoints-platform-grpc:
```

# Platform gRPC Endpoints

Please refer to the [gRPC Overview](../reference/dapi-endpoints-grpc-overview.md) for details regarding running the examples shown below.

## Data Proofs and Metadata

Platform gRPC endpoints can provide [proofs](https://github.com/dashpay/platform/blob/master/packages/dapi-grpc/protos/platform/v0/platform.proto#L17-L22) so the data returned for a request can be verified as being valid. When requesting proofs, the data requested will be encoded as part of the proof in the response. Full support is not yet available in the JavaScript client, but can be used via the low level [dapi-grpc library](https://github.com/dashpay/platform/tree/master/packages/dapi-grpc).

Some [additional metadata](https://github.com/dashpay/platform/blob/master/packages/dapi-grpc/protos/platform/v0/platform.proto#L48-L55) is also provided with responses:

| Metadata field          | Description                                           |
| :---------------------- | :---------------------------------------------------- |
| `height`                | Last committed platform chain height                  |
| `coreChainLockedHeight` | Height of the most recent ChainLock on the core chain |
| `epoch`                 | The current Platform epoch                            |
| `timeMs`                | Unix timestamp in milliseconds for the response       |
| `protocolVersion`       | Platform protocol version                             |
| `chainId`               | Name of the network                                   |

## Versioning

Dash Platform 0.25.16 included a [breaking change that added versioning](https://github.com/dashpay/platform/pull/1522) to these endpoints so future updates can be done without creating significant issues for API consumers.

```{eval-rst}
.. _mn-identity-id:
```

## Masternode identity IDs

[Masternode identities](../explanations/identity.md#masternode-identities) are created automatically
by the system based on the [Core masternode registration transaction (protx)
hash](inv:core:std#ref-txs-proregtx). Masternode identity IDs are created by converting the protx
hash to base58. This can be done using an [online base58
encoder](https://appdevtools.com/base58-encoder-decoder) or through JavaScript using the [bs58
package](https://www.npmjs.com/package/bs58) as shown below. For gRPCurl, convert the protx hash to
base64 instead. This can be done using an [online hex to base64
encoder](https://base64.guru/converter/encode/hex).

```{eval-rst}
.. _reference-dapi-endpoints-platform-grpc-protx-to-id:
```

:::{code-block} javascript
:caption: Protx hash to identity ID

const bs58 = require('bs58').default;

const protx = '8eca4bcbb3a124ab283afd42dad3bdb2077b3809659788a0f1daffce5b9f001f';
const base58Protx = bs58.encode(Buffer.from(protx, 'hex'));
console.log(`Masternode identity id (base58): ${base58Protx}`);
const base64Protx = Buffer.from(protx, 'hex').toString('base64');
console.log(`Masternode identity id (base58): ${base64Protx}`);
// Output:
//  Masternode identity id (base58): AcPogCxrxeas7jrWYG7TnLHKbsA5KLHGfvg6oYgANZ8J
//  Masternode identity id (base64): jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=
:::

## Endpoint Details

### broadcastStateTransition

Broadcasts a [state transition](../explanations/platform-protocol-state-transition.md) to the platform via DAPI to make a change to layer 2 data. The `broadcastStateTransition` call returns once the state transition has been accepted into the mempool.

**Returns**: Nothing or error

:::{note}
The [`waitForStateTransitionResult` endpoint](#waitforstatetransitionresult) should be used after `broadcastStateTransition` if proof of block confirmation is required.
:::

**Parameters**:

| Name               | Type           | Required | Description                                                          |
| ------------------ | -------------- | -------- | -------------------------------------------------------------------- |
| `state_transition` | Bytes (Base64) | Yes      | A [state transition](../explanations/platform-protocol-state-transition.md) |

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\nJavaScript (dapi-client) example (old)\nconst DAPIClient = require('@dashevo/dapi-client');\nconst DashPlatformProtocol = require('@dashevo/dpp');\n\nconst client = new DAPIClient();\nconst dpp = new DashPlatformProtocol();\n\n// Data Contract Create State Transition (JSON)\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    client.platform.broadcastStateTransition(stateTransition.toBuffer())\n      .then(() => console.log('State Transition broadcast successfully'));\n  });\n-->\n\n<!--\nJavaScript (dapi-grpc) example (old)\nconst {\n  v0: {\n    PlatformPromiseClient,\n    BroadcastStateTransitionRequest,\n  },\n} = require('@dashevo/dapi-grpc');\nconst DashPlatformProtocol = require('@dashevo/dpp');\n\nconst platformPromiseClient = new PlatformPromiseClient(\n  'https://seed-1.testnet.networks.dash.org:1443',\n);\n\nconst dpp = new DashPlatformProtocol();\n\n// Data Contract Create State Transition (JSON)\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\nconst broadcastStateTransitionRequest = new BroadcastStateTransitionRequest();\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    console.log(stateTransition);\n    broadcastStateTransitionRequest.setStateTransition(stateTransition.toBuffer());\n\n    platformPromiseClient.broadcastStateTransition(broadcastStateTransitionRequest)\n      .then(() => console.log('State Transition broadcast successfully'))\n      .catch((e) => {\n        console.error(e);\n        console.error(e.metadata);\n      });\n  })\n  .catch((e) => console.error(e));\n-->\n\n<!--\ngRPCurl example (old)\n# Submit an identity create State Transition\n# `state_transition` must be represented in base64\n# Replace `state_transition` with your own state transition object before running\ngrpcurl -proto protos/platform/v0/platform.proto \\\n  -d '{\n    \"state_transition\":\"pWR0eXBlAmlzaWduYXR1cmV4WEg3TWhFWDQ0Z3JzMVIwTE9XTU5IZjAxWFNpYVFQcUlVZ1JLRXQyMkxHVERsUlUrZ1BwQUlUZk5JUmhXd3IvYTVHd0lzWm1idGdYVVFxcVhjbW9lQWtUOD1qcHVibGljS2V5c4GkYmlkAGRkYXRheCxBdzh2UmYxeFFCTlVLbzNiY2llaHlaR2NhM0hBSThkY0ZvVWJTK3hLb0lITmR0eXBlAGlpc0VuYWJsZWT1bmxvY2tlZE91dFBvaW50eDBLT1VUSHB5YnFPek9DNnhEVUhFWm9uc1lNSVpqcGppTHFZNnkxYmlWNWxRQUFBQUFvcHJvdG9jb2xWZXJzaW9uAA==\"\n\n    }' \\\n  seed-1.testnet.networks.dash.org:1443 \\\n  org.dash.platform.dapi.v0.Platform/broadcastStateTransition\n-->"
  }
  [/block]
```

**Response**: No response except on error

### getContestedResources

Retrieves the contested resources for a specific contract, document type, and index.

**Returns**: A list of contested resource values or a cryptographic proof.

**Parameters**:

| Name                   | Type     | Required | Description                                                                 |
| ---------------------- | -------- | -------- | --------------------------------------------------------------------------- |
| `contract_id`          | Bytes    | Yes      | The ID of the data contract associated with the contested resources         |
| `document_type_name`   | String   | Yes      | The name of the document type associated with the contested resources       |
| `index_name`           | String   | Yes      | The name of the index used to query the contested resources                 |
| `start_index_values`   | Array    | No       | Start values for index, for pagination                                      |
| `end_index_values`     | Array    | No       | End values for index, for pagination                                        |
| `start_at_value_info`  | Object   | No       | Start value information for pagination                                      |
| `count`                | Integer  | No       | Number of contested resources to return                                     |
| `order_ascending`      | Boolean  | No       | Sort order for results                                                      |
| `prove`                | Boolean  | No       | Set to `true` to receive a proof that contains the requested contested resources |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "document_type_name": "domain",
      "index_name": "parentNameAndLabel"
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContestedResources
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "contestedResourceValues": {
      "contestedResourceValues": [
        "EgRkYXNo"
      ]
    },
    "metadata": {
      "height": "2729",
      "coreChainLockedHeight": 1086764,
      "epoch": 756,
      "timeMs": "1724076831562",
      "protocolVersion": 1,
      "chainId": "dash-testnet-50"
    }
  }
}
```
:::
::::

### getContestedResourceIdentityVotes

Retrieves the voting record of a specific identity.

**Returns**: A list of contested resource votes or a cryptographic proof.

**Parameters**:

| Name                           | Type     | Required | Description |
| ------------------------------ | -------- | -------- | ------------|
| `identity_id`                  | Bytes    | Yes      | The ID of the identity whose votes are being requested |
| `limit`                        | Integer  | No       | Maximum number of results to return |
| `offset`                       | Integer  | No       | Offset for pagination |
| `order_ascending`              | Boolean  | No       | Sort order for results |
| `start_at_vote_poll_id_info`   | Object   | No       | Start poll ID information for pagination |
| `prove`                        | Boolean  | No       | Set to `true` to receive a proof that contains the requested identity votes |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
# `identity_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContestedResourceIdentityVotes
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "votes": {
      "finishedResults": true
    },
    "metadata": {
      "height": "7762",
      "coreChainLockedHeight": 1099677,
      "epoch": 1260,
      "timeMs": "1725889742454",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getContestedResourceVotersForIdentity

Retrieves the voters for a specific identity associated with a contested resource.

**Returns**: A list of voters or a cryptographic proof.

**Parameters**:

| Name                   | Type     | Required | Description                                                                 |
| ---------------------- | -------- | -------- | --------------------------------------------------------------------------- |
| `contract_id`          | Bytes    | Yes      | The ID of the data contract associated with the contested resource          |
| `document_type_name`   | String   | Yes      | The name of the document type associated with the contested resource        |
| `index_name`           | String   | Yes      | The name of the index used to query the contested resource                  |
| `index_values`         | Array    | Yes      | The values used to query the contested resource                             |
| `contestant_id`        | Bytes    | Yes      | The ID of the identity for which to retrieve voters                         |
| `start_at_identifier_info` | Object | No      | Start identifier information for pagination                                 |
| `count`                | Integer  | No       | Number of results to return                                                 |
| `order_ascending`      | Boolean  | No       | Sort order for results                                                      |
| `prove`                | Boolean  | No       | Set to `true` to receive a proof that contains the requested voters         |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
# `contract_id` and `contestant_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "document_type_name": "domain",
      "index_name": "parentNameAndLabel",
      "index_values": [],
      "contestant_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContestedResourceVotersForIdentity
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "contestedResourceVoters": {
      "finishedResults": true
    },
    "metadata": {
      "height": "7762",
      "coreChainLockedHeight": 1099677,
      "epoch": 1260,
      "timeMs": "1725889742454",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getContestedResourceVoteState

Retrieves the state of a vote for a specific contested resource.

**Returns**: The state of the contested resource vote, including the current contenders and the tally of votes.

**Parameters**:

| Name                                             | Type     | Required | Description                                                                                             |
| ------------------------------------------------ | -------- | -------- | ------------------------------------------------------------------------------------------------------- |
| `contract_id`                                    | Bytes    | Yes      | The ID of the data contract associated with the contested resource |
| `document_type_name`                             | String   | Yes      | The name of the document type associated with the contested resource |
| `index_name`                                     | String   | Yes      | The name of the index used to query the contested resource |
| `index_values`                                   | Array    | Yes      | The values used to query the contested resource. |
| `result_type`                                    | Enum     | Yes      | Specifies the result type to return: `DOCUMENTS`, `VOTE_TALLY`, or `DOCUMENTS_AND_VOTE_TALLY` |
| `allow_include_locked_and`<br>`_abstaining_vote_tally` | Boolean  | No       | Include votes that are locked or abstaining in the tally |
| `start_at_identifier_info`                       | Object   | No       | Start identifier information for pagination |
| `count`                                          | Integer  | No       | Number of results to return |
| `prove`                                          | Boolean  | No       | Set to `true` to receive a proof that contains the requested vote state |

```{eval-rst}
..
  Commented out info
  The following example isn't fully functional
  
  **Example Request and Response**

  ::::{tab-set}
  :::{tab-item} gRPCurl
  ```shell
  grpcurl -proto protos/platform/v0/platform.proto \
    -d '{
      "v0": {
        "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
        "document_type_name": "domain",
        "index_name": "parentNameAndLabel",
        "index_values": ["EgRkYXNo", "value2"],
        "result_type": 1
      }
    }' \
    seed-1.testnet.networks.dash.org:1443 \
    org.dash.platform.dapi.v0.Platform/getContestedResourceVoteState
  ```
  :::
  ::::

```{eval-rst}
..
  Commented out info
  The following example isn't fully functional
  
  ::::{tab-set}
  :::{tab-item} Response (gRPCurl)
  ```json
  {
    "v0": {
      "contested_resource_contenders": {
        "contenders": [{"identifier": "id1", "vote_count": 10}, {"identifier": "id2", "vote_count": 5}]
      },
      "metadata": {
        "height": "6852",
        "coreChainLockedHeight": 927072,
        "epoch": 850,
        "timeMs": "1701983652299",
        "protocolVersion": 1,
        "chainId": "dash-testnet-37"
      }
    }
  }
  ```
  :::
  ::::

### getEvonodesProposedEpochBlocksByIds

Retrieves the number of blocks proposed by the specified evonodes in a certain epoch, based on their IDs.

**Returns**: A list of evonodes and their proposed block counts or a cryptographic proof.

**Parameters**:

| Name               | Type     | Required | Description |
| ------------------ | -------- | -------- | ----------- |
| `epoch`            | Integer  | No       | The epoch to query for. If not set, the current epoch will be used |
| `ids`              | Array    | Yes    | An array of evonode IDs for which proposed blocks are retrieved IDs<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
| `prove`            | Boolean  | No       | Set to `true` to receive a proof that contains the requested data |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "ids": [
        "jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=","dUuJ2ujbIPxM7l462wexRtfv5Qimb6Co4QlGdbnao14="
      ],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getEvonodesProposedEpochBlocksByIds
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "evonodesProposedBlockCountsInfo": {
      "evonodesProposedBlockCounts": [
        {
          "proTxHash": "dUuJ2ujbIPxM7l462wexRtfv5Qimb6Co4QlGdbnao14="
        },
        {
          "proTxHash": "jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=",
          "count": "13"
        }
      ]
    },
    "metadata": {
      "height": "13621",
      "coreChainLockedHeight": 1105397,
      "epoch": 1482,
      "timeMs": "1726691577244",
      "protocolVersion": 3,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getEvonodesProposedEpochBlocksByRange

Retrieves the number of blocks proposed by evonodes for a specified epoch.

**Returns**: A list of evonodes and their proposed block counts or a cryptographic proof.

**Parameters**:

| Name               | Type     | Required | Description |
| ------------------ | -------- | -------- | ----------- |
| `epoch`            | Integer  | No       | The epoch to query for. If not set, the current epoch will be used |
| `limit`            | Integer  | No       | Maximum number of evonodes proposed epoch blocks to return |
| `start_after`      | Bytes    | No       | Retrieve results starting after this document |
| `start_at`         | Bytes    | No       | Retrieve results starting at this document |
| `prove`            | Boolean  | No       | Set to `true` to receive a proof that contains the requested data |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "epoch": 0,
      "limit": 10,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getEvonodesProposedEpochBlocksByRange
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "evonodesProposedBlockCountsInfo": {
      "evonodesProposedBlockCounts": [
        {
          "proTxHash": "BbaHl4NE+iQzsqqZ1B9kPi2FgaeJzcIwhIic7KUkTqg=",
          "count": "1"
        }
      ]
    },
    "metadata": {
      "height": "20263",
      "coreChainLockedHeight": 1105827,
      "epoch": 1499,
      "timeMs": "1726752270072",
      "protocolVersion": 3,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentity

**Returns**: [Identity](../explanations/identity.md) information for the requested identity  
**Parameters**:

| Name    | Type    | Required | Description                                                           |
| ------- | ------- | -------- | --------------------------------------------------------------------- |
| `id`    | Bytes   | Yes      | An identity `id`<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity. The data requested will be encoded as part of the proof in the response.|

**Example Request and Response**

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol();
const client = new DAPIClient();

const identityId = Identifier.from('36LGwPSXef8q8wpdnx4EdDeVNuqCYNAE9boDu5bxytsm');
client.platform.getIdentity(identityId).then((response) => {
  const identity = dpp.identity.createFromBuffer(response.getIdentity());
  console.log(identity.toJSON());
});
```
:::

:::{tab-item} JavaScript (dapi-grpc)
:sync: js-dapi-grpc
```javascript
const {
  v0: { PlatformPromiseClient, GetIdentityRequest },
} = require('@dashevo/dapi-grpc');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const platformPromiseClient = new PlatformPromiseClient(
  'https://seed-1.testnet.networks.dash.org:1443',
);

const id = Identifier.from('36LGwPSXef8q8wpdnx4EdDeVNuqCYNAE9boDu5bxytsm');
const idBuffer = Buffer.from(id);
const getIdentityRequest = new GetIdentityRequest();
getIdentityRequest.setId(idBuffer);
getIdentityRequest.setProve(false);

platformPromiseClient
  .getIdentity(getIdentityRequest)
  .then((response) => {
    const identity = dpp.identity.createFromBuffer(response.getIdentity());
    console.dir(identity.toJSON());
  })
  .catch((e) => console.error(e));
```
:::

:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentity
```
:::
::::

::::{tab-set}
:::{tab-item} Response (JavaScript)
:sync: js-dapi-client
```json
{
  "$version":"0",
  "id":"EuzJmuZdBSJs2eTrxHEp6QqJztbp6FKDNGMeb4W2Ds7h",
  "publicKeys":[
    {
      "$version":"0",
      "id":0,
      "purpose":0,
      "securityLevel":0,
      "contractBounds":null,
      "type":0,
      "readOnly":false,
      "data":"Asi0dHtSjKxf3femzGNwLuBO19EzKQTghRA0PqANzlRq",
      "disabledAt":null
    },
    {
      "$version":"0",
      "id":1,
      "purpose":0,
      "securityLevel":2,
      "contractBounds":null,
      "type":0,
      "readOnly":false,
      "data":"AgHuKPhPVIU5BWfpOcK1hgELY6aeySyrU13JaoxxkTYC",
      "disabledAt":null
    }
  ],
  "balance":17912102140,
  "revision":0
}
```
:::

:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "identity": "AB8VEmymhcW7r01Ka36+WtMlOruBGrE3Ulr0sTsCo5scBAAAAAAAAAAAIQMSQ7bd3xPfA+9xn2+FLl/AJrQTEhdW/OUafgjhbjs6qwABAAEAAgAAACED8nl3p8oFHACE5DGvv8Y9sBxWEVPLpUDUlSD7yICx0OoAAgACAAEAAAAhA9BQqn5pbKnveG+CTGpr+sheSghjJFEUYpm//gO1HPa1AAMAAwMBAAAAIQK7PbawzDv5oNWL3icaXEeAnv5xigN0gUMXRVzn6VgPQwD8J+gRAgA=",
    "metadata": {
      "height": "5986",
      "coreChainLockedHeight": 1097381,
      "epoch": 1170,
      "timeMs": "1725566939334",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```

::::

### getIdentityBalance

**Returns**: Credit balance for the requested [Identity](../explanations/identity.md)

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `id`    | Bytes   | Yes      | An identity ID<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids)
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityBalance
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "balance": "669520130",
    "metadata": {
      "height": "5986",
      "coreChainLockedHeight": 1097381,
      "epoch": 1170,
      "timeMs": "1725566939334",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentityBalanceAndRevision

**Returns**: Credit balance and identity revision for the requested [Identity](../explanations/identity.md)

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `id`    | Bytes   | Yes      | An identity ID<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids)
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityBalanceAndRevision
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "balanceAndRevision": {
      "balance": "669520130"
    },
    "metadata": {
      "height": "5986",
      "coreChainLockedHeight": 1097381,
      "epoch": 1170,
      "timeMs": "1725566939334",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentityByPublicKeyHash

**Returns**: An [identity](../explanations/identity.md) associated with the provided public key hash

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `public_key_hash` | Bytes   | Yes | Public key hash (sha256-ripemd160) of identity public key
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "public_key_hash": "uNFZGqdNRA4K+cC+FsVbvBQYR/c="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityByPublicKeyHash
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "identity": "ADASwZuY7AAzrds2zWS39RBnDyo1GkMEtfaZQUQobv2sAgAAAAAAAAAAIQLItHR7UoysX933psxjcC7gTtfRMykE4IUQND6gDc5UagABAAEAAgAAACECAe4o+E9UhTkFZ+k5wrWGAQtjpp7JLKtTXclqjHGRNgIA/QAAAAQ8fEg8AA==",
    "metadata": {
      "height": "6870",
      "coreChainLockedHeight": 927094,
      "epoch": 851,
      "timeMs": "1701985137472",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::
::::

### getIdentityContractNonce

**Returns**: Current contract nonce for the requested [Identity](../explanations/identity.md)

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `identity_id`    | Bytes   | Yes      | An identity ID<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids)
| `contract_id`    | Bytes   | Yes      | A contract ID
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity contract nonce

**Example Request and Response**

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const client = new DAPIClient();

const identityId = Identifier.from('36LGwPSXef8q8wpdnx4EdDeVNuqCYNAE9boDu5bxytsm');
const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
client.platform.getIdentityContractNonce(identityId, contractId).then((response) => {
  console.log(`Current identity contract nonce: ${response.getIdentityContractNonce()}`);
});
```
:::

:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityContractNonce
```
:::
::::

::::{tab-set}
:::{tab-item} Response (dapi-client)
:sync: js-dapi-client
```text
Current identity contract nonce: 0
```
:::

:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "identityContractNonce": "3",
    "metadata": {
      "height": "5986",
      "coreChainLockedHeight": 1097381,
      "epoch": 1170,
      "timeMs": "1725566939334",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentityKeys

**Returns**: Keys for an [Identity](../explanations/identity.md).

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `identity_td`  | String | Yes | An identity ID<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids)
| `request_type` | [KeyRequestType](#request-types) | Yes | Request all keys (`all_keys`), specific keys (`specific_keys`), search for keys (`search_key`)
| `limit` | Integer  | Yes     | The maximum number of revisions to return |
| `offset` | Integer | Yes     | The offset of the first revision to return |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

#### Request Types

**All keys**

To request all keys for an identity, use the `all_keys` request type:

```json
"all_keys": {}
```

**Specific keys**

To request specific keys for an identity, use the `specific_keys` request type where `key_ids` is an array containing the key IDs to request:

```json
"specific_keys": {
  "key_ids": [
    1
  ]
}
```

**Search keys**

To search for identity keys, use the `search_keys` request type. The options for `security_Level_map` are "CURRENT_KEY_OF_KIND_REQUEST" and "ALL_KEYS_OF_KIND_REQUEST":

```json
"search_key": {
  "purpose_map": {
    "0": {
      "security_level_map": {
        "0": "CURRENT_KEY_OF_KIND_REQUEST"
      }
    }
  }
}
```

#### Example Request and Response

::::{tab-set}
:::{tab-item} gRPCurl (All keys)

Request all identity keys

Note: `identityId` must be represented in base64

```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
      "request_type": {
        "allKeys": {}
      }
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityKeys
```
:::
:::{tab-item} gRPCurl (Specific keys)

Request specific keys

Note: `identityId` must be represented in base64

```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
      "request_type": {
        "specificKeys": {
          "keyIds": [
            1
          ]
        }
      },
      "limit": 1
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityKeys
```
:::

:::{tab-item} gRPCurl (Search keys)

Search keys

Note: `identityId` must be represented in base64

```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
      "request_type": {
        "search_key": {
          "purpose_map": {
            "0": {
              "security_level_map": {
                "0": "CURRENT_KEY_OF_KIND_REQUEST"
              }
            }
          }
        }
      },
      "limit": 1
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityKeys
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
All keys
```json
{
  "v0": {
    "keys": {
      "keysBytes": [
        "AAAAAAAAACEDEkO23d8T3wPvcZ9vhS5fwCa0ExIXVvzlGn4I4W47OqsA",
        "AAEAAgAAACED8nl3p8oFHACE5DGvv8Y9sBxWEVPLpUDUlSD7yICx0OoA",
        "AAIAAQAAACED0FCqfmlsqe94b4JMamv6yF5KCGMkURRimb/+A7Uc9rUA",
        "AAMDAQAAACECuz22sMw7+aDVi94nGlxHgJ7+cYoDdIFDF0Vc5+lYD0MA"
      ]
    },
    "metadata": {
      "height": "5986",
      "coreChainLockedHeight": 1097381,
      "epoch": 1170,
      "timeMs": "1725566939334",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentityNonce

**Returns**: Current nonce for the requested [Identity](../explanations/identity.md)

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `identity_id`    | Bytes   | Yes      | An identity ID<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids)
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity nonce

**Example Request and Response**

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const client = new DAPIClient();

const identityId = Identifier.from('36LGwPSXef8q8wpdnx4EdDeVNuqCYNAE9boDu5bxytsm');
client.platform.getIdentityNonce(identityId).then((response) => {
  console.log(`Current identity nonce: ${response.getIdentityNonce()}`);
});
```
:::

:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityNonce
```
:::
::::

::::{tab-set}
:::{tab-item} Response (dapi-client)
:sync: js-dapi-client
```text
Current identity nonce: 0
```
:::

:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "identityNonce": "3",
    "metadata": {
      "height": "5990",
      "coreChainLockedHeight": 1097384,
      "epoch": 1170,
      "timeMs": "1725567663863",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentitiesBalances

Retrieves the balances for a list of identities.

**Returns**: A list of identities with their corresponding balances or a cryptographic proof.

**Parameters**:

| Name      | Type    | Required | Description                                              |
|-----------|---------|----------|----------------------------------------------------------|
| `ids`     | Array   | No       | An array of identity IDs for which balances are requested<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
| `prove`   | Boolean | No       | Set to `true` to receive a proof containing the requested balances |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "ids": [
        "jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=","dUuJ2ujbIPxM7l462wexRtfv5Qimb6Co4QlGdbnao14="
      ],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentitiesBalances
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "identitiesBalances": {
      "entries": [
        {
          "identity_id": "jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=",
          "balance": 1000000
        },
        {
          "identity_id": "dUuJ2ujbIPxM7l462wexRtfv5Qimb6Co4QlGdbnao14=",
          "balance": 2500000
        }
      ]
    },
    "metadata": {
      "height": "13621",
      "coreChainLockedHeight": 1105397,
      "epoch": 1482,
      "timeMs": "1726691577244",
      "protocolVersion": 3,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentitiesContractKeys

**Returns**: Keys associated to a specific contract for multiple [Identities](../explanations/identity.md).

**Parameters**:

| Name                 | Type                    | Required | Description |
|----------------------|-------------------------|----------|-------------|
| `identities_ids`     | Array                   | Yes      | An array of identity IDs<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
| `contract_id`        | String                  | Yes      | The ID of the contract |
| `document_type_name` | String                  | No       | Name of the document type |
| `purposes`           | Array of [KeyPurpose](#key-purposes) | No | Array of purposes for which keys are requested |
| `prove`              | Boolean                 | No       | Set to `true` to receive a proof that contains the requested identity keys |

#### Key Purposes

**Key Purposes** define the intent of usage for each key. Here are the available purposes:

- `AUTHENTICATION` - Keys used for authentication purposes.
- `ENCRYPTION` - Keys used for encrypting data.
- `DECRYPTION` - Keys used for decrypting data.
- `TRANSFER` - Keys used for transferring assets.
- `VOTING` - Keys used for voting mechanisms.

#### Example Request and Response

::::{tab-set}
:::{tab-item} gRPCurl
```shell
# Request identity keys associated with the specified contract
# `identities_ids` and `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identities_ids": [
        "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
        "NBgQk65dTNttDYDGLZNLrb1QEAWB91jqkqXtK1KU4Dc="
      ],
      "purposes": [],
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentitiesContractKeys
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "identitiesKeys": {},
    "metadata": {
      "height": "5990",
      "coreChainLockedHeight": 1097384,
      "epoch": 1170,
      "timeMs": "1725567663863",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getDataContract

**Returns**: [Data Contract](../explanations/platform-protocol-data-contract.md) information for the requested data contract  
**Parameters**:

| Name    | Type    | Required | Description                                                                |
| ------- | ------- | -------- | -------------------------------------------------------------------------- |
| `id`    | Bytes   | Yes      | A data contract `id`                                                       |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested data contract. The data requested will be encoded as part of the proof in the response. |

**Example Request and Response**

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const client = new DAPIClient();

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
client.platform.getDataContract(contractId).then((response) => {
  dpp.dataContract.createFromBuffer(response.getDataContract()).then((dataContract) => {
    console.dir(dataContract.toJSON(), { depth: 10 });
  });
});
```
:::

:::{tab-item} JavaScript (dapi-grpc)
:sync: js-dapi-grpc
```javascript
const {
  v0: { PlatformPromiseClient, GetDataContractRequest },
} = require('@dashevo/dapi-grpc');
const { default: loadDpp, DashPlatformProtocol, Identifier } = require('@dashevo/wasm-dpp');

const platformPromiseClient = new PlatformPromiseClient(
  'https://seed-1.testnet.networks.dash.org:1443',
);

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
const contractIdBuffer = Buffer.from(contractId);
const getDataContractRequest = new GetDataContractRequest();
getDataContractRequest.setId(contractIdBuffer);

platformPromiseClient
  .getDataContract(getDataContractRequest)
  .then((response) => {
    dpp.dataContract.createFromBuffer(response.getDataContract()).then((dataContract) => {
      console.dir(dataContract.toJSON(), { depth: 10 });
    });
  })
  .catch((e) => console.error(e));
```
:::

:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "id":"5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDataContract
```
:::
::::

::::{tab-set}
:::{tab-item} Response (JavaScript)
:sync: js-dapi-client
```json
{
  "$format_version":"0",
  "id":"GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec",
  "config":{
    "$format_version":"0",
    "canBeDeleted":false,
    "readonly":false,
    "keepsHistory":false,
    "documentsKeepHistoryContractDefault":false,
    "documentsMutableContractDefault":true,
    "requiresIdentityEncryptionBoundedKey":null,
    "requiresIdentityDecryptionBoundedKey":null
  },
  "version":1,
  "ownerId":"EuzJmuZdBSJs2eTrxHEp6QqJztbp6FKDNGMeb4W2Ds7h",
  "schemaDefs":null,
  "documentSchemas":{
    "domain":{
      "type":"object",
      "indices":[
        {
          "name":"parentNameAndLabel",
          "properties":[
            {
              "normalizedParentDomainName":"asc"
            },
            {
              "normalizedLabel":"asc"
            }
          ],
          "unique":true
        },
        {
          "name":"dashIdentityId",
          "properties":[
            {
              "records.dashUniqueIdentityId":"asc"
            }
          ],
          "unique":true
        },
        {
          "name":"dashAlias",
          "properties":[
            {
              "records.dashAliasIdentityId":"asc"
            }
          ]
        }
      ],
      "properties":{
        "label":{
          "type":"string",
          "pattern":"^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$",
          "minLength":3,
          "maxLength":63,
          "position":0,
          "description":"Domain label. e.g. 'Bob'."
        },
        "normalizedLabel":{
          "type":"string",
          "pattern":"^[a-hj-km-np-z0-9][a-hj-km-np-z0-9-]{0,61}[a-hj-km-np-z0-9]$",
          "maxLength":63,
          "position":1,
          "description":"`Domain label converted to lowercase for case-insensitive uniqueness validation. \"o\", \"i\" and \"l\" replaced with \"0\" and \"1\" to mitigate homograph attack. e.g. 'b0b'`",
          "$comment":"Must be equal to the label in lowercase. \"o\", \"i\" and \"l\" must be replaced with \"0\" and \"1\"."
        },
        "parentDomainName":{
          "type":"string",
          "pattern":"^$|^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$",
          "minLength":0,
          "maxLength":63,
          "position":2,
          "description":"A full parent domain name. e.g. 'dash'."
        },
        "normalizedParentDomainName":{
          "type":"string",
          "pattern":"^$|^[a-hj-km-np-z0-9][a-hj-km-np-z0-9-\\.]{0,61}[a-hj-km-np-z0-9]$",
          "minLength":0,
          "maxLength":63,
          "position":3,
          "description":"`A parent domain name in lowercase for case-insensitive uniqueness validation. \"o\", \"i\" and \"l\" replaced with \"0\" and \"1\" to mitigate homograph attack. e.g. 'dash'`",
          "$comment":"Must either be equal to an existing domain or empty to create a top level domain. \"o\", \"i\" and \"l\" must be replaced with \"0\" and \"1\". Only the data contract owner can create top level domains."
        },
        "preorderSalt":{
          "type":"array",
          "byteArray":true,
          "minItems":32,
          "maxItems":32,
          "position":4,
          "description":"Salt used in the preorder document"
        },
        "records":{
          "type":"object",
          "properties":{
            "dashUniqueIdentityId":{
              "type":"array",
              "byteArray":true,
              "minItems":32,
              "maxItems":32,
              "position":0,
              "contentMediaType":"application/x.dash.dpp.identifier",
              "description":"Identity ID to be used to create the primary name the Identity",
              "$comment":"Must be equal to the document owner"
            },
            "dashAliasIdentityId":{
              "type":"array",
              "byteArray":true,
              "minItems":32,
              "maxItems":32,
              "position":1,
              "contentMediaType":"application/x.dash.dpp.identifier",
              "description":"Identity ID to be used to create alias names for the Identity",
              "$comment":"Must be equal to the document owner"
            }
          },
          "minProperties":1,
          "maxProperties":1,
          "position":5,
          "additionalProperties":false,
          "$comment":"Constraint with max and min properties ensure that only one identity record is used - either a `dashUniqueIdentityId` or a `dashAliasIdentityId`"
        },
        "subdomainRules":{
          "type":"object",
          "properties":{
            "allowSubdomains":{
              "type":"boolean",
              "description":"This option defines who can create subdomains: true - anyone; false - only the domain owner",
              "$comment":"Only the domain owner is allowed to create subdomains for non top-level domains",
              "position":0
            }
          },
          "position":6,
          "description":"Subdomain rules allow domain owners to define rules for subdomains",
          "additionalProperties":false,
          "required":[
            "allowSubdomains"
          ]
        }
      },
      "required":[
        "label",
        "normalizedLabel",
        "normalizedParentDomainName",
        "preorderSalt",
        "records",
        "subdomainRules"
      ],
      "additionalProperties":false,
      "$comment":"In order to register a domain you need to create a preorder. The preorder step is needed to prevent man-in-the-middle attacks. normalizedLabel + '.' + normalizedParentDomain must not be longer than 253 chars length as defined by RFC 1035. Domain documents are immutable: modification and deletion are restricted"
    },
    "preorder":{
      "type":"object",
      "indices":[
        {
          "name":"saltedHash",
          "properties":[
            {
              "saltedDomainHash":"asc"
            }
          ],
          "unique":true
        }
      ],
      "properties":{
        "saltedDomainHash":{
          "type":"array",
          "byteArray":true,
          "minItems":32,
          "maxItems":32,
          "position":0,
          "description":"Double sha-256 of the concatenation of a 32 byte random salt and a normalized domain name"
        }
      },
      "required":[
        "saltedDomainHash"
      ],
      "additionalProperties":false,
      "$comment":"Preorder documents are immutable: modification and deletion are restricted"
    }
  }
}
```
:::

:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "dataContract": "AOZoxlmvZq7h5ywYbd57W34KHXEqCcQNVyH2Ir9TxTFVAAAAAAABAQAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIGZG9tYWluFgsSEGRvY3VtZW50c011dGFibGUTABIMY2FuQmVEZWxldGVkEwESDHRyYW5zZmVyYWJsZQIBEgl0cmFkZU1vZGUCARIEdHlwZRIGb2JqZWN0EgdpbmRpY2VzFQIWBBIEbmFtZRIScGFyZW50TmFtZUFuZExhYmVsEgpwcm9wZXJ0aWVzFQIWARIabm9ybWFsaXplZFBhcmVudERvbWFpbk5hbWUSA2FzYxYBEg9ub3JtYWxpemVkTGFiZWwSA2FzYxIGdW5pcXVlEwESCWNvbnRlc3RlZBYDEgxmaWVsZE1hdGNoZXMVARYCEgVmaWVsZBIPbm9ybWFsaXplZExhYmVsEgxyZWdleFBhdHRlcm4SE15bYS16QS1aMDEtXXszLDE5fSQSCnJlc29sdXRpb24CABILZGVzY3JpcHRpb24SqklmIHRoZSBub3JtYWxpemVkIGxhYmVsIHBhcnQgb2YgdGhpcyBpbmRleCBpcyBsZXNzIHRoYW4gMjAgY2hhcmFjdGVycyAoYWxsIGFscGhhYmV0IGEteiwgQS1aLCAwLCAxLCBhbmQgLSkgdGhlbiBhIG1hc3Rlcm5vZGUgdm90ZSBjb250ZXN0IHRha2VzIHBsYWNlIHRvIGdpdmUgb3V0IHRoZSBuYW1lFgMSBG5hbWUSCmlkZW50aXR5SWQSDm51bGxTZWFyY2hhYmxlEwASCnByb3BlcnRpZXMVARYBEhByZWNvcmRzLmlkZW50aXR5EgNhc2MSCnByb3BlcnRpZXMWBxIFbGFiZWwWBhIEdHlwZRIGc3RyaW5nEgdwYXR0ZXJuEipeW2EtekEtWjAtOV1bYS16QS1aMC05LV17MCw2MX1bYS16QS1aMC05XSQSCW1pbkxlbmd0aAIDEgltYXhMZW5ndGgCPxIIcG9zaXRpb24CABILZGVzY3JpcHRpb24SGURvbWFpbiBsYWJlbC4gZS5nLiAnQm9iJy4SD25vcm1hbGl6ZWRMYWJlbBYGEgR0eXBlEgZzdHJpbmcSB3BhdHRlcm4SPF5bYS1oai1rbS1ucC16MC05XVthLWhqLWttLW5wLXowLTktXXswLDYxfVthLWhqLWttLW5wLXowLTldJBIJbWF4TGVuZ3RoAj8SCHBvc2l0aW9uAgESC2Rlc2NyaXB0aW9uEqNEb21haW4gbGFiZWwgY29udmVydGVkIHRvIGxvd2VyY2FzZSBmb3IgY2FzZS1pbnNlbnNpdGl2ZSB1bmlxdWVuZXNzIHZhbGlkYXRpb24uICJvIiwgImkiIGFuZCAibCIgcmVwbGFjZWQgd2l0aCAiMCIgYW5kICIxIiB0byBtaXRpZ2F0ZSBob21vZ3JhcGggYXR0YWNrLiBlLmcuICdiMGInEggkY29tbWVudBJcTXVzdCBiZSBlcXVhbCB0byB0aGUgbGFiZWwgaW4gbG93ZXJjYXNlLiAibyIsICJpIiBhbmQgImwiIG11c3QgYmUgcmVwbGFjZWQgd2l0aCAiMCIgYW5kICIxIi4SEHBhcmVudERvbWFpbk5hbWUWBhIEdHlwZRIGc3RyaW5nEgdwYXR0ZXJuEi1eJHxeW2EtekEtWjAtOV1bYS16QS1aMC05LV17MCw2MX1bYS16QS1aMC05XSQSCW1pbkxlbmd0aAIAEgltYXhMZW5ndGgCPxIIcG9zaXRpb24CAhILZGVzY3JpcHRpb24SJ0EgZnVsbCBwYXJlbnQgZG9tYWluIG5hbWUuIGUuZy4gJ2Rhc2gnLhIabm9ybWFsaXplZFBhcmVudERvbWFpbk5hbWUWBxIEdHlwZRIGc3RyaW5nEgdwYXR0ZXJuEkFeJHxeW2EtaGota20tbnAtejAtOV1bYS1oai1rbS1ucC16MC05LVwuXXswLDYxfVthLWhqLWttLW5wLXowLTldJBIJbWluTGVuZ3RoAgASCW1heExlbmd0aAI/Eghwb3NpdGlvbgIDEgtkZXNjcmlwdGlvbhKiQSBwYXJlbnQgZG9tYWluIG5hbWUgaW4gbG93ZXJjYXNlIGZvciBjYXNlLWluc2Vuc2l0aXZlIHVuaXF1ZW5lc3MgdmFsaWRhdGlvbi4gIm8iLCAiaSIgYW5kICJsIiByZXBsYWNlZCB3aXRoICIwIiBhbmQgIjEiIHRvIG1pdGlnYXRlIGhvbW9ncmFwaCBhdHRhY2suIGUuZy4gJ2Rhc2gnEggkY29tbWVudBLATXVzdCBlaXRoZXIgYmUgZXF1YWwgdG8gYW4gZXhpc3RpbmcgZG9tYWluIG9yIGVtcHR5IHRvIGNyZWF0ZSBhIHRvcCBsZXZlbCBkb21haW4uICJvIiwgImkiIGFuZCAibCIgbXVzdCBiZSByZXBsYWNlZCB3aXRoICIwIiBhbmQgIjEiLiBPbmx5IHRoZSBkYXRhIGNvbnRyYWN0IG93bmVyIGNhbiBjcmVhdGUgdG9wIGxldmVsIGRvbWFpbnMuEgxwcmVvcmRlclNhbHQWBhIEdHlwZRIFYXJyYXkSCWJ5dGVBcnJheRMBEghtaW5JdGVtcwIgEghtYXhJdGVtcwIgEghwb3NpdGlvbgIEEgtkZXNjcmlwdGlvbhIiU2FsdCB1c2VkIGluIHRoZSBwcmVvcmRlciBkb2N1bWVudBIHcmVjb3JkcxYFEgR0eXBlEgZvYmplY3QSCnByb3BlcnRpZXMWARIIaWRlbnRpdHkWBxIEdHlwZRIFYXJyYXkSCWJ5dGVBcnJheRMBEghtaW5JdGVtcwIgEghtYXhJdGVtcwIgEghwb3NpdGlvbgIBEhBjb250ZW50TWVkaWFUeXBlEiFhcHBsaWNhdGlvbi94LmRhc2guZHBwLmlkZW50aWZpZXISC2Rlc2NyaXB0aW9uEjFJZGVudGlmaWVyIG5hbWUgcmVjb3JkIHRoYXQgcmVmZXJzIHRvIGFuIElkZW50aXR5Eg1taW5Qcm9wZXJ0aWVzAgESCHBvc2l0aW9uAgUSFGFkZGl0aW9uYWxQcm9wZXJ0aWVzEwASDnN1YmRvbWFpblJ1bGVzFgYSBHR5cGUSBm9iamVjdBIKcHJvcGVydGllcxYBEg9hbGxvd1N1YmRvbWFpbnMWBBIEdHlwZRIHYm9vbGVhbhILZGVzY3JpcHRpb24SW1RoaXMgb3B0aW9uIGRlZmluZXMgd2hvIGNhbiBjcmVhdGUgc3ViZG9tYWluczogdHJ1ZSAtIGFueW9uZTsgZmFsc2UgLSBvbmx5IHRoZSBkb21haW4gb3duZXISCCRjb21tZW50Ek9Pbmx5IHRoZSBkb21haW4gb3duZXIgaXMgYWxsb3dlZCB0byBjcmVhdGUgc3ViZG9tYWlucyBmb3Igbm9uIHRvcC1sZXZlbCBkb21haW5zEghwb3NpdGlvbgIAEghwb3NpdGlvbgIGEgtkZXNjcmlwdGlvbhJCU3ViZG9tYWluIHJ1bGVzIGFsbG93IGRvbWFpbiBvd25lcnMgdG8gZGVmaW5lIHJ1bGVzIGZvciBzdWJkb21haW5zEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEghyZXF1aXJlZBUBEg9hbGxvd1N1YmRvbWFpbnMSCHJlcXVpcmVkFQkSCiRjcmVhdGVkQXQSCiR1cGRhdGVkQXQSDiR0cmFuc2ZlcnJlZEF0EgVsYWJlbBIPbm9ybWFsaXplZExhYmVsEhpub3JtYWxpemVkUGFyZW50RG9tYWluTmFtZRIMcHJlb3JkZXJTYWx0EgdyZWNvcmRzEg5zdWJkb21haW5SdWxlcxIJdHJhbnNpZW50FQESDHByZW9yZGVyU2FsdBIUYWRkaXRpb25hbFByb3BlcnRpZXMTABIIJGNvbW1lbnQS+wE3SW4gb3JkZXIgdG8gcmVnaXN0ZXIgYSBkb21haW4geW91IG5lZWQgdG8gY3JlYXRlIGEgcHJlb3JkZXIuIFRoZSBwcmVvcmRlciBzdGVwIGlzIG5lZWRlZCB0byBwcmV2ZW50IG1hbi1pbi10aGUtbWlkZGxlIGF0dGFja3MuIG5vcm1hbGl6ZWRMYWJlbCArICcuJyArIG5vcm1hbGl6ZWRQYXJlbnREb21haW4gbXVzdCBub3QgYmUgbG9uZ2VyIHRoYW4gMjUzIGNoYXJzIGxlbmd0aCBhcyBkZWZpbmVkIGJ5IFJGQyAxMDM1LiBEb21haW4gZG9jdW1lbnRzIGFyZSBpbW11dGFibGU6IG1vZGlmaWNhdGlvbiBhbmQgZGVsZXRpb24gYXJlIHJlc3RyaWN0ZWQIcHJlb3JkZXIWCBIQZG9jdW1lbnRzTXV0YWJsZRMAEgxjYW5CZURlbGV0ZWQTARIEdHlwZRIGb2JqZWN0EgdpbmRpY2VzFQEWAxIEbmFtZRIKc2FsdGVkSGFzaBIKcHJvcGVydGllcxUBFgESEHNhbHRlZERvbWFpbkhhc2gSA2FzYxIGdW5pcXVlEwESCnByb3BlcnRpZXMWARIQc2FsdGVkRG9tYWluSGFzaBYGEgR0eXBlEgVhcnJheRIJYnl0ZUFycmF5EwESCG1pbkl0ZW1zAiASCG1heEl0ZW1zAiASCHBvc2l0aW9uAgASC2Rlc2NyaXB0aW9uEllEb3VibGUgc2hhLTI1NiBvZiB0aGUgY29uY2F0ZW5hdGlvbiBvZiBhIDMyIGJ5dGUgcmFuZG9tIHNhbHQgYW5kIGEgbm9ybWFsaXplZCBkb21haW4gbmFtZRIIcmVxdWlyZWQVARIQc2FsdGVkRG9tYWluSGFzaBIUYWRkaXRpb25hbFByb3BlcnRpZXMTABIIJGNvbW1lbnQSSlByZW9yZGVyIGRvY3VtZW50cyBhcmUgaW1tdXRhYmxlOiBtb2RpZmljYXRpb24gYW5kIGRlbGV0aW9uIGFyZSByZXN0cmljdGVk",
    "metadata": {
      "height": "5990",
      "coreChainLockedHeight": 1097384,
      "epoch": 1170,
      "timeMs": "1725567663863",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getDataContracts

**Returns**: [Data Contract](../explanations/platform-protocol-data-contract.md) information for the requested data contracts

**Parameters**:

| Name    | Type    | Required | Description                               |
| ------- | ------- | -------- | ----------------------------------------- |
| `ids`   | Array   | Yes      | An array of data contract IDs             |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested data contracts |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "ids": [
        "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
      ]
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDataContracts
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "dataContracts": {
      "dataContractEntries": [
        {
          "identifier": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "dataContract": "AOZoxlmvZq7h5ywYbd57W34KHXEqCcQNVyH2Ir9TxTFVAAAAAAABAAABMBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/awAAgZkb21haW4WBhIEdHlwZRIGb2JqZWN0EgdpbmRpY2VzFQMWAxIEbmFtZRIScGFyZW50TmFtZUFuZExhYmVsEgpwcm9wZXJ0aWVzFQIWARIabm9ybWFsaXplZFBhcmVudERvbWFpbk5hbWUSA2FzYxYBEg9ub3JtYWxpemVkTGFiZWwSA2FzYxIGdW5pcXVlEwEWAxIEbmFtZRIOZGFzaElkZW50aXR5SWQSCnByb3BlcnRpZXMVARYBEhxyZWNvcmRzLmRhc2hVbmlxdWVJZGVudGl0eUlkEgNhc2MSBnVuaXF1ZRMBFgISBG5hbWUSCWRhc2hBbGlhcxIKcHJvcGVydGllcxUBFgESG3JlY29yZHMuZGFzaEFsaWFzSWRlbnRpdHlJZBIDYXNjEgpwcm9wZXJ0aWVzFgcSBWxhYmVsFgYSBHR5cGUSBnN0cmluZxIHcGF0dGVybhIqXlthLXpBLVowLTldW2EtekEtWjAtOS1dezAsNjF9W2EtekEtWjAtOV0kEgltaW5MZW5ndGgCAxIJbWF4TGVuZ3RoAj8SCHBvc2l0aW9uAgASC2Rlc2NyaXB0aW9uEhlEb21haW4gbGFiZWwuIGUuZy4gJ0JvYicuEg9ub3JtYWxpemVkTGFiZWwWBhIEdHlwZRIGc3RyaW5nEgdwYXR0ZXJuEjxeW2EtaGota20tbnAtejAtOV1bYS1oai1rbS1ucC16MC05LV17MCw2MX1bYS1oai1rbS1ucC16MC05XSQSCW1heExlbmd0aAI/Eghwb3NpdGlvbgIBEgtkZXNjcmlwdGlvbhKjRG9tYWluIGxhYmVsIGNvbnZlcnRlZCB0byBsb3dlcmNhc2UgZm9yIGNhc2UtaW5zZW5zaXRpdmUgdW5pcXVlbmVzcyB2YWxpZGF0aW9uLiAibyIsICJpIiBhbmQgImwiIHJlcGxhY2VkIHdpdGggIjAiIGFuZCAiMSIgdG8gbWl0aWdhdGUgaG9tb2dyYXBoIGF0dGFjay4gZS5nLiAnYjBiJxIIJGNvbW1lbnQSXE11c3QgYmUgZXF1YWwgdG8gdGhlIGxhYmVsIGluIGxvd2VyY2FzZS4gIm8iLCAiaSIgYW5kICJsIiBtdXN0IGJlIHJlcGxhY2VkIHdpdGggIjAiIGFuZCAiMSIuEhBwYXJlbnREb21haW5OYW1lFgYSBHR5cGUSBnN0cmluZxIHcGF0dGVybhItXiR8XlthLXpBLVowLTldW2EtekEtWjAtOS1dezAsNjF9W2EtekEtWjAtOV0kEgltaW5MZW5ndGgCABIJbWF4TGVuZ3RoAj8SCHBvc2l0aW9uAgISC2Rlc2NyaXB0aW9uEidBIGZ1bGwgcGFyZW50IGRvbWFpbiBuYW1lLiBlLmcuICdkYXNoJy4SGm5vcm1hbGl6ZWRQYXJlbnREb21haW5OYW1lFgcSBHR5cGUSBnN0cmluZxIHcGF0dGVybhJBXiR8XlthLWhqLWttLW5wLXowLTldW2EtaGota20tbnAtejAtOS1cLl17MCw2MX1bYS1oai1rbS1ucC16MC05XSQSCW1pbkxlbmd0aAIAEgltYXhMZW5ndGgCPxIIcG9zaXRpb24CAxILZGVzY3JpcHRpb24SokEgcGFyZW50IGRvbWFpbiBuYW1lIGluIGxvd2VyY2FzZSBmb3IgY2FzZS1pbnNlbnNpdGl2ZSB1bmlxdWVuZXNzIHZhbGlkYXRpb24uICJvIiwgImkiIGFuZCAibCIgcmVwbGFjZWQgd2l0aCAiMCIgYW5kICIxIiB0byBtaXRpZ2F0ZSBob21vZ3JhcGggYXR0YWNrLiBlLmcuICdkYXNoJxIIJGNvbW1lbnQSwE11c3QgZWl0aGVyIGJlIGVxdWFsIHRvIGFuIGV4aXN0aW5nIGRvbWFpbiBvciBlbXB0eSB0byBjcmVhdGUgYSB0b3AgbGV2ZWwgZG9tYWluLiAibyIsICJpIiBhbmQgImwiIG11c3QgYmUgcmVwbGFjZWQgd2l0aCAiMCIgYW5kICIxIi4gT25seSB0aGUgZGF0YSBjb250cmFjdCBvd25lciBjYW4gY3JlYXRlIHRvcCBsZXZlbCBkb21haW5zLhIMcHJlb3JkZXJTYWx0FgYSBHR5cGUSBWFycmF5EglieXRlQXJyYXkTARIIbWluSXRlbXMCIBIIbWF4SXRlbXMCIBIIcG9zaXRpb24CBBILZGVzY3JpcHRpb24SIlNhbHQgdXNlZCBpbiB0aGUgcHJlb3JkZXIgZG9jdW1lbnQSB3JlY29yZHMWBxIEdHlwZRIGb2JqZWN0Egpwcm9wZXJ0aWVzFgISFGRhc2hVbmlxdWVJZGVudGl0eUlkFggSBHR5cGUSBWFycmF5EglieXRlQXJyYXkTARIIbWluSXRlbXMCIBIIbWF4SXRlbXMCIBIIcG9zaXRpb24CABIQY29udGVudE1lZGlhVHlwZRIhYXBwbGljYXRpb24veC5kYXNoLmRwcC5pZGVudGlmaWVyEgtkZXNjcmlwdGlvbhI+SWRlbnRpdHkgSUQgdG8gYmUgdXNlZCB0byBjcmVhdGUgdGhlIHByaW1hcnkgbmFtZSB0aGUgSWRlbnRpdHkSCCRjb21tZW50EiNNdXN0IGJlIGVxdWFsIHRvIHRoZSBkb2N1bWVudCBvd25lchITZGFzaEFsaWFzSWRlbnRpdHlJZBYIEgR0eXBlEgVhcnJheRIJYnl0ZUFycmF5EwESCG1pbkl0ZW1zAiASCG1heEl0ZW1zAiASCHBvc2l0aW9uAgESEGNvbnRlbnRNZWRpYVR5cGUSIWFwcGxpY2F0aW9uL3guZGFzaC5kcHAuaWRlbnRpZmllchILZGVzY3JpcHRpb24SPUlkZW50aXR5IElEIHRvIGJlIHVzZWQgdG8gY3JlYXRlIGFsaWFzIG5hbWVzIGZvciB0aGUgSWRlbnRpdHkSCCRjb21tZW50EiNNdXN0IGJlIGVxdWFsIHRvIHRoZSBkb2N1bWVudCBvd25lchINbWluUHJvcGVydGllcwIBEg1tYXhQcm9wZXJ0aWVzAgESCHBvc2l0aW9uAgUSFGFkZGl0aW9uYWxQcm9wZXJ0aWVzEwASCCRjb21tZW50EpBDb25zdHJhaW50IHdpdGggbWF4IGFuZCBtaW4gcHJvcGVydGllcyBlbnN1cmUgdGhhdCBvbmx5IG9uZSBpZGVudGl0eSByZWNvcmQgaXMgdXNlZCAtIGVpdGhlciBhIGBkYXNoVW5pcXVlSWRlbnRpdHlJZGAgb3IgYSBgZGFzaEFsaWFzSWRlbnRpdHlJZGASDnN1YmRvbWFpblJ1bGVzFgYSBHR5cGUSBm9iamVjdBIKcHJvcGVydGllcxYBEg9hbGxvd1N1YmRvbWFpbnMWBBIEdHlwZRIHYm9vbGVhbhILZGVzY3JpcHRpb24SW1RoaXMgb3B0aW9uIGRlZmluZXMgd2hvIGNhbiBjcmVhdGUgc3ViZG9tYWluczogdHJ1ZSAtIGFueW9uZTsgZmFsc2UgLSBvbmx5IHRoZSBkb21haW4gb3duZXISCCRjb21tZW50Ek9Pbmx5IHRoZSBkb21haW4gb3duZXIgaXMgYWxsb3dlZCB0byBjcmVhdGUgc3ViZG9tYWlucyBmb3Igbm9uIHRvcC1sZXZlbCBkb21haW5zEghwb3NpdGlvbgIAEghwb3NpdGlvbgIGEgtkZXNjcmlwdGlvbhJCU3ViZG9tYWluIHJ1bGVzIGFsbG93IGRvbWFpbiBvd25lcnMgdG8gZGVmaW5lIHJ1bGVzIGZvciBzdWJkb21haW5zEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEghyZXF1aXJlZBUBEg9hbGxvd1N1YmRvbWFpbnMSCHJlcXVpcmVkFQYSBWxhYmVsEg9ub3JtYWxpemVkTGFiZWwSGm5vcm1hbGl6ZWRQYXJlbnREb21haW5OYW1lEgxwcmVvcmRlclNhbHQSB3JlY29yZHMSDnN1YmRvbWFpblJ1bGVzEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEggkY29tbWVudBL7ATdJbiBvcmRlciB0byByZWdpc3RlciBhIGRvbWFpbiB5b3UgbmVlZCB0byBjcmVhdGUgYSBwcmVvcmRlci4gVGhlIHByZW9yZGVyIHN0ZXAgaXMgbmVlZGVkIHRvIHByZXZlbnQgbWFuLWluLXRoZS1taWRkbGUgYXR0YWNrcy4gbm9ybWFsaXplZExhYmVsICsgJy4nICsgbm9ybWFsaXplZFBhcmVudERvbWFpbiBtdXN0IG5vdCBiZSBsb25nZXIgdGhhbiAyNTMgY2hhcnMgbGVuZ3RoIGFzIGRlZmluZWQgYnkgUkZDIDEwMzUuIERvbWFpbiBkb2N1bWVudHMgYXJlIGltbXV0YWJsZTogbW9kaWZpY2F0aW9uIGFuZCBkZWxldGlvbiBhcmUgcmVzdHJpY3RlZAhwcmVvcmRlchYGEgR0eXBlEgZvYmplY3QSB2luZGljZXMVARYDEgRuYW1lEgpzYWx0ZWRIYXNoEgpwcm9wZXJ0aWVzFQEWARIQc2FsdGVkRG9tYWluSGFzaBIDYXNjEgZ1bmlxdWUTARIKcHJvcGVydGllcxYBEhBzYWx0ZWREb21haW5IYXNoFgYSBHR5cGUSBWFycmF5EglieXRlQXJyYXkTARIIbWluSXRlbXMCIBIIbWF4SXRlbXMCIBIIcG9zaXRpb24CABILZGVzY3JpcHRpb24SWURvdWJsZSBzaGEtMjU2IG9mIHRoZSBjb25jYXRlbmF0aW9uIG9mIGEgMzIgYnl0ZSByYW5kb20gc2FsdCBhbmQgYSBub3JtYWxpemVkIGRvbWFpbiBuYW1lEghyZXF1aXJlZBUBEhBzYWx0ZWREb21haW5IYXNoEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEggkY29tbWVudBJKUHJlb3JkZXIgZG9jdW1lbnRzIGFyZSBpbW11dGFibGU6IG1vZGlmaWNhdGlvbiBhbmQgZGVsZXRpb24gYXJlIHJlc3RyaWN0ZWQ="
        }
      ]
    },
    "metadata": {
      "height": "6807",
      "coreChainLockedHeight": 927014,
      "epoch": 848,
      "timeMs": "1701973925674",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::
::::

### getDataContractHistory

**Returns**: [Data Contract](../explanations/platform-protocol-data-contract.md) information for the requested data contract  
**Parameters**:

| Name    | Type     | Required | Description                              |
| ------- | -------- | -------- | ---------------------------------------- |
| `id`    | Bytes    | Yes      | A data contract `id`                     |
| `start_at_ms` | Integer | Yes | Request revisions starting at this timestamp |
| `limit` | Integer  | Yes      | The maximum number of revisions to return |
| `offset` | Integer | Yes      | The offset of the first revision to return |
| `prove` | Boolean  | No       | Set to `true` to receive a proof that contains the requested data contract. The data requested will be encoded as part of the proof in the response.|

**Example Request and Response**

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const client = new DAPIClient();

const contractId = Identifier.from('23iZPjG4ADx8CYGorW4yM8FUo1gihQL2fZszWLTMFyQf');
client.platform.getDataContractHistory(contractId, 0, 2, 0).then((response) => {
  for (const key in response.getDataContractHistory()) {
    const revision = response.getDataContractHistory()[key];
    dpp.dataContract.createFromBuffer(revision).then((dataContract) => {
      console.dir(dataContract.toJSON(), { depth: 10 });
    });
  }
});
```
:::

:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "id":"D43WwBJeadt7AR8wRmcagPiCmi/YvDBHYwheFKzMfyw=",
      "limit": 2,
      "offset": 0,
      "start_at_ms": 0,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDataContractHistory
```
:::
::::

::::{tab-set}
:::{tab-item} Response (JavaScript)
:sync: js-dapi-client
```json 
{
  "$format_version":"0",
  "id":"2ciAVGRuzogbR2NNtNfbn6YdW7BkLWntC7jrLNRMZN9n",
  "config":{
    "$format_version":"0",
    "canBeDeleted":false,
    "readonly":false,
    "keepsHistory":true,
    "documentsKeepHistoryContractDefault":false,
    "documentsMutableContractDefault":true,
    "requiresIdentityEncryptionBoundedKey":null,
    "requiresIdentityDecryptionBoundedKey":null
  },
  "version":1,
  "ownerId":"EB9eBUQxLjA7XGj71x3Msdd1uNmehKYZff3b6idhnTyV",
  "schemaDefs":null,
  "documentSchemas":{
    "note":{
      "type":"object",
      "properties":{
        "message":{
          "type":"string",
          "position":0
        }
      },
      "additionalProperties":false
    }
  }
},
{
  "$format_version":"0",
  "id":"2ciAVGRuzogbR2NNtNfbn6YdW7BkLWntC7jrLNRMZN9n",
  "config":{
    "$format_version":"0",
    "canBeDeleted":false,
    "readonly":false,
    "keepsHistory":true,
    "documentsKeepHistoryContractDefault":false,
    "documentsMutableContractDefault":true,
    "requiresIdentityEncryptionBoundedKey":null,
    "requiresIdentityDecryptionBoundedKey":null
  },
  "version":2,
  "ownerId":"EB9eBUQxLjA7XGj71x3Msdd1uNmehKYZff3b6idhnTyV",
  "schemaDefs":null,
  "documentSchemas":{
    "note":{
      "type":"object",
      "properties":{
        "message":{
          "type":"string",
          "position":0
        },
        "author":{
          "type":"string",
          "position":1
        }
      },
      "additionalProperties":false
    }
  }
}
```
:::

:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "dataContractHistory": {
      "dataContractEntries": [
        {
          "date": "1701271990189",
          "value": "ABgBjx2sR2xg0L+ti2CDLmGzmmI6g9+l/6SFwA8U3ybxAAAAAQABAAABw8GCMyj2ynyRr4i36i1KKHFYdYuPDVwKmo1jmEgT4zwAAQRub3RlFgMSBHR5cGUSBm9iamVjdBIKcHJvcGVydGllcxYBEgdtZXNzYWdlFgISBHR5cGUSBnN0cmluZxIIcG9zaXRpb24DABIUYWRkaXRpb25hbFByb3BlcnRpZXMTAA=="
        },
        {
          "date": "1701272469813",
          "value": "ABgBjx2sR2xg0L+ti2CDLmGzmmI6g9+l/6SFwA8U3ybxAAAAAQABAAACw8GCMyj2ynyRr4i36i1KKHFYdYuPDVwKmo1jmEgT4zwAAQRub3RlFgMSBHR5cGUSBm9iamVjdBIKcHJvcGVydGllcxYCEgdtZXNzYWdlFgISBHR5cGUSBnN0cmluZxIIcG9zaXRpb24CABIGYXV0aG9yFgISBHR5cGUSBnN0cmluZxIIcG9zaXRpb24CARIUYWRkaXRpb25hbFByb3BlcnRpZXMTAA=="
        }
      ]
    },
    "metadata": {
      "height": "6776",
      "coreChainLockedHeight": 926975,
      "epoch": 846,
      "timeMs": "1701968396855",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::
::::

### getDocuments

**Returns**: [Document](../explanations/platform-protocol-document.md) information for the requested document(s)  
**Parameters**:

:::{note}
The `where`, `order_by`, `limit`, `start_at`, and `start_after` parameters must comply with the limits defined on the [Query Syntax](../reference/query-syntax.md) page.
:::

| Name                    | Type    | Required | Description                                                                                      |
| ----------------------- | ------- | -------- | ------------------------------------------------------------------------------------------------ |
| `data_contract_id`      | Bytes   | Yes      | A data contract `id`                                                                             |
| `document_type`         | String  | Yes      | A document type defined by the data contract (e.g. `preorder` or `domain` for the DPNS contract) |
| `where` \*              | Bytes   | No       | Where clause to filter the results |
| `order_by` \*           | Bytes   | No       | Sort records by the field(s) provided |
| `limit`                 | Integer | No       | Maximum number of results to return                                                              |
| ----------              |         |          |                                                                                                  |
| _One_ of the following: |         |          |                                                                                                  |
| `start_at`              | Integer | No       | Return records beginning with the index provided                                                 |
| `start_after`           | Integer | No       | Return records beginning after the index provided                                                |
| ----------              |         |          |                                                                                                  |
| `prove`                 | Boolean | No       | Set to `true` to receive a proof that contains the requested document(s). The data requested will be encoded as part of the proof in the response. |

**Example Request and Response**

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp,
  DashPlatformProtocol,
  Identifier,
} = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const client = new DAPIClient();

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
const type = 'domain';
const limit = 1;
client.platform.getDataContract(contractId).then((contractResponse) => {
  dpp.dataContract
    .createFromBuffer(contractResponse.getDataContract())
    .then((contract) => {
      // Get document(s)
      client.platform
        .getDocuments(contractId, type, {
          limit,
        })
        .then((response) => {
          for (const document of response.documents) {
            const doc = dpp.document.createExtendedDocumentFromDocumentBuffer(
              document,
              type,
              contract,
            );
            console.log(doc.toJSON());
          }
        });
    });
});
```
:::

:::{tab-item} JavaScript (dapi-grpc)
:sync: js-dapi-grpc
```javascript
const {
  v0: { PlatformPromiseClient, GetDataContractRequest, GetDocumentsRequest },
} = require('@dashevo/dapi-grpc');
const { default: loadDpp, DashPlatformProtocol, Identifier } = require('@dashevo/wasm-dpp');

loadDpp();
const dpp = new DashPlatformProtocol(null);
const platformPromiseClient = new PlatformPromiseClient(
  'https://seed-1.testnet.networks.dash.org:1443',
);

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
const contractIdBuffer = Buffer.from(contractId);
const getDataContractRequest = new GetDataContractRequest();
getDataContractRequest.setId(contractIdBuffer);

platformPromiseClient
  .getDataContract(getDataContractRequest)
  .then((contractResponse) => {
    dpp.dataContract.createFromBuffer(contractResponse.getDataContract()).then((contract) => {
      // Get documents
      const getDocumentsRequest = new GetDocumentsRequest();
      const type = 'domain';
      const limit = 10;

      getDocumentsRequest.setDataContractId(contractIdBuffer);
      getDocumentsRequest.setDocumentType(type);
      // getDocumentsRequest.setWhere(whereSerialized);
      // getDocumentsRequest.setOrderBy(orderBySerialized);
      getDocumentsRequest.setLimit(limit);
      // getDocumentsRequest.setStartAfter(startAfter);
      // getDocumentsRequest.setStartAt(startAt);

      platformPromiseClient.getDocuments(getDocumentsRequest).then((response) => {
        for (const document of response.getDocuments().getDocumentsList()) {
          const documentBuffer = Buffer.from(document);
          const doc = dpp.document.createExtendedDocumentFromDocumentBuffer(
            documentBuffer,
            type,
            contract,
          );
          console.log(doc.toJSON());
        }
      });
    });
  })
  .catch((e) => console.error(e));
```
:::

:::{tab-item} Request (gRPCurl)
:sync: grpcurl
```shell
# Request documents
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "data_contract_id":"5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "document_type":"domain",
      "limit":1
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```
:::
::::

::::{tab-set}
:::{tab-item} Response (JavaScript)
:sync: js-dapi-client
```json
{
  "$id":"Do3YtBPJG72zG4tCbN5VE8djJ6rLpvx7yvtMWEy89HC",
  "$ownerId":"4pk6ZhgDtxn9yN2bbB6kfsYLRmUBH7PKUq275cjyzepT",
  "label":"Chronic",
  "normalizedLabel":"chr0n1c",
  "normalizedParentDomainName":"dash",
  "parentDomainName":"dash",
  "preorderSalt":"1P9N5qv1Ww2xkv6/XXpsvymyGYychRsLXMhCqvW79Jo=",
  "records":{
    "dashUniqueIdentityId":"OM4WaCQNLedQ0rpbl1UMTZhEbnVeMfL4941ZD08iyFw="
  },
  "subdomainRules":{
    "allowSubdomains":false
  },
  "$revision":1,
  "$createdAt":null,
  "$updatedAt":null,
  "$dataContract":{
    "$format_version":"0",
    "id":"GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec",
    "config":{
      "$format_version":"0",
      "canBeDeleted":false,
      "readonly":false,
      "keepsHistory":false,
      "documentsKeepHistoryContractDefault":false,
      "documentsMutableContractDefault":true,
      "requiresIdentityEncryptionBoundedKey":null,
      "requiresIdentityDecryptionBoundedKey":null
    },
    "version":1,
    "ownerId":"EuzJmuZdBSJs2eTrxHEp6QqJztbp6FKDNGMeb4W2Ds7h",
    "schemaDefs":null,
    "documentSchemas":{
      "domain":[
        "Object"
      ],
      "preorder":[
        "Object"
      ]
    }
  },
  "$type":"domain"
}
```
:::

:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "documents": {
      "documents": [
        "AAZ1S7dbhY4VJrSCvjs2Z1DIwa9Qt9MAyjbJdh7gPu6oDsGC/h1Ayf+ZzXp2zLWDF4XB2qMLWZ0brsAKo0r/0sYBAAcAAAGRivixugAAAZGK+LG6AAABkYr4sboAF2F1ZzI1LTEyMzQ1Njc4OTAxMjM0NTY3F2F1ZzI1LTEyMzQ1Njc4OTAxMjM0NTY3AQRkYXNoBGRhc2gAIQEOwYL+HUDJ/5nNenbMtYMXhcHaowtZnRuuwAqjSv/SxgEA"
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "epoch": 1170,
      "timeMs": "1725567845055",
      "protocolVersion": 1,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getEpochsInfo

**Returns**: Information for the requested epoch(s)

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ----------- |
| `start_epoch` | Bytes | No | First epoch being requested
| `count` | Integer | No | Number of records to request
| `ascending` | Boolean | No | Set to `true` to query in ascending order. Results are returned in descending order by default.
| `prove` | Boolean | No | Set to `true` to receive a proof that contains the requested data contracts

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "count": 2
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getEpochsInfo
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "epochs": {
      "epochInfos": [
        {
          "number": 849,
          "firstBlockHeight": "6822",
          "firstCoreBlockHeight": 927030,
          "startTime": "1701976758619",
          "feeMultiplier": 2
        },
        {
          "number": 850,
          "firstBlockHeight": "6840",
          "firstCoreBlockHeight": 927061,
          "startTime": "1701980303210",
          "feeMultiplier": 2
        }
      ]
    },
    "metadata": {
      "height": "6843",
      "coreChainLockedHeight": 927065,
      "epoch": 850,
      "timeMs": "1701980850126",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}

```
:::
::::

### getPathElements

Retrieves elements for a specified path in the platform.

**Returns**: The elements or a cryptographic proof.

**Parameters**:

| Name    | Type     | Required | Description |
| ------- | -------- | -------- | ----------- |
| `path`  | Array    | Yes      | The path for which elements are being requested |
| `keys`  | Array    | No       | The keys associated with the elements being requested |
| `prove` | Boolean  | No       | Set to `true` to receive a proof that contains the requested elements |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
# `path` array values be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "path": ["path_element_1", "path_element_2"],
      "keys": ["key1", "key2"]
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getPathElements
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "elements": {},
    "metadata": {
      "height": "3256",
      "coreChainLockedHeight": 1087397,
      "epoch": 780,
      "timeMs": "1724164508171",
      "protocolVersion": 1,
      "chainId": "dash-testnet-50"
    }
  }
}
```
:::
::::

### getPrefundedSpecializedBalance

Retrieves the pre-funded specialized balance for a specific identity.

**Returns**: The balance or a cryptographic proof.

**Parameters**:

| Name    | Type     | Required | Description |
| ------- | -------- | -------- | ----------- |
| `id`    | Bytes    | Yes      | The ID of the identity whose balance is being requested |
| `prove` | Boolean  | No       | Set to `true` to receive a proof that contains the requested balance |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getPrefundedSpecializedBalance
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "balance": "100000000",
    "metadata": {
      "height": "6860",
      "coreChainLockedHeight": 927080,
      "epoch": 852,
      "timeMs": "1701983732299",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::
::::

### getProofs

:::::{dropdown} ⚠️ For internal use only
  
  This endpoint is only used for communication between DAPI and Drive. All external requests are rejected.

  **Returns**: Proof information for the requested identities, contracts, and/or document(s)

  **Parameters**:

  A combination of one or more of the following are required fields are required:

  | Field | Type | Required | Description |
  | - | - | - | - |
  | `identities` | `IdentityRequest` | No | List of identity requests
  | `contracts`  | `ContractRequest` | No | List of contract requests
  | `documents`  | `DocumentRequest` | No | List of document requests

  **Request type details**

  | Field | Type | Required | Description |
  | - | - | - | - |
  | **IdentityRequest** | | |
  | `identity_id`  | Bytes       | Yes | Identity ID
  | `request_type` | Type (enum) | Yes | Type of identity proof data to request (options: FULL_IDENTITY, BALANCE, KEYS)
  | --------------- | | |
  | **ContractRequest** | | |
  | `contract_id` | Bytes | Yes | A contract ID
  | --------------- | | |
  | **DocumentRequest** | | |
  | `contract_id`                 | Bytes  | Yes | A contract ID
  | `document_type`               | String | Yes | Type of contract document
  | `document_type_keeps_history`   | Boolean | No |Indicates if the document type maintains a history
  | `document_id`                 | Bytes  | Yes | Document ID

  **Example Request and Response**

  ::::{tab-set}
  :::{tab-item} gRPCurl
  :sync: grpcurl
  ```shell
  # Request proofs for an identity and a data contract
  # `identity_id` and `contract_id` must be represented in base64
  grpcurl -proto protos/platform/v0/platform.proto \
    -d '{
      "v0": {
        "identities": [
          {
            "request_type": "FULL_IDENTITY",
            "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
          }
        ],
        "contracts": [
          {
            "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
          }
        ],
        "documents": []
      }
    }' \
    seed-1.testnet.networks.dash.org:1443 \
    org.dash.platform.dapi.v0.Platform/getProofs
  ```
  :::
  ::::
  ::::{tab-set}
  :::{tab-item} Response (gRPCurl)
  :sync: grpcurl
  ```json
  // GroveDB proof for the requested identity and contract
  {
    "v0": {
      "proof": {
        "grovedbProof": "AQYAAQDuAgHx2HzoF4wSud2eE4a+j9LczjcgboCJsEZJK+Bl/97hLAQBIAAkAgEgn2WlCmdZa3aGIz7NDvWCqFa+KfeLcarKW0WH8vLbYZgAAJpItikQWz3TcDudnxxiJSY5h5Ndejq2UOkZPubKDN0QAfhJDycGmgAM67TyQkPU3kuavJLc7wlcbvBD48JEelqeEQQBQAAkAgEgoqG0rG/vIuoqGmjoEjZEs1eHX2tBLBgQkoHBRueycbwA1L5TY2e0nwaAJolrXP7S6qWDVVTGeFpz4cjXIHoOPUoQAY6uNnLUV0nQB1qQqQWBLRyaJZfu/o/kBIBYXq4egeakBAFgAC0EASCfZaUKZ1lrdoYjPs0O9YKoVr4p94txqspbRYfy8tthmP3KiDkEJD0hAACXwGQWS6E+DOmhhxAd6xNjdVGeulgD5i3dNpt5nRiwGxABMwg2kOcA+9xQ3NhoBqze6XaeidN/5COubSCHkp+bZ9wREQEBIN0CAduEoBne86ZfsX2HwXtJ9jM/ghzM4rJqnUNLkRV/wom8As3l9skVhNWf85H1JsVvK8PkRe3fO83N0QjZ9StB5QNQEAFviDbTTGTvt2tyoqGNJydjW32VQs0vs5XVc8d/M5FJpQQgMBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/awACQIBAQIBAwAAAKWXTEBAq5u+FwX5AZapJ7qj7G7SIxP3mYey+otzvhefEAHYJdPBfgqNhf9vXtvya+ip4ZEJR6rubhW79ZMAabO48RERAmKv6d1LDUzhxxrKW1iDGkYD6tZ9TfORRKQKkfWd11g8EAFfm8qRd2+WVybP18udB0457INJ3U11YNIZvdKFY1rQjBECDegFhb6zh0BzQ1pirX6IQGLel/eF8+xv98HZYmkJgBAQAVAO5YGj0RWNmvhmC0NqrtWHwnjSUQNxd6uYRJMjfcPrEQEgMBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/ax/AwEAAAsACAAAAAAAAAAAAAQBAQAFAgEBAQCqh3fBWf3zs2zg6Wt8+AFC1/58xqnqSxC9exEK7kPRhRACKQ9N/X8hOac8dT4zuZC4upFtihZq9JsYfb5UoiGIDyIQAUYZe6LR2JrmXw44tCBxZtK21SAUzHBMVnCCvx29ZfnfEQIBAWUDAQAALQAqAAAAAAAAACECyLR0e1KMrF/d96bMY3Au4E7X0TMpBOCFEDQ+oA3OVGoAAAMBAQAtACoAAQACAAAAIQIB7ij4T1SFOQVn6TnCtYYBC2Omnsksq1NdyWqMcZE2AgAAEAEBQNkCAaylxbCNFaN71X5p+nfqhe5T3e5JDjX3BTp7s2veVhTOAgHZbe7OzqjzwOzXn6NLbzSt8PItwUVj91x8pf3lguQGEAE2pM5PtpHXYchTiDJh5csJWcrbCMX9R548J6lvLkRY1AKghzeA2y1iYD9QJGMD9IAzws0Sh9r+EI5NYy7xhp72chABtgUnjZcfcBf5QBfldwp2LQHKYDCIWImz4Q/4E46nyQMEIOZoxlmvZq7h5ywYbd57W34KHXEqCcQNVyH2Ir9TxTFVAAUCAQEBAPLfdXh4PcRzmCXJPABALtDjvEgBgLJwwOYCf0L54idmEAFJybKFoR6l0GDoa2MQGMKbvM0N4w1AhupCbh4b3NiCWhEC0vjwIA7WA1zKJTmJ6cqaWFgqIs59iDoqcRdSLsZEaLkQAXPWZ9eFJe3P3Uf6GA/WznOBSDg+hIny9UF6gSdQJYiIERERAiDmaMZZr2au4ecsGG3ee1t+Ch1xKgnEDVch9iK/U8UxVf8eAwEAD1gA+1MPAOZoxlmvZq7h5ywYbd57W34KHXEqCcQNVyH2Ir9TxTFVAAAAAAABAAABMBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/awAAgZkb21haW4WBhIEdHlwZRIGb2JqZWN0EgdpbmRpY2VzFQMWAxIEbmFtZRIScGFyZW50TmFtZUFuZExhYmVsEgpwcm9wZXJ0aWVzFQIWARIabm9ybWFsaXplZFBhcmVudERvbWFpbk5hbWUSA2FzYxYBEg9ub3JtYWxpemVkTGFiZWwSA2FzYxIGdW5pcXVlEwEWAxIEbmFtZRIOZGFzaElkZW50aXR5SWQSCnByb3BlcnRpZXMVARYBEhxyZWNvcmRzLmRhc2hVbmlxdWVJZGVudGl0eUlkEgNhc2MSBnVuaXF1ZRMBFgISBG5hbWUSCWRhc2hBbGlhcxIKcHJvcGVydGllcxUBFgESG3JlY29yZHMuZGFzaEFsaWFzSWRlbnRpdHlJZBIDYXNjEgpwcm9wZXJ0aWVzFgcSBWxhYmVsFgYSBHR5cGUSBnN0cmluZxIHcGF0dGVybhIqXlthLXpBLVowLTldW2EtekEtWjAtOS1dezAsNjF9W2EtekEtWjAtOV0kEgltaW5MZW5ndGgCAxIJbWF4TGVuZ3RoAj8SCHBvc2l0aW9uAgASC2Rlc2NyaXB0aW9uEhlEb21haW4gbGFiZWwuIGUuZy4gJ0JvYicuEg9ub3JtYWxpemVkTGFiZWwWBhIEdHlwZRIGc3RyaW5nEgdwYXR0ZXJuEjxeW2EtaGota20tbnAtejAtOV1bYS1oai1rbS1ucC16MC05LV17MCw2MX1bYS1oai1rbS1ucC16MC05XSQSCW1heExlbmd0aAI/Eghwb3NpdGlvbgIBEgtkZXNjcmlwdGlvbhKjRG9tYWluIGxhYmVsIGNvbnZlcnRlZCB0byBsb3dlcmNhc2UgZm9yIGNhc2UtaW5zZW5zaXRpdmUgdW5pcXVlbmVzcyB2YWxpZGF0aW9uLiAibyIsICJpIiBhbmQgImwiIHJlcGxhY2VkIHdpdGggIjAiIGFuZCAiMSIgdG8gbWl0aWdhdGUgaG9tb2dyYXBoIGF0dGFjay4gZS5nLiAnYjBiJxIIJGNvbW1lbnQSXE11c3QgYmUgZXF1YWwgdG8gdGhlIGxhYmVsIGluIGxvd2VyY2FzZS4gIm8iLCAiaSIgYW5kICJsIiBtdXN0IGJlIHJlcGxhY2VkIHdpdGggIjAiIGFuZCAiMSIuEhBwYXJlbnREb21haW5OYW1lFgYSBHR5cGUSBnN0cmluZxIHcGF0dGVybhItXiR8XlthLXpBLVowLTldW2EtekEtWjAtOS1dezAsNjF9W2EtekEtWjAtOV0kEgltaW5MZW5ndGgCABIJbWF4TGVuZ3RoAj8SCHBvc2l0aW9uAgISC2Rlc2NyaXB0aW9uEidBIGZ1bGwgcGFyZW50IGRvbWFpbiBuYW1lLiBlLmcuICdkYXNoJy4SGm5vcm1hbGl6ZWRQYXJlbnREb21haW5OYW1lFgcSBHR5cGUSBnN0cmluZxIHcGF0dGVybhJBXiR8XlthLWhqLWttLW5wLXowLTldW2EtaGota20tbnAtejAtOS1cLl17MCw2MX1bYS1oai1rbS1ucC16MC05XSQSCW1pbkxlbmd0aAIAEgltYXhMZW5ndGgCPxIIcG9zaXRpb24CAxILZGVzY3JpcHRpb24SokEgcGFyZW50IGRvbWFpbiBuYW1lIGluIGxvd2VyY2FzZSBmb3IgY2FzZS1pbnNlbnNpdGl2ZSB1bmlxdWVuZXNzIHZhbGlkYXRpb24uICJvIiwgImkiIGFuZCAibCIgcmVwbGFjZWQgd2l0aCAiMCIgYW5kICIxIiB0byBtaXRpZ2F0ZSBob21vZ3JhcGggYXR0YWNrLiBlLmcuICdkYXNoJxIIJGNvbW1lbnQSwE11c3QgZWl0aGVyIGJlIGVxdWFsIHRvIGFuIGV4aXN0aW5nIGRvbWFpbiBvciBlbXB0eSB0byBjcmVhdGUgYSB0b3AgbGV2ZWwgZG9tYWluLiAibyIsICJpIiBhbmQgImwiIG11c3QgYmUgcmVwbGFjZWQgd2l0aCAiMCIgYW5kICIxIi4gT25seSB0aGUgZGF0YSBjb250cmFjdCBvd25lciBjYW4gY3JlYXRlIHRvcCBsZXZlbCBkb21haW5zLhIMcHJlb3JkZXJTYWx0FgYSBHR5cGUSBWFycmF5EglieXRlQXJyYXkTARIIbWluSXRlbXMCIBIIbWF4SXRlbXMCIBIIcG9zaXRpb24CBBILZGVzY3JpcHRpb24SIlNhbHQgdXNlZCBpbiB0aGUgcHJlb3JkZXIgZG9jdW1lbnQSB3JlY29yZHMWBxIEdHlwZRIGb2JqZWN0Egpwcm9wZXJ0aWVzFgISFGRhc2hVbmlxdWVJZGVudGl0eUlkFggSBHR5cGUSBWFycmF5EglieXRlQXJyYXkTARIIbWluSXRlbXMCIBIIbWF4SXRlbXMCIBIIcG9zaXRpb24CABIQY29udGVudE1lZGlhVHlwZRIhYXBwbGljYXRpb24veC5kYXNoLmRwcC5pZGVudGlmaWVyEgtkZXNjcmlwdGlvbhI+SWRlbnRpdHkgSUQgdG8gYmUgdXNlZCB0byBjcmVhdGUgdGhlIHByaW1hcnkgbmFtZSB0aGUgSWRlbnRpdHkSCCRjb21tZW50EiNNdXN0IGJlIGVxdWFsIHRvIHRoZSBkb2N1bWVudCBvd25lchITZGFzaEFsaWFzSWRlbnRpdHlJZBYIEgR0eXBlEgVhcnJheRIJYnl0ZUFycmF5EwESCG1pbkl0ZW1zAiASCG1heEl0ZW1zAiASCHBvc2l0aW9uAgESEGNvbnRlbnRNZWRpYVR5cGUSIWFwcGxpY2F0aW9uL3guZGFzaC5kcHAuaWRlbnRpZmllchILZGVzY3JpcHRpb24SPUlkZW50aXR5IElEIHRvIGJlIHVzZWQgdG8gY3JlYXRlIGFsaWFzIG5hbWVzIGZvciB0aGUgSWRlbnRpdHkSCCRjb21tZW50EiNNdXN0IGJlIGVxdWFsIHRvIHRoZSBkb2N1bWVudCBvd25lchINbWluUHJvcGVydGllcwIBEg1tYXhQcm9wZXJ0aWVzAgESCHBvc2l0aW9uAgUSFGFkZGl0aW9uYWxQcm9wZXJ0aWVzEwASCCRjb21tZW50EpBDb25zdHJhaW50IHdpdGggbWF4IGFuZCBtaW4gcHJvcGVydGllcyBlbnN1cmUgdGhhdCBvbmx5IG9uZSBpZGVudGl0eSByZWNvcmQgaXMgdXNlZCAtIGVpdGhlciBhIGBkYXNoVW5pcXVlSWRlbnRpdHlJZGAgb3IgYSBgZGFzaEFsaWFzSWRlbnRpdHlJZGASDnN1YmRvbWFpblJ1bGVzFgYSBHR5cGUSBm9iamVjdBIKcHJvcGVydGllcxYBEg9hbGxvd1N1YmRvbWFpbnMWBBIEdHlwZRIHYm9vbGVhbhILZGVzY3JpcHRpb24SW1RoaXMgb3B0aW9uIGRlZmluZXMgd2hvIGNhbiBjcmVhdGUgc3ViZG9tYWluczogdHJ1ZSAtIGFueW9uZTsgZmFsc2UgLSBvbmx5IHRoZSBkb21haW4gb3duZXISCCRjb21tZW50Ek9Pbmx5IHRoZSBkb21haW4gb3duZXIgaXMgYWxsb3dlZCB0byBjcmVhdGUgc3ViZG9tYWlucyBmb3Igbm9uIHRvcC1sZXZlbCBkb21haW5zEghwb3NpdGlvbgIAEghwb3NpdGlvbgIGEgtkZXNjcmlwdGlvbhJCU3ViZG9tYWluIHJ1bGVzIGFsbG93IGRvbWFpbiBvd25lcnMgdG8gZGVmaW5lIHJ1bGVzIGZvciBzdWJkb21haW5zEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEghyZXF1aXJlZBUBEg9hbGxvd1N1YmRvbWFpbnMSCHJlcXVpcmVkFQYSBWxhYmVsEg9ub3JtYWxpemVkTGFiZWwSGm5vcm1hbGl6ZWRQYXJlbnREb21haW5OYW1lEgxwcmVvcmRlclNhbHQSB3JlY29yZHMSDnN1YmRvbWFpblJ1bGVzEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEggkY29tbWVudBL7ATdJbiBvcmRlciB0byByZWdpc3RlciBhIGRvbWFpbiB5b3UgbmVlZCB0byBjcmVhdGUgYSBwcmVvcmRlci4gVGhlIHByZW9yZGVyIHN0ZXAgaXMgbmVlZGVkIHRvIHByZXZlbnQgbWFuLWluLXRoZS1taWRkbGUgYXR0YWNrcy4gbm9ybWFsaXplZExhYmVsICsgJy4nICsgbm9ybWFsaXplZFBhcmVudERvbWFpbiBtdXN0IG5vdCBiZSBsb25nZXIgdGhhbiAyNTMgY2hhcnMgbGVuZ3RoIGFzIGRlZmluZWQgYnkgUkZDIDEwMzUuIERvbWFpbiBkb2N1bWVudHMgYXJlIGltbXV0YWJsZTogbW9kaWZpY2F0aW9uIGFuZCBkZWxldGlvbiBhcmUgcmVzdHJpY3RlZAhwcmVvcmRlchYGEgR0eXBlEgZvYmplY3QSB2luZGljZXMVARYDEgRuYW1lEgpzYWx0ZWRIYXNoEgpwcm9wZXJ0aWVzFQEWARIQc2FsdGVkRG9tYWluSGFzaBIDYXNjEgZ1bmlxdWUTARIKcHJvcGVydGllcxYBEhBzYWx0ZWREb21haW5IYXNoFgYSBHR5cGUSBWFycmF5EglieXRlQXJyYXkTARIIbWluSXRlbXMCIBIIbWF4SXRlbXMCIBIIcG9zaXRpb24CABILZGVzY3JpcHRpb24SWURvdWJsZSBzaGEtMjU2IG9mIHRoZSBjb25jYXRlbmF0aW9uIG9mIGEgMzIgYnl0ZSByYW5kb20gc2FsdCBhbmQgYSBub3JtYWxpemVkIGRvbWFpbiBuYW1lEghyZXF1aXJlZBUBEhBzYWx0ZWREb21haW5IYXNoEhRhZGRpdGlvbmFsUHJvcGVydGllcxMAEggkY29tbWVudBJKUHJlb3JkZXIgZG9jdW1lbnRzIGFyZSBpbW11dGFibGU6IG1vZGlmaWNhdGlvbiBhbmQgZGVsZXRpb24gYXJlIHJlc3RyaWN0ZWQAAjfsugQjtjFH1tziawxcHm6Itrtfd4HxFXit+EBuIEGCEAIBYN8CAb/jxzcNWFZEpbAUm+m8bHmGDiDoIp0nmnAVzK1RREtVAtYIgZuRPU70BrwnGYqsfr3rqOmCvT+uOZn5JD+z2Fb7EAHRk0v0/UW0amfTj5Q3RgNXsCy34jIVuLie5yXuiKURfQQgMBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/awACwP9eCCC7wkAAAAApQ40uU7eIE6Lc7gSiikQMybwd7ICds9JRkR7mN9dsKsQAS6QXX9hmpIEs9jEW3eAXNz9stWYGeSq/BnIm9Y+L8XMERECiTcgqXvEL2837Y7t1JcjkYGVIFZ7NkS80ZLVeDUZzS0QAfdYjSzg2BIkhpiPAHQ5W4aN0OlpO7pNjwx46JLVtF5HEQLIaUC5PRYEMoQrfMJnG3PgKokrA37sdKCgo7Hxar/TcRABMapwxTKSfBkDooZq35By87R1c8Y4h4LvZXgOwY+CNfQR",
        "quorumHash": "AAAAu4I2BiBDnydSZOLs2bV45yWb+vJFEKQi9wTc3hg=",
        "signature": "t6IYrtqREmhCMGQva67DMYpqoY+4fIPB0245y/vhrs0L4qqv7+jDYFoppC7TzFCnCpXLxwOL15u8AOmGFsuMn7FA7qtz/rzJT0124Va1EL5ioeD0DwPVVCAEfQcN/7+6",
        "round": 1,
        "blockIdHash": "R6LgAhbTCMP2bbiktIm1nLnJ4csO0UvaK6vArGJ2ghs=",
        "quorumType": 6
      },
      "metadata": {
        "height": "9350",
        "coreChainLockedHeight": 929436,
        "epoch": 943,
        "timeMs": "1702317747792",
        "protocolVersion": 1,
        "chainId": "dash-testnet-37"
      }
    }
  }
  
  ```
  :::
  ::::
  :::::

### getProtocolVersionUpgradeState

**Returns**: The number of votes cast for each protocol version.

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": { }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getProtocolVersionUpgradeState
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "versions": {
      "versions": [
        {
          "versionNumber": 1,
          "voteCount": 28
        }
      ]
    },
    "metadata": {
      "height": "10649",
      "coreChainLockedHeight": 930014,
      "epoch": 965,
      "timeMs": "1702397313265",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::
::::

### getProtocolVersionUpgradeVoteStatus

**Returns**: Protocol version upgrade status.

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `start_pro_tx_hash` | String | No | Protx hash of an evonode
| `count` | Integer | No       | Number of records to request
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `start_pro_tx_hash` must be represented in base64 if present
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "count": 2
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getProtocolVersionUpgradeVoteStatus
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "versions": {
      "versionSignals": [
        {
          "proTxHash": "WyRggLpkNQaF/jAtPXkPW7I4y2GZINRiMMhE8HmUSiM=",
          "version": 1
        },
        {
          "proTxHash": "XGVCdmYVOHGDcV2VipJVUkcvkzNfoWEogEI+S72u9DY=",
          "version": 1
        }
      ]
    },
    "metadata": {
      "height": "10662",
      "coreChainLockedHeight": 930024,
      "epoch": 966,
      "timeMs": "1702398582963",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::
::::

### getStatus

Retrieves status information related to Dash Platform.

**Returns**: Status details including version, node, chain, network, and state sync information, or a cryptographic proof.

**Parameters**:

This endpoint does not require any parameters.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {}
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getStatus
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "version": {
      "software": {
        "dapi": "1.2.0",
        "drive": "1.2.0",
        "tenderdash": "1.2.1"
      },
      "protocol": {
        "tenderdash": {
          "p2p": 10,
          "block": 14
        },
        "drive": {
          "latest": 1,
          "current": 1
        }
      }
    },
    "node": {
      "id": "H/vx0yVB3Lj1VVMFKVcEqf+a3CQ=",
      "proTxHash": "LkhlGi6cDLTy+3q4dAYapK8M0otZaVYx5qNa85UO9vs="
    },
    "chain": {
      "latestBlockHash": "XY1U/Ay7DCdZqJJwM4sXSw1OFdBIbnVYFc9sJep1hNw=",
      "latestAppHash": "9wq6IzU4AjuL27HybKqvWOOPCbnpBJQjk6q64nsd7i8=",
      "latestBlockHeight": "7768",
      "earliestBlockHash": "CPoCwn7AOQujAeT8fj1+rbNQyBk+PmKgk2iXBuOiC/o=",
      "earliestAppHash": "vwzLnKBxugGubmegwJD5eAPSbVbWddzVExeBy8rI7I8=",
      "earliestBlockHeight": "1",
      "maxPeerBlockHeight": "7768",
      "coreChainLockedHeight": 1099682
    },
    "network": {
      "chainId": "dash-testnet-51",
      "peersCount": 61,
      "listening": true
    },
    "stateSync": {},
    "time": {
      "local": "1725890999274",
      "block": "1725890829092",
      "genesis": "0",
      "epoch": 1260
    }
  }
}
```
:::
::::

### getTotalCreditsInPlatform

Retrieves the total credits in the platform.

**Returns**: The total amount of credits or a cryptographic proof.

**Parameters**:

| Name    | Type     | Required | Description |
| ------- | -------- | -------- | ----------- |
| `prove` | Boolean  | No       | Set to `true` to receive a proof that contains the requested credit total |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {}
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTotalCreditsInPlatform
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "credits": "1594457743625920",
    "metadata": {
      "height": "3263",
      "coreChainLockedHeight": 1087403,
      "epoch": 781,
      "timeMs": "1724165757972",
      "protocolVersion": 1,
      "chainId": "dash-testnet-50"
    }
  }
}
```
:::
::::

### getVotePollsByEndDate

Retrieves vote polls that will end within a specified date range.

**Returns**: A list of vote polls or a cryptographic proof.

**Parameters**:

| Name               | Type     | Required | Description |
| ------------------ | -------- | -------- | ----------- |
| `start_time_info`  | Object   | No       | Start time information for filtering vote polls |
| `end_time_info`    | Object   | No       | End time information for filtering vote polls |
| `limit`            | Integer  | No       | Maximum number of results to return |
| `offset`           | Integer  | No       | Offset for pagination |
| `ascending`        | Boolean  | No       | Sort order for results |
| `prove`            | Boolean  | No       | Set to `true` to receive a proof that contains the requested vote polls |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "start_time_info": {"start_time_ms": "1701980000000", "start_time_included": true},
      "end_time_info": {"end_time_ms": "1702000000000", "end_time_included": true},
      "limit": 10
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getVotePollsByEndDate
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "votePollsByTimestamps": {
      "finishedResults": true
    },
    "metadata": {
      "height": "2876",
      "coreChainLockedHeight": 1086885,
      "epoch": 761,
      "timeMs": "1724094056585",
      "protocolVersion": 1,
      "chainId": "dash-testnet-50"
    }
  }
}
```
:::
::::

### waitForStateTransitionResult

**Returns**: The state transition hash and either a proof that the state transition was confirmed in a block or an error.  
**Parameters**:

| Name                    | Type    | Required | Description                      |
| ----------------------- | ------- | -------- | -------------------------------- |
| `state_transition_hash` | Bytes   | Yes      | Hash of the state transition     |
| `prove`                 | Boolean | Yes      | Set to `true` to request a proof. The data requested will be encoded as part of the proof in the response. |

**Example Request**

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\nJavaScript (dapi-client) example (old)\nconst DAPIClient = require('@dashevo/dapi-client');\nconst DashPlatformProtocol = require('@dashevo/dpp');\nconst crypto = require('crypto');\n\nconst client = new DAPIClient();\nconst dpp = new DashPlatformProtocol();\n\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    //  Calculate state transition hash\n    const hash = crypto.createHash('sha256')\n      .update(stateTransition.toBuffer())\n      .digest();\n\n    console.log(`Requesting proof of state transition with hash:\\n\\t${hash.toString('hex')}`);\n\n    client.platform.waitForStateTransitionResult(hash, { prove: true })\n      .then((response) => {\n        console.log(response);\n      });\n  });\n-->\n\n<!--\nJavaScript (dapi-grpc) example (old)\nconst {\n  v0: {\n    PlatformPromiseClient,\n    WaitForStateTransitionResultRequest,\n  },\n} = require('@dashevo/dapi-grpc');\nconst DashPlatformProtocol = require('@dashevo/dpp');\nconst crypto = require('crypto');\n\nconst platformPromiseClient = new PlatformPromiseClient(\n  'https://seed-1.testnet.networks.dash.org:1443',\n);\n\nconst dpp = new DashPlatformProtocol();\n\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    //  Calculate state transition hash\n    const hash = crypto.createHash('sha256')\n      .update(stateTransition.toBuffer())\n      .digest();\n\n    const waitForStateTransitionResultRequest = new WaitForStateTransitionResultRequest();\n    waitForStateTransitionResultRequest.setStateTransitionHash(hash);\n    waitForStateTransitionResultRequest.setProve(true);\n\n    console.log(`Requesting proof of state transition with hash:\\n\\t${hash.toString('hex')}`);\n\n    platformPromiseClient.waitForStateTransitionResult(waitForStateTransitionResultRequest)\n      .then((response) => {\n        const rootTreeProof = Buffer.from(response.getProof().getRootTreeProof());\n        const storeTreeProof = Buffer.from(response.getProof().getStoreTreeProof());\n        console.log(`Root tree proof: ${rootTreeProof.toString('hex')}`);\n        console.log(`Store tree proof: ${storeTreeProof.toString('hex')}`);\n      })\n  \t\t.catch((e) => console.error(e));\n  });\n-->\n\n<!--\ngRPCurl example (old)\n# `state_transition_hash` must be represented in base64\n# Replace `state_transition_hash` with your own before running\ngrpcurl -proto protos/platform/v0/platform.proto \\\n  -d '{\n    \"state_transition_hash\":\"wEiwFu9WvAtylrwTph5v0uXQm743N+75C+C9DhmZBkw=\",\n    \"prove\": \"true\"\n    }' \\\n  seed-1.testnet.networks.dash.org:1443 \\\n  org.dash.platform.dapi.v0.Platform/waitForStateTransitionResult\n-->"
  }
  [/block]
```

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');

const client = new DAPIClient();

// Replace <YOUR_STATE_TRANSITION_HASH> with your actual hash
const hash = <YOUR_STATE_TRANSITION_HASH>;
client.platform.waitForStateTransitionResult(hash, { prove: true })
  .then((response) => {
    console.log(response);
  });

```
:::

:::{tab-item} Request (gRPCurl)
:sync: grpcurl
```shell
# Replace `your_state_transition_hash` with your own before running
# `your_state_transition_hash` must be represented in base64
#    Example: wEiwFu9WvAtylrwTph5v0uXQm743N+75C+C9DhmZBkw=
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "state_transition_hash":your_state_transition_hash,
      "prove": "true"
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/waitForStateTransitionResult
```
:::
::::

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\ndapi-client\n{\n  proof: {\n    rootTreeProof: <Buffer 01 00 00 00 03 26 e0 35 e0 31 82 7e 7c 27 b0 91 23 41 ed d2 11 bf 3b 90 54 70 11 2c 68 5a 8e 76 8c 68 bb 39 21 3d cf 46 6d 09 d0 7a 28 e3 e9 0b 2b 0e ... 17 more bytes>,\n    storeTreeProof: <Buffer 01 0b ee 31 ce ca 2a bd 44 6a db d4 9f 13 4a 7d 70 25 96 a9 b9 02 6e c4 e1 90 95 f7 a1 b4 c9 de 1f e4 63 e6 ce f7 58 3a 5b c3 10 01 78 9b 4f 98 9a c9 ... 526 more bytes>\n  }\n}\n-->\n<!--\ndapi-grpc\nRequesting proof of state transition with hash:\n        8ae93b89c272455f3ce8d01dba99a3a28c9550262a602c6ba44de08e545d3aa9\nRoot tree proof: 010000000326e035e031827e7c27b0912341edd211bf3b905470112c685a8e768c68bb39213dcf466d09d07a28e3e90b2b0e1d1510dede30214f68e32f8cf498220101\nStore tree proof: 010bee31ceca2abd446adbd49f134a7d702596a9b9026ec4e19095f7a1b4c9de1fe463e6cef7583a5bc31001789b4f989ac9f8f524f1247fed372502d8c54a3c026072d5239f074422621673c250d1c74eadbb304a10013fb54a99ef641b9a7585d6d28dd443875e435a35022d92a0711f56ae23bc13f4a630a1455970451e3f1001fe2b060fca69ce2eb3d784cec28c0f575690f131026df252af068635bdf08f5448ea67c23d9a9a02831001a7df0a9f392682d7d7d0a29bd43d932c16b0d6530320a8b7df4cadb6cdfd5b5d1bb31cbb488d241e91d60cc1341cd686a3fbb6291f19e800a5632469645820a8b7df4cadb6cdfd5b5d1bb31cbb488d241e91d60cc1341cd686a3fbb6291f196724736368656d61783468747470733a2f2f736368656d612e646173682e6f72672f6470702d302d342d302f6d6574612f646174612d636f6e7472616374676f776e657249645820703796bfd3e2bbd54505a8e04929bb05b8aecfb1cd5c013ef8a8b84511770e0c69646f63756d656e7473a1646e6f7465a26a70726f70657274696573a1676d657373616765a1647479706566737472696e67746164646974696f6e616c50726f70657274696573f46f70726f746f636f6c56657273696f6e001001d94cd40044b8485e962d80e57c1992c77a182a1611111102abe7e3f7231ed71b8c4fd7ee09d4a1f970a51cd4100139312feadce145313ef34f720e940892d0ed2405111102245c6aaaf192b51207333be85ab77c9c9393af47100128ef7d4479e4f488373d92280fe8e52a9a48a6621111\n-->\n<!--\ngRPCurl\n{\n  \"proof\": {\n    \"merkleProof\": \"AQAAAAAAAAJHAV8NeFRgf0cWRiCIIVsbJcNs+bALwShVQEkXV2jRCueIAkeoHTKeU60+Jm2oiHbGSkOL8ui06Nj27SLz2raMF29iEAHKnCrDvO67hcJV79tfQwqQSFcxJOek9Fa/x3oYvwQrQQL8lxVOSAkZSC1qhI8LJa6PtR+u8TifMMmRCRY2dXrSUBABihjPBDgD9SM/d9JgWkYyT+sUp4FdgotmwHhZIB1rJVUCkaeftxRkQ/B0FU26ojDJirY/SwZ8RcU1/3pnbJbA+5EQBCBkeRNzJuVLjOKnDOmG48wnSzjHg5lLdlA5JSBD79rQxQAFAgEBAAAYUfu7+1iqqIwjkszndZ6Vm8pli6pjt4XxvvgKCcE3ygI+G8nIsflGKoZQOaWGcFBmXDzAwJqjGlMxSIWNSEgoQBACAQd7xuP4BzKoaf75MNyQQC6Q7e94Vg2IdQe2LFJysA4QAZ2mq+ad/rNJ7n2fPiJgHi4NMT9Wht6Kb5J8qF20hajJEQKz2VnGsgYNwMjY9kadWb63Tjk3nTqFttgjLnoz4PCpQBABpdWVJ9sfU+o+OEcUuFcDOV+y4gYFoao3kVNLZ+Yz7Y4RAuVHBoF21TyNc9DUDHmAfcaJf6K+/VzqIzfnJ7iGqXN+EAGvNlkFsWw+DjFg+MLjzo2MzUaWk7sA63+rG3FQJ7LO2hERERECPImih8uZnpEfew+qLeKrdEig5TR6g5VsfuHI9U2WuvsQAU7qdWenHDisDf3TNzJQytKJYaeyhmy2LEo11zZVwsoREQIAAAAAAAAA/wMBAAD6APcBAAAApGJpZFggZHkTcyblS4zipwzphuPMJ0s4x4OZS3ZQOSUgQ+/a0MVnYmFsYW5jZRo7mmxAaHJldmlzaW9uAGpwdWJsaWNLZXlzgqZiaWQAZGRhdGFYIQLlz7I9IuqDAf1fp2xiyvGiApsvgANo2ldfmrWv6MsfG2R0eXBlAGdwdXJwb3NlAGhyZWFkT25sefRtc2VjdXJpdHlMZXZlbACmYmlkAWRkYXRhWCECrq7odM9OoHGEyM1D19ZAaEPf50OKLwsxL2D4SpnLZllkdHlwZQBncHVycG9zZQBocmVhZE9ubHn0bXNlY3VyaXR5TGV2ZWwCAAEAAAAAAAAA0QQBAAAkAgEgbaBpE46QX8+EXS6Sl5CG4r+JuiXVDhxZeZy/TS8qnQEAUw2uiB7scatAs99mQfB5VfVb0lMSywDMHXpmUgNfONsC4OEPflWGlZAqBSOhaKD0/SfPJHbOOMEfCjTtBV1jjgwQARdKA3tf2c8gP3H7tRKcRMHXfljTH/4L8L63tbZk5FX/EQL+TedZ8kFHQEuNY8e9pfmaLI36Y7rHe1hAjVBSh9U95BABfPfYq74T0N0ygKE4spKvSQkekrnH0Ge8Ot0FEDsq2rcR\",\n    \"signatureLlmqHash\": \"AAAA1h0X9yUNsXpD0/iKlsPvVb+VezkZAIkQIzmGqoc=\",\n    \"signature\": \"jeByZ8qlZvID/C3LVVy/mZGHlRu2QhN3MZO09hCOjAH0gn1tqrAX6BXaJf6qRLw9APv0+nInObRF3JhstvsByPK8QOHCCl9M3NpcgI/HCECpqMMG8S9DPtJYI6HwQO5I\"\n  },\n  \"metadata\": {\n    \"height\": \"1221\",\n    \"coreChainLockedHeight\": 802939\n  }\n}\n-->"
  }
  [/block]
```

## Deprecated Endpoints

The following endpoints were recently deprecated. See the [previous version of documentation](https://docs.dash.org/projects/platform/en/0.25.0/docs/reference/dapi-endpoints-platform-endpoints.html) for additional information on these endpoints.

### getIdentities

:::{attention}
Deprecated in Dash Platform v1.0.0
:::

**Returns**: [Identity](../explanations/identity.md) information for the requested identities  

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `ids`   | Array   | Yes      | An array of identity IDs
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity

### getIdentitiesByPublicKeyHashes

:::{attention}
Deprecated in Dash Platform v1.0.0
:::

**Returns**: An array of [identities](../explanations/identity.md) associated with the provided public key hashes  
**Parameters**:

| Name                | Type    | Required | Description                                                             |
| ------------------- | ------- | -------- | ----------------------------------------------------------------------- |
| `public_key_hashes` | Bytes   | Yes      | Public key hashes (sha256-ripemd160) of identity public keys            |
| `prove`             | Boolean | No       | Set to `true` to receive a proof that contains the requested identities |

## Code Reference

Implementation details related to the information on this page can be found in:

* The [Platform repository](https://github.com/dashpay/platform/tree/master/packages/dapi) `packages/dapi/lib/grpcServer/handlers/core` folder
* The [Platform repository](https://github.com/dashpay/platform/tree/master/packages/dapi-grpc) `packages/dapi-grpc/protos` folder
