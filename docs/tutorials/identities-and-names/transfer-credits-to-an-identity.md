```{eval-rst}
.. tutorials-transfer-credits-to-identity:
```

# Transfer to an Identity

The purpose of this tutorial is to walk through the steps necessary to transfer credits to an
identity. Additional details regarding credits can be found in the [credits description](../../explanations/identity.md#credits).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK
  installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a
  Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- Two Dash Platform Identities: [Tutorial: Register an
  Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const transferCreditsToIdentity = async () => {
  const identityId = 'identity ID of the sender goes here';
  const identity = await client.platform.identities.get(identityId);

  const recipientID = 'identity ID of the recipient goes here';
  console.log('Recipient identity balance before transfer: ', recipientIdentity.balance);
  const transferAmount = 300000; // Number of credits to transfer

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

:::{note}
:class: note
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::
