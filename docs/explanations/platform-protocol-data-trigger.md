```{eval-rst}
.. _explanations-data-trigger:
```

# Data Trigger

This page is intended to provide a brief description of how data triggers work in the initial version of Dash Platform. The design will likely undergo changes in the future.

## Overview

Although [data contracts](../explanations/platform-protocol-data-contract.md) provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, [DPNS](../explanations/dpns.md) must enforce some rules to ensure names remain DNS compatible. [Dash Platform Protocol](../explanations/platform-protocol.md) (DPP) supports this application-specific custom logic using Data Triggers.

:::{attention}
Given a number of technical considerations (security, masternode processing capacity, etc.), data triggers are not considered a platform feature at this time. They are currently hard-coded in Dash Platform Protocol and only used in system data contracts.
:::

## Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the document `action` so separate triggers can be created for the `CREATE`, `REPLACE`, or `DELETE` actions.

As an example, DPP contains several [data triggers for DPNS](https://github.com/dashpay/platform/tree/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/documents_batch/data_triggers/triggers/dpns). The `domain` document has added constraints for creation. All DPNS document types have constraints on replacing or deleting:

| Data Contract | Document | Action(s) | Trigger Description |
| - | - | - | - |
| DPNS | `domain` | [`CREATE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/documents_batch/data_triggers/triggers/dpns/v0/mod.rs) | Enforces DNS compatibility, validate provided hashes, and restrict top-level domain (TLD) registration |
| ---- | ----| ---- | ---- |
| DPNS | All Document Types | [`REPLACE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/documents_batch/data_triggers/triggers/reject/v0/mod.rs) | Prevents updates to any DPNS document type |
| DPNS | All Document Types | [`DELETE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/documents_batch/data_triggers/triggers/reject/v0/mod.rs) | Prevents deletion of any DPNS document type |

When document state transitions are received, DPP checks if there is a trigger associated with the document type and action. If a trigger is found, DPP executes the trigger logic. Successful execution of the trigger logic is necessary for the document to be accepted and applied to the [platform state](../explanations/drive-platform-state.md).
