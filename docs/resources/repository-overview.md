```{eval-rst}
.. _resources-repository-overview:
```

# Repository Overview

> 📘 Change to monorepo
>
> Dash Platform v0.21 migrated to a [monorepo](https://en.wikipedia.org/wiki/Monorepo) structure to streamline continuous integration builds and testing. A number of the libraries below were previously independent repositories but now are aggregated into the [`packages` directory](https://github.com/dashevo/platform/tree/master/packages) of the monorepo (<https://github.com/dashpay/platform/>).

## js-dash-sdk

Dash client-side JavaScript library for application development and wallet payment/signing. Uses wallet-lib, dapi-client, and dashcore-lib to expose layer-1 and layer-2 functionality. Main user is app developers.

npm: `dash`  
[Repository](https://github.com/dashevo/platform/tree/master/packages/js-dash-sdk)

## js-dapi-client

Client library for accessing [DAPI Endpoints](../reference/dapi-endpoints.md) . Enables interaction with Dash platform through the [DAPI](../explanations/dapi.md) hosted on masternodes. Provides automatic masternode discovery starting from any initial masternode.

npm: `@dashevo/dapi-client`  
[Repository](https://github.com/dashevo/platform/tree/master/packages/js-dapi-client)

## dapi

A decentralized API for the Dash network. Exposes endpoints for interacting with the layer 1 blockchain and layer 2 platform services.

[Repository](https://github.com/dashevo/platform/tree/master/packages/dapi)

## js-dpp

JavaScript implementation of [Dash Platform Protocol](../explanations/platform-protocol.md). Performs validation of all data submitted to the platform.

npm: `@dashevo/dpp`  
[Repository](https://github.com/dashevo/platform/tree/master/packages/js-dpp)

## Supporting Repositories

### drive

Manages the platform state and provides decentralized application storage on the Dash network.

[Repository](https://github.com/dashevo/platform/tree/master/packages/js-drive)

### dashcore-lib

A JavaScript Dash library

npm: `@dashevo/dashcore-lib`  
Repository: <https://github.com/dashpay/dashcore-lib>

### grove-db

A hierarchical authenticated data structure. The construction is based on [Database Outsourcing with Hierarchical Authenticated Data Structures](https://eprint.iacr.org/2015/351.pdf).

[Repository](https://github.com/dashevo/grovedb)

### wallet-lib

An extensible JavaScript Wallet Library for Dash. Provides layer 1 SPV wallet functionality.

npm: `@dashevo/wallet-lib`  
[Repository](https://github.com/dashevo/platform/tree/master/packages/wallet-lib)

### dapi-grpc

Decentralized API gRPC definition files and generated clients. Used by clients (e.g. dapi-client) to interact with DAPI endpoints.

npm: `@dashevo/dapi-grpc`  
[Repository](https://github.com/dashevo/platform/tree/master/packages/dapi-grpc)

### dash-network-deploy

Tool for assisting Dash devnet network deployment and testing.

<https://github.com/dashpay/dash-network-deploy>

### platform-test-suite

Test suite for end-to-end testing of Dash Platform by running some real-life scenarios against a Dash Network.

[Repository](https://github.com/dashevo/platform/tree/master/packages/platform-test-suite)

### rs-drive

Implements secondary indices for Platform in conjunction with GroveDB.

[Repository](https://github.com/dashevo/rs-drive)

### dashmate

A distribution package for Dash masternode installation.

[Repository](https://github.com/dashevo/platform/tree/master/packages/dashmate)

## Contract Repositories

### dashpay-contract

DashPay contract documents JSON Schema

[Repository](https://github.com/dashevo/platform/tree/master/packages/dashpay-contract)

### dpns-contract

DPNS contract documents JSON Schema

[Repository](https://github.com/dashevo/platform/tree/master/packages/dpns-contract)
