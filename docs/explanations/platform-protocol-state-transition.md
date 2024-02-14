```{eval-rst}
.. _explanations-state-transition:
```

# State Transition

## Overview

At any given point in time, the data stored by each application (and more broadly, the entire platform) is in a specific state. State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state.

For example, Alice may have already added Bob and Carol as friends in [DashPay](../explanations/dashpay.md) while also having a pending friend request to Dan. If Dan declines the friend request, the state will transition to a new one where Alice and Bob remain in Alice’s friend list while Dan moves to the declined list.

```{eval-rst}
.. figure:: ../../img/state-transition.svg
   :class: no-scaled-link
   :align: center
   :width: 90%
   :alt: State transition example

   State Transition Example
```

## Implementation Overview

To ensure the consistency and integrity of data stored on Layer 2, all data is governed by the [Dash Platform Protocol](../explanations/platform-protocol.md) (DPP) which describes serialization and validation rules. Since state transitions are the vehicle for delivering data to the platform, the implementation of state transitions resides in DPP alongside the validation logic.

### Structure

To support the various data types used on the platform and enable future updates, state transitions were designed to be flexible. Each state transition consists of a:

1. Header - version and payload type
2. Payload - contents vary depending on payload type
3. Signature - signature of the header/payload by the identity submitting to state transition

The following table contains a list of currently defined payload types:

| Payload Type | Payload Description |
| - | - |
| [Data Contract Create](../protocol-ref/data-contract.md#data-contract-creation) (`0`) | [Database schema](../explanations/platform-protocol-data-contract.md) for a single application |
| [Documents Batch](../protocol-ref/document.md#document-submission) (`1`) | An array of 1 or more [document](../explanations/platform-protocol-document.md) transition objects containing application data |
| [Identity Create](../protocol-ref/identity.md#identity-creation) (`2`) | Information including the public keys required to create a new [Identity](../explanations/identity.md) |
| [Identity Topup](../protocol-ref/identity.md#identity-topup) (`3`) | Information including proof of a transaction containing an amount to add to the provided identity's balance |
| [Data Contract Update](../protocol-ref/data-contract.md#data-contract-update) (`4`) | An updated [database schema](../explanations/platform-protocol-data-contract.md) to modify an existing application |
| [Identity Update](../protocol-ref/identity.md#identity-update) (`5`) | A set of one or more new public keys to add to the [identity](../explanations/identity.md) or a list of existing keys to disable |
| [Identity Credit Withdrawal](../protocol-ref/identity.md) (`6`) | Information required to withdraw credits from Dash Platform |
| [Identity Credit Transfer](../protocol-ref/identity.md) (`7`) | Information required to transfer credits |

### Application Usage

State transitions are constructed by client-side libraries and then submitted to the platform via [DAPI](../explanations/dapi.md). Based on the validation rules described in [DPP](../explanations/platform-protocol.md) (and an application [data contract](../explanations/platform-protocol-data-contract.md) where relevant), Dash Platform first validates the state transition.

Some state transitions (e.g. data contracts, identity) are validated solely by rules explicitly defined in DPP, while others (e.g. documents) are also subject to the rules defined by the relevant application’s data contract. Once the state transition has been validated, the platform stores the data and updates the platform state.

> 📘
>
> For more detailed information, see the [Platform Protocol Reference - State Transition](../protocol-ref/state-transition.md) page.
