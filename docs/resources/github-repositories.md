## [dashcore-lib](https://github.com/dashevo/dashcore-lib)
npm: `@dashevo/dashcore-lib`
This handles core network functions like managing private keys, creating and signing transactions, and verifying blocks, as well as some masternode-related functions such as fetching governance objects and the deterministic masternode list. Based on Bitcoin's bitcore-lib.

## [dash-spv](https://github.com/dashevo/dash-spv)
npm: `@dashevo/dash-spv`
This offers [SPV](glossary#section-simple-payment-verification) functions on top of dashcore-lib to enable lightweight wallet clients that can start quickly and don't need to download the whole Dash blockchain.

## [dapi-client](https://github.com/dashevo/platform/tree/master/packages/js-dapi-client)
npm: `@dashevo/dapi-client`
Enables interaction with Dash platform through the DAPI hosted on masternodes. Provides automatic masternode discovery starting from any initial masternode.
Uses dash-spv and dashcore-lib.

## [js-dpp](https://github.com/dashevo/platform/tree/master/packages/js-dpp)
npm: `@dashevo/dpp`

## [wallet-lib](https://github.com/dashevo/platform/tree/master/packages/wallet-lib)
npm: `@dashevo/wallet-lib`
Provides layer-1 spv wallet functions
Uses dapi-client, dashcore-lib, and js-dpp.

## [DashJS](https://github.com/dashevo/platform/tree/master/packages/js-dash-sdk)
npm: `dash`
uses wallet-lib, dapi-client, and dashcore-lib to expose layer-1 and layer-2 functionality. Main user is app developers