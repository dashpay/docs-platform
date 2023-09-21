# Update documents

In this tutorial we will update existing data on Dash Platform. Data is stored in the form of [documents](../../explanations/platform-protocol-document.md) which are encapsulated in a [state transition](../../explanations/platform-protocol-state-transition.md) before being submitted to DAPI. 

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- Access to a previously created document (e.g., one created using the [Submit Documents tutorial](../../tutorials/contracts-and-documents/submit-documents.md))

# Code

```javascript
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
  apps: {
    tutorialContract: {
      contractId: '8cvMFwa2YbEsNNoc1PXfTacy2PVq2SzVnkZLeQSzjfi6',
    },
  },
};
const client = new Dash.Client(clientOpts);

const updateNoteDocument = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');
  const documentId = 'an existing document ID goes here';

  // Retrieve the existing document
  const [document] = await client.platform.documents.get(
    'tutorialContract.note',
    { where: [['$id', '==', documentId]] },
  );

  // Update document
  document.set('message', `Updated document @ ${new Date().toUTCString()}`);

  // Sign and submit the document replace transition
  await platform.documents.broadcast({ replace: [document] }, identity);
  return document;
};

updateNoteDocument()
  .then((d) => console.log('Document updated:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

> 👍 Initializing the Client with a contract identity
> 
> The example above shows how access to contract documents via `<contract name>.<contract document>` syntax (e.g. `tutorialContract.note`) can be enabled by passing a contract identity to the constructor. Please refer to the [Dash SDK documentation](https://github.com/dashevo/platform/blob/master/packages/js-dash-sdk/docs/getting-started/multiple-apps.md) for details.

# What's happening

After we initialize the Client, we retrieve the document to be updated via `platform.documents.get` using its `id`. Once the document has been retrieved, we must submit it to [DAPI](../../explanations/dapi.md) with the desired data updates. Documents are submitted in batches that may contain multiple documents to be created, replaced, or deleted. In this example, a single document is being updated.

The `platform.documents.broadcast` method then takes the document batch (e.g. `{replace: [noteDocument]}`) and an identity parameter. Internally, it creates a [State Transition](../../explanations/platform-protocol-state-transition.md) containing the previously created document, signs the state transition, and submits the signed state transition to DAPI.

> 📘 Wallet Operations
> 
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
> 
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.