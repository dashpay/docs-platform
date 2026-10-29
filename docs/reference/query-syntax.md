```{eval-rst}
.. _reference-query-syntax:
```

# Query Syntax

## Overview

Generally queries will consist of a `where` clause plus optional [modifiers](#query-modifiers) controlling the specific subset of results returned.

## Where Clause

The Where clause is an optional array of conditions. If omitted or empty, all documents of the queried type are returned (subject to `limit`). For some operators, `value` will be an array. All fields referenced in a query's where clause must be defined in the same index. This includes system timestamp fields (e.g., `$createdAt`, `$updatedAt`, `$transferredAt`, and their block-height variants such as `$createdAtBlockHeight` and `$createdAtCoreBlockHeight`). See the following general syntax example:

:::{code-block} json
:force:
:caption: Syntax

{
  where: [
    [<fieldName>, <operator>, <value>],
    [<fieldName>, <array operator>, [<value1>, <value2>]] 
  ]
}
:::

### Fields

Valid fields consist of the indices defined for the document being queried. For example, the [DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json) defines two indices for domain documents:

| Index Field(s) | Index Type | Unique |
| - | - | :-: |
| [normalizedParentDomainName, normalizedLabel](https://github.com/dashpay/platform/blob/v5.0.1/packages/dpns-contract/schema/v2/dpns-contract-documents.json#L12-L33) | Compound | Yes |
| [records.identity](https://github.com/dashpay/platform/blob/v5.0.1/packages/dpns-contract/schema/v2/dpns-contract-documents.json#L34-L42) | Single Field | No |

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
| == (or =) | Matches values that are equal to a specified value |

#### Range

| Name | Description |
| :-: | - |
| < | Matches values that are less than a specified value |
| <= | Matches values that are less than or equal to a specified value |
| >= | Matches values that are greater than or equal to a specified value |
| > | Matches values that are greater than a specified value |
| in | Matches all document(s) where the value of the field equals any value in the specified array <br>The array must contain between 1 and 100 values, with no duplicates. Empty arrays, oversized arrays, and duplicate values are rejected with `InvalidInClause` |
| Between | Matches values between two bounds (inclusive on both sides) — value must be a two-element array `[lower, upper]` with `lower < upper` |
| BetweenExcludeBounds | Matches values strictly between two bounds (exclusive on both sides) |
| BetweenExcludeLeft | Matches values between two bounds, excluding the lower bound |
| BetweenExcludeRight | Matches values between two bounds, excluding the upper bound |

**Range operator constraints**

- A query can have only one effective range clause. Use `Between` or one of its variants to express both bounds, or supply two complementary range clauses on the same field; Platform normalizes the pair to the equivalent `Between*` form
- A single `in` clause is only allowed for the last two indexed properties. This applies to ordinary document queries and grouped aggregates; [ranked](#ranked-aggregate-queries) and [having-range](#having-range-queries) queries instead pin each leading index property with one clause, at most one of which may be an `in` of 2 to 10 elements
- *Added in Dash Platform v5.0.0:* from protocol version 14, a query returning `DOCUMENTS` may carry several `in` clauses when they sit on consecutive properties of one compound index, after any `==` clauses and with an optional range clause right after the last `in`. Each `in` property needs an `orderBy` entry, the product of the `in` array sizes may not exceed 100 (`InvalidInClause` otherwise), and `startAt` / `startAfter` cannot be combined with more than one `in`. Grouped aggregate queries still accept only one `in` clause, and protocol version 13 and earlier reject a second `in` clause with `MultipleInClauses`
- Range operators apply to an indexed field that follows any `==` and `in` clauses in the index. A standalone range (with no preceding `==`/`in` clause) is valid when a matching index exists
- Range operators are only allowed for the last two fields used in the where condition
- Queries using range operators (including `in`, which is treated as a range) must also include an `orderBy` statement

### Evaluation Operators

| Name | Description |
| :-: | - |
| startsWith | Selects documents where the value of a field begins with the specified characters. Must include an `orderBy` statement. |
| inTimeRange | Selects documents falling in one window of a `timeRange` index grid. See [Time-range selection](#time-range-selection). Available on the v1 query surface only. |
| inIntegerRange | *Added in Dash Platform v5.0.0.* Selects documents falling in one window of an `integerRange` index grid. See [Integer-range selection](#integer-range-selection). Available on the v1 query surface only. |
| contains | *Added in Dash Platform v5.0.0.* Selects documents whose typed array holds the specified element. See [Typed array elements](#typed-array-elements). |
| containsAny | *Added in Dash Platform v5.0.0.* Selects documents whose typed array holds any of the specified elements. See [Typed array elements](#typed-array-elements). |

#### Time-range selection

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

The `inTimeRange` operator selects one window of a time grid rather than comparing against a value. The clause's field must name a timestamp covered by a [`timeRange` index](../reference/data-contracts.md#document-indices), and the operand is a typed selection rather than an ordinary value:

| Selector | Selects |
| - | - |
| `NEWEST` | The freshest started window - the largest grid start at or before block time, so the latest partial slice of history. |
| `OLDEST` | The oldest window still active at block time, a near-full trailing window. Best for "trending over the last window" reads. |
| `BY_START` | A named window, current or historic, identified by its start timestamp. |

The relative selectors (`NEWEST` and `OLDEST`) are resolved server-side from the current block time, and a proof verifier re-derives the same window from the quorum-signed response metadata time, so neither side has to trust the other's clock. They must not carry a start timestamp.

`BY_START` requires a start timestamp in milliseconds, and it must lie on the grid (`start_ms == phase + k * step`). An unaligned start is rejected rather than snapped to the nearest window. A window holding no documents - including one that has not started yet - is a provable empty answer, not an error.

A query may carry at most one window selection - one `inTimeRange` or one `inIntegerRange` clause, not both. When more than one `timeRange` grid buckets the field, the clause must also name the grid (its `range`, `step`, and `phase`, in the contract's own seconds); a bare selector is ambiguous there and rejected. Naming the grid is optional when exactly one grid covers the field.

If the index declares a `ttl`, a `BY_START` window that has passed the ttl horizon is rejected with `Unsupported`. Expired windows are drained lazily and may be partially removed, so they are not queryable.

#### Integer-range selection

:::{versionadded} 5.0.0
Requires protocol version 14, which introduces `integerRange` indices.
:::

The `inIntegerRange` operator selects one window of an integer grid, the integer counterpart of [time-range selection](#time-range-selection). The clause's field must name an integer property covered by an `integerRange` index; on any other field the clause is rejected with `WhereClauseOnNonIndexedProperty`. The operand is a typed selection, `integer_range`, carrying:

| Field | Description |
| - | - |
| `start` | Required. The window's start, as an integer value (`int64_value` or `uint64_value`). It must be a window start of the grid - `phase + k * step` within the property's integer type, or the type's minimum when that starts a clamped bottom window. An unaligned start is rejected with `Unsupported` rather than snapped. |
| `grid` | The grid's `range`, `step`, and `phase`, verbatim from the contract's `integerRange` declaration. Required when more than one grid buckets the field; optional while exactly one does. |

The window is named absolutely, so both the node and a proof verifier resolve it from the query alone. A window holding no documents is a provable empty answer, not an error. The bucketed property cannot also carry a range clause, an `in` clause, or an `orderBy`, and the `inIntegerRange` clause counts toward the one-window-selection limit above. Chained and composite queries reject window selections.

#### Typed array elements

:::{versionadded} 5.0.0
Requires protocol version 14. Earlier versions reject both operators with `Unsupported`.
:::

A typed array is an `array` property whose `items` schema names a single scalar element type. An index on a typed array holds each document once per distinct element, so the array is queried by its elements:

- `contains` matches documents whose array holds the given element. The operand is one non-null value of the element type. It behaves as an equality and may page with `startAt` / `startAfter`, provided the cursor document holds the element.
- `containsAny` matches documents whose array holds any of the given elements. The operand is an array of 1 to 100 distinct values; an empty, oversized, or duplicated array is rejected with `InvalidInClause`. A document holding several of the elements is returned once, where it first appears, but `limit` counts every index entry walked, so a page can hold fewer documents than the limit. `containsAny` accepts an `orderBy` on the array, which sets the order the elements are walked in, and rejects cursors.

No other operator may name a typed array, and neither operator may name anything else; both mismatches are rejected with `InvalidWhereClauseComponents`. An `orderBy` on a typed array is accepted only together with `containsAny` on it. In aggregate queries, `contains` is accepted wherever an equality is; `containsAny` is accepted for `COUNT`, `SUM`, and `AVG` only when grouped by the array alone with no range clause, and is rejected by ranked and having-range queries and by composite and chained queries.

### Operator aliases

Operator names are matched against a fixed set of aliases:

| Operator | Accepted aliases |
| - | - |
| `==` | `=` |
| `in` | `In` |
| `Between` | `between` |
| `BetweenExclude*` | CamelCase, lowercase, and snake_case variants, such as `betweenExcludeLeft`, `betweenexcludeleft`, and `between_exclude_left` |
| `startsWith` | `StartsWith`, `startswith`, `starts_with` |
| `contains` | `Contains` |
| `containsAny` | `ContainsAny`, `containsany`, `contains_any` |

Any other spelling is rejected.

### Operator Examples

:::::{tab-set}
::::{tab-item} Range
:::{code-block} json
:force:

{
  where: [
    ["nameHash", "<", "56116861626961756e6176657a382e64617368"],
  ],
  orderBy: [
    ["nameHash", "asc"],
  ],
}
:::
::::

::::{tab-item} Between
:::{code-block} json
:force:

{
  where: [
    ["normalizedParentDomainName", "==", "dash"],
    // Return names between "alice" and "carol" (inclusive)
    ["normalizedLabel", "Between", ["alice", "carol"]],
  ],
  orderBy: [
    ["normalizedLabel", "asc"],
  ]
}
:::
::::

::::{tab-item} in
:::{code-block} json
:force:
:caption: in

{
  where: [
      ["normalizedParentDomainName", "==", "dash"],
      // Return all matching names from the provided array
      ["normalizedLabel", "in", ["alice", "bob"]],
    ],
  orderBy: [
    ["normalizedLabel", "asc"],
  ]
}
:::
::::

::::{tab-item} startsWith
:::{code-block} json
:force:
:caption: startsWith

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
:::
::::
:::::

## Query Modifiers

The query modifiers described here determine how query results will be sorted and what subset of data matching the query will be returned.

| Modifier | Effect | Example |
| - | - | - |
| `limit` | Restricts the number of documents returned. An omitted value or `0` uses the configured default (100 by default). Positive values cannot exceed the configured maximum (also 100 by default). See [Aggregate query limits](#aggregate-query-limits) for aggregate result modes. | `limit: 10` |
| `orderBy` | Returns records sorted by the field(s) provided. The `orderBy` fields must match a consecutive run of the index's properties, read from the end of the index (for a compound index, sort by one or more of its trailing fields). Required for `>`, `<`, `>=`, `<=`, `in`, `Between`, `BetweenExcludeBounds`, `BetweenExcludeLeft`, `BetweenExcludeRight`, and `startsWith` queries. Can also be used with equality-only queries to sort by a trailing field of the matched index. | `orderBy: [['normalizedLabel', 'asc']]` |
| `startAt` | Returns records beginning with the document ID provided | `startAt: '<document ID>'` |
| `startAfter` | Returns records beginning after the document ID provided | `startAfter: '<document ID>'` |
| `offset` | On the v1 `getDocuments` wire, consumed only in [ranked aggregate mode](#ranked-aggregate-queries), where it skips that many ranks before the returned page and the response reports the skip performed; every other v1 path rejects it with `Unsupported`, so use `startAt` or `startAfter` for pagination there. | `offset: 20` |

### Ordering compound indexes

For indices composed of multiple fields ([example from the DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json)), the sort order in an `orderBy` must either match the order defined in the data contract OR be the inverse order.

### Combining a cursor with a range operator

This behavior applies when returning `DOCUMENTS`; aggregate result modes do not support cursors.

When a `startAt` / `startAfter` cursor is combined with a range operator (`>`, `>=`, `<`, `<=`), the cursor narrows the effective range in the direction of the `orderBy` sort:

- Ascending order — the cursor is the lower bound and the range clause's value is the upper bound. `startAfter` excludes the cursor row itself.
- Descending order — the roles invert: the range clause's value is the lower bound and the cursor is the upper bound.

:::{versionchanged} 4.1.0
Ascending queries that combined a cursor with a `<` or `<=` clause previously [built their range backwards](https://github.com/dashpay/platform/blob/v4.1.0/packages/rs-drive/src/query/conditions.rs#L944-L990), returning incorrect or empty results. Paginating a bounded range now returns the expected results, so a query written against the earlier behavior may return different results after upgrading.
:::

## Aggregate Queries

:::{versionadded} 4.0.0
:::

:::{versionchanged} 5.0.0
Protocol version 14 adds [ranked](#ranked-aggregate-queries) and [having-range](#having-range-queries) query modes, and relaxes the blanket rejection of `HAVING` and `OFFSET` accordingly.
:::

The [getDocuments](../reference/dapi-endpoints-platform-endpoints.md#getdocuments) v1 surface adds an aggregate-query mode. The same `where` / `orderBy` clauses described above still apply; an additional `select` projection (and optional `groupBy`) determines whether the request returns documents or aggregate values over the matched set.

| `select` | Returns |
| - | - |
| `DOCUMENTS` | Matched documents (same as v0). |
| `COUNT(*)` | Number of documents matching the query. |
| `SUM(<field>)` | Sum of `<field>` across matching documents. |
| `AVG(<field>)` | `(count, sum)` pair the client divides to compute the average. |

`groupBy` is optional. With an empty `groupBy`, the response carries a single aggregate value; with a `groupBy` of one or two fields, the response carries one entry per group. Each `groupBy` field must be constrained by the query's where clause: a single field must carry an `in` or range clause (`startsWith` counts as a range here), and two fields must be an (`in` field, range field) pair. Any other `groupBy` shape is currently rejected with `Unsupported`.

Aggregate queries impose extra schema requirements. For unfiltered doctype-wide aggregates, the document type must set the doctype-level flags — `COUNT` needs `documentsCountable`, `SUM` needs `documentsSummable`, `AVG` needs `documentsAverageable` (or both base flags). An aggregate with a `where` clause or `groupBy` instead requires an index covering the queried fields that carries the corresponding index-level flags (`countable`, `summable`, `averageable`). Range-grouped aggregates additionally need the `range*` variants, and [ranked](#ranked-aggregate-queries) and [having-range](#having-range-queries) queries need the matching ranked axis (`rankedCountable`, `rankedSummable`, or `rankedAverageable`), each of which costs its own secondary tree and is opted into separately. See the [aggregate query flags](../protocol-ref/data-contract-document.md#aggregate-query-flags) for the schema annotations and the [`getDocuments` reference](../reference/dapi-endpoints-platform-endpoints.md#getdocuments) for the full `select` × `groupBy` shape table.

On the raw gRPC layer, `SUM` / `AVG` integer values are delivered to JavaScript clients as strings so they don't lose precision on values larger than `Number.MAX_SAFE_INTEGER`.

### Aggregate query limits

The `limit` modifier behaves differently in aggregate result modes than it does when returning `DOCUMENTS`, and some `select` × `groupBy` combinations reject it outright. On the wire, [`limit` is an optional field](https://github.com/dashpay/platform/blob/v5.0.1/packages/dapi-grpc/protos/platform/v0/platform.proto#L1786-L1830):

- Omit `limit` to request the server's default.
- Send a positive value to request an explicit cap.
- An explicit `limit: 0` is rejected with `InvalidLimit` in every `select` mode, including `DOCUMENTS`. On this wire `0` is never a "use the default" sentinel; that behavior applies to SDK query objects and the v0 `getDocuments` wire, where the limit field has no unset state and `0` means omitted (see [Query Modifiers](#query-modifiers)).

SDK bindings that must pass a numeric argument use `-1` as the server-default sentinel; any other negative value is rejected.

:::{versionchanged} 4.1.0
In aggregate result modes, an effective limit of zero is now rejected with `InvalidLimit` rather than walking storage with a zero bound, which previously surfaced as an empty result set.
:::

How a positive `limit` is interpreted depends on `groupBy`:

| `select` / `groupBy` | Effect of `limit` |
| - | - |
| `DOCUMENTS` | Uses the general behavior described under [Query Modifiers](#query-modifiers). |
| `COUNT` with an empty `groupBy` | Rejected with `InvalidLimit`. An aggregate count is a single row by construction. |
| `COUNT` grouped by an `In` field | Rejected with `InvalidLimit`. The `In` array is already capped at 100 entries, so the result is bounded. Narrow the `In` array instead. |
| `COUNT` grouped by a range field | Caps the distinct-range walk, so the response carries at most `limit` groups. |
| `COUNT` grouped by an `In` field and a range field | A global cap over the emitted stream, not a per-branch cap. With three `In` values and `limit: 5`, the response carries at most 5 entries in total across all branches. |

`SUM` and `AVG` follow the same policy as `COUNT`: distinct walks apply the default/cap/reject-zero rules, and a zero limit is rejected.

#### Oversized limits with and without proofs

On range-grouped aggregates, an oversized `limit` is handled differently depending on whether a proof is requested. With `prove: true`, a `limit` above the node's configured maximum is rejected with `InvalidLimit` so that proof bytes stay deterministic. With `prove: false`, the limit is silently clamped to that maximum instead. With the default maximum of 100, for example, a caller requesting 500 groups receives at most 100 with no error, which can look like missing data.

Compound carrier-aggregate shapes that pair an `In` field with a range field and request a proof cap the outer range walk at [10 entries](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive/src/query/drive_document_count_query/mod.rs#L129). This is a hard ceiling: a `limit` above it is rejected, and callers needing more results issue repeated queries over disjoint outer-range windows.

### Ranked aggregate queries

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

A ranked query returns the top or bottom groups by their aggregate value - a provable "leaderboard" read - instead of every matching group. A request routes to the ranked executor when it combines an aggregate `select` with exactly one `groupBy` property and exactly one `orderBy` clause naming the selected aggregate:

| `select` | `orderBy` names |
| - | - |
| `COUNT(*)` | The reserved `$count` sentinel. |
| `SUM(<field>)` | `<field>`, the summed property. |
| `AVG(<field>)` | `<field>`, the averaged property. |

The `orderBy` clause must use the field spelling shown above; naming the aggregate function itself is rejected.

`desc` walks the axis from the largest aggregate down (the "top n" reading); `asc` walks from the smallest up (the "bottom n" reading). Groups holding equal aggregate values are returned in group-key order in the direction of the walk.

`limit` is required and must be between 1 and [100](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive/src/query/drive_document_ranked_query/mod.rs#L142). This is a hard ceiling rather than a clamp: a larger limit is rejected with `InvalidLimit`, because the limit is part of the traversal a client re-executes when verifying the proof.

`offset` skips that many ranks before the returned page, so `limit: 1, offset: 4` returns the fifth-ranked group. The skip is counted from subtree aggregates rather than walked, so there is deliberately no ceiling on it. The response reports the skip actually performed, which can be smaller than the requested offset when the groups run out. Cursors (`startAt` / `startAfter`) are rejected in ranked mode, which makes `offset` the only way to page a ranked result.

Where clauses are optional. When present, each pins one leading property of a covering compound ranked index with an equality, except that at most one may be an `in` clause of 2 to 10 distinct elements (a single-element `in` normalizes to an equality pin). A multi-element `in` fans the read out into one branch per element, and combining it with a non-zero `offset` is rejected with `InvalidLimit`, because the counted rank-skip is attested per-branch and cannot span the union.

The covering index must declare the matching ranking axis - `rankedCountable` for `COUNT(*)`, `rankedSummable` for `SUM`, `rankedAverageable` for `AVG`. Each axis is opted into separately and costs its own secondary tree; none implies another. See [Document Indices](../reference/data-contracts.md#document-indices) for the schema keywords.

### Having-range queries

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

A having-range query filters grouped aggregates by their aggregate value, returning the groups whose aggregate falls in a bounded range. A request routes to the having-range executor when it combines an aggregate `select` with exactly one `groupBy` property and exactly one `having` clause whose aggregate is the selected aggregate.

The operator must describe one contiguous range - `==`, `>`, `>=`, `<`, `<=`, `Between`, or a `BetweenExclude*` variant. `!=` and `in` are rejected, because neither describes a contiguous range of the axis. Multi-clause `having` is also rejected.

As with ranked queries, `limit` must be between 1 and [100](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive/src/query/drive_document_having_query/mod.rs#L119), and the same ranking-axis index flags apply.

Having-range queries support neither `offset` nor cursors. To continue past a page cut short by the limit, tighten the `having` bound past the last aggregate value seen. This cannot cross a tie: several groups sharing the boundary aggregate value must fit inside one limit.

An `orderBy` on the selected aggregate is accepted and flips the walk direction.

On protocol version 13 and earlier, and for every other `having` shape at v14, `having` is rejected with `Unsupported`. A shape that routes here but carries a bad limit is rejected with `InvalidLimit`, and one with no `groupBy` with `InvalidParameter`.

### Other aggregate restrictions

- `startAt` and `startAfter` are supported only with `DOCUMENTS`; every aggregate result mode rejects cursors. How to page instead depends on the mode:
  - Grouped `COUNT` / `SUM` / `AVG` - narrow the `where` range to query a different group range.
  - [Ranked](#ranked-aggregate-queries) - use `offset`, which is counted rather than walked and so stays cheap at any depth.
  - [Having-range](#having-range-queries) - neither cursors nor `offset` are available. Tighten the `having` bound past the last aggregate value seen. A page cut inside a tie cannot be continued, so size `limit` above the widest expected tie.
- `COUNT(<field>)`, `MIN`, `MAX`, and multi-projection `SELECT` are present on the wire but currently return `Unsupported`. Callers can encode them in builders ahead of server support landing, but evaluation rejects them today.
- On the v1 wire, `OFFSET` is evaluated only in [ranked aggregate mode](#ranked-aggregate-queries). On the grouped `COUNT` / `SUM` / `AVG` paths, on having-range queries, and when returning `DOCUMENTS`, it still returns `Unsupported`.
- `HAVING` is evaluated only in [having-range mode](#having-range-queries). Every other `HAVING` shape returns `Unsupported`.

## Chained queries

:::{versionadded} 5.0.0
Chained queries have no protocol-version gate of their own, but depend in practice on protocol version 14, which is what admits the `indexOnly` and `refersTo` keywords they require.
:::

A chained query is a provable semi-join: it returns the documents of one type whose IDs appear as a property value on the documents of another type. Conceptually:

```text
SELECT * FROM <outerDocumentType> WHERE $id IN (SELECT <joinProperty> FROM <documentType> WHERE ...)
```

The request's own document type, where clauses, `orderBy`, and `limit` describe the **inner** query. The outer half is derived from the inner results rather than sent, and a proof verifier re-derives it from the proven inner values - so the join cannot be steered by the node that answers it. The chained request names only the join property and the outer document type.

Chained mode has strict prerequisites:

- The inner document type must be [`indexOnly`](../reference/data-contracts.md#document-configuration), and must resolve to an index carrying the join property.
- The join property must declare a same-contract by-ID `refersTo` - `permanentDocument`, `deletableDocument`, or `moderatedDocument` - targeting the outer document type. `findBy` references, `anyOf` / `allOf` alternatives, and arrays of references are not accepted.
- `limit` is required - it bounds the derived outer query, so there is no server-default fallback. A value outside 1 to 100 (the configured `max_query_limit`, 100 by default) is rejected with `InvalidLimit` rather than clamped.
- The outer document type must **not** be `indexOnly`, and `selects` must be empty or a single `DOCUMENTS` projection.
- `groupBy`, `having`, window selections (`inTimeRange` and `inIntegerRange`), `containsAny`, cursors, and `offset` are all rejected. Paginate with a range clause on the join property.

The response carries both halves: the inner documents in query order, and the outer documents ordered by the first appearance of their ID among the inner results, deduplicated.

What happens when a join value has no outer document depends on the join property's `refersTo` kind. Under `permanentDocument` the reference cannot dangle, so a missing document fails the query. Under `deletableDocument` the missing IDs are reported alongside the results. Under `moderatedDocument` each missing ID is reported with the moderators' removal record, and an ID with neither a document nor a removal record fails the query.

A node predating this feature ignores the chained field and serves the plain inner query. That fails closed on the client: an inner-only proof cannot satisfy the re-derived merged query.

## Composite queries

:::{versionadded} 5.0.0
:::

A composite query returns a page of documents plus one or more sub-queries derived from that page, answered as a single merged proof over one state root. This replaces a round-trip-per-lookup pattern - fetch a page, then fetch each referenced profile - with one provable request. Conceptually:

```text
-- Page
SELECT * FROM <documentType> WHERE ... ORDER BY ... LIMIT <n>

-- Sub-query bound to the page: the IN values are read off the proven page documents
SELECT * FROM <subDocumentType> WHERE <field> IN (SELECT <sourceProperty> FROM <page results>)

-- Sub-query bound to an earlier sub-query
SELECT * FROM <subDocumentType2> WHERE <field> IN (SELECT <sourceProperty> FROM <sub-query 1 results>)

-- Sibling sub-query: unbound, proven under the same state root
SELECT * FROM <subDocumentType3> WHERE ... LIMIT <n>
```

For example, a page of `post` documents, a by-ID join fetching each author's `profile` (`$id IN` the posts' `authorId` values), and a `COUNT` sub-query tallying `like` documents per post (`postId IN` the posts' `$id` values) are answered together as one proof.

The request's own contract, document type, where clauses, `orderBy`, and `limit` describe the **page**. Each sub-query carries its own fixed clauses, and its `IN` clause is derived by the node from the proven documents of the page or of an earlier sub-query. As with chained queries, the verifier re-derives every sub-query from the proven page and re-checks the whole composition.

Each sub-query names a document type and optionally a different contract (empty means the page's own), plus a kind:

| Kind | Returns |
| - | - |
| `DOCUMENTS` | The matching documents. |
| `COUNT` | One count per derived value, read from the `countable` index covering the fixed clauses plus the bound field. A value with no entry counts zero. |

A sub-query may declare a binding describing where its derived `IN` values come from:

| Binding field | Meaning |
| - | - |
| `source` | Whose proven documents supply the values: `0` is the page, `n` is the preceding sub-query `n - 1`, which must be a `DOCUMENTS` sub-query. |
| `source_property` | The property read off each source document - `$id`, `$ownerId`, or an identifier-typed property. Dotted paths reach nested properties, and documents lacking the property contribute nothing. |
| `field` | The sub-query field receiving the derived `IN` clause. |

Setting `field` to `$id` makes the sub-query a by-ID join, which requires the source property to declare a by-ID `refersTo` (`permanentDocument`, `deletableDocument`, or `moderatedDocument`) targeting the sub-query's contract and document type. Missing documents are handled as for [chained queries](#chained-queries): under `permanentDocument` every derived ID must resolve and a missing document fails the query, `deletableDocument` reports missing IDs, and `moderatedDocument` reports each missing ID with its removal record. Any other field is a lookup, where absence is itself a proven fact. A sub-query with no binding is a sibling: an independent query proven under the same state root.

Composite mode has the same gates as chained mode: the page's `limit` is required, and a value outside 1 to 100 is rejected with `InvalidLimit` rather than clamped. A page addressed by IDs is proven without its limit, so that limit must be at least as large as the number of IDs it addresses. `groupBy`, `having`, window selections (`inTimeRange` and `inIntegerRange`), cursors, and `offset` are rejected, and chained and composite modes are mutually exclusive. A request may carry at most 10 sub-queries, and neither the page nor a sub-query may use `containsAny`.

Whether a sub-query takes its own `limit` depends on whether its lookup is already bounded by its values. A value-bounded lookup - a unique index, or an `indexOnly` terminal with every prefix fixed - must not carry one, and neither must a by-ID join or a count. Every other lookup, siblings included, requires one.

The response carries the page exactly as the page query alone would return it, followed by one result per sub-query in request order.

## Example query

The following query combines both a where clause and query modifiers.

::::{tab-set}
:::{tab-item} Query object
```javascript
const query = {
  limit: 5,
  startAt: '4Qp3menV9QjE92hc3BzkUCusAmHLxh1AU6gsVsPF4L2q',
  where: [
    ['normalizedParentDomainName', '==', 'dash'],
    ['normalizedLabel', 'startsWith', 'test'],
  ],
  orderBy: [
    ['normalizedLabel', 'asc'],
  ],
}
```
:::

:::{tab-item} Evo SDK example
```javascript
import { EvoSDK } from '@dashevo/evo-sdk';

const sdk = EvoSDK.testnetTrusted();
await sdk.connect();

const results = await sdk.documents.query({
  dataContractId: 'GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec',
  documentTypeName: 'domain',
  limit: 5,
  startAt: '4etYFuWbXRXB74gTDp53eLUqjLEAtNSfUX2XtrQ1uMdT',
  where: [
    ['normalizedParentDomainName', '==', 'dash'],
    ['normalizedLabel', 'startsWith', 'test'],
  ],
  orderBy: [
    ['normalizedLabel', 'asc'],
  ],
});

for (const [id, doc] of results) {
  console.log(id.toString(), doc?.toJSON());
}
```
:::

:::{tab-item} Evo SDK aggregate example
The Evo SDK does not expose `select` directly. Each aggregate mode has its own method — `documents.count()`, `documents.sum(query, property)`, and `documents.average(query, property)`. `groupBy` is passed as part of the query.

```javascript
import { EvoSDK } from '@dashevo/evo-sdk';

const sdk = EvoSDK.testnetTrusted();
await sdk.connect();

// COUNT grouped by a range field: one entry per distinct rating.
// The `rating` range clause is what puts the query in grouped mode.
const counts = await sdk.documents.count({
  dataContractId: 'BdgTqaTAPYMyhp1WdeWdcvYSgoD7AuJ7tVCaCSXyQgyP',
  documentTypeName: 'review',
  where: [
    ['resourceId', '==', 'dashnote'],
    ['rating', 'between', [1, 5]],
  ],
  orderBy: [
    ['rating', 'asc'],
  ],
  groupBy: ['rating'],
});

// Keys are hex-encoded index keys, not the raw field values, and
// counts are BigInt. A small positive integer encodes as `0x80 | value`,
// so rating 5 is the key "85".
for (const [key, count] of counts) {
  console.log(`${key - 80} stars: ${count.toString()} review(s)`);
}
```

The query's index must support the aggregate: this example needs a `[resourceId, rating]` index carrying the index-level `countable` and `rangeCountable` flags. An ungrouped `count()` returns a single-entry map keyed by the empty string, so read it with `counts.values().next().value`.
:::
::::
