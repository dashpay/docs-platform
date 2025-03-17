```{eval-rst}
.. _dapi-client-js-index:
```

# Overview

:::{attention}
This documentation is based on the [docs directory in the repository](https://github.com/dashpay/platform/tree/master/packages/js-dapi-client/docs) and may not always reflect recent code changes. For the most up-to-date information, please refer to the latest version of the code.
:::

## DAPI-Client

[![NPM Version](https://img.shields.io/npm/v/@dashevo/dapi-client)](https://www.npmjs.com/package/@dashevo/dapi-client)  
[![Build Status](https://github.com/dashevo/js-dapi-client/actions/workflows/test_and_release.yml/badge.svg)](https://github.com/dashevo/js-dapi-client/actions/workflows/test_and_release.yml)  
[![Release Date](https://img.shields.io/github/release-date/dashpay/platform)](https://github.com/dashpay/platform/releases/latest)  
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen)](https://github.com/RichardLitt/standard-readme)

Client library used to access Dash DAPI endpoints

This library enables HTTP-based interaction with the Dash blockchain and Dash Platform via the decentralized API ([DAPI](https://github.com/dashpay/platform/tree/master/packages/dapi)) hosted on Dash masternodes.

- `DAPI-Client` provides automatic server (masternode) discovery using either a default seed node or a user-supplied one
- `DAPI-Client` maps to DAPI's [RPC](https://github.com/dashpay/platform/tree/master/packages/dapi/lib/rpcServer/commands) and [gRPC](https://github.com/dashpay/platform/tree/master/packages/dapi/lib/grpcServer/handlers) endpoints

### Install

### ES5/ES6 via NPM

In order to use this library in Node, you will need to add it to your project as a dependency.

Having [NodeJS](https://nodejs.org/) installed, just type in your terminal :

```sh
npm install @dashevo/dapi-client
```

### CDN Standalone

For browser usage, you can also directly rely on unpkg :

```
<script src="https://unpkg.com/@dashevo/dapi-client"></script>
```

## Licence

[MIT](https://github.com/dashevo/dapi-client/blob/master/LICENCE.md) © Dash Core Group, Inc.