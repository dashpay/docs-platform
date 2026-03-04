```{eval-rst}
.. tutorials-submit-documents:
```

# Submit documents

In this tutorial we will submit some data to an application on Dash Platform. Data is stored in the form of [documents](../../explanations/platform-protocol-document.md) which are encapsulated in a [state transition](../../explanations/platform-protocol-state-transition.md) before being submitted to DAPI.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- (Optional) A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md) — a default testnet tutorial contract is provided

## Code

```{code-block} javascript
:caption: submitDocument.mjs

import { Document } from '@dashevo/evo-sdk';
import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

// Default tutorial contract (testnet). Replace or override via DATA_CONTRACT_ID.
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ??
  'FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4';

try {
  // Create a new document
  const document = new Document({
    properties: {
      message: `Tutorial Test @ ${new Date().toUTCString()}`,
    },
    documentTypeName: 'note',
    dataContractId: DATA_CONTRACT_ID,
    ownerId: identity.id,
  });

  // Submit the document to the platform
  await sdk.documents.create({
    document,
    identityKey,
    signer,
  });

  console.log('Document submitted:\n', document.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's happening

After we initialize the Client via `setupDashClient()`, we get the auth key signer from the key manager. We then create a `Document` object with the properties defined by the data contract (e.g. a `message` for the `note` document type), along with the contract ID and document type name.

The `sdk.documents.create()` method takes the document and signing credentials. Internally, it creates a [State Transition](../../explanations/platform-protocol-state-transition.md) containing the document, signs the state transition, and submits it to DAPI.
