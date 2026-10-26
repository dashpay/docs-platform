```{eval-rst}
.. _reference-dapi-endpoints-platform-grpc:
```

# Platform gRPC Endpoints

Please refer to the [gRPC Overview](../reference/dapi-endpoints-grpc-overview.md) for details regarding running the examples shown below.

## General Behavior

### Versioning

All Dash Platform endpoints are versioned so future updates can be done without creating significant
issues for API consumers.

### Request size limit

:::{versionadded} 4.1.0
Platform gRPC requests are capped at 128 KiB encoded, reduced from 64 MiB. A larger request is rejected by the transport before it reaches the endpoint. The limit sits above every per-endpoint budget — the largest are [`getPathElements`](#getpathelements) at 64 KiB of path and key components and [`broadcastStateTransition`](#broadcaststatetransition) at 20 KiB — so requests within those bounds are unaffected.
:::

### Result limits and pagination

Endpoints that return a list accept a `count` or `limit` field. Unless an endpoint states otherwise,
the default and maximum are 100, although node operators may configure a different limit. A value of
`0` or a value above the node's limit is rejected. Exceptions are documented in the relevant
endpoint sections.

Endpoints that accept an array of identifiers (for example identity IDs, token IDs, or ProTx hashes)
accept at most 100 entries.

A few endpoints accept a different range:

| Endpoint | Accepted range |
| -------- | -------------- |
| [`getShieldedEncryptedNotes`](#getshieldedencryptednotes) | `count` is capped at 8,192 notes; `0` requests the maximum rather than being rejected |

Some endpoints also cap the response independently of what the request asks for. These caps are
applied by the server and cannot be raised by the caller:

| Endpoint | Response cap |
| -------- | ------------ |
| [`getRecentAddressBalanceChanges`](#getrecentaddressbalancechanges) | 100 blocks |
| [`getRecentCompactedAddressBalanceChanges`](#getrecentcompactedaddressbalancechanges) | 25 entries |

### Data Proofs and Metadata

Platform gRPC endpoints can provide [proofs](https://github.com/dashpay/platform/blob/master/packages/dapi-grpc/protos/platform/v0/platform.proto#L142-L149) so the data returned for a request can be verified as being valid. When requesting proofs, the data requested will be encoded as part of the proof in the response. Proofs are supported in the [js-evo-sdk](https://github.com/dashpay/platform/tree/master/packages/js-evo-sdk) and via the low-level [dapi-grpc library](https://github.com/dashpay/platform/tree/master/packages/dapi-grpc).

Some [additional metadata](https://github.com/dashpay/platform/blob/master/packages/dapi-grpc/protos/platform/v0/platform.proto#L153-L160) is also provided with responses:

| Metadata field          | Description                                           |
| :---------------------- | :---------------------------------------------------- |
| `height`                | Last committed platform chain height                  |
| `coreChainLockedHeight` | Height of the most recent ChainLock on the core chain |
| `epoch`                 | The current Platform epoch                            |
| `timeMs`                | Unix timestamp in milliseconds for the response       |
| `protocolVersion`       | Platform protocol version                             |
| `chainId`               | Name of the network                                   |

```{eval-rst}
.. _mn-identity-id:
```

### Masternode identity IDs

[Masternode identities](../explanations/identity.md#masternode-identities) are created automatically
by the system based on the [Core masternode registration transaction (protx)
hash](inv:user:std#ref-txs-proregtx). The masternode *owner* identity ID is the protx hash itself, so
it is created by converting the protx hash to base58. This can be done using an [online base58
encoder](https://appdevtools.com/base58-encoder-decoder) or through JavaScript using the [bs58
package](https://www.npmjs.com/package/bs58) as shown below. For gRPCurl, convert the protx hash to
base64 instead. This can be done using an [online hex to base64
encoder](https://base64.guru/converter/encode/hex).

The *voter* and *operator* identities use derived IDs instead: `SHA-256(protx_hash || voting_address)`
for the voter identity and `SHA-256(protx_hash || operator_public_key)` for the operator identity
([source](https://github.com/dashpay/platform/blob/v4.1.0/packages/rs-dpp/src/identifier/mod.rs#L5-L31)).
Encoding the protx hash alone will not produce a voter or operator identity ID.

```{eval-rst}
.. _reference-dapi-endpoints-platform-grpc-protx-to-id:
```

:::{code-block} javascript
:caption: Protx hash to owner identity ID

const bs58 = require('bs58').default;

const protx = '8eca4bcbb3a124ab283afd42dad3bdb2077b3809659788a0f1daffce5b9f001f';
const base58Protx = bs58.encode(Buffer.from(protx, 'hex'));
console.log(`Masternode owner identity id (base58): ${base58Protx}`);
const base64Protx = Buffer.from(protx, 'hex').toString('base64');
console.log(`Masternode owner identity id (base64): ${base64Protx}`);
// Output:
//  Masternode owner identity id (base58): AcPogCxrxeas7jrWYG7TnLHKbsA5KLHGfvg6oYgANZ8J
//  Masternode owner identity id (base64): jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=
:::

## Contested Resource Endpoints

Contested resources are a special class of Dash Platform documents that require deterministic
conflict resolution when multiple identities request the same logical resource (e.g., a DPNS name).
These resources are defined at the data contract level using [contested
indexes](./data-contracts.md#contested-indices). See the [DPNS conflict resolution
section](../explanations/dpns.md#conflict-resolution) for an example of how this works for premium
DPNS names.

The endpoints in this section allow clients to check the status of active contests, retrieve
contestants, and obtain the outcome.

:::{versionadded} 4.1.0
Serialized index and cursor values are now bounded. A request to `getContestedResources`,
`getContestedResourceVotersForIdentity`, or `getContestedResourceVoteState` is rejected with
`InvalidArgument` if it supplies more values than the contested index has properties, if any single
encoded value exceeds 4 KiB, if the combined encoded size of all index and cursor values in the
request exceeds 4 KiB, if a value nests arrays or maps more than 64 levels deep, or if a value has
trailing bytes after its encoding. Previously these values were decoded without bounds.
:::

### getContestedResources

Retrieves the contested resources for a specific contract, document type, and index.

**Returns**: A list of contested resource values or a cryptographic proof.

**Parameters**:

| Name                   | Type     | Required | Description                                                                 |
| ---------------------- | -------- | -------- | --------------------------------------------------------------------------- |
| `contract_id`          | Bytes    | Yes      | The ID of the data contract associated with the contested resources         |
| `document_type_name`   | String   | Yes      | The name of the document type associated with the contested resources       |
| `index_name`           | String   | Yes      | The name of the document type's contested index. A document type has at most one contested index; naming any other index is rejected with `InvalidArgument` |
| `start_index_values`   | Array    | No       | Start values for index, for pagination                                      |
| `end_index_values`     | Array    | No       | End values for index, for pagination                                        |
| `start_at_value_info`  | Object   | No       | Start value information for pagination                                      |
| `count`                | Integer  | No       | Number of contested resources to return. See [Result limits and pagination](#result-limits-and-pagination) |
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
| `limit`                        | Integer  | No       | Maximum number of results to return. See [Result limits and pagination](#result-limits-and-pagination) |
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
      "identity_id": "CSgo7cCB07oaVPBDJZuUE2jyxxiIGwap00eIOyG/4xM="
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
      "contestedResourceIdentityVotes": [
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "domain",
          "serializedIndexStorageValues": [
            "ZGFzaA==",
            "dDBueQ=="
          ],
          "voteChoice": {
            "identityId": "+G9rGhk5ggauDroBJbx8DHj/DCjLaLvlxj3m4oFs9f0="
          }
        },
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "domain",
          "serializedIndexStorageValues": [
            "ZGFzaA==",
            "anUxeQ=="
          ],
          "voteChoice": {
            "identityId": "hzKARzLQgCeLgieyXkc22PVsDy9RoyRCSQpVA1sq3Ag="
          }
        },
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "domain",
          "serializedIndexStorageValues": [
            "ZGFzaA==",
            "cmVkcGFuZGE="
          ],
          "voteChoice": {
            "identityId": "Yiub6FbtHuyrGjiOhtFFsNzkFXay15HKapz/5WmIdRc="
          }
        },
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "domain",
          "serializedIndexStorageValues": [
            "ZGFzaA==",
            "YTFleGFuZHJh"
          ],
          "voteChoice": {
            "identityId": "FSzaDd9OWziOwkizZf/t6HdDCG3pY6zb4MTriOuiyf0="
          }
        },
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "domain",
          "serializedIndexStorageValues": [
            "ZGFzaA==",
            "ZW0xMTFt"
          ],
          "voteChoice": {
            "identityId": "HpGErJllHxDvKnetz9d88452CCfWsbm8s+SLq7hn1v4="
          }
        },
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "domain",
          "serializedIndexStorageValues": [
            "ZGFzaA==",
            "YXNkdGhyZWVhcHI="
          ],
          "voteChoice": {
            "identityId": "toqsgrVi2jpH5zyFqx8IkC2cK987anWbUQJknPu+qss="
          }
        }
      ],
      "finishedResults": true
    },
    "metadata": {
      "height": "164297",
      "coreChainLockedHeight": 2256124,
      "epoch": 25,
      "timeMs": "1744850434997",
      "protocolVersion": 8,
      "chainId": "evo1"
    }
  }
}
```
:::
::::

Each `voteChoice` carries a `voteChoiceType` of `TOWARDS_IDENTITY`, `ABSTAIN`, or `LOCK`. Because
`TOWARDS_IDENTITY` is the proto3 default it is omitted from JSON output, so the entries above are all
`TOWARDS_IDENTITY` votes. `identityId` is present only for `TOWARDS_IDENTITY`; abstain and lock votes
carry no `identityId`.

### getContestedResourceVotersForIdentity

Retrieves the voters for a specific identity associated with a contested resource.

**Returns**: A list of voters or a cryptographic proof.

**Parameters**:

| Name                   | Type     | Required | Description                                                                 |
| ---------------------- | -------- | -------- | --------------------------------------------------------------------------- |
| `contract_id`          | Bytes    | Yes      | The ID of the data contract associated with the contested resource          |
| `document_type_name`   | String   | Yes      | The name of the document type associated with the contested resource        |
| `index_name`           | String   | Yes      | The name of the document type's contested index. A document type has at most one contested index; naming any other index is rejected with `InvalidArgument` |
| `index_values`         | Array    | Yes      | The values used to query the contested resource. Must contain exactly one value per contested index property; supplying more returns `InvalidArgument`, and supplying fewer surfaces as an `InvalidParameter` error from Drive. |
| `contestant_id`        | Bytes    | Yes      | The ID of the identity for which to retrieve voters                         |
| `start_at_identifier_info` | Object | No      | Start identifier information for pagination                                 |
| `count`                | Integer  | No       | Number of results to return. See [Result limits and pagination](#result-limits-and-pagination) |
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
      "index_values": ["EgRkYXNo", "EgZlbTExMW0="],
      "contestant_id": "HpGErJllHxDvKnetz9d88452CCfWsbm8s+SLq7hn1v4="
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
      "voters": [
        "9BNnQL24MI/zNJQeg6njKqMFsPfY3r1syRB9zxAlZFQ=",
        "7GFTbyVQbbUuol/RD2iNAeKbsL7NXPjfqSjhapTRN3g=",
        "vMOhByXvdDR4bNAWsB/gF5WdtF+W4HIEciZgRJZnN4I=",
        "rU44/IHactYbFCOO5uW5GRVVTiTXJXGIAGktOoY8kQs=",
        "nrjH6/4hLLe9Eh/Y9NPsezMctlDH4+q+4+2AujX68WQ=",
        "hLickXbsCtHIUjadrnX4DGaALQ1hBi4HSzAn1iAiI1A=",
        "TC4jH+JzJyRlHQ/YxdtqN+L2icRxcM/8Uuq7gxjSJ+8=",
        "Nk7hQkGkrfC7lApPG8EyQXOKXoGKsg07MfY1khdQxoM=",
        "FE0hYA6383IDzr7zrFxdT6pgY9kXjt90b4OKJED7tCg=",
        "CSgo7cCB07oaVPBDJZuUE2jyxxiIGwap00eIOyG/4xM="
      ],
      "finishedResults": true
    },
    "metadata": {
      "height": "164240",
      "coreChainLockedHeight": 2256049,
      "epoch": 25,
      "timeMs": "1744839902217",
      "protocolVersion": 8,
      "chainId": "evo1"
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
| `index_name`                                     | String   | Yes      | The name of the document type's contested index. A document type has at most one contested index; naming any other index is rejected with `InvalidArgument` |
| `index_values`                                   | Array    | Yes      | The values used to query the contested resource. Must contain exactly one value per contested index property. |
| `result_type`                                    | Enum     | Yes      | Specifies the result type to return: `DOCUMENTS`, `VOTE_TALLY`, or `DOCUMENTS_AND_VOTE_TALLY` |
| `allow_include_locked_and`<br>`_abstaining_vote_tally` | Boolean  | No       | Include votes that are locked or abstaining in the tally |
| `start_at_identifier_info`                       | Object   | No       | Start identifier information for pagination |
| `count`                                          | Integer  | No       | Number of results to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`                                          | Boolean  | No       | Set to `true` to receive a proof that contains the requested vote state |

**Response Object** (`contestedResourceContenders`)

| Name | Type | Description |
| ---- | ---- | ----------- |
| `contenders` | Array | Contenders in the contest. Each has an `identifier`, an optional `voteCount`, and an optional serialized `document` |
| `abstainVoteTally` | Integer | Number of abstain votes. Returned only when `allow_include_locked_and_abstaining_vote_tally` is `true` |
| `lockVoteTally` | Integer | Number of lock votes. Returned only when `allow_include_locked_and_abstaining_vote_tally` is `true` |
| `finishedVoteInfo` | Object | Present only once the contest has concluded. See below |

When the contest has finished, `finishedVoteInfo` contains:

| Name | Type | Description |
| ---- | ---- | ----------- |
| `finishedVoteOutcome` | Enum | `TOWARDS_IDENTITY`, `LOCKED`, or `NO_PREVIOUS_WINNER`. `TOWARDS_IDENTITY` is the proto3 default and is omitted from JSON output |
| `wonByIdentityId` | Bytes | The winning identity. Present only when the outcome is `TOWARDS_IDENTITY` |
| `finishedAtBlockHeight` | String (uint64) | Platform block height at which the contest concluded |
| `finishedAtCoreBlockHeight` | Integer | Core block height at which the contest concluded |
| `finishedAtBlockTimeMs` | String (uint64) | Block time in milliseconds at which the contest concluded |
| `finishedAtEpoch` | Integer | Epoch in which the contest concluded |

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
      "index_values": ["EgRkYXNo", "EgZlbTExMW0="],
      "result_type": 2
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContestedResourceVoteState
```
:::
::::
::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "contestedResourceContenders": {
      "contenders": [
        {
          "identifier": "HpGErJllHxDvKnetz9d88452CCfWsbm8s+SLq7hn1v4=",
          "voteCount": 34,
          "document": "AKcHIgv30Tb3zWNw0bgSF17cJp7HW+A6eiYRVpS3YMKuHpGErJllHxDvKnetz9d88452CCfWsbm8s+SLq7hn1v4BAAcAAAGWGJoweAAAAZYYmjB4AAABlhiaMHgABkVtaWxpTQZlbTExMW0BBGRhc2gEZGFzaAAhAR6RhKyZZR8Q7yp3rc/XfPOOdggn1rG5vLPki6u4Z9b+AQA="
        }
      ]
    },
    "metadata": {
      "height": "164296",
      "coreChainLockedHeight": 2256122,
      "epoch": 25,
      "timeMs": "1744850252661",
      "protocolVersion": 8,
      "chainId": "evo1"
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
| `limit`            | Integer  | No       | Maximum number of results to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `offset`           | Integer  | No       | Offset for pagination. Cannot be combined with `prove`; a proof request with a non-zero `offset` is rejected |
| `ascending`        | Boolean  | No       | Sort order for results |
| `prove`            | Boolean  | No       | Set to `true` to receive a proof that contains the requested vote polls |

**Response Object**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `votePollsByTimestamps` | Array | Vote polls grouped by end timestamp. Each entry has a `timestamp` and a `serializedVotePolls` array holding the serialized vote polls ending at that time |
| `finishedResults` | Boolean | `true` when the returned page is the last one for the requested range |

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

## Data Contract Endpoints

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
const client = new DAPIClient({ network: 'testnet' });

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

### getDataContractsByRange

:::{versionadded} 5.0.0
:::

Enumerates every data contract on Platform, one page at a time, in ascending contract ID order.

**Returns**: A page of [Data Contract](../explanations/platform-protocol-data-contract.md) entries, each with the contract ID and (unless `ids_only` is set) the serialized contract, or a cryptographic proof. The response uses the same `GetDataContractsResponse` message as [`getDataContracts`](#getdatacontracts).

**Parameters**:

| Name          | Type    | Required | Description |
| ------------- | ------- | -------- | ----------- |
| `limit`       | Integer | No       | Maximum number of contracts to return, from 1 to 100. Omit to return up to 100. `0` or a value above 100 is rejected with `InvalidLimit`. The default and maximum are protocol constants, not node settings, so an omitted limit selects the same page on every node |
| `start_after` | Bytes   | No       | 32-byte contract ID. The page starts after this contract. Mutually exclusive with `start_at` |
| `start_at`    | Bytes   | No       | 32-byte contract ID. The page starts at this contract (inclusive). Mutually exclusive with `start_after` |
| `ids_only`    | Boolean | No       | Set to `true` to return only contract IDs. Each entry's `data_contract` is left unset |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested page |

A cursor that is not 32 bytes long is rejected with `InvalidArgument`. When no contracts remain, the
response contains an empty `data_contract_entries` list rather than a `NotFound` error. A page with
fewer entries than `limit` is the last page; otherwise pass the last entry's `identifier` as
`start_after` to fetch the next page.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once Dash Platform v5.0 is deployed on
# testnet. The response values below are illustrative only.
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "limit": 2,
      "ids_only": true
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDataContractsByRange
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
          "identifier": "AAJ1jKe+lMQ0w2eRyEWOrfiQXjxgPzVZf9hxVhfq/bM="
        },
        {
          "identifier": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
        }
      ]
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getDataContractsLatestVersions

:::{versionadded} 5.0.0
:::

Returns the current version number of each requested data contract. Clients can use this to check whether contracts they already hold are still current without downloading the contracts again.

**Returns**: One entry per distinct requested contract ID, in contract ID order, or a cryptographic proof. Each entry contains the contract `identifier`, its current `version` (absent when no contract has that ID), and the serialized `data_contract` when `include_contracts` is set and the contract exists.

**Parameters**:

| Name                | Type    | Required | Description |
| ------------------- | ------- | -------- | ----------- |
| `ids`               | Array   | Yes      | An array of 32-byte data contract IDs. At least one and at most 100 IDs; an empty array or an ID that is not 32 bytes is rejected with `InvalidArgument`, and more than 100 returns `InvalidLimit` |
| `include_contracts` | Boolean | No       | Set to `true` to also return the serialized contract in each entry for a contract that exists |
| `prove`             | Boolean | No       | Set to `true` to receive a proof that contains the requested contract versions |

From protocol version 14, every contract has a small version record stored beside it. When
`include_contracts` is not set, the response is read from that record and a proof covers only the
version records (a few hundred bytes per contract) rather than the full contracts. When
`include_contracts` is set, or on protocol versions before 14, the proof is the same
multi-contract proof that [`getDataContracts`](#getdatacontracts) returns.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once Dash Platform v5.0 is deployed on
# testnet. The response values below are illustrative only.
# `ids` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "ids": [
        "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
      ],
      "include_contracts": false,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDataContractsLatestVersions
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "dataContractsLatestVersions": {
      "entries": [
        {
          "identifier": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
        },
        {
          "identifier": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "version": 1
        }
      ]
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getContractFeePots

:::{versionadded} 5.0.0
:::

Returns the two fee pots of a data contract. From protocol version 14, a document type can charge a
fixed action fee, on top of the normal processing fees, for actions on its documents. Each fee has
an owner part, which collects in the owner pot that the contract owner claims, and a moderators part,
which collects in the moderators pot that the contract's moderation team shares. A pot is paid out
by a contract fee claim, at most once per epoch.

**Returns**: The `owner` and `moderators` pots, or a cryptographic proof. Each pot contains the
`credits` it holds and, if the pot has been paid out before, its `last_claim`: the `epoch` and block
time (`time_ms`) of the most recent payout and the `claimant_id` of the identity that signed the
claim. `last_claim` is unset for a pot that has never been paid out.

**Parameters**:

| Name          | Type    | Required | Description |
| ------------- | ------- | -------- | ----------- |
| `contract_id` | Bytes   | Yes      | The 32-byte ID of the data contract. An ID that is not 32 bytes is rejected with `InvalidArgument`, and an ID with no contract returns `NotFound` |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains both pots and their last claims |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a contract charging action fees
# is published on testnet. The response values below are illustrative only.
# `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractFeePots
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "pots": {
      "owner": {
        "credits": "1500000",
        "lastClaim": {
          "epoch": 17950,
          "timeMs": "1792500000000",
          "claimantId": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw="
        }
      },
      "moderators": {
        "credits": "500000"
      }
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
      "chainId": "dash-testnet-51"
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
| `start_at_ms` | Integer | No | Request revisions starting at this timestamp |
| `limit` | Integer  | No      | The maximum number of revisions to return |
| `offset` | Integer | No      | The offset of the first revision to return |
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
const client = new DAPIClient({ network: 'testnet' });

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

## Document Endpoints

### getDocuments

:::{versionchanged} 4.0.0
Adds a typed v1 request surface (`WhereClause` / `OrderClause` / `Select`) and four aggregate modes — `DOCUMENTS`, `COUNT`, `SUM`, `AVG`. The legacy v0 CBOR surface is still supported.
:::

:::{versionchanged} 4.2.0
Protocol version 14 adds [ranked](#ranked-documents), [having-range](#having-range-documents), [chained](#chained-documents), and [composite](#composite-documents) query modes, plus the `IN_TIME_RANGE` where operator. `offset` is now consumed in ranked mode, and `having` is served in having-range mode.
:::

**Returns**: [Document](../explanations/platform-protocol-document.md) information for the requested document(s), or an aggregate count/sum/average over the matched document set.

The request envelope is `oneof version { v0; v1; }`. Pick a version per call:

- **v1** (default for new code, v4.0+) — typed request fields and aggregate `select` modes.
- **v0** (legacy) — CBOR-encoded `where` / `order_by` byte strings. Fetch only.

**Common request fields** (apply to every variant below)

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `data_contract_id` | Bytes | Yes | A data contract `id`. |
| `document_type` | String | Yes | A document type defined by the data contract. |
| `where_clauses` (v1) / `where` (v0) | Typed (v1) or CBOR bytes (v0) | No | Filter clauses. A v1 clause carries `field`, `operator`, and exactly one operand: `IN_TIME_RANGE` clauses set `time_range` and leave `value` unset, every other operator sets `value` and leaves `time_range` unset. Either mismatch is rejected. See [Query Syntax](../reference/query-syntax.md) and [Time-range selection](../reference/query-syntax.md#time-range-selection). |
| `order_by` | Typed (v1) or CBOR bytes (v0) | No | Sort order. See [Query Syntax](../reference/query-syntax.md). |
| `prove` | Boolean | No | Return a proof instead of data. See [Platform proofs](../reference/platform-proofs.md). |
| `having` (v1) | Typed | No | Aggregate filters on grouped results. From protocol version 14, a single clause naming the selected aggregate alongside one `group_by` property is served as a [having-range query](../reference/query-syntax.md#having-range-queries). Other shapes, and every request on protocol version 13 or earlier, are rejected - usually with `Unsupported`, though a bad limit gives `InvalidLimit` and a missing `group_by` gives `InvalidParameter`. See [Query Syntax](../reference/query-syntax.md). |
| `offset` (v1) | Integer | No | Row-based pagination offset. Consumed only by [ranked queries](../reference/query-syntax.md#ranked-aggregate-queries), where it skips that many ranks before the returned page and the response reports the skip performed. Rejected with `Unsupported` on every other v1 route; use `start_at` / `start_after` instead. See [Query Syntax](../reference/query-syntax.md). |

For v1, see also the [doctype-level aggregate flags](../protocol-ref/data-contract-document.md#aggregate-query-flags), which control whether a document type supports the `COUNT` / `SUM` / `AVG` modes below.

#### Fetch documents

Returns matched documents.

**Mode-specific request fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `limit` | Integer | No | Maximum number of documents to return. A value of `0` or an omitted value uses the configured default of 100; the [maximum is also 100](query-syntax.md#query-modifiers) by default, and a larger value is rejected with `InvalidLimit`. |
| `start_at` _or_ `start_after` | Bytes | No | Cursor — start at / after this document ID. |

For v1, `selects` may be omitted (defaults to `[Select{ function: DOCUMENTS }]`) or set explicitly.

**Example Request**

::::{tab-set}
:::{tab-item} v1 (gRPCurl)
:sync: v1-grpcurl

```shell
# `data_contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v1": {
      "data_contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "document_type": "domain",
      "where_clauses": [
        { "field": "normalizedParentDomainName", "operator": "EQUAL", "value": { "text": "dash" } }
      ],
      "limit": 1
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```

:::

:::{tab-item} v0 (gRPCurl)
:sync: v0-grpcurl

```shell
# `data_contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "data_contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "document_type": "domain",
      "limit": 1
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```

:::

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
const client = new DAPIClient({ network: 'testnet' });

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
const type = 'domain';
const limit = 1;
client.platform.getDataContract(contractId).then((contractResponse) => {
  dpp.dataContract
    .createFromBuffer(contractResponse.getDataContract())
    .then((contract) => {
      client.platform
        .getDocuments(contractId, type, { limit })
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
::::

**Example Response**

::::{tab-set}
:::{tab-item} v1 (gRPCurl)
:sync: v1-grpcurl

```json
{
  "v1": {
    "data": {
      "documents": {
        "documents": [
          "AAZ1S7dbhY4VJrSCvjs2Z1DIwa9Qt9MAyjbJdh7gPu6oDsGC/h1Ayf+ZzXp2zLWDF4XB2qMLWZ0brsAKo0r/0sYBAAcAAAGRivixugAAAZGK+LG6AAABkYr4sboAF2F1ZzI1LTEyMzQ1Njc4OTAxMjM0NTY3F2F1ZzI1LTEyMzQ1Njc4OTAxMjM0NTY3AQRkYXNoBGRhc2gAIQEOwYL+HUDJ/5nNenbMtYMXhcHaowtZnRuuwAqjSv/SxgEA"
        ]
      }
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

:::{tab-item} v0 (gRPCurl)
:sync: v0-grpcurl

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

:::{tab-item} JavaScript (decoded document)
:sync: js-dapi-client

```json
{
  "$id": "Do3YtBPJG72zG4tCbN5VE8djJ6rLpvx7yvtMWEy89HC",
  "$ownerId": "4pk6ZhgDtxn9yN2bbB6kfsYLRmUBH7PKUq275cjyzepT",
  "label": "Chronic",
  "normalizedLabel": "chr0n1c",
  "normalizedParentDomainName": "dash",
  "parentDomainName": "dash",
  "records": {
    "dashUniqueIdentityId": "OM4WaCQNLedQ0rpbl1UMTZhEbnVeMfL4941ZD08iyFw="
  },
  "subdomainRules": { "allowSubdomains": false },
  "$revision": 1,
  "$type": "domain"
}
```

:::
::::

#### Count documents

:::{versionadded} 4.0.0
:::

Returns one aggregate count, or per-group counts when `group_by` is set. Requires the doctype to set `documentsCountable: true` (and `rangeCountable: true` for range-grouped queries). See [aggregate query flags](../protocol-ref/data-contract-document.md#aggregate-query-flags).

**Mode-specific request fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `selects` | `[Select{ function: COUNT }]` | Yes | Projection. |
| `group_by` | Repeated string | No | `[]`, `[in_field]`, `[range_field]`, or `[in_field, range_field]`. |

`limit` is rejected for `group_by=[]` and `group_by=[in_field]` (the result is bounded by construction). `limit: 0` is rejected with `InvalidLimit` in every mode — omit the field to request the server default (SDK bindings that require a numeric argument use `-1`). `start_at` / `start_after` are not valid in this mode — paginate by narrowing the where clause. See [aggregate query limits](query-syntax.md#aggregate-query-limits) for the full per-mode contract.

**Response shape**

- `group_by = []` → `counts.aggregate_count` (single integer).
- `group_by = [...]` → `counts.entries[]` of `{ in_key?, key, count }`.

`IN` values that match no documents are omitted from `counts.entries` rather than returned with `count: 0`. Diff your request's `IN` array against the returned `key` values to detect "queried but absent."

**Example Request**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl

```shell
# TODO: Replace with a real example once a contract using
# `documentsCountable` is published on testnet. The contract id,
# document type, and field name below are illustrative only.
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v1": {
      "data_contract_id": "<base64-of-countable-contract-id>",
      "document_type": "shipments",
      "selects": [{ "function": "COUNT" }],
      "where_clauses": [
        { "field": "status", "operator": "EQUAL", "value": { "text": "delivered" } }
      ]
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```

:::
::::

**Example Response**

```json
{
  "v1": {
    "data": {
      "counts": {
        "aggregateCount": "1234"
      }
    },
    "metadata": { "height": "5991", "coreChainLockedHeight": 1097384 }
  }
}
```

Count values use `[jstype = JS_STRING]` on the proto, so JavaScript clients receive strings to avoid precision loss above `Number.MAX_SAFE_INTEGER`.

#### Sum documents

:::{versionadded} 4.0.0
:::

Returns the sum of an integer field across matched documents, or per-group sums when `group_by` is set. Requires the doctype to set `documentsSummable: "<property>"` (and `rangeSummable: true` for range-grouped queries). See [aggregate query flags](../protocol-ref/data-contract-document.md#aggregate-query-flags).

**Mode-specific request fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `selects` | `[Select{ function: SUM, field: "<prop>" }]` | Yes | `field` must name the summable property. |
| `group_by` | Repeated string | No | Same shape rules as Count above. |

`limit` follows the same rules as Count: rejected for `group_by=[]` and `group_by=[in_field]`, and `limit: 0` is rejected with `InvalidLimit` in every mode. `start_at` / `start_after` are not valid. See [aggregate query limits](query-syntax.md#aggregate-query-limits).

**Response shape**

- `group_by = []` → `sums.aggregate_sum` (signed integer).
- `group_by = [...]` → `sums.entries[]` of `{ in_key?, key, sum }`.

**Example Request**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl

```shell
# TODO: Replace with a real example once a contract using
# `documentsSummable` is published on testnet. The contract id,
# document type, and field name below are illustrative only.
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v1": {
      "data_contract_id": "<base64-of-summable-contract-id>",
      "document_type": "inventory",
      "selects": [{ "function": "SUM", "field": "quantity" }],
      "where_clauses": [
        { "field": "warehouse", "operator": "EQUAL", "value": { "text": "north" } }
      ]
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```

:::
::::

**Example Response**

```json
{
  "v1": {
    "data": {
      "sums": {
        "aggregateSum": "42000"
      }
    },
    "metadata": { "height": "5991", "coreChainLockedHeight": 1097384 }
  }
}
```

#### Average documents

:::{versionadded} 4.0.0
:::

Returns a `(count, sum)` pair the client divides to compute the average, or per-group `(count, sum)` pairs when `group_by` is set. Requires the doctype to set `documentsAverageable: "<property>"` (and `rangeAverageable: true` for range-grouped queries). See [aggregate query flags](../protocol-ref/data-contract-document.md#aggregate-query-flags).

Why `(count, sum)` instead of a single `average`? Returning the pair preserves full precision and lets the client pick how to represent the result (integer division, floating-point, decimal).

**Mode-specific request fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `selects` | `[Select{ function: AVG, field: "<prop>" }]` | Yes | `field` must name the averageable property. |
| `group_by` | Repeated string | No | Same shape rules as Count above. |

`limit` follows the same rules as Count: rejected for `group_by=[]` and `group_by=[in_field]`, and `limit: 0` is rejected with `InvalidLimit` in every mode. `start_at` / `start_after` are not valid. See [aggregate query limits](query-syntax.md#aggregate-query-limits).

**Response shape**

- `group_by = []` → `averages.aggregate_average` of `{ count, sum }`.
- `group_by = [...]` → `averages.entries[]` of `{ in_key?, key, count, sum }`.

**Example Request**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl

```shell
# TODO: Replace with a real example once a contract using
# `documentsAverageable` is published on testnet. The contract id,
# document type, and field name below are illustrative only.
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v1": {
      "data_contract_id": "<base64-of-averageable-contract-id>",
      "document_type": "ratings",
      "selects": [{ "function": "AVG", "field": "score" }],
      "where_clauses": [
        { "field": "productId", "operator": "EQUAL", "value": { "text": "abc123" } }
      ]
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```

:::
::::

**Example Response**

```json
{
  "v1": {
    "data": {
      "averages": {
        "aggregateAverage": {
          "count": "50",
          "sum": "215"
        }
      }
    },
    "metadata": { "height": "5991", "coreChainLockedHeight": 1097384 }
  }
}
```

Client computes `avg = 215 / 50 = 4.3`.

#### Ranked documents

:::{versionadded} 4.2.0
Requires protocol version 14.
:::

Returns the top or bottom groups by their aggregate value. A request routes here when it carries an aggregate `selects` projection, exactly one `group_by` property, and exactly one `order_by` clause naming the selected aggregate - the reserved `$count` sentinel for `COUNT(*)`, otherwise the aggregated field.

**Mode-specific request fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `limit` | Integer | Yes | Number of groups to return, between 1 and 100. A larger value is rejected with `InvalidLimit` rather than clamped. |
| `offset` | Integer | No | Number of ranks to skip before the returned page. Counted rather than walked, so there is no ceiling. Combining a non-zero offset with a multi-element `in` prefix pin is rejected with `InvalidLimit`. |

The covering index must declare the matching ranking axis (`rankedCountable`, `rankedSummable`, or `rankedAverageable`). Cursors are rejected, so `offset` is the only ranked pagination. See [Ranked aggregate queries](../reference/query-syntax.md#ranked-aggregate-queries).

The response is carried in `result.data.ranked`, which reports the entries and the skip actually performed - potentially smaller than the requested offset when the groups run out.

#### Having-range documents

:::{versionadded} 4.2.0
Requires protocol version 14.
:::

Returns the groups whose aggregate value falls in a bounded range. A request routes here when it carries an aggregate projection, exactly one `group_by` property, and exactly one `having` clause naming the selected aggregate.

The clause's operator must describe one contiguous range - `EQUAL`, `GREATER_THAN[_OR_EQUALS]`, `LESS_THAN[_OR_EQUALS]`, or a `BETWEEN` variant. `NOT_EQUAL` and `IN` are rejected, as is a multi-clause `having`. `limit` must be between 1 and 100 (`InvalidLimit` otherwise), a missing `group_by` is rejected with `InvalidParameter`, and neither `offset` nor cursors are supported. An `order_by` on the selected aggregate is accepted and flips the walk direction. See [Having-range queries](../reference/query-syntax.md#having-range-queries).

The response is carried in `result.data.ranked`, with no skip reported.

#### Chained documents

:::{versionadded} 4.2.0
No protocol-version gate of its own, but depends in practice on protocol version 14, which admits the `indexOnly` and `refersTo` keywords it requires.
:::

Performs a provable semi-join. Presence of the `chained` message selects this mode: the request's own `document_type`, `where_clauses`, `order_by`, and `limit` describe the **inner** query, and the outer half is derived from the proven inner results rather than sent.

**Mode-specific request fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `chained.join_property` | String | Yes | The inner property whose proven values become the outer documents' `$id`s. |
| `chained.outer_document_type` | String | Yes | The joined document type - the `refersTo` target. |
| `limit` | Integer | Yes | Bounds the derived outer query, so there is no server-default fallback. A value outside 1 to 100 is rejected with `InvalidLimit` rather than clamped. |

The inner document type must be `indexOnly` and resolve to an index carrying the join property; the outer type must not be `indexOnly`. The join property must declare a same-contract `refersTo: permanentDocument` targeting the outer document type, and `selects` must be empty or a single `DOCUMENTS` projection. `group_by`, `having`, time-range clauses, cursors, and `offset` are rejected; paginate with a range clause on the join property. See [Chained queries](../reference/query-syntax.md#chained-queries).

The response is carried in `result.data.chained` as `inner_documents` and `outer_documents`.

A node predating this field ignores it and serves the plain inner query, which fails closed on the client: an inner-only proof cannot satisfy the re-derived merged query.

#### Composite documents

:::{versionadded} 4.2.0
:::

Returns a page plus sub-queries derived from it, answered as one merged proof over a single state root. Presence of any `sub_queries` selects this mode: the request's own contract, document type, clauses, and `limit` describe the **page**, and each sub-query's `IN` clause is derived by the node from the page's - or an earlier sub-query's - proven documents.

**Sub-query fields**

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `data_contract_id` | Bytes | No | The contract targeted. Empty means the page's own contract. |
| `document_type` | String | Yes | The document type queried. |
| `where_clauses` | Typed | No | The fixed clauses - everything but the derived `IN`, which must not be named here. |
| `order_by` | Typed | No | Ordering, documents only. Must agree with the page's direction. |
| `limit` | Integer | No | Required unless the lookup is already value-bounded. A unique index, an `indexOnly` terminal with every prefix fixed, a by-ID join, and a count must not carry one; every other lookup, siblings included, must. |
| `kind` | Enum | Yes | `DOCUMENTS` (the matching documents) or `COUNT` (one count per derived value). |
| `bind` | Typed | No | Where the derived values come from. Absent makes the sub-query a sibling: an independent query proven under the same root. |

**Binding fields**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `source` | Integer | `0` is the page; `n` is `sub_queries[n - 1]`, which must precede this one and be a `DOCUMENTS` sub-query. |
| `source_property` | String | The property read off each source document - `$id`, `$ownerId`, or an identifier-typed property. Dotted paths reach nested properties. |
| `field` | String | The sub-query field receiving the `IN` clause. `$id` makes this a by-ID join, requiring the source property to declare `refersTo: permanentDocument` targeting this document type. |

The page's `limit` is required, and a value outside 1 to 100 is rejected with `InvalidLimit` rather than clamped. `group_by`, `having`, time-range clauses, cursors, and `offset` are rejected, `chained` and `sub_queries` are mutually exclusive, and a request may carry at most 10 sub-queries. See [Composite queries](../reference/query-syntax.md#composite-queries).

The response is carried in `result.data.composite` as `page_documents` plus one `sub_results` entry per sub-query, in request order.

### getDocumentHistory

**Returns**: The revision history for a single document on a contract that keeps document history  
**Parameters**:

| Name | Type | Required | Description |
| ---- | ---- | -------- | ----------- |
| `data_contract_id` | Bytes | Yes | A data contract `id` |
| `document_type_name` | String | Yes | A document type defined by the data contract |
| `document_id` | Bytes | Yes | The `id` of the document whose history is requested |
| `limit` | Integer | No | Maximum number of history entries to return, between 1 and 10. Omitting the field uses the maximum (10); an explicit `0` or a value above 10 is rejected with `InvalidArgument`. |
| `offset` | Integer | No | Number of history entries to skip. Omitted and explicit `0` both start at the first entry. |
| `start_at_ms` | Integer | No | Only return results *after* this time in milliseconds; the bound is exclusive. |
| `prove` | Boolean | No | Set to `true` to receive a proof that contains the requested document history. The data requested will be encoded as part of the proof in the response.|

**Example Request**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `data_contract_id` and `document_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "data_contract_id": "nfpmJoj9R+rFTYLo/ddAuhHA4Si2YlK6BAAvEGmUIdo=",
      "document_type_name": "review",
      "document_id": "wZiWoQCwYKPVjAZ8NDXpbSMb7IEh++hGXzB38niWrIg=",
      "limit": 2,
      "offset": 0,
      "start_at_ms": 0,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocumentHistory
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "documentHistory": {
      "documentEntries": [
        {
          "date": "1782423220252",
          "value": "AsGYlqEAsGCj1YwGfDQ16W0jG+yBIfvoRl8wd/J4lqyIM1bHElsMayy0ZD9WkprWAf6lYDIwqyC8dsdzc++MmRsBAAMAAAGfALPwHAAAAZ8As/AcCGRhc2hub3RlBQEuV2Fsa3Rocm91Z2ggcmV2aWV3IGNyZWF0ZSAyMDI2LTA2LTI1VDIxOjMzOjM1Wg=="
        },
        {
          "date": "1782423230374",
          "value": "AsGYlqEAsGCj1YwGfDQ16W0jG+yBIfvoRl8wd/J4lqyIM1bHElsMayy0ZD9WkprWAf6lYDIwqyC8dsdzc++MmRsCAAMAAAGfALPwHAAAAZ8AtBemCGRhc2hub3RlBQEsV2Fsa3Rocm91Z2ggcmV2aWV3IGVkaXQgMjAyNi0wNi0yNVQyMTozMzo0NVo="
        }
      ]
    },
    "metadata": {
      "height": "375045",
      "coreChainLockedHeight": 1506013,
      "epoch": 17082,
      "timeMs": "1782851061688",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

## Contract Moderation Endpoints

:::{versionadded} 5.0.0
:::

Contract moderation, introduced in protocol version 14, lets a data contract declare moderation
rules in its config. A moderated contract can keep up to three lists of identities: a
**banlist** (barred until unbanned), a **suspension list** (barred until a given block time), and
a **warning list** (a record of warnings that bars nothing). A banned identity, or one with an
active suspension, cannot submit document transitions for the contract. Document types can also
let moderators delete documents; by default each deletion leaves a removal record, and the
document can be restored within 7 days. A contract's moderators are its owner, a set of
identities the contract appoints, or a team elected by masternodes. Once seated, an elected team
can jointly delete settled documents through proposals and approvals, and each member's
moderation actions are counted toward a share of the contract's moderators fee pot.

The endpoints in this section read that state. The contract must keep the data being queried.
Querying a moderation list the contract doesn't keep, a document type whose deletions keep no
records, or team actions or action counts that the contract doesn't track is rejected with
`InvalidArgument`. A contract that doesn't exist returns `NotFound`.

### getContractModerationStatus

Returns an identity's status on one or more moderation lists of a moderated data contract: whether it is banned, until when it is suspended, and which warnings it carries.

**Returns**: The identity's status on the requested lists, or a cryptographic proof.

**Parameters**:

| Name          | Type    | Required | Description |
|---------------|---------|----------|-------------|
| `contract_id` | Bytes   | Yes      | The 32-byte ID of the moderated data contract |
| `identity_id` | Bytes   | Yes      | The 32-byte ID of the identity to check |
| `lists`       | Array of enums | Yes | The lists to read: `CONTRACT_MODERATION_LIST_BANLIST = 1`, `CONTRACT_MODERATION_LIST_SUSPENSIONS = 2`, or `CONTRACT_MODERATION_LIST_WARNINGS = 3`. Name at least one list, with no repeats. Each list must be one the contract keeps. `CONTRACT_MODERATION_LIST_UNSPECIFIED = 0` is rejected |
| `prove`       | Boolean | No       | Set to `true` to receive a proof of the identity's entry, present or absent, on each requested list |

A request is rejected with `InvalidArgument` if `lists` is empty, names a list twice, or names a
list the contract doesn't keep, or if the contract isn't moderated.

**Response Object**

The status covers only the lists named in the request. Fields for a list that wasn't read are
left unset rather than reported as empty.

| Name | Type | Description |
|------|------|-------------|
| `status.lists` | Array of enums | The lists this status covers, as named in the request |
| `status.banned` | Boolean (optional) | Set only when the banlist was read: `true` if the identity is on it |
| `status.ban_reason` | Object (optional) | Set when the identity is banned. See [Moderation reason fields](#moderation-reason-fields) |
| `status.suspended_until` | UInt64 (optional) | The block time, in milliseconds, at which the identity's suspension lapses. Unset when the identity isn't suspended or the suspension list wasn't read. A lapsed suspension stays on the list until the identity's next document transition or an unsuspend removes it, so compare this value with the current block time to tell whether the suspension is still in effect |
| `status.suspension_reason` | Object (optional) | Set when the identity is suspended. See [Moderation reason fields](#moderation-reason-fields) |
| `status.warnings` | Array | When the warning list was read, the identity's warnings, oldest first. Each has `warned_at` (the block time of the warning, in milliseconds) and a `reason`. Empty when the identity carries no warnings or the warning list wasn't read; use `status.lists` to tell the two apart |
| `metadata` | Object | Metadata about the blockchain state. See [metadata details](#data-proofs-and-metadata) for complete information |

#### Moderation reason fields

Every ban, suspension, warning, document removal, and team action carries a reason. Platform
doesn't check what a moderator writes, and the documents a reason cites aren't looked up.

| Name | Type | Description |
|------|------|-------------|
| `code` | UInt32 (optional) | Reserved for ban codes that contracts may declare in a later protocol version. Expected to be unset; not validated |
| `text` | String | Free-text reason, up to 1024 bytes of UTF-8. May be empty |
| `documents` | Array | Up to 16 documents on the moderated contract that the reason is about, each with a `document_type_name` and a 32-byte `document_id`. No document is listed twice |
| `reason_document_id` | Bytes (optional) | The 32-byte ID of a `reason` document in the moderation charters system contract. For an action by a seated elected team, it must be a reason listed by the team's proposal; otherwise it isn't checked |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a moderated contract is
# published on testnet. The IDs and values below are illustrative only.
# `contract_id` and `identity_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "<base64-of-moderated-contract-id>",
      "identity_id": "<base64-of-identity-id>",
      "lists": [
        "CONTRACT_MODERATION_LIST_BANLIST",
        "CONTRACT_MODERATION_LIST_SUSPENSIONS",
        "CONTRACT_MODERATION_LIST_WARNINGS"
      ],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractModerationStatus
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "status": {
      "banned": false,
      "suspendedUntil": "1793232000000",
      "lists": [
        "CONTRACT_MODERATION_LIST_BANLIST",
        "CONTRACT_MODERATION_LIST_SUSPENSIONS",
        "CONTRACT_MODERATION_LIST_WARNINGS"
      ],
      "suspensionReason": {
        "text": "flooding"
      },
      "warnings": [
        {
          "warnedAt": "1792800000000",
          "reason": {
            "text": "first strike"
          }
        }
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "protocolVersion": 14
    }
  }
}
```
:::
::::

### getContractModerationEntries

Returns one page of a moderated contract's banlist, suspension list, or warning list, in identity ID order.

**Returns**: A page of list entries, or a cryptographic proof.

**Parameters**:

| Name          | Type    | Required | Description |
|---------------|---------|----------|-------------|
| `contract_id` | Bytes   | Yes      | The 32-byte ID of the moderated data contract |
| `list`        | Enum    | Yes      | The list to read: `CONTRACT_MODERATION_LIST_BANLIST = 1`, `CONTRACT_MODERATION_LIST_SUSPENSIONS = 2`, or `CONTRACT_MODERATION_LIST_WARNINGS = 3`. Must be a list the contract keeps. `CONTRACT_MODERATION_LIST_UNSPECIFIED = 0` is rejected |
| `start_after` | Bytes   | No       | A 32-byte identity ID. The page starts after this identity (exclusive) |
| `limit`       | UInt32  | No       | Maximum number of entries to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested page |

To read the next page, pass the last `identity_id` returned as `start_after`. A page with fewer
entries than the limit is the last one.

**Response Object**

| Name | Type | Description |
|------|------|-------------|
| `entries.entries` | Array | The page of entries, in identity ID order |
| `entries.entries[]`<br>`.identity_id` | Bytes | The identity on the list |
| `entries.entries[]`<br>`.until` | UInt64 (optional) | Suspension list only: the block time, in milliseconds, at which the suspension lapses. A lapsed suspension stays listed until it is removed |
| `entries.entries[]`<br>`.reason` | Object | Banlist and suspension list only: why the identity is on the list. Unset for warning list entries. See [Moderation reason fields](#moderation-reason-fields) |
| `entries.entries[]`<br>`.warnings` | Array | Warning list only: every warning the identity carries, oldest first, each with `warned_at` and `reason`. The latest warning is why the identity is on the list |
| `metadata` | Object | Metadata about the blockchain state. See [metadata details](#data-proofs-and-metadata) for complete information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a moderated contract is
# published on testnet. The IDs and values below are illustrative only.
# `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "<base64-of-moderated-contract-id>",
      "list": "CONTRACT_MODERATION_LIST_BANLIST",
      "limit": 2,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractModerationEntries
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "entries": {
      "entries": [
        {
          "identityId": "<base64-of-identity-id-1>",
          "reason": {
            "text": "spam"
          }
        },
        {
          "identityId": "<base64-of-identity-id-2>",
          "reason": {
            "text": "impersonation",
            "documents": [
              {
                "documentTypeName": "post",
                "documentId": "<base64-of-document-id>"
              }
            ]
          }
        }
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "protocolVersion": 14
    }
  }
}
```
:::
::::

### getContractDocumentRemovals

Returns the removal records of documents that a contract's moderators deleted from one document type, either for specific document IDs or as a page in document ID order. A record shows who removed the document, when, and why, and whether it has since been restored.

**Returns**: A list of document removal records, or a cryptographic proof.

**Parameters**:

| Name                 | Type    | Required | Description |
|----------------------|---------|----------|-------------|
| `contract_id`        | Bytes   | Yes      | The 32-byte ID of the moderated data contract |
| `document_type_name` | String  | Yes      | A document type whose moderator deletions keep records: one that sets `moderatorAbilities.delete` without turning off `deleteKeepsRecord` |
| `document_ids`       | Object  | No\*     | Select the records of specific documents |
| `document_ids.`<br>`document_ids` | Array of bytes | Yes | 32-byte document IDs, from 1 to 100, with no repeats. An ID with no removal record is left out of the response, and proved absent when a proof is requested |
| `page`               | Object  | No\*     | Select one page of the type's records, in document ID order |
| `page.start_after`   | Bytes   | No       | A 32-byte document ID. The page starts after this document (exclusive) |
| `page.limit`         | UInt32  | No       | Maximum number of records to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`              | Boolean | No       | Set to `true` to receive a proof that contains the requested records |

\* Exactly one of `document_ids` or `page` must be set. A request with neither is rejected with
`InvalidArgument`, as is a request for a document type that doesn't exist or doesn't keep
removal records.

**Response Object**

| Name | Type | Description |
|------|------|-------------|
| `removals.removals` | Array | The removal records, in document ID order |
| `removals.removals[]`<br>`.document_id` | Bytes | The ID of the removed document |
| `removals.removals[]`<br>`.document_owner_id` | Bytes | The identity that owned the document |
| `removals.removals[]`<br>`.moderator_id` | Bytes | The contract owner or moderator that removed it |
| `removals.removals[]`<br>`.removed_at` | UInt64 | The block time of the removal, in milliseconds |
| `removals.removals[]`<br>`.reason` | Object | Why the moderator removed it. See [Moderation reason fields](#moderation-reason-fields) |
| `removals.removals[]`<br>`.document_hash` | Bytes | A 32-byte double SHA-256 of the document as serialized under its document type when it was removed. A restore must supply a document that matches it byte for byte |
| `removals.removals[]`<br>`.restoration` | Object (optional) | Set once a moderator has restored the document, which is then live again. Contains `moderator_id` (who restored it) and `restored_at` (the block time of the restore, in milliseconds). Absent while the removal stands |
| `removals.removals[]`<br>`.kept_fields` | Bytes | The values the record keeps for the paths listed in the document type's `moderatorAbilities.deleteKeepsFields`, in that order. Each path is encoded as `0` when the document held no value there, or `1` followed by the value encoded the way the document encodes its properties. Decode it using the contract's document type. Empty when the type keeps no fields |
| `metadata` | Object | Metadata about the blockchain state. See [metadata details](#data-proofs-and-metadata) for complete information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a moderated contract is
# published on testnet. The IDs and values below are illustrative only.
# `contract_id` and `document_ids` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "<base64-of-moderated-contract-id>",
      "document_type_name": "post",
      "document_ids": {
        "document_ids": ["<base64-of-document-id>"]
      },
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractDocumentRemovals
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "removals": {
      "removals": [
        {
          "documentId": "<base64-of-document-id>",
          "documentOwnerId": "<base64-of-owner-identity-id>",
          "moderatorId": "<base64-of-moderator-identity-id>",
          "removedAt": "1792800000000",
          "reason": {
            "text": "off-topic"
          },
          "documentHash": "<base64-of-32-byte-document-hash>"
        }
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "protocolVersion": 14
    }
  }
}
```
:::
::::

### getContractTeamActions

Returns one page of the actions that an elected contract's seated moderation team is voting on (active) or has carried out (closed), in action ID order. One member proposes an action, other members approve it, and it runs once the approvals meet the document type's rule. Currently the only action is deleting a settled document: one past its document type's `deleteWithin` window, which the type's `moderatorAbilities.deleteSettled` rule lets the team delete together.

**Returns**: A list of team actions, or a cryptographic proof.

**Parameters**:

| Name                 | Type    | Required | Description |
|----------------------|---------|----------|-------------|
| `contract_id`        | Bytes   | Yes      | The 32-byte ID of the elected contract. At least one of its document types must set `moderatorAbilities.deleteSettled` |
| `status`             | Enum    | No       | `ACTIVE = 0` (still gathering approvals) or `CLOSED = 1` (approvals met the rule and the action ran). Omitting the field selects `ACTIVE` |
| `start_at_action_id` | Object  | No       | Where the page starts. Omit to start at the first action |
| `start_at_action_id.`<br>`start_action_id` | Bytes | Yes | The 32-byte action ID to start from |
| `start_at_action_id.`<br>`start_action_id_included` | Boolean | No | Whether the page includes the start action |
| `count`              | UInt32  | No       | Maximum number of actions to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`              | Boolean | No       | Set to `true` to receive a proof that contains the requested actions |

A request for a contract with no document type that sets `moderatorAbilities.deleteSettled` is
rejected with `InvalidArgument`.

**Response Object**

| Name | Type | Description |
|------|------|-------------|
| `actions.actions` | Array | The actions, in action ID order |
| `actions.actions[]`<br>`.action_id` | Bytes | The 32-byte ID of the action |
| `actions.actions[]`<br>`.proposer_id` | Bytes | The team member that proposed it |
| `actions.actions[]`<br>`.proposed_at` | UInt64 | The block time of the proposal, in milliseconds |
| `actions.actions[]`<br>`.delete_settled_document` | Object | The settled document the action deletes |
| `actions.actions[]`<br>`.delete_settled_document`<br>`.document_type_name` | String | The document's type |
| `actions.actions[]`<br>`.delete_settled_document`<br>`.document_id` | Bytes | The 32-byte ID of the document |
| `actions.actions[]`<br>`.delete_settled_document`<br>`.document_last_modified_at` | UInt64 | The document's `$updatedAt` (or `$createdAt`) when the action was proposed. Approvals apply to the document as it was then |
| `actions.actions[]`<br>`.delete_settled_document`<br>`.document_revision` | UInt64 (optional) | The document's `$revision` when the action was proposed. Absent for types whose documents carry no revision. An approval is refused if the document has changed since |
| `actions.actions[]`<br>`.delete_settled_document`<br>`.reason` | Object | Why, as given by the proposer. See [Moderation reason fields](#moderation-reason-fields) |
| `actions.actions[]`<br>`.approval_count` | UInt32 | The number of approvals the action holds, including the proposer's. For an active action this is an upper bound: an approval from a member who has since left the team is only dropped when a later approval is processed. For the exact figure, get the action's signers with [`getContractTeamActionSigners`](#getcontractteamactionsigners) and count those still on the team |
| `metadata` | Object | Metadata about the blockchain state. See [metadata details](#data-proofs-and-metadata) for complete information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once an elected contract with a
# seated moderation team is published on testnet. The IDs and values
# below are illustrative only.
# `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "<base64-of-elected-contract-id>",
      "status": 0,
      "count": 10,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractTeamActions
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "actions": {
      "actions": [
        {
          "actionId": "<base64-of-action-id>",
          "proposerId": "<base64-of-member-identity-id>",
          "proposedAt": "1792800000000",
          "deleteSettledDocument": {
            "documentTypeName": "post",
            "documentId": "<base64-of-document-id>",
            "documentLastModifiedAt": "1790000000000",
            "documentRevision": "2",
            "reason": {
              "text": "doxxing"
            }
          },
          "approvalCount": 2
        }
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "protocolVersion": 14
    }
  }
}
```
:::
::::

### getContractTeamActionSigners

Returns the team members that approved one of the actions an elected contract's seated moderation team votes on.

**Returns**: The IDs of the members that approved the action, or a cryptographic proof.

**Parameters**:

| Name          | Type    | Required | Description |
|---------------|---------|----------|-------------|
| `contract_id` | Bytes   | Yes      | The 32-byte ID of the elected contract. At least one of its document types must set `moderatorAbilities.deleteSettled` |
| `status`      | Enum    | No       | Whether the action is `ACTIVE = 0` or `CLOSED = 1`. Omitting the field selects `ACTIVE` |
| `action_id`   | Bytes   | Yes      | The 32-byte ID of the action |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested approvals |

The response's `signers.signer_ids` lists the 32-byte IDs of the approving members in ID order.
The proposer is included unless it has left the team and its approval was dropped. The list is
empty when there is no action with that ID and status.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once an elected contract with a
# seated moderation team is published on testnet. The IDs below are
# illustrative only.
# `contract_id` and `action_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "<base64-of-elected-contract-id>",
      "status": 0,
      "action_id": "<base64-of-action-id>",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractTeamActionSigners
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "signers": {
      "signerIds": [
        "<base64-of-member-identity-id-1>",
        "<base64-of-member-identity-id-2>"
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "protocolVersion": 14
    }
  }
}
```
:::
::::

### getContractModerationActionCounts

Returns how many counted moderation actions (bans, suspensions, warnings, and document deletions) each member of an elected contract's seated moderation team has signed since the moderators fee pot was last settled. These counts set each member's part of the action share when the pot is paid out. A payout resets every count, and so does a change to the team.

**Returns**: The action count of each member, or a cryptographic proof.

**Parameters**:

| Name          | Type    | Required | Description |
|---------------|---------|----------|-------------|
| `contract_id` | Bytes   | Yes      | The 32-byte ID of a contract whose moderators are an elected team |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested counts |

The response isn't paginated: it returns every count, which the team's size bounds. A request
for a contract whose moderators aren't an elected team is rejected with `InvalidArgument`.

The response's `counts.counts` lists one entry per member, in identity ID order, each with the
member's `identity_id` and `count` (UInt32). A member that hasn't signed a counted action since
the last settlement has no entry.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once an elected contract with a
# seated moderation team is published on testnet. The IDs and values
# below are illustrative only.
# `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "<base64-of-elected-contract-id>",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractModerationActionCounts
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "counts": {
      "counts": [
        {
          "identityId": "<base64-of-member-identity-id-1>",
          "count": 12
        },
        {
          "identityId": "<base64-of-member-identity-id-2>",
          "count": 3
        }
      ]
    },
    "metadata": {
      "height": "5991",
      "coreChainLockedHeight": 1097384,
      "protocolVersion": 14
    }
  }
}
```
:::
::::

## Identity Endpoints

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
const client = new DAPIClient({ network: 'testnet' });

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

`balanceAndRevision` also carries a `revision` field. The example above was captured for an identity
at revision `0`, and proto3 omits zero-valued scalars from JSON output, so the field does not appear.
An identity that has been updated returns it alongside `balance`, quoted as a string.

### getIdentityByNonUniquePublicKeyHash

:::{versionadded} 2.0.0
:::

**Returns**: One or more [identities](../explanations/identity.md) associated with a public key
hash, including non-unique masternode keys.

:::{note}
Unlike [`getIdentityByPublicKeyHash`](#getidentitybypublickeyhash), this endpoint supports public
key hashes that may be associated with multiple identities, such as masternode voting keys. Use the
`start_after` parameter to paginate through results.
:::

**Parameters**:

| Name             | Type   | Required | Description |
| ---------------- | ------ | -------- | ----------- |
| `public_key_hash`| Bytes  | Yes      | Public key hash (sha256-ripemd160) to search for |
| `start_after`    | Bytes  | No       | Identity ID to start after (for pagination) |
| `prove`          | Boolean| No       | Set to `true` to receive a proof that contains the requested identity |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# `public_key_hash` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "public_key_hash": "uNFZGqdNRA4K+cC+FsVbvBQYR/c="
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityByNonUniquePublicKeyHash
```
:::
::::

::::{tab-set}
:::{tab-item} Response (identity)
```json
{
  "v0": {
    "identity": {
      "identity": "ADASwZuY7AAzrds2zWS39RBnDyo1GkMEtfaZQUQobv2sAgAAAAAAAAAAIQCgUViOvLoIUc3Ibd9YqICX+1+xQz+fdYxRkyZPslTrBzQABAAEAAgAAACECA+Zn..."
    },
    "metadata": {
      "height": "7242",
      "coreChainLockedHeight": 927815,
      "epoch": 855,
      "timeMs": "1702012386543",
      "protocolVersion": 1,
      "chainId": "dash-testnet-37"
    }
  }
}
```
:::

::::

### getIdentityByPublicKeyHash

**Returns**: An [identity](../explanations/identity.md) associated with the provided public key hash

:::{note}
This endpoint only works for unique keys. Since masternode keys do not have to be unique
(e.g., voting keys), some masternode identities cannot be retrieved using this endpoint. See
[`getIdentityByNonUniquePublicKeyHash`](#getidentitybynonuniquepublickeyhash) for masternode
identities.
:::

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
const client = new DAPIClient({ network: 'testnet' });

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
| `identity_id`  | Bytes | Yes | An identity ID<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids)
| `request_type` | [KeyRequestType](#request-types) | Yes | Request all keys (`all_keys`), specific keys (`specific_keys`), search for keys (`search_key`)
| `limit` | Integer  | No      | The maximum number of keys to return. Values above 100 are rejected with `InvalidLimit` |
| `offset` | Integer | No      | The offset for pagination through the keys |
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

To search for identity keys, use the `search_key` request type. The options for `security_level_map` are "CURRENT_KEY_OF_KIND_REQUEST" and "ALL_KEYS_OF_KIND_REQUEST":

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

### getIdentityKeysRemainingBudgets

:::{versionadded} 5.0.0
:::

Returns what is left of the credit budgets of an identity's keys. From protocol version 14, a
non-master authentication key can carry a total credit budget (see [Identity
keys](../explanations/identity.md#keys)). The key itself never changes, so the remaining budget is
tracked separately and read with this endpoint.

**Returns**: One entry per requested key, in key ID order, or a cryptographic proof. Each entry
contains the `key_id` and its `remaining_budget` in credits. `remaining_budget` is absent when the
key has no budget, or when the key or identity does not exist. A `remaining_budget` of `0` means
the key can no longer sign transitions.

**Parameters**:

| Name          | Type    | Required | Description |
| ------------- | ------- | -------- | ----------- |
| `identity_id` | Bytes   | Yes      | An identity ID. An ID that is not 32 bytes is rejected with `InvalidArgument` |
| `key_ids`     | Array   | Yes      | An array of key IDs to look up. At least one and at most 100 IDs, with no repeats; an empty array or a repeated ID is rejected with `InvalidArgument`, and more than 100 returns `InvalidLimit` |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested remaining budgets |

Key budgets only exist from protocol version 14. On earlier protocol versions, the endpoint returns
an error instead of a result.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once Dash Platform v5.0 is deployed on
# testnet. The response values below are illustrative only.
# `identity_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
      "key_ids": [2, 5],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityKeysRemainingBudgets
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "keysRemainingBudgets": {
      "entries": [
        {
          "keyId": 2
        },
        {
          "keyId": 5,
          "remainingBudget": "750000"
        }
      ]
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
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
const client = new DAPIClient({ network: 'testnet' });

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
| `ids`     | Array   | No       | An array of identity IDs for which balances are requested. At most 100 IDs per call; more returns `InvalidLimit`<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
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
          "identityId": "jspLy7OhJKsoOv1C2tO9sgd7OAlll4ig8dr/zlufAB8=",
          "balance": "1000000"
        },
        {
          "identityId": "dUuJ2ujbIPxM7l462wexRtfv5Qimb6Co4QlGdbnao14=",
          "balance": "2500000"
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
| `identities_ids`     | Array                   | Yes      | An array of identity IDs. At most 100 IDs per call; more returns `InvalidLimit`<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
| `contract_id`        | Bytes                   | Yes      | The ID of the contract |
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

## Security Group Endpoints

:::{versionadded} 2.0.0
:::

Security groups provide a way to distribute token configuration and update authorization across multiple identities. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action. The endpoints in this section are used to retrieve information about groups and the actions they are performing.

### getGroupInfo

Retrieves information about a specific group within a contract, including its members and required power.

**Returns**: Group information containing member details and required power, or a cryptographic proof.

**Parameters**:

| Name                     | Type     | Required | Description |
|--------------------------|---------|----------|-------------|
| `contract_id`            | Bytes   | Yes      | The ID of the contract containing the group |
| `group_contract_position` | UInt32  | Yes      | The position of the group within the contract |
| `prove`                  | Boolean | No       | Set to `true` to receive a proof that contains the requested group information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "group_contract_position": 1,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getGroupInfo
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "group_info": {
      "group_info": {
        "members": [
          {
            "member_id": "01abcdef",
            "power": 5
          },
          {
            "member_id": "02abcdef",
            "power": 10
          }
        ],
        "group_required_power": 15
      }
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

### getGroupInfos

Retrieves information about multiple groups within a contract, including their members and required power.

**Returns**: A list of group information entries or a cryptographic proof.

**Parameters**:

| Name                                      | Type     | Required | Description |
|-------------------------------------------|---------|----------|-------------|
| `contract_id`                             | Bytes   | Yes      | The ID of the contract containing the groups |
| `start_at_group_contract_position`        | Object  | No       | Filtering options for retrieving groups |
| `start_at_group_contract_position`<br>`.start_group_contract_position` | UInt32  | No       | The position of the first group to retrieve |
| `start_at_group_contract_position`<br>`.start_group_contract_position_included` | Boolean | No       | Whether the start position should be included in the results |
| `count`                                   | UInt32  | No       | The maximum number of groups to retrieve. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`                                   | Boolean | No       | Set to `true` to receive a proof that contains the requested group information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "start_at_group_contract_position": {
        "start_group_contract_position": 1,
        "start_group_contract_position_included": true
      },
      "count": 5,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getGroupInfos
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "group_infos": {
      "group_infos": [
        {
          "group_contract_position": 1,
          "members": [
            {
              "member_id": "01abcdef",
              "power": 5
            },
            {
              "member_id": "02abcdef",
              "power": 10
            }
          ],
          "group_required_power": 15
        },
        {
          "group_contract_position": 2,
          "members": [
            {
              "member_id": "03abcdef",
              "power": 8
            },
            {
              "member_id": "04abcdef",
              "power": 12
            }
          ],
          "group_required_power": 20
        }
      ]
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

### getGroupActions

Retrieves a list of actions performed by a specific group within a contract.

**Parameters**:

| Name                              | Type     | Required | Description |
|-----------------------------------|---------|----------|-------------|
| `contract_id`                     | Bytes   | Yes      | The ID of the contract containing the group |
| `group_contract_position`         | UInt32  | Yes      | The position of the group within the contract |
| `status`                          | Enum    | Yes      | The status of the actions to retrieve (`ACTIVE = 0`, `CLOSED = 1`) |
| `start_at_action_id`              | Object  | No       | Filtering options for retrieving actions |
| `start_at_action_id.`<br>`start_action_id` | Bytes  | No       | The action ID to start retrieving from |
| `start_at_action_id.`<br>`start_action_id_included` | Boolean | No | Whether the start action should be included in the results |
| `count`                           | UInt32  | No       | The maximum number of actions to retrieve. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`                           | Boolean | No       | Set to `true` to receive a proof that contains the requested group actions |

**Returns**: A list of group actions or a cryptographic proof. The response message contains details about actions performed by a group, including various event types related to token operations, document updates, contract updates, and emergency actions. The list of possible actions is shown in the table below:

| Event Type        | Subtype                     | Description |
|-------------------|---------------------------|-------------|
| **TokenEvent**    | `mint`                     | Mints new tokens to a specified recipient. |
|                   | `burn`                     | Burns (destroys) a specified amount of tokens. |
|                   | `freeze`                   | Freezes a specific entity's tokens. |
|                   | `unfreeze`                 | Unfreezes a specific entity's tokens. |
|                   | `destroy_frozen_funds`     | Destroys frozen funds for a specified entity. |
|                   | `emergency_action`         | Performs emergency actions like pausing or resuming the contract. |
|                   | `token_config_update`      | Updates token configuration settings. |
|                   | `update_price`             | Updates the token's direct purchase price (fixed or tiered). |
| **DocumentEvent** | `create`                   | Represents the creation of a document. |
| **ContractEvent** | `update`                   | Represents updates to a contract. |

**Response Object**

| Name                | Type      | Description |
|---------------------|----------|-------------|
| `group_actions`    | Object   | Contains a list of group actions |
| `group_actions.group_actions` | Array of `GroupActionEntry` | A list of actions performed by the group |
| `group_actions.group_actions[]`<br>`.action_id` | Bytes  | Unique identifier for the action |
| `group_actions.group_actions[]`<br>`.event` | Object  | The event data associated with the action |
| `group_actions.group_actions[]`<br>`.event.event_type` | Object  | The specific type of event |
| `group_actions.group_actions[]`<br>`.event.event_type.token_event` | Object  | Token-related event details (if applicable). See [Token Event details](#token-event-fields) below for complete information. |
| `group_actions.group_actions[]`<br>`.event.event_type.document_event` | Object  | Document-related event details |
| `group_actions.group_actions[]`<br>`.event.event_type.document_event`<br>`.create` | Object  | Document creation event details |
| `group_actions.group_actions[]`<br>`.event.event_type.document_event`<br>`.create.created_document` | Bytes | Created document data |
| `group_actions.group_actions[]`<br>`.event.event_type.contract_event` | Object  | Contract-related event details |
| `group_actions.group_actions[]`<br>`.event.event_type.contract_event`<br>`.update` | Object  | Contract update event details |
| `group_actions.group_actions[]`<br>`.event.event_type.contract_event`<br>`.update.updated_contract` | Bytes | Updated contract data |
| `metadata` | Object  | Metadata about the blockchain state. See [metadata details](#data-proofs-and-metadata) for complete information |

#### Token Event Fields

| Token Event Type | Field Name | Type | Description |
|-----------------|------------|------|-------------|
| `mint`   | `amount` | UInt64 | Amount of tokens to mint. |
|          | `recipient_id` | Bytes | Identity ID of the recipient. |
|          | `public_note` | String (Optional) | A public note for the mint event. |
| `burn`   | `amount` | UInt64 | Amount of tokens to burn. |
|          | `burn_from_id` | Bytes | Identity ID the tokens are burned from. |
|          | `public_note` | String (Optional) | A public note for the burn event. |
| `freeze` | `frozen_id` | Bytes | Identifier of the entity being frozen. |
|          | `public_note` | String (Optional) | A public note for the freeze event. |
| `unfreeze` | `frozen_id` | Bytes | Identifier of the entity being unfrozen. |
|          | `public_note` | String (Optional) | A public note for the unfreeze event. |
| `destroy_frozen_funds` | `frozen_id` | Bytes | Identifier of the frozen entity. |
|          | `amount` | UInt64 | Amount of frozen funds to destroy. |
|          | `public_note` | String (Optional) | A public note for the destruction event. |
| `emergency_action` | `action_type` | Enum (`PAUSE = 0`, `RESUME = 1`) | Type of emergency action performed. |
|           | `public_note` | String (Optional) | A public note for the emergency action. |
| `token_config_update` | `token_config_`<br>`update_item` | Bytes | Configuration update details. |
|           | `public_note` | String (Optional) | A public note for the configuration update. |
| `update_price` | `fixed_price` | UInt64 | Fixed direct purchase price (present when a fixed price is set). |
|           | `variable_price` | Object | Tiered pricing schedule (`price_for_quantity` array of `{quantity, price}`), present when tiered pricing is set. |
|           | `public_note` | String (Optional) | A public note for the price update event. |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "group_contract_position": 1,
      "status": 0,
      "start_at_action_id": {
        "start_action_id": "01abcdef",
        "start_action_id_included": true
      },
      "count": 5,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getGroupActions
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "group_actions": {
      "group_actions": [
        {
          "action_id": "01abcdef",
          "event": {
            "event_type": {
              "token_event": {
                "mint": {
                  "amount": "1000",
                  "recipient_id": "02abcdef",
                  "public_note": "Minting 1000 tokens"
                }
              }
            }
          }
        },
        {
          "action_id": "02abcdef",
          "event": {
            "event_type": {
              "token_event": {
                "burn": {
                  "amount": "500",
                  "public_note": "Burning 500 tokens"
                }
              }
            }
          }
        }
      ]
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

### getGroupActionSigners

Retrieves the signers for a specified group action within a contract, along with their assigned power.

**Returns**: A list of group action signers or a cryptographic proof.

**Parameters**

| Name                      | Type     | Required | Description |
|---------------------------|---------|----------|-------------|
| `contract_id`             | Bytes   | Yes      | The ID of the contract containing the group action. |
| `group_contract_position` | UInt32  | Yes      | The position of the group within the contract. |
| `status`                  | Enum    | Yes      | The status of the action (`ACTIVE = 0`, `CLOSED = 1`). |
| `action_id`               | Bytes   | Yes      | The unique identifier of the action. |
| `prove`                   | Boolean | No       | Set to `true` to receive a proof that contains the requested group action signers. |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "group_contract_position": 1,
      "status": 0,
      "action_id": "01abcdef",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getGroupActionSigners
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "group_action_signers": {
      "signers": [
        {
          "signer_id": "01abcdef",
          "power": 5
        },
        {
          "signer_id": "02abcdef",
          "power": 10
        }
      ]
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

## Contract Group Endpoints

:::{versionadded} 5.0.0
:::

From protocol version 14, [contract groups](../explanations/platform-protocol-data-contract.md#contract-groups)
organize data contracts, document types, and tokens into an identity-owned collection, which
[authentication keys](../explanations/identity.md#keys) can be scoped to. A contract group is
registered by a data contract create transition and has its own 32-byte ID, an owner identity,
optional admins who may add members alongside the owner, and an optional name and description.
Contracts created by the owner or an admin can add themselves, one of their document types, or one
of their tokens to the group.

Contract groups are not the same as the token [security groups](#security-group-endpoints) returned
by `getGroupInfo` and related endpoints. Security groups are defined inside a data contract at a
numeric position, and their members are identities with voting power that jointly authorize token
actions. Contract groups exist independently of any one contract, and their members are contracts,
document types, and tokens.

### getContractGroupInfo

Retrieves the stored information of a contract group: its owner, admins, name, and description.

**Returns**: The group's information, or a cryptographic proof. The `contract_group_info` result
contains the `owner_id`, the `admin_ids` (empty when the owner is the only identity that can add
members), and the optional `name` and `description`. When no group has the requested ID, the
response contains no result rather than a `NotFound` error. A proof covers the group's information
or its absence.

**Parameters**:

| Name                | Type    | Required | Description |
| ------------------- | ------- | -------- | ----------- |
| `contract_group_id` | Bytes   | Yes      | The 32-byte ID of the contract group. An ID that is not 32 bytes is rejected with `InvalidArgument` |
| `prove`             | Boolean | No       | Set to `true` to receive a proof that contains the requested group information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a contract group is registered on
# testnet. The request and response values below are illustrative only.
# `contract_group_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_group_id": "<base64-of-contract-group-id>",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractGroupInfo
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "contractGroupInfo": {
      "ownerId": "HxUSbKaFxbuvTUprfr5a0yU6u4EasTdSWvSxOwKjmxw=",
      "adminIds": [
        "NBgQk65dTNttDYDGLZNLrb1QEAWB91jqkqXtK1KU4Dc="
      ],
      "name": "Example apps",
      "description": "Contracts published by the example team"
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getContractGroupMembers

Retrieves one page of a contract group's members of a single kind: member contracts, member document
types, or member tokens.

**Returns**: One page of members of the requested kind, or a cryptographic proof:

- `contracts`: member contract IDs, in contract ID order
- `document_types`: member document types (`contract_id` and `document_type_name`), in contract ID then document type name order
- `tokens`: member tokens (`contract_id` and `token_position`), in contract ID then token position order

A group that does not exist, or that has no members of the requested kind after the cursor, returns
an empty page.

**Parameters**:

| Name                | Type    | Required | Description |
| ------------------- | ------- | -------- | ----------- |
| `contract_group_id` | Bytes   | Yes      | The 32-byte ID of the contract group. An ID that is not 32 bytes is rejected with `InvalidArgument` |
| `contracts`         | Object  | Yes      | Request member contracts. Optional `start_after`: a 32-byte contract ID; the page starts after it |
| `document_types`    | Object  | Yes      | Request member document types. Optional `start_after`: a `{contract_id, document_type_name}` pair; the page starts after it |
| `tokens`            | Object  | Yes      | Request member tokens. Optional `start_after`: a `{contract_id, token_position}` pair; the page starts after it. `token_position` must fit in 16 bits |
| `limit`             | Integer | No       | Maximum number of members to return, from 1 to 100. Omit to return up to 100. `0` or a value above 100 is rejected with `InvalidLimit`. The default and maximum are protocol constants, not node settings |
| `prove`             | Boolean | No       | Set to `true` to receive a proof that contains the requested page |

Exactly one of `contracts`, `document_types`, or `tokens` must be set; a request with none is
rejected with `InvalidArgument`. An invalid cursor (a contract ID that is not 32 bytes or a token
position above 65,535) is also rejected with `InvalidArgument`. To fetch the next page, pass the last
returned member as `start_after`.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a contract group is registered on
# testnet. The request and response values below are illustrative only.
# `contract_group_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_group_id": "<base64-of-contract-group-id>",
      "document_types": {},
      "limit": 10,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractGroupMembers
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "documentTypes": {
      "documentTypes": [
        {
          "contractId": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
          "documentTypeName": "note"
        }
      ]
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getContractGroupsForContract

Retrieves the contract groups a data contract belongs to, whether as a whole contract, through its
document types, or through its tokens.

**Returns**: The contract's group memberships, or a cryptographic proof. The
`contract_group_memberships` result contains:

- `contract_group_ids`: the groups the whole contract belongs to
- `document_types`: for each member document type, its `document_type_name` and the `contract_group_ids` it belongs to
- `tokens`: for each member token, its `token_position` and the `contract_group_ids` it belongs to

Every list is empty when the contract belongs to no group or does not exist. A proof covers the
memberships or their absence.

**Parameters**:

| Name          | Type    | Required | Description |
| ------------- | ------- | -------- | ----------- |
| `contract_id` | Bytes   | Yes      | The 32-byte ID of the data contract. An ID that is not 32 bytes is rejected with `InvalidArgument` |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested memberships |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# TODO: Replace with a real example once a contract group is registered on
# testnet. The response values below are illustrative only.
# `contract_id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "contract_id": "5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getContractGroupsForContract
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "contractGroupMemberships": {
      "documentTypes": [
        {
          "documentTypeName": "note",
          "contractGroupIds": [
            "<base64-of-contract-group-id>"
          ]
        }
      ]
    },
    "metadata": {
      "height": "412345",
      "coreChainLockedHeight": 1520000,
      "epoch": 18000,
      "timeMs": "1793000000000",
      "protocolVersion": 14,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

## State Transition Endpoints

### broadcastStateTransition

Broadcasts a [state transition](../explanations/platform-protocol-state-transition.md) to the platform via DAPI to make a change to layer 2 data. The `broadcastStateTransition` call returns once the state transition has been accepted into the mempool.

**Returns**: Nothing or error

:::{note}
The [`waitForStateTransitionResult` endpoint](#waitforstatetransitionresult) should be used after `broadcastStateTransition` if proof of block confirmation is required.
:::

**Parameters**:

| Name               | Type           | Required | Description                                                          |
| ------------------ | -------------- | -------- | -------------------------------------------------------------------- |
| `state_transition` | Bytes (Base64) | Yes      | A [state transition](../explanations/platform-protocol-state-transition.md). Must be non-empty and no larger than the maximum state transition size (20 KiB at protocol version 13). |

:::{versionadded} 4.1.0
DAPI now rejects an oversized state transition with `INVALID_ARGUMENT` before attempting to broadcast it. An empty payload is rejected the same way. The DAPI-side check is a static upper bound; Drive enforces the active protocol version's limit authoritatively, so a state transition that passes this check can still be rejected later.
:::

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\nJavaScript (dapi-client) example (old)\nconst DAPIClient = require('@dashevo/dapi-client');\nconst DashPlatformProtocol = require('@dashevo/dpp');\n\nconst client = new DAPIClient({ network: 'testnet' });\nconst dpp = new DashPlatformProtocol();\n\n// Data Contract Create State Transition (JSON)\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    client.platform.broadcastStateTransition(stateTransition.toBuffer())\n      .then(() => console.log('State Transition broadcast successfully'));\n  });\n-->\n\n<!--\nJavaScript (dapi-grpc) example (old)\nconst {\n  v0: {\n    PlatformPromiseClient,\n    BroadcastStateTransitionRequest,\n  },\n} = require('@dashevo/dapi-grpc');\nconst DashPlatformProtocol = require('@dashevo/dpp');\n\nconst platformPromiseClient = new PlatformPromiseClient(\n  'https://seed-1.testnet.networks.dash.org:1443',\n);\n\nconst dpp = new DashPlatformProtocol();\n\n// Data Contract Create State Transition (JSON)\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\nconst broadcastStateTransitionRequest = new BroadcastStateTransitionRequest();\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    console.log(stateTransition);\n    broadcastStateTransitionRequest.setStateTransition(stateTransition.toBuffer());\n\n    platformPromiseClient.broadcastStateTransition(broadcastStateTransitionRequest)\n      .then(() => console.log('State Transition broadcast successfully'))\n      .catch((e) => {\n        console.error(e);\n        console.error(e.metadata);\n      });\n  })\n  .catch((e) => console.error(e));\n-->\n\n<!--\ngRPCurl example (old)\n# Submit an identity create State Transition\n# `state_transition` must be represented in base64\n# Replace `state_transition` with your own state transition object before running\ngrpcurl -proto protos/platform/v0/platform.proto \\\n  -d '{\n    \"state_transition\":\"pWR0eXBlAmlzaWduYXR1cmV4WEg3TWhFWDQ0Z3JzMVIwTE9XTU5IZjAxWFNpYVFQcUlVZ1JLRXQyMkxHVERsUlUrZ1BwQUlUZk5JUmhXd3IvYTVHd0lzWm1idGdYVVFxcVhjbW9lQWtUOD1qcHVibGljS2V5c4GkYmlkAGRkYXRheCxBdzh2UmYxeFFCTlVLbzNiY2llaHlaR2NhM0hBSThkY0ZvVWJTK3hLb0lITmR0eXBlAGlpc0VuYWJsZWT1bmxvY2tlZE91dFBvaW50eDBLT1VUSHB5YnFPek9DNnhEVUhFWm9uc1lNSVpqcGppTHFZNnkxYmlWNWxRQUFBQUFvcHJvdG9jb2xWZXJzaW9uAA==\"\n\n    }' \\\n  seed-1.testnet.networks.dash.org:1443 \\\n  org.dash.platform.dapi.v0.Platform/broadcastStateTransition\n-->"
  }
  [/block]
```

**Response**: No response except on error

### waitForStateTransitionResult

**Returns**: The state transition hash and either a proof that the state transition was confirmed in a block or an error.  
**Parameters**:

| Name                    | Type    | Required | Description                      |
| ----------------------- | ------- | -------- | -------------------------------- |
| `state_transition_hash` | Bytes   | Yes      | Hash of the state transition. Must be exactly 32 bytes (the SHA-256 of the serialized state transition). |
| `prove`                 | Boolean | Yes      | Set to `true` to request a proof. The data requested will be encoded as part of the proof in the response. |

:::{versionadded} 4.1.0
A `state_transition_hash` of any length other than 32 bytes is now rejected with `INVALID_ARGUMENT`. Previously only an empty hash was rejected, so a truncated or differently derived hash was accepted and simply never matched, causing the call to wait until it timed out.

A node also serves a bounded number of concurrent pending waits (1,024). Once saturated, further calls return `RESOURCE_EXHAUSTED`; clients should back off and retry, or connect to a different node.
:::

**Example Request**

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\nJavaScript (dapi-client) example (old)\nconst DAPIClient = require('@dashevo/dapi-client');\nconst DashPlatformProtocol = require('@dashevo/dpp');\nconst crypto = require('crypto');\n\nconst client = new DAPIClient({ network: 'testnet' });\nconst dpp = new DashPlatformProtocol();\n\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    //  Calculate state transition hash\n    const hash = crypto.createHash('sha256')\n      .update(stateTransition.toBuffer())\n      .digest();\n\n    console.log(`Requesting proof of state transition with hash:\\n\\t${hash.toString('hex')}`);\n\n    client.platform.waitForStateTransitionResult(hash, { prove: true })\n      .then((response) => {\n        console.log(response);\n      });\n  });\n-->\n\n<!--\nJavaScript (dapi-grpc) example (old)\nconst {\n  v0: {\n    PlatformPromiseClient,\n    WaitForStateTransitionResultRequest,\n  },\n} = require('@dashevo/dapi-grpc');\nconst DashPlatformProtocol = require('@dashevo/dpp');\nconst crypto = require('crypto');\n\nconst platformPromiseClient = new PlatformPromiseClient(\n  'https://seed-1.testnet.networks.dash.org:1443',\n);\n\nconst dpp = new DashPlatformProtocol();\n\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    //  Calculate state transition hash\n    const hash = crypto.createHash('sha256')\n      .update(stateTransition.toBuffer())\n      .digest();\n\n    const waitForStateTransitionResultRequest = new WaitForStateTransitionResultRequest();\n    waitForStateTransitionResultRequest.setStateTransitionHash(hash);\n    waitForStateTransitionResultRequest.setProve(true);\n\n    console.log(`Requesting proof of state transition with hash:\\n\\t${hash.toString('hex')}`);\n\n    platformPromiseClient.waitForStateTransitionResult(waitForStateTransitionResultRequest)\n      .then((response) => {\n        const rootTreeProof = Buffer.from(response.getProof().getRootTreeProof());\n        const storeTreeProof = Buffer.from(response.getProof().getStoreTreeProof());\n        console.log(`Root tree proof: ${rootTreeProof.toString('hex')}`);\n        console.log(`Store tree proof: ${storeTreeProof.toString('hex')}`);\n      })\n  \t\t.catch((e) => console.error(e));\n  });\n-->\n\n<!--\ngRPCurl example (old)\n# `state_transition_hash` must be represented in base64\n# Replace `state_transition_hash` with your own before running\ngrpcurl -proto protos/platform/v0/platform.proto \\\n  -d '{\n    \"state_transition_hash\":\"wEiwFu9WvAtylrwTph5v0uXQm743N+75C+C9DhmZBkw=\",\n    \"prove\": \"true\"\n    }' \\\n  seed-1.testnet.networks.dash.org:1443 \\\n  org.dash.platform.dapi.v0.Platform/waitForStateTransitionResult\n-->"
  }
  [/block]
```

::::{tab-set}
:::{tab-item} JavaScript (dapi-client)
:sync: js-dapi-client
```javascript
const DAPIClient = require('@dashevo/dapi-client');

const client = new DAPIClient({ network: 'testnet' });

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

## System Info Endpoints

### getCurrentQuorumsInfo

Retrieves current quorum details, including validator sets and metadata for each quorum.

**Returns**: Information about current quorums, including quorum hashes, validator sets, and
the last block proposer.

**Response Object**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `quorumHashes` | Array of Bytes | Hashes of all current quorums |
| `currentQuorumHash` | Bytes | Hash of the quorum currently responsible for signing |
| `validatorSets` | Array | One entry per quorum. Each has a `quorumHash`, a `coreHeight`, a `members` array, and a `thresholdPublicKey` |
| `validatorSets[].members[].proTxHash` | Bytes | ProTx hash of the validator |
| `validatorSets[].members[].nodeIp` | String | IP address of the validator |
| `validatorSets[].members[].isBanned` | Boolean | Whether the validator is banned. Omitted from JSON output when `false` |
| `lastBlockProposer` | Bytes | ProTx hash of the validator that proposed the most recent block |

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
  org.dash.platform.dapi.v0.Platform/getCurrentQuorumsInfo
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "quorumHashes": [
      "AAABC9mcu+F3eC33hC9wyZAP20QQNHz4kYnfFQPwa5A="
    ],
    "currentQuorumHash": "AAABP7yY5DKt8UlLUR/QJlH8BI108xugKSEIOrR6iAA=",
    "validatorSets": [
      {
        "quorumHash": "AAABC9mcu+F3eC33hC9wyZAP20QQNHz4kYnfFQPwa5A=",
        "coreHeight": 1131096,
        "members": [
          {
            "proTxHash": "BbaHl4NE+iQzsqqZ1B9kPi2FgaeJzcIwhIic7KUkTqg=",
            "nodeIp": "52.24.124.162"
          },
          {
            "proTxHash": "iCUb1LEk7+uHU33qvuxU9sj1dfTfgfEM9ejuoHMJK28=",
            "nodeIp": "52.33.28.47"
          },
          {
            "proTxHash": "FD3Namt2hP3gHoihDl1l3popJExezVhtFKNCZXAl8RM=",
            "nodeIp": "35.164.23.245"
          }
        ],
        "thresholdPublicKey": "ixciXjkgFnI/cQNXS51yBi4MYgdPZWjRGxsubEsfzItgvTlABUxow9S1eCE7w9+f"
      }
    ],
    "lastBlockProposer": "iCUb1LEk7+uHU33qvuxU9sj1dfTfgfEM9ejuoHMJK28=",
    "metadata": {
      "height": "43865",
      "coreChainLockedHeight": 1131112,
      "epoch": 2483,
      "timeMs": "1730295469308",
      "protocolVersion": 4,
      "chainId": "dash-testnet-51"
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
| `ids`              | Array    | Yes    | An array of evonode IDs for which proposed blocks are retrieved. At most 100 IDs per call, each exactly 32 bytes<br>Note: masternode IDs are created uniquely as described in the [masternode identity IDs section](#masternode-identity-ids) |
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
| `limit`            | Integer  | No       | Maximum number of evonodes proposed epoch blocks to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `start_after`      | Bytes    | No       | Retrieve results starting after this document. Mutually exclusive with `start_at` |
| `start_at`         | Bytes    | No       | Retrieve results starting at this document. Mutually exclusive with `start_after` |
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

### getEpochsInfo

**Returns**: Information for the requested epoch(s)

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ----------- |
| `start_epoch` | Integer | No | First epoch being requested. Must be below 65535, and `start_epoch` plus `count` must also stay below 65535; otherwise the request is rejected with `InvalidArgument`
| `count` | Integer | No | Number of records to request. The effective ceiling is 65534 minus `start_epoch`
| `ascending` | Boolean | No | Set to `true` to query in ascending order. Results are returned in descending order by default.
| `prove` | Boolean | No | Set to `true` to receive a proof that contains the requested data contracts

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
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
          "number": 7859,
          "firstBlockHeight": "157927",
          "firstCoreBlockHeight": 1268167,
          "startTime": "1749645648076",
          "feeMultiplier": 1,
          "protocolVersion": 9
        },
        {
          "number": 7860,
          "firstBlockHeight": "157947",
          "firstCoreBlockHeight": 1268194,
          "startTime": "1749649302574",
          "feeMultiplier": 1,
          "protocolVersion": 9
        }
      ]
    },
    "metadata": {
      "height": "157955",
      "coreChainLockedHeight": 1268198,
      "epoch": 7860,
      "timeMs": "1749650378981",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}

```
:::
::::

### getFinalizedEpochInfos

Retrieves finalized epoch information within a specified index range.

**Returns**: A list of finalized epoch information entries or a cryptographic proof.

**Parameters**:

| Name                         | Type    | Required | Description |
| ---------------------------- | ------- | -------- | ----------- |
| `start_epoch_index`          | Integer | No       | Starting epoch index for the query. Must not exceed 65,279. |
| `start_epoch_index_included` | Boolean | No       | Whether to include the `start_epoch_index` in the results |
| `end_epoch_index`            | Integer | No       | Ending epoch index for the query. Must not exceed 65,279. |
| `end_epoch_index_included`   | Boolean | No       | Whether to include the `end_epoch_index` in the results |
| `prove`                      | Boolean | No       | Set to `true` to receive a cryptographic proof instead of epoch data |

:::{versionadded} 4.1.0
The requested range may contain at most 100 epochs, and each index must be no greater than 65,279. Exceeding either bound returns `InvalidArgument`. The `*_included` flags count toward the range size, so callers requesting a wider window must page through it in successive requests of at most 100 epochs each.

When `start_epoch_index` and `end_epoch_index` are equal, both boundaries must be included or the request is rejected, since the range would otherwise be empty.
:::

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl

```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "start_epoch_index": 7850,
      "start_epoch_index_included": true,
      "end_epoch_index": 7851,
      "end_epoch_index_included": false,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getFinalizedEpochInfos
```

:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "epochs": {
      "finalizedEpochInfos": [
        {
          "number": 7850,
          "firstBlockHeight": "157747",
          "firstCoreBlockHeight": 1267938,
          "firstBlockTime": "1749613360443",
          "feeMultiplier": 1,
          "protocolVersion": 9,
          "totalBlocksInEpoch": "19",
          "nextEpochStartCoreBlockHeight": 1267964,
          "totalDistributedStorageFees": "38925829",
          "totalCreatedStorageFees": "760",
          "coreBlockRewards": "1947189353778",
          "blockProposers": [
            {
              "proposerId": "BbaHl4NE+iQzsqqZ1B9kPi2FgaeJzcIwhIic7KUkTqg=",
              "blockCount": 1
            },
            {
              "proposerId": "FD3Namt2hP3gHoihDl1l3popJExezVhtFKNCZXAl8RM=",
              "blockCount": 1
            },
            {
              "proposerId": "IBB+xQ6BiA3KGBeLt+U+LQRJwHNBBqYHJTua8v/qAGw=",
              "blockCount": 1
            },
            {
              "proposerId": "LkhlGi6cDLTy+3q4dAYapK8M0otZaVYx5qNa85UO9vs=",
              "blockCount": 1
            },
            {
              "proposerId": "OXQa2D3XkeHnOPGe2ugtbAMily5qRVmBQk2jdps9vUo=",
              "blockCount": 1
            },
            {
              "proposerId": "QHhPP5p2HGAVb5JEqQLAYm+LyP4AN4bHDx/GvkHaRn0=",
              "blockCount": 1
            },
            {
              "proposerId": "XGVCdmYVOHGDcV2VipJVUkcvkzNfoWEogEI+S72u9DY=",
              "blockCount": 1
            },
            {
              "proposerId": "YdM/R4kzeXvk3og1PHwthDwhMQ9tAPbv8xQkp1buffs=",
              "blockCount": 1
            },
            {
              "proposerId": "bRsYW6A2781Ep34Fqar2mgxOQJdq7ACwR3PlKGMyCWY=",
              "blockCount": 1
            },
            {
              "proposerId": "dxjtrTceRtIPrTAIbkrPSgXCtmDfauXypoSuvfG+QpA=",
              "blockCount": 1
            },
            {
              "proposerId": "hfFaMdODgpOpwdcqGg+iHmYRDOIIeL1MECTErh1b6CQ=",
              "blockCount": 1
            },
            {
              "proposerId": "hwdSNKxHNTtCu5fORjMMtnzUZIwB8LI5PX5ymw1niRg=",
              "blockCount": 1
            },
            {
              "proposerId": "iCUb1LEk7+uHU33qvuxU9sj1dfTfgfEM9ejuoHMJK28=",
              "blockCount": 1
            },
            {
              "proposerId": "iRe7VGMY80ENGnkBx7hGpzRGMRtRZLRaA/DmE/II8jQ=",
              "blockCount": 1
            },
            {
              "proposerId": "i40Rk6/SLlOM4Mn7UP7hVdD2F2ymjmXaaExdzi0eCBU=",
              "blockCount": 1
            },
            {
              "proposerId": "jeixKVL3BY2Ce9BM3/HCF12Hu/ifKLUkUqY3vJea3cQ=",
              "blockCount": 1
            },
            {
              "proposerId": "uozh3HKFe0Fo4zJyVx33+6+Ewxbf5IIXrdz2WV4lQhY=",
              "blockCount": 1
            },
            {
              "proposerId": "2bCQz8Gcry4n1RLmnEOBKidL3ynAgdCt5P0nKtVqX4k=",
              "blockCount": 1
            },
            {
              "proposerId": "/yYdLBx2kHoq2K62xWEXlvA7XL2IrpJFKkcn4T9PSsk=",
              "blockCount": 1
            }
          ]
        }
      ]
    },
    "metadata": {
      "height": "157957",
      "coreChainLockedHeight": 1268201,
      "epoch": 7860,
      "timeMs": "1749650741098",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
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
| `path`  | Array    | Yes      | The path for which elements are being requested. At most 256 components, each no larger than 255 bytes. |
| `keys`  | Array    | No       | The keys associated with the elements being requested. At most 100 entries, each no larger than 255 bytes. |
| `prove` | Boolean  | No       | Set to `true` to receive a proof that contains the requested elements |

:::{versionadded} 4.1.0
Requests are now bounded: at most 256 path components, at most 100 keys, at most 255 bytes per component, and at most 64 KiB for the combined byte length of all path and key components. Exceeding any of these returns `RESOURCE_EXHAUSTED`.
:::

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

```{eval-rst}
..
  Internal use only - getProofs is used for DAPI-to-Drive communication only; all external requests are rejected
```

### getProtocolVersionUpgradeState

**Returns**: The number of votes cast for each protocol version.

**Parameters**:

| Name    | Type    | Required | Description |
| ------- | ------- | -------- | ------------ |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested protocol version state

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
| `start_pro_tx_hash` | Bytes | No | Protx hash of an evonode. Must be represented in base64 if present, and must be exactly 32 bytes; any other length is rejected with `InvalidArgument`
| `count` | Integer | No       | Number of records to request. Must be below 65535
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested protocol version vote status

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

**Response Object**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `version.software.dapi` | String | DAPI version |
| `version.software.drive` | String | Drive version. Missing if Drive is not responding |
| `version.software.tenderdash` | String | Tenderdash version. Missing if Tenderdash is not responding |
| `version.protocol.tenderdash.p2p` | Integer | Tenderdash P2P protocol version |
| `version.protocol.tenderdash.block` | Integer | Tenderdash block protocol version |
| `version.protocol.drive.latest` | Integer | Highest protocol version supported by this node |
| `version.protocol.drive.current` | Integer | Protocol version used in the current epoch |
| `version.protocol.drive.next_epoch` | Integer | Protocol version that will be used in the next epoch |
| `node.id` | Bytes | Platform node ID |
| `node.proTxHash` | Bytes | Evonode ProTx hash. Absent if the node is a full node |
| `chain.catchingUp` | Boolean | `true` while the node is still syncing. Omitted from JSON output when `false` |
| `chain.latestBlockHash` | Bytes | Hash of the most recent block |
| `chain.latestAppHash` | Bytes | Application hash of the most recent block |
| `chain.latestBlockHeight` | String (uint64) | Height of the most recent block |
| `chain.earliestBlockHash` | Bytes | Hash of the earliest retained block |
| `chain.earliestAppHash` | Bytes | Application hash of the earliest retained block |
| `chain.earliestBlockHeight` | String (uint64) | Height of the earliest retained block |
| `chain.maxPeerBlockHeight` | String (uint64) | Highest block height reported by peers |
| `chain.coreChainLockedHeight` | Integer | Latest known core height in consensus. Missing if Drive is not responding |
| `network.chainId` | String | Name of the network |
| `network.peersCount` | Integer | Number of connected peers |
| `network.listening` | Boolean | Whether the node is accepting inbound connections |
| `stateSync` | Object | State sync progress. Empty when no state sync is in progress. Members are `totalSyncedTime`, `remainingTime`, `totalSnapshots`, `chunkProcessAvgTime`, `snapshotHeight`, `snapshotChunksCount`, `backfilledBlocks`, and `backfillBlocksTotal` |
| `time.local` | String (uint64) | Node's local time in milliseconds |
| `time.block` | String (uint64) | Most recent block time. Missing if Drive is not responding |
| `time.genesis` | String (uint64) | Genesis time. Missing if Drive is not responding |
| `time.epoch` | Integer | Current epoch. Missing if Drive is not responding |

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
        "dapi": "4.1.0",
        "drive": "4.1.0",
        "tenderdash": "1.6.0"
      },
      "protocol": {
        "tenderdash": {
          "p2p": 10,
          "block": 14
        },
        "drive": {
          "latest": 13,
          "current": 13,
          "nextEpoch": 13
        }
      }
    },
    "node": {
      "id": "QbMI9zfKnjn2e1UxWJAxmKiMUW4=",
      "proTxHash": "s7V0hXG2D+mtEScV1qUXJdblpSqcOvX9NqFyTPUNhi8="
    },
    "chain": {
      "latestBlockHash": "pdWnS2qZPt4KW1E5AFojX3FMamipgcXLLoeAt72vfEI=",
      "latestAppHash": "gK9aXNoc9ARLegnhv210Z70Yjnmphf2jANqHBdPMcpk=",
      "latestBlockHeight": "505427",
      "earliestBlockHash": "CPoCwn7AOQujAeT8fj1+rbNQyBk+PmKgk2iXBuOiC/o=",
      "earliestAppHash": "vwzLnKBxugGubmegwJD5eAPSbVbWddzVExeBy8rI7I8=",
      "earliestBlockHeight": "1",
      "maxPeerBlockHeight": "505427",
      "coreChainLockedHeight": 1531571
    },
    "network": {
      "chainId": "dash-testnet-51",
      "peersCount": 151,
      "listening": true
    },
    "stateSync": {},
    "time": {
      "local": "1786373846",
      "block": "1786373752393",
      "genesis": "0",
      "epoch": 18061
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

## Token Endpoints

:::{versionadded} 2.0.0
:::

### getIdentityTokenBalances

Retrieves token balances for a specified identity.

**Returns**: A list of token balances or a cryptographic proof.

**Parameters**:

| Name         | Type     | Required | Description |
|-------------|---------|----------|-------------|
| `identity_id` | Bytes   | Yes      | The ID of the identity for which token balances are requested |
| `token_ids`  | Array of Bytes | No | List of token IDs to filter the balances. At most 100 entries |
| `prove`      | Boolean | No       | Set to `true` to receive a proof containing the requested token balances |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=",
      "token_ids": ["rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=", "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityTokenBalances
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "tokenBalances": {
      "tokenBalances": [
        {
          "tokenId": "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="
        },
        {
          "tokenId": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
          "balance": "101820"
        }
      ]
    },
    "metadata": {
      "height": "157980",
      "coreChainLockedHeight": 1268232,
      "epoch": 7861,
      "timeMs": "1749654828318",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentitiesTokenBalances

Retrieves the token balances for a list of specified identities.

**Returns**: A list of identity token balances or a cryptographic proof.

**Parameters**:

| Name         | Type     | Required | Description |
|-------------|---------|----------|-------------|
| `token_id`    | Bytes   | Yes      | The ID of the token whose balances are requested |
| `identity_ids` | Array of Bytes | No      | A list of identity IDs to filter the balances. At most 100 entries |
| `prove`        | Boolean | No      | Set to `true` to receive a proof that contains the requested token balances |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_id": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
      "identity_ids": ["HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=", "tBRF8/5pzZtmKQ7SHfkm0B3WOUmm3/EfZldNi8sdaDk="],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentitiesTokenBalances
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "identityTokenBalances": {
      "identityTokenBalances": [
        {
          "identityId": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=",
          "balance": "101820"
        },
        {
          "identityId": "tBRF8/5pzZtmKQ7SHfkm0B3WOUmm3/EfZldNi8sdaDk=",
          "balance": "5"
        }
      ]
    },
    "metadata": {
      "height": "157980",
      "coreChainLockedHeight": 1268232,
      "epoch": 7861,
      "timeMs": "1749654828318",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentityTokenInfos

Retrieves information about specified tokens for a given identity.

**Returns**: A list of token information entries or a cryptographic proof.

**Parameters**:

| Name         | Type     | Required | Description |
|-------------|---------|----------|-------------|
| `identity_id` | Bytes   | Yes      | The ID of the identity whose token information is requested |
| `token_ids`   | Array of Bytes | No      | A list of token IDs to retrieve information for. At most 100 entries |
| `prove`       | Boolean | No      | Set to `true` to receive a proof that contains the requested token information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "identity_id": "tBRF8/5pzZtmKQ7SHfkm0B3WOUmm3/EfZldNi8sdaDk=",
      "token_ids": ["rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=", "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentityTokenInfos
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "tokenInfos": {
      "tokenInfos": [
        {
          "tokenId": "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="
        },
        {
          "tokenId": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
          "info": {
            "frozen": true
          }
        }
      ]
    },
    "metadata": {
      "height": "157984",
      "coreChainLockedHeight": 1268234,
      "epoch": 7861,
      "timeMs": "1749655176587",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getIdentitiesTokenInfos

Retrieves token information for a list of specified identities.

**Returns**: A list of token information entries for the provided identities or a cryptographic proof.

**Parameters**:

| Name         | Type     | Required | Description |
|-------------|---------|----------|-------------|
| `token_id`    | Bytes   | Yes      | The ID of the token whose information is requested |
| `identity_ids` | Array of Bytes | No      | A list of identity IDs to retrieve token information for. At most 100 entries |
| `prove`        | Boolean | No      | Set to `true` to receive a proof that contains the requested token information |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_id": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
      "identity_ids": ["HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=", "tBRF8/5pzZtmKQ7SHfkm0B3WOUmm3/EfZldNi8sdaDk="],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentitiesTokenInfos
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "identityTokenInfos": {
      "tokenInfos": [
        {
          "identityId": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ="
        },
        {
          "identityId": "tBRF8/5pzZtmKQ7SHfkm0B3WOUmm3/EfZldNi8sdaDk=",
          "info": {
            "frozen": true
          }
        }
      ]
    },
    "metadata": {
      "height": "157984",
      "coreChainLockedHeight": 1268234,
      "epoch": 7861,
      "timeMs": "1749655176587",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getTokenContractInfo

Retrieves contract information for a specific token ID.

**Returns**: Token contract info or a cryptographic proof.

**Parameters**:

| Name       | Type    | Required | Description                                                                      |
| ---------- | ------- | -------- | -------------------------------------------------------------------------------- |
| `token_id` | Bytes   | Yes      | The 32-byte ID of the token whose contract information is being requested        |
| `prove`    | Boolean | No       | Set to `true` to receive a proof that contains the requested token contract info |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl

```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_id": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTokenContractInfo
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "data": {
      "contractId": "L+2jKoiBdmhzIAg82a3nnOn8/K5sQiaIW/Tinw0ypNM=",
      "tokenContractPosition": 0
    },
    "metadata": {
      "height": "157984",
      "coreChainLockedHeight": 1268234,
      "epoch": 7861,
      "timeMs": "1749655176587",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getTokenDirectPurchasePrices

Retrieves direct purchase prices defined for the specified token IDs.

This endpoint provides pricing data for tokens that support direct purchases. Each token may have either a fixed price or a tiered pricing schedule that depends on the quantity being purchased.

**Returns**: A list of token price entries or a cryptographic proof containing the requested data.

**Parameters**:

| Name        | Type     | Required | Description |
|-------------|----------|----------|-------------|
| `token_ids` | Array    | Yes      | List of 32-byte token IDs to retrieve pricing for. Must be non-empty and contain at most 100 entries. |
| `prove`     | Boolean  | No       | Set to `true` to receive a proof that contains the requested pricing data |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_ids": ["rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=", "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTokenDirectPurchasePrices
```
:::
::::

::::{tab-set}
:::{tab-item} Response (Fixed Price)
```json
{
  "v0": {
    "tokenDirectPurchasePrices": {
      "tokenDirectPurchasePrice": [
        {
          "tokenId": "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="
        },
        {
          "tokenId": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
          "fixedPrice": "10000000000"
        }
      ]
    },
    "metadata": {
      "height": "158027",
      "coreChainLockedHeight": 1268261,
      "epoch": 7862,
      "timeMs": "1749659877672",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::

:::{tab-item} Response (Tiered Pricing)
```json
{
  "v0": {
    "tokenDirectPurchasePrices": {
      "tokenDirectPurchasePrice": [
        {
          "tokenId": "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="
        },
        {
          "tokenId": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
          "variablePrice": {
            "priceForQuantity": [
              {
                "quantity": "1",
                "price": "10000000000"
              },
              {
                "quantity": "10",
                "price": "7000000000"
              },
              {
                "quantity": "50",
                "price": "5000000000"
              }
            ]
          }
        }
      ]
    },
    "metadata": {
      "height": "158017",
      "coreChainLockedHeight": 1268248,
      "epoch": 7862,
      "timeMs": "1749658213296",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getTokenPerpetualDistributionLastClaim

Retrieves the last-claim timestamp for a token’s perpetual distribution for a specific identity.

**Returns**: A timestamp indicating the last successful claim, or a cryptographic proof.

The returned `last_claim` value takes one of several forms depending on the token’s distribution interval: `timestamp_ms` (milliseconds since epoch), `block_height`, `epoch`, or `raw_bytes`.

**Parameters**:

| Name                      | Type    | Required | Description |
|---------------------------|---------|----------|-------------|
| `token_id`                | Bytes   | Yes      | The unique 32-byte identifier of the token |
| `contract_info`           | Object  | No       | Token contract info, used to disambiguate tokens with the same ID across contracts |
| `contract_info.`<br>`contract_id`         | Bytes   | Yes (if `contract_info` is provided) | ID of the data contract where the token is defined |
| `contract_info.`<br>`token_contract_position` | Integer | Yes (if `contract_info` is provided) | Token position within the contract |
| `identity_id`             | Bytes   | Yes      | Identity whose last-claim info is being requested |
| `prove`                   | Boolean | No       | Set to `true` to receive a proof containing the requested last-claim data |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_id": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
      "identity_id": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTokenPerpetualDistributionLastClaim
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "lastClaim": {
      "rawBytes": "AAABl1+BUYA="
    },
    "metadata": {
      "height": "158030",
      "coreChainLockedHeight": 1268268,
      "epoch": 7863,
      "timeMs": "1749660288110",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getTokenPreProgrammedDistributions

Retrieves pre-programmed distributions of a specified token.

**Returns**: A list of token distributions scheduled over time or a cryptographic proof.

**Parameters**:

| Name                      | Type     | Required | Description |
|---------------------------|---------|----------|-------------|
| `token_id`                | Bytes   | Yes      | The ID of the token whose distributions are requested |
| `start_at_info`           | Object  | No       | Filtering options for the distribution query |
| `start_at_info.start_time_ms` | UInt64  | No       | Start timestamp (in milliseconds) for filtering distributions |
| `start_at_info.start_recipient` | Bytes   | No       | The recipient ID to start retrieving distributions from |
| `start_at_info.start_recipient_included` | Boolean | No       | Whether the start recipient should be included in the results |
| `limit`                   | UInt32  | No       | Maximum number of results to return. See [Result limits and pagination](#result-limits-and-pagination) |
| `prove`                   | Boolean | No       | Set to `true` to receive a proof that contains the requested token distributions |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_id": "qa3VvNgqTlRQEfBbqHFQrVJJqO8fcxHMCy4PNrBR4Ho=",
      "limit": 10,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTokenPreProgrammedDistributions
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "tokenDistributions": {
      "tokenDistributions": [
        {
          "timestamp": "1749662152621",
          "distributions": [
            {
              "recipientId": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=",
              "amount": "100"
            }
          ]
        },
        {
          "timestamp": "1749665692621",
          "distributions": [
            {
              "recipientId": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=",
              "amount": "1000"
            }
          ]
        },
        {
          "timestamp": "1781198092621",
          "distributions": [
            {
              "recipientId": "HVkP3Jq7Rx6O4+TDMIe9emp4NUx2xOjvPSgYJqPqTPQ=",
              "amount": "1000000"
            }
          ]
        }
      ]
    },
    "metadata": {
      "height": "158043",
      "coreChainLockedHeight": 1268281,
      "epoch": 7863,
      "timeMs": "1749662275384",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getTokenStatuses

Retrieves the statuses of specified tokens.

**Returns**: A list of token statuses or a cryptographic proof.

**Parameters**:

| Name        | Type     | Required | Description |
|------------|---------|----------|-------------|
| `token_ids`  | Array of Bytes | Yes      | A list of token IDs to retrieve statuses for. At most 100 entries |
| `prove`      | Boolean | No      | Set to `true` to receive a proof that contains the requested token statuses |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_ids": ["rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=", "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTokenStatuses
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "tokenStatuses": {
      "tokenStatuses": [
        {
          "tokenId": "LP44w8MPMx6hjEL1fBbCWVoekxUzyK/fdiHURk1jl7U="
        },
        {
          "tokenId": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
          "paused": false
        }
      ]
    },
    "metadata": {
      "height": "158031",
      "coreChainLockedHeight": 1268271,
      "epoch": 7863,
      "timeMs": "1749660469151",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getTokenTotalSupply

Retrieves the total supply of a specified token, including aggregated user accounts and system-held amounts.

**Returns**: The total supply of a token or a cryptographic proof.

**Parameters**:

| Name        | Type     | Required | Description |
|------------|---------|----------|-------------|
| `token_id`  | Bytes   | Yes      | The ID of the token whose total supply is requested |
| `prove`      | Boolean | No      | Set to `true` to receive a proof that contains the requested token supply data |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "token_id": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getTokenTotalSupply
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "tokenTotalSupply": {
      "tokenId": "rHb8c3C+RFDdsmSXv7dV4F5daFa1xiMpJx4A9YWHyOQ=",
      "totalAggregatedAmountInUserAccounts": "102060",
      "totalSystemAmount": "102060"
    },
    "metadata": {
      "height": "158031",
      "coreChainLockedHeight": 1268271,
      "epoch": 7863,
      "timeMs": "1749660469151",
      "protocolVersion": 9,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

## Address System Endpoints

:::{versionadded} 3.0.0
:::

### getAddressInfo

Returns balance and nonce information for a specified address.

**Returns**: An address info entry or a cryptographic proof.

**Parameters**:

| Name      | Type    | Required | Description |
|-----------|---------|----------|-------------|
| `address` | Bytes   | Yes      | The address to query |
| `prove`   | Boolean | No       | Set to `true` to receive a proof that contains the requested address info |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "address": "AGMKU+A583xy+MWA8kFpOkxFrDlA",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getAddressInfo
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "addressInfoEntry": {
      "address": "AGMKU+A583xy+MWA8kFpOkxFrDlA",
      "balanceAndNonce": {
        "balance": "99388684960",
        "nonce": 10
      }
    },
    "metadata": {
      "height": "307493",
      "coreChainLockedHeight": 1453973,
      "epoch": 15063,
      "timeMs": "1775581907797",
      "protocolVersion": 11,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getAddressesInfos

Returns balance and nonce information for multiple addresses.

**Returns**: A list of address info entries or a cryptographic proof.

**Parameters**:

| Name        | Type             | Required | Description |
|-------------|------------------|----------|-------------|
| `addresses` | Array of Bytes   | Yes      | The addresses to query. At most 100 addresses per request; exceeding this returns an invalid-limit error |
| `prove`     | Boolean          | No       | Set to `true` to receive a proof that contains the requested address info |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "addresses": [
        "AGMKU+A583xy+MWA8kFpOkxFrDlA",
        "AHEBwunnlfvW0zylnqC6rokXwANq"
      ],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getAddressesInfos
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "addressInfoEntries": {
      "addressInfoEntries": [
        {
          "address": "AGMKU+A583xy+MWA8kFpOkxFrDlA",
          "balanceAndNonce": {
            "balance": "99388684960",
            "nonce": 10
          }
        },
        {
          "address": "AHEBwunnlfvW0zylnqC6rokXwANq",
          "balanceAndNonce": {
            "balance": "500000000"
          }
        }
      ]
    },
    "metadata": {
      "height": "307493",
      "coreChainLockedHeight": 1453973,
      "epoch": 15063,
      "timeMs": "1775581907797",
      "protocolVersion": 11,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getAddressesTrunkState

Returns a cryptographic proof of the trunk state of the address balance tree. Used with [`getAddressesBranchState`](#getaddressesbranchstate) to perform incremental sync of address
balances.

The trunk proof is served from the latest available checkpoint rather than from current state, so the returned `metadata.height` is a checkpoint height that generally trails the chain tip. The quorum signature, `blockIdHash`, and round in the proof correspond to that checkpoint height as well, so verifiers must resolve the signing quorum at the checkpoint height rather than at the tip. Pass the returned height as `checkpoint_height` on follow-up [`getAddressesBranchState`](#getaddressesbranchstate) calls; branch proofs are served only from checkpoints, so a height that no longer has a checkpoint returns an error.

**Returns**: A cryptographic proof of the address tree trunk state.

**Parameters**:

None.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{ "v0": {} }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getAddressesTrunkState
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "proof": {
      "grovedbProof": "APsA/wGQtKE8gXoPHBaBJWO/39M63DsnEkx4Lah9...(truncated)",
      "quorumHash": "AAAAN0ggLzkGuHl7bJM48baKuEs/b3rhSMSF5kIw14g=",
      "signature": "oc8EMH7WkoZhv06iPvP4HjTlleaRLOfDRvWg30hjXL3z83DpNigk1/8mZwC1jrEDFymkkftcoE+DcPhZu/R8wlP2yxWcWo+605lLqU/FIb29nOt0q6hUbuX+eZL39mdb",
      "blockIdHash": "Eq24v2aaWwDXN41oCmduKOYnDRsvoAJwDk8BEHZRDaU=",
      "quorumType": 6
    },
    "metadata": {
      "height": "307493",
      "coreChainLockedHeight": 1453973,
      "epoch": 15063,
      "timeMs": "1775581907797",
      "protocolVersion": 11,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getAddressesBranchState

Returns a Merkle proof for a branch of the address balance tree. The `key` must be a valid node key from the address tree, obtained by parsing a `getAddressesTrunkState` proof. Use the `height` from that response's metadata as `checkpoint_height` to ensure consistency.

**Returns**: A Merkle proof for the specified branch.

**Parameters**:

| Name                | Type    | Required | Description |
|---------------------|---------|----------|-------------|
| `key`               | Bytes   | Yes      | A valid node key from the address tree (obtained by parsing a trunk proof) |
| `depth`             | Integer | Yes      | The depth of the branch (valid range: 6–9) |
| `checkpoint_height` | Integer | Yes      | Block height from a `getAddressesTrunkState` response `metadata.height`, for consistency |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "key": "<node key from trunk proof>",
      "depth": 6,
      "checkpointHeight": "<height from getAddressesTrunkState metadata>"
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getAddressesBranchState
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "merkProof": "AAEC..."
  }
}
```
:::
::::

Use the `checkpoint_height` from the preceding `getAddressesTrunkState` response to ensure the
branch proof corresponds to the same checkpoint.

### getRecentAddressBalanceChanges

Returns address balance changes starting from a specified block height. Supports both inclusive and exclusive start heights for incremental sync.

A single call returns changes for at most 100 blocks. If the response contains 100 blocks, more
changes may remain: page forward by re-issuing the call with `start_height` set to the highest
`blockHeight` returned and `start_height_exclusive` set to `true`.

**Returns**: A list of address balance changes grouped by block, or a cryptographic proof.

**Parameters**:

| Name                     | Type    | Required | Description |
|--------------------------|---------|----------|-------------|
| `start_height`           | String (uint64) | Yes      | Block height to start from (as a string due to uint64 size) |
| `prove`                  | Boolean | No       | Set to `true` to receive a proof that contains the requested changes |
| `start_height_exclusive` | Boolean | No       | When `true`, use exclusive start (excludes the start height block); when `false` or omitted, the start height block is included |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "startHeight": "305000",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getRecentAddressBalanceChanges
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "addressBalanceUpdateEntries": {
      "blockChanges": [
        {
          "blockHeight": "305590",
          "changes": [
            {
              "address": "AGMKU+A583xy+MWA8kFpOkxFrDlA",
              "addToBalance": "800000000000"
            }
          ]
        },
        {
          "blockHeight": "305591",
          "changes": [
            {
              "address": "AGMKU+A583xy+MWA8kFpOkxFrDlA",
              "setBalance": "99388684960"
            }
          ]
        }
      ]
    },
    "metadata": {
      "height": "307487",
      "coreChainLockedHeight": 1453964,
      "epoch": 15063,
      "timeMs": "1775580820548",
      "protocolVersion": 11,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getRecentCompactedAddressBalanceChanges

Returns compacted address balance changes from a specified block height. Compacted changes merge multiple operations per address into a single entry per block range, reducing response size for bulk sync.

A single call returns at most 25 compacted block-range entries, a bound chosen to keep proofs within
their size limit. If the response contains 25 entries, page forward by re-issuing the call with
`start_block_height` set past the `endBlockHeight` of the last entry returned.

**Returns**: A list of compacted address balance changes grouped by block range, or a cryptographic proof.

**Parameters**:

| Name                 | Type    | Required | Description |
|----------------------|---------|----------|-------------|
| `start_block_height` | String (uint64) | Yes      | Block height to start from (as a string due to uint64 size) |
| `prove`              | Boolean | No       | Set to `true` to receive a proof that contains the requested changes |

**Example Request and Response**

The example response below was captured at protocol version 11. At protocol version 13 and above,
proof responses use the [compacted proof encoding described in Platform Proofs](platform-proofs.md#compacted-address-balance-proofs).

::::{tab-set}
:::{tab-item} gRPCurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "startBlockHeight": "307400",
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getRecentCompactedAddressBalanceChanges
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
```json
{
  "v0": {
    "compactedAddressBalanceUpdateEntries": {},
    "metadata": {
      "height": "307489",
      "coreChainLockedHeight": 1453968,
      "epoch": 15063,
      "timeMs": "1775581182645",
      "protocolVersion": 11,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

The example above was captured for a range with no balance changes, so
`compactedAddressBalanceUpdateEntries` is empty. When changes are present it contains a
`compactedBlockChanges` array; each element has a `startBlockHeight`, an `endBlockHeight`, and a
`changes` array. Each entry in `changes` carries an `address` plus exactly one of `setCredits` (the
final balance for the range) or `addToCreditsOperations` (the individual adds, each tagged with its
block height, so a client can apply only those above its own sync height). Note that these names
differ from the `setBalance` and `addToBalance` fields used by
[`getRecentAddressBalanceChanges`](#getrecentaddressbalancechanges).

## Shielded Transaction Endpoints

:::{versionadded} 4.0.0
:::

### getShieldedEncryptedNotes

Returns encrypted notes from the shielded pool for a specified range. Clients use these notes for trial decryption to identify notes belonging to their viewing key.

**Returns**: A list of encrypted notes or a cryptographic proof.

**Parameters**:

| Name          | Type    | Required | Description |
|---------------|---------|----------|-------------|
| `start_index` | Integer | Yes      | The index of the first note to retrieve. Must be chunk-aligned: a multiple of the note commitment tree's MMR chunk size (2048). A non-aligned value is rejected with `InvalidArgument` |
| `count`       | Integer | Yes      | The number of notes to retrieve, capped at 8,192 (4 MMR chunks of 2,048 notes each). A `count` of `0` or one above the cap is silently treated as a request for the maximum rather than rejected |
| `prove`       | Boolean | No       | Set to `true` to receive a proof that contains the requested notes |

Because `start_index` must land on an MMR chunk boundary, paginate by advancing `start_index` in
multiples of the chunk size rather than by the number of notes actually returned.

A response containing fewer notes than requested means the end of the note commitment tree was
reached, not that the response was truncated. Stop paginating when this occurs.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "start_index": 0,
      "count": 2,
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getShieldedEncryptedNotes
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "encryptedNotes": {
      "entries": [
        {
          "nullifier": "ACLc9k5HtKNM//KyTT/iWa+MIA8f1Ya3HDIsURjUYRc=",
          "cmx": "ecV1F/WDoBa8CfL2Fwdlq3gcBrrZqnvgI+NwtsJZ6Ss=",
          "encryptedNote": "WhToIlQhpze9cE45wNRsmxukpDPVOQ5k2Ws5FW2WYIjJiNctiIDc0CvGIKA49tJu8Z0lwjhp8RTUPmLdGShZgSTIp7W/dO2emMRUtPxb1TWUVU8EYd1lBnIXOATGmuV35oUQbt94GeX2PLp5rEOmm0o5rtgqiDyJ305AiLRSwZeOPPRrFrly/XQX90nacrqVBVg7vNvLlTKQazFPAcyjG1O/DpYh82W4jzXWakCn5XQYnMkRHv/u+YxK87viIG5C6XLpxOkxBgeONeYFBBGz8YlTnCnOBIkp",
          "cvNet": "3Z5DAoE4aC3roM3Qh4U+wuCndC1WiASsxer1oSIMIIY="
        },
        {
          "nullifier": "5ShcfdX68dfTfdZZ4nAXwfooPvd+1XHLXFP4D5hUzS4=",
          "cmx": "CEa3w+gR7bMftk6XcIA1/1JT27UqxZYGmfO7gP7fWwg=",
          "encryptedNote": "JzRWtHVnO5x4Ijn4M2URM4ojlY9W9mPV2Qz/Rz2TeA6hz5s63bYlTzy/eAQuJStsjCYQwq5H9OtN/EqFov/f1CqtwRTEWnro/3H+QAwMW+hYW982lBNImsPZhLk533fG2f0QD3yuu+BQXAryxNg4jHFBb70wEDF+m9ZklhNH5Bdyl0KoTXjEZqL2mUcY6zcb5gjU6DkozwNOFuiVjMCRVjzRdwUVNLNQhZqqLFIeWUCo37GZbN8oC6p24Lb9phnYNu53Km2d4c74nLdOVdSMeAzTIjle+woH",
          "cvNet": "TuY3Si9ojWn1BbX4oHLQ+ZDZ/eFlHpMNV5vh3rzd+jU="
        }
      ]
    },
    "metadata": {
      "height": "375055",
      "coreChainLockedHeight": 1506025,
      "epoch": 17083,
      "timeMs": "1782852695259",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getShieldedAnchors

Returns the commitment tree anchors currently retained by the node for the shielded pool. Anchors are used by shielded transaction provers to reference a valid state of the commitment tree.

**Returns**: A list of commitment tree anchors or a cryptographic proof.

**Parameters**:

| Name    | Type    | Required | Description |
|---------|---------|----------|-------------|
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested anchors |

The response covers the [node's retention window](../protocol-ref/shielded-pool.md#anchors) rather than the full history of the pool: older anchors are pruned, so the retained set is bounded by the retention and pruning policy.

:::{versionadded} 4.1.0
If the retained anchor set exceeds what this unpaginated response can enumerate, the call returns `RESOURCE_EXHAUSTED` instead of doing unbounded work. Retry with backoff; if the condition persists, try another node rather than repeatedly retrying the same one.
:::

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getShieldedAnchors
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "anchors": {
      "anchors": [
        "Ahh3yHTlv9H1vhEGVFRbRquziIuG7is28el/VpCv7jk=",
        "JeaJEco0ewcWxwIudW6TX/GQQQ+muiLIMwn8S3cbNw8=",
        "Li/voQtJmL93TZfi/j3ht81uXY4TfPB2iPkRpfnfhhw="
      ]
    },
    "metadata": {
      "height": "375055",
      "coreChainLockedHeight": 1506025,
      "epoch": 17083,
      "timeMs": "1782852695259",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getMostRecentShieldedAnchor

Returns the most recent commitment tree anchor for the shielded pool.

**Returns**: The most recent anchor or a cryptographic proof.

**Parameters**:

| Name    | Type    | Required | Description |
|---------|---------|----------|-------------|
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested anchor |

If no anchor has been recorded on the chain yet, the unproved response returns an all-zero 32-byte
`anchor` as an "absent" sentinel rather than omitting the field or returning an error. Treat an
all-zero anchor as "no anchor available" and do not use it for proof generation.

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getMostRecentShieldedAnchor
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "anchor": "Li/voQtJmL93TZfi/j3ht81uXY4TfPB2iPkRpfnfhhw=",
    "metadata": {
      "height": "375055",
      "coreChainLockedHeight": 1506025,
      "epoch": 17083,
      "timeMs": "1782852695259",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getShieldedPoolState

Returns the total balance held in the shielded pool.

**Returns**: The total shielded pool balance (in credits) or a cryptographic proof.

**Parameters**:

| Name    | Type    | Required | Description |
|---------|---------|----------|-------------|
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested pool state |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getShieldedPoolState
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "totalBalance": "1831893452700",
    "metadata": {
      "height": "375055",
      "coreChainLockedHeight": 1506025,
      "epoch": 17083,
      "timeMs": "1782852695259",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getShieldedNotesCount

Returns the count of leaves in the shielded notes commitment tree. Wallets use this at the start of a shielded sync to seed a determinate progress indicator.

**Returns**: The total shielded notes count or a cryptographic proof.

**Parameters**:

| Name    | Type    | Required | Description |
|---------|---------|----------|-------------|
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested count |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getShieldedNotesCount
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "totalNotesCount": "622",
    "metadata": {
      "height": "375055",
      "coreChainLockedHeight": 1506025,
      "epoch": 17083,
      "timeMs": "1782852695259",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

### getShieldedNullifiers

Returns the spent status of specified nullifiers. Clients use this to determine whether notes have already been spent.

**Returns**: A list of nullifier statuses or a cryptographic proof.

**Parameters**:

| Name         | Type           | Required | Description |
|--------------|----------------|----------|-------------|
| `nullifiers` | Array of Bytes | Yes      | The nullifiers to query. Must contain between 1 and 100 entries, each exactly 32 bytes. An empty list or a wrong-length entry is rejected with `InvalidArgument`; more than 100 entries is rejected as an invalid limit |
| `prove`      | Boolean        | No       | Set to `true` to receive a proof that contains the requested nullifier statuses |

**Example Request and Response**

::::{tab-set}
:::{tab-item} gRPCurl
:sync: grpcurl
```shell
# Each nullifier must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "v0": {
      "nullifiers": [
        "ACLc9k5HtKNM//KyTT/iWa+MIA8f1Ya3HDIsURjUYRc="
      ],
      "prove": false
    }
  }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getShieldedNullifiers
```
:::
::::

::::{tab-set}
:::{tab-item} Response (gRPCurl)
:sync: grpcurl
```json
{
  "v0": {
    "nullifierStatuses": {
      "entries": [
        {
          "nullifier": "ACLc9k5HtKNM//KyTT/iWa+MIA8f1Ya3HDIsURjUYRc="
        }
      ]
    },
    "metadata": {
      "height": "375055",
      "coreChainLockedHeight": 1506025,
      "epoch": 17083,
      "timeMs": "1782852695259",
      "protocolVersion": 12,
      "chainId": "dash-testnet-51"
    }
  }
}
```
:::
::::

A nullifier's `is_spent` field is omitted from the response when `false` (proto3 default), so an entry without `is_spent` indicates the nullifier has not been spent.

## Code Reference

Implementation details related to the information on this page can be found in:

* The [Platform repository](https://github.com/dashpay/platform/tree/master/packages/rs-dapi/src/services) `packages/rs-dapi/src/services` folder, which contains the DAPI implementation deployed by dashmate
* The [Platform repository](https://github.com/dashpay/platform/tree/master/packages/dapi-grpc) `packages/dapi-grpc/protos` folder
