```{eval-rst}
.. _explanations-platform-state:
```

# Platform State

Platform state represents the current state of all the data stored on the platform. You can think about this as one large database, where each application has its own database (Application State) defined by the Data Contract associated with the application. Therefore, the platform state can be thought of as a global view of all Dash Platform data, whereas the application state is a local view of one application's data.

The Platform Chain is processed by a state machine to reach consensus on how to build the state and what it should look like. Each committed block's header contains an AppHash that commits to the root of the state tree after the block's execution. By checking the AppHash stored in the block, a node can confirm that it has the correct state.

```{eval-rst}
.. figure:: ../../img/platform-state.svg
   :class: no-scaled-link
   :align: center
   :width: 80%
   :alt: Platform State Propagation

   Platform State Propagation
```

## GroveDB and AppHash

Platform state is stored in [GroveDB](https://github.com/dashpay/grovedb), a hierarchical authenticated data structure maintained by Drive. Because GroveDB is authenticated, each operation that mutates state also updates an aggregate root hash that commits to the entire state tree.

Under the [Tenderdash](../explanations/platform-consensus.md) same-block execution model, state transitions in a proposed block are validated and applied during block processing. The resulting state-tree root is then embedded in the committed block's header as the `AppHash`, meaning the committed block itself commits to the post-execution state.

## Proofs

Because state is stored in GroveDB, [DAPI](../explanations/dapi.md) queries can return GroveDB proofs alongside the requested data. Clients verify these proofs against the block header's `AppHash` (which itself is signed by the validator quorum), allowing light clients to trustlessly confirm the returned data without re-executing the chain.
