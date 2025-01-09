# Create documentation for a new endpoint

Use this endpoint documentation as a template to create documentation for new platform endpoints:

```
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
```


Create documentation for the following new endpoint using the style of previously provided endpoint documentation as a template:

```
INSERT DETAILS FROM THE .proto FILE HERE
```
