```{eval-rst}
.. tutorials-retrieve-identity:
```

# Retrieve an identity

In this tutorial we will retrieve the identity created in the [Register an Identity tutorial](../../tutorials/identities-and-names/register-an-identity.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```{code-block} javascript
:caption: retrieveIdentity.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();

// Identity ID from the identity create tutorial
const IDENTITY_ID = keyManager.identityId;

if (!IDENTITY_ID) {
  throw new Error(
    'No identity found. Run the "Register an Identity" tutorial first or provide an identity ID.',
  );
}

try {
  const identity = await sdk.identities.fetch(IDENTITY_ID);
  console.log('Identity retrieved:\n', identity.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## Example Identity

The following example response shows a retrieved identity:

```json
{
  "$version": "0",
  "id": "FKZZFDTfGdSWUmL2g7H9e46pMJMPQp9DHQcvjrsS6884",
  "publicKeys": [
    {
      "$version": "0",
      "id": 0,
      "purpose": 0,
      "securityLevel": 0,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "AlBCEk8Ic+6wNW6ifZvZEhAwowcwNsvnINdrM0g8v/E3",
      "disabledAt": null
    },
    {
      "$version": "0",
      "id": 1,
      "purpose": 0,
      "securityLevel": 2,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "A8KQezkA1nv0K3KwL2rwfco3fKEevnnIMWQ6U6q18Oad",
      "disabledAt": null
    },
    {
      "$version": "0",
      "id": 2,
      "purpose": 0,
      "securityLevel": 1,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "Axo18YRoOaN9QXpZBgpt7JOs+KkVSdwsa5qtigDJU9fR",
      "disabledAt": null
    },
    {
      "$version": "0",
      "id": 3,
      "purpose": 3,
      "securityLevel": 1,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "A1XZSbd9slDQnDS+Wt2S2lHXOtoTrPEFSHFquHTryktX",
      "disabledAt": null
    },
    {
      "$version": "0",
      "id": 4,
      "purpose": 1,
      "securityLevel": 3,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "As04TZMCOTYWZnAe2IA1qbdf47005uMDs1YEg+s9t6Rt",
      "disabledAt": null
    }
  ],
  "balance": 5000000,
  "revision": 0
}
```

## What's Happening

After we initialize the client, we request an identity. The `sdk.identities.fetch` method takes a single argument: an identity ID. After the identity is retrieved, it is displayed on the console.
