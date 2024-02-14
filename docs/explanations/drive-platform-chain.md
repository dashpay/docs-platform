```{eval-rst}
.. _explanations-platform-chain:
```

# Platform Chain

## Overview

The platform chain is the [Drive](../explanations/drive.md) component responsible for replicating the platform state across all masternodes participating in the network. Masternodes operate this Proof of Service (PoSe) chain to provide layer 2 consensus and support Dash Platform-specific requirements without impacting layer 1 functionality. Although the platform chain can read from the Dash layer 1 core blockchain, the core blockchain is not dependent on it or aware of it.

## Details

### Evolution of design

Early designs of Drive were based on using on the layer 1 core blockchain and [IPFS](https://docs.ipfs.io/introduction/overview/) to replicate layer 2 data. As the design matured, a number of challenges led to a re-evaluation of how to efficiently secure, propagate, and finalize this data. Ultimately, meeting the requirements for a trustless, decentralized system led to choosing a blockchain-based solution over some seemingly obvious choices that work fine in a centralized setting.

### Characteristics

In order to support Dash Platform's performance requirements, the platform chain has the following design characteristics:

- Relies on masternode Proof of Service, not miner Proof of Work (PoW)
- Hosted exclusively on masternodes
- Uses a [practical Byzantine Fault Tolerance (pBFT)](../reference/glossary.md#practical-byzantine-fault-tolerance-pbft) consensus algorithm
- Has a deterministic fee structure
- Provides fast (< 10 seconds) and absolute block finality (no reorgs)

### Blocks and Transitions

Similar to transactions on the Dash core chain, state transitions are aggregated and put into blocks periodically on the platform chain. Each block has a header that points back to the previous block, thus forming a chain of blocks that is shared among all masternodes. The platform's pBFT consensus algorithm is responsible for ordering the state transitions into a block and then committing the block. As soon as a block is accepted by a ⅔ + 1 majority of validators, it becomes final and cannot be changed. Thus, the platform chain is not susceptible to blockchain reorganizations.
