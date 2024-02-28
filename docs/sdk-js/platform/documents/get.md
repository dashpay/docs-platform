# Get

**Usage**: `client.platform.documents.get(typeLocator, opts)`  
**Description**: This method will allow you to fetch back documents matching the provided parameters.

Parameters:

| Parameters      | Type   | Required         | Description                                                         |
| --------------- | ------ | ---------------- | ------------------------------------------------------------------- |
| **typeLocator** | string | yes              | Field of a specific application, under the form `appName.fieldName` |
| **opts**        | object | no (default: {}) | Query options of the request                                        |

**Queries options**:

| Parameters     | Type    | Required | Description               |
| -------------- | ------- | -------- | ------------------------- |
| **where**      | array   | no       | Mongo-like where query    |
| **orderBy**    | array   | no       | Mongo-like orderBy query  |
| **limit**      | integer | no       | how many objects to fetch |
| **startAt**    | integer | no       | number of objects to skip |
| **startAfter** | integer | no       | exclusive skip            |

[Learn more about query syntax](../../../reference/query-syntax.md).

**Example**:

```js
   const queryOpts = {
         where: [
             ['normalizedLabel', '==', 'alice'],
             ['normalizedParentDomainName', '==', 'dash'],
         ],
     };
  await client.platform.documents.get('dpns.domain', queryOpts);
```
