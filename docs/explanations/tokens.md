```{eval-rst}
.. _explanations-tokens:
```

# Tokens

The Dash Platform token system is designed to let developers create and manage tokens (similar to ERC-20 style assets) without writing full-blown smart contracts. It leverages Dash’s data contracts, state transition types, and built-in access control (via "groups”) to provide flexible token management.

Dash Platform’s token functionality provides an easy, account-based approach to creating and managing tokens—much simpler than writing custom smart contracts. Features include:

- **Flexible Configuration**: Localization, supply limits, admin rules, freeze/pause rules, etc
- **Robust Access Control**: Multi-signature "groups” with user-defined thresholds
- **Built-in Distribution**: Manual minting or scheduled release over time
- **Seamless Integration**: Tokens live alongside documents in a single data contract, enabling additional use cases (e.g., ticketing, digital assets, stablecoins)

As this feature continues to develop, expect refinements to distribution types, group logic, and new queries or transitional actions. For now, this documentation should serve as a starting point to understand the fundamental pieces of the new token system.

## Data Contract Structure

Tokens live inside a **Data Contract** alongside "Groups.” A single contract can define:

- **One or more tokens** (indexed by a "token contract position”—e.g., `0`, `1`, etc.).
- **One or more groups** (for multi-signature / access-control rules).

### Groups

A "Group” represents a set of members and the "power” of each member:

- Each member has an integer "power.”
- The group itself has a "required power” threshold to authorize an action.
- You can have up to 256 members in a group, each with a maximum power of `2^16 - 1`.
- Changes to a token (e.g., mint, burn, freeze) can be configured so they require group authorization.
  - Example: "2-of-3 multisig” among three admins, each with certain voting power.

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

Tokens can have "distribution rules” to define **how new tokens are introduced** over time:

1. **Manual Minting**  
   - If configured to allow manual minting, authorized users (or groups) can create new tokens at will (subject to `maxSupply`).

2. **Programmed Distribution**  
   - "Hard-coded” events: At a specific future timestamp, a fixed number of tokens automatically mint to certain identities.  
   - Example: On `Jan 1st, 2027`, allocate `X` tokens to identity `Alice`.

3. **Perpetual Distribution** *(in active development)*  
   - Releasing tokens on a block-based or time-based schedule, potentially with variable amounts (linear, logarithmic, stepwise, etc.).  
   - Example: "Emit 100 tokens every 20 blocks,” or "Halve the emission every year,” etc.  
   - These distributions can be automatically triggered (if configured) or must be manually invoked with a "release” action.

4. **Mint Destination Rules**  
   - **Choose Destination**: The minter can specify which identity receives newly minted tokens.  
   - **Fixed Destination**: Newly minted tokens always go to a predetermined identity.  
   - These can be combined or set exclusively.

## Token State Transitions

All token operations occur through **state transitions** (similar to documents in Dash Platform). Key operations include:

1. **Mint**  
   - Creates new tokens, either to a specified identity or a fixed destination (depending on configuration).  
   - Requires the sender (or group) to have `mint` permissions.

2. **Burn**  
   - Destroys a specified amount of tokens from the sender’s balance.  
   - Can be restricted (i.e., not everyone can burn tokens unless configured).

3. **Transfer**  
   - Moves a given amount of tokens from the sender to a recipient identity.  
   - Optional **notes**:  
     - Public note (visible to everyone)  
     - Shared encrypted note (only sender & recipient can decrypt)  
     - Private encrypted note (only sender can decrypt)

4. **Freeze / Unfreeze**  
   - Freezes an identity’s ability to **send** tokens. This is typically used by regulated tokens (e.g., stablecoins).  
   - Unfreeze removes this restriction.

5. **Destroy Frozen Funds**  
   - If allowed, destroys tokens from a frozen identity’s balance (e.g., blacklisting stolen tokens in stablecoin systems).

6. **Emergency Action (Pause / Unpause)**  
   - Globally pause or unpause an entire token. While paused, no transfers can occur.

7. **Group Actions**  
   - If a token action (e.g., mint) requires multiple signatures, each group member submits the same state transition referencing the **same "action ID.”**  
   - Once enough members (by "power”) have approved, the network finalizes the action.

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

## Access Control: Groups in Depth

- Each group has multiple members, each with a certain integer "power.”  
- The group itself has a "required power” threshold.  
- If the required threshold is 10, you could have:  
  - **Member A**: power 6  
  - **Member B**: power 3  
  - **Member C**: power 2  
- To pass an action requiring 10 points, you would need A + B together (9 does not meet 10), or A + C (8 does not meet 10). So in this example, you’d actually need all three.  

*(This is just an example—actual group configuration is flexible.)*

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
- **Additional Distribution Types**: Some complicated emission patterns (e.g., polynomials, sinusoidal, etc.) might be simplified or removed, depending on real-world usage and developer feedback.  
- **Document Cost in Tokens**: Eventually, creation of certain documents in a data contract could require payment in a specified token (e.g., for ticketing systems where you "redeem” a token to generate a user-specific ticket document).
