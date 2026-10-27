```{eval-rst}
.. _explanations-platform-protocol:
```

# Platform Protocol (DPP)

## Overview

To ensure the consistency and integrity of data stored on Layer 2, all data is governed by the Dash Platform Protocol (DPP). Dash Platform Protocol describes serialization and validation rules for the platform's core data structures: identities, data contracts (including tokens, groups, and keywords), documents, and state transitions. It also governs the [Platform address system](../protocol-ref/address-system.md) and the [shielded pool](../explanations/shielded-pool.md), which together account for a substantial share of the available state transition types. Each of these structures are briefly described below.

## Structure Descriptions

### Identity

An identity is the actor that owns data and authorizes changes on the platform. It holds the public keys used to sign state transitions, a credit balance used to pay fees, and the nonces that order an owner's submissions. Most other structures are anchored to an identity: data contracts and documents record an owner, and identity keys are what authorize the transitions that modify them.

For additional detail, see the [Identity](../explanations/identity.md) explanation.

### Data Contract

A data contract is a database schema that a developer needs to register with the platform in order to start using any decentralized storage functionality. Data contracts are described using the JSON Schema language and must follow some basic rules as described in the platform protocol repository.

:::{note}
Dash's data contracts support backwards-compatible modifications after their initial deployment unlike many smart contract based systems. This provides developers with additional flexibility when designing applications.
:::

For additional detail, see the [Data Contract](../explanations/platform-protocol-data-contract.md) explanation.

### Document

A document is an atomic entity used by the platform to store user-submitted data. It resembles the documents stored in a [document-oriented DB](https://en.wikipedia.org/wiki/Document-oriented_database) (e.g. [MongoDB](https://www.mongodb.com/document-databases)). All documents must follow some specific rules that are defined by a generic document schema. Additionally, documents are always related to a particular application, so they must comply with the rules defined by the application’s data contract. Documents are submitted to the platform API ([DAPI](../explanations/dapi.md)) by clients during their use of the application.

For additional detail, see the [Document](../explanations/platform-protocol-document.md) explanation.

### State Transition

A state transition represents a change made by a user to the application and platform states. It consists of:

* A header (version and payload type)
* A payload
* Authorization data

The payload varies by type and covers a range of operations including document and token updates, data contract creation, identity management, credit transfers, masternode voting, data contract moderation and fee claims, [Platform address](../protocol-ref/address-system.md) funding and transfers, and [shielded pool](../explanations/shielded-pool.md) operations.

How a transition is authorized depends on its family. Identity-owned transitions carry a signature made for the binary representation of the state transition using a private key associated with an [identity](../explanations/identity.md). Platform address transitions are instead authorized by a witness signature on each input. Shielded pool transitions omit the generic identity transition signature but retain Orchard `spendAuthSig` and `bindingSignature` authorization; applicable transitions also carry address witnesses or an asset-lock signature. A state transition is constructed by a client-side library when the user creates documents and submits them to the platform API.

For additional detail, see the [State Transition](../explanations/platform-protocol-state-transition.md) explanation.

### Contract-level features

In addition to documents, a data contract may declare:

* **Tokens** - fungible token definitions with their own configuration, distribution, and authorization rules. From protocol version 14, a token can also have its own [shielded pool](../explanations/shielded-pool.md#token-shielded-pools). See the [Tokens](../explanations/tokens.md) explanation.
* **Groups** - sets of identities with assigned power that can jointly authorize token and other privileged actions on the contract.
* **Keywords** - contract-level discovery terms that allow contracts to be searched and surfaced by clients.
* **Description** - an optional human-readable summary of the contract, used alongside keywords when contracts are surfaced to users.

For additional detail, see the [Data Contract](../explanations/platform-protocol-data-contract.md) explanation.

## Versions

Platform Protocol carries its own protocol version, which is distinct from the Dash Platform release
version. Each protocol version selects a coherent set of feature versions - the specific serialization,
validation, and execution behavior in effect - so that every node processing a given block agrees on
exactly which rules apply.

The active protocol version advances by network consensus rather than by deploying new software.
Evonodes signal the version they are prepared to run, and once enough of them signal a newer version,
it activates at the following epoch boundary. This is why a feature can be present in a release but
inactive on the network until activation occurs.

For the latest implementation details and release history, see the
[Dash Platform monorepo](https://github.com/dashpay/platform) and the
[GitHub releases page](https://github.com/dashpay/platform/releases).

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

platform-protocol-data-contract
platform-protocol-state-transition
platform-protocol-document
platform-protocol-data-trigger
```
