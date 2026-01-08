```{eval-rst}
.. _protocol-ref-constants:
```

:::{attention}
Draft page - work in progress
:::

# Protocol Constants

This page provides a comprehensive reference for all constants, limits, and default values defined in the Dash Platform Protocol implementation (rs-dpp).

## Credit System

Credits are the unit of account for fees on Dash Platform. They are created from Dash locked on the Core blockchain.

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `CREDITS_PER_DUFF` | 1,000 | Credits created per duff (satoshi) | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/balances/credits.rs#L37) |
| `MAX_CREDITS` | 9,223,372,036,854,775,807 | Maximum credit value (i64::MAX) | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/balances/credits.rs) |

**Conversion:** 1 Dash = 100,000,000 duffs = 100,000,000,000 credits

## Fee Constants

### Base Processing Fees

These constants define the base costs for state transition processing.

| Constant | Value (Credits) | Description | Source |
|----------|-----------------|-------------|--------|
| `BASE_ST_PROCESSING_FEE` | 10,000 | Base state transition processing fee | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L3) |
| `DEFAULT_USER_TIP` | 0 | Default priority tip | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L4) |
| `STORAGE_CREDIT_PER_BYTE` | 5,000 | Storage cost per byte | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L5) |
| `PROCESSING_CREDIT_PER_BYTE` | 12 | Processing cost per byte | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L6) |
| `DELETE_BASE_PROCESSING_COST` | 2,000 | Base deletion cost | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L7) |
| `READ_BASE_PROCESSING_COST` | 8,400 | Base read cost | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L8) |
| `WRITE_BASE_PROCESSING_COST` | 6,000 | Base write cost | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L9) |

### Minimum State Transition Fees

These are the minimum fees required for each state transition type.

| State Transition | Min Fee (Credits) | Min Fee (Dash) | Source |
|------------------|-------------------|----------------|--------|
| Credit Transfer | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L4) |
| Credit Transfer to Addresses | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L5) |
| Credit Withdrawal | 400,000,000 | 0.004 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L6) |
| Identity Update | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L7) |
| Document Batch (per sub-transition) | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L8) |
| Contract Create | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L9) |
| Contract Update | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L10) |
| Masternode Vote | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L11) |
| Address Credit Withdrawal | 400,000,000 | 0.004 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L13) |
| Address Funds Transfer (per input) | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L14) |
| Address Funds Transfer (per output) | 6,000,000 | 0.00006 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L15) |
| Identity Create (base) | 2,000,000 | 0.00002 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L16) |
| Identity Key (per key at creation) | 6,500,000 | 0.000065 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L17) |
| Identity TopUp (base) | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L18) |

### Processing Fees

Fees for specific operations during state transition processing.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Fetch identity balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Fetch identity revision | 9,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Fetch identity balance and revision | 15,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Fetch identity key by ID | 9,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Fetch identity token balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Fetch prefunded specialized balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Fetch single identity key | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Network threshold signing | 100,000,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |
| Validate key structure | 50 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs) |

### Storage Fees

Fees related to data storage operations.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Storage disk usage (per byte) | 27,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Storage processing (per byte) | 400 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Storage load (per byte) | 20 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Non-storage load (per byte) | 10 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Storage seek | 2,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs) |

### Signature Verification Fees

Fees for verifying different signature types.

| Key Type | Verification Fee (Credits) | Source |
|----------|----------------------------|--------|
| ECDSA Secp256k1 | 15,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| BLS 12-381 | 300,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| ECDSA Hash160 | 15,500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| BIP13 Script Hash | 300,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| EdDSA 25519 Hash160 | 3,500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs) |

### Hashing Fees

Fees for cryptographic hash operations.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Single SHA256 (base) | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| Blake3 (base) | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| SHA256 + RIPEMD160 (base) | 6,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| SHA256 (per block) | 5,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| Blake3 (per block) | 300 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| RIPEMD160 (per block) | 5,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |

### Data Contract Registration Fees

One-time fees for registering data contracts and their components.

| Component | Fee (Credits) | Fee (Dash) | Source |
|-----------|---------------|------------|--------|
| Base contract registration | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Document type registration | 2,000,000,000 | 0.02 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Non-unique index registration | 1,000,000,000 | 0.01 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Unique index registration | 1,000,000,000 | 0.01 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Contested index registration | 100,000,000,000 | 1.0 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Token registration | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Token perpetual distribution | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Token pre-programmed distribution | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Search keyword (per keyword) | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |

### Vote Resolution Fund Fees

Fees related to contested document voting.

| Fee Type | Amount (Credits) | Amount (Dash) | Source |
|----------|------------------|---------------|--------|
| Contested document vote resolution fund | 20,000,000,000 | 0.2 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs) |
| Contested document unlock fund | 400,000,000,000 | 4.0 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs) |
| Single vote cost | 10,000,000 | 0.0001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs) |

## Size Limits

### System Limits

