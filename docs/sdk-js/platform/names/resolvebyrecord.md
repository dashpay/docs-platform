# ResolveByRecord

**Usage**: `client.platform.names.resolveByRecord(record, value)`  
**Description**: This method will allow you to resolve a DPNS record by identity ID.

Parameters:

| Parameters | Type   | Required | Description                                                          |
| ---------- | ------ | -------- | -------------------------------------------------------------------- |
| **record** | String | yes      | Type of the record (`identity`) |
| **value**  | String | yes      | Identifier value for the record                                      |

**Example**:

This example will describe how to resolve names by the dash unique identity id.

```js
const identityId = '3ge4yjGinQDhxh2aVpyLTQaoka45BkijkoybfAkDepoN';
const document = await client.platform.names.resolveByRecord('identity', identityId);
```

Returns: array of ExtendedDocument.