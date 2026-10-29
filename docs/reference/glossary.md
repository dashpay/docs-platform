```{eval-rst}
.. _reference-glossary:
```

# Glossary

## Application

The combination of Application Identity, Data Contract, and Application State that together represent a Dash Platform Application

## Application State

The collection of documents created by users during their use of an application

## Block

One or more transactions prefaced by a block header and protected by proof of work. Blocks are the data stored on the [core blockchain](#core-chain)

## Block Reward

The amount that miners may claim as a reward for creating a block. Equal to the sum of the block subsidy (newly available duffs) plus the transactions fees paid by transactions included in the block

## ChainLock

Defined in [DIP8](https://github.com/dashpay/dips/blob/master/dip-0008.md), ChainLocks are a method of using an LLMQ to threshold sign a block immediately after it is propagated by the miner in order to enforce the first-seen rule. This powerful method of mitigating 51% mining attacks results in near-instant consensus on the valid chain.

## Classical Transactions

Standard Dash transactions moving Dash on the core blockchain ledger

## Coinbase Transaction

The first transaction in a block. Always created by a miner, it includes a single coinbase.

## Core Chain

Layer 1 blockchain used for payments, governance, and providing the foundation for tier 2 masternode infrastructure (LLMQs, DML, PoSe, etc.)

## Credits

Means of paying fees on the layer 2 platform. Credits are the smallest unit of account on Platform:
1 duff = 1,000 credits, and 1 Dash = 100,000,000,000 credits. See [Protocol
constants](../protocol-ref/protocol-constants.md#credit-system) for the full conversion table.

## DAPI  

Dash's decentralized API for interacting with the core blockchain (layer 1) and the platform (layer 2)

## DAPI Client  

A client that connects to DAPI to read and write Platform data or access Core chain information.
DAPI exposes gRPC services for Platform and Core, plus JSON-RPC for selected Core information and
Platform status.

## DashPay

Dash Platform based wallet supporting payments via usernames

## DashPay Contact Request

A platform document that defines a one way relationship between a sender and a recipient. It includes an encrypted extended public key which will allow the sender to pay the recipient using addresses that other users have no knowledge of. The sender creates and publishes this document. When two users have both sent contact requests to each other, then each is considered a fully established contact with the other.

## DashPay Contact Info

A platform document containing an identity's set of private information related to other identities that are contacts.

## DashPay Profile

A platform document containing a set of public information for an identity that includes a display name, a public message (bio/status) and an avatar URL. The display name and avatar help complement the identity's username from DPNS to better visually identify an identity in a user interface. An identity can only have a single DashPay profile.

## Dash Core  

Layer 1 core blockchain reference client

## Data Contract

The database schema a developer submits in order to start using Dash Platform as a back end for their application

## Dash Platform Application

A client application that leverages Dash Platform services

## Dash Platform Naming Service (DPNS)

A service used to register names on the Dash Platform. Can be extended to work in a DNS-like mode. Implemented as an application on top of the platform that leverages platform capabilities

## Dash Platform Protocol (DPP)

Describes data structures and validation rules for the data structures used by the platform (e.g. Data Contract, Document, and State Transition). Data structures are defined using JSON-Schema based format

## Decentralized Autonomous Organization (DAO)

An organization where decision making is governed according to a set of rules that is transparent, controlled by organization members, and lacking any central authority. Financial records are tracked using a blockchain, which provides the transparency and trust required by organization members.

## Devnet

A development environment in which developers can obtain and spend Dash that has no real-world value on a network that is very similar to the Dash [mainnet](#mainnet). Multiple independent devnets can coexist without interference. Devnets can be either public or private networks. See the <a href="https://docs.dash.org/en/stable/docs/core/examples/testing-applications.html" target="_blank">Testing Applications page</a> for a more detailed description of network types.

## Direct Settlement Payment Channel (DSPC)

In DashPay, established contacts have address spaces to send and receive from each other. When these are present either in one way or bi-directional we will call this a direct settlement payment channel.

## Distributed Key Generation (DKG)

Distributed key generation (DKG) is a cryptographic process in which multiple parties contribute to the calculation of a shared public and private key set. In Dash, DKG is used to generate a BLS key pair for use in a [long-living masternode quorum](#long-living-masternode-quorum-llmq) (LLMQ) to perform threshold signing on network messages. Further detail can be found in [DIP-6 Long-Living Masternode Quorums](https://github.com/dashpay/dips/blob/master/dip-0006.md#llmq-dkg-network-protocol).

## Document

A data entry, similar to a  document in a document-oriented database. Represented as a JSON.  An atomic entity used by the platform to store the user-submitted data

## Drive  

Layer 2 platform storage

## Epoch

An epoch is a fixed time period used to organize and manage blockchain operations. Dash Platform epochs are exactly 9.125 days (219 hours), resulting in 40 epochs (one [era](#era)) per year. Evonode reward payouts happen at the end of each epoch based on an evonode's validator set participation. The first epoch began at the genesis of Dash Platform.

**Note:** Epochs are not determined by a certain number of blocks, but by a certain unix timestamp.

## Era

An era consists of 40 [epochs](#epoch) and equals approximately one year. At the end of an era, Dash Platform may optionally do additional accounting or reconfiguration. Document storage is prepaid for 50 eras.

## Evonode

An evolution masternode: a [masternode](#masternode) that meets the additional collateral and hardware requirements to run Dash Platform services alongside Dash Core. Only evonodes participate in the [validator set](#validator-set) that produces Platform blocks, and evonode operators receive Platform block rewards for that participation.

## Group (data contract)

A set of identities defined in a [data contract](#data-contract) that jointly authorize actions on that contract, such as token minting or configuration changes. Each member is assigned a voting power, and an action executes once the members approving it reach the group's required power threshold. Distinct from a [quorum](#quorum), which is a set of masternodes selected by the network to sign protocol-level actions.

## History (contract revision)

The record of successive revisions of a [data contract](#data-contract), retained when the contract sets `keepsHistory` at creation. Retrieved with [`getDataContractHistory`](../reference/dapi-endpoints-platform-endpoints.md#getdatacontracthistory). This tracks changes to the contract definition itself, not to the documents stored under it. See [Retrieve data contract history](../tutorials/contracts-and-documents/retrieve-data-contract-history.md).

## History (document revision)

The record of successive revisions of an individual [document](#document), retained when its document type sets `documentsKeepHistory`. Retrieved with [`getDocumentHistory`](../reference/dapi-endpoints-platform-endpoints.md#getdocumenthistory). This tracks edits to a document's own fields, not its transfers or sales.

## History (document ownership and pricing)

The record of transfers, purchases and price updates for documents, written to the [document history system contract](../protocol-ref/data-contract.md#document-history-system-contract). Document types opt in with the [document history flags](../protocol-ref/data-contract-document.md#document-history-flags) `keepsTransferHistory`, `keepsPurchaseHistory` and `keepsPricingHistory`. This is separate from both revision histories above: it records ownership and pricing events rather than changes to contract or document content.

## Identity

A Platform entity identified by a 32-byte identifier. An identity holds a set of public keys and a [credit](#credits) balance, and signs most [state transitions](#state-transition). Documents, tokens, and contracts are all created and updated on behalf of one. See [Identity](../explanations/identity.md).

## Index-Only Document Type

A [document](#document) type whose documents are never written to primary storage - its index entries are the rows. Only what the indices hold exists and is recoverable, which makes the type cheaper to store but queryable only along its declared indices. Introduced at protocol version 14. See [indexOnly document types](../reference/data-contracts.md#indexonly-document-types).

## Layer (1, 2, 3)  

- Layer 1: Core blockchain and [Dash Core](#dash-core)
- Layer 2: Drive and DAPI
- Layer 3: DAPI clients

## Local network

A configuration unique to [dashmate](https://www.npmjs.com/package/dashmate) that uses Dash Core's [regtest](#regtest) network type to create a multi-node network on a single computer. This configuration allows developers to work independently on their own network for testing and development.

## Long Living Masternode Quorum (LLMQ)  

Deterministic subset of the global deterministic masternode list used to perform threshold signing of consensus-related messages

## Mainnet

The original and main network for Dash transactions, where transactions have real economic value.

## Masternode  

2nd-tier collateralized Node in the Dash P2P network, performing additional functions and forming a provision layer

## Platform Address

An account in Platform's address system, holding a credit balance that is not tied to an [identity](#identity). Address-system [state transitions](#state-transition) carry no owner identity. See [Address system](../protocol-ref/address-system.md).

## Platform Chain

Layer 2 blockchain that propagates platform data among masternodes, propagates platform blocks among masternodes, applies Layer 2 consensus, authoritatively orders state transitions, and controls platform state consistency

## Platform State

All Platform data including contracts, documents (user data), [tokens](#token), groups, [contract groups](../explanations/platform-protocol-data-contract.md#contract-groups), credit balance, [identity](#identity) (username), [address](#platform-address) balances, [shielded pool](#shielded-pool) state, and masternode voting/contested resource state. Platform state also includes protocol bookkeeping such as fee and epoch pools, pre-funded specialized balances, spent asset lock transactions, saved block transactions, withdrawal transactions, and proposer-desired protocol versions.

## practical Byzantine Fault Tolerance (pBFT)

A consensus algorithm designed to work efficiently in asynchronous environments while assuming the presence of adversarial actors. Advantages of pBFT include energy efficiency, transaction finality, and low reward variance.

## Proof of Service (PoSe)  

Ability to trustlessly prove that a [masternode](#masternode) provided the required service to the network in order to earn a reward

## Proof of Work (PoW)

Ability to trustlessly prove that a node completed a certain amount of work during the process of confirming a new block to the blockchain.

## Quorum  

Group of masternodes signing some action, formation of the group determined by some determination algorithm

## Quorum Signature  

BLS signature resulting from some agreement within a masternode quorum

## Ranked Index

An [index](../reference/data-contracts.md#document-indices) carrying a ranking axis, letting Platform answer "top or bottom K groups by aggregate value" queries with proofs. Each axis - count, sum, or average - adds its own ordered secondary tree and is opted into separately. Introduced at protocol version 14. See [Ranked index flags](../reference/data-contracts.md#ranked-index-flags) and [Ranked aggregate queries](../reference/query-syntax.md#ranked-aggregate-queries).

## Regtest

A local regression testing environment in which developers can almost instantly generate blocks on demand for testing events, and can create private Dash with no real-world value. See the <a href="https://docs.dash.org/en/stable/docs/core/examples/testing-applications.html" target="_blank">Testing Applications page</a> for a more detailed description of network types.

## Shielded Pool

Platform's privacy pool, holding value whose ownership and amounts are hidden from public state. Shielded-pool [state transitions](#state-transition) carry no owner identity. See [Shielded pool](../explanations/shielded-pool.md).

## Simple Payment Verification

A method for verifying if transactions are part of a block without downloading the whole block. This is useful for lightweight clients which don't run continuously and which don't have the storage space or bandwidth for a full copy of the blockchain.

## Special Transactions  

Transactions containing an extra payload using the format defined by [DIP-2](https://github.com/dashpay/dips/blob/master/dip-0002.md)

## State Machine

The application that validates state transitions and updates state in Drive

## State Transition

A signed change to platform state. Most state transitions are submitted by an identity, but some are not owned by one - the address-system and shielded-pool transitions carry no owner identity. State transitions cover a range of operations, including data contract creation and updates, document and token changes (batched), identity lifecycle operations (create, top-up, update), credit transfers and withdrawals, address-system and shielded-pool operations, and masternode voting (cast by masternode and evonode operators)

## Tenderdash

Dash fork of [Tendermint](https://tendermint.com/core) modified for use in Dash Platform. See [Platform Consensus](../explanations/platform-consensus.md) for more information.

## Testnet

A global testing environment in which developers can obtain and spend Dash that has no real-world value on a network that is very similar to the Dash [mainnet](#mainnet). See the <a href="https://docs.dash.org/en/stable/docs/core/examples/testing-applications.html" target="_blank">Testing Applications page</a> for a more detailed description of network types.

See: [Intro to Testnet](../intro/testnet.md) for more information

## Time-Range Index

An [index](../reference/data-contracts.md#document-indices) that buckets a timestamp property into fixed-length, regularly spaced windows, enabling trending and leaderboard queries scoped to a time window. Introduced at protocol version 14. See [Ranked index flags](../reference/data-contracts.md#ranked-index-flags) and [Time-range selection](../reference/query-syntax.md#time-range-selection).

## Token

A fungible asset defined by a [data contract](#data-contract) and tracked in [platform state](#platform-state). A contract may define multiple tokens, each with its own supply rules, distribution schedule, and authorization - which may be delegated to a [group](#group-data-contract). See [Tokens](../explanations/tokens.md).

## Validator Set

The group of masternodes responsible for the layer 2 blockchain (platform chain) consensus at a given time. They vote on the content of each platform chain block and are analogous to miners on the layer 1's core blockchain
