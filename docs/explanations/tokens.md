```{eval-rst}
.. _explanations-tokens:
```

# Tokens

Dash Platform is designed to let developers create and manage tokens (similar to ERC-20 style assets) without writing smart contracts. Tokens leverage data contracts, state transitions, and built-in access control (via data contract groups) to provide flexible token management.

Dash Platform’s token functionality provides an easy, account-based approach to creating and managing tokens—much simpler than writing custom smart contracts. Features include:

- **Flexible Configuration**: Localization, supply limits, admin rules, freeze/pause rules, etc.
- **Access Control**: Multi-signature "groups” with user-defined thresholds
- **Built-in Distribution**: Manual minting or scheduled release over time
- **Seamless Integration**: Tokens live alongside documents in a single data contract, enabling additional use cases (e.g., ticketing, digital assets, stablecoins)

## Token Features

The following sections describe the features and options available for token creators using Dash
Platform.

### Mint

- Creates new tokens, either to a specified identity or a fixed destination depending on the  [distribution rules](#distribution-rules)  configuration
- Requires the sender (or group) to have `mint` permissions

### Transfer

Moves a given amount of tokens from the sender to a recipient identity. Three types of optional notes can be provided:

- Public note (visible to everyone)  
- Shared encrypted note (only sender & recipient can decrypt)  
- Private encrypted note (only sender can decrypt)

### Burn

- Destroys a specified amount of tokens from the sender’s balance
- Can be restricted (i.e., not everyone can burn tokens unless configured)

### Freeze and Unfreeze

- Freeze prevents an identity from transferring tokens. This is typically used by regulated tokens (e.g., stablecoins)
- Unfreeze removes the restriction and enables transfers for the previously frozen identity

### Destroy Frozen

:::{note}
This feature can only be used if it was enabled in the token configuration.
:::

Destroys tokens from a frozen identity’s balance (e.g., blacklisting stolen tokens in stablecoin systems).

### Emergency Action

Globally pause or unpause an entire token. While paused, no transfers can occur.


## Token Creation

Creating a token on Dash Platform consists of creating a data contract, registering it on the network, and then creating tokens based on the schema defined in the data contract.


## Data Contract Structure

Tokens live inside the [data contract](./platform-protocol-data-contract.md) alongside documents and groups. A single contract can define:

- **One or more tokens** (indexed by a "token contract position”—e.g., `0`, `1`, etc.).
- **One or more groups** (for multi-signature / access-control rules).

### Groups

Groups can be used to distribute token configuration and update authorization across multiple identities. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action.

- Each group member is assigned an integer power.
- The group itself has a required power threshold to authorize an action.
- Groups can have up to 256 members, each with a maximum power of 2^16 - 1 (65536).
- Changes to a token (e.g., mint, burn, freeze) can be configured so they require group authorization.

**Example**

A group is defined with a required threshold of 10. The group members are assigned the following power:

- Member A: 6  
- Member B: 3  
- Member C: 5  

In this group, Member A and Member C have a combined power of 11 and can perform actions without approval from Member B. If Member B proposes an action, Member A and C must both approve for the action to be authorized.

### Token Configuration

When creating a token, you define its **configuration**, which includes:

1. **Naming Conventions / Localizations**  
   - Token name in multiple languages, how to capitalize it, singular vs. plural form, etc.

2. **Decimals / Precision**  
   - How many decimal places the token uses.

3. **Base Supply and Maximum Supply**  
   - Initial supply at launch (`baseSupply`).  
   - Hard cap (`maxSupply`). If `maxSupply = baseSupply`, no minting is possible.

4. **History Keeping**  
   - Whether or not to store a full on-chain log of every token action (e.g., transfers, burns, etc.).

5. **Paused State** (initial)  
   - Whether the token starts out "paused” (no transfers allowed) upon creation.

6. **Change Control Rules**  
   - Who (or what group) can change specific fields later.  
   - Whether the authority to change these fields can be **transferred** or locked to "no one.”  
   - Example: "Only group #0 (2-of-3 multisig) can update the max supply.”

7. **Main Control Group**  
   - A "catch-all” group you can reference in other fields if you want the same group to control multiple aspects of the token.

## Distribution Rules

Tokens can have distribution rules to define how new tokens are introduced over time. The three
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

## Example Workflow

1. **Create a Data Contract**  
   - Define "groups” for your multi-sig rules (optional).  
   - Define a "token” with the appropriate configuration (max supply, distribution, etc.).

2. **Issue a State Transition**  
   - For instance, to mint tokens if you are an authorized minter.  
   - If multi-signature is required, multiple members must submit transitions referencing the same "action ID.”

3. **Query the Network**  
   - **Get Identity Token Balances:** Confirm how many tokens each identity holds.  
   - **Get Token Total Supply:** Verify total minted tokens match your expectations.  
   - **Get Group Info:** Check which group members can sign off on future changes.

4. **Perform Other Operations**  
   - Transfer tokens between identities (with optional notes).  
   - Freeze/Unfreeze suspicious addresses.  
   - Burn tokens, or schedule them to be minted in the future, and so on.

## Overview of Token Queries

Several new queries have been introduced to interact with tokens on the network:

1. **Get Identity Token Balances**  
   - **Use Case**: Retrieve all token balances belonging to a **single identity** across multiple tokens.
   - **Example**: Return the amounts of `TokenA`, `TokenB`, etc. owned by identity `X`.

2. **Get Identities Token Balances**  
   - **Use Case**: Retrieve the balances of **one particular token** across multiple identities.
   - **Example**: Return the balances of `TokenA` for identities `X`, `Y`, `Z`.

3. **Get Token Statuses / Infos**  
   - **Use Case**: Check if a token is paused, or if an identity is frozen.  
   - **Examples**:  
     - **Is the token globally paused?**  
     - **Is this identity’s balance frozen?**  

4. **Get Token Total Supply**  
   - **Use Case**: Audit the total supply of a token on-chain.  
   - **Example**: Compare the "official” total supply vs. the sum of all balances across identities to verify everything is in sync.

5. **Get Group Info**  
   - **Use Case**: Inspect the details of groups (multi-signature style access control).  
   - **Example**: Retrieve each group’s members, their power (vote weight), and the required power threshold to authorize actions such as minting or configuration changes.

## Future Extensions

- **Smart Contracts**: In the future, more advanced logic (e.g., timed release with special conditions, or advanced marketplaces) can be built on top of these tokens.  
- **Document Cost in Tokens**: Eventually, creation of certain documents in a data contract could require payment in a specified token (e.g., for ticketing systems where you "redeem” a token to generate a user-specific ticket document).
