# Contract Tokens

## Contract Token Overview

The `tokens` object defines each type of token in the data contract. At a minimum, a token must define [conventions](#token-conventions). All other fields have sensible defaults. Each token must be assigned a unique [position](#assigning-position) within the contract and follow the [token constraints](#token-constraints).

:::{note}
The protocol only requires `conventions`. However, some SDKs (e.g., the JavaScript SDK) may require [change control rules](#token-change-control-rules) to be provided explicitly.
:::

The following example shows a minimal `tokens` object defining a single token with basic conventions:

```json
{
  "tokens": {
    "0": {
      "$formatVersion": "0",
      "conventions": {
        "$formatVersion": "0",
        "localizations": {
          "en": {
            "$formatVersion": "0",
            "shouldCapitalize": false,
            "singularForm": "credit-token",
            "pluralForm": "credit-tokens"
          }
        },
        "decimals": 8
      }
    }
  }
}
```

Tokens may also define [distribution rules](#token-distribution-rules), [history tracking](#token-history-tracking), [marketplace rules](#token-marketplace-rules), and various [configuration options](#token-configuration). Refer to this table for a brief description of the major token sections:

| Feature    | Description                                   |
|------------|-----------------------------------------------|
| [Conventions](#token-conventions) | Display properties including localization, decimals, and naming conventions |
| [Configuration](#token-configuration) | Behavioral settings for token operations, freezing, and emergency actions |
| [Change Control Rules](#token-change-control-rules) | Authorization rules governing who can modify token parameters |
| [Distribution Rules](#token-distribution-rules) | Rules for token distribution, minting destinations, and pricing |
| [History Tracking](#token-history-tracking) | Configuration for recording token operations in Platform history |

### Token Creation Fees

Token creation incurs specific fees based on which token features are used:

| Operation | Fee (DASH)| Description |
|-----------|-----------|-------------|
| Token registration | [0.1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L11)| Base fee for adding a token to a contract |
| Perpetual distribution | [0.1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L12) | Fee for enabling perpetual distribution |
| Pre-programmed distribution | [0.1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L13) | Fee for enabling pre-programmed distribution |
| Search keyword fee | [0.1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L14) | Per keyword fee for including search keywords |

## Assigning Position

Each token in the `tokens` object must be assigned a unique `position` value, with ordering starting at zero and incrementing with each token. The position is used as the key in the tokens object and indicates which token to perform operations on when a contract contains multiple tokens.

```json
{
  "tokens": {
    "0": { /* first token definition */ },
    "1": { /* second token definition */ },
    "2": { /* third token definition */ }
  }
}
```

## Token Conventions

The `conventions` object defines the display and formatting properties of a token. It includes localization settings, decimal precision, and naming conventions that determine how the token is presented to users.

### Localization

The `localizations` object contains language-specific display properties using [ISO 639-1 language codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) as keys. Each localization entry includes:

| Property | Type | Description |
|----------|------|-------------|
| `$formatVersion` | string | Version of the localization format (currently "0") |
| `shouldCapitalize` | boolean | Whether the token name should be capitalized when displayed |
| `singularForm` | string | Singular form of the token name |
| `pluralForm` | string | Plural form of the token name |

```json
"localizations": {
  "en": {
    "$formatVersion": "0", 
    "shouldCapitalize": true,
    "singularForm": "loyalty-point",
    "pluralForm": "loyalty-points"
  },
  "es": {
    "$formatVersion": "0",
    "shouldCapitalize": false,
    "singularForm": "punto-de-lealtad", 
    "pluralForm": "puntos-de-lealtad"
  }
}
```

::::{note}
An English (`en`) localization entry is required. Tokens without an `en` key in the `localizations` map will fail protocol validation with a `MissingDefaultLocalizationError`.
::::

### Decimal Precision

The `decimals` property specifies the number of decimal places for token amounts. This affects how token balances are displayed and calculated. If `decimals` is set to zero, token operations (e.g., mint, transfer) will only allow integer amounts.

```json
"conventions": {
  "$formatVersion": "0",
  "localizations": { /* ... */ },
  "decimals": 8  // 8 decimal places (default)
}
```

## Token Configuration

Token configuration controls behavioral aspects of token operations, including supply management, operational controls, and security features.

### General

| Property | Type | Description |
|----------|------|-------------|
| `description` | string | Optional text describing the token's purpose or behavior |

### Supply Management

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `baseSupply` | unsigned integer | 0 | Initial supply of tokens created at contract deployment |
| `maxSupply` | unsigned integer | null | Maximum number of tokens that can ever exist (null for unlimited) |

### Operational Controls

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `startAsPaused` | boolean | false | Whether the token begins in a paused state where tokens cannot be transferred |
| `allowTransferToFrozenBalance` | boolean | true | Whether minting and transfers to frozen balances are permitted |

### Control Group Management

| Property | Type | Description |
|----------|------|-------------|
| `mainControlGroup` | unsigned integer | Position assigned to the main control group |
| `mainControlGroupCanBeModified` | object | Who is authorized to modify the main control group, given as a `$type` map. Valid values are listed in the [authorized parties table](#authorized-parties). |

**Example:**

```json
{
  "baseSupply": 1000000,
  "maxSupply": 10000000,
  "startAsPaused": false,
  "allowTransferToFrozenBalance": true,
  "mainControlGroup": null,
  "mainControlGroupCanBeModified": {"$type": "noOne"}
}
```

## Token Change Control Rules

Change control rules define authorization requirements for modifying various aspects of a token after deployment. These rules specify who can make changes and under what conditions.

### Authorized Parties

Rules can authorize no one, specific identities, or multiparty groups. The complete set of options [defined by DPP](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/change_control_rules/authorized_action_takers.rs#L28-L35) is:

| Authorized Party | JSON value | Description |
| - | - | - |
| `NoOne` | `{"$type": "noOne"}` | No one is authorized |
| `ContractOwner` | `{"$type": "contractOwner"}` | Only the contract owner is authorized |
| `Identity(Identifier)` | `{"$type": "identity", "identity": "<base58>"}` | Only an identity is authorized |
| `MainGroup` | `{"$type": "mainGroup"}` | Only the [main control group](../explanations/tokens.md#main-control-group) is authorized |
| `Group(<x>)` | `{"$type": "group", "position": <x>}` | Only the specific group based in contract position "x" is authorized |

Authorized parties are encoded as objects carrying a `$type` discriminator. Bare strings such as `"ContractOwner"` are not accepted.

:::{note}
Starting in protocol version 13, group-valued authorized parties must resolve when the contract is registered. `Group(<x>)` requires a group defined at contract position `x`, otherwise registration fails with `GroupPositionDoesNotExistError`. `MainGroup` requires `mainControlGroup` to be set, otherwise registration fails with `MainGroupIsNotDefinedError`. This applies to both `authorizedToMakeChange` and `adminActionTakers` across every change control rule family.

At action time, a group action authorized by `MainGroup` succeeds only when the group submitting it is at the same contract position as the token's configured `mainControlGroup`. An unset `mainControlGroup` authorizes no group, and the action is rejected with `UnauthorizedTokenActionError`.
:::

### Change Rule Structure

Each rule consists of the following parameters [defined in DPP](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/change_control_rules/v0/mod.rs) that control its behavior:

| Field | Description |
| - | - |
| `authorizedTo`<br>`MakeChange` | This is who is authorized to make such a change. Valid values are listed in the [authorized parties table](#authorized-parties). |
| `adminActionTakers` | This is who is authorized to make such a change to the people authorized to make a change. Valid values are listed in the [authorized parties table](#authorized-parties). |
| `changingAuthorized`<br>`ActionTakersTo`<br>`NoOneAllowed` | Are we allowed to change to no one in the future (default: false) |
| `changingAdminAction`<br>`TakersToNoOneAllowed` | Are we allowed to change the admin action takers to no one in the future (default: false) |
| `selfChangingAdmin`<br>`ActionTakersAllowed` | Can the admin action takers change themselves (default: false) |

**Example**

```json
"<rule_name>": {
  "$formatVersion": "0",
  "authorizedToMakeChange": {"$type": "contractOwner"},
  "adminActionTakers": {"$type": "noOne"},
  "changingAuthorizedActionTakersToNoOneAllowed": false,
  "changingAdminActionTakersToNoOneAllowed": false,
  "selfChangingAdminActionTakersAllowed": false
}
```

### Available Change Rules

Tokens support the following change control rules:

| Rule Name | Description |
|-----------|-------------|
| `conventionsChangeRules` | Controls who can modify token conventions (localization) |
| `maxSupplyChangeRules` | Controls who can modify the maximum supply limit |
| `perpetualDistributionRules` | Controls who can modify perpetual distribution settings (subset of `distributionRules`) |
| `newTokensDestinationIdentityRules` | Controls who can change where new tokens are sent  (subset of `distributionRules`)|
| `mintingAllowChoosingDestinationRules` | Controls who can modify minting destination rules  (subset of `distributionRules`)|
| `changeDirectPurchasePricingRules` | Controls who can set direct purchase pricing  (subset of `distributionRules`)|
| `tradeModeChangeRules` | Controls who can modify trade mode rules (subset of `marketplaceRules`) |
| `manualMintingRules` | Controls who can manually mint tokens |
| `manualBurningRules` | Controls who can manually burn tokens |
| `freezeRules` | Controls who can freeze token balances |
| `unfreezeRules` | Controls who can unfreeze token balances |
| `destroyFrozenFundsRules` | Controls who can destroy frozen funds |
| `emergencyActionRules` | Controls who can execute emergency actions |

**Example:**

```json
"manualMintingRules": {
  "$formatVersion": "0",
  "authorizedToMakeChange": {"$type": "contractOwner"},
  "adminActionTakers": {"$type": "noOne"},
  "changingAuthorizedActionTakersToNoOneAllowed": false,
  "changingAdminActionTakersToNoOneAllowed": false,
  "selfChangingAdminActionTakersAllowed": false
}
```

## Token Distribution Rules

Distribution rules govern how tokens are created, allocated, and priced within the platform. These rules provide flexible mechanisms for token distribution and marketplace integration.

### Distribution Properties

| Property | Type | Description |
|----------|------|-------------|
| `perpetualDistribution` | object | Ongoing distribution mechanism for continuous token allocation |
| `perpetualDistributionRules` | object | Change control rules for perpetual distribution |
| `newTokensDestinationIdentity` | string | Default identity to receive newly minted tokens |
| `newTokensDestinationIdentityRules` | object | Change control rules for destination identity |
| `mintingAllowChoosingDestination` | boolean | Whether minting operations can specify custom destinations |
| `mintingAllowChoosingDestinationRules` | object | Change control rules for destination choice |
| `preProgrammedDistribution` | object | Scheduled token allocations at predetermined timestamps |
| `changeDirectPurchasePricingRules` | object | Change control rules for direct purchase pricing |

### Perpetual Distribution

Perpetual distribution enables ongoing token allocation. The following configuration distributes 100 tokens to the contract owner every 60 minutes (3600000 ms):

```json
"perpetualDistribution": {
  "$formatVersion": "0",
  "distributionType": {
    "$type": "timeBasedDistribution",
    "interval": 3600000,
    "function": {
      "$type": "fixedAmount",
      "amount": 100
    }
  },
  "distributionRecipient": {"$type": "contractOwner"}
}
```

#### Distribution Types

The `distributionType` field accepts one of three schedule types:

| Type | JSON `$type` value | Interval Unit | Description |
| - | - | - | - |
| `BlockBasedDistribution` | `blockBasedDistribution` | Block height | Emits tokens every N blocks. By default begins at the block when the data contract is registered. |
| `TimeBasedDistribution` | `timeBasedDistribution` | Milliseconds | Emits tokens every N milliseconds. By default begins at the time of the block when the data contract is registered. |
| `EpochBasedDistribution` | `epochBasedDistribution` | Epochs | Emits tokens every N epochs. By default begins at the epoch of the block when the data contract is registered. Distribution happens at the start of the following epoch. Required when using `EvonodesByParticipation` as the distribution recipient. |

Each type wraps an `interval` (the period length) and a `function` (the emission pattern from the options below). There is no separate `start` field on the distribution type; the schedule begins at contract registration by default and a later start can be set through the function's start offset parameter (`start_step`, `start_moment`, or `start_decreasing_offset`, depending on the function).

The `interval` has a network specific minimum, checked when the contract is registered or updated. Block based intervals must be at least 100 blocks on mainnet (5 on testnet, 2 on devnet, 1 on regtest). Time based intervals must be at least 3,600,000 ms (1 hour) on mainnet (600,000 ms on testnet, 60,000 ms on devnet and regtest) and must be a multiple of 60,000 ms. Epoch based intervals have no minimum.

#### Perpetual Distribution Options

A wide variety of emission patterns are provided to cover most common scenarios. The following table summarizes the options and links to further details.

| Name | JSON `$type` value | Description |
| - | - | - |
| [Fixed Amount](#fixed-amount) | `fixedAmount` | Emits a constant number of tokens per period |
| [Random](#random) | `random` | Emits a random amount between `min` and `max`, using a PRF |
| [Step Decreasing Amount](#step-decreasing-amount) | `stepDecreasingAmount` | Emits tokens that decrease in discrete steps at fixed intervals |
| [Linear](#linear) | `linear` | Linear growth/decay with integer or fractional precision |
| [Polynomial](#polynomial) | `polynomial` | Polynomial with integer or fractional exponents or coefficients |
| [Exponential](#exponential) | `exponential` | Emits tokens following an exponential function |
| [Logarithmic](#logarithmic) | `logarithmic` | Slows emission over time |
| [Inverted Logarithmic](#inverted-logarithmic) | `invertedLogarithmic` | Slows emission over time |
| [Stepwise](#stepwise) | `stepwise` | Emits constant values within predefined steps |

##### Fixed Amount

Emits a constant (fixed) number of tokens for every period.

- **Formula:** `f(x) = n`
- **Use Case:**
  - When a predictable, unchanging reward is desired.
  - Simplicity and stable emissions.
- **Example:** If `n = 5` tokens per block, then after 3 blocks the total emission is 15 tokens.

##### Random

Emits a random number of tokens within a specified range.

:::{note}
The Random distribution function is not supported in the current release. Contract validation rejects it with an `UnsupportedFeatureError`, so a contract using it cannot be registered.
:::

- **Formula**: `f(x) ∈ [min, max]`
  - Constraints:
    - `min` must be ≤ `max`, otherwise the function is invalid.
    - If `min == max`, this behaves like a [Fixed Amount](#fixed-amount) function with a constant emission.
- **Description**
  - This function selects a **random** token emission amount between `min` and `max`.
  - The value is drawn **uniformly** between the bounds.
  - The randomness uses a Pseudo Random Function (PRF) from x.
- **Use Case**
  - **Stochastic Rewards**: Introduces randomness into rewards to incentivize unpredictability.
  - **Lottery-Based Systems**: Used for randomized emissions, such as block rewards with probabilistic payouts.
- **Example**

  Suppose a system emits **between 10 and 100 tokens per period**.

  ```text
  Random { min: 10, max: 100 }
  ```

  | Period (x) | Emitted Tokens (Random) |
  |------------|------------------------|
  | 1          | 27                     |
  | 2          | 94                     |
  | 3          | 63                     |
  | 4          | 12                     |

  - Each period, the function emits a **random number of tokens** between `min = 10` and `max = 100`.
  - Over time, the **average reward trends toward the midpoint** `(min + max) / 2`.

##### Step Decreasing Amount

Emits tokens that decrease in discrete steps at fixed intervals.

- **Formula:** `f(x) = distribution_start_amount * (1 - (decrease_per_interval_numerator / decrease_per_interval_denominator))^((x - start_decreasing_offset) / step_count)`
- **Description:** Reduces token emissions by a fixed percentage at regular intervals.
  - `step_count` (u32): number of periods between each step
  - `decrease_per_interval_numerator` (u16): reduction factor numerator
  - `decrease_per_interval_denominator` (u16): reduction factor denominator
  - `start_decreasing_offset` (optional u64): start period offset. If not provided, the contract creation start is used. Before this offset, `distribution_start_amount` is emitted every interval.
  - `distribution_start_amount` (TokenAmount): initial token emission amount
  - `max_interval_count` (optional u16): maximum number of decreasing intervals. **Defaults to 128 if not set.** After this many cycles, `trailing_distribution_interval_amount` is emitted per interval. When provided, it must be between 2 and 1024 inclusive.
  - `trailing_distribution_interval_amount` (TokenAmount): token emission after all decreasing intervals are exhausted
  - `min_value` (optional u64): minimum emission floor
- **Use Case:** Reward systems with predictable decay—ideal for Bitcoin-style halvings or Dash-style gradual reductions
- **Example:**
  - Bitcoin: 50% reduction every 210,000 blocks  
  - Dash: ~7% reduction every 210,240 blocks

##### Linear

Emits tokens following a linear function that can increase or decrease over time with fractional precision.

- **Formula:** `f(x) = (a * (x - s) / d) + b`

- **Description:** Supports both integer and fractional slopes via `a / d` ratio. Enables precise reward schedules without floating-point rounding errors.  
  - Parameters
    - `a`: slope numerator (positive = increase, negative = decrease)
    - `d`: slope divisor (enables fractional precision)
    - `s` (`start_step`): optional start period offset (defaults to contract creation)
    - `b` (`starting_amount`): starting emission amount
    - `min_value` / `max_value`: optional emission bounds
  - Behavior
    - If `a > 0`, emissions increase linearly over time
    - If `a < 0`, emissions decrease linearly over time
    - If `a = 0`, emissions remain constant at `b`

- **Use Case:** Predictable inflation or deflation, gradual reward scaling, clamped emission schedules

- **Example:**
  - Increasing Linear Emission: `f(x) = (1 * (x - 0) / 1) + 10`
  - Decreasing Linear Emission: `f(x) = (-2 * (x - 0) / 1) + 100`
  - Delayed Start: `f(x) = (5 * (x - 10) / 1) + 50`
  - Clamping Emissions: `f(x) = (2 * (x - 0) / 1) + 50`

##### Polynomial

A polynomial function using fixed-point arithmetic for fractional or integer exponents.

- **Formula:**  
  `f(x) = (a * (x - s + o)^(m / n)) / d + b`

- **Description:**  
  Emits tokens based on a polynomial curve, where the exponent is defined as a fraction (`m / n`). This enables a wide range of growth or decay behaviors—linear, quadratic, root-based, and more—using precise fixed-point logic.  
  Parameters:
  - `a`: coefficient scaling the curve (positive for growth, negative for decay)  
  - `m` and `n`: exponent numerator and denominator, allowing fractional powers (e.g., `m = 1`, `n = 2` → square root)
  - `d`: divisor to scale the result
  - `s` (`start_moment`): optional start period offset
  - `o`: offset inside the exponent input
  - `b`: amount added after the curve is computed
  - `min_value` / `max_value`: optional boundaries to clamp emissions

- **Use Case:**  
  - **Accelerating Growth:** Use `a > 0` and `m > 1` for quadratic/cubic growth  
  - **Diminishing Emissions:** Use `a < 0` and fractional exponents for decaying curves  
  - **Root-based Models:** Use `m = 1`, `n > 1` to slow down early growth  
  - **Flexibility:** Fine-tune emission behavior with high control over shape

- **Example:**
  - Increasing Polynomial Growth: `f(x) = (2 * (x - s + o)^2) / d + 10`
  - Decreasing Polynomial Decay: `f(x) = (5 * (x - s + o)^(-1)) / d + 10`
  - Inverted Growth → Decreasing Over Time: `f(x) = (-3 * (x - s + o)^2) / d + 50`
  - Inverted Decay → Slowing Increase: `f(x) = (-10 * (x - s + o)^(-2)) / d + 50`

##### Exponential

Emits tokens following an exponential function.

- **Formula:** `f(x) = (a * e^(m * (x - s + o) / n)) / d + b`
- **Description:** Exponential growth or decay depending on parameter signs
- **Use Case:** Early contributor boosts or quick emission tapering

##### Logarithmic

Logarithmic growth of token emissions.

- **Formula:** `f(x) = (a * ln(m * (x - s + o) / n)) / d + b`
- **Description:** Growth slows as `x` increases (uses natural log)
- **Use Case:** Sustainable long-term emission tapering

##### Inverted Logarithmic

Emits tokens following an inverted logarithmic decay curve.

- **Formula:**  
  `f(x) = (a * log(n / (m * (x - s + o)))) / d + b`

- **Description:**  
  Emits a high number of tokens initially, with emissions decreasing rapidly at first, then slowing over time. Useful when early adoption or front-loaded incentives are desired.  
  Parameters:
  - `a`: scaling factor for the log term
  - `d`: divisor to scale the final result
  - `m` and `n`: Control the logarithmic inversion
  - `o`: offset applied inside the logarithm
  - `s` (`start_moment`): optional start period offset (defaults to contract creation time if not provided)
  - `b`: offset added after scaling
  - `min_value` / `max_value`: optional bounds to constrain emissions

- **Use Case:**  
  - **Gradual Decay of Rewards**: Prioritize early users with higher emissions that reduce over time  
  - **Resource Draining / Controlled Burn**: Designed for token models where supply tapers gradually  
  - **Airdrops & Grants**: Rewards diminish for late claimants, encouraging early participation

- **Example:**
  - `f(x) = (1000 * log(5000 / (5 * (x - 1000)))) / 10 + 10`
  - Sample outputs:

    | Period (x) | Emission (f(x)) |
    |------------|----------------|
    | 1000       | 500 tokens     |
    | 1500       | 230 tokens     |
    | 2000       | 150 tokens     |
    | 5000       | 50 tokens      |
    | 10,000     | 20 tokens      |
    | 50,000     | 10 tokens      |

  - Starts high and decays gradually without hitting zero too fast

##### Stepwise

Emits tokens in fixed amounts for specific intervals.

- **Description:** Emissions remain constant within each step
- **Use Case:** Adjust rewards at specific milestones
- **Example:** 100 tokens per block for first 1000 blocks, then 50 tokens thereafter

:::{note}
Starting with protocol version 14 (Dash Platform 4.2.0), the logarithmic, inverted logarithmic, exponential, and polynomial functions are evaluated with a fixed portable math library so every node computes the same reward. A client that predicts rewards with its own platform's math library may differ from the consensus amount by one unit on boundary inputs.
:::

### Pre-Programmed Distribution

Pre-programmed distribution allows scheduling specific token allocations at predetermined times. The following configuration distributes 3 sets of tokens to the same identity at the defined timestamps:

```json
"preProgrammedDistribution": {
  "$formatVersion": "0",
  "distributions": {
    "1749662152621": {
      "2yZbE3TAZAhLwNVQk7JMUUuBXgrVt1NG172PGjeUfjUo": 100
    },
    "1749665692621": {
      "2yZbE3TAZAhLwNVQk7JMUUuBXgrVt1NG172PGjeUfjUo": 1000
    },
    "1781198092621": {
      "2yZbE3TAZAhLwNVQk7JMUUuBXgrVt1NG172PGjeUfjUo": 1000000
    }
  }
}
```

### Direct Purchase Pricing

Direct purchase pricing enables tokens to be [purchased directly using Platform](../explanations/tokens.md#direct-purchase):

```json
"changeDirectPurchasePricingRules": {
  "$formatVersion": "0",
  "authorizedToMakeChange": {"$type": "contractOwner"},
  "adminActionTakers": {"$type": "noOne"},
  "changingAuthorizedActionTakersToNoOneAllowed": false,
  "changingAdminActionTakersToNoOneAllowed": false,
  "selfChangingAdminActionTakersAllowed": false
}
```

## Token History Tracking

Token history tracking controls which operations are recorded in Platform's historical records. This provides audit trails and transparency for token operations.

The properties below are token-level and are nested under the token's `keepsHistory` object. Document types have a separate set of [document history flags](./data-contract-document.md#document-history-flags) set at the document type root, including a distinct `keepsTransferHistory` flag that defaults to false and records into the document history system contract.

### History Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `keepsTransferHistory` | boolean | true | Record all token transfers |
| `keepsFreezingHistory` | boolean | true | Record freeze/unfreeze operations |
| `keepsMintingHistory` | boolean | true | Record token minting events |
| `keepsBurningHistory` | boolean | true | Record token burning events |
| `keepsDirectPricingHistory` | boolean | true | Record direct purchase price changes |
| `keepsDirectPurchaseHistory` | boolean | true | Record direct purchase transactions |

**Example:**

```json
"keepsHistory": {
  "$formatVersion": "0",
  "keepsTransferHistory": true,
  "keepsFreezingHistory": true,
  "keepsMintingHistory": true,
  "keepsBurningHistory": true,
  "keepsDirectPricingHistory": true,
  "keepsDirectPurchaseHistory": false
}
```

## Token Marketplace Rules

Marketplace rules define how tokens can be traded within Platform's built-in marketplace system.

### Trade Modes

| Mode | Description |
|------|-------------|
| `NotTradeable` | Token cannot be traded on the marketplace |

**Example:**

```json
"marketplaceRules": {
  "$formatVersion": "0",
  "tradeMode": "NotTradeable",
  "tradeModeChangeRules": {
    "$formatVersion": "0",
    "authorizedToMakeChange": {"$type": "noOne"},
    "adminActionTakers": {"$type": "noOne"},
    "changingAuthorizedActionTakersToNoOneAllowed": false,
    "changingAdminActionTakersToNoOneAllowed": false,
    "selfChangingAdminActionTakersAllowed": false
  }
}
```

## Token Distribution Function Parameters

The distribution functions use the following parameters defined across various implementations:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `a` | integer | - | Coefficient/scaling factor |
| `b` | integer | - | Base offset or constant term |
| `d` | integer | 1 | Divisor for precision control |
| `m` | integer | - | Exponent numerator |
| `n` | integer | 1 | Exponent denominator |
| `o` | integer | 0 | Offset inside function input |
| `s` | integer | 0 | Start period offset |
| `min_value` | integer | - | Minimum emission bound |
| `max_value` | integer | - | Maximum emission bound |
| `step_count` | integer | - | Periods between steps |
| `numerator` | integer | - | Reduction factor numerator |
| `denominator` | integer | - | Reduction factor denominator |
| `interval` | integer | - | Period length; unit depends on the distribution type (blocks, milliseconds, or epochs) |

:::{note}
Parameter sign types vary by function: `a` is unsigned (u64) for `Exponential` but signed (i64) for all other functions. `m` is unsigned (u64) for `Logarithmic` and `InvertedLogarithmic` but signed (i64) for `Polynomial` and `Exponential`.

The **Default** column shows typical values rather than code-enforced defaults. In the underlying structs, `a`, `b`, `d`, `m`, `n`, and `o` are required fields with no default — they must be supplied for the functions that use them. Only the start offset (`s`) and the emission bounds (`min_value`, `max_value`) are optional; the start offset defaults to contract registration.
:::

### Parameter Bounds

Contract registration validates each function's parameters. Where a bound applies, the largest allowed value is 281,474,976,710,655 (2^48 - 1); this caps the emitted amounts, the start offset (`s`), the offset `o` (as an absolute value), `max_value`, and the constant term `b` for the exponential, logarithmic, and inverted logarithmic functions. Divisors (`d`, `n`, `decrease_per_interval_denominator`, `step_count`) may not be zero, and `min_value` may not exceed `max_value`.

| Function | Enforced bounds |
| - | - |
| `fixedAmount` | `amount` from 1 to 2^48 - 1 |
| `stepDecreasingAmount` | `distribution_start_amount` from 1 to 2^48 - 1 and at least `min_value`; `trailing_distribution_interval_amount` <= `distribution_start_amount`; `decrease_per_interval_numerator` > 0 and < `decrease_per_interval_denominator`; `max_interval_count` from 2 to 1024 when set |
| `stepwise` | at least 2 steps |
| `linear` | `a` from -255 to 256, not 0 |
| `polynomial` | `a` from -32766 to 32767, not 0; `m` from -8 to 8, not 0; `n` from 1 to 32; `n` may not equal `m` when `m` > 0 |
| `exponential` | `a` from 1 to 256; `m` from -8 to 8, not 0; `n` from 1 to 32; `max_value` required when `m` > 0 |
| `logarithmic` | `a` from -32766 to 32767, not 0; `m` from 1 to 2^48 - 1; `(x - s + o)` must be greater than 0 at the start |
| `invertedLogarithmic` | `a` from -32766 to 32767, not 0; `m` greater than 0; `n` greater than 0; `(x - s + o)` must be greater than 0 at the start |

### Distribution Recipients

| Recipient | JSON value | Description |
| - | - | - |
| `ContractOwner` | `{"$type": "contractOwner"}` | Tokens sent to the contract owner |
| `Identity(Identifier)` | `{"$type": "identity", "identity": "<base58>"}` | Tokens sent to a specific identity |
| `EvonodesByParticipation` | `{"$type": "evonodesByParticipation"}` | Tokens distributed to evonodes proportional to their participation (only valid with `EpochBasedDistribution`) |

:::{seealso}
For all protocol constants, see [Protocol Constants](protocol-constants.md).
:::

## Token Constraints

For performance and security reasons, tokens have the following constraints:

### General Constraints

The keyword and description limits below apply to the data contract that holds the tokens, not to each token.

| Parameter | Value |
|-----------|-------|
| Maximum number of keywords | [50](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/methods/validate_update/common/mod.rs#L329-L335) |
| Keyword length | [3 to 50 bytes](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/methods/validate_update/common/mod.rs#L340-L345) |
| Description length | [3 to 100 characters](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/methods/validate_update/common/mod.rs#L379-L386) |
| Maximum note length | [2048 bytes](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/tokens/mod.rs#L19) |
| Maximum number of tokens per contract | Only limited by [maximum contract size](./data-contract.md#data-size) |

### Convention Constraints

| Parameter | Value |
|-----------|-------|
| Language code length | [2 to 12 characters](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L97-L101) |
| Token name length (singular) | [3 to 25 characters](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L84-L89) |
|  Token name length (plural)  | [3 to 25 characters](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L90-L95) |
| Decimal places | [0 to 16](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L31-L36) |
| Maximum localization entries | Only limited by [maximum contract size](./data-contract.md#data-size) |

### Supply Constraints

| Parameter | Value |
|-----------|-------|
| Maximum token amount | [i64::MAX (2^63 - 1 = 9,223,372,036,854,775,807)](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/errors/consensus/basic/data_contract/invalid_token_base_supply_error.rs#L24-L28) |

## Example Syntax

This example shows the complete structure of a token definition with all major configuration options:

```json
{
  "tokens": {
    "0": {
      "$formatVersion": "0",
      "conventions": {
        "$formatVersion": "0",
        "localizations": {
          "en": {
            "$formatVersion": "0",
            "shouldCapitalize": true,
            "singularForm": "reward-token",
            "pluralForm": "reward-tokens"
          }
        },
        "decimals": 8
      },
      "conventionsChangeRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "noOne"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "baseSupply": 1000000,
      "maxSupply": 10000000,
      "keepsHistory": {
        "$formatVersion": "0",
        "keepsTransferHistory": true,
        "keepsFreezingHistory": true,
        "keepsMintingHistory": true,
        "keepsBurningHistory": true,
        "keepsDirectPricingHistory": true,
        "keepsDirectPurchaseHistory": true
      },
      "startAsPaused": false,
      "allowTransferToFrozenBalance": true,
      "maxSupplyChangeRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "contractOwner"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "distributionRules": {
        "$formatVersion": "0",
        "perpetualDistribution": null,
        "perpetualDistributionRules": {
          "$formatVersion": "0",
          "authorizedToMakeChange": {"$type": "noOne"},
          "adminActionTakers": {"$type": "noOne"},
          "changingAuthorizedActionTakersToNoOneAllowed": false,
          "changingAdminActionTakersToNoOneAllowed": false,
          "selfChangingAdminActionTakersAllowed": false
        },
        "preProgrammedDistribution": null,
        "newTokensDestinationIdentity": null,
        "newTokensDestinationIdentityRules": {
          "$formatVersion": "0",
          "authorizedToMakeChange": {"$type": "contractOwner"},
          "adminActionTakers": {"$type": "noOne"},
          "changingAuthorizedActionTakersToNoOneAllowed": false,
          "changingAdminActionTakersToNoOneAllowed": false,
          "selfChangingAdminActionTakersAllowed": false
        },
        "mintingAllowChoosingDestination": true,
        "mintingAllowChoosingDestinationRules": {
          "$formatVersion": "0",
          "authorizedToMakeChange": {"$type": "contractOwner"},
          "adminActionTakers": {"$type": "noOne"},
          "changingAuthorizedActionTakersToNoOneAllowed": false,
          "changingAdminActionTakersToNoOneAllowed": false,
          "selfChangingAdminActionTakersAllowed": false
        },
        "changeDirectPurchasePricingRules": {
          "$formatVersion": "0",
          "authorizedToMakeChange": {"$type": "contractOwner"},
          "adminActionTakers": {"$type": "noOne"},
          "changingAuthorizedActionTakersToNoOneAllowed": false,
          "changingAdminActionTakersToNoOneAllowed": false,
          "selfChangingAdminActionTakersAllowed": false
        }
      },
      "marketplaceRules": {
        "$formatVersion": "0",
        "tradeMode": "NotTradeable",
        "tradeModeChangeRules": {
          "$formatVersion": "0",
          "authorizedToMakeChange": {"$type": "noOne"},
          "adminActionTakers": {"$type": "noOne"},
          "changingAuthorizedActionTakersToNoOneAllowed": false,
          "changingAdminActionTakersToNoOneAllowed": false,
          "selfChangingAdminActionTakersAllowed": false
        }
      },
      "manualMintingRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "contractOwner"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "manualBurningRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "contractOwner"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "freezeRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "noOne"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "unfreezeRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "noOne"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "destroyFrozenFundsRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "noOne"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "emergencyActionRules": {
        "$formatVersion": "0",
        "authorizedToMakeChange": {"$type": "noOne"},
        "adminActionTakers": {"$type": "noOne"},
        "changingAuthorizedActionTakersToNoOneAllowed": false,
        "changingAdminActionTakersToNoOneAllowed": false,
        "selfChangingAdminActionTakersAllowed": false
      },
      "mainControlGroup": null,
      "mainControlGroupCanBeModified": {"$type": "noOne"},
      "description": "Reward token for customer loyalty program"
    }
  }
}
```
