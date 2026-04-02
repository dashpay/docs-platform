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
| [rs-sdk-ffi](https://github.com/dashpay/platform/tree/master/packages/rs-sdk-ffi) / [swift-sdk](https://github.com/dashpay/platform/tree/master/packages/swift-sdk) | Shared components used for Swift and other native integrations |
| [wasm-sdk](https://github.com/dashpay/platform/tree/master/packages/wasm-sdk) | WebAssembly-oriented bindings for browser and hybrid environments |

## Platform and Supporting Repositories

These run on the network and process data.

| Component | Description |
| - | - |
| [dapi](https://github.com/dashpay/platform/tree/master/packages/dapi) / [rs-dapi](https://github.com/dashpay/platform/tree/master/packages/rs-dapi) | Decentralized API server implementations |
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

## Source Code Location

All source code produced by Dash Core Group is located in two GitHub organizations:

- [Dashpay](https://github.com/dashpay) - Dash Core and Platform software and documentation
- [Dashevo](https://github.com/dashevo) - Original source of Dash Platform development. Archived for historical reference
