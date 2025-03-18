# Token

## Token Overview

## Token State Transition Details

All token transitions include the [token base transition fields](#token-base-transition). Most token transitions (.e.g., [token mint](#token-mint-transition)) require additional fields to provide their functionality.

### Token Base Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_base_transition/v0/mod.rs#L45-L72

```rs
pub struct TokenBaseTransitionV0 {
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "$identity-contract-nonce")
    )]
    pub identity_contract_nonce: IdentityNonce,
    /// ID of the token within the contract
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "$tokenContractPosition")
    )]
    pub token_contract_position: u16,
    /// Data contract ID generated from the data contract's `owner_id` and `entropy`
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "$dataContractId")
    )]
    pub data_contract_id: Identifier,
    /// Token ID generated from the data contract ID and the token position
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "$tokenId")
    )]
    pub token_id: Identifier,
    /// Using group multi party rules for authentication
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub using_group_info: Option<GroupStateTransitionInfo>,
}
```

### Token Burn Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_burn_transition/v0/mod.rs#L22-L38

```rs
pub struct TokenBurnTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "burnAmount")
    )]
    /// How much should we burn
    pub burn_amount: u64,
    /// The public note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "publicNote")
    )]
    pub public_note: Option<String>,
}
```

### Token Claim Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_claim_transition/v0/mod.rs#L18-L26

```rs
pub struct TokenClaimTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    /// The type of distribution we are targeting
    pub distribution_type: TokenDistributionType,
    /// A public note, this will only get saved to the state if we are using a historical contract
    pub public_note: Option<String>,
}
```

### Token Config Update Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_config_update_transition/v0/mod.rs#L19-L27

```rs
pub struct TokenConfigUpdateTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    /// Updated token configuration item
    pub update_token_configuration_item: TokenConfigurationChangeItem,
    /// The public note
    pub public_note: Option<String>,
}
```

### Token Destroy Frozen Funds Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_destroy_frozen_funds_transition/v0/mod.rs#L17-L25

```rs
pub struct TokenDestroyFrozenFundsTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    /// The identity id of the account whose balance should be destroyed
    pub frozen_identity_id: Identifier,
    /// The public note
    pub public_note: Option<String>,
}
```

### Token Emergency Action Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_emergency_action_transition/v0/mod.rs#L16-L24

```rs
pub struct TokenEmergencyActionTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    /// The emergency action
    pub emergency_action: TokenEmergencyAction,
    /// The public note
    pub public_note: Option<String>,
}
```

### Token Freeze Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_freeze_transition/v0/mod.rs#L19-L35

```rs
pub struct TokenFreezeTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    /// The identity that we are freezing
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "frozenIdentityId")
    )]
    pub identity_to_freeze_id: Identifier,
    /// The public note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "publicNote")
    )]
    pub public_note: Option<String>,
}
```

### Token Mint Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_mint_transition/v0/mod.rs#L23-L43

```rs
pub struct TokenMintTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "issuedToIdentityId")
    )]
    /// Who should we issue the token to? If this is not set then we issue to the identity set in
    /// contract settings. If such an operation is allowed.
    pub issued_to_identity_id: Option<Identifier>,

    /// How much should we issue
    pub amount: u64,
    /// The public note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "publicNote")
    )]
    pub public_note: Option<String>,
}
```

### Token Transfer Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_transfer_transition/v0/mod.rs#L30-L61

```rs
pub struct TokenTransferTransitionV0 {
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "$amount")
    )]
    pub amount: u64,
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "recipientId")
    )]
    pub recipient_id: Identifier,
    /// The public note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "publicNote")
    )]
    pub public_note: Option<String>,
    /// An optional shared encrypted note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "sharedEncryptedNote")
    )]
    pub shared_encrypted_note: Option<SharedEncryptedNote>,
    /// An optional private encrypted note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "privateEncryptedNote")
    )]
    pub private_encrypted_note: Option<PrivateEncryptedNote>,
}
```

### Token Unfreeze Transition

https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_unfreeze_transition/v0/mod.rs#L19-L35

```rs
pub struct TokenUnfreezeTransitionV0 {
    /// Document Base Transition
    #[cfg_attr(feature = "state-transition-serde-conversion", serde(flatten))]
    pub base: TokenBaseTransition,
    /// The identity that we are freezing
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "frozenIdentityId")
    )]
    pub frozen_identity_id: Identifier,
    /// The public note
    #[cfg_attr(
        feature = "state-transition-serde-conversion",
        serde(rename = "publicNote")
    )]
    pub public_note: Option<String>,
}
```
