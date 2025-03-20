# Token

## Token Overview

Dash Platform lets developers create and manage tokens (similar to ERC-20 style assets) without writing smart contracts. Tokens leverage [data contracts](./data-contract.md), [state transitions](./state-transition.md), and built-in access control (via data contract groups) to enable flexible token management. All token operations are completed by submitting them to the platform in a [batch state transition](./state-transition.md#batch).

## Token State Transition Details

All token transitions include the [token base transition fields](#token-base-transition). Most token transitions (.e.g., [token mint](#token-mint-transition)) require additional fields to provide their functionality.

### Token Base Transition

The following fields are included in all token transitions:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| $identityContractNonce | unsigned integer | 64 bits | Identity contract nonce |
| $tokenContractPosition | unsigned integer | 16 bits | Position of the token within the contract |
| $dataContractId | array | 32 bytes | Data contract ID [generated](../protocol-ref/data-contract.md#data-contract-id) from the data contract's `ownerId` and `entropy` |
| [$tokenId](#token-id) | array | 32 bytes | Token ID generated from the data contract ID and the token position |
| usingGroupInfo | [GroupStateTransitionInfo object](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/group/mod.rs#L42-L59) | Varies | Optional field indicating group multi-party authentication rules |

Each token transition must comply with the [token base transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_base_transition/v0/mod.rs#L45-L72).

#### Token id

The `$tokenId` is created by double sha256 hashing the token `$dataContractId` and `$tokenContractPosition` with a byte vector of the string "dash_token" as shown in [rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/tokens/mod.rs#L22-L27).

```rust
// From the Rust reference implementation (rs-dpp)
// tokens/mod.rs
pub fn calculate_token_id(contract_id: &[u8; 32], token_pos: TokenContractPosition) -> [u8; 32] {
    let mut bytes = b"dash_token".to_vec();
    bytes.extend_from_slice(contract_id);
    bytes.extend_from_slice(&token_pos.to_be_bytes());
    hash_double(bytes)
}
```

#### Token Transition Action

The token transition actions [defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_transition_action_type.rs#L7-L17) indicate what operation platform should perform with the provided transition data.

| Action | Name | Description |
| :-: | - | - |
| 0 | [Burn](#token-burn-transition) | Permanently remove a specified amount of tokens from circulation |
| 1 | [Mint](#token-mint-transition) | Create new tokens |
| 2 | [Transfer](#token-transfer-transition) | Send tokens from one identity to another |
| 3 | [Freeze](#token-freeze-transition) | Restrict an identity’s ability to transfer or use tokens |
| 4 | [Unfreeze](#token-unfreeze-transition) | Lift a freeze restriction on an identity's tokens |
| 5 | [Destroy Frozen Funds](#token-destroy-frozen-funds-transition) | Remove frozen tokens from an identity's balance |
| 6 | [Claim](#token-claim-transition) | Retrieve tokens based on a specified distribution method |
| 7 | [Emergency Action](#token-emergency-action-transition) | Execute an emergency protocol affecting tokens |
| 8 | [Config Update](#token-config-update-transition) | Modify the configuration settings of a token |

### Token Notes

Some token transitions include optional notes fields. The maximum note length for these fields is [2048 characters](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/tokens/mod.rs#L14).

### Token Burn Transition

The token burn transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| burnAmount | unsigned integer | 64 bits | Number of tokens to be burned |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token burn transition must comply with the [token burn transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_burn_transition/v0/mod.rs#L22-L38).

### Token Mint Transition

The token mint transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| issuedToIdentityId | array | 32 bytes | Optional identity ID receiving the minted tokens. If this is not set then we issue to the identity set in contract settings. |
| amount | unsigned integer | 64 bits | Number of tokens to mint |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token mint transition must comply with the [token mint transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_mint_transition/v0/mod.rs#L23-L43).

### Token Transfer Transition

The token transfer transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| amount | unsigned integer | 64 bits | Number of tokens to transfer |
| recipientId | array | 32 bytes | Identity ID of the recipient |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |
| sharedEncryptedNote | [SharedEncryptedNote object](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/tokens/mod.rs#L15) | [<= 2048 characters](#token-notes) | Optional shared encrypted note |
| privateEncryptedNote | [PrivateEncryptedNote object](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/tokens/mod.rs#L16-L20) | [<= 2048 characters](#token-notes) | Optional private encrypted note |

Each token transfer transition must comply with the [token transfer transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_transfer_transition/v0/mod.rs#L30-L61).

### Token Freeze Transition

The token freeze transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| frozenIdentityId | array | 32 bytes | Identity ID of the account to be frozen |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token freeze transition must comply with the [token freeze transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_freeze_transition/v0/mod.rs#L19-L35).

### Token Unfreeze Transition

The token unfreeze transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| frozenIdentityId | array | 32 bytes | Identity ID of the account to be unfrozen |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token unfreeze transition must comply with the [token unfreeze transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_unfreeze_transition/v0/mod.rs#L19-L35).

### Token Destroy Frozen Funds Transition

The token destroy frozen funds transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| frozenIdentityId | array | 32 bytes | Identity ID of the account whose frozen balance should be destroyed |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token destroy frozen funds transition must comply with the [token destroy frozen funds transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_destroy_frozen_funds_transition/v0/mod.rs#L17-L25).

### Token Claim Transition

The token claim transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| distributionType | [TokenDistributionType enum](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/associated_token/token_distribution_key.rs#L18-L25) | Varies | Type of [token distribution](../explanations/tokens.md#distribution-rules) targeted |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note (only saved for historical contracts) |

Each token claim transition must comply with the [token claim transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_claim_transition/v0/mod.rs#L18-L26).

### Token Emergency Action Transition

The token emergency action transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| emergencyAction | [TokenEmergencyAction enum](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/tokens/emergency_action.rs#L14-L18) | Varies | The emergency action to be executed |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token emergency action transition must comply with the [token emergency action transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_emergency_action_transition/v0/mod.rs#L16-L24).

### Token Config Update Transition

The token config update transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| updateTokenConfigurationItem | [TokenConfigurationChangeItem object](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/associated_token/token_configuration_item.rs#L32-L63) | Varies | Updated token configuration item |
| publicNote | string | [<= 2048 characters](#token-notes) | Optional public note |

Each token configuration update transition must comply with the [token config update transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_config_update_transition/v0/mod.rs#L19-L27).
