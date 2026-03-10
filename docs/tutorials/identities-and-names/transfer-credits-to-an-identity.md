```{eval-rst}
.. tutorials-transfer-credits-to-identity:
```

# Transfer to an Identity

The purpose of this tutorial is to walk through the steps necessary to transfer credits to an
identity. Additional details regarding credits can be found in the [credits description](../../explanations/identity.md#credits).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK
  installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- Two Dash Platform Identities: [Tutorial: Register an
  Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```{code-block} javascript
:caption: identity-transfer-credits.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, signer } = await keyManager.getTransfer();

// Default recipient (testnet). Replace or override via RECIPIENT_ID.
const recipientId =
  process.env.RECIPIENT_ID ?? '7XcruVSsGQVSgTcmPewaE4tXLutnW1F6PXxwMbo8GYQC';
const transferAmount = 100000n; // Credits to transfer

try {
  await sdk.identities.creditTransfer({
    identity,
    recipientId,
    amount: transferAmount,
    signer,
  });

  const recipient = await sdk.identities.fetch(recipientId);
  console.log('Recipient identity balance after transfer:', recipient.balance);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we get the transfer key signer using `keyManager.getTransfer()`. We then call `sdk.identities.creditTransfer()` with our identity, the recipient's identity ID, and the amount to transfer. After the credits are transferred, we retrieve the recipient's identity and output their updated balance to the console.
