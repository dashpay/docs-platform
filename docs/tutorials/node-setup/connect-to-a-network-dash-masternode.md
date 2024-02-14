```{eval-rst}
.. tutorials-setup-masternode:
```

# Dash masternode

The purpose of this tutorial is to walk through the steps necessary to set up a masternode with Dash Platform services.

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/) (v20.10.0+) and [docker-compose](https://docs.docker.com/compose/install/) (v1.25.0+) installed
- An installation of [NodeJS](https://nodejs.org/en/download/) (v20, NPM v8.0+)

The following is not necessary for setting up a local network for development, but is helpful if setting up a testnet masternode:

- Access to a Linux system configured with a non-root user ([guide](https://docs.dash.org/en/stable/masternodes/setup.html#set-up-your-vps))

> 📘
>
> More comprehensive details of using the dashmate tool can be found in the [dashmate README](https://github.com/dashevo/platform/tree/master/packages/dashmate).

Use NPM to install dashmate globally in your system:

```shell
npm install -g dashmate
```

## Local Network

Dashmate can be used to create a local network on a single computer. This network contains multiple nodes to mimic conditions and features found in testnet/mainnet settings.

> 📘
>
> Dashmate local networks use the [regtest network type](../../reference/glossary.md#regtest) so layer 1 blocks can be easily mined as needed.

### Setup

Run the following command to start the setup wizard, then accept the default values at each step to create a local network:

```shell
dashmate setup local
```

Example (partial) output of the setup wizard showing important information:

``` text
  ✔ Initialize SDK
    › HD private key: tprv8ZgxMBicQKsPfLTCjh8vdHkDHYM369tUeQ4aqpV9GzUfQyBKutfstB1sDfQyLERACTEYy5Qjph42gBiqqnqYmXJZZqRc4PQssGzbvwJXHnN
  ✔ Register DPNS identity
    › DPNS identity: 6whgUd1LzwzU4ob7K8FGCLV765K7dp2JbEmVgdTQEFxD
  ✔ Register DPNS contract
    › DPNS contract ID: EpCvWuoh3JcFetFY83HdwuzRUvwxF2hc3mU19MtBg2kK
  ✔ Obtain DPNS contract commit block height
    › DPNS contract block height: 5
  ✔ Register top level domain "dash"
  ✔ Register identity for Dashpay
    › Dashpay's owner identity: 2T7kLcbJzQrLhBV6BferW42Jimb3BJ5zAAore42mfNyE
  ✔ Register Dashpay Contract
    › Dashpay contract ID: EAv8ePXREdJ719ntcRiKuEYxv9XooMwL1mJmPHMGuW9r
  ✔ Obtain Dashpay contract commit block height
    › Dashpay contract block height: 15
  ✔ Register Feature Flags identity
    › Feature Flags identity: 8BsvV4RCbW7srWj81kgjJCykRBF2rzyigys8XkBchY96
  ✔ Register Feature Flags contract
    › Feature Flags contract ID: JDrDAGVqTWsM9k7KGBsSjcyC11Vd2UdPxPoPf4NzyyrP
  ✔ Obtain Feature Flags contract commit block height
    › Feature Flags contract block height: 20

```

> 📘
>
> Make a note of the key and identity information displayed during setup as they may be required in the future.

### Operation

Once the setup completes, start/stop/restart the network via the following commands:

```shell
dashmate group start
dashmate group stop
dashmate group restart
```

The status of the network's nodes can be check via the group status command:

```shell
dashmate group status
```

### Mining Dash

During development it may be necessary to obtain Dash to create and topup [identities](../../explanations/identity.md). This can be done using the dashmate `wallet:mint` command. First obtain an address to fund via the [Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md) tutorial and then mine Dash to it as shown below:

::::{tab-set}
:::{tab-item} Mine to provided address
```shell
# Stop the devnet first
dashmate group stop

# Mine 10 Dash to a provided address
dashmate wallet mint 10 --address=<your address> --config=local_seed

# Restart the devnet
dashmate group start
```
:::

:::{tab-item} Mine to new address
```shell
# Stop the devnet first
dashmate group:stop

# Mine 10 Dash to a random address/key
# The address and private key will be displayed
dashmate wallet:mint 10 --config=local_seed

# Restart the devnet
dashmate group:start
```
:::
::::

Example output of `dashmate wallet mint 10 --address=yYqfdpePzn2kWtMxr9nz22HBFM7WBRmAqG --config=local_seed`:

```text
✔ Generate 10 dash to address
  ✔ Start Core
  ↓ Use specified address yYqfdpePzn2kWtMxr9nz22HBFM7WBRmAqG [SKIPPED]
  ✔ Generate ≈10 dash to address yYqfdpePzn2kWtMxr9nz22HBFM7WBRmAqG
    › Generated 172.59038279 dash
  ✔ Wait for balance to confirm
  ✔ Stop Core
```

### Using the network

Once the address is funded, you can begin creating identities, data contracts, etc. and experimenting with Dash Platform. The [other tutorials](../../tutorials/introduction.md) in this section will help you get started.

To make the Dash SDK connect to your local network, set the `network` option to `'local'`:

```javascript
const clientOpts = {
  network: 'local',
  ...
};

const client = new Dash.Client(clientOpts);
```

## Testnet Masternode Setup

> ❗️ Advanced Topic
>
> Running a masternode requires familiarity with Dash Platform services. Improper configuration may impact testing so please exercise caution if running a masternode.

To setup a testnet masternode, please refer to the comprehensive documentation of the process as described [here](https://docs.dash.org/en/stable/masternodes/setup-testnet.html#dashmate-installation). The following video also details how to complete the process.

```{eval-rst}
.. raw:: html

    <div style="position: relative; padding-bottom: 56.25%; height: 0; margin-bottom: 1em; overflow: hidden; max-width: 100%; height: auto;">
        <iframe src="//www.youtube.com/embed/LLiMMXSAfeU" frameborder="0" allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe>
    </div>
```

> 📘 Full Platform Node
>
> A full node that with all Platform services can be started by simply running the setup command with the [node type setup parameter](https://github.com/dashevo/platform/tree/master/packages/dashmate#setup-node) set to  `fullnode` and then starting the node.
>
> ``` text
> dashmate setup testnet fullnode
> dashmate start
> ```

## Remote Development Network

> 📘 Connecting to a remote development network
>
> In order to connect to a remote [devnet](../../reference/glossary.md#devnet) (e.g. one run by Dash Core Group), please use one of the methods described in the [Connect to a Devnet](../../tutorials/connecting-to-testnet.md#connect-to-a-devnet) section.

For development we recommend using either a local network created via dashmate as [described above](#local-network) or using Testnet. While configuring a remote development network is possible using the Dash network deployment tool, it is beyond the scope of this documentation. For details regarding this tool, please refer to the [GitHub repository](https://github.com/dashevo/dash-network-deploy).
