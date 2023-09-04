# Platform State

Platform state represents the current state of all the data stored on the platform. You can think about this as one large database, where each application has its own database (Application State) defined by the Data Contract associated with the application. Therefore, the platform state can be thought of as a global view of all Dash Platform data, whereas the application state is a local view of one application's data.

The Platform Chain is processed by a state machine to reach consensus on how to build the state and what it should look like. The last block of the Platform Chain contains the root of the tree structure built from all documents in the platform state. By checking the root of the state tree stored in the block, the node can confirm that it has the correct state.

```{eval-rst}
.. figure:: ../../img/platform-state.svg
   :class: no-scaled-link
   :align: center
   :width: 80%
   :alt: Platform State Propagation

   Platform State Propagation
```
