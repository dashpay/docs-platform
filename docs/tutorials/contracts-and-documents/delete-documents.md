```{eval-rst}
.. tutorials-delete-documents:
```

# Delete documents

In this tutorial we will update delete data from Dash Platform. Data is stored in the form of [documents](../../explanations/platform-protocol-document.md) which are encapsulated in a [state transition](../../explanations/platform-protocol-state-transition.md) before being submitted to DAPI.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- Access to a previously created document (e.g., one created using the [Submit Documents tutorial](../../tutorials/contracts-and-documents/submit-documents.md))

## Code

```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const deleteNoteDocument = async () => {
  const { platform } = client;
  const identity = await platform.identities.get('an identity ID goes here');
  const documentId = 'an existing document ID goes here';

  // Retrieve the existing document
  const [document] = await client.platform.documents.get(
    'tutorialContract.note',
    { where: [['$id', '==', documentId]] },
  );

  // Sign and submit the document delete transition
  await platform.documents.broadcast({ delete: [document] }, identity);
  return document;
};

deleteNoteDocument()
  .then((d) => console.log('Document deleted:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

:::{tip}
The example above shows how access to contract documents via `<contract name>.<contract document>` syntax (e.g. `tutorialContract.note`) can be enabled by passing a contract identity to the constructor. Please refer to the [Dash SDK documentation](https://github.com/dashpay/platform/blob/master/packages/js-dash-sdk/docs/getting-started/multiple-apps.md) for details.
:::

## What's happening

After we initialize the Client, we retrieve the document to be deleted via `platform.documents.get` using its `id`.

Once the document has been retrieved, we must submit it to [DAPI](../../explanations/dapi.md). Documents are submitted in batches that may contain multiple documents to be created, replaced, or deleted. In this example, a single document is being deleted.

The `platform.documents.broadcast` method takes the document batch (e.g. `{delete: [documents[0]]}`) and an identity parameter. Internally, it creates a [State Transition](../../explanations/platform-protocol-state-transition.md) containing the previously created document, signs the state transition, and submits the signed state transition to DAPI.

:::{note}
:class: note
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::
