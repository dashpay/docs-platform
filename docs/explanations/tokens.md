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
- **Token-Based Document [Fees](#token-based-fees)**: Charge tokens for an application's document actions (e.g., create, transfer), with options to burn tokens or reward the contract owner
- **Optional [Shielded Pool](#shielded-pool)**: Let holders keep and move token balances privately in a pool dedicated to the token

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
| [Claim](#claim) | Redeems or withdraws tokens to the authorized identity (e.g., from rewards) |
| [Emergency action](#emergency-action) | Performs emergency actions like pausing or resuming the contract |
| [Token config update](#configuration-updates) | Updates token configuration settings |
| [Set Purchase Price](#set-purchase-price) | Sets or updates the price for direct token purchases |
| [Purchase](#purchase) | Purchases tokens at the predefined price in exchange for Platform credits |
| [Shielded pool actions](#shielded-pool-actions) | Moves tokens into, within, or out of the token's shielded pool, or mints, burns, claims, or purchases tokens directly in the pool |

#### Mint

- Creates new tokens to a specified identity or a fixed destination depending on the  [distribution rules](#distribution-rules) configuration
- Requires the sender (or group) to have mint permissions

#### Transfer

- Moves a given amount of tokens from the sender to a recipient identity. Three types of optional notes can be provided:
  - Public note (visible to everyone)  
  - Shared encrypted note (only sender & recipient can decrypt)  
  - Private encrypted note (only sender can decrypt)
- Not available for [non-transferable](#transferability) tokens

#### Burn

- Destroys a specified amount of tokens from the sender’s balance
- Can be restricted (i.e., not everyone can burn tokens unless configured)

#### Freeze and Thaw

- Freeze prevents an identity from transferring tokens. This is typically used by regulated tokens (e.g., stablecoins)
- Unfreeze (thaw) removes the restriction and enables transfers for the previously frozen identity
- Not available for tokens with a [shielded pool](#shielded-pool)

#### Destroy Frozen

- Destroy tokens from a frozen identity’s balance (e.g., blacklisting stolen tokens in stablecoin systems).

#### Claim

- Claim tokens that have been allocated to an identity by a [distribution rule](#distribution-rules) but not yet credited to its balance. Claim covers both:
  - **Perpetual distributions** - tokens continuously emitted on a block, time, or epoch schedule that recipients must pull in order to take ownership.
  - **Pre-programmed distributions** - tokens scheduled for specific recipients at specific times that recipients must claim to receive.
- Each claim collects a bounded number of unclaimed perpetual distribution intervals (128 for variable-rate distribution functions), so recipients with a long backlog may need to claim more than once to collect everything owed.

#### Emergency Action

- Globally pause or unpause an entire token. While paused, no transfers can occur.

#### Configuration Updates

Update token configuration parameters, including:

- Localization options and other display conventions
- Maximum supply
- Perpetual distribution settings and the destination for newly minted tokens
- The authorized party for each action rule
- Marketplace trade mode
- Which group acts as the main control group

A configuration update can point the token at a different [group](#groups), but it cannot change any group's members or their powers. Existing groups are immutable once the data contract is registered, although a data contract update can add groups at new positions.

#### Set Purchase Price

- Sets or updates the price for direct token purchases.
  - Can be a single entry (for a fixed price) or multiple entries for tiered pricing.
- Setting an empty price disables direct token purchases.
- Records changes to the token history if direct pricing history is enabled.

#### Purchase

- Purchases tokens at the predefined price in exchange for Platform credits
- Records changes to the token history if direct purchase history is enabled

#### Shielded Pool Actions

From protocol version 14, a token with a [shielded pool](#shielded-pool) supports additional actions that move tokens into, within, or out of its pool:

- **Shield**, **shielded transfer**, and **unshield** move tokens from a holder's balance into the pool, between notes inside the pool, and from the pool to any identity's token balance.
- **Mint to pool** and **burn from pool** follow the token's manual minting and burning rules, and can be performed by a [group](#groups). Minting into the pool also requires the token to allow choosing the mint destination, since the minter decides who receives the new notes. A burn from the pool spends notes that the burner holds; it cannot remove other holders' notes.
- **Claim to pool** and **purchase to pool** deliver a distribution claim or a direct purchase as new notes in the pool instead of to the identity's balance.

The identity that signs the transition pays the fee in credits; tokens are never used to pay fees. Every shielded pool action is rejected while the token is paused. See [Shielded Pool](./shielded-pool.md#token-shielded-pools) for how token pools relate to the credit shielded pool, including transitions that move pooled tokens without involving any identity.

### Configuration

When creating a token, you define its configuration using the following parameters. Some parameters can be configured to allow modifications after data contract registration, but several are fixed permanently when the contract is registered:

| Configuration Parameter | Mutable           | Default |
|:------------------------|:------------------|:--------|
| Description                              | **No** | None |
| [Conventions](#display-conventions)      | Yes | Required; must include English |
| [Decimal precision](#display-conventions)| Yes | [8](https://github.com/dashpay/platform/blob/v5.0-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/v0/mod.rs#L57) |
| [Base supply](#token-supply)             | **No**  | [0](https://github.com/dashpay/platform/blob/v5.0-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration/v0/mod.rs#L55) |
| [Maximum supply](#token-supply)          | Yes | None |
| [Keep history](#history)                 | **No** | True (all history types) |
| [Start paused](#initial-state)           | **No** | False |
| [Allow transfer to frozen balance](#allow-transfer-to-frozen-balance) | **No** | True |
| [Transferable](#transferability)         | **No** | True |
| [Shielded pool](#shielded-pool)          | **No** | False |
| [Minimum pool notes for outgoing](#shielded-pool) | Yes | None |
| [Main control group](#main-control-group)| Yes | None |
| Main control group can be modified       | **No** | NoOne |
| Marketplace rules                        | Yes | NotTradeable |
| [Distribution rules](#distribution-rules)| Yes (pre-programmed schedule excluded) | None |

#### Display Conventions

- The token name in multiple languages, how to capitalize it, singular vs. plural form, etc.
- An English (`en`) localization is required and serves as the fallback for languages the token does not define. Singular and plural names must be 3-25 characters.
- How many decimal places the token uses (limited to 16)

#### Token Supply

- Initial supply at launch (base supply)
- Maximum supply
  - Minting is rejected if it would push the current supply above the maximum supply, so a token that starts at its maximum cannot be minted until some of it is burned
  - Token can be configured to allow authorized parties to change the maximum supply

#### History

- Whether or not to store an on-chain log of token actions. History is configured per action category (for example transfers, minting, burning, and freezing) rather than as a single switch, so a token can record some categories and not others.
- Some categories are always recorded regardless of configuration: configuration updates, destroying frozen funds, emergency actions, and distribution.

#### Initial State

- Whether the token starts out paused (no transfers allowed) upon creation

#### Change Control Rules

- Who (or what group) can change specific parameters later
- Whether the authority to change these parameters can be transferred or locked to "no one"
- Example: "Only group #1 can update the max supply.” See the [Rules section](#rules) for details.

#### Allow Transfer to Frozen Balance

- Allow transferring and minting of tokens to frozen identity token balances

#### Transferability

- From protocol version 14, a token can be made non-transferable. Holders cannot transfer it to another identity, but it can still be minted (including to a chosen recipient), claimed, purchased directly, burned, frozen, and destroyed as configured.
- A document type can charge a non-transferable token only by burning it. Since only a contract's own token can be burned as a [token-based fee](#token-based-fees), document types in other contracts cannot charge it at all.
- A non-transferable token cannot have a [shielded pool](#shielded-pool).

#### Shielded Pool

- From protocol version 14, a token can have its own shielded pool that lets holders keep and move balances privately. See [Shielded pool actions](#shielded-pool-actions) and the [Shielded Pool](./shielded-pool.md#token-shielded-pools) explanation.
- The pool can only be enabled when the token is created. It cannot be added to or removed from an existing token.
- Notes in the pool belong to no identity's balance, so they cannot be frozen. A token with a pool must therefore permanently disable freezing: its freeze, unfreeze, and destroy frozen funds rules must authorize no one. Pausing the token still applies to the pool.
- The token can require the pool to hold a minimum number of notes (at most 250) before tokens may leave it. No minimum is required by default. The minimum can be changed later only if the token's change rules authorize someone to change it.

#### Main Control Group

- A group that can be referenced in other fields to control multiple aspects of the token with the same group.

#### Rules

Token rules assign permissions for various token control and configuration actions. There are levels of authorization defined by rules: Admin and Control.

:::{tip}
For more details, see [Change Rule Structure](../protocol-ref/data-contract-token.md#change-rule-structure) section in the protocol reference.
:::

**Admin**

Admin level rule settings are used to manage who has permission to perform actions by modifying which user or [group](#groups) is authorized to complete an action. An admin group can also modify who has admin authorization if the data contract has enabled that option.

**Control**

Control level rule settings define who can perform token actions. This includes actions like [mint](#mint) or [burn](#burn), as well as [token distribution](#distribution-rules).

##### Action Rules

Token action rules can be configured to control access to many [token actions](#actions). The
following table summarizes the configurable rules and their default authorized parties:

###### General Controls

| Configuration Rule                    | Can be Changed? | Default Authorized Party |
|:--------------------------------------|:----------------|:-------------------------|
| Conventions change rules              | Yes             | NoOne                    |
| Max supply change rules               | Yes             | NoOne                    |
| Main control group can be modified    | No              | NoOne                    |
| Marketplace trade mode change rules   | Yes             | NoOne                    |
| Minimum pool notes for outgoing change rules | Yes      | NoOne                    |

###### Minting and Burning

| Configuration Rule                    | Can be Changed? | Default Authorized Party |
|:--------------------------------------|:----------------|:-------------------------|
| Manual minting rules                  | Yes             | Contract Owner           |
| Manual burning rules                  | Yes             | Contract Owner           |
| Minting: choosing destination rules   | Yes             | NoOne                    |

###### Freezing Controls

| Configuration Rule                    | Can be Changed? | Default Authorized Party |
|:--------------------------------------|:----------------|:-------------------------|
| Freeze rules                          | Yes             | NoOne                    |
| Unfreeze rules                        | Yes             | NoOne                    |
| Destroy frozen funds rules            | Yes             | NoOne                    |

###### Distribution

| Configuration Rule                    | Can be Changed? | Default Authorized Party |
|:--------------------------------------|:----------------|:-------------------------|
| Perpetual distribution rules          | Yes             | NoOne                    |
| New tokens destination identity rules | Yes             | NoOne                    |
| Direct purchase pricing change rules  | Yes             | NoOne                    |

###### Emergency

| Configuration Rule                    | Can be Changed? | Default Authorized Party |
|:--------------------------------------|:----------------|:-------------------------|
| Emergency action rules                | Yes             | NoOne                    |

##### Distribution Rules

Tokens have distribution rules to define how new tokens are introduced over time. The three
distribution options are summarized below:

| Method | Description |  Example |  Notes |
| ------ | ----------- | -------- | ------ |
| Manual Minting      | Authorized users/groups can create new tokens until `maxSupply` is reached | On-demand minting | - Requires proper configuration to enable<br>- Minting actions may be logged or controlled via permissions |
| Programmed Distribution | A fixed number of tokens are allocated to designated identities at explicit timestamps, and the recipients must [claim](#claim) them to receive the tokens | *On Jan 1, 2047, allocate `X` tokens to the provided identity* | - Schedules token release at known times<br>- Each entry is a one-time allocation at a fixed timestamp; there is no recurrence option<br>- The schedule is set when the contract is registered and cannot be changed later |
| [Perpetual Distribution](../protocol-ref/data-contract-token.md#perpetual-distribution-options) | Scheduled release of tokens based on block, time, or epoch intervals | *Emit 100 tokens every 20 blocks*, or *Halve the emission every year* | - Offers ongoing, dynamic token emission patterns.<br>- Supports variable rates (e.g., linear, steps).<br>- Emissions accrue on schedule and are always collected by the recipient via a [claim](#claim). |

Dash Platform also supports three options to control the destination for newly minted tokens:

| Option | Description | Notes |
| - | - | - |
| **Choose Destination** | The minter can dynamically specify which identity receives newly minted tokens at the time of minting. | - Offers flexibility for varied or on-demand allocation.<br>- Requires minter input for each mint event. |
| **Fixed Destination**  | Newly minted tokens are always directed to one predetermined (fixed) identity. | - Ensures a strict, predictable allocation.<br>- No choice at the time of minting once configured. |
| **Combination / Exclusive** | These two approaches can be used exclusively (only one rule active) or combined for more granular control. | - In a combined setup, some mints could go to a fixed address while others go to a chosen address. |

Perpetual distributions can also target evonodes as a group rather than a single identity, allocating the emission across them in proportion to their participation. This recipient mode applies only to epoch-based perpetual distributions.

### Groups

Groups can be used to distribute token configuration and update authorization across multiple identities. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action.

- Each group member is assigned an integer power. No member may have a power of zero.
- The group itself has a required power threshold to authorize an action.
- A group must have at least two members.
- No member's power may exceed the group's required threshold, so no single member can be given more weight than the threshold itself.
- The required threshold must be between 1 and 65535, and the members' combined power must be able to reach it.
- If some members have power equal to the threshold (and so can act alone), the remaining members must still be able to reach the threshold together.
- Groups can currently have up to 256 members, each with a maximum power of 65535 (2^16 - 1).
- Changes to a token (e.g., mint, burn, freeze) can be configured so they require group authorization. This is done by assigning the group under the [token rule configuration](#rules).

**Example**

A token's mint action is protected by a [rule](#rules) that only authorizes a group to mint tokens. Therefore, members of the assigned group must cooperate to complete the action. Once enough members (by power) approve, the network will finalize the action.

For example, a group is defined with a required threshold of 10. The group members are assigned the following powers:

- Member A: 6  
- Member B: 3  
- Member C: 5  

In this group, Member A and Member C have a combined power of 11 and can perform actions without approval from Member B. If Member B proposes an action, Member A and C must both approve to authorize the action.

When a group burns tokens, the tokens come from the balance of the member who proposed the burn. Members who only sign the action contribute their power; their own balances are not affected.

### Token-Based Fees

Dash Platform allows developers to charge token fees for document-related actions (e.g., creating or transferring a document). This provides a way to monetize app usage or implement economic incentives using tokens. These fees are configured per document type in the data contract, and each document action (create, replace, delete, transfer, set price, purchase) can carry its own cost. Different document types in the same contract can therefore charge different amounts, or nothing at all.

Examples:

- Require 1000 tokens to create a document
- Burn 200 tokens when a document is transferred

This allows for:

- Spam protection (pay-to-post)
- Revenue generation for app creators
- Deflationary models via token burning
- Shared-currency ecosystems, by pricing document actions in a token that belongs to another contract. Such external-token payments transfer to the contract owner; burning is only permitted for a contract's own token.
- A gasless user experience, by having the contract owner rather than the document owner pay the Platform credit cost of the action (from protocol version 14). The identity submitting the action still pays any [user fee increase](./fees.md#user-fee-increase) it adds.

Alongside the amount and its effect, each cost in the contract specifies who pays the Platform gas fees. Separately, the client submitting the action can attach its own minimum and maximum bounds on what it is willing to pay. Clients should generally set a maximum: without one, a contract whose rules allow the price to change could charge more than the user expected between signing and execution.

From protocol version 14, a token payment must also respect the token's own configuration. A paused token cannot be burned or transferred to pay for document actions. A [non-transferable](#transferability) token can only be burned. A payment to a contract owner whose token account is frozen is rejected unless the token [allows transfers to frozen balances](#allow-transfer-to-frozen-balance). If the token has a [shielded pool](#shielded-pool), the cost can instead be paid from the pool, leaving the payer's token balance untouched.

## Token Creation

Creating a token on Dash Platform consists of creating a data contract, registering it on the network, and then creating tokens based on the schema defined in the data contract.

When a contract that declares a token is registered, Platform automatically mints the token's configured base supply to the contract owner (or to the destination configured for new tokens). A single contract may declare more than one token; each token is identified by its position within the contract and configured independently. Ongoing changes to token balances - including further minting, burning, transfers, freezes, and claims - are performed through the [token state transitions](#actions).

A token can also be added to a contract that is already registered, by updating the contract to declare a token at a previously unused position. Token positions that already exist cannot be altered, and their configuration cannot be modified by a contract update. All post-registration changes to an existing token must use the [token config update](#configuration-updates) action.

### Contract Setup

Structurally, there is no difference between contracts incorporating tokens and non-token contracts. While token contracts have a large set of token-specific options, there is no other difference.

Once the data contract design is completed, the contract can be registered on the network in preparation for token minting and use. See the [contract registration tutorial](../tutorials/contracts-and-documents/register-a-data-contract.md) for examples of how to register a contract. For step-by-step examples covering token contract registration, minting, burning, transferring, and querying token information, see the [token tutorials](../tutorials/tokens.md).

## Token Trading

### Direct Purchase

Tokens can be configured to enable direct purchase by users. This allows the contract owner (or other authorized party) to sell the token directly to users at a fixed price or according to a tiered pricing schedule.

The token’s [change control rules](#change-control-rules) include a `changeDirectPurchasePricingRules` setting to determine who is authorized to set or update the price. By default this is set to no one (`NoOne`) to disable direct sales. To allow direct sales, this rule should be set to authorize someone (e.g., the contract owner) to change pricing.

When enabled, the authorized party can set the token price using a state transition. Users can purchase the token through Platform’s built-in mechanism (see [Token Set Purchase Price Transition](../protocol-ref/token.md#token-set-purchase-price-transition) and [Token Purchase Transition](../protocol-ref/token.md#token-purchase-transition)). The direct purchase system supports defining a minimum purchase amount and volume discounts via pricing tiers. The token’s price can also be removed to stop sales.

### Marketplace

Token contracts already expose marketplace rules in their configuration, which declares a trade mode that governs how tokens may be traded on Platform. The only trade mode currently defined is:

- **`NotTradeable`** - the token cannot be traded on Platform. This is the default and, at present, the only available value.

A dedicated marketplace trade mode is reserved for a future release. The protocol-level marketplace rules exist to support this, but the trade mode itself, along with broader client tooling and user-facing marketplace experiences, is expected to continue evolving in future releases.
