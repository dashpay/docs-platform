```{eval-rst}
.. tutorials-register-identity:
```

# Register an Identity

The purpose of this tutorial is to walk through the steps necessary to register an identity.

## Overview

Identities serve as the basis for interactions with Dash Platform. They consist primarily of a public key used to register a unique entity on the network. Additional details regarding identities can be found in the [Identity description](../../explanations/identity.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [How to Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)

## Code

```{code-block} javascript
:caption: identity-register.mjs

import { randomBytes } from 'node:crypto';
import { Identity, Identifier } from '@dashevo/evo-sdk';
import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager, addressKeyManager } = await setupDashClient({
  requireIdentity: false,
});

try {
  // Build the identity shell with 5 standard public keys
  const identity = new Identity(new Identifier(randomBytes(32)));
  keyManager.getKeysInCreation().forEach((key) => {
    identity.addPublicKey(key.toIdentityPublicKey());
  });

  // Create the identity on-chain, funded from the platform address
  const result = await sdk.addresses.createIdentity({
    identity,
    inputs: [
      {
        address: addressKeyManager.primaryAddress.bech32m,
        amount: 5000000n, // Credits to fund the new identity
      },
    ],
    identitySigner: keyManager.getFullSigner(),
    addressSigner: addressKeyManager.getSigner(),
  });

  console.log(
    'Identity registered!\nIdentity ID:',
    result.identity.id.toString(),
  );
} catch (e) {
  // Known SDK bug: proof verification fails but the identity was created
  // Issue: https://github.com/dashpay/platform/issues/3095
  // Extract the real identity ID from the error message
  const match = e.message?.match(/proof returned identity (\w+) but/);
  if (match) {
    console.log('Identity registered!\nIdentity ID:', match[1]);
  } else {
    console.error('Something went wrong:\n', e.message);
  }
}
```

:::{attention}
Make a note of the returned identity ID as it will be used in subsequent tutorials throughout the documentation.
:::

## What's Happening

We call `setupDashClient({ requireIdentity: false })` since we're creating a new identity rather than loading an existing one. This connects to the network and derives keys from the mnemonic, returning `sdk`, `keyManager`, and `addressKeyManager`.

1. **Identity shell**: We create a temporary `Identity` object with a random identifier and attach all 5 standard public keys from the key manager. These keys serve different purposes (master, authentication, transfer, and encryption).

2. **On-chain creation**: We call `sdk.addresses.createIdentity()` which requires two signers -- the `identitySigner` (proves ownership of the identity keys) and the `addressSigner` (authorizes the credit transfer from the platform address). This submits an _Identity Create State Transition_ to the network.
