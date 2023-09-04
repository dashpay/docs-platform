# Dash Core full node

Since Dash Platform is fully accessible via DAPI, running a full node is unnecessary and generally provides no particular benefit. Regardless, the steps below provide the necessary information for advanced users to connect.

## Config File

 The config file shown below may be used to connect a Dash Core node to Testnet. Testnet currently operates using [Dash Core v19.3.0](https://github.com/dashpay/dash/releases/tag/v19.3.0).

```ini dash-testnet.conf
# dash-testnet.conf
testnet=1

# Hard-coded first node
addnode=seed-1.testnet.networks.dash.org:19999
```

## Starting Dash Core

To start Dash Core and connect to Testnet, simply run dashd or dash-qt with the `conf` parameter set to the configuration file created above: `<path to binary> -conf=<path to configuration file>`

```shell Start dashd on Testnet
dashd -conf=/home/dash/.dashcore/dash-testnet.conf
```