Maximum sizes for various platform components.

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max state transition size | 20,480 bytes (20 KiB) | Maximum serialized state transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |
| Max contract size | 16,384 bytes (16 KiB) | Maximum serialized data contract | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |
| Max field value size | 5,120 bytes (5 KiB) | Maximum single field value | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |
| Max CBOR encoded length | 16,384 bytes (16 KiB) | Maximum CBOR encoding size | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/util/cbor_serializer.rs#L8) |
| Contract deserialization limit | 15,000 | Maximum contract deserialization | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/serialized_version/mod.rs) |

### Withdrawal Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max withdrawal amount | 50,000,000,000,000 credits | 500 Dash maximum per withdrawal | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |
| Min withdrawal amount | ~181,000 credits | Based on unlock tx size | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/) |
| Withdrawals per block | 4 | Maximum withdrawal transactions | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |
| Min core fee per byte | 1 | Must be Fibonacci number | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/) |

## Identity Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max public keys per identity | 15,000 | Maximum keys an identity can have | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/identity/fields.rs#L7) |
| Max keys in creation | 6 | Keys allowed at identity creation | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs) |
| Identity nonce value filter | 0xFFFFFFFFFF | 40-bit nonce filter | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/identity/identity_nonce.rs) |
| Max missing identity revisions | 24 | Maximum revision gaps | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/identity/identity_nonce.rs) |

### Identity Create Requirements

| Requirement | Value | Description | Source |
|-------------|-------|-------------|--------|
| Min asset lock balance | 200,000 duffs | 0.002 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L20) |
| Min top-up balance | 50,000 duffs | 0.0005 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L21) |
| Min address funding balance | 50,000 duffs | 0.0005 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L22) |
| Min identity funding amount | 200,000 credits | Minimum for address-based creation | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L41) |

## Document and Index Limits

### Document Type Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max indexed string length | 63 characters | Maximum indexable string | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs) |
| Max indexed byte array length | 255 bytes | Maximum indexable byte array | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs) |
| Max indexed array items | 1,024 | Maximum items in indexed array | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs) |
| Max index size | 255 bytes | Maximum total index size | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L38) |
| Default hash size | 32 bytes | Standard hash size | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L35) |
| Default float size | 8 bytes | Standard float size | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L36) |
| Empty tree storage size | 33 bytes | Storage for empty tree | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L37) |
| Storage flags size | 2 bytes | Size of storage flags | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L39) |

### Batch Transition Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max transitions in batch | 1 | Maximum document transitions per batch | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |

## Data Contract Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Initial contract version | 1 | Starting version number | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/mod.rs#L76) |
| Max contract group size | 256 | Maximum members per group | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |
| Max token redemption cycles | 128 | Maximum redemption cycles | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/system_limits/v1.rs) |

## Token Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max token note length | 2,048 characters | Maximum note/memo length | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/tokens/mod.rs#L19) |

### Token Distribution Function Limits

These limits apply to token perpetual distribution function parameters.

| Parameter | Min | Max | Source |
|-----------|-----|-----|--------|
| `MAX_DISTRIBUTION_PARAM` | 1 | 281,474,976,710,655 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L12) |
| `MAX_DISTRIBUTION_CYCLES_PARAM` | 1 | 32,767 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L18) |
| Linear slope A | -255 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial M | -8 | 8 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial N | 0 | 32 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial A | -255 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Log A | -32,766 | 32,767 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential A | 1 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential M | -8 | 8 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential N | 0 | 32 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Default step decreasing max cycles | 128 | 128 | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L20) |

## Epoch and Time Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Genesis epoch index | 0 | First epoch number | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/epoch/mod.rs#L45) |
| Perpetual storage eras | 50 | Number of storage eras (~50 years) | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/epoch/mod.rs#L49) |
| Default epochs per era | 40 | Epochs in each era (~1 year) | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/epoch/mod.rs#L51) |
| Epoch key offset | 256 | Offset for epoch keys | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/block/epoch/mod.rs#L6) |
| Max epoch | 65,279 | Maximum epoch number (u16::MAX - 256) | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/block/epoch/mod.rs#L9) |

## Address Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Address hash size | 20 bytes | Size of address hash | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L22) |
| Platform HRP (mainnet) | "dashevo" | Human-readable prefix | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L85) |
| Platform HRP (testnet) | "tdashevo" | Testnet human-readable prefix | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L87) |
| P2PKH address type | 0 | Pay-to-public-key-hash | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L91) |
| P2SH address type | 1 | Pay-to-script-hash | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L93) |

## Address-Based Transition Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Min output amount | 500,000 credits | Minimum output per address | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L39) |
| Min input amount | 100,000 credits | Minimum input per address | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L40) |
| Max fee strategies | 4 | Maximum fee strategy steps | [rs-platform-version](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v1.rs#L45) |

## Refund Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Min refund limit | 32 bytes | Minimum bytes for refund | [rs-dpp](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/fee/fee_result/refunds.rs#L23) |
