# Overview

At any given point in time, the data stored by each application (and more broadly, the entire platform) is in a specific state. State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state.

For example, Alice may have already added Bob and Carol as friends in [DashPay](explanation-dashpay) while also having a pending friend request to Dan. If Dan declines the friend request, the state will transition to a new one where Alice and Bob remain in Alice’s friend list while Dan moves to the declined list.
[block:image]
{
  "images": [
    {
      "image": [
        "https://files.readme.io/48c666f-State_Transition.svg",
        "State Transition.svg",
        610,
        262,
        "#e9f0fd"
      ],
      "caption": "State Transition Example"
    }
  ]
}
[/block]

# Implementation Overview

To ensure the consistency and integrity of data stored on Layer 2, all data is governed by the [Dash Platform Protocol](explanation-platform-protocol) (DPP) which describes serialization and validation rules. Since state transitions are the vehicle for delivering data to the platform, the implementation of state transitions resides in DPP alongside the validation logic. 

## Structure

To support the various data types used on the platform and enable future updates, state transitions were designed to be flexible. Each state transition consists of a:

1. Header - version and payload type
2. Payload - contents vary depending on payload type
3. Signature - signature of the header/payload by the identity submitting to state transition

The following table contains a list of currently defined payload types:

| Payload Type | Payload Description |
| - | - |
| [Data Contract Create](platform-protocol-reference-data-contract#data-contract-creation) (`0`) | [Database schema](explanation-platform-protocol-data-contract) for a single application |
| [Documents Batch](platform-protocol-reference-document#document-submission) (`1`) | An array of 1 or more [document](explanation-platform-protocol-document) transition objects containing application data |
| [Identity Create](platform-protocol-reference-identity#identity-creation) (`2`) | Information including the public keys required to create a new [Identity](explanation-identity) |
| [Identity Topup](platform-protocol-reference-identity#identity-topup) (`3`) | Information including proof of a transaction containing an amount to add to the provided identity's balance |
| [Data Contract Update](platform-protocol-reference-data-contract#data-contract-update) (`4`) | An updated [database schema](explanation-platform-protocol-data-contract) to modify an existing application |

## Application Usage

State transitions are constructed by client-side libraries and then submitted to the platform via [DAPI](explanation-dapi). Based on the validation rules described in [DPP](explanation-platform-protocol) (and an application [data contract](explanation-platform-protocol-data-contract) where relevant), Dash Platform first validates the state transition. 

Some state transitions (e.g. data contracts, identity) are validated solely by rules explicitly defined in DPP, while others (e.g. documents) are also subject to the rules defined by the relevant application’s data contract. Once the state transition has been validated, the platform stores the data and updates the platform state.

> 📘
>
> For more detailed information, see the [Platform Protocol Reference - State Transition](platform-protocol-reference-state-transition) page