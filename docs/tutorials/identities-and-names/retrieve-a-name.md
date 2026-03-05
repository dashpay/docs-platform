```{eval-rst}
.. tutorials-retrieve-name:
```

# Retrieve a name

In this tutorial we will retrieve the name created in the [Register a Name for an Identity tutorial](../../tutorials/identities-and-names/register-a-name-for-an-identity.md). Additional details regarding identities can be found in the [Identity description](../../explanations/identity.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)

## Code

::::{tab-set}
:::{tab-item} Resolve by Name

```{code-block} javascript
:caption: resolve-by-name.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk } = await setupDashClient();

const NAME = 'quantumexplorer.dash';

try {
  // Resolve by full name (e.g., myname.dash)
  const result = await sdk.dpns.resolveName(NAME);
  console.log(`Identity ID for "${NAME}": ${result}`);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

**Example Response**

```text
Identity ID for "quantumexplorer.dash": BNnn19SAJZuvsUu787dMzPDXASwuCrm4yQ864tEpQFvo
```

:::

:::{tab-item} Get Identity Names

```{code-block} javascript
:caption: get-identity-names.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();

// Identity ID from the identity create tutorial
let IDENTITY_ID = 'GgZekwh38XcWQTyWWWvmw6CEYFnLU7yiZFPWZEjqKHit';

// Uncomment the line below to use the identity created in the earlier tutorial
// IDENTITY_ID = keyManager.identityId;

try {
  // Retrieve usernames registered to an identity
  const usernames = await sdk.dpns.usernames({ identityId: IDENTITY_ID });
  console.log(`Name(s) retrieved for ${IDENTITY_ID}:\n`, usernames);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

**Example Response**

```text
Name(s) retrieved for GgZekwh38XcWQTyWWWvmw6CEYFnLU7yiZFPWZEjqKHit:
 [ 'Tutorial-Test-000000-backup.dash', 'Tutorial-Test-000000.dash' ]
```

:::

:::{tab-item} Search for Name

```{code-block} javascript
:caption: search-by-name.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk } = await setupDashClient();

const DPNS_CONTRACT_ID = 'GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec';
const PREFIX = 'Tutorial-Test-00';

try {
  // Convert prefix to homograph-safe form for normalized search
  const normalizedPrefix = await sdk.dpns.convertToHomographSafe(PREFIX);

  // Search the DPNS contract for matching names
  const results = await sdk.documents.query({
    dataContractId: DPNS_CONTRACT_ID,
    documentTypeName: 'domain',
    where: [
      ['normalizedParentDomainName', '==', 'dash'],
      ['normalizedLabel', 'startsWith', normalizedPrefix],
    ],
    orderBy: [['normalizedLabel', 'asc']],
  });

  for (const [id, doc] of results) {
    const { label, parentDomainName } = doc.toJSON();
    console.log(`${label}.${parentDomainName} (ID: ${id.toString()})`);
  }
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

**Example Response**

```text
Tutorial-Test-000000.dash (ID: E8m6NCCnpschx4WRfk1uLMHqttqMJKPwYt8fWaVSJPrL)
Tutorial-Test-000000-backup.dash (ID: 98bruK9TdJki5xP8BYpmNXqdH9ZHzBD9phwDRzhaJsWF)
```

:::
::::

## What's Happening

After we initialize the Client, we request a name. The [code examples](#code) demonstrate the three ways to request a name:

1. **Resolve by name.** The `sdk.dpns.resolveName` method takes a single argument: a fully-qualified name (e.g., `quantumexplorer.dash`). It returns the identity ID that the name resolves to.
2. **Get identity names.** The `sdk.dpns.usernames` method takes an object with an `identityId` property to find all names registered to that identity. It returns an array of fully-qualified names.
3. **Search.** To search for names by prefix, we query the DPNS contract's `domain` documents directly using `sdk.documents.query()`. The prefix is first converted to a homograph-safe form via `sdk.dpns.convertToHomographSafe()`. Results are returned as a `Map` of document IDs to document objects. We call `.toJSON()` on each document to extract the `label` and `parentDomainName`.
