The purpose of this tutorial is to walk through the steps necessary to register an identity.

# Overview
Identities serve as the basis for interactions with Dash Platform. They consist primarily of a public key used to register a unique entity on the network. Additional details regarding identities can be found in the [Identity description](explanation-identity).

## Prerequisites
- [General prerequisites](tutorials-introduction#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [How to Create and Fund a Wallet](tutorial-create-and-fund-a-wallet)

# Code

> 📘 Wallet Operations
>
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
>
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.

```javascript
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
  	mnemonic: 'a Dash wallet mnemonic with testnet funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

const createIdentity = async () => {
  return client.platform.identities.register();
};

createIdentity()
  .then((d) => console.log('Identity:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
``` 

The Identity will be output to the console. The Identity will need to have one confirmation before it is accessible via `client.platform.identity.get`.

> 👍
>
> **Make a note of the returned identity `id` as it will be used used in subsequent tutorials throughout the documentation.**

# What's Happening

After connecting to the Client, we call `platform.identities.register`. This will generate a keypair and submit an _Identity Create State Transaction_. After the Identity is registered, we output it to the console.