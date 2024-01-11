# Identity

## Overview

Identities are foundational to Dash Platform. They provide a familiar, easy-to-use way for users to interact and identify one another using names rather than complicated cryptocurrency identifiers such as public key hashes.

Identities are separate from names and can be thought of as a lower-level primitive that provides the foundation for various user-facing functionality. An identity consists primarily of one or more public keys recorded on the platform chain that can be used to control a user's profile and sign their documents. Each identity also has a balance of [credits](#credits) that is established by locking funds on layer 1. These credits are used to pay fees associated with the [state transitions](../explanations/platform-protocol-state-transition.md) used to perform actions on the platform.

> 👍 Identities DIP
>
> The [Identities Dash Improvement Proposal (DIP)](https://github.com/dashpay/dips/blob/master/dip-0011.md) provides more extensive background information and details.

## Identity Management

In order to [create an identity](#identity-create-process), a user pays the network to store their public key(s) on the platform chain. Since new users may not have existing Dash funds, an invitation process will allow users to create an identity despite lacking their own funds. The invitation process will effectively separate the funding and registration steps that are required for any new identity to be created.

Once an identity is created, its credit balance is used to pay for activity (e.g. use of applications). The [topup process](#identity-balance-topup-process) provides a way to add additional funds to the balance when necessary.

### Identity Create Process

> 📘 Testnet Faucet
>
> On Testnet, a [test Dash faucet](https://testnet-faucet.dash.org/) is available. It dispenses small amounts to enable all users to directly acquire the funds necessary to create an identity and username.

First, a sponsor (which could be a business, another person, or even the same user who is creating the identity) spends Dash in a transaction to create an invitation. The transaction contains one or more outputs which lock some Dash funds to establish credits within Dash platform.

After the transaction is broadcast and confirmed, the sponsor sends information about the invitation to the new user. This may be done as a hyperlink that the core wallet understands, or as a QR code that a mobile wallet can scan. Once the user has the transaction data from the sponsor, they can use it to fund an [identity create state transition](https://github.com/dashpay/dips/blob/master/dip-0011.md#identity-create-transition) within Dash platform.

Users who already have Dash funds can act as their own sponsor if they wish, using the same steps listed here.

### Identity Balance Topup Process

The identity balance topup process works in a similar way to the initial identity creation funding. As with identity creation, a lock transaction is created on the layer 1 core blockchain. This lock transaction is then referenced in the [identity topup state transition](https://github.com/dashpay/dips/blob/master/dip-0011.md#identity-topup-transition) which increases the identity's balance by the designated amount.

> 📘  
>
> Since anyone can topup either their own account or any other account, application developers can easily subsidize the cost of using their application by topping up their user's identities.

### Identity Update Process

> 👍
>
> Added in Dash Platform Protocol v0.23

Identity owners may find it necessary to update their identity keys periodically for security purposes. The [identity update state transition](https://github.com/dashpay/dips/blob/master/dip-0011.md#identity-update-transition) enables users to add new keys and disable existing ones.

Identity updates only require the creation of a state transition that includes a list of keys being added and/or disabled. Platform retains disabled keys so that any existing data they signed can still be verified while preventing them from signing new data.

### Masternode Identities

Dash Platform v0.22 introduced identities for masternode owners and operators, and a future release will introduce identities for masternode voters. The system automatically creates and updates these identities based on information in the layer 1 masternode registration transactions. For example, owner/operator withdraw keys on Platform are aligned with the keys assigned on the Core blockchain.

In a future release, the credits paid as fees for state transitions will be distributed to masternode-related identities similar to how rewards are currently distributed to masternodes on the core blockchain. Credits will be split between owner and operator in the same ratio as on layer 1, and masternode owners will also have the flexibility to further split their portion between multiple identities to support reward-sharing use cases.

## Credits

> 👍  Added in Dash Platform Protocol v0.13
>
> DPP v0.13 introduced the initial implementation of credits. Future releases will expand the functionality available.

As mentioned above, credits provide the mechanism for paying fees that cover the cost of platform usage. Once a user locks Dash on the core blockchain and proves ownership of the locked value in an identity create or topup transaction, their credit balance increases by that amount. As they perform platform actions, these credits are deducted to pay the associated fees.

> 📘
>
> As of Dash Platform Protocol v0.13, credits deducted to pay state transition fees cannot be converted by masternodes back into Dash. This aspect of the credit system will come in a future release.
