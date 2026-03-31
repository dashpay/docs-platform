```{eval-rst}
.. _protocol-ref-data-trigger:
```

# Data Trigger

## Data Trigger Overview

Although [data contracts](../protocol-ref/data-contract.md) provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, [DPNS](../explanations/dpns.md) must enforce some rules to ensure names remain DNS compatible. Dash Platform Protocol (DPP) supports this application-specific custom logic using Data Triggers.

## Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the [document transition action](../protocol-ref/document.md#document-transition-action) so separate triggers can be created for the CREATE, REPLACE, or DELETE actions.

When document state transitions are received, DPP checks if there is a trigger associated with the document transition type and action. If there is, it then executes the trigger logic.

**Note:** Successful execution of the trigger logic is necessary for the document to be accepted and applied to the platform state.

### Example

As an example, DPP contains several data triggers for DPNS as defined in the [data triggers factory](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/executor.rs). The `domain` document has added constraints for creation. All DPNS document types have constraints on replacing or deleting:

| Data Contract | Document           | Action(s)                                                                                                                            | Trigger Description                                                                                      |
| ------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| DPNS          | `domain`           | [`CREATE`](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dpns/v0/mod.rs#L48) | Enforces DNS compatibility, validates provided hashes, and restricts top-level domain (TLD) registration |
| ----          | ----               | ----                                                                                                                                 | ----                                                                                                     |
| DPNS          | `domain`           | [`REPLACE`](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25)                | Prevents updates to existing documents                                                                   |
| DPNS          | `domain`           | [`DELETE`](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25)                 | Prevents deletion of existing documents                                                                  |
| DPNS          | `domain`           | [`TRANSFER`](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25) | Prevents transfer of existing documents |
| DPNS          | `domain`           | [`PURCHASE`](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25) | Prevents purchase of existing documents |
| DPNS          | `domain`           | [`UPDATE_PRICE`](https://github.com/dashpay/platform/blob/v3.1-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25) | Prevents updating price of existing documents |

**DPNS Trigger Constraints**

The following table details the DPNS constraints applied via data triggers. These constraints are in addition to the ones applied directly by the DPNS data contract.

| Document   | Action    | Constraint                                                                                                  |
| ---------- | --------- | ----------------------------------------------------------------------------------------------------------- |
| `domain`   | `CREATE`  | Full domain length \<= 253 characters                                                                       |
| `domain`   | `CREATE`  | `normalizedLabel` matches homograph-safe conversion of `label` (lowercase with character substitutions: o→0, l/i→1) |
| `domain`   | `CREATE`  | `normalizedParentDomainName` matches homograph-safe conversion of `parentDomainName` |
| `domain`   | `CREATE`  | `ownerId` matches `records.dashUniqueIdentityId` or `dashAliasIdentityId` (whichever one is present)        |
| `domain`   | `CREATE`  | Only creating a top-level domain with an authorized identity                                                |
| `domain`   | `CREATE`  | Referenced `normalizedParentDomainName` must be an existing parent domain                                   |
| `domain`   | `CREATE`  | Subdomain registration for non top level domains prevented if `subdomainRules.allowSubdomains` is true      |
| `domain`   | `CREATE`  | Subdomain registration only allowed by the parent domain owner if `subdomainRules.allowSubdomains` is false |
| `domain`   | `CREATE`  | Referenced `preorder` document must exist                                                                   |
| `domain`   | `REPLACE` | Action not allowed                                                                                          |
| `domain`   | `DELETE`       | Action not allowed                                                                                          |
| `domain`   | `TRANSFER`     | Action not allowed                                                                                          |
| `domain`   | `PURCHASE`     | Action not allowed                                                                                          |
| `domain`   | `UPDATE_PRICE` | Action not allowed                                                                                          |

### Other System Contract Triggers

In addition to DPNS, the following system contracts have registered data triggers:

**Dashpay**

| Document         | Action   | Trigger Description                              |
| ---------------- | -------- | ------------------------------------------------ |
| `contactRequest` | `CREATE` | Validates contact request fields and permissions |

**Masternode Rewards**

| Document      | Action    | Trigger Description                                         |
| ------------- | --------- | ----------------------------------------------------------- |
| `rewardShare` | `CREATE`  | Rejected by data trigger (only masternodes can create)      |
| `rewardShare` | `REPLACE` | Rejected by data trigger (only masternodes can update)      |
| `rewardShare` | `DELETE`  | Rejected by data trigger (only masternodes can delete)      |

**Withdrawals**

| Document     | Action    | Trigger Description |
| ------------ | --------- | ------------------- |
| `withdrawal` | `REPLACE` | Rejected by data trigger (withdrawal documents cannot be updated) |
| `withdrawal` | `DELETE`  | Rejected unless status is `COMPLETE` |
