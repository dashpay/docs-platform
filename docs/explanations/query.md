```{eval-rst}
.. _explanations-query:
```

# Query Capabilities

Dash Platform allows applications to retrieve data in a structured and deterministic manner. Clients
query the latest committed state of identities, data contracts, documents, and other Platform data
similar to traditional databases while retaining decentralized trust benefits.

## Querying the State

Queries operate on the finalized data stored within Platform’s state tree. Responses reflect the
most recently committed block and do not include pending or historical intermediate changes.

This means:

- Query results are consistent across nodes
- Clients do not need to process blockchain history
- Data retrieval is deterministic and efficient

:::{note}
Queries return the *current finalized state*, not the sequence of events that created it.
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

Benefits of indexed querying include:

- Predictable performance
- Consistent execution across nodes

:::{important}
Indexes should be planned during contract design since there are [limited index update
options](./platform-protocol-data-contract.md#contract-updates) for already registered contracts.
:::
