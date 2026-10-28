```{eval-rst}
.. _explanations-query:
```

# Query Capabilities

Dash Platform allows applications to retrieve data in a structured and deterministic manner. Clients
query the latest committed state of identities, data contracts, documents, and other Platform data
similar to traditional databases while retaining decentralized trust benefits.

## Querying the State

Queries operate on the finalized data stored within Platform’s state tree. Responses reflect the
most recently committed block and do not include pending changes.

This means:

- Query results are consistent across nodes
- Clients do not need to process blockchain history
- Data retrieval is deterministic and efficient

:::{note}
By default, queries return the *current finalized state* rather than the sequence of events that created it. Data contracts and document types configured to retain history are the exception: dedicated history queries return their successive revisions, and those responses support proofs like any other query.
:::

## Deterministic Results

All queries produce deterministic results. The same query executed on two honest and up-to-date
Platform nodes will always produce the same result. This ensures consistent application behavior
regardless of which node provides the response.

## Data Proofs

Queries can return locally verifiable cryptographic proofs, allowing clients to verify response
accuracy without trusting the responding node.

Two types of proofs exist:

| Proof Type | Purpose |
|------------|---------|
| Inclusion Proof | Confirms that specific data exists and has not been modified |
| Non-Inclusion Proof | Confirms that specific data does *not* exist (useful for uniqueness checks such as usernames) |

Proofs are especially valuable for:

- Light clients
- Browser-based and serverless environments
- Trust-minimized applications

## Indexed Queries

Dash Platform requires queries to use indexes defined in the data contract for the relevant document
type. If a field is not indexed, it cannot be used for filtering or sorting.

System fields are recognized by the query engine without being declared as normal schema properties. `$id` is implicitly queryable as the primary key. Other system fields like `$ownerId`, `$createdAt`, `$updatedAt`, and `$transferredAt` are built-in field names, but document queries still need to match an appropriate contract index. Querying and sorting on indexed fields also follows compound-index prefix and range/`orderBy` rules - see the [query syntax reference](../reference/query-syntax.md) for details.

A query is served only when its filters line up with a leading, gap-free run of an index's properties. A query that skips a property in the middle of an index is rejected. Set-membership filters can also be applied to more than one adjacent index property in a single query.

An index can also cover the elements of a typed array, which is a list property such as a post's tags. A query can then select the documents whose array holds a given element, or any of several elements. See [Typed array elements](../reference/query-syntax.md#typed-array-elements). Unsigned integer index values are ordered by numeric value, so range filters and ordering on unsigned integer properties return results in value order. The exception is an unsigned property that ends a `rangeSummable` index. In every index of its document type, that property keeps a legacy ordering in which the values in the upper half of its integer type's range (128 and above, for a one-byte integer) sort before the lower values.

Some document types can be declared index-only in the data contract. Their documents are never stored as a body, so queries return documents reconstructed from the index entries themselves. This suits cheap relation-style rows such as likes or follows, and these types are what the chained queries described below are built on. See [indexOnly document types](../reference/data-contracts.md#indexonly-document-types) in the data contract reference.

Benefits of indexed querying include:

- Predictable performance
- Consistent execution across nodes

## Aggregate Queries

Beyond returning whole documents, Dash Platform can compute a value over the set of documents a query
matches - how many there are, their total, or their average - and return that instead of the documents
themselves. Results can optionally be grouped, so a single query returns one value per group.

Aggregates are not available on every document type. The contract must opt in for the document type
being queried, which means this is another decision to make during contract design. See the
[query syntax reference](../reference/query-syntax.md#aggregate-queries) for the supported aggregates
and how to request them.

## Ranked, Windowed, and Composed Queries

Platform can answer several further kinds of question in a single verifiable round trip:

- **Which groups rank highest?** [Ranked queries](../reference/query-syntax.md#ranked-aggregate-queries)
  return the top (or bottom) groups by a count, sum, or average, such as a leaderboard.
- **Which groups fall in a value band?** [Having-range queries](../reference/query-syntax.md#having-range-queries)
  return only the groups whose aggregate falls within a given range.
- **What happened in this time window?** [Time-range selection](../reference/query-syntax.md#time-range-selection)
  reads documents bucketed into fixed time windows, for trending-style views.
- **Which documents does this page refer to?** [Chained queries](../reference/query-syntax.md#chained-queries)
  use the results of one query to select the documents returned by a second, and
  [composite queries](../reference/query-syntax.md#composite-queries) return a page of documents together
  with related documents or counts derived from that page.

## Invalid Queries

A query that the request itself makes invalid, such as one with a limit of zero or a where clause that breaks the query rules, is answered with the gRPC `INVALID_ARGUMENT` status. The same status is returned for a query that relies on a feature not yet active at the network's current protocol version. Every node at that height would give the same answer, so clients should treat these errors as final rather than retrying the query on another node.

## Contract Design Considerations

An application's expected queries shape its data contract. Fields used for filtering and sorting need
suitable indexes, while capabilities such as aggregation, ranking, time-range selection, and composed
queries require additional contract declarations. These choices should be made before registering the
contract because [updates are limited](./platform-protocol-data-contract.md#updates). See the
[data contract reference](../reference/data-contracts.md#document-indices) and
[query syntax reference](../reference/query-syntax.md) for the exact configuration and query rules.
