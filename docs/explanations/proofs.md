```{eval-rst}
.. _explanations-proofs:
```

# Proofs

## Overview

Proofs are a fundamental security feature of Dash Platform that enable trustless verification of data. When retrieving information from the network, clients can request cryptographic proofs that allow them to verify the data's authenticity without trusting the individual node that provided it.

This is particularly important in a decentralized system where any single node could potentially return incorrect or malicious data. With proofs, clients can mathematically verify that:

- The data exists (or doesn't exist) in the platform state
- The state was agreed upon by the network's validator quorum
- No tampering occurred between the node and the client

Proofs enable light clients and mobile applications to interact securely with Dash Platform without running a full node or blindly trusting remote servers.

## How Proofs Work

Dash Platform uses a two-layer proof architecture that combines Merkle proofs from the storage layer with consensus signatures from the validator network.

### GroveDB Merkle Proofs

The first layer of verification uses [GroveDB](https://github.com/dashpay/grovedb), Dash Platform's authenticated data structure. GroveDB organizes all platform data in a tree structure where each piece of data contributes to a cryptographic hash that rolls up to a single root hash.

When a client requests data with a proof, GroveDB returns:

- The requested data (or proof of its absence)
- A Merkle path showing how the data connects to the root hash

This allows clients to independently calculate what the root hash should be and verify it matches. Any modification to the data would produce a different root hash, making tampering detectable.

### Tenderdash Consensus Signatures

The second layer connects the GroveDB root hash to the network's consensus. Dash Platform uses [Tenderdash](../explanations/platform-consensus.md), a Byzantine fault-tolerant consensus protocol, where validator quorums sign each block.

The proof includes:

- A BLS threshold signature from the validator quorum
- The quorum hash identifying which validators signed
- Block metadata (height, round, timestamp)

Clients verify that the root hash from the GroveDB proof matches what the quorum signed. Since producing a valid BLS threshold signature requires participation from more than two-thirds of the quorum members, this proves the network agreed on this exact state.

:::{tip}
BLS threshold signatures are particularly efficient because regardless of how many validators participated, the final signature is always the same compact size. This keeps proofs small even as the validator set scales.
:::

### Verification Flow

The complete verification process follows these steps:

1. Client sends a request to [DAPI](../explanations/dapi.md) with `prove: true`
2. DAPI retrieves the data and generates a proof from [Drive](../explanations/drive.md)
3. Client receives the response containing data, GroveDB proof, and consensus signature
4. Client verifies the GroveDB proof to extract the root hash
5. Client verifies the BLS signature against the root hash using the quorum's public key
6. If both verifications pass, the data is cryptographically confirmed

## What Can Be Proven

Dash Platform supports proofs for all core data types:

**Identities**

- Identity existence and full details
- Identity balance and revision
- Public keys associated with an identity
- Identity nonces (for replay protection)

**Data Contracts**

- Contract existence and contents
- Contract history (for contracts that track changes)

**Documents**

- Document existence within a contract
- Document queries with multiple results
- Proof of document absence (data doesn't exist)
- Aggregate values over a document set (count, sum, average) — see [Aggregate Proofs](#aggregate-proofs) below

**Tokens**

- Token balances for identities
- Token total supply
- Token status and configuration

**System State**

- Current epoch information
- Protocol version and upgrade status
- Contested resource voting state

## Aggregate Proofs

Beyond proving the existence and contents of individual documents, Dash Platform can produce verifiable answers to aggregate queries — questions about a *set* of documents, answered with one or more aggregate values instead of a list. This avoids streaming and verifying every matching document just to learn how many there are or what they sum to.

Three aggregate primitives are supported:

- **Count** — number of documents matching the query.
- **Sum** — sum of an integer field across matching documents.
- **Average** — average of an integer field across matching documents.

Some aggregate queries can return either one total or grouped totals, depending on the query shape.

Aggregate queries use the same two-layer verification as any other proof (GroveDB Merkle proof plus Tenderdash consensus signature), so the result carries the same trust model as other proven Platform responses.

For the exact request and response shapes, see the [DAPI Platform endpoints reference](../reference/dapi-endpoints-platform-endpoints.md).

## Requesting and Verifying Proofs

### DAPI Integration

The Decentralized API (DAPI) provides the interface for requesting proofs. When making queries, clients can set the `prove` parameter to receive cryptographic proofs alongside the data.

Without proofs, clients must trust that the DAPI node is returning accurate data. With proofs enabled, clients can verify responses independently, treating DAPI nodes as untrusted data carriers rather than trusted authorities.

:::{note}
The Dash Platform SDKs handle proof verification automatically when proofs are requested. Developers using the SDK don't need to implement verification logic manually.
:::

### What Verification Confirms

When a proof verifies successfully, the client has cryptographic assurance that:

1. **Data integrity**: The data matches exactly what is stored in platform state
2. **Consensus agreement**: A valid validator quorum signed this state at a specific block height
3. **Temporal accuracy**: The proof is tied to a specific block height and timestamp
4. **Completeness**: For queries, all matching results are included (nothing omitted)

Proof verification also detects proof-of-absence, confirming when requested data genuinely doesn't exist rather than being withheld by a malicious node.

## Asset Lock Proofs

Asset lock proofs are a special category used when creating or funding [identities](../explanations/identity.md). They prove that Dash has been locked on the core blockchain (layer 1) to establish credits on Dash Platform (layer 2).

### Instant Asset Lock Proof

Uses Dash's InstantSend feature to prove funds are locked immediately:

- Contains the InstantSend lock proving transaction finality
- Includes the asset lock special transaction
- Enables immediate identity creation without waiting for block confirmations

This is the preferred method as it allows near-instant identity creation.

### Chain Asset Lock Proof

Uses ChainLocks to prove funds are locked at a specific core blockchain height:

- References the asset lock transaction by its outpoint
- Specifies the core chain height where the transaction was chain-locked
- Provides finality guarantee through Dash's ChainLock mechanism

This method is used when InstantSend confirmation is not available.

:::{attention}
Asset lock proofs are verified by the network during identity creation and topup state transitions. The locked funds cannot be spent on the core chain once used to create platform credits.
:::

## Related Topics

- [Platform Consensus](../explanations/platform-consensus.md) - How Tenderdash and validator quorums work
- [Identity](../explanations/identity.md) - Identity creation using asset lock proofs
- [DAPI](../explanations/dapi.md) - The API layer for requesting proofs
- [Drive](../explanations/drive.md) - The storage layer that generates proofs
