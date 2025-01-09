```{eval-rst}
.. _reference-query-syntax:
```

# Query Syntax

## Overview

Generally queries will consist of a `where` clause plus optional [modifiers](#query-modifiers) controlling the specific subset of results returned.

## Where Clause

The Where clause must be a non-empty array containing not more than 10 conditions. For some operators, `value` will be an array. All fields referenced in a query's where clause must be defined in the same index. This includes `$createdAt` and `$updatedAt`. See the following general syntax example:

```json Syntax
{
  where: [
    [<fieldName>, <operator>, <value>],
    [<fieldName>, <array operator>, [<value1>, <value2>]] 
  ] 
}
```

### Fields

Valid fields consist of the indices defined for the document being queried. For example, the [DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json) defines two indices for domain documents:

| Index Field(s) | Index Type | Unique |
| - | - | :-: |
| [normalizedParentDomainName, normalizedLabel](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json#L5-L16) | Compound | Yes |
| [records.identity](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json#L31-L39) | Single Field | No |

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

| Name | Description |
| :-: | - |
| < | Matches values that are less than a specified value |
| <= | Matches values that are less than or equal to a specified value |
| >= | Matches values that are greater than or equal to a specified value |
| > | Matches values that are greater than a specified value |
| in | Matches all document(s) where the value of the field equals any value in the specified array <br>Array may include up to 100 (unique) elements |

:::{tip}
- Only one range operator is allowed in a query (except for between behavior)
- The `in` operator is only allowed for last two indexed properties
- Range operators are only allowed after `==` and `in` operators
- Range operators are only allowed for the last two fields used in the where condition
- Queries using range operators must also include an `orderBy` statement
:::

### Evaluation Operators

| Name | Description |
| :-: | - |
| startsWith | Selects documents where the value of a field begins with the specified characters (string, <= 255 characters). Must include an `orderBy` statement. |

### Operator Examples

::::{tab-set}
:::{tab-item} Range
```json
{
  where: [
    ["nameHash", "<", "56116861626961756e6176657a382e64617368"],
  ],
}
```
:::

:::{tab-item} in
```json in
{
  where: [
      ["normalizedParentDomainName", "==", "dash"],
      // Return all matching names from the provided array
      ["normalizedLabel", "in", ["alice", "bob"]],
    ]
}
```
:::

:::{tab-item} startsWith
```json startsWith
{
  where: [
      ["normalizedParentDomainName", "==", "dash"],
      // Return any names beginning with "al" (e.g. alice, alfred)
      ["normalizedLabel", "startsWith", "al"],
    ],
  orderBy: [
    ["normalizedLabel", "asc"],
  ]
}
```
:::
::::

## Query Modifiers

The query modifiers described here determine how query results will be sorted and what subset of data matching the query will be returned.

| Modifier | Effect | Example |
| - | - | - |
| `limit` | Restricts the number of results returned (maximum: 100) | `limit: 10` |
| `orderBy` | Returns records sorted by the field(s) provided (maximum: 2). Sorting must be by the last indexed property. Can only be used with `>`, `<`, `>=`, `<=`, and `startsWith` queries. | `orderBy: [['normalizedLabel', 'asc']]` |
| `startAt` | Returns records beginning with the document ID provided | `startAt: Buffer.from(Identifier.from(<document ID>))` |
| `startAfter` | Returns records beginning after the document ID provided | `startAfter: Buffer.from(Identifier.from(<document ID>))` |

:::{attention}
For indices composed of multiple fields ([example from the DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json)), the sort order in an `orderBy` must either match the order defined in the data contract OR be the inverse order.
:::

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
