```{eval-rst}
.. _tutorials-intro:
```

# Introduction

The tutorials in this section walk through the steps necessary to begin building on Dash Platform using the Dash JavaScript SDK. As all communication happens via the masternode hosted decentralized API (DAPI), you can begin using Dash Platform immediately without running a local blockchain node.

Building on Dash Platform requires first registering an Identity and then registering a Data Contract describing the schema of data to be stored. Once that is done, data can be stored and updated by submitting Documents that comply with the Data Contract.

## Prerequisites

The tutorials in this section are written in JavaScript and use [Node.js](https://nodejs.org/en/about/). The following prerequisites are necessary to complete the tutorials:

- [Node.js](https://nodejs.org/en/) (v20+)
- Familiarity with JavaScript asynchronous functions using [async/await](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Async_await)
- The [Dash JavaScript SDK](https://www.npmjs.com/package/@dashevo/evo-sdk) (see [Connecting to a Network](../tutorials/connecting-to-testnet.md#1-install-the-dash-sdk))

## Quickstart

:::{tip}
You can clone a repository containing the code for all tutorials from <a href="https://github.com/dashpay/platform-readme-tutorials#readme" target="_blank">GitHub</a> or download it as a [zip file](https://github.com/dashpay/platform-readme-tutorials/archive/refs/heads/main.zip).
:::

While going through each tutorial is advantageous, the subset of tutorials listed below get you from a start to storing data on Dash Platform most quickly:

- [Obtaining test funds](../tutorials/create-and-fund-a-wallet.md)
- [Setting up the SDK client](../tutorials/setup-sdk-client.md)
- [Registering an Identity](../tutorials/identities-and-names/register-an-identity.md)
- [Registering a Data Contract](../tutorials/contracts-and-documents/register-a-data-contract.md)
- [Submitting data](../tutorials/contracts-and-documents/submit-documents.md)

## Example apps

For end-to-end walkthroughs of example apps built on the SDK, see:

- [DashMint Lab](example-apps/dashmint-lab.md) — NFT marketplace exercising mint / transfer / price / purchase / burn
- [Dashnote](example-apps/dashnote.md) — personal notes app demonstrating the document CRUD lifecycle

Each app's source lives in the [`platform-tutorials`](https://github.com/dashpay/platform-tutorials/tree/main/example-apps) repo.
