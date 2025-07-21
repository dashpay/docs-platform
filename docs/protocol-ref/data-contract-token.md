# Contract Tokens

## Contract Token Overview

The `tokens` object defines each type of token in the data contract. At a minimum, a token must consist of [conventions](#token-conventions) and [change control rules](#token-change-control-rules). Each token must be assigned a unique [position](#assigning-position) within the contract and follow the [token constraints](#token-constraints).

The following example shows a minimal `tokens` object defining a single token with basic conventions:

```json
{
  "tokens": {
    "0": {
      "$format_version": "0",
      "conventions": {
        "$format_version": "0",
        "localizations": {
          "en": {
            "$format_version": "0",
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
| Token registration | [0.1](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L11)| Base fee for adding a token to a contract |
| Perpetual distribution | [0.1](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L12) | Fee for enabling perpetual distribution |
| Pre-programmed distribution | [0.1](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L13) | Fee for enabling pre-programmed distribution |
| Search keyword fee | [0.1](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L14) | Per keyword fee for including search keywords |

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
| `$format_version` | string | Version of the localization format (currently "0") |
| `shouldCapitalize` | boolean | Whether the token name should be capitalized when displayed |
| `singularForm` | string | Singular form of the token name |
| `pluralForm` | string | Plural form of the token name |

```json
"localizations": {
  "en": {
    "$format_version": "0", 
    "shouldCapitalize": true,
    "singularForm": "loyalty-point",
    "pluralForm": "loyalty-points"
  },
  "es": {
    "$format_version": "0",
    "shouldCapitalize": false,
    "singularForm": "punto-de-lealtad", 
    "pluralForm": "puntos-de-lealtad"
  }
}
```

### Decimal Precision

The `decimals` property specifies the number of decimal places for token amounts. This affects how token balances are displayed and calculated. If `decimals` is set to zero, token operations (e.g., mint, transfer) will only allow integer amounts.

```json
"conventions": {
  "$format_version": "0",
  "localizations": { /* ... */ },
  "decimals": 8  // 8 decimal places (default)
}
```

## Token Configuration

Token configuration controls behavioral aspects of token operations, including supply management, operational controls, and security features.

### Supply Management

| Property | Type | Description |
|----------|------|-------------|
| `baseSupply` | unsigned integer | Initial supply of tokens created at contract deployment |
| `maxSupply` | unsigned integer | Maximum number of tokens that can ever exist (null for unlimited) |

### Operational Controls

| Property | Type | Description |
|----------|------|-------------|
| `startAsPaused` | boolean | Whether the token begins in a paused state where tokens cannot be transferred |
| `allowTransferToFrozenBalance` | boolean | Whether transfers to frozen balances are permitted |

### Control Group Management

| Property | Type | Description |
|----------|------|-------------|
| `mainControlGroup` | unsigned integer | Position assigned to the main control group |
| `mainControlGroupCanBeModified` | string | Authorization level for modifying the main control group |

**Example:**

```json
{
  "baseSupply": 1000000,
  "maxSupply": 10000000,
  "startAsPaused": false,
  "allowTransferToFrozenBalance": true,
  "mainControlGroup": null,
  "mainControlGroupCanBeModified": "NoOne"
}
```

## Token Change Control Rules

Change control rules define authorization requirements for modifying various aspects of a token after deployment. These rules specify who can make changes and under what conditions.

### Authorized Parties

Rules can authorize no one, specific identities, or multiparty groups. The complete set of options [defined by DPP](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/change_control_rules/authorized_action_takers.rs#L14-L21) is:

| Authorized Party     | Description |
|----------------------|-------------|
| `NoOne`              | No one is authorized |
| `ContractOwner`      | Only the contract owner is authorized |
| `Identity(Identifier)` | Only an identity is authorized |
| `MainGroup`          | Only the [main control group](../explanations/tokens.md#main-control-group) is authorized |
| `Group(<x>)`         | Only the specific group based in contract position "x" is authorized |

### Change Rule Structure

Each rule consists of the following parameters [defined in DPP](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/change_control_rules/v0/mod.rs) that control its behavior:

| Field | Description |
| - | - |
| `authorized_to`<br>`_make_change` | This is who is authorized to make such a change. Valid values are listed in the [authorized parties table](#authorized-parties). |
| `admin_action_takers` | This is who is authorized to make such a change to the people authorized to make a change. Valid values are listed in the [authorized parties table](#authorized-parties). |
| `changing_authorized`<br>`_action_takers_to`<br>`_no_one_allowed` | Are we allowed to change to `NoOne` in the future (default: false) |
| `changing_admin_action`<br>`_takers_to_no_one_allowed` | Are we allowed to change the admin action takers to `NoOne` in the future (default: false) |
| `self_changing_admin_`<br>`action_takers_allowed` | Can the admin action takers change themselves (default: false) |

**Example**

```json
"<rule_name>": {
  "V0": {
    "authorized_to_make_change": "ContractOwner",
    "admin_action_takers": "NoOne",
    "changing_authorized_action_takers_to_no_one_allowed": false,
    "changing_admin_action_takers_to_no_one_allowed": false,
    "self_changing_admin_action_takers_allowed": false
  }
}
```

### Available Change Rules

Tokens support the following change control rules:

| Rule Name | Description |
|-----------|-------------|
| `conventionsChangeRules` | Controls who can modify token conventions (localization) |
| `maxSupplyChangeRules` | Controls who can modify the maximum supply limit |
| `perpetualDistributionRules` | Controls who can modify perpetual distribution settings (subset of `distributionRules`) |
| `preProgrammedDistribution` | Controls who can modify pre-programmed distribution settings (subset of `distributionRules`) |
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
  "V0": {
    "authorized_to_make_change": "ContractOwner",
    "admin_action_takers": "NoOne",
    "changing_authorized_action_takers_to_no_one_allowed": false,
    "changing_admin_action_takers_to_no_one_allowed": false,
    "self_changing_admin_action_takers_allowed": false
  }
}
```

## Token Distribution Rules

Distribution rules govern how tokens are created, allocated, and priced within the platform. These rules provide flexible mechanisms for token distribution and marketplace integration.

### Distribution Properties

| Property | Type | Description |
|----------|------|-------------|
| `perpetualDistribution` | object | Ongoing distribution mechanism for continuous token allocation |
| `perpetualDistributionRules` | object | Change control rules for perpetual distribution |
| `preProgrammedDistribution` | object | Scheduled distribution events with specific timing and recipients |
| `newTokensDestinationIdentity` | string | Default identity to receive newly minted tokens |
| `newTokensDestinationIdentityRules` | object | Change control rules for destination identity |
| `mintingAllowChoosingDestination` | boolean | Whether minting operations can specify custom destinations |
| `mintingAllowChoosingDestinationRules` | object | Change control rules for destination choice |
| `changeDirectPurchasePricingRules` | object | Change control rules for direct purchase pricing |

### Perpetual Distribution

Perpetual distribution enables ongoing token allocation. The following configuration distributes 100 tokens to the contract owner every 60 minutes (3600000 ms):

```json
"perpetualDistribution": {
  "$format_version": "0",
  "distributionType": {
    "TimeBasedDistribution": {
      "interval": 3600000,
      "function": {
        "FixedAmount": {
          "amount": 100
        }
      }
    }
  },
  "distributionRecipient": "ContractOwner"
}
```

#### Perpetual Distribution Options

A wide variety of emission patterns are provided to cover most common scenarios. The following table summarizes the options and links to further details.

| Name | Description |
| - | - |
| [Fixed Amount](#fixed-amount) | Emits a constant number of tokens per period |
| [Random](#random) | Emits a random amount between `min` and `max`, using a PRF |
| [Step Decreasing Amount](#step-decreasing-amount) | Emits tokens that decrease in discrete steps at fixed intervals |
| [Linear](#linear) | Linear growth/decay with integer or fractional precision |
| [Polynomial](#polynomial) | Polynomial with integer or fractional exponents or coefficients |
| [Exponential](#exponential) | Emits tokens following an exponential function |
| [Logarithmic](#logarithmic) | Slows emission over time |
| [Inverted Logarithmic](#inverted-logarithmic) | Slows emission over time |
| [Stepwise](#stepwise) | Emits constant values within predefined steps |

##### Fixed Amount

Emits a constant (fixed) number of tokens for every period.

- **Formula:** `f(x) = n`
- **Use Case:**
  - When a predictable, unchanging reward is desired.
  - Simplicity and stable emissions.
- **Example:** If `n = 5` tokens per block, then after 3 blocks the total emission is 15 tokens.

##### Random

Emits a random number of tokens within a specified range.

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

- **Formula:** `f(x) = n * (1 - (numerator / denominator))^((x - s) / step_count)`
- **Description:** Reduces token emissions by a fixed percentage at regular intervals. Includes optional start offset and minimum emission floor.
  - `step_count`: number of periods between each step
  - `numerator` and `denominator`: the reduction factor per step
  - `s`: optional start period offset (e.g., start block or time). If not provided, the contract creation start is used.
  - `n`: initial token emission amount
  - `min_value`: optional minimum emission value
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
    - `s`: optional start period offset (defaults to contract creation)
    - `b`: starting emission amount
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
  - `s`: optional start period offset
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

- **Formula:** `f(x) = a * e^(b * x) + c`
- **Description:**
  - `b` > 0 -> rapid growth
  - `b` < 0 -> rapid decay
- **Use Case:** Early contributor boosts or quick emission tapering
- **Example:** f(x) = 100 * e^(-0.693 * x) + 5

##### Logarithmic

Logarithmic growth of token emissions.

- **Formula:** `f(x) = a * log_b(x) + c`
- **Description:** Growth slows as `x` increases
- **Use Case:** Sustainable long-term emission tapering
- **Example:** f(x) = 20 * log_2(x) + 5

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
  - `s`: optional start period offset (defaults to contract creation time if not provided)
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

### Pre-Programmed Distribution

Pre-programmed distribution allows scheduling specific token allocations at predetermined times. The following configuration distributes 3 sets of tokens to the same identity at the defined timestamps:

```json
"preProgrammedDistribution": {
  "$format_version": "0",
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
  "V0": {
    "authorized_to_make_change": "ContractOwner",
    "admin_action_takers": "NoOne",
    "changing_authorized_action_takers_to_no_one_allowed": false,
    "changing_admin_action_takers_to_no_one_allowed": false,
    "self_changing_admin_action_takers_allowed": false
  }
}
```

## Token History Tracking

Token history tracking controls which operations are recorded in Platform's historical records. This provides audit trails and transparency for token operations.

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
  "$format_version": "0",
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
  "$format_version": "0",
  "tradeMode": "NotTradeable",
  "tradeModeChangeRules": {
    "V0": {
      "authorized_to_make_change": "NoOne",
      "admin_action_takers": "NoOne",
      "changing_authorized_action_takers_to_no_one_allowed": false,
      "changing_admin_action_takers_to_no_one_allowed": false,
      "self_changing_admin_action_takers_allowed": false
    }
  }
}
```

## Token Constraints

For performance and security reasons, tokens have the following constraints:

### General Constraints

| Parameter | Value |
|-----------|-------|
| Maximum number of keywords | [50](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/methods/validate_update/v0/mod.rs#L272-L277) |
| Keyword length | [3 to 50 characters](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/methods/validate_update/v0/mod.rs#L279-L287) |
| Description length | [3 to 100 characters](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/methods/validate_update/v0/mod.rs#L312-L323) |
| Maximum note length | [2048 characters](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/tokens/mod.rs#L19) |
| Maximum number of tokens per contract | Only limited by [maximum contract size](./data-contract.md#data-size) |

### Convention Constraints

| Parameter | Value |
|-----------|-------|
| Language code length | [2 to 12 characters](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L97-L101) |
| Token name length (singular) | [3 to 25 characters](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L84-L89) |
|  Token name length (plural)  | [3 to 25 characters](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L90-L95) |
| Decimal places | [0 to 16](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_configuration_convention/methods/validate_localizations/v0/mod.rs#L31-L36) |
| Maximum localization entries | Only limited by [maximum contract size](./data-contract.md#data-size) |

### Supply Constraints

| Parameter | Value |
|-----------|-------|
| Maximum token amount | [2^64 - 1](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/errors/consensus/basic/data_contract/invalid_token_base_supply_error.rs#L12-L16) |

## Example Syntax

This example shows the complete structure of a token definition with all major configuration options:

```json
{
  "tokens": {
    "0": {
      "$format_version": "0",
      "conventions": {
        "$format_version": "0",
        "localizations": {
          "en": {
            "$format_version": "0",
            "shouldCapitalize": true,
            "singularForm": "reward-token",
            "pluralForm": "reward-tokens"
          }
        },
        "decimals": 8
      },
      "conventionsChangeRules": {
        "V0": {
          "authorized_to_make_change": "NoOne",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "baseSupply": 1000000,
      "maxSupply": 10000000,
      "keepsHistory": {
        "$format_version": "0",
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
        "V0": {
          "authorized_to_make_change": "ContractOwner",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "distributionRules": {
        "$format_version": "0",
        "perpetualDistribution": null,
        "perpetualDistributionRules": {
          "V0": {
            "authorized_to_make_change": "NoOne",
            "admin_action_takers": "NoOne",
            "changing_authorized_action_takers_to_no_one_allowed": false,
            "changing_admin_action_takers_to_no_one_allowed": false,
            "self_changing_admin_action_takers_allowed": false
          }
        },
        "preProgrammedDistribution": null,
        "newTokensDestinationIdentity": null,
        "newTokensDestinationIdentityRules": {
          "V0": {
            "authorized_to_make_change": "ContractOwner",
            "admin_action_takers": "NoOne",
            "changing_authorized_action_takers_to_no_one_allowed": false,
            "changing_admin_action_takers_to_no_one_allowed": false,
            "self_changing_admin_action_takers_allowed": false
          }
        },
        "mintingAllowChoosingDestination": true,
        "mintingAllowChoosingDestinationRules": {
          "V0": {
            "authorized_to_make_change": "ContractOwner",
            "admin_action_takers": "NoOne",
            "changing_authorized_action_takers_to_no_one_allowed": false,
            "changing_admin_action_takers_to_no_one_allowed": false,
            "self_changing_admin_action_takers_allowed": false
          }
        },
        "changeDirectPurchasePricingRules": {
          "V0": {
            "authorized_to_make_change": "ContractOwner",
            "admin_action_takers": "NoOne",
            "changing_authorized_action_takers_to_no_one_allowed": false,
            "changing_admin_action_takers_to_no_one_allowed": false,
            "self_changing_admin_action_takers_allowed": false
          }
        }
      },
      "manualMintingRules": {
        "V0": {
          "authorized_to_make_change": "ContractOwner",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "manualBurningRules": {
        "V0": {
          "authorized_to_make_change": "ContractOwner",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "freezeRules": {
        "V0": {
          "authorized_to_make_change": "NoOne",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "unfreezeRules": {
        "V0": {
          "authorized_to_make_change": "NoOne",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "destroyFrozenFundsRules": {
        "V0": {
          "authorized_to_make_change": "NoOne",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "emergencyActionRules": {
        "V0": {
          "authorized_to_make_change": "NoOne",
          "admin_action_takers": "NoOne",
          "changing_authorized_action_takers_to_no_one_allowed": false,
          "changing_admin_action_takers_to_no_one_allowed": false,
          "self_changing_admin_action_takers_allowed": false
        }
      },
      "mainControlGroup": null,
      "mainControlGroupCanBeModified": "NoOne",
      "description": "Reward token for customer loyalty program"
    }
  }
}
```
