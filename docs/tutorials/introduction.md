```{eval-rst}
.. _tutorials-intro:
```

# Introduction

The tutorials in this section walk through the steps necessary to begin building on Dash Platform using the Dash JavaScript SDK. As all communication happens via the masternode hosted decentralized API (DAPI), you can begin using Dash Platform immediately without running a local blockchain node.

:::{warning}
Only the JavaScript SDK provides easy access to Dash Platform without requiring a full node;
however, it **_does not support Dash Platform's proofs_**. Therefore, it is less secure than the
[Rust SDK](../sdk-rs/overview.md), which requests proofs for all queried data.
:::

Building on Dash Platform requires first registering an Identity and then registering a Data Contract describing the schema of data to be stored. Once that is done, data can be stored and updated by submitting Documents that comply with the Data Contract.

## Prerequisites

The tutorials in this section are written in JavaScript and use [Node.js](https://nodejs.org/en/about/). The following prerequisites are necessary to complete the tutorials:

- [Node.js](https://nodejs.org/en/) (v20+)
- Familiarity with JavaScript asynchronous functions using [async/await](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Async_await)
- The Dash JavaScript SDK (see [Connecting to a Network](../tutorials/connecting-to-testnet.md#1-install-the-dash-sdk))

## Quickstart

:::{tip}
You can clone a repository containing the code for all tutorials from <a href="https://github.com/dashpay/platform-readme-tutorials#readme" target="_blank">GitHub</a> or download it as a [zip file](https://github.com/dashpay/platform-readme-tutorials/archive/refs/heads/main.zip).
:::

While going through each tutorial is advantageous, the subset of tutorials listed below get you from a start to storing data on Dash Platform most quickly:

- [Obtaining test funds](../tutorials/create-and-fund-a-wallet.md)
- [Setting up client options](../tutorials/setup-sdk-client.md)
- [Registering an Identity](../tutorials/identities-and-names/register-an-identity.md)
- [Registering a Data Contract](../tutorials/contracts-and-documents/register-a-data-contract.md)
- [Submitting data](../tutorials/contracts-and-documents/submit-documents.md)
