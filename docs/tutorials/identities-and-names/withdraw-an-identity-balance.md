```{eval-rst}
.. tutorials-withdraw-identity-balance:
```

# Withdraw an Identity's balance

The purpose of this tutorial is to walk through the steps necessary to withdraw part of an identity's balance from Platform to a Dash address.

## Overview

Over time, users may want to convert some of their identity's [Platform credits](../../explanations/identity.md#credits) back to Dash for use on the Core chain.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity with a credit balance: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- A Core chain address to receive the withdrawn credits as Dash

## Code

```{code-block} javascript
:caption: identity-withdraw-credits.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, signer } = await keyManager.getTransfer();

console.log('Identity balance before withdrawal:', identity.balance);

// Default: testnet faucet address. Replace or override via WITHDRAWAL_ADDRESS.
const toAddress =
  process.env.WITHDRAWAL_ADDRESS ?? 'yXWJGWuD4VBRMp9n2MtXQbGpgSeWyTRHme';
const amount = 190000n; // Credits to withdraw
const amountDash = Number(amount) / (1000 * 100000000);

console.log(`Withdrawing ${amount} credits (${amountDash} DASH)`);

try {
  const remainingBalance = await sdk.identities.creditWithdrawal({
    identity,
    amount,
    toAddress,
    signer,
  });

  console.log(`Identity balance after withdrawal: ${remainingBalance} credits`);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we get the transfer key signer using `keyManager.getTransfer()` and log the identity's current balance. We also convert the credit amount to Dash for display (1000 credits = 1 duff = 0.00000001 DASH). We then call `sdk.identities.creditWithdrawal()` with the identity, withdrawal amount in credits, the destination Core chain address, and the signer to authorize the withdrawal. The remaining credit balance is logged to confirm the withdrawal succeeded.
