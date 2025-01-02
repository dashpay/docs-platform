```{eval-rst}
.. tutorials-create-wallet:
```


# Create and fund a wallet

In order to make changes on Dash Platform, you need a wallet with a balance. This tutorial explains how to generate a new wallet, retrieve an address from it, and transfer test funds to the address from a faucet.

## Prerequisites

- [General prerequisites](../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)

# Code

```javascript
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: null, // this indicates that we want a new wallet to be generated
    // if you want to get a new address for an existing wallet
    // replace 'null' with an existing wallet mnemonic
    offlineMode: true,  // this indicates we don't want to sync the chain
    // it can only be used when the mnemonic is set to 'null'
  },
};

const client = new Dash.Client(clientOpts);

const createWallet = async () => {
  const account = await client.getWalletAccount();

  const mnemonic = client.wallet.exportWallet();
  const address = account.getUnusedAddress();
  console.log('Mnemonic:', mnemonic);
  console.log('Unused address:', address.address);
};

createWallet()
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());

// Handle wallet async errors
client.on('error', (error, context) => {
  console.error(`Client error: ${error.name}`);
  console.error(context);
});
```

```text
Mnemonic: thrive wolf habit timber birth service crystal patient tiny depart tower focus
Unused address: yXF7LsyajRvJGX96vPHBmo9Dwy9zEvzkbh
```

:::{attention}
Please save your mnemonic for the next step and for re-use in subsequent tutorials throughout the documentation.
:::

# What's Happening

Once we connect, we output the newly generated mnemonic from `client.wallet.exportWallet()` and an unused address from the wallet from `account.getUnusedAddress()`.

# Next Step

Using the [faucet](https://testnet-faucet.dash.org/), send test funds to the "unused address" from the console output. You will need to wait until the funds are confirmed to use them. The [block explorer](https://insight.testnet.networks.dash.org/insight/) can be used to check confirmations.
