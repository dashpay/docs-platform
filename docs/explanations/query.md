# Query Capabilities

Dash Platform allows applications to retrieve blockchain state in a structured and deterministic
way. Instead of replaying historical transactions, clients query the latest committed state of
identities, data contracts, documents, etc. This enables predictable data access similar to
traditional databases while retaining decentralized trust guarantees.

## Querying the State

All queries operate on the finalized state stored within Platform’s state tree. Responses reflect
the most recently committed block and do not include pending or historical intermediate changes.

This means:

- Query results are consistent across nodes
- Clients do not need to process blockchain history
- Data retrieval is deterministic and efficient

:::{note}
Queries return the *current finalized state*, not the sequence of events that created it.
:::

## Indexed Queries

Dash Platform requires that queries use indexes defined in the data contract for the relevant
document type. If a field is not indexed, it cannot be used in filtering or sorting expressions.

Benefits of indexed querying include:

- Predictable performance
- No full-table scanning
- Consistent execution across nodes

:::{important}
Indexes should be planned during contract design since there are [limited index update
options](./platform-protocol-data-contract.md#contract-updates) for already registered contracts.
:::

