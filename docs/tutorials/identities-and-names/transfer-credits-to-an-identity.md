# Transfer to an Identity

The purpose of this tutorial is to walk through the steps necessary to transfer credits to an
identity. Additional details regarding credits can be found in the [credits description](../../explanations/identity.md#credits).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK
  installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a
  Wallet](../../tutorials/create-and-fund-a-wallet.md)
- Two Dash Platform Identities: [Tutorial: Register an
  Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```javascript
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with testnet funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from mid-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

const transferCreditsToIdentity = async () => {
  const identityId = 'identity ID of the sender goes here';
  const identity = await client.platform.identities.get(identityId);

  const recipientID = 'identity ID of the recipient goes here';
  console.log('Recipient identity balance before transfer: ', recipientIdentity.balance);
  const transferAmount = 1000; // Number of credits to transfer

  await client.platform.identities.creditTransfer(
    identity,
    recipientID,
    transferAmount,
  );
  return client.platform.identities.get(identityId);
};

transferCreditsToIdentity()
  .then((d) => console.log('Recipient identity balance after transfer: ', d.balance))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

## What's Happening

After connecting to the Client, we call `platform.identities.creditTransfer` with our identity, the recipient's identity ID, and the amount to transfer. After the credits are transferred to the recipient, we retrieve the recipient's identity and output their updated balance to the console.

> 📘 Wallet Operations
>
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some
> wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+
> minutes.
>
> A future release will add caching so that access is much faster after the initial sync. For now,
> the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain
> block height.
