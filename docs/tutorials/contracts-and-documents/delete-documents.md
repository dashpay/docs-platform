```{eval-rst}
.. tutorials-delete-documents:
```

# Delete documents

In this tutorial we will delete data from Dash Platform. Data is stored in the form of [documents](../../explanations/platform-protocol-document.md) which are encapsulated in a [state transition](../../explanations/platform-protocol-state-transition.md) before being submitted to DAPI.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- (Optional) A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md) — a default testnet tutorial contract is provided
- An existing document (e.g., one created using the [Submit Documents tutorial](../../tutorials/contracts-and-documents/submit-documents.md))

## Code

```{code-block} javascript
:caption: document-delete.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

// Default tutorial contract (testnet). Replace or override via DATA_CONTRACT_ID.
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ??
  'FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4';

// Replace with your existing document ID
const DOCUMENT_ID = 'YOUR_DOCUMENT_ID';

try {
  // Delete the document from the platform
  await sdk.documents.delete({
    document: {
      id: DOCUMENT_ID,
      ownerId: identity.id,
      dataContractId: DATA_CONTRACT_ID,
      documentTypeName: 'note',
    },
    identityKey,
    signer,
  });

  console.log('Document deleted successfully');
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's happening

After we initialize the client, we get the auth key signer from the key manager. We then call `sdk.documents.delete()` with an object identifying the document to delete — its `id`, `ownerId`, `dataContractId`, and `documentTypeName` — along with the signing credentials.

Internally, the method creates a [State Transition](../../explanations/platform-protocol-state-transition.md) containing the document deletion instruction, signs the state transition, and submits it to DAPI. Only the document's owner can delete it.

:::{note}
You do not need to retrieve the full document before deleting it. The `sdk.documents.delete()` method only requires the document's identifying fields (`id`, `ownerId`, `dataContractId`, `documentTypeName`).
:::
