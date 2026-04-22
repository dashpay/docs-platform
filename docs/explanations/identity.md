```{eval-rst}
.. _explanations-identity:
```

# Identity

## Overview

Identities are foundational to Dash Platform. They provide a familiar, easy-to-use way for users to interact and identify one another using names rather than complicated cryptocurrency identifiers such as public key hashes.

Identities are separate from names and can be thought of as a lower-level primitive that provides the foundation for various user-facing functionality. An identity consists primarily of one or more public keys recorded on the platform chain that can be used to control a user's profile and sign their documents. Each identity also has a balance of [credits](#credits) that is established by locking funds on layer 1. These credits are used to pay fees associated with the [state transitions](../explanations/platform-protocol-state-transition.md) used to perform actions on the platform.

:::{tip}
The [Identities Dash Improvement Proposal (DIP)](https://github.com/dashpay/dips/blob/master/dip-0011.md) provides more extensive background information and details.
:::

## Identity Management

In order to [create an identity](#identity-create-process), a user pays the network to store their public key(s) on the platform chain. This is done by locking Dash on the Core chain in an asset lock transaction and then submitting an identity create state transition that references a proof of that lock.

Once an identity is created, its credit balance is used to pay for activity (e.g. use of applications). The [topup process](#identity-balance-topup-process) provides a way to add additional funds to the balance when necessary.

### Identity Create Process

:::{note}
On Testnet, a [test Dash faucet](https://faucet.testnet.networks.dash.org/) is available. It dispenses small amounts to enable all users to directly acquire the funds necessary to create an identity and username.
:::

First, the user creates an asset lock transaction on the Core chain with one or more outputs that lock Dash funds for use on Platform. An asset lock proof is then obtained for that transaction - either an InstantSend lock proof (for fast confirmation) or a ChainLock-based proof once the transaction is included in a ChainLocked block.

The user then submits an [identity create state transition](https://github.com/dashpay/dips/blob/master/dip-0011.md#identity-create-transition) referencing the asset lock proof and the public keys to register for the new identity. The locked value (minus fees) becomes the new identity's initial credit balance.

Application-layer flows where a third party funds an identity on behalf of another user are possible by having that third party create the asset lock transaction and share the resulting proof, but this is a client-side convention rather than a protocol-level invitation mechanism.

### Identity Balance Topup Process

The identity balance topup process works in a similar way to the initial identity creation funding. As with identity creation, a lock transaction is created on the layer 1 core blockchain. This lock transaction is then referenced in the [identity topup state transition](https://github.com/dashpay/dips/blob/master/dip-0011.md#identity-topup-transition) which increases the identity's balance by the designated amount.

:::{note}
Since anyone can topup either their own account or any other account, application developers can easily subsidize the cost of using their application by topping up their user's identities.
:::

### Identity Update Process

Identity owners may find it necessary to update their identity keys periodically for security purposes. The [identity update state transition](https://github.com/dashpay/dips/blob/master/dip-0011.md#identity-update-transition) enables users to add new keys and disable existing ones.

Identity updates only require the creation of a state transition that includes a list of keys being added and/or disabled. Platform retains disabled keys so that any existing data they signed can still be verified while preventing them from signing new data.

### Masternode Identities

Several features, including voting and reward distribution, are dependent on masternodes reliably having identities. Thus, Dash Platform automatically creates identities for all masternodes using information from Core chain masternode registration transactions.

Unique identities are created for the owner, operator, and voting roles, with each one assigned the respective keys found in the masternode list. For example, owner and operator withdraw keys on Platform are set to their payout keys assigned on the Core blockchain. Since these identities are created automatically, their keys can only be modified using [Core masternode update transactions](inv:user:std#update-dip3-config).

#### Voting

All masternodes can use their identities to vote on Platform polls for contested resources. In Platform v1.0, masternode voting is used to resolve cases where multiple identities attempt to register the same [DPNS name](./dpns.md).

#### Reward distribution

Evonodes receive their Platform-specific block rewards and Platform fees with their masternode identity. The credits paid as state transition fees are distributed to masternode-related identities similar to how rewards are currently distributed to masternodes on the core blockchain. Credits are split between owner and operator in the same ratio as on layer 1, and masternode owners have the flexibility to further split their portion between multiple identities to support reward-sharing use cases.

Note: the payout key is associated with the masternode owner identity, so both the owner and payout keys should be controlled by the same party.

## Credits

Credits provide the mechanism for paying fees that cover the cost of platform usage. Once a user locks Dash on the core blockchain and proves ownership of the locked value in an identity create or topup state transition, their credit balance increases by that amount. As they perform platform actions, these credits are deducted to pay the associated fees.

Credits can be converted back to Dash using the identity credit withdrawal state transition, subject to a daily network-wide limit.
