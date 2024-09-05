```{eval-rst}
.. _sdk-js-index:
```

# Overview

[![NPM Version](https://img.shields.io/npm/v/dash)](https://www.npmjs.org/package/dash)  
[![Release Packages](https://github.com/dashpay/platform/actions/workflows/release.yml/badge.svg)](https://github.com/dashpay/platform/actions/workflows/release.yml)  
[![Release Date](https://img.shields.io/github/release-date/dashpay/platform)](https://github.com/dashpay/platform/releases/latest)  
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen)](https://github.com/RichardLitt/standard-readme)

Dash library for JavaScript/TypeScript ecosystem (Wallet, DAPI, Primitives, BLS, ...)

:::{warning}
The JavaScript SDK should only be used in production when connected to trusted nodes. While it
provides easy access to Dash Platform without requiring a full node, it **_does not support Dash
Platform's proofs or verify synchronized blockchain data_**. Therefore, it is less secure than the
[Rust SDK](../sdk-rs/overview.md), which requests proofs for all queried data.
:::

Dash library provides access via [DAPI](../explanations/dapi.md) to use both the Dash Core network and Dash Platform on [supported networks](https://github.com/dashpay/platform/#supported-networks). The Dash Core network can be used to broadcast and receive payments. Dash Platform can be used to manage identities, register data contracts for applications, and submit or retrieve application data via documents.

## Install

### From NPM

In order to use this library, you will need to add our [NPM package](https://www.npmjs.com/dash) to your project.

Having [NodeJS](https://nodejs.org/) installed, just type:

```bash
npm install dash
```

### From unpkg

```html
<script src="https://unpkg.com/dash"></script>
```

### Usage examples

- [Generate a mnemonic](./examples/generate-a-new-mnemonic.md)
- [Receive money and display balance](./examples/receive-money-and-check-balance.md)
- [Pay to another address](./examples/paying-to-another-address.md)
- [Use another BIP44 account](./examples/use-different-account.md)

### Dash Platform Tutorials

See the [Tutorial section](../tutorials/introduction.md) of the Dash Platform documentation for examples.

## Licence

[MIT](https://github.com/dashevo/dashjs/blob/master/LICENCE.md) © Dash Core Group, Inc.
