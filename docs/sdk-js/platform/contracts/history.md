# History

**Usage**: `client.platform.contracts.history(identifier, startAtMs, limit, offset)`  
**Description**: Fetches the historical changes of a Data Contract by its identifier over time.

Parameters:

| Parameters     | Type            | Required | Description                                                                                          |
| -------------- | --------------- | -------- | ---------------------------------------------------------------------------------------------------- |
| **identifier** | string \| Identifier | yes      | The identifier of the contract to fetch. Can be a string or an `Identifier` object.                  |
| **startAtMs**  | number          | yes      | Timestamp in milliseconds from which to start fetching the contract history.                         |
| **limit**      | number          | yes      | The maximum number of history entries to return.                                                     |
| **offset**     | number          | yes      | The number of history entries to skip. Useful for pagination.                                        |

**Example**:

```js
const identifier = 'yourContractIdentifier'; // Your Data Contract identifier.
const startAtMs = Date.now() - (24 * 60 * 60 * 1000); // 24 hours ago
const limit = 10; // Maximum number of history entries to fetch
const offset = 0; // Start from the first entry

const history = await client.platform.contracts.history(identifier, startAtMs, limit, offset);

if (history) {
  console.log('Contract history:', history);
} else {
  console.log('Contract not found or no history available.');
}
```

Returns: An object where keys are timestamps of the contract updates and values are the `DataContract` objects representing the state of the contract at that time. Returns `null` if the contract or its history cannot be found.
