# Platform Protocol (DPP)

## Overview

To ensure the consistency and integrity of data stored on Layer 2, all data is governed by the Dash Platform Protocol (DPP). Dash Platform Protocol describes serialization and validation rules for the platform's 3 core data structures: data contracts, documents, and state transitions. Each of these structures are briefly described below.

> ❗️ Advanced Topic
>
> **Dash Platform Protocol 0.22** 
> A number of breaking changes were introduced in DPP 0.22. Details can be found in the [GitHub release](https://github.com/dashevo/platform/releases/tag/v0.22.0).
>
> **Dash Platform Protocol 0.21** 
> A number of breaking changes were introduced in DPP 0.21. Details can be found in the [GitHub release](https://github.com/dashevo/js-dpp/releases/tag/v0.21.0).
>
> **Dash Platform Protocol 0.20**
> This release updated to a newer version of JSON Schema (2020-12 spec) and also switched to a new regex module ([Re2](https://github.com/google/re2)) for improved security. More details can be found in the [GitHub release](https://github.com/dashevo/js-dpp/releases/tag/v0.20.0).

## Structure Descriptions

### Data Contract

A data contract is a database schema that a developer needs to register with the platform in order to start using any decentralized storage functionality. Data contracts are described using the JSON Schema language and must follow some basic rules as described in the platform protocol repository. Contracts are serialized to binary form using [CBOR](https://cbor.io/).

> 👍 Updating contracts
>
> Dash's data contracts support backwards-compatible modifications after their initial deployment unlike many smart contract based systems. This provides developers with additional flexibility when designing applications.

For additional detail, see the [Data Contract](explanation-platform-protocol-data-contract) explanation.

### Document

A document is an atomic entity used by the platform to store user-submitted data. It resembles the documents stored in a document-oriented DB (e.g. MongoDB). All documents must follow some specific rules that are defined by a generic document schema. Additionally, documents are always related to a particular application, so they must comply with the rules defined by the application’s data contract. Documents are submitted to the platform API ([DAPI](explanation-dapi)) by clients during their use of the application.

> 📘 Document-Oriented Databases
>
> Information about document-oriented databases can be found on the [MongoDB site](https://www.mongodb.com/document-databases) and in this [Wikipedia article](https://en.wikipedia.org/wiki/Document-oriented_database).

For additional detail, see the [Document](explanation-platform-protocol-document) explanation.

### State Transition

A state transition represents a change made by a user to the application and platform states. It consists of:
 - Either: 
    - An array of documents, or
    - One data contract
 -  The contract ID of the application to which the change is made
 - The user's signature.

The user signature is made for the binary representation of the state transition using a private key associated with an [identity](explanation-identity). A state transition is constructed by a client-side library when the user creates documents and submits them to the platform API.

For additional detail, see the [State Transition](explanation-platform-protocol-state-transition) explanation.

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

platform-protocol-data-contract
platform-protocol-state-transition
platform-protocol-document
platform-protocol-data-trigger
```
