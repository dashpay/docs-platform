# Introduction

The tutorials in this section walk through the steps necessary to begin building on Dash Platform using the Dash JavaScript SDK. As all communication happens via the masternode hosted decentralized API (DAPI), you can begin using Dash Platform immediately without running a local blockchain node.

Building on Dash Platform requires first registering an Identity and then registering a Data Contract describing the schema of data to be stored. Once that is done, data can be stored and updated by submitting Documents that comply with the Data Contract.

> 📘 Tutorial code
>
> You can clone a repository containing the code for all tutorials from <a href="https://github.com/dashevo/platform-readme-tutorials#readme" target="_blank">GitHub</a> or download it as a [zip file](https://github.com/dashevo/platform-readme-tutorials/archive/refs/heads/main.zip).

## Prerequisites

The tutorials in this section are written in JavaScript and use [Node.js](https://nodejs.org/en/about/). The following prerequisites are necessary to complete the tutorials:

- [Node.js](https://nodejs.org/en/) (v12+)
- Familiarity with JavaScript asynchronous functions using [async/await](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Async_await)
- The Dash JavaScript SDK (see [Connecting to a Network](tutorial-connecting-to-testnet#1-install-the-dash-sdk))

## Quickstart
[block:image]
{
  "images": [
    {
      "image": [
        "https://files.readme.io/d38f3cf-benefits_speed-1.svg",
        "benefits_speed-1.svg",
        152,
        132,
        "#272724"
      ]
    }
  ]
}
[/block]
While going through each tutorial is advantageous, the subset of tutorials listed below get you from a start to storing data on Dash Platform most quickly:
- [Obtaining test funds](tutorial-create-and-fund-a-wallet)
- [Registering an Identity](tutorial-register-an-identity)
- [Registering a Data Contract](tutorial-register-a-data-contract)
- [Submitting data](tutorial-submit-documents)

[block:html]
{
  "html": "<div>\n</div>\n\n<style>\n .markdown-body img {\n float: right;\n margin-left: 30px;\n /*width: 25%;*/\n max-width: 25%; /*400px;*/\n height: auto;  \n}\n</style>"
}
[/block]
