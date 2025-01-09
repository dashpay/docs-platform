```{eval-rst}
.. tutorials-submit-documents:
```

# Submit documents

In this tutorial we will submit some data to an application on Dash Platform. Data is stored in the form of [documents](../../explanations/platform-protocol-document.md) which are encapsulated in a [state transition](../../explanations/platform-protocol-state-transition.md) before being submitted to DAPI.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)
- A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md)

## Code

```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

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
  await platform.documents.broadcast(documentBatch, identity);
  return noteDocument;
};

submitNoteDocument()
  .then((d) => console.log(d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

:::{tip}
The example above shows how access to contract documents via `<contract name>.<contract document>` syntax (e.g. `tutorialContract.note`) can be enabled by passing a contract identity to the constructor. Please refer to the [Dash SDK documentation](https://github.com/dashpay/platform/blob/master/packages/js-dash-sdk/docs/getting-started/multiple-apps.md) for details.
:::

## What's happening

After we initialize the Client, we create a document that matches the structure defined by the data contract of the application being referenced (e.g. a `note` document for the contract registered in the [data contract tutorial](../../tutorials/contracts-and-documents/register-a-data-contract.md#code)). The `platform.documents.create` method takes three arguments: a document locator, an identity, and the document data. The document locator consists of an application name (e.g. `tutorialContract`) and the document type being created (e.g. `note`). The document data should contain values for each of the properties defined for it in the data contract (e.g. `message` for the tutorial contract's note).

Once the document has been created, we still need to submit it to [DAPI](../../explanations/dapi.md). Documents are submitted in batches that may contain multiple documents to be created, replaced, or deleted. In this example, a single document is being created. The `documentBatch` object defines the action to be completed for the document (the empty action arrays - `replace` and `delete` in this example - may be excluded and are shown for reference only here).

The `platform.documents.broadcast` method then takes the document batch and an identity parameter. Internally, it creates a [State Transition](../../explanations/platform-protocol-state-transition.md) containing the previously created document, signs the state transition, and submits the signed state transition to DAPI.

:::{note}
:class: note
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::
