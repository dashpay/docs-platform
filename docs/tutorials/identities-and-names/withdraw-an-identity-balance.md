```{eval-rst}
.. tutorials-withdraw-identity-balance:
```

:::{attention}
Mainnet withdrawals will not be available until the activation of Dash Platform v1.4 on mainnet in late October or early November. They are already available on testnet.
:::

# Withdraw an Identity's balance

The purpose of this tutorial is to walk through the steps necessary to withdraw part of their identity's balance from Platform to a Dash address.

## Overview

Over time, users may want to convert some of their identity's [Platform credits](../../explanations/identity.md#credits) back to Dash for use on the Core chain.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity with a credit balance: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- A Core chain address to receive the withdrawn credits as Dash

## Code

```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const withdrawCredits = async () => {
  const identityId = 'an identity ID goes here';
  const identity = await client.platform.identities.get(identityId);

  console.log('Identity balance before transfer: ', identity.balance);

  const toAddress = 'a Dash address goes here';
  const amount = 1000000; // Number of credits to withdraw
  const amountDash = amount / (1000 * 100000000);

  console.log(`Withdrawing ${amount} credits (${amountDash} DASH)`);
  // Temporarily force minRelay to have a value so withdrawal succeeds
  // https://github.com/dashpay/platform/issues/2233
  client.wallet.storage.getDefaultChainStore().state.fees.minRelay = 1000;

  const response = await client.platform.identities.withdrawCredits(
    identity,
    amount,
    {
      toAddress,
    },
  );
  return client.platform.identities.get(identityId);
};

withdrawCredits()
  .then((d) => console.log('Identity balance after withdrawal: ', d.balance))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

## What's Happening

After connecting to the Client, we get an identity and set the withdrawal address and amount. We then call `platform.identities.withdrawCredits` with the identity, withdrawal amount in credits, and the destination address. This creates an unlock transaction and decreases the identity's credit balance by the relevant amount including a fee. The updated identity balance is output to the console. Once the withdrawal is processed, it is broadcast to the Core chain where the unlocked Dash is sent to the provided destination address.

:::{note}
:class: note
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::
