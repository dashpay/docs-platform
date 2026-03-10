```{eval-rst}
.. tutorials-topup-identity-balance:
```

# Topup an identity's balance

The purpose of this tutorial is to walk through the steps necessary to add credits to an identity's balance.

## Overview

As users interact with Dash Platform applications, the credit balance associated with their identity will decrease. Eventually it will be necessary to top up the balance by transferring credits from a funded platform address. Additional details regarding credits can be found in the [Credits description](../../explanations/identity.md#credits).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```{code-block} javascript
:caption: identity-topup.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, addressKeyManager, keyManager } = await setupDashClient();
const signer = addressKeyManager.getSigner();

try {
  // Identity ID from the identity create tutorial
  const IDENTITY_ID = keyManager.identityId;
  const identity = await sdk.identities.fetch(IDENTITY_ID);

  const result = await sdk.addresses.topUpIdentity({
    identity,
    inputs: [
      {
        address: addressKeyManager.primaryAddress.bech32m,
        amount: 200000n, // Credits to transfer
      },
    ],
    signer,
  });

  console.log(`Top-up result:
  Start balance: ${identity.toJSON().balance}
  Final balance: ${result.newBalance}`);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we get the address signer from the address key manager and fetch the identity to top up using its ID from the key manager.

We then call `sdk.addresses.topUpIdentity()` with the identity, the source platform address, the amount of credits to transfer, and the signer to authorize the transfer. The start and final balances are logged to confirm the top-up succeeded.
