# Token 

## Token Overview

## Token State Transition Details

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

### Token Destroy Frozen Funds Transition

### Token Emergency Action Transition

### Token Freeze Transition

### Token Mint Transition

### Token Transfer Transition

### Token Unfreeze Transition
