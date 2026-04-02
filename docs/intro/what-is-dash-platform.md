```{eval-rst}
.. _intro-dash-platform:
```

# What is Dash Platform

Dash Platform is a [Web3](https://en.wikipedia.org/wiki/Web3) technology stack for building
decentralized applications on the Dash network. It is best understood as a decentralized data
storage and application layer on top of Dash: developers define schemas and submit structured state
transitions instead of deploying arbitrary user-written code on-chain.

Its core components, [Drive](../explanations/drive.md) and [DAPI](../explanations/dapi.md),
provide structured data storage, identity primitives, rich queries, and verifiable data access on
top of the Dash network.

:::{tip}
Dash Platform is developed in the open. For the current implementation details, package layout, and
build instructions, see the [Dash Platform monorepo](https://github.com/dashpay/platform). For a
broader architectural walkthrough of the Rust codebase, see the
[Dash Platform Book](https://dashpay.github.io/platform/).
:::

```{eval-rst}
.. raw:: html

    <div style="position: relative; padding-bottom: 56.25%; height: 0; margin-bottom: 1em; overflow: hidden; max-width: 100%; height: auto;">
        <iframe src="https://www.youtube-nocookie.com/embed/3H6KRcYkKpY" frameborder="0" allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe>
    </div>
```

## Key Advantages

### Decentralized Cloud Storage

Store structured application data on the Dash network with consensus-backed integrity and
availability.

### Reduced Data Silos

Because application data is stored across the Dash masternode network, it can be shared and queried
without relying on a single hosted backend.

### Client Libraries

Write code and integrate with Dash Platform using the languages that matter to your business. Don't worry about understanding blockchain infrastructure: a growing number of client libraries abstract away the complexity typically associated with working on blockchain-based networks.

### Instant Data Confirmation

Unlike many blockchain-based networks, Platform is designed for fast finality and proof-based data
verification, making it practical for light clients and user-facing applications.

```{eval-rst}
.. figure:: ../../img/join-community.svg
   :class: no-scaled-link
   :align: center
   :width: 60%
   :alt: Developer community image
```

## Key Components

### DAPI - A decentralized API

DAPI is a _decentralized_ HTTP API exposing [JSON-RPC](https://www.jsonrpc.org/) and [gRPC](https://grpc.io/) endpoints. Through these endpoints, developers can send and retrieve application data and query the Dash blockchain.

DAPI provides developers the same access and security as running their own Dash node without the cost and maintenance overhead. Unlike traditional APIs which have a single point of failure, DAPI allows clients to connect to different instances depending on resource availability in the Dash network.

Developers can connect to DAPI directly or use higher-level SDKs and client libraries maintained in
the Dash Platform monorepo. These libraries handle connection management, data serialization, and
common application workflows. A major design goal of Platform is that clients can verify responses
with proofs rather than trusting the node that served them.

The source for these components is available on GitHub:

- Platform monorepo: <https://github.com/dashpay/platform>

### Drive - Decentralized Storage

Drive is Dash Platform's storage component, allowing for consensus-based verification and validation of user-created data. In order for this to occur, developers create a [data contract](../explanations/platform-protocol-data-contract.md). This data contract describes the data structures that comprise an application, similar to creating a schema for a document-oriented database like MongoDB.

Data created by users of the application is validated and verified against this contract. Upon successful validation/verification, application data is submitted to Drive (via DAPI), where it is stored on the masternode network. Drive uses Dash's purpose-built database, [GroveDB](https://github.com/dashpay/grovedb/), to provide efficient proofs with query responses, so you don't have to trust the API provider to be certain your data is authentic.

The source is available on GitHub:

- Drive: <https://github.com/dashpay/platform/tree/master/packages/rs-drive>
