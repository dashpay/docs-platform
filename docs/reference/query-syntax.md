```{eval-rst}
.. _reference-query-syntax:
```

# Query Syntax

## Overview

Generally queries will consist of a `where` clause plus optional [modifiers](#query-modifiers) controlling the specific subset of results returned.

> 🚧 Query limitations
>
> Dash Platform v0.22 introduced a number of limitations due to the switch to using [GroveDB](https://github.com/dashpay/grovedb). See details in pull requests [77](https://github.com/dashpay/platform/pull/77) and [230](https://github.com/dashpay/platform/pull/230) that implemented these changes.
>
> Query validation details may be found [here](https://github.com/dashpay/platform/blob/master/packages/js-drive/lib/document/query/validateQueryFactory.js) along with the associated validation [tests](https://github.com/dashpay/platform/blob/master/packages/js-drive/test/unit/document/query/validateQueryFactory.spec.js).

## Where Clause

The Where clause must be a non-empty array containing not more than 10 conditions. For some operators, `value` will be an array. See the following general syntax example:

>❗️
>
> As of Dash Platform v0.22, _all fields_ referenced in a query's where clause must be defined in the _same index_. This includes `$createdAt` and `$updatedAt`.

```json Syntax
{
  where: [
    [<fieldName>, <operator>, <value>],
    [<fieldName>, <array operator>, [<value1>, <value2>]] 
  ] 
}
```

### Fields

Valid fields consist of the indices defined for the document being queried. For example, the [DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json) defines three indices:

| Index Field(s) | Index Type | Unique |
| - | - | :-: |
| [normalizedParentDomainName, normalizedLabel](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json#L5-L16) | Compound | Yes |
| [records.dashUniqueIdentityId](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json#L17-L25) | Single Field | Yes |
| [records.dashAliasIdentityId](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json#L26-L33) | Single Field | No |

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<div></div>\n<!--\nSpecial fields - `$id`, `$userId`\n-->\n<style></style>"
  }
  [/block]
```

### Comparison Operators

#### Equal

| Name | Description |
| :-: | - |
| == | Matches values that are equal to a specified value |

#### Range

> 🚧 Dash Platform v0.22 notes
>
> - Only one range operator is allowed in a query (except for between behavior)
> - The `in` operator is only allowed for last two indexed properties
> - Range operators are only allowed after `==` and `in` operators
> - Range operators are only allowed for the last two fields used in the where condition
> - Queries using range operators must also include an `orderBy` statement

| Name | Description |
| :-: | - |
| < | Matches values that are less than a specified value |
| <= | Matches values that are less than or equal to a specified value |
| >= | Matches values that are greater than or equal to a specified value |
| > | Matches values that are greater than a specified value |
| in | Matches all document(s) where the value of the field equals any value in the specified array <br>Array may include up to 100 (unique) elements |

### Array Operators

| Name | Description |
| :-: | - |
| length | **Not available in Dash Platform v0.22**<br>Selects documents if the array field is a specified size (integer) |
| contains | **Not available in Dash Platform v0.22**<br>- Matches arrays that contain all elements specified in the query condition array <br>- 100 element maximum
| elementMatch |  **Not available in Dash Platform v0.22**<br>- Matches documents that contain an array field with at least one element that matches all the criteria in the query condition array <br>- Two or more conditions must be provided

### Evaluation Operators

| Name | Description |
| :-: | - |
| startsWith | Selects documents where the value of a field begins with the specified characters (string, <= 255 characters). Must include an `orderBy` statement. |

### Operator Examples

```json <
{
  where: [
    ['nameHash', '<', '56116861626961756e6176657a382e64617368'],
  ],
}
```

```json in
{
  where: [
      ['normalizedParentDomainName', '==', 'dash'],
      // Return all matching names from the provided array
      ['normalizedLabel', 'in', ['alice', 'bob']],
    ]
}
```

```json startsWith
{
  where: [
      ['normalizedParentDomainName', '==', 'dash'],
      // Return any names beginning with "al" (e.g. alice, alfred)
      ['normalizedLabel', 'startsWith', 'al'],
    ]
}
```

```json length
// Not available in Dash Platform v0.22
// See https://github.com/dashpay/platform/pull/77
{
  where: [
      // Return documents that have 5 values in their `items` array
      ['items', 'length', 5],
    ]
}
```

```json contains
// Not available in Dash Platform v0.22
// See https://github.com/dashpay/platform/pull/77
{
  where: [
      // Return documents that have both "red" and "blue" 
      // in the `colors` array
      ['colors', 'contains', ['red', 'blue']],
    ]
}
```

```json elementMatch
// Not available in Dash Platform v0.22
// See https://github.com/dashpay/platform/pull/77
{
  where: [
    // Return `scores` documents where the results contain 
    // elements in the range 80-90
    ['scores', 'elementMatch',
      [
        ['results', '>=', '80'],
        ['results', '<=', '90']
      ],
    ],
  ]
}
```

## Query Modifiers

The query modifiers described here determine how query results will be sorted and what subset of data matching the query will be returned.

>❗️ Breaking changes
>
> Starting with Dash Platform v0.22, `startAt` and `startAfter` must be provided with a document ID rather than an integer.

| Modifier | Effect | Example |
| - | - | - |
| `limit` | Restricts the number of results returned (maximum: 100) | `limit: 10` |
| `orderBy` | Returns records sorted by the field(s) provided (maximum: 2). Sorting must be by the last indexed property. Can only be used with `>`, `<`, `>=`, `<=`, and `startsWith` queries. | `orderBy: [['normalizedLabel', 'asc']]`
| `startAt` | Returns records beginning with the document ID provided | `startAt: Buffer.from(Identifier.from(<document ID>))` |
| `startAfter` | Returns records beginning after the document ID provided | `startAfter: Buffer.from(Identifier.from(<document ID>))` |

> 🚧 Compound Index Constraints
>
> For indices composed of multiple fields ([example from the DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json)), the sort order in an `orderBy` must either match the order defined in the data contract OR be the inverse order.
>
> Please refer to [pull request 230](https://github.com/dashpay/platform/pull/230) for additional information related to compound index constraints in Platform v0.22.

## Example query

The following query combines both a where clause and query modifiers.

```javascript
import Dash from "dash"

const { Essentials: { Buffer }, PlatformProtocol: { Identifier } } = Dash;

const query = {
  limit: 5,
  startAt: Buffer.from(Identifier.from('4Qp3menV9QjE92hc3BzkUCusAmHLxh1AU6gsVsPF4L2q')),
  where: [
    ['normalizedParentDomainName', '==', 'dash'],
    ['normalizedLabel', 'startsWith', 'test'],
  ],
  orderBy: [
    ['normalizedLabel', 'asc'],
  ],
}
```
