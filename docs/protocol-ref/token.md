# Token

## Token Overview

Dash Platform lets developers create and manage tokens (similar to ERC-20 style assets) without writing smart contracts. Tokens leverage [data contracts](./data-contract.md), [state transitions](./state-transition.md), and built-in access control (via data contract groups) to enable flexible token management. All token operations are completed by submitting them to the platform in a [batch state transition](./state-transition.md#batch).

## Token Constants and Limits

| Constant | Value | Description |
|----------|-------|-------------|
| `MAX_TOKEN_NOTE_LEN` | 2,048 bytes | Maximum length for public/private notes |
| `document_batch_sub_transition` | 100,000 credits | Minimum fee per token sub-transition |

### Token Fee Payer Options

A document action whose [token cost](data-contract-document.md#token-costs) is paid with a token can shift its gas fees (storage and processing) to the contract owner via the [`GasFeesPaidBy` enum](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/gas_fees_paid_by.rs#L27-L49). The document type's token cost states what the contract owner offers, and the transition's [token payment info](document.md#token-payment-info) states what the document owner asks for:

| Value | Name | Description |
|-------|------|-------------|
| 0 | `DocumentOwner` | Fees paid by the identity submitting the transition |
| 1 | `ContractOwner` | Fees paid by the contract owner |
| 2 | `PreferContractOwner` | Fees paid by the contract owner if possible, otherwise by the document owner |

:::{versionchanged} 5.0.0
Protocol version 14 acts on `GasFeesPaidBy`. Earlier versions carried the value but ignored it, and the signer always paid. A request for `ContractOwner` is rejected unless the document type offers `ContractOwner`, and `PreferContractOwner` falls back to the document owner when the contract does not offer to pay. See the [resolution rules in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/gas_fees_paid_by.rs#L51-L83).
:::

:::{seealso}
For all protocol constants, see [Protocol Constants](protocol-constants.md).
:::

## Token State Transition Details

All token transitions include the [token base transition fields](#token-base-transition). Most token transitions (.e.g., [token mint](#token-mint-transition)) require additional fields to provide their functionality.

### Token Base Transition

The following fields are included in all token transitions:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| $identity-contract-nonce | unsigned integer | 64 bits | Identity contract nonce |
| $tokenContractPosition | unsigned integer | 16 bits | Position of the token within the contract |
| $dataContractId | array | 32 bytes | Data contract ID [generated](../protocol-ref/data-contract.md#data-contract-id) from the data contract's `ownerId` and `entropy` |
| [$tokenId](#token-id) | array | 32 bytes | Token ID generated from the data contract ID and the token position |
| $groupContractPosition<br>$groupActionId<br>$groupActionIsProposer | unsigned integer<br>array<br>boolean | 16 bits<br>32 bytes<br>- | Optional group multi-party authentication info, flattened from [GroupStateTransitionInfo](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/group/mod.rs#L49-L54) so the three fields appear at the top level of the transition. All three are present together or absent together. Since protocol version 13, a transition confirming an existing group action must carry the same `$dataContractId` and `$tokenContractPosition` as the original proposal. |

Each token transition must comply with the [token base transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_base_transition/v0/mod.rs#L45-L63).

#### Token id

The `$tokenId` is created by double sha256 hashing the token `$dataContractId` and `$tokenContractPosition` with a byte vector of the string "dash_token" as shown in [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/mod.rs#L27-L32).

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

The token transition actions [defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_transition_action_type.rs#L15-L69) indicate what operation platform should perform with the provided transition data.

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
| 9 | [Purchase](#token-purchase-transition) | Purchase tokens directly from the token’s owner or distribution pool at the predefined price (transfers tokens to the buyer in exchange for Platform credits) |
| 10 | [Set Purchase Price](#token-set-purchase-price-transition) | Define or update the token’s direct purchase pricing schedule for users (enables or adjusts direct token sales) |
| 11 | [Shield](#token-shield-transition) | Move tokens from the owner's balance into the token's shielded pool (added in 5.0.0) |
| 12 | [Mint To Pool](#token-mint-to-pool-transition) | Mint new tokens directly into the token's shielded pool (added in 5.0.0) |
| 13 | [Burn From Pool](#token-burn-from-pool-transition) | Burn tokens held in the token's shielded pool (added in 5.0.0) |
| 14 | [Claim To Pool](#token-claim-to-pool-transition) | Claim a distribution into the token's shielded pool (added in 5.0.0) |
| 15 | [Direct Purchase To Pool](#token-direct-purchase-to-pool-transition) | Purchase tokens at the direct purchase price and receive them in the token's shielded pool (added in 5.0.0) |
| 16 | [Unshield](#token-unshield-transition) | Move tokens from the token's shielded pool to an identity's balance (added in 5.0.0) |
| 17 | [Shielded Transfer](#token-shielded-transfer-transition) | Transfer tokens within the token's shielded pool (added in 5.0.0) |

:::{note}
The numeric action codes above are for client-side reference ordering only. `TokenTransitionActionType` is not used by the platform backend consensus directly.
:::

### Token Notes

Some token transitions include optional notes fields. The maximum note length for these fields is [2048 bytes](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/mod.rs#L19).

### Token Burn Transition

The token burn transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| burnAmount | unsigned integer | 64 bits | Number of tokens to be burned |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

Each token burn transition must comply with the [token burn transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_burn_transition/v0/mod.rs#L23-L33).

### Token Mint Transition

The token mint transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| issuedToIdentityId | array | 32 bytes | Optional identity ID receiving the minted tokens. If this is not set then we issue to the identity set in contract settings. |
| amount | unsigned integer | 64 bits | Number of tokens to mint |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

Each token mint transition must comply with the [token mint transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_mint_transition/v0/mod.rs#L25-L39).

### Token Transfer Transition

The token transfer transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| $amount | unsigned integer | 64 bits | Number of tokens to transfer. Note the `$` prefix, which is specific to the transfer transition - the mint transition uses a plain `amount` field |
| recipientId | array | 32 bytes | Identity ID of the recipient |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |
| sharedEncryptedNote | [SharedEncryptedNote object](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/mod.rs#L20) | [<= 2048 bytes](#token-notes) | Optional shared encrypted note |
| privateEncryptedNote | [PrivateEncryptedNote object](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/mod.rs#L21-L25) | [<= 2048 bytes](#token-notes) | Optional private encrypted note |

:::{versionadded} 5.0.0
A token whose configuration sets [`transferable: false`](data-contract-token.md#operational-controls) rejects every transfer transition with [`TokenNotTransferableError`](errors.md) (code 40726).
:::

Each token transfer transition must comply with the [token transfer transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_transfer_transition/v0/mod.rs#L39-L55).

### Token Freeze Transition

The token freeze transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| frozenIdentityId | array | 32 bytes | Identity ID of the account to be frozen |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

Each token freeze transition must comply with the [token freeze transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_freeze_transition/v0/mod.rs#L22-L32).

### Token Unfreeze Transition

The token unfreeze transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| frozenIdentityId | array | 32 bytes | Identity ID of the account to be unfrozen |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

Each token unfreeze transition must comply with the [token unfreeze transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_unfreeze_transition/v0/mod.rs#L22-L32).

### Token Destroy Frozen Funds Transition

The token destroy frozen funds transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| frozenIdentityId | array | 32 bytes | Identity ID of the account whose frozen balance should be destroyed |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

Each token destroy frozen funds transition must comply with the [token destroy frozen funds transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_destroy_frozen_funds_transition/v0/mod.rs#L20-L28).

### Token Claim Transition

The token claim transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| distributionType | [TokenDistributionType enum](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_distribution_key.rs#L33-L43) | Varies | Type of [token distribution](../explanations/tokens.md#distribution-rules) targeted (binary `0` = PreProgrammed, `1` = Perpetual, `2` = OncePerIdentity; JSON `"PreProgrammed"`, `"Perpetual"`, or `"OncePerIdentity"`) |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note (only saved for historical contracts) |

:::{versionadded} 5.0.0
Protocol version 14 added the `OncePerIdentity` distribution type for tokens with a [once-per-identity distribution](data-contract-token.md#once-per-identity-distribution). Each identity can claim it once and receives the configured amount. A second claim by the same identity is rejected with [`TokenOncePerIdentityDistributionAlreadyClaimedError`](errors.md) (code 40722). Earlier protocol versions reject a `OncePerIdentity` claim.
:::

Each token claim transition must comply with the [token claim transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_claim_transition/v0/mod.rs#L21-L29).

### Token Emergency Action Transition

The token emergency action transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| emergencyAction | [TokenEmergencyAction enum](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/emergency_action.rs#L20-L24) | Varies | The emergency action to be executed (binary `0` = Pause, `1` = Resume; JSON `"pause"` or `"resume"`) |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

Each token emergency action transition must comply with the [token emergency action transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_emergency_action_transition/v0/mod.rs#L19-L27).

### Token Config Update Transition

The token config update transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| updateTokenConfigurationItem | [TokenConfigurationChangeItem object](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_configuration_item.rs#L44-L83) | Varies | Updated token configuration item |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

:::{versionadded} 5.0.0
`TokenConfigurationChangeItem` adds `MinimumPoolNotesForOutgoing`, `MinimumPoolNotesForOutgoingControlGroup`, and `MinimumPoolNotesForOutgoingAdminGroup`. They change a token's [`minimumPoolNotesForOutgoing`](data-contract-token.md#shielded-pool) and its change control rules, and apply only to a token that has a shielded pool. The new threshold may not exceed 250. `hasShieldedPool` and `transferable` cannot be changed.
:::

Each token configuration update transition must comply with the [token config update transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_config_update_transition/v0/mod.rs#L22-L30).

### Token Set Purchase Price Transition

The token set purchase price transition enables token purchases by setting the token price using a pricing schedule. This can be a single entry (for a fixed price) or multiple entries for tiered pricing. For example, a token might define a price of 100 credits each for a minimum of 1 token, and 90 credits each for a minimum of 10 tokens – allowing a discount for bulk purchases.

Only an identity authorized by the token’s *change direct purchase pricing* rules can successfully execute this transition. On execution, platform will update the token’s current direct purchase price schedule. If direct pricing history is enabled, it will also record the change in the token’s history.

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| price | Optional [TokenPricingSchedule](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/token_pricing_schedule.rs#L41-L57) | Variable | (Optional) Set the fixed price or tiered price. Tiered pricing entries consists of a *minimum token amount* (unsigned 64-bit) and a *price in credits* (unsigned 64-bit) applicable for purchases of that size or greater. The smallest amount tier also defines the *minimum purchasable amount*. If the lowest tier has amount > 1, users cannot buy less than that amount in a single purchase.  If multiple tiers are provided, they should be ordered by ascending minimum amount.<br>**Note:** Setting price to null disables direct purchases for the token. |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note |

The pricing schedule is tagged by a `$type` field naming the form. A single fixed price uses `singlePrice`:

```json
{
  "$type": "singlePrice",
  "price": 100
}
```

Tiered pricing uses `setPrices`, keyed by minimum token amount:

```json
{
  "$type": "setPrices",
  "prices": {
    "1": 100,
    "10": 90
  }
}
```

:::{note}
In human-readable JSON, credit and token amount values above `Number.MAX_SAFE_INTEGER` are serialized as strings. This affects JSON representations only; the bincode serialization used for consensus is unaffected.
:::

Each token set purchase price transition must comply with the [token set purchase price transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_set_price_for_direct_purchase_transition/v0/mod.rs#L21-L32).

### Token Purchase Transition

The token purchase transition mints the requested number of tokens to the purchasing identity. Platform simultaneously deducts the corresponding purchase cost in credits from the buyer’s balance as part of the state transition. The credits are moved from the purchaser to the contract owner by the purchase transition itself; no separate credit transfer is needed. Purchases that would push the total supply above `maxSupply` are rejected. If direct purchase history is enabled for the token, platform will create a record of this sale in the token’s history.

Attempts to purchase tokens when no price is set, when providing insufficient payment, or below the minimum amount will be rejected by platform consensus.

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| tokenCount       | unsigned integer | 64 bits | Number of tokens the user is purchasing. Must be at least the minimum purchase amount defined by the current pricing and cannot exceed any available supply limits. |
| totalAgreedPrice | unsigned integer | 64 bits | Maximum total price (in credits) the purchaser agrees to pay. Must be at least the unit price (or tiered price) times `tokenCount` according to the current pricing schedule. |

Each token purchase transition must comply with the [token direct purchase transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_direct_purchase_transition/v0/mod.rs#L23-L34).

### Token Shielded Pool Transitions

:::{versionadded} 5.0.0
Protocol version 14 added these transitions.
:::

A token whose configuration sets [`hasShieldedPool`](data-contract-token.md#shielded-pool) has its own [shielded pool](shielded-pool.md) that holds that token instead of credits. Holders and issuers move tokens into, within, and out of the pool with the token transitions below. Like every token transition, they are submitted in a [batch](state-transition.md#batch) that the identity signs, and the identity pays the fee in credits, including a proof verification fee for each bundle. Tokens are never used to pay fees. To move pooled tokens without an identity, see the [token shielded pool state transitions](shielded-pool.md#token-shielded-transfer-with-shielded-fee).

Each transition carries an Orchard bundle (`actions`, `anchor`, `proof`, `bindingSignature`) next to the [token base transition](#token-base-transition) fields. The bundle is bound to the transition through the [platform sighash](shielded-pool.md#platform-sighash), using the `extra_data` layout listed for each transition below (`||` is concatenation; amounts are u64 little-endian). Outputs-only bundles (Shield, Mint To Pool, Claim To Pool, Direct Purchase To Pool) have no spends, so their anchor is not checked against the pool. Their `extra_data` starts with a [kind tag](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L36-L49). Bundles that spend notes must use an anchor recorded for the token's pool.

The following rules apply to every token shielded pool transition:

- Structure validation checks the bundle like other shielded bundles: at most [`max_shielded_transition_actions`](protocol-constants.md) actions, correctly sized encrypted notes, a non-empty proof, and a non-zero anchor.
- The token must have a shielded pool ([`TokenShieldedPoolNotEnabledError`](errors.md), code 40723) and must not be paused. Pausing blocks every pool operation, including transitions that move tokens into the pool.
- A bundle that spends notes must use an anchor recorded for the token pool, and its nullifiers must be unspent ([`InvalidAnchorError`](errors.md), [`NullifierAlreadySpentError`](errors.md)). An outputs-only bundle's dummy nullifiers must not repeat or already be recorded in the pool.
- The proof verification fee is charged before the proof is checked, so a batch whose proof fails is still charged and its nonce advances.
- Transitions that move tokens out of the pool to a visible destination (Unshield and Burn From Pool) require the pool to hold at least the token's [`minimumPoolNotesForOutgoing`](data-contract-token.md#shielded-pool) notes ([`InsufficientPoolNotesError`](errors.md), code 40903). Transfers inside the pool are not limited.

#### Token Shield Transition

Move tokens from the batch owner's token balance into the token's shielded pool as new notes. The bundle is outputs-only, and its value balance is `-amount`.

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| amount | unsigned integer | 64 bits | Tokens leaving the owner's balance and entering the pool |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

Sighash `extra_data`: [`0x80` || `tokenId` || `ownerId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L755-L767). `amount` must be from 1 to 2^48 - 1. The owner's token balance must cover `amount`.

Each token shield transition must comply with the [token shield transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_shield_transition/v0/mod.rs#L23-L42). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_shield_transition_action/state_v0/mod.rs).

#### Token Mint To Pool Transition

Mint new tokens directly into the token's shielded pool as new notes. The bundle is outputs-only, and its value balance is `-amount`. The total supply and the pool balance both grow by `amount`. This transition can be submitted as a group action (see the [base transition](#token-base-transition) group fields).

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| amount | unsigned integer | 64 bits | Tokens minted into the pool |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note. In a group action, only the proposer may set it |

Sighash `extra_data`: [`0x81` || `tokenId` || `minterId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L755-L767), where `minterId` is the batch owner, or the proposer of a group action. `amount` must be from 1 to 2^48 - 1. The identity (or group) must be authorized by the token's `manualMintingRules`. The token's `mintingAllowChoosingDestination` must be `true`, because the minter chooses the notes' recipients. The mint must not push the total supply above `maxSupply`.

Each token mint to pool transition must comply with the [token mint to pool transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_mint_to_pool_transition/v0/mod.rs#L23-L43). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_mint_to_pool_transition_action/state_v0/mod.rs).

#### Token Burn From Pool Transition

Spend notes in the token's shielded pool and destroy `amount` tokens. The bundle's value balance is `+amount`, and change returns to the pool as new notes. The total supply and the pool balance both shrink by `amount`. This transition can be submitted as a group action (see the [base transition](#token-base-transition) group fields).

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| amount | unsigned integer | 64 bits | Tokens burned from the pool |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note. In a group action, only the proposer may set it |

Sighash `extra_data`: [`tokenId` || `burnerId` || `amount`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L424-L435), where `burnerId` is the batch owner, or the proposer of a group action. `amount` must be from 1 to 2^48 - 1. The identity (or group) must be authorized by the token's `manualBurningRules`.

Each token burn from pool transition must comply with the [token burn from pool transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_burn_from_pool_transition/v0/mod.rs#L23-L43). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_burn_from_pool_transition_action/state_v0/mod.rs).

#### Token Claim To Pool Transition

Claim a token distribution into the token's shielded pool as new notes instead of into the claimant's balance. The bundle is outputs-only. The claim is resolved the same way as a [token claim](#token-claim-transition).

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| distributionType | [TokenDistributionType enum](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_distribution_key.rs#L33-L43) | Varies | Type of distribution claimed |
| claimUpTo | unsigned integer | 64 bits | (Optional) For a perpetual distribution, the cycle-aligned moment to claim up to. Ignored for pre-programmed distributions |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |
| publicNote | string | [<= 2048 bytes](#token-notes) | Optional public note. In a group action, only the proposer may set it |

Sighash `extra_data`: [`0x82` || `tokenId` || `ownerId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L755-L767). The claim must not push the total supply above `maxSupply`.

Each token claim to pool transition must comply with the [token claim to pool transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_claim_to_pool_transition/v0/mod.rs#L23-L45). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_claim_to_pool_transition_action/state_v0/mod.rs).

#### Token Direct Purchase To Pool Transition

Purchase tokens at the token's [direct purchase price](#token-set-purchase-price-transition) and mint them into the token's shielded pool as new notes. The batch owner pays the price in credits. The bundle is outputs-only, and its value balance is `-tokenCount`.

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| tokenCount | unsigned integer | 64 bits | Number of tokens purchased and minted into the pool |
| totalAgreedPrice | unsigned integer | 64 bits | Maximum total price (in credits) the purchaser agrees to pay |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

Sighash `extra_data`: [`0x83` || `tokenId` || `ownerId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L755-L767). `tokenCount` must be from 1 to 2^48 - 1. The pricing schedule and maximum supply are checked as for a [token purchase](#token-purchase-transition).

Each token direct purchase to pool transition must comply with the [token direct purchase to pool transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_direct_purchase_to_pool_transition/v0/mod.rs#L24-L44). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_direct_purchase_to_pool_transition_action/state_v0/mod.rs).

#### Token Unshield Transition

Spend notes in the token's shielded pool and credit `amount` to the recipient's token balance. The bundle's value balance is `+amount`, and change returns to the pool as new notes.

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| amount | unsigned integer | 64 bits | Tokens leaving the pool and credited to `recipientId` |
| recipientId | array | 32 bytes | Identity ID whose token balance receives `amount` |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

Sighash `extra_data`: [`tokenId` || `ownerId` || `recipientId` || `amount`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L382-L396). `amount` must be from 1 to 2^48 - 1. The recipient identity must exist, and the pool must hold `amount`.

Each token unshield transition must comply with the [token unshield transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_unshield_transition/v0/mod.rs#L24-L45). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_unshield_transition_action/state_v0/mod.rs).

#### Token Shielded Transfer Transition

Spend and recreate notes inside the token's shielded pool. The bundle's value balance is zero, so the pool balance does not change.

This transition extends the [base transition](#token-base-transition) to include the following additional fields:

| Field | Type | Size | Description |
| ----- | ---- | ---- | ----------- |
| actions | array | Varies | Orchard [actions](shielded-pool.md#actions) of the bundle in the token's shielded pool |
| anchor | array of bytes | 32 bytes | [Anchor](shielded-pool.md#anchors) of the token pool's note commitment tree |
| proof | array of bytes | Varies | Halo 2 proof |
| bindingSignature | array of bytes | 64 bytes | RedPallas binding signature |

Sighash `extra_data`: [`tokenId` || `ownerId`](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/shielded/sighash.rs#L646-L656).

Each token shielded transfer transition must comply with the [token shielded transfer transition defined in rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/document/batch_transition/batched_transition/token_shielded_transfer_transition/v0/mod.rs#L22-L38). See the [state validation in rs-drive-abci](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/action_validation/token/token_shielded_transfer_transition_action/state_v0/mod.rs).
