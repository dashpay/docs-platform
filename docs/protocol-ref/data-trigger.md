```{eval-rst}
.. _protocol-ref-data-trigger:
```

# Data Trigger

## Data Trigger Overview

Although [data contracts](../protocol-ref/data-contract.md) provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, [DPNS](../explanations/dpns.md) must enforce some rules to ensure names remain DNS compatible. Dash Platform Protocol (DPP) supports this application-specific custom logic using Data Triggers.

## Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the [document transition action](../protocol-ref/document.md#document-transition-action) so separate triggers can be created for any document transition action (for example, CREATE, REPLACE, DELETE, TRANSFER, PURCHASE, or UPDATE_PRICE).

When document state transitions are received, DPP checks if there is a trigger associated with the document transition type and action. If there is, it then executes the trigger logic.

**Note:** Successful execution of the trigger logic is necessary for the document to be accepted and applied to the platform state.

### Example

As an example, DPP contains several data triggers for DPNS as defined in the [data trigger bindings](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/bindings/list/v2/mod.rs). The `domain` document has added constraints for creation, replacement or deletion:

| Data Contract | Document           | Action(s)                                                                                                                            | Trigger Description                                                                                      |
| ------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| DPNS          | `domain`           | [`CREATE`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dpns/v1/mod.rs#L48) | Enforces DNS compatibility, validates provided hashes, and restricts top-level domain (TLD) registration |
| ----          | ----               | ----                                                                                                                                 | ----                                                                                                     |
| DPNS          | `domain`           | [`REPLACE`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25)                | Prevents updates to existing documents                                                                   |
| DPNS          | `domain`           | [`DELETE`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25)                 | Prevents deletion of existing documents                                                                  |
| DPNS          | `domain`           | [`TRANSFER`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25) | Prevents transfer of existing documents (protocol version 12 and earlier only) |
| DPNS          | `domain`           | [`PURCHASE`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25) | Prevents purchase of existing documents (protocol version 12 and earlier only) |
| DPNS          | `domain`           | [`UPDATE_PRICE`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/reject/v0/mod.rs#L25) | Prevents updating price of existing documents (protocol version 12 and earlier only) |

Starting in protocol version 13, the `TRANSFER`, `PURCHASE` and `UPDATE_PRICE` actions have no DPNS trigger binding. They are validated by the generic document validation paths, which permit them because the DPNS data contract declares `transferable: 1` and `tradeMode: 1`. `REPLACE` and `DELETE` remain rejected.

**DPNS Trigger Constraints**

The following table details the DPNS constraints applied via data triggers. These constraints are in addition to the ones applied directly by the DPNS data contract.

| Document   | Action    | Constraint |
| ---------- | --------- | ---------- |
| `domain`   | `CREATE`  | Full domain length \<= 253 characters                                                                       |
| `domain`   | `CREATE`  | `normalizedLabel` matches homograph-safe conversion of `label` (lowercase with character substitutions: o→0, l/i→1) |
| `domain`   | `CREATE`  | `normalizedParentDomainName` matches homograph-safe conversion of `parentDomainName` |
| `domain`   | `CREATE`  | `ownerId` validation against `records` identity fields is a no-op (see note below) |
| `domain`   | `CREATE`  | Only creating a top-level domain with an authorized identity                                                |
| `domain`   | `CREATE`  | Referenced `normalizedParentDomainName` must be an existing parent domain                                   |
| `domain`   | `CREATE`  | Subdomain registration for non-top-level domains prevented if the new domain's `subdomainRules.allowSubdomains` is true |
| `domain`   | `CREATE`  | Subdomain registration only allowed by the parent domain owner if the parent domain's `subdomainRules.allowSubdomains` is false |
| `domain`   | `CREATE`  | Referenced `preorder` document must exist                                                                   |
| `domain`   | `REPLACE` | Action not allowed                                                                                          |
| `domain`   | `DELETE`       | Action not allowed                                                                                          |
| `domain`   | `TRANSFER`     | Action not allowed (protocol version 12 and earlier only)                                                   |
| `domain`   | `PURCHASE`     | Action not allowed (protocol version 12 and earlier only)                                                   |
| `domain`   | `UPDATE_PRICE` | Action not allowed (protocol version 12 and earlier only)                                                   |

:::{note}
The trigger for `domain` `CREATE` attempts to validate that `ownerId` matches
`records.dashUniqueIdentityId` or `records.dashAliasIdentityId`. However, the
DPNS v1 schema defines only `records.identity` and sets `additionalProperties:
false`, so neither field can exist in a valid document. Both checks are
therefore permanent no-ops and `records.identity` is not validated against
`ownerId` at the trigger level.
:::

:::{note}
Starting in protocol version 13, when a DPNS `domain` document is transferred or purchased platform rewrites the document's `records.identity` to the new owner's identity ID as part of applying the transition. Name resolution and `records.identity` queries therefore follow the ownership change. This rewrite is applied outside the data trigger system and is scoped to the DPNS `domain` document type.
:::

### Other System Contract Triggers

In addition to DPNS, the following system contracts have registered data triggers:

**Dashpay**

| Document         | Action   | Trigger Description                              |
| ---------------- | -------- | ------------------------------------------------ |
| `contactRequest` | `CREATE` | Validates contact request fields and permissions |
| `profile` | `CREATE` | Rejects `corePaymentAddress` or `platformPaymentAddress` values whose first byte is not `0x00` (P2PKH) or `0x01` (P2SH) (protocol version 14+) |
| `profile` | `REPLACE` | Same payment address type byte check as `CREATE` (protocol version 14+) |

**Masternode Rewards**

| Document      | Action    | Trigger Description                                         |
| ------------- | --------- | ----------------------------------------------------------- |
| `rewardShare` | `CREATE`  | Rejected unconditionally (masternodes manage reward shares via internal platform operations) |
| `rewardShare` | `REPLACE` | Rejected unconditionally (masternodes manage reward shares via internal platform operations) |
| `rewardShare` | `DELETE`  | Rejected unconditionally (masternodes manage reward shares via internal platform operations) |

**Withdrawals**

| Document     | Action    | Trigger Description |
| ------------ | --------- | ------------------- |
| `withdrawal` | `REPLACE` | Rejected by data trigger (withdrawal documents cannot be updated) |
| `withdrawal` | `DELETE`  | Rejected unless status is `COMPLETE` or, from protocol version 14, `FAILED` (an expired withdrawal whose amount is below Core's dust threshold) |
