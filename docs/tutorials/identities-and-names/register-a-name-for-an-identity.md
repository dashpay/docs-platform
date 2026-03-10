```{eval-rst}
.. tutorials-register-name-for-identity:
```

# Register a name for an identity

The purpose of this tutorial is to walk through the steps necessary to register a [Dash Platform Name Service (DPNS)](../../reference/glossary.md#dash-platform-naming-service-dpns) name.

## Overview

Dash Platform names make cryptographic identities easy to remember and communicate by enabling them to link to one or more names. Additional details regarding identities can be found in the [Identity description](../../explanations/identity.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- A name you want to register: [Name restrictions](../../explanations/dpns.md#implementation)

## Code

:::{tip}
Pass only the label (e.g., `myname`), not the full domain name. The `.dash` suffix is handled by the SDK. Currently, only the `dash` top-level domain may be used.
:::

```{code-block} javascript
:caption: name-register.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

// ⚠️ Change this to a unique name to register
const NAME_LABEL = 'alice';

try {
  // Register a DPNS name for the identity
  const result = await sdk.dpns.registerName({
    label: NAME_LABEL,
    identity,
    identityKey,
    signer,
  });

  console.log('Name registered:\n', result.toJSON());
} catch (e) {
  if (e.message?.includes('duplicate unique properties')) {
    console.error(
      `Name "${NAME_LABEL}.dash" is already registered. Try a different name.`,
    );
  } else {
    console.error('Something went wrong:\n', e.message);
  }
}
```

## What's Happening

After initializing the client, we get the auth key signer using `keyManager.getAuth()`. We then call `sdk.dpns.registerName()` with the label (name without the `.dash` suffix), the identity, and the signing credentials. The SDK submits a DPNS domain document to the network. We wait for the result and output it to the console.
