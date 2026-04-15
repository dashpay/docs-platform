```{eval-rst}
.. _explanations-platform-protocol:
```

# Platform Protocol (DPP)

## Overview

To ensure the consistency and integrity of data stored on Layer 2, all data is governed by the Dash Platform Protocol (DPP). Dash Platform Protocol describes serialization and validation rules for the platform's 3 core data structures: data contracts, documents, and state transitions. Each of these structures are briefly described below.

## Structure Descriptions

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
* The user's signature

The payload varies by type and covers a range of operations including document and token updates, data contract creation, identity management, credit transfers, and masternode voting.

The user signature is made for the binary representation of the state transition using a private key associated with an [identity](../explanations/identity.md). A state transition is constructed by a client-side library when the user creates documents and submits them to the platform API.

For additional detail, see the [State Transition](../explanations/platform-protocol-state-transition.md) explanation.

## Versions

Platform Protocol evolves together with the public Dash Platform codebase. For the latest
implementation details and release history, see the
[Dash Platform monorepo](https://github.com/dashpay/platform) and the
[GitHub releases page](https://github.com/dashpay/platform/releases).

Older version-specific notes that referenced pre-mainnet releases have been removed from this page
because they no longer reflect the current public Platform state as clearly as the source
repositories do.

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

platform-protocol-data-contract
platform-protocol-state-transition
platform-protocol-document
platform-protocol-data-trigger
```
