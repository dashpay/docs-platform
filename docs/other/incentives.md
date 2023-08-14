# Overview

In a decentralized network, there is no authority directing each part of the system to do its work. Because of this, it's important to plan the system so that each participant benefits only by contributing in a way that helps the network. The major participants in Dash Platform are two of the three participants in Dash Core:

**Users:** new services that are part of Dash Platform give users capabilities they didn't have before.

**DAPI (Masternodes):** Masternodes operate a public API which receives platform data requests and alterations. They must have the resources to respond quickly and consistently.

**Miners:** Masternode data is hashed to a separate blockchain (the [platform chain](explanation-drive-platform-chain)) operated just by the masternodes, so miners' only contribution to Dash Platform is to store transactions from users converting Dash to credits, or from masternodes converting credits back to Dash.

In general, masternodes and miners are incentivized to perform this work by fees that the users pay as they use Dash Platform. In some cases, such as new user creation, someone else may pay the fee for the user. This may be expanded in the future to allow organizations to pay for their own users' platform activity.

# Details

## Fees

Dash Platform collects fees for three activities:

* [Registering a new identity](tutorial-register-an-identity)
* [Registering a Data Contract](tutorial-register-a-data-contract)
* [Updating Application Data](tutorial-submit-a-state-transition)

New users may not have any Dash of their own, so when registering an identity, some Dash is converted into _credits_, which is Dash that can only be spent on Platform activity. Users can also convert Dash into credits after registration as needed.

Dash Platform fees go to the masternodes, but how they are distributed is not yet finalized. The fees for registering a new identity, registering a data contract, and submitting a state transition, mainly exist today to reduce frivolous use of the platform. In the future when block rewards have decreased, fees may become the main source of compensation for the work Masternodes do storing and processing these activities.

## Attacks

Another kind of incentive which must be considered is the incentive to cheat. If there is a way that a participant can harm the network to improve their own situation, someone will do it. For example, if the fees from state transitions always went to the next masternode in line for a block payout, that masternode would be able to spam large, expensive state transitions, knowing that they would be getting their money back almost immediately. These kind of incentives guide and constrain all aspects of decentralized systems like Dash.