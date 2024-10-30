```{eval-rst}
.. _reference-dapi-endpoints:
```

# DAPI Endpoints

[DAPI](../explanations/dapi.md) currently provides 2 types of endpoints:
[JSON-RPC](https://www.jsonrpc.org/) and [gRPC](https://grpc.io/docs/guides/). The JSON-RPC
endpoints expose some layer 1 information while the gRPC endpoints support layer 2 as well as
streaming of events related to blocks and transactions/transitions.

## JSON-RPC Endpoints

| Layer | Endpoint | Description |
| :---: | -------- | ----------- |
|   1   | [`getBestBlockHash`](../reference/dapi-endpoints-json-rpc-endpoints.md#getbestblockhash) | Returns block hash of the chaintip |
|   1   | [`getBlockHash`](../reference/dapi-endpoints-json-rpc-endpoints.md#getblockhash)         | Returns block hash of the requested block |
|   1   | `getMnListDiff` | **Replaced by [`subscribeToMasternodeList`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetomasternodelist) in Dash Platform v1.0.0** |

## gRPC Endpoints

### Core gRPC Service

| Layer | Endpoint |   |
| :---: | -------- | - |
|   1   | [`broadcastTransaction`](../reference/dapi-endpoints-core-grpc-endpoints.md#broadcasttransaction) | Broadcasts the provided transaction |
|   1   | [`getBestBlockHeight`](../reference/dapi-endpoints-core-grpc-endpoints.md#getbestblockheight) | *Added in Dash Platform v1.0.0*<br>Return the best block height|
|   1   | [`getBlock`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblock) | **Disabled in Dash Platform v1.0.0**<br>Returns information for the requested block |
|   1   | [`getBlockchainStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblockchainstatus) | *Added in Dash Platform v1.0.0*<br>Returns blockchain status information |
|   1   | [`getMasternodeStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getmasternodestatus) | **Disabled in Dash Platform v1.0.0**<br>Returns masternode status information |
|   1   | `getStatus` | **Deprecated in Dash Platform v1.0.0**<br>Split into [`getBlockchainStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblockchainstatus) and [`getMasternodeStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getmasternodestatus).<br>Returns blockchain status information |
|   1   | [`getTransaction`](../reference/dapi-endpoints-core-grpc-endpoints.md#gettransaction) | Returns details for the requested transaction |
|   1   | [`subscribeTo` `BlockHeadersWithChainLocks`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetoblockheaderswithchainlocks) | Returns the requested block headers along with the associated ChainLocks. |
|   1   | [`subscribeToMasternodeList`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetomasternodelist) | *Added in Dash Platform v1.0.0*<br>Returns the full masternode list from the genesis block to the chain tip as the first message and provides update messages with every new block |
|   1   | [`subscribeTo` `TransactionsWithProofs`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetotransactionswithproofs) | Returns transactions matching the provided bloom filter along with the associated [`islock` message](https://docs.dash.org/projects/core/en/stable/docs/reference/p2p-network-instantsend-messages.html#islock) and [merkle block](https://docs.dash.org/projects/core/en/stable/docs/reference/p2p-network-data-messages.html#merkleblock) |

### Platform gRPC Service

In addition to providing the request data, the following endpoints can also provide proofs that the
data returned is valid and complete. The endpoints are versioned so updates can be made to them without introducing issues for endpoint consumers.

| Layer | Endpoint |   |
| :---: | -------- | - |
|   2   | [`broadcastStateTransition`](../reference/dapi-endpoints-platform-endpoints.md#broadcaststatetransition) | Broadcasts the provided State Transition |
|   2   | [`getContestedResources`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresources) | *Added in Dash Platform v1.0.0*<br>Retrieves the contested resources for a specific contract, document type, and index. |
|   2   | [`getContestedResourceIdentityVotes`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresourceidentityvotes) | *Added in Dash Platform v1.0.0*<br>Retrieves the voting record of a specific identity. |
|   2   | [`getContestedResourceVotersForIdentity`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresourcevotersforidentity) | *Added in Dash Platform v1.0.0*<br>Retrieves the voters for a specific identity associated with a contested resource. |
|   2   | [`getContestedResourceVoteState`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresourcevotestate) | *Added in Dash Platform v1.0.0*<br>Retrieves the state of a vote for a specific contested resource. |
|   2   | [`getCurrentQuorumsInfo`](../reference/dapi-endpoints-platform-endpoints.md#getcurrentquorumsinfo) | **Added in Dash Platform v1.4.0**<br>Retrieves current quorum details, including validator sets and metadata for each quorum. |
|   2   | [`getEvonodesProposedEpochBlocksByIds`](../reference/dapi-endpoints-platform-endpoints.md#getevonodesproposedepochblocksbyids) | **Added in Dash Platform v1.3.0**<br>Retrieves the number of blocks proposed by the specified evonodes in a certain epoch, based on their IDs |
|   2   | [`getEvonodesProposedEpochBlocksByRange`](../reference/dapi-endpoints-platform-endpoints.md#getevonodesproposedepochblocksbyrange) | **Added in Dash Platform v1.3.0**<br>Retrieves the number of blocks proposed by evonodes for a specified epoch |
|   2   | [`getIdentity`](../reference/dapi-endpoints-platform-endpoints.md#getidentity) | Returns the requested identity |
|   2   | [`getIdentityBalance`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybalance) | Returns the requested identity's balance |
|   2   | [`getIdentityBalanceAndRevision`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybalanceandrevision) | Returns the requested identity's balance and revision |
|   2   | [`getIdentityByPublicKeyHash`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybypublickeyhash) | Returns the identity associated with the provided public key hash |
|   2   | [`getIdentityContractNonce`](../reference/dapi-endpoints-platform-endpoints.md#getidentitycontractnonce) | Returns the identity contract nonce |
|   2   | [`getIdentityKeys`](../reference/dapi-endpoints-platform-endpoints.md#getidentitykeys) | Returns the requested identity keys
|   2   | [`getIdentityNonce`](../reference/dapi-endpoints-platform-endpoints.md#getidentitynonce) | Returns the current identity nonce |
|   2   | `getIdentities` | **Removed in Dash Platform v1.0.0**<br>Returns the requested identities |
|   2   | [`getIdentitiesBalances`](../reference/dapi-endpoints-platform-endpoints.md#getidentitiesbalances) | **Added in Dash Platform v1.3.0**<br>Retrieves the balances for a list of identities |
|   2   | [`getIdentitiesContractKeys`](../reference/dapi-endpoints-platform-endpoints.md#getidentitiescontractkeys) | *Added in Dash Platform v1.0.0*<br>Returns keys associated to a specific contract for multiple Identities |
|   2   | `getIdentitiesByPublicKeyHashes` | **Removed in Dash Platform v1.0.0**<br>Returns the identities associated with the provided public key hashes |
|   2   | [`getDataContract`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontract) | Returns the requested data contract |
|   2   | [`getDataContracts`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontracts) | Returns the requested data contracts |
|   2   | [`getDataContractHistory`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontracthistory) | Returns the requested data contract history |
|   2   | [`getDocuments`](../reference/dapi-endpoints-platform-endpoints.md#getdocuments) | Returns the requested document(s) |
|   2   | [`getEpochsInfo`](../reference/dapi-endpoints-platform-endpoints.md#getepochsinfo) | Returns information about the requested epoch(s)
|   2   | [`getPathElements`](../reference/dapi-endpoints-platform-endpoints.md#getpathelements) | *Added in Dash Platform v1.0.0*<br>Returns elements for a specified path in the Platform |
|   2   | [`getPrefundedSpecializedBalance`](../reference/dapi-endpoints-platform-endpoints.md#getprefundedspecializedbalance) | *Added in Dash Platform v1.0.0*<br>Returns the pre-funded specialized balance for a specific identity |
|   2   | `getProofs` | **Disabled for external use in Dash Platform v1.0.0**<br>Returns proof information for the requested identities, contracts, and/or document(s) |
|   2   | [`getProtocolVersionUpgradeState`](../reference/dapi-endpoints-platform-endpoints.md#getprotocolversionupgradestate) | Returns the number of votes cast for each protocol version
|   2   | [`getProtocolVersionUpgradeVoteStatus`](../reference/dapi-endpoints-platform-endpoints.md#getprotocolversionupgradevotestatus) | Returns protocol version upgrade status |
|   2   | [`getStatus`](../reference/dapi-endpoints-platform-endpoints.md#getstatus) | **Added in Dash Platform v1.2.0**<br>Retrieves status information related to Dash Platform |
|   2   | [`getTotalCreditsInPlatform`](../reference/dapi-endpoints-platform-endpoints.md#gettotalcreditsinplatform) | **Added in Dash Platform v1.1.0**<br>Retrieves the total credits in the platform |
|   2   | [`getVotePollsByEndDate`](../reference/dapi-endpoints-platform-endpoints.md#getvotepollsbyenddate) | Retrieves vote polls that will end within a specified date range |
|   2   | [`waitForStateTransitionResult`](../reference/dapi-endpoints-platform-endpoints.md#waitforstatetransitionresult) | Responds with the state transition hash and either a proof that the state transition was confirmed in a block or an error |

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<div></div>\n<!--\nPrimarily for debugging, don't document - getConsensusParams\n-->\n<style></style>"
  }
  [/block]
```

:::{note}
The previous version of documentation can be [viewed
here](https://docs.dash.org/projects/platform/en/0.25.0/docs/reference/dapi-endpoints.html).
:::

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

dapi-endpoints-json-rpc-endpoints
dapi-endpoints-grpc-overview
dapi-endpoints-core-grpc-endpoints
dapi-endpoints-platform-endpoints
```
