# Overview

In this tutorial we will submit some data to an application on Dash Platform. Data is stored in the form of [documents](explanation-platform-protocol-document) which are encapsulated in a [state transition](explanation-platform-protocol-state-transition) before being submitted to DAPI. 

## Prerequisites

- [General prerequisites](tutorials-introduction#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](tutorial-create-and-fund-a-wallet)
- A Dash Platform Identity: [Tutorial: Register an Identity](tutorial-register-an-identity)
- A Dash Platform Contract ID: [Tutorial: Register a Data Contract](tutorial-register-a-data-contract) 

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
      contractId: '3iaEhdyAVbmSjd59CT6SCrqPjfAfMdPTc8ksydgqSaWE',
    },
  },
};
const client = new Dash.Client(clientOpts);

const submitNoteDocument = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');

  const docProperties = {
    message: `Tutorial Test @ ${new Date().toUTCString()}`,
  };

  // Create the note document
  const noteDocument = await platform.documents.create(
    'tutorialContract.note',
    identity,
    docProperties,
  );

  const documentBatch = {
    create: [noteDocument], // Document(s) to create
    replace: [], // Document(s) to update
    delete: [], // Document(s) to delete
  };
  // Sign and submit the document(s)
  return platform.documents.broadcast(documentBatch, identity);
};

submitNoteDocument()
  .then((d) => console.log(d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```



> 👍 Initializing the Client with a contract identity
> 
> The example above shows how access to contract documents via `<contract name>.<contract document>` syntax (e.g. `tutorialContract.note`) can be enabled by passing a contract identity to the constructor. Please refer to the [Dash SDK documentation](https://github.com/dashevo/platform/blob/master/packages/js-dash-sdk/docs/getting-started/multiple-apps.md) for details.

# What's happening

After we initialize the Client, we create a document that matches the structure defined by the data contract of the application being referenced (e.g. a `note` document for the contract registered in the [data contract tutorial](tutorial-register-a-data-contract#section-code)). The `platform.documents.create` method takes three arguments: a document locator, an identity, and the document data. The document locator consists of an application name (e.g. `tutorialContract`) and the document type being created (e.g. `note`). The document data should contain values for each of the properties defined for it in the data contract (e.g. `message` for the tutorial contract's note).

Once the document has been created, we still need to submit it to [DAPI](explanation-dapi). Documents are submitted in batches that may contain multiple documents to be created, replaced, or deleted. In this example, a single document is being created. The `documentBatch` object defines the action to be completed for the document (the empty action arrays - `replace` and `delete` in this example - may be excluded and are shown for reference only here).

The `platform.documents.broadcast` method then takes the document batch and an identity parameter. Internally, it creates a [State Transition](explanation-platform-protocol-state-transition) containing the previously created document, signs the state transition, and submits the signed state transition to DAPI.

> 📘 Wallet Operations
> 
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
> 
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.