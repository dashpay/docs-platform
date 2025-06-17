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
| Token registration | [0.1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L11)| Base fee for adding a token to a contract |
| Perpetual distribution | [0.1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L12) | Fee for enabling perpetual distribution |
| Pre-programmed distribution | [0.1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L13) | Fee for enabling pre-programmed distribution |
| Search keyword fee | [0.1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L14) | Per keyword fee for including search keywords |

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
| `baseSupply` | unisgned integer | Initial supply of tokens created at contract deployment |
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

### Authorization Types

Rules can authorize no one, specific identities, or multiparty groups. The complete set of options [defined by DPP](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/change_control_rules/authorized_action_takers.rs#L14-L21) is:

| Authorized Party     | Description |
|----------------------|-------------|
| `NoOne`              | No one is authorized |
| `ContractOwner`      | Only the contract owner is authorized |
| `Identity(Identifier)` | Only an identity is authorized |
| `MainGroup`          | Only the [main control group](#main-control-group) is authorized |
| `Group(<x>)`         | Only the specific group based in contract position "x" is authorized |

### Change Rule Structure

Each change rule follows this structure:

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
