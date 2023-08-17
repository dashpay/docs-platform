# Platform Consensus

Dash Platform is a decentralized network that requires its own consensus algorithm for decision-making and verifying state transitions. This consensus algorithm must fulfill the following three requirements:

** \* Fast write operations:** The Drive block time needs to be small since state transitions must be confirmed and applied to the state as quickly as possible.  
**  \* Fast reads:** Each block should update the state so that the data and cryptographic proofs can be read directly from the database. However, this needs to be done fast, so a consensus algorithm with faster reads is needed.  
**  \* Data consistency:** Nodes should always respond with the same data for a given block height to negate instances of blockchain reorgs.

Tendermint was selected as the consensus solution that most closely aligned with the requirements and goals of Dash Platform.

## Tendermint

Tendermint is a mostly asynchronous, pBFT-based consensus protocol. Here is a quick overview of how it works:

- Validators participate by taking turns to propose. They validate state transitions by voting on them.
- If a validator successfully validates a block, it gets added to the chain. Do note that voting on state transitions is indirect. Plus, validators don't work on individual transitions, but vote on a block of transitions. This method is a lot more resource-friendly.
- If a validator fails to add a block, the protocol automatically moves to the next round, and a new validator is chosen to propose the block.
- Following the proposal, Tendermint goes through two stages to voting – Pre-vote and Pre-Commit. 
- A block gets committed when it gets >2/3rd of the total validators pre-committing for it in one round. The sequence of Propose -> Pre-vote -> Pre-commit is one round. 
- In the event of a network dispute, Tendermint prefers consistency over availability.No additional blocks are confirmed or finalized until the dispute is resolved. This takes network reorg out of the equation.

Tendermint has been mainly designed to enable efficient verification and authentication of the latest state of the blockchain. It does so by embedding cryptographic commitments for certain information in the block "header." This information includes:

- Contents of the block.
- The Validator set committing the block.
- Various results returned by the application.

> 📘 Notes about Tendermint
> 
> - Block execution only occurs after a block is committed. So, cryptographic proofs for the latest state are only available in the subsequent block.
> 
> - Information like the transaction results and the validator set is never directly included in the block - only their Merkle roots are. 
> 
> - Verification of a block requires a separate data structure to store this information. We call this the “State.” 
> 
> - Block verification also requires access to the previous block.
> 
> Additional information about Tendermint is available in the <a href="https://docs.tendermint.com/master/spec/#overview" target="_blank">Tendermint Core spec</a>.

### Tendermint Limitations

While Tendermint provided a great starting point, implementing the classic version of the algorithm would have required us to start from scratch. For example, Tendermint validators use [EdDSA](https://en.wikipedia.org/wiki/EdDSA) cryptographic keys to sign votes during the consensus process. 

However, Dash already has a well-established network of Masternodes that use BLS keys and a [BLS threshold signing mechanism](https://blog.dash.org/secret-sharing-and-threshold-signatures-with-bls-954d1587b5f) to produce a single signature that mobile wallets and other light clients can easily verify. In addition, subsets of masternodes, called [Long-living Masternode Quorums (LLMQ)](https://github.com/dashpay/dips/blob/master/dip-0006.md), can perform BLS threshold signing on arbitrary messages. 

Rather than reinventing the wheel, Dash chose to fork the Tendermint code and integrate masternode quorums into the process to create a new consensus algorithm called "Tenderdash."

## Tenderdash

As with Tendermint, Tenderdash provides Byzantine Fault Tolerant (BFT) State Machine Replication via blocks containing transactions. Additionally, it has been updated to integrate some improvements that leverage Dash's LLMQs. Key mechanisms of the Tenderdash algorithm include:

- If enough members have signed the same message, a valid recovered threshold signature can be created and propagated to the rest of the network.
- Quorums are formed and rotated from time to time through distributed key generation (DKG) sessions.
- DKG chooses pseudorandom nodes from the deterministic masternode list.
- The resulting quorum is then committed to the core blockchain as a transaction. 
- The members of a quorum operate somewhat like validators but do so more efficiently due to the pre-existing BLS threshold signature.
- BLS threshold signing results in more compact block headers since only a single BLS threshold signature is required instead of individual signatures from each validator. Notably, this means that any client can easily verify the block signatures using the deterministic masternode list.
- The validators' signature is produced by an LLMQ, which is secured by the core blockchain’s Proof-of-Work (PoW).

This allows Dash Platform to leverage the best of both worlds – the speed and finality of Tendermint and the security of PoW.

### Dynamic Validator Set Rotation

Rather than having a static validator set, Tenderdash periodically changes to a new set of validator nodes. These validator sets are a subset of masternodes that belong to the LLMQs. 

The validator set is assigned to a new masternode quorum every 15 blocks (~2 mins). To determine the next quorum, the BLS threshold signature of the previous block is used as a [verifiable random function](https://en.wikipedia.org/wiki/Verifiable_random_function) to choose one of the available quorums. 

There are many advantages to adopting this dynamic rotation approach: 

- The validator set is less predictable, which reduces the window for attacks like DoS.
- The process balances the performance and security of platform chains like InstantSend and ChainLock quorum changes on the core chain.

## How Does Tenderdash Differ From Tendermint?

Here are the differences between Tenderdash and Tendermint:

- **Threshold Signatures**: Tenderdash employs threshold signatures for signing, adding an extra layer of security.
- **Quorum-Based Voting**: Tenderdash implements quorums, meaning not all validators participate in every voting round; only active quorum members are involved, enhancing efficiency.
- **Execution Timing**: Tenderdash facilitates same-block execution, optimizing transaction processing, whereas Tendermint traditionally relies on next-block execution.
- **Consensus Module Refactoring**: Tenderdash has undergone a complete overhaul of its vote-extensions and consensus module, working diligently to eliminate deadlocks and increase stability.
- **Dynamic Validator Management**: Tenderdash incorporates logic to actively connect with new validators in a set and disconnect those that are no longer in the validator set, thereby ensuring an adaptable and efficient network.
- **Project Activity**: Whereas Tenderdash continues to evolve and improve, Tendermint appears somewhat inactive lately, though this observation might be subjective.