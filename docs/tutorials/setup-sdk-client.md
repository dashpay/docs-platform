# Setup SDK Client

:::{warning}
The JavaScript SDK should only be used in production when connected to trusted nodes. While it
provides easy access to Dash Platform without requiring a full node, it **_does not support Dash
Platform's proofs or verify synchronized blockchain data_**. Therefore, it is less secure than the
[Rust SDK](../sdk-rs/overview.md), which requests proofs for all queried data.
:::

In this tutorial we will show how to configure the client for use in the remaining tutorials.

## Prerequisites

- [General prerequisites](../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [How to Create and Fund a
  Wallet](../tutorials/create-and-fund-a-wallet.md)

## Code

:::{tip}
The JavaScript Dash SDK connects to testnet by default. Mainnet can only be accessed by [connecting via address](./connecting-to-testnet.md#connect-to-a-network).
:::

Save the following client configuration module in a file named `setupDashClient.js`. This module
will be re-used in later tutorials.

```{code-block} javascript
:caption: setupDashClient.js
:name: setupDashClient.js

// Fully configured client options
const clientOptions = {
  // The network to connect to ('testnet' or 'local')
  network: 'testnet',

  // Wallet configuration for transactions and account management
  wallet: {
    // The mnemonic (seed phrase) for the wallet. Required for signing transactions.
    mnemonic: 'a Dash wallet mnemonic with testnet funds goes here',

    // Unsafe wallet options (use with caution)
    unsafeOptions: {
      // Starting synchronization from a specific block height can speed up the initial wallet sync process.
      skipSynchronizationBeforeHeight: 875000, // only sync from mid-2023
    },

    // The default account index to use for transactions and queries. Default is 0.
    // defaultAccountIndex: 0,
  },

  // Configuration for Dash Platform applications
  apps: {
    // yourApp: { contractId: 'yourCustomAppContractId' },
    tutorialContract: {
      contractId: '8cvMFwa2YbEsNNoc1PXfTacy2PVq2SzVnkZLeQSzjfi6', // Contract ID
    },
  },

  // Custom list of DAPI seed nodes to connect to. Overrides the default seed list.
  // Format: { service: 'ip|domain:port' }
  // seeds: [
  //   { host: 'seed-1.testnet.networks.dash.org:1443' }
  // ],

  // Custom list of DAPI addresses to connect to
  // Format: [ 'ip:port' }
  // dapiAddresses: [ '127.0.0.1:3000' ],

  // Request timeout in milliseconds for DAPI calls
  // timeout: 3000,

  // The number of retries for a failed DAPI request before giving up
  // retries: 5,

  // The base ban time in milliseconds for a DAPI node that fails to respond properly
  // baseBanTime: 120000,
};

/**
 * Creates and returns a Dash client instance
 * @returns {Dash.Client} The Dash client instance.
 */
const setupDashClient = () => {
  // Ensure that numeric values from environment variables are properly converted to numbers
  if (clientOptions.wallet?.unsafeOptions?.skipSynchronizationBeforeHeight) {
    clientOptions.wallet.unsafeOptions.skipSynchronizationBeforeHeight =
      parseInt(
        clientOptions.wallet.unsafeOptions.skipSynchronizationBeforeHeight,
        10,
      );
  }
  return new Dash.Client(clientOptions);
};

module.exports = setupDashClient;
```

## Wallet Operations

Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations (e.g. `client.getWalletAccount()`). A future release will add caching so that access is much faster after the initial sync.

For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a
certain block height. Set it to a height just below your wallet's first transaction height to
minimize the sync time.

## What's Happening

In this module, we return an SDK client configured with the options necessary for typical use. The
module is then imported in the following tutorials to streamline them and avoid repeating client
initialization details.
