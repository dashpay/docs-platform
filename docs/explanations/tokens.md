```{eval-rst}
.. _explanations-tokens:
```

# Tokens

## Overview

Dash Platform lets developers create and manage tokens (similar to ERC-20 style assets) without writing smart contracts. Tokens leverage data contracts, state transitions, and built-in access control (via data contract groups) to enable flexible token management.

## Token Features

Dash Platform’s token functionality provides a straightforward, account-based approach to creating and managing tokens that is much simpler than writing custom smart contracts. Features include:

- **Flexible [Configuration](#configuration)**: Localization, supply limits, admin rules, freeze/pause rules, etc.
- **Access Control [Groups](#groups)**: Multi-party groups with user-defined thresholds support complex authorization schemes for token management
- **Built-in [Distribution](#distribution-rules)**: Manual minting or scheduled release over time
- **Seamless Integration**: Tokens live alongside documents in a single data contract, enabling additional use cases (e.g., ticketing, digital assets, stablecoins)

The following sections describe the features and configuration options available for token creators
using Dash Platform.

### Actions

:::{note}
Authorization for token actions is based on the configuration defined in the data contract. Token creators may disable specific actions or limit the ability to modify the token configuration.
:::

The initial token implementation includes all actions required to create, use, and manage tokens. This table summarizes available actions:

| Action                 | Description |
|------------------------|-------------|
| [Mint](#mint)          | Mints new tokens to a specified recipient |
| [Transfer](#transfer)  | Transfers tokens to another recipient |
| [Burn](#burn)          | Burns (destroys) a specified amount of tokens |
| [Freeze / Thaw](#freeze-and-thaw) | Freezes/thaws a specific entity's tokens |
| [Destroy frozen funds](#destroy-frozen) | Destroys frozen funds for a specified entity |
| [Emergency action](#emergency-action) | Performs emergency actions like pausing or resuming the contract |
| [Token config update](#configuration-updates) | Updates token configuration settings |

#### Mint

- Creates new tokens to a specified identity or a fixed destination depending on the  [distribution rules](#distribution-rules) configuration
- Requires the sender (or group) to have mint permissions

#### Transfer

- Moves a given amount of tokens from the sender to a recipient identity. Three types of optional notes can be provided:
  - Public note (visible to everyone)  
  - Shared encrypted note (only sender & recipient can decrypt)  
  - Private encrypted note (only sender can decrypt)

#### Burn

- Destroys a specified amount of tokens from the sender’s balance
- Can be restricted (i.e., not everyone can burn tokens unless configured)

#### Freeze and Thaw

- Freeze prevents an identity from transferring tokens. This is typically used by regulated tokens (e.g., stablecoins)
- Unfreeze (thaw) removes the restriction and enables transfers for the previously frozen identity

#### Destroy Frozen

- Destroy tokens from a frozen identity’s balance (e.g., blacklisting stolen tokens in stablecoin systems).

#### Emergency Action

- Globally pause or unpause an entire token. While paused, no transfers can occur.

#### Configuration Updates

Update token configuration parameters, including:

- Localization options
- Maximum supply
- History retention
- Group membership

### Configuration

When creating a token, you define its configuration using the following parameters. Most parameters can be configured to allow modifications after data contract registration; however, the base supply is immutable:

| Configuration Parameter | Mutable           | Default |
|:------------------------|:------------------|:--------|
| [Conventions](#display-conventions)      | Yes | N/A. Depends on implementation |
| [Decimal precision](#display-conventions)| Yes | [8](https://github.com/dashpay/platform/blob/v2.0-tokens-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/v0/mod.rs#L38) |
| [Base supply](#token-supply)             | **No**  | [100000](https://github.com/dashpay/platform/blob/v2.0-tokens-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration/v0/mod.rs#L159) |
| [Maximum supply](#token-supply)          | Yes | None |
| [Keep history](#history)                 | Yes | True |
| [Start paused](#initial-state)           | Yes | False |
| [Main control group](#main-control-group)| Yes | None |
| Main control group can be modified       | Yes | NoOne |

#### Display Conventions

- The token name in multiple languages, how to capitalize it, singular vs. plural form, etc.
- How many decimal places the token uses

#### Token Supply

- Initial supply at launch (base supply)
- Maximum supply
  - No minting is possible if the maximum supply equals the base supply
  - Token can be configured to allow authorized parties to change the maximum supply

#### History

- Whether or not to store a complete on-chain log of every token action (e.g., transfers, burns, etc.)

#### Initial State

- Whether the token starts out paused (no transfers allowed) upon creation

#### Change Control Rules

- Who (or what group) can change specific parameters later
- Whether the authority to change these parameters can be transferred or locked to "no one"
- Example: "Only group #1 can update the max supply.” See the [Rules section](#rules) for details.

#### Main Control Group

- A group that can be referenced in other fields to control multiple aspects of the token with the same group.

#### Rules

Token rules assign permissions for various token control and configuration actions. There are levels of authorization defined by rules: Admin and Control.

**Admin**

Admin level rule settings are used to manage who has permission to perform actions by modifying which user or [group](#groups) is authorized to complete an action. An admin group can also modify who has admin authorization if the data contract has enabled that option.

**Control**

Control level rule settings define who can perform token actions. This includes actions like [mint](#mint) or [burn](#burn), as well as [token distribution](#distribution-rules).

##### Parameters

Each rule consists of the following parameters [defined in DPP](https://github.com/dashpay/platform/blob/v2.0-tokens-dev/packages/rs-dpp/src/data_contract/change_control_rules/v0/mod.rs) that control its behavior:

| Field | Description |
| - | - |
| `authorized_to`<br>`_make_change` | This is who is authorized to make such a change. Valid values are listed in the [authorized parties table](#authorized-parties). |
| `admin_action_takers` | This is who is authorized to make such a change to the people authorized to make a change. Valid values are listed in the [authorized parties table](#authorized-parties). |
| `changing_authorized`<br>`_action_takers_to`<br>`_no_one_allowed` | Are we allowed to change to `NoOne` in the future (default: false) |
| `changing_admin_action`<br>`_takers_to_no_one_allowed` | Are we allowed to change the admin action takers to `NoOne` in the future (default: false) |
| `self_changing_admin_`<br>`action_takers_allowed` | Can the admin action takers change themselves (default: false) |

###### Authorized Parties

Rules can authorize no one, specific identities, or multiparty groups. The complete set of options [defined by DPP](https://github.com/dashpay/platform/blob/v2.0-tokens-dev/packages/rs-dpp/src/data_contract/change_control_rules/authorized_action_takers.rs#L14-L21) is:

| Authorized Party     | Description |
|----------------------|-------------|
| `NoOne`              | No one is authorized |
| `ContractOwner`      | Only the contract owner is authorized |
| `Identity(Identifier)` | Only an identity is authorized |
| `MainGroup`          | Only the [main control group](#main-control-group) is authorized |
| `Group(<x>)`         | Only the specific group based in contract position "x" is authorized |

##### Action Rules

Token action rules can be configured to allow updating who has access to many [token actions](#actions). The following table summarizes the available action rules:

| Configuration Rule | Can be Changed?   | Default Authorized Party|
|:-------------------|:------------------|:--------|
| Conventions change rules   | Yes | NoOne |
| Max supply change rules    | Yes | NoOne |
| Manual minting rules       | Yes | Contract Owner |
| Manual burning rules       | Yes | Contract Owner |
| Freeze rules               | Yes | NoOne |
| Unfreeze rules             | Yes | NoOne |
| Destroy frozen funds rules | Yes | NoOne |
| Emergency_action rules     | Yes | NoOne |
| Main control group can be modified | Yes | NoOne |

##### Distribution Rules

Tokens have distribution rules to define how new tokens are introduced over time. The three
distribution options are summarized below:

| Method | Description |  Example |  Notes |
| ------ | ----------- | -------- | ------ |
| Manual Minting      | Authorized users/groups can create new tokens until `maxSupply` is reached | On-demand minting | - Requires proper configuration to enable<br>- Minting actions may be logged or controlled via permissions |
| Programmed Distribution | A fixed number of tokens are automatically minted to designated identities at a specific timestamp | *On Jan 1, 2047, allocate `X` tokens to the provided identity* | - Automates token release at known times<br>- Useful for predictable, one-time or recurring events at fixed timestamps |
| Perpetual Distribution | Scheduled release of tokens based on blocks or time intervals | *Emit 100 tokens every 20 blocks*, or *Halve the emission every year* | - Offers ongoing, dynamic token emission patterns.<br>- Supports variable rates (e.g., linear, steps).<br>- Configurable to trigger automatically or require manual "release" actions. |
  
Dash Platform also supports three options to control the destination for newly minted tokens:

| Option | Description | Notes |
| - | - | - |
| **Choose Destination** | The minter can dynamically specify which identity receives newly minted tokens at the time of minting. | - Offers flexibility for varied or on-demand allocation.<br>- Requires minter input for each mint event. |
| **Fixed Destination**  | Newly minted tokens are always directed to one predetermined (fixed) identity. | - Ensures a strict, predictable allocation.<br>- No choice at the time of minting once configured. |
| **Combination / Exclusive** | These two approaches can be used exclusively (only one rule active) or combined for more granular control. | - In a combined setup, some mints could go to a fixed address while others go to a chosen address. |

### Groups

Groups can be used to distribute token configuration and update authorization across multiple identities. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action.

- Each group member is assigned an integer power.
- The group itself has a required power threshold to authorize an action.
- Groups can have up to 256 members, each with a maximum power of 2^16 - 1 (65536).
- Changes to a token (e.g., mint, burn, freeze) can be configured so they require group authorization. This is done by assigning the group under the [token rule configuration](#rules).

**Example**

A token's mint action is protected by a [rule](#rules) that only authorizes a group to mint tokens. Therefore, members of the assigned group must cooperate to complete the action. Once enough members (by power) approve, the network will finalize the action.

For example, a group is defined with a required threshold of 10. The group members are assigned the following powers:

- Member A: 6  
- Member B: 3  
- Member C: 5  

In this group, Member A and Member C have a combined power of 11 and can perform actions without approval from Member B. If Member B proposes an action, Member A and C must both approve to authorize the action.

## Token Creation

Creating a token on Dash Platform consists of creating a data contract, registering it on the network, and then creating tokens based on the schema defined in the data contract.

### Contract Setup

Structurally, there is no difference between contracts incorporating tokens and non-token contracts. While token contracts have a large set of token-specific options, there is no other difference.

Once the data contract design is completed, the contract can be registered on the network in preparation for token minting and use. See the [contract registration tutorial](../tutorials/contracts-and-documents/register-a-data-contract.md) for examples of how to register a contract.

### Example Contract

```json
{
   "$format_version": "1",
   "id": "AcYUCSvAmUwryNsQqkqqD1o3BnFuzepGtR3Mhh2swLk6",
   "ownerId": "HLfavpy1B2mVHnpYYDKDVM76eWJRqvPfuuASy7cyJBXC",
   "version": 1,
   "documentSchemas": {},
   "tokens": {
     "0": {
       "$format_version": "0",
       "conventions": {
         "$format_version": "0",
         "localizations": {
           "en": {
             "shouldCapitalize": true,
             "singularForm": "flurgon",
             "pluralForm": "flurgons"
           }
         },
         "decimals": 8
       },
       "baseSupply": 1000000,
       "maxSupply": 5000000,
       "transferable": true,
       "keepsHistory": false,
       "freezeRules": {
         "V0": {
           "authorized_to_make_change": "ContractOwner",
           "admin_action_takers": "ContractOwner",
           "changing_authorized_action_takers_to_no_one_allowed": false,
           "changing_admin_action_takers_to_no_one_allowed": false,
           "self_changing_admin_action_takers_allowed": false
         }
       },
       "unfreezeRules": {
         "V0": {
           "authorized_to_make_change": "ContractOwner",
           "admin_action_takers": "ContractOwner",
           "changing_authorized_action_takers_to_no_one_allowed": false,
           "changing_admin_action_takers_to_no_one_allowed": false,
           "self_changing_admin_action_takers_allowed": false
         }
       },
       "destroyFrozenFundsRules": {
         "V0": {
           "authorized_to_make_change": "ContractOwner",
           "admin_action_takers": "ContractOwner",
           "changing_authorized_action_takers_to_no_one_allowed": false,
           "changing_admin_action_takers_to_no_one_allowed": false,
           "self_changing_admin_action_takers_allowed": false
         }
       },
       "emergencyActionRules": {
         "V0": {
           "authorized_to_make_change": "ContractOwner",
           "admin_action_takers": "ContractOwner",
           "changing_authorized_action_takers_to_no_one_allowed": false,
           "changing_admin_action_takers_to_no_one_allowed": false,
           "self_changing_admin_action_takers_allowed": false
         }
       }
     }
   }
}
```

## Token Trading

A planned token marketplace will support the trading of tokens.
