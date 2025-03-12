```{eval-rst}
.. _reference-dapi-endpoints:
```

# DAPI Endpoints

## Overview

[DAPI](../explanations/dapi.md) currently provides 2 types of endpoints:
[JSON-RPC](https://www.jsonrpc.org/) and [gRPC](https://grpc.io/docs/guides/). The JSON-RPC
endpoints expose some layer 1 information while the gRPC endpoints support layer 2 as well as
streaming of events related to blocks and transactions/transitions.

## Platform Endpoints

In addition to providing the requested data, the following endpoints can also provide proofs that
the data returned is valid and complete. The endpoints are versioned so updates can be made to them
without introducing issues for endpoint consumers.

### Contested Resources

| Endpoint | Description |
| -------- | ----------- |
| [`getContestedResources`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresources) | *Added in Dash Platform v1.0.0*<br>Retrieves the contested resources for a specific contract, document type, and index. |
| [`getContestedResourceIdentityVotes`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresourceidentityvotes) | *Added in Dash Platform v1.0.0*<br>Retrieves the voting record of a specific identity. |
| [`getContestedResourceVotersForIdentity`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresourcevotersforidentity) | *Added in Dash Platform v1.0.0*<br>Retrieves the voters for a specific identity associated with a contested resource. |
| [`getContestedResourceVoteState`](../reference/dapi-endpoints-platform-endpoints.md#getcontestedresourcevotestate) | *Added in Dash Platform v1.0.0*<br>Retrieves the state of a vote for a specific contested resource. |
| [`getVotePollsByEndDate`](../reference/dapi-endpoints-platform-endpoints.md#getvotepollsbyenddate) | Retrieves vote polls that will end within a specified date range |

### Data Contracts and Documents

| Endpoint | Description |
| -------- | ----------- |
| [`getDataContract`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontract) | Returns the requested data contract |
| [`getDataContracts`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontracts) | Returns the requested data contracts |
| [`getDataContractHistory`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontracthistory) | Returns the requested data contract history |
| [`getDocuments`](../reference/dapi-endpoints-platform-endpoints.md#getdocuments) | Returns the requested document(s) |

### Identities

| Endpoint | Description |
| -------- | ----------- |
| [`getIdentity`](../reference/dapi-endpoints-platform-endpoints.md#getidentity) | Returns the requested identity |
| [`getIdentityBalance`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybalance) | Returns the requested identity's balance |
| [`getIdentityBalanceAndRevision`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybalanceandrevision) | Returns the requested identity's balance and revision |
| [`getIdentityByPublicKeyHash`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybypublickeyhash) | Returns the identity associated with the provided public key hash |
| [`getIdentityContractNonce`](../reference/dapi-endpoints-platform-endpoints.md#getidentitycontractnonce) | Returns the identity contract nonce |
| [`getIdentityKeys`](../reference/dapi-endpoints-platform-endpoints.md#getidentitykeys) | Returns the requested identity keys
| [`getIdentityNonce`](../reference/dapi-endpoints-platform-endpoints.md#getidentitynonce) | Returns the current identity nonce |
| [`getIdentitiesBalances`](../reference/dapi-endpoints-platform-endpoints.md#getidentitiesbalances) | *Added in Dash Platform v1.3.0*<br>Retrieves the balances for a list of identities |
| [`getIdentitiesContractKeys`](../reference/dapi-endpoints-platform-endpoints.md#getidentitiescontractkeys) | *Added in Dash Platform v1.0.0*<br>Returns keys associated to a specific contract for multiple Identities |

### Security Groups

:::{versionadded} 2.0.0
:::

Security groups provide a way to distribute token configuration and update authorization across multiple identities. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action. The endpoints in this section are used to retrieve information about groups and the actions they are performing.

| Endpoint | Description |
| -------- | ----------- |
| [`getGroupInfo`](../reference/dapi-endpoints-platform-endpoints.md#getgroupinfo) | Retrieves information about a specific group within a contract, including its members and required power. |
| [`getGroupInfos`](../reference/dapi-endpoints-platform-endpoints.md#getgroupinfos) | Retrieves information about multiple groups within a contract, including their members and required power. |
| [`getGroupActions`](../reference/dapi-endpoints-platform-endpoints.md#getgroupactions) | Retrieves a list of actions performed by a specific group within a contract. |
| [`getGroupActionSigners`](../reference/dapi-endpoints-platform-endpoints.md#getgroupactionsigners) | Retrieves the signers for a specified group action within a contract, along with their assigned power. |

### State Transitions

| Endpoint | Description |
| -------- | ----------- |
| [`broadcastStateTransition`](../reference/dapi-endpoints-platform-endpoints.md#broadcaststatetransition) | Broadcasts the provided State Transition |
| [`waitForStateTransitionResult`](../reference/dapi-endpoints-platform-endpoints.md#waitforstatetransitionresult) | Responds with the state transition hash and either a proof that the state transition was confirmed in a block or an error |

### System Info

| Endpoint | Description |
| -------- | ----------- |
| [`getCurrentQuorumsInfo`](../reference/dapi-endpoints-platform-endpoints.md#getcurrentquorumsinfo) | *Added in Dash Platform v1.4.0*<br>Retrieves current quorum details, including validator sets and metadata for each quorum. |
| [`getEvonodesProposedEpochBlocksByIds`](../reference/dapi-endpoints-platform-endpoints.md#getevonodesproposedepochblocksbyids) | *Added in Dash Platform v1.3.0*<br>Retrieves the number of blocks proposed by the specified evonodes in a certain epoch, based on their IDs |
| [`getEvonodesProposedEpochBlocksByRange`](../reference/dapi-endpoints-platform-endpoints.md#getevonodesproposedepochblocksbyrange) | *Added in Dash Platform v1.3.0*<br>Retrieves the number of blocks proposed by evonodes for a specified epoch |
| [`getEpochsInfo`](../reference/dapi-endpoints-platform-endpoints.md#getepochsinfo) | Returns information about the requested epoch(s)
| [`getPathElements`](../reference/dapi-endpoints-platform-endpoints.md#getpathelements) | *Added in Dash Platform v1.0.0*<br>Returns elements for a specified path in the Platform |
| [`getPrefundedSpecializedBalance`](../reference/dapi-endpoints-platform-endpoints.md#getprefundedspecializedbalance) | *Added in Dash Platform v1.0.0*<br>Returns the pre-funded specialized balance for a specific identity |
| `getProofs` | **Disabled for external use in Dash Platform v1.0.0**<br>Returns proof information for the requested identities, contracts, and/or document(s) |
| [`getProtocolVersionUpgradeState`](../reference/dapi-endpoints-platform-endpoints.md#getprotocolversionupgradestate) | Returns the number of votes cast for each protocol version
| [`getProtocolVersionUpgradeVoteStatus`](../reference/dapi-endpoints-platform-endpoints.md#getprotocolversionupgradevotestatus) | Returns protocol version upgrade status |
| [`getStatus`](../reference/dapi-endpoints-platform-endpoints.md#getstatus) | *Added in Dash Platform v1.2.0*<br>Retrieves status information related to Dash Platform |
| [`getTotalCreditsInPlatform`](../reference/dapi-endpoints-platform-endpoints.md#gettotalcreditsinplatform) | *Added in Dash Platform v1.1.0*<br>Retrieves the total credits in the platform |

### Tokens

:::{versionadded} 2.0.0
:::

| Endpoint | Description |
| -------- | ----------- |
| [`getIdentityTokenBalances`](../reference/dapi-endpoints-platform-endpoints.md#getidentitytokenbalances) | Retrieves the token balances of a specified identity. |
| [`getIdentitiesTokenBalances`](../reference/dapi-endpoints-platform-endpoints.md#getidentitiestokenbalances) | Retrieves the token balances for a list of specified identities. |
| [`getIdentityTokenInfos`](../reference/dapi-endpoints-platform-endpoints.md#getidentitytokeninfos) | Retrieves information about specified tokens for a given identity. |
| [`getIdentitiesTokenInfos`](../reference/dapi-endpoints-platform-endpoints.md#getidentitiestokeninfos) | Retrieves token information for a list of specified identities. |
| [`getTokenStatuses`](../reference/dapi-endpoints-platform-endpoints.md#gettokenstatuses) | Retrieves the statuses of specified tokens. |
| [`getTokenPreProgrammedDistributions`](../reference/dapi-endpoints-platform-endpoints.md#gettokenpreprogrammeddistributions) | Retrieves pre-programmed distributions of a specified token. |
| [`getTokenTotalSupply`](../reference/dapi-endpoints-platform-endpoints.md#gettokentotalsupply) | Retrieves the total supply of a specified token, including aggregated user accounts and system-held amounts. |

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<div></div>\n<!--\nPrimarily for debugging, don't document - getConsensusParams\n-->\n<style></style>"
  }
  [/block]
```

## Core Endpoints

The following endpoints provide information about the Core chain.

### JSON-RPC Endpoints

| Endpoint | Description |
| -------- | ----------- |
| [`getBestBlockHash`](../reference/dapi-endpoints-json-rpc-endpoints.md#getbestblockhash) | Returns block hash of the chaintip |
| [`getBlockHash`](../reference/dapi-endpoints-json-rpc-endpoints.md#getblockhash)         | Returns block hash of the requested block |

### gRPC Endpoints

| Endpoint | Description |
| -------- | ----------- |
| [`broadcastTransaction`](../reference/dapi-endpoints-core-grpc-endpoints.md#broadcasttransaction) | Broadcasts the provided transaction |
| [`getBestBlockHeight`](../reference/dapi-endpoints-core-grpc-endpoints.md#getbestblockheight) | *Added in Dash Platform v1.0.0*<br>Return the best block height|
| [`getBlock`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblock) | **Disabled in Dash Platform v1.0.0**<br>Returns information for the requested block |
| [`getBlockchainStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblockchainstatus) | *Added in Dash Platform v1.0.0*<br>Returns blockchain status information |
| [`getMasternodeStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getmasternodestatus) | **Disabled in Dash Platform v1.0.0**<br>Returns masternode status information |
| [`getTransaction`](../reference/dapi-endpoints-core-grpc-endpoints.md#gettransaction) | Returns details for the requested transaction |
| [`subscribeTo` `BlockHeadersWithChainLocks`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetoblockheaderswithchainlocks) | Returns the requested block headers along with the associated ChainLocks. |
| [`subscribeToMasternodeList`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetomasternodelist) | *Added in Dash Platform v1.0.0*<br>Returns the full masternode list from the genesis block to the chain tip as the first message and provides update messages with every new block |
| [`subscribeTo` `TransactionsWithProofs`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetotransactionswithproofs) | Returns transactions matching the provided bloom filter along with the associated [`islock` message](https://docs.dash.org/en/stable/docs/core/reference/p2p-network-instantsend-messages.html#islock) and [merkle block](https://docs.dash.org/en/stable/docs/core/reference/p2p-network-data-messages.html#merkleblock) |

:::{note}
The previous version of documentation can be [viewed
here](https://docs.dash.org/projects/platform/en/1.0.0/docs/reference/dapi-endpoints.html).
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
