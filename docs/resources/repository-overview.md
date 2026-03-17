```{eval-rst}
.. _resources-repository-overview:
```

# Repository Overview

Dash Platform uses a [monorepo](https://en.wikipedia.org/wiki/Monorepo) structure containing most
packages that comprise Dash Platform. Packages are located in the
[packages](https://github.com/dashpay/platform/tree/master/packages) directory.

## SDKs

These are the primary tools for developers building on Dash Platform.

| Component | Description |
| - | - |
| [js-evo-sdk](https://github.com/dashpay/platform/tree/master/packages/js-evo-sdk) | JavaScript SDK (`npm install @dashevo/evo-sdk`) |
| [rs-sdk](https://github.com/dashpay/platform/tree/master/packages/rs-sdk) | Rust SDK for building applications on Dash Platform |
| [rs-sdk-ffi](https://github.com/dashpay/platform/tree/master/packages/rs-sdk-ffi) / [swift-sdk](https://github.com/dashpay/platform/tree/master/packages/swift-sdk) | FFI layer and iOS/Swift SDK |
| [wasm-sdk](https://github.com/dashpay/platform/tree/master/packages/wasm-sdk) | WebAssembly bindings for browser-based applications |

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
