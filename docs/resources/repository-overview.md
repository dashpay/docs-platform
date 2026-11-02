```{eval-rst}
.. _resources-repository-overview:
```

# Repository Overview

Dash Platform uses a [monorepo](https://en.wikipedia.org/wiki/Monorepo) structure containing most
of the source code that powers the network, SDKs, and development tooling. The public source tree
is available in the [dashpay/platform](https://github.com/dashpay/platform) repository.

If you want a higher-level architectural walkthrough of the current Rust codebase, see the
[Dash Platform Book](https://dashpay.github.io/platform/).

## SDKs

These are the primary tools for developers building on Dash Platform. Package names and exact module
layout can change over time, so treat the monorepo as the source of truth.

| Component | Description |
| - | - |
| [js-evo-sdk](https://github.com/dashpay/platform/tree/master/packages/js-evo-sdk) | JavaScript tooling for connecting to Platform, creating identities, and submitting state transitions |
| [rs-sdk](https://github.com/dashpay/platform/tree/master/packages/rs-sdk) | Rust-first SDK for building applications and verifying Platform data |
| [dash-platform-queries](https://github.com/dashpay/platform/tree/master/packages/dash-platform-queries) | Transport-free query building and proof verification shared by rs-sdk and other SDK embedders |
| [rs-sdk-ffi](https://github.com/dashpay/platform/tree/master/packages/rs-sdk-ffi) / [swift-sdk](https://github.com/dashpay/platform/tree/master/packages/swift-sdk) / [kotlin-sdk](https://github.com/dashpay/platform/tree/master/packages/kotlin-sdk) | Shared components used for Swift, Kotlin (Android), and other native integrations |
| [wasm-sdk](https://github.com/dashpay/platform/tree/master/packages/wasm-sdk) | WebAssembly-oriented bindings for browser and hybrid environments |

The [Evo SDK site](https://evo-sdk.dash.org/) hosts developer-facing tooling for the JavaScript SDK: an interactive [playground](https://evo-sdk.dash.org/playground.html) that runs read-only queries in the browser against testnet, [SDK documentation](https://evo-sdk.dash.org/docs.html), and an AI reference.

## Platform and Supporting Repositories

These run on the network and process data.

| Component | Description |
| - | - |
| [rs-dapi](https://github.com/dashpay/platform/tree/master/packages/rs-dapi) | Decentralized API (DAPI) server |
| [dapi](https://github.com/dashpay/platform/tree/master/packages/dapi) | Legacy JavaScript DAPI implementation, replaced by rs-dapi |
| [rs-drive](https://github.com/dashpay/platform/tree/master/packages/rs-drive) | Drive query and indexing layer over GroveDB |
| [rs-dpp](https://github.com/dashpay/platform/tree/master/packages/rs-dpp) | Dash Platform Protocol (data contracts, documents, state transitions, identities) |
| [dashmate](https://github.com/dashpay/platform/tree/master/packages/dashmate) | Node management and local development tool |
| [rs-tenderdash-abci](https://github.com/dashpay/rs-tenderdash-abci) | Tenderdash ABCI application |
| [grovedb](https://github.com/dashpay/grovedb) | Hierarchical authenticated data structure |
| [tenderdash](https://github.com/dashpay/tenderdash) | Byzantine fault-tolerant consensus engine |
| [rust-dashcore](https://github.com/dashpay/rust-dashcore) | Rust implementation of Dash Core primitives |

## Contracts

Built-in data contracts used by the network.

| Component | Description |
| - | - |
| [dashpay-contract](https://github.com/dashpay/platform/tree/master/packages/dashpay-contract) | DashPay contract documents JSON Schema |
| [dpns-contract](https://github.com/dashpay/platform/tree/master/packages/dpns-contract) | DPNS contract documents JSON Schema |
| [app-connect-contract](https://github.com/dashpay/platform/tree/master/packages/app-connect-contract) | Wallet's encrypted response to an app login request |
| [document-history-contract](https://github.com/dashpay/platform/tree/master/packages/document-history-contract) | Transfer, purchase, and price-change history for documents that opt in |
| [keyword-search-contract](https://github.com/dashpay/platform/tree/master/packages/keyword-search-contract) | Keyword search for data contracts and tokens |
| [masternode-reward-shares-contract](https://github.com/dashpay/platform/tree/master/packages/masternode-reward-shares-contract) | Masternode reward sharing |
| [moderation-charters-contract](https://github.com/dashpay/platform/tree/master/packages/moderation-charters-contract) | Charters of elected moderation teams |
| [token-history-contract](https://github.com/dashpay/platform/tree/master/packages/token-history-contract) | Token history records (mints, burns, transfers, and other token events) |
| [wallet-utils-contract](https://github.com/dashpay/platform/tree/master/packages/wallet-utils-contract) | Wallet utilities such as encrypted transaction metadata |
| [withdrawals-contract](https://github.com/dashpay/platform/tree/master/packages/withdrawals-contract) | Tracking of withdrawals from Platform to Dash Core |

## Source Code Location

All source code produced by Dash Core Group is located in two GitHub organizations:

- [Dashpay](https://github.com/dashpay) - Dash Core and Platform software and documentation
- [Dashevo](https://github.com/dashevo) - Original source of Dash Platform development. Archived for historical reference
