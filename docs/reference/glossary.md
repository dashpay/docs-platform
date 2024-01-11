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

Means of paying fees on the layer 2 platform

## DAPI  

Dash's decentralized API for interacting with the core blockchain (layer 1) and the platform (layer 2)

## DAPI Client  

An HTTP Client that connects to DAPI to enable users to read and write data to the Dash platform

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

A development environment in which developers can obtain and spend Dash that has no real-world value on a network that is very similar to the Dash [mainnet](#mainnet). Multiple independent devnets can coexist without interference. Devnets can be either public or private networks. See the <a href="https://docs.dash.org/projects/core/en/stable/docs/examples/testing-applications.html" target="_blank">Testing Applications page</a> for a more detailed description of network types.

## Direct Settlement Payment Channel (DSPC)

In DashPay, established contacts have address spaces to send and receive from each other. When these are present either in one way or bi-directional we will call this a direct settlement payment channel.

## Distributed Key Generation (DKG)

Distributed key generation (DKG) is a cryptographic process in which multiple parties contribute to the calculation of a shared public and private key set. In Dash, DKG is used to generate a BLS key pair for use in a [long-living masternode quorum](#long-living-masternode-quorum-llmq) (LLMQ) to perform threshold signing on network messages. Further detail can be found in [DIP-6 Long-Living Masternode Quorums](https://github.com/dashpay/dips/blob/master/dip-0006.md#llmq-dkg-network-protocol).

## Document

A data entry, similar to a  document in a document-oriented database. Represented as a JSON.  An atomic entity used by the platform to store the user-submitted data

## Drive  

Layer 2 platform storage

## Layer (1, 2, 3)  

- Layer 1: Core blockchain and [Dash Core](#dash-core)
- Layer2: Drive and DAPI
- Layer 3: DAPI clients

## Local network

A configuration unique to [dashmate](https://www.npmjs.com/package/dashmate) that uses Dash Core's [regtest](#regtest) network type to create a multi-node network on a single computer. This configuration allows developers to work independently on their own network for testing and development.

## Long Living Masternode Quorum (LLMQ)  

Deterministic subset of the global deterministic masternode list used to perform threshold signing of consensus-related messages

## Mainnet

The original and main network for Dash transactions, where transaction have real economic value.

## Masternode  

2nd-tier collateralized Node in the Dash P2P network, performing additional functions and forming a provision layer

## Platform Chain

Layer 2 blockchain that propagates platform data among masternodes, propagates platform blocks among masternodes, applies Layer 2 consensus, authoritatively orders state transitions, and controls platform state consistency

## Platform State

All layer 2 data including contracts, documents (user data), credit balance, identity (username)

## practical Byzantine Fault Tolerance (pBFT)

A consensus algorithm designed to work efficiently in asynchronous environments while assuming the presence of adversarial actors. Advantages of pBFT include energy efficiency, transaction finality, and low reward variance.

## Proof of Service (PoSe)  

Ability to trustlessly prove that a [masternode](#masternode) provided the required service to the network in order to earn a reward

## Proof of Work (PoW)

Ability to trustlessly prove that a node completed a certain amount of work during the process of confirming a new block to the blockchain.

## Quorum  

Group of masternodes signing some action, formation of the group determined by via some determination algorithm

## Quorum Signature  

BLS signature resulting from some agreement within a masternode quorum

## Regtest

A local regression testing environment in which developers can almost instantly generate blocks on demand for testing events, and can create private Dash with no real-world value. See the <a href="https://docs.dash.org/projects/core/en/stable/docs/examples/testing-applications.html" target="_blank">Testing Applications page</a> for a more detailed description of network types.

## Simple Payment Verification

A method for verifying if transactions are part of a block without downloading the whole block. This is useful for lightweight clients which don't run continuously and which don't have the storage space or bandwidth for a full copy of the blockchain.

## Special Transactions  

Transactions containing an extra payload using the format defined by [DIP-2](https://github.com/dashpay/dips/blob/master/dip-0002.md)

## State Machine

The application that validates state transitions and updates state in Drive

## State Transition

The change a user does to the application and platforms states. Consists of an array of documents _or_ one data contract, the id of the application to which the change is made, and a user signature

## Tenderdash

Dash fork of [Tendermint](https://tendermint.com/core) modified for use in Dash Platform. See [Platform Consensus](../explanations/platform-consensus.md) for more information.

## Testnet

A global testing environment in which developers can obtain and spend Dash that has no real-world value on a network that is very similar to the Dash [mainnet](#mainnet). See the <a href="https://docs.dash.org/projects/core/en/stable/docs/examples/testing-applications.html" target="_blank">Testing Applications page</a> for a more detailed description of network types.

See: [Intro to Testnet](../intro/testnet.md) for more information

## Validator Set

The group of masternodes responsible for the layer 2 blockchain (platform chain) consensus at a given time. They vote on the content of each platform chain block and are analogous to miners on the layer 1's core blockchain
