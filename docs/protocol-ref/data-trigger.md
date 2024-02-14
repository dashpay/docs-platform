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

As an example, DPP contains several data triggers for DPNS as defined in the [data triggers factory](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_trigger/get_data_triggers_factory.rs). The `domain` document has added constraints for creation. All DPNS document types have constraints on replacing or deleting:

| Data Contract | Document           | Action(s)                                                                                                                            | Trigger Description                                                                                      |
| ------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| DPNS          | `domain`           | [`CREATE`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/lib/dataTrigger/dpnsTriggers/createDomainDataTrigger.js) | Enforces DNS compatibility, validates provided hashes, and restricts top-level domain (TLD) registration |
| ----          | ----               | ----                                                                                                                                 | ----                                                                                                     |
| DPNS          | All Document Types | [`REPLACE`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_trigger/reject_data_trigger.rs)                | Prevents updates to existing documents                                                                   |
| DPNS          | All Document Types | [`DELETE`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_trigger/reject_data_trigger.rs)                 | Prevents deletion of existing documents                                                                  |

**DPNS Trigger Constraints**

The following table details the DPNS constraints applied via data triggers. These constraints are in addition to the ones applied directly by the DPNS data contract.

| Document   | Action    | Constraint                                                                                                  |
| ---------- | --------- | ----------------------------------------------------------------------------------------------------------- |
| `domain`   | `CREATE`  | Full domain length \<= 253 characters                                                                       |
| `domain`   | `CREATE`  | `normalizedLabel` matches lowercase `label`                                                                 |
| `domain`   | `CREATE`  | `ownerId` matches `records.dashUniqueIdentityId` or `dashAliasIdentityId` (whichever one is present)        |
| `domain`   | `CREATE`  | Only creating a top-level domain with an authorized identity                                                |
| `domain`   | `CREATE`  | Referenced `normalizedParentDomainName` must be an existing parent domain                                   |
| `domain`   | `CREATE`  | Subdomain registration for non top level domains prevented if `subdomainRules.allowSubdomains` is true      |
| `domain`   | `CREATE`  | Subdomain registration only allowed by the parent domain owner if `subdomainRules.allowSubdomains` is false |
| `domain`   | `CREATE`  | Referenced `preorder` document must exist                                                                   |
| `domain`   | `REPLACE` | Action not allowed                                                                                          |
| `domain`   | `DELETE`  | Action not allowed                                                                                          |
| `preorder` | `REPLACE` | Action not allowed                                                                                          |
| `preorder` | `DELETE`  | Action not allowed                                                                                          |
