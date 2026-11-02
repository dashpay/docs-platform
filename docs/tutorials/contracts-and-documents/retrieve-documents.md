```{eval-rst}
.. tutorials-retrieve-documents:
```

# Retrieve documents

In this tutorial we will retrieve some of the current data from a data contract. Data is stored in the form of documents as described in the Dash Platform Protocol [Document explanation](../../explanations/platform-protocol-document.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- (Optional) A Dash Platform Contract ID: [Tutorial: Register a Data Contract](../../tutorials/contracts-and-documents/register-a-data-contract.md) — a default testnet tutorial contract is provided

## Code

```{code-block} javascript
:caption: document-retrieve.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk } = await setupDashClient();

// Default tutorial contract (testnet). Replace or override via DATA_CONTRACT_ID.
const DATA_CONTRACT_ID =
  process.env.DATA_CONTRACT_ID ||
  'FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4';

try {
  const results = await sdk.documents.query({
    dataContractId: DATA_CONTRACT_ID,
    documentTypeName: 'note',
    limit: 2,
  });

  for (const [id, doc] of results) {
    console.log('Document:', id.toString(), doc.toJSON());
  }
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

```{raw} html
<div class="interactive-tutorial interactive-tutorial--integrated" data-operation="documents-query" data-network="testnet" data-renderer="documents">
  <div class="interactive-tutorial__toolbar">
    <strong>Run this example on testnet</strong>
    <span class="interactive-tutorial__connection" data-role="connection"></span>
  </div>
  <div class="interactive-tutorial__controls">
    <div class="interactive-tutorial__field interactive-tutorial__field--wide">
      <label class="interactive-tutorial__label" for="documents-contract-id">Data contract ID</label>
      <input id="documents-contract-id" class="interactive-tutorial__input"
        data-param="dataContractId" data-label="a data contract ID"
        data-default-value="FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4"
        type="text" spellcheck="false" autocomplete="off" required>
    </div>
    <div class="interactive-tutorial__field">
      <label class="interactive-tutorial__label" for="documents-type">Document type</label>
      <input id="documents-type" class="interactive-tutorial__input"
        data-param="documentTypeName" data-label="a document type"
        data-default-value="note" type="text" spellcheck="false" required>
    </div>
    <div class="interactive-tutorial__field interactive-tutorial__field--small">
      <label class="interactive-tutorial__label" for="documents-limit">Limit</label>
      <input id="documents-limit" class="interactive-tutorial__input"
        data-param="limit" data-label="a limit" data-default-value="2"
        type="number" min="1" max="100" required>
    </div>
  </div>
  <div class="interactive-tutorial__actions">
    <button class="interactive-tutorial__button" data-role="run" type="button">Run query</button>
    <button class="interactive-tutorial__button interactive-tutorial__button--text" data-role="reset" type="button">Reset</button>
  </div>
  <details class="interactive-tutorial__source">
    <summary>View browser code</summary>
    <pre><code data-role="source"></code></pre>
  </details>
  <div class="interactive-tutorial__result" data-role="result" aria-live="polite">
    <div class="interactive-tutorial__empty">Run the query to inspect matching documents.</div>
  </div>
</div>
```

### Queries

The example code uses a very basic query to return only two results. More extensive querying capabilities are covered in the [query syntax reference](../../reference/query-syntax.md).

## Example Document

The following examples show the structure of a `note` document returned from the SDK. The values returned by `.toJSON()` include the base document properties (prefixed with `$`) present in all documents along with the data contract defined properties (the `message` propoerty in the example document).

:::{note}
Note: When using `.toJSON()`, binary data is displayed as a base64 string (since JSON is a text-based format).
:::

```json
 {
  "$id": "5CL7qwbGPi4P6jqhat5pQxzSZ9PPxvNkDU8tU9yXYyzt",
  "$ownerId": "FKZZFDTfGdSWUmL2g7H9e46pMJMPQp9DHQcvjrsS6884",
  "$revision": 1,
  "$createdAt": null,
  "$updatedAt": null,
  "$transferredAt": null,
  "$createdAtBlockHeight": null,
  "$updatedAtBlockHeight": null,
  "$transferredAtBlockHeight": null,
  "$createdAtCoreBlockHeight": null,
  "$updatedAtCoreBlockHeight": null,
  "$transferredAtCoreBlockHeight": null,
  "$creatorId": null,
  "$dataContractId": "FW3DHrQiG24VqzPY4ARenMgjEPpBNuEQTZckV8hbVCG4",
  "$type": "note",
  "$entropy": "jsO295ymKBeMAiAwrSsaDX7qjYD/9i+Q8g9MIDx/xik=",
  "message": "Tutorial Test @ Wed, 04 Mar 2026 22:37:48 GMT"
}
```

## What's happening

After we initialize the Client, we request documents using `sdk.documents.query()`. The method takes an object with the `dataContractId`, `documentTypeName`, and optional query parameters like `where`, `orderBy`, `limit`, `startAt`, and `startAfter`.

Results are returned as a `Map` where each key is a document ID and each value is the document object. We iterate over the entries using `for (const [id, doc] of results)`.

If you need more than the default number of documents, use the `startAt` or `startAfter` parameters for pagination.

:::{tip}
See this in an example app: [Dashnote — Read path: queries first](../example-apps/dashnote.md#read-path-queries-first) and [DashMint Lab — Read path: queries first](../example-apps/dashmint-lab.md#read-path-queries-first).
:::
