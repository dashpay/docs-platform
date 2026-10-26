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
| [`getDataContractsByRange`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontractsbyrange) | **Added in Dash Platform v5.0.0**<br>Enumerates every data contract on Platform, one page at a time, in ascending contract ID order. |
| [`getDataContractsLatestVersions`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontractslatestversions) | **Added in Dash Platform v5.0.0**<br>Returns the current version number of each requested data contract. Clients can use this to check whether contracts they already hold are still current without downloading the contracts again. |
| [`getContractFeePots`](../reference/dapi-endpoints-platform-endpoints.md#getcontractfeepots) | **Added in Dash Platform v5.0.0**<br>Returns the two fee pots of a data contract. |
| [`getDocuments`](../reference/dapi-endpoints-platform-endpoints.md#getdocuments) | **Updated in Dash Platform v4.2.0**<br>Returns the requested document(s), or an aggregate count/sum/average over the matched document set. Includes ranked, having-range, chained, and composite query modes and the `IN_TIME_RANGE` operator. |
| [`getDocumentHistory`](../reference/dapi-endpoints-platform-endpoints.md#getdocumenthistory) | *Added in Dash Platform v4.0.0*<br>Returns the revision history for a single document on a contract that keeps document history |

### Contract Moderation

:::{versionadded} 5.0.0
:::

Contract moderation, introduced in protocol version 14, lets a data contract keep a banlist, a suspension list, and a warning list of identities, and lets its moderators delete documents. A contract's moderators are its owner, identities it appoints, or a team elected by masternodes. A banned or suspended identity cannot submit document transitions for the contract. The endpoints in this section read an identity's moderation status, the lists themselves, the records of removed documents, and the actions and action counts of an elected contract's seated moderation team.

| Endpoint | Description |
| -------- | ----------- |
| [`getContractModerationStatus`](../reference/dapi-endpoints-platform-endpoints.md#getcontractmoderationstatus) | **Added in Dash Platform v5.0.0**<br>Returns an identity's status on one or more moderation lists of a moderated data contract: whether it is banned, until when it is suspended, and which warnings it carries. |
| [`getContractModerationEntries`](../reference/dapi-endpoints-platform-endpoints.md#getcontractmoderationentries) | **Added in Dash Platform v5.0.0**<br>Returns one page of a moderated contract's banlist, suspension list, or warning list, in identity ID order. |
| [`getContractDocumentRemovals`](../reference/dapi-endpoints-platform-endpoints.md#getcontractdocumentremovals) | **Added in Dash Platform v5.0.0**<br>Returns the removal records of documents that a contract's moderators deleted from one document type, either for specific document IDs or as a page in document ID order. A record shows who removed the document, when, and why, and whether it has since been restored. |
| [`getContractTeamActions`](../reference/dapi-endpoints-platform-endpoints.md#getcontractteamactions) | **Added in Dash Platform v5.0.0**<br>Returns one page of the actions that an elected contract's seated moderation team is voting on (active) or has carried out (closed), in action ID order. |
| [`getContractTeamActionSigners`](../reference/dapi-endpoints-platform-endpoints.md#getcontractteamactionsigners) | **Added in Dash Platform v5.0.0**<br>Returns the team members that approved one of the actions an elected contract's seated moderation team votes on. |
| [`getContractModerationActionCounts`](../reference/dapi-endpoints-platform-endpoints.md#getcontractmoderationactioncounts) | **Added in Dash Platform v5.0.0**<br>Returns how many counted moderation actions (bans, suspensions, warnings, and document deletions) each member of an elected contract's seated moderation team has signed since the moderators fee pot was last settled. |

### Identities

| Endpoint | Description |
| -------- | ----------- |
| [`getIdentity`](../reference/dapi-endpoints-platform-endpoints.md#getidentity) | Returns the requested identity |
| [`getIdentityBalance`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybalance) | Returns the requested identity's balance |
| [`getIdentityBalanceAndRevision`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybalanceandrevision) | Returns the requested identity's balance and revision |
| [`getIdentityByNonUniquePublicKeyHash`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybynonuniquepublickeyhash) | *Added in Dash Platform v2.0.0*<br>Returns one or more identities associated with a public key hash, including for non-unique masternode keys. |
| [`getIdentityByPublicKeyHash`](../reference/dapi-endpoints-platform-endpoints.md#getidentitybypublickeyhash) | Returns the identity associated with the provided public key hash |
| [`getIdentityContractNonce`](../reference/dapi-endpoints-platform-endpoints.md#getidentitycontractnonce) | Returns the identity contract nonce |
| [`getIdentityKeys`](../reference/dapi-endpoints-platform-endpoints.md#getidentitykeys) | Returns the requested identity keys |
| [`getIdentityKeysRemainingBudgets`](../reference/dapi-endpoints-platform-endpoints.md#getidentitykeysremainingbudgets) | **Added in Dash Platform v5.0.0**<br>Returns what is left of the credit budgets of an identity's keys. |
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

### Contract Groups

:::{versionadded} 5.0.0
:::

From protocol version 14, contract groups organize data contracts, document types, and tokens into an identity-owned collection, which authentication keys can be scoped to. Each group has an owner, optional admins, and an optional name and description. Contract groups are not the same as security groups: security groups are defined inside a data contract and their member identities jointly authorize token actions, while the members of a contract group are contracts, document types, and tokens.

| Endpoint | Description |
| -------- | ----------- |
| [`getContractGroupInfo`](../reference/dapi-endpoints-platform-endpoints.md#getcontractgroupinfo) | Retrieves the stored information of a contract group: its owner, admins, name, and description. |
| [`getContractGroupMembers`](../reference/dapi-endpoints-platform-endpoints.md#getcontractgroupmembers) | Retrieves one page of a contract group's members of a single kind: member contracts, member document types, or member tokens. |
| [`getContractGroupsForContract`](../reference/dapi-endpoints-platform-endpoints.md#getcontractgroupsforcontract) | Retrieves the contract groups a data contract belongs to, whether as a whole contract, through its document types, or through its tokens. |

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
| [`getEpochsInfo`](../reference/dapi-endpoints-platform-endpoints.md#getepochsinfo) | Returns information about the requested epoch(s) |
| [`getFinalizedEpochInfos`](../reference/dapi-endpoints-platform-endpoints.md#getfinalizedepochinfos) | *Added in Dash Platform v2.0.0*<br>Retrieves finalized epoch information within a specified index range |
| [`getPathElements`](../reference/dapi-endpoints-platform-endpoints.md#getpathelements) | *Added in Dash Platform v1.0.0*<br>Returns elements for a specified path in the Platform |
| [`getPrefundedSpecializedBalance`](../reference/dapi-endpoints-platform-endpoints.md#getprefundedspecializedbalance) | *Added in Dash Platform v1.0.0*<br>Returns the pre-funded specialized balance for a specific identity |
| [`getProtocolVersionUpgradeState`](../reference/dapi-endpoints-platform-endpoints.md#getprotocolversionupgradestate) | Returns the number of votes cast for each protocol version |
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
| [`getTokenContractInfo`](../reference/dapi-endpoints-platform-endpoints.md#gettokencontractinfo) | Retrieves contract information associated with a specific token ID. |
| [`getTokenDirectPurchasePrices`](../reference/dapi-endpoints-platform-endpoints.md#gettokendirectpurchaseprices) | Retrieves direct purchase prices defined for the specified token IDs. |
| [`getTokenPerpetualDistributionLastClaim`](../reference/dapi-endpoints-platform-endpoints.md#gettokenperpetualdistributionlastclaim) | Retrieves the last-claim timestamp for a token’s perpetual distribution for a specific identity. |
| [`getTokenPreProgrammedDistributions`](../reference/dapi-endpoints-platform-endpoints.md#gettokenpreprogrammeddistributions) | Retrieves pre-programmed distributions of a specified token. |
| [`getTokenStatuses`](../reference/dapi-endpoints-platform-endpoints.md#gettokenstatuses) | Retrieves the statuses of specified tokens. |
| [`getTokenTotalSupply`](../reference/dapi-endpoints-platform-endpoints.md#gettokentotalsupply) | Retrieves the total supply of a specified token, including aggregated user accounts and system-held amounts. |

### Address System

:::{versionadded} 3.0.0
:::

| Endpoint | Description |
| -------- | ----------- |
| [`getAddressInfo`](../reference/dapi-endpoints-platform-endpoints.md#getaddressinfo) | Returns balance and nonce information for a specified address. |
| [`getAddressesInfos`](../reference/dapi-endpoints-platform-endpoints.md#getaddressesinfos) | Returns balance and nonce information for multiple addresses. |
| [`getAddressesTrunkState`](../reference/dapi-endpoints-platform-endpoints.md#getaddressestrunkstate) | Returns a proof of the trunk state of the address tree. |
| [`getAddressesBranchState`](../reference/dapi-endpoints-platform-endpoints.md#getaddressesbranchstate) | Returns a Merkle proof for a branch of the address tree. |
| [`getRecentAddressBalanceChanges`](../reference/dapi-endpoints-platform-endpoints.md#getrecentaddressbalancechanges) | Returns recent address balance changes starting from a specified block height. |
| [`getRecentCompactedAddressBalanceChanges`](../reference/dapi-endpoints-platform-endpoints.md#getrecentcompactedaddressbalancechanges) | Returns compacted address balance changes from a specified block height. |

### Shielded Transactions

:::{attention}
Shielded Transaction endpoints are defined in the protocol but are not yet available on public nodes.
:::

:::{versionadded} 4.0.0
:::

| Endpoint | Description |
| -------- | ----------- |
| [`getShieldedEncryptedNotes`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedencryptednotes) | Returns encrypted notes from the shielded pool for a specified range. |
| [`getShieldedAnchors`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedanchors) | Returns all commitment tree anchors for the shielded pool. |
| [`getMostRecentShieldedAnchor`](../reference/dapi-endpoints-platform-endpoints.md#getmostrecentshieldedanchor) | Returns the most recent commitment tree anchor. |
| [`getShieldedPoolState`](../reference/dapi-endpoints-platform-endpoints.md#getshieldedpoolstate) | Returns the total balance held in the shielded pool. |
| [`getShieldedNotesCount`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednotescount) | Returns the count of leaves in the shielded notes commitment tree, used to seed shielded sync progress. |
| [`getShieldedNullifiers`](../reference/dapi-endpoints-platform-endpoints.md#getshieldednullifiers) | Returns the spent status of specified nullifiers. |

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

These endpoints historically expose Core information; `getStatus` is the exception and returns
Platform status.

| Endpoint | Description |
| -------- | ----------- |
| [`getBestBlockHash`](../reference/dapi-endpoints-json-rpc-endpoints.md#getbestblockhash) | Returns block hash of the chaintip |
| [`getBlockHash`](../reference/dapi-endpoints-json-rpc-endpoints.md#getblockhash)         | Returns block hash of the requested block |
| [`getStatus`](../reference/dapi-endpoints-json-rpc-endpoints.md#getstatus) | Returns Platform status information |
| [`sendRawTransaction`](../reference/dapi-endpoints-json-rpc-endpoints.md#sendrawtransaction) | Submits a raw transaction to the network |

### gRPC Endpoints

| Endpoint | Description |
| -------- | ----------- |
| [`broadcastTransaction`](../reference/dapi-endpoints-core-grpc-endpoints.md#broadcasttransaction) | Broadcasts the provided transaction |
| [`getBestBlockHeight`](../reference/dapi-endpoints-core-grpc-endpoints.md#getbestblockheight) | *Added in Dash Platform v1.0.0*<br>Return the best block height|
| [`getBlock`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblock) | Returns information for the requested block |
| [`getBlockchainStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getblockchainstatus) | *Added in Dash Platform v1.0.0*<br>Returns blockchain status information |
| [`getMasternodeStatus`](../reference/dapi-endpoints-core-grpc-endpoints.md#getmasternodestatus) | Returns masternode status information |
| [`getTransaction`](../reference/dapi-endpoints-core-grpc-endpoints.md#gettransaction) | Returns details for the requested transaction |
| [`subscribeTo` `BlockHeadersWithChainLocks`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetoblockheaderswithchainlocks) | Returns the requested block headers along with the associated ChainLocks. |
| [`subscribeToMasternodeList`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetomasternodelist) | *Added in Dash Platform v1.0.0*<br>Returns the full masternode list from the genesis block to the chain tip as the first message and provides update messages with every new block |
| [`subscribeTo` `TransactionsWithProofs`](../reference/dapi-endpoints-core-grpc-endpoints.md#subscribetotransactionswithproofs) | Returns transactions matching the provided bloom filter along with the associated [`islock` message](https://docs.dash.org/en/stable/docs/core/reference/p2p-network-instantsend-messages.html#islock) and [merkle block](https://docs.dash.org/en/stable/docs/core/reference/p2p-network-data-messages.html#merkleblock) |

:::{note}
The previous version of documentation can be [viewed
here](https://docs.dash.org/projects/platform/en/4.1.0/docs/reference/dapi-endpoints.html).
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
