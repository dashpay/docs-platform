```{eval-rst}
.. _explanations-data-trigger:
```

# Data Trigger

This page is intended to provide a brief description of how data triggers work in Dash Platform.

## Overview

Although [data contracts](../explanations/platform-protocol-data-contract.md) provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, [DPNS](../explanations/dpns.md) must enforce some rules to ensure names remain DNS compatible. Dash Platform supports this application-specific custom logic using Data Triggers, which are executed by the node's execution layer ([Drive](../explanations/drive.md)) as part of state transition validation.

:::{attention}
Given a number of technical considerations (security, masternode processing capacity, etc.), data triggers are not considered a platform feature at this time. They are currently hard-coded in the Drive execution layer, versioned with the protocol, and only used in system data contracts.
:::

## Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the document `action`, so a separate trigger can be created for any [document transition action](../explanations/platform-protocol-document.md#document-submission): `create`, `replace`, `delete`, `transfer`, `purchase`, `updatePrice`, and (from protocol version 14) `indexOnlyDelete`.

Which trigger runs for a given contract, document type, and action is defined in the data trigger [binding list](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/bindings/list/v2/mod.rs). The binding list is versioned with the protocol, so the set of active triggers can change when a new protocol version activates. The trigger implementations linked in the tables below (for example the shared `reject` trigger) are generic and do not name the contracts that use them - the binding list is what associates each action with its trigger.

As an example, Drive contains several [data triggers for DPNS](https://github.com/dashpay/platform/tree/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dpns). The `domain` document has added constraints for creation, replacing, and deleting:

| Data Contract | Document | Action(s) | Trigger Description |
| - | - | - | - |
| DPNS | `domain` | [`CREATE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dpns/v0/mod.rs) | Enforces DNS compatibility, validate provided hashes, and restrict top-level domain (TLD) registration |
| ---- | ----| ---- | ---- |
| DPNS | `domain` | [`REPLACE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs) | Prevents updates to DPNS `domain` documents |
| DPNS | `domain` | [`DELETE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs) | Prevents deletion of DPNS `domain` documents |

:::{note}
The `REPLACE` and `DELETE` rows for DPNS both link to the same shared `reject` trigger, which DPNS reuses to disallow those actions on `domain` documents. The DPNS `preorder` document type has no data triggers at all - its immutability comes from the contract schema rather than from trigger logic.

The absence of a trigger matters too: DPNS `domain` documents deliberately have no trigger bound to the `transfer`, `purchase`, or `updatePrice` actions, so those actions fall through to generic document validation. That is what makes [username transfers and sales](../explanations/dpns.md#name-transfers-and-sales) possible, while `REPLACE` and `DELETE` remain rejected so name records stay immutable and permanent.
:::

In addition to DPNS, Drive ships data triggers for a small set of other system contracts:

| Data Contract | Document | Action(s) | Trigger Description |
| - | - | - | - |
| DashPay | `contactRequest` | [`CREATE`](https://github.com/dashpay/platform/tree/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dashpay) | Enforces DashPay-specific rules on outgoing contact requests |
| DashPay | `profile` | [`CREATE`/`REPLACE`](https://github.com/dashpay/platform/tree/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dashpay) | Validates that the optional core and Platform payment address fields carry a supported address type byte (P2PKH or P2SH), a rule the schema alone cannot express (protocol version 14+) |
| ---- | ---- | ---- | ---- |
| Masternode Rewards | `rewardShare` | [`CREATE`/`REPLACE`/`DELETE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs) | Rejects all three actions so ordinary identities cannot write reward share records |
| ---- | ---- | ---- | ---- |
| Withdrawals | `withdrawal` | [`REPLACE`](https://github.com/dashpay/platform/blob/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs) | Prevents direct external mutation of withdrawal documents |
| Withdrawals | `withdrawal` | [`DELETE`](https://github.com/dashpay/platform/tree/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/withdrawals) | Allows deletion in `COMPLETE` status, and from protocol version 14 also in terminal `FAILED` status |

When document state transitions are received, Drive checks if there is a trigger associated with the document type and action. If a trigger is found, Drive executes the trigger logic. Successful execution of the trigger logic is necessary for the document to be accepted and applied to the [platform state](../explanations/drive-platform-state.md).
