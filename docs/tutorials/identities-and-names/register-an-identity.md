```{eval-rst}
.. tutorials-register-identity:
```

# Register an Identity

The purpose of this tutorial is to walk through the steps necessary to register an identity.

## Overview

Identities serve as the basis for interactions with Dash Platform. They consist primarily of a public key used to register a unique entity on the network. Additional details regarding identities can be found in the [Identity description](../../explanations/identity.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [How to Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)

## Code

:::{note}
:class: note
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::

```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const createIdentity = async () => {
  return client.platform.identities.register();
};

createIdentity()
  .then((d) => console.log('Identity:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

The Identity will be output to the console. The Identity will need to have one confirmation before it is accessible via `client.platform.identity.get`.

:::{attention}
Make a note of the returned identity `id` as it will be used used in subsequent tutorials throughout the documentation.
:::

## What's Happening

After connecting to the Client, we call `platform.identities.register`. This will generate a keypair and submit an _Identity Create State Transaction_. After the Identity is registered, we output it to the console.
