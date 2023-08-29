# Register a name for an identity

The purpose of this tutorial is to walk through the steps necessary to register a [Dash Platform Name Service (DPNS)](../../reference/glossary.md#dash-platform-naming-service-dpns) name.

## Overview
Dash Platform names make cryptographic identities easy to remember and communicate. An identity may have multiple alias names (`dashAliasIdentityId`) in addition to its default name (`dashUniqueIdentityId`). Additional details regarding identities can be found in the [Identity description](../../explanations/identity.md).

**Note**: An identity must have a default name before any aliases can be created for the identity.

### Prerequisites
- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A Dash Platform identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md) 
- A name you want to register: [Name restrictions](../../explanations/dpns.md#implementation)

## Code

 The examples below demonstrate creating both the default name and alias names.

**Note**: the name must be the full domain name including the parent domain (i.e. `myname.dash` instead of just `myname`). Currently `dash` is the only top-level domain that may be used.

::::{tab-set-code}

```javascript Register Name for Identity
// Register Name for Identity
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

const registerName = async () => {
  const { platform } = client;

  const identity = await platform.identities.get('an identity ID goes here');
  const nameRegistration = await platform.names.register(
    '<identity name goes here>.dash',
    { dashUniqueIdentityId: identity.getId() },
    identity,
  );

  return nameRegistration;
};

registerName()
  .then((d) => console.log('Name registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
```javascript Register Alias for Identity
// Register Alias for Identity
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

const registerAlias = async () => {
  const platform = client.platform;
  const identity = await platform.identities.get('an identity ID goes here');
  const aliasRegistration = await platform.names.register(
    '<identity alias goes here>.dash',
    { dashAliasIdentityId: identity.getId() },
    identity,
  );

  return aliasRegistration;
};

registerAlias()
  .then((d) => console.log('Alias registered:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

::::

## What's Happening

After initializing the Client, we fetch the Identity we'll be associating with a name. This is an asynchronous method so we use _await_ to pause until the request is complete. Next, we call `platform.names.register` and pass in the name we want to register, the type of identity record to create, and the identity we just fetched. We wait for the result, and output it to the console.

> 📘 Wallet Operations
> 
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
> 
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.