```{eval-rst}
.. tutorials-update-documents:
```

# Update documents

In this tutorial we will update existing data on Dash Platform. Data is stored in the form of [documents](../../explanations/platform-protocol-document.md) which are encapsulated in a [state transition](../../explanations/platform-protocol-state-transition.md) before being submitted to DAPI.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- (Optional) A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md) — a default testnet tutorial contract is provided
- An existing document (e.g., one created using the [Submit Documents tutorial](../../tutorials/contracts-and-documents/submit-documents.md))

## Code

```{code-block} javascript
:caption: document-update.mjs

import { Document } from '@dashevo/evo-sdk';
import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

// Default tutorial contract (testnet). Replace or override via DATA_CONTRACT_ID.
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ??
  'FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4';

// Replace with your existing document ID from the Submit Documents tutorial
const DOCUMENT_ID = 'YOUR_DOCUMENT_ID';

try {
  // Fetch the existing document to get current revision
  const docs = await sdk.documents.query({
    dataContractId: DATA_CONTRACT_ID,
    documentTypeName: 'note',
    where: [['$id', '==', DOCUMENT_ID]],
  });
  const existingDoc = [...docs.values()][0];
  if (!existingDoc) {
    throw new Error(`Document ${DOCUMENT_ID} not found`);
  }

  // Create the replacement document with incremented revision
  const document = new Document({
    properties: {
      message: `Updated Tutorial Test @ ${new Date().toUTCString()}`,
    },
    documentTypeName: 'note',
    dataContractId: DATA_CONTRACT_ID,
    ownerId: identity.id,
    revision: existingDoc.revision + 1n,
    id: DOCUMENT_ID,
  });

  // Submit the replacement to the platform
  await sdk.documents.replace({
    document,
    identityKey,
    signer,
  });

  console.log('Document updated:\n', document.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's happening

After we initialize the client, we get the auth key signer from the key manager. We first query for the existing document by its `$id` to retrieve the current `revision` number. We then create a new `Document` object with the updated properties, the same `id`, and the revision incremented by one (as a `BigInt`).

The `sdk.documents.replace()` method takes the document and signing credentials. Internally, it creates a [State Transition](../../explanations/platform-protocol-state-transition.md) containing the replacement document, signs the state transition, and submits it to DAPI.

:::{note}
The SDK requires constructing a complete replacement `Document` with all fields — including the document `id` and incremented `revision`. The example above queries the existing document first to determine the current revision.
:::
