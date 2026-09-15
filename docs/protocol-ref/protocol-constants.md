```{eval-rst}
.. _protocol-ref-constants:
```

# Protocol Constants

This page provides a comprehensive reference for all constants, limits, and default values defined in the Dash Platform Protocol implementation (rs-dpp).

## System Limits

Maximum sizes and limits for various platform components.

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max contract size | 16,384 bytes (16 KiB) | Maximum serialized data contract | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L10) |
| Max field value size | 5,120 bytes (5 KiB) | Maximum single field value | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L11) |
| Max document value depth | 256 nested containers | Maximum nesting depth within a document property value (protocol version 13 and later; unbounded earlier) | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L14) |
| Max state transition size | 20,480 bytes (20 KiB) | Maximum serialized state transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L15) |
| Max transitions in documents batch | 1 | Maximum document transitions per batch | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L18) |
| Withdrawals per block | 4 | Maximum withdrawal transactions per block | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L19) |
| Retry signing expired withdrawals per block | 1 | Max expired withdrawal retries per block | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L20) |
| Max withdrawal amount | 50,000,000,000,000 credits | 500 Dash maximum per withdrawal | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L21) |
| Daily withdrawal limit | Protocol versions 8-13: 200,000,000,000,000 credits (2000 Dash)<br>Protocol version 14+: 15% of the credits Platform held one day earlier, with a 500-Dash floor and 4000-Dash cap | The relative limit added in 4.2.0 is `min(max(day-old total × 15%, max withdrawal amount), 4000 Dash)`. Until a full day of credit history is available after activation, the previous 2000-Dash limit remains in effect. | [v8-v13](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/withdrawal/daily_withdrawal_limit/v1/mod.rs), [v14+](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/withdrawal/daily_withdrawal_limit/v2/mod.rs) |
| Max contract group size | 256 | Maximum members per group | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L26) |
| Max token redemption cycles | 128 | Maximum redemption cycles | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L27) |
| Max shielded transition actions | 16 | Consensus cap on [actions](shielded-pool.md#actions) per shielded transition. The effective limit is 6 - the Halo 2 proof grows ~2,681 bytes per action, so larger transitions exceed the max state transition size | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L35) |
| Max time-range overlap factor | 24 | **Added in 4.2.0.** Maximum `range / step` for a [timeRange](data-contract-document.md#document-indices) index, so at most 24 windows overlap at any timestamp | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L65) |
| Max time-range TTL | 604,800 seconds (1 week) | **Added in 4.2.0.** Maximum `ttl` a [timeRange](data-contract-document.md#document-indices) index may declare | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L66) |
| Min time-range TTL drop operations per write | 32 | **Added in 4.2.0.** Minimum expired-entry cleanup operations Drive performs on each write into a `ttl` index | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L67) |
| Core dust relay fee | 3,000 duffs/kB | **Added in 4.2.0.** Used to compute the Core dust threshold of a withdrawal's output script (546 duffs for P2PKH). An expired withdrawal whose whole amount is below it is marked `FAILED` instead of being re-signed | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L54) |
| Min GroveDB proof envelope version | 1 | **Added in 4.2.0.** Clients verifying with protocol version 14 tables reject the legacy V0 proof envelope | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L68) |
| Max CBOR encoded length | 16,384 bytes (16 KiB) | Maximum CBOR encoding size (defined as `MAX_ENCODED_KBYTE_LENGTH = 16` kibibytes) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/util/cbor_serializer.rs#L8) |
| Contract deserialization limit | 15,000 | Maximum contract deserialization | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/serialized_version/mod.rs#L40) |

## Credit System

Credits are the unit of account for fees on Dash Platform. They are created from Dash locked on the Core blockchain.

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `CREDITS_PER_DUFF` | 1,000 | Credits created per duff (satoshi) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/balances/credits.rs#L43) |
| `MAX_CREDITS` | 9,223,372,036,854,775,807 | Maximum credit value (i64::MAX) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/balances/credits.rs#L41) |

**Conversion:** 1 Dash = 100,000,000 duffs = 100,000,000,000 credits

## Protocol Fees

### Base Processing

These constants define the base costs for state transition processing.

| Constant | Value (Credits) | Description | Source |
|----------|-----------------|-------------|--------|
| `BASE_ST_PROCESSING_FEE` | 10,000 | Base state transition processing fee | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L3) |
| `DEFAULT_USER_TIP` | 0 | Default priority tip | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L4) |
| `STORAGE_CREDIT_PER_BYTE` | 5,000 | Storage cost per byte | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L5) |
| `PROCESSING_CREDIT_PER_BYTE` | 12 | Processing cost per byte | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L6) |
| `DELETE_BASE_PROCESSING_COST` | 2,000 | Base deletion cost | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L7) |
| `READ_BASE_PROCESSING_COST` | 8,400 | Base read cost | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L8) |
| `WRITE_BASE_PROCESSING_COST` | 6,000 | Base write cost | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/default_costs/constants.rs#L9) |

### State Transition Pricing

These constants define minimum values required for a state transition to be considered valid.

| State Transition | Min Fee (Credits) | Min Fee (Dash) | Source |
|------------------|-------------------|----------------|--------|
| Credit Transfer | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L4) |
| Credit Transfer to Addresses | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L5) |
| Credit Withdrawal | 400,000,000 | 0.004 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L6) |
| Identity Update | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L7) |
| Document Batch (per sub-transition) | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L8) |
| Contract Create | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L9) |
| Contract Update | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L10) |
| Masternode Vote | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L11) |
| Address Credit Withdrawal | 400,000,000 | 0.004 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L13) |
| Address Funds Transfer (per input) | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L14) |
| Address Funds Transfer (per output) | 6,000,000 | 0.00006 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L15) |
| Identity Create (base) | 2,000,000 | 0.00002 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L16) |
| Identity Key (per key at creation) | 6,500,000 | 0.000065 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L17) |
| Identity TopUp (base) | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L18) |

### Execution and Resource Pricing

These fees meter execution and resource usage. They do not affect validity, but determine total cost.

#### Processing

Fees for specific operations during state transition processing.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Fetch identity balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L4) |
| Fetch identity revision | 9,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L5) |
| Fetch identity balance and revision | 15,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L6) |
| Fetch identity key by ID | 9,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L7) |
| Fetch identity token balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L8) |
| Fetch prefunded specialized balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L9) |
| Fetch key with type, nonce and balance | 12,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L10) |
| Fetch single identity key | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L11) |
| Network threshold signing | 100,000,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L12) |
| Validate key structure | 50 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/processing/v1.rs#L13) |

#### Storage

Fees related to data storage operations.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Storage disk usage (per byte) | 27,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Storage processing (per byte) | 400 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Storage load (per byte) | 20 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Non-storage load (per byte) | 10 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| Storage seek | 2,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/storage/v1.rs) |
| TTL ephemeral disk usage (per byte) | 270 | **Added in 4.2.0.** Charged as processing for bytes written under a [timeRange `ttl`](data-contract-document.md#document-indices) index instead of the storage rate; not refunded on removal. [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/storage/v1.rs#L23) |

#### Cryptographic Operations

##### Signature Verification

Fees for verifying different signature types.

| Key Type | Verification Fee (Credits) | Source |
|----------|----------------------------|--------|
| ECDSA Secp256k1 | 15,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| BLS 12-381 | 300,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| ECDSA Hash160 | 15,500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| BIP13 Script Hash | 300,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/signature/v1.rs) |
| EdDSA 25519 Hash160 | 3,500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/signature/v1.rs) |

##### Hashing

Fees for cryptographic hash operations.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Single SHA256 (base) | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| Blake3 (base) | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| SHA256 + RIPEMD160 (base) | 6,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| SHA256 (per block) | 5,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| Blake3 (per block) | 300 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| RIPEMD160 (per block) | 5,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |
| Sinsemilla (base) | 40,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/hashing/v1.rs) |

#### Data Contract Validation

Fees for validating data contract structure during state transition processing.

| Fee Type | Amount (Credits) | Source |
|----------|------------------|--------|
| Document type base fee | 500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L5) |
| Schema size fee (per byte) | 10 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L6) |
| Per property fee | 40 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L7) |
| Non-unique index base fee | 50 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L8) |
| Non-unique index per property fee | 30 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L9) |
| Unique index base fee | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L10) |
| Unique index per property fee | 60 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L11) |

### Voting

Fees related to contested document voting.

| Fee Type | Amount (Credits) | Amount (Dash) | Source |
|----------|------------------|---------------|--------|
| Contested document vote resolution fund | **Updated in 4.2.0.**<br>Through protocol version 13: 20,000,000,000<br>Protocol version 14+: 10,000,000,000 | 0.2<br>0.1 | [through v13](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs), [v14+](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v2.rs#L6) |
| Contested document unlock fund | 400,000,000,000 | 4.0 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs) |
| Single vote cost | 10,000,000 | 0.0001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs) |

## Identity Model

### Identity Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max public keys per identity | 15,000 | Maximum keys an identity can have | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/identity/fields.rs#L7) |
| Max keys in creation | 6 | Keys allowed at identity creation | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L18) |
| Identity nonce value filter | 0xFFFFFFFFFF | 40-bit nonce filter | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/identity/identity_nonce.rs#L15) |
| Max missing identity revisions | 24 | Maximum revision gaps | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/identity/identity_nonce.rs#L17) |

### Identity Create Fees

| Requirement | Value | Description | Source |
|-------------|-------|-------------|--------|
| Min asset lock balance | 200,000 duffs | 0.002 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L20) |
| Min top-up balance | 50,000 duffs | 0.0005 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L21) |
| Min address funding balance | 50,000 duffs | 0.0005 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L22) |
| Min identity funding amount | 200,000 credits | Minimum for address-based creation | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L42) |
| Max asset-lock transaction inputs | 100 | Maximum Core inputs in an asset-lock transaction used to fund an identity or top-up (introduced in protocol v3 to prevent stuck funds; v1/v2 had no effective limit) | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L25) |

## Document & Data Contract Model

### Document and Index Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max indexed string length | 63 characters | Maximum indexable string | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L28) |
| Max indexed byte array length | 255 bytes | Maximum indexable byte array | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L29) |
| Max indexed array items | 1,024 | Maximum items in indexed array | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L30) |
| Max index size | 255 bytes | Maximum total index size | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L42) |
| Default hash size | 32 bytes | Standard hash size | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L39) |
| Default float size | 8 bytes | Standard float size | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L40) |
| Empty tree storage size | 33 bytes | Storage for empty tree | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L41) |
| Storage flags size | 2 bytes | Size of storage flags | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L43) |
| Contract version stamp size | 5 bytes | **Added in 4.2.0.** Extra bytes document serialization format 3 adds to the estimated document size | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L46) |

### Data Contract Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Initial contract version | 1 | Starting version number | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/mod.rs#L80) |

### Data Contract Registration Fees

One-time fees for registering data contracts and their components.

| Component | Fee (Credits) | Fee (Dash) | Source |
|-----------|---------------|------------|--------|
| Base contract registration | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Document type registration | 2,000,000,000 | 0.02 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Non-unique index registration | 1,000,000,000 | 0.01 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Unique index registration | 1,000,000,000 | 0.01 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Contested index registration | 100,000,000,000 | 1.0 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Token registration | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Token perpetual distribution | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Token pre-programmed distribution | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |
| Search keyword (per keyword) | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs) |

### Tokens

Tokens are defined within data contracts and share the same lifecycle, versioning, and validation model as documents.

#### Token Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max token note length | 2,048 bytes | Maximum note/memo length | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/tokens/mod.rs#L19) |

#### Token Distribution Function Limits

These limits apply to token perpetual distribution function parameters.

| Parameter | Min | Max | Source |
|-----------|-----|-----|--------|
| `MAX_DISTRIBUTION_PARAM` | 1 | 281,474,976,710,655 (2^48 - 1) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L14) |
| `MAX_DISTRIBUTION_CYCLES_PARAM` | 1 | 32,767 (2^(63-48) - 1) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L20) |
| Linear slope A | -255 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial M | -8 | 8 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial N | 0 | 32 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial A | -255 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Log A | -32,766 | 32,767 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential A | 1 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential M | -8 | 8 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential N | 0 | 32 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Default step decreasing max cycles | 128 | 128 | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L22) |

## Address System

:::{versionadded} 3.0.0
:::

### Address Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Address hash size | 20 bytes | Size of address hash | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/address_funds/platform_address.rs#L24) |
| Platform HRP (mainnet) | "dash" | Human-readable prefix | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/address_funds/platform_address.rs#L259) |
| Platform HRP (non-mainnet) | "tdash" | Human-readable prefix used for testnet, devnet, and regtest | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/address_funds/platform_address.rs#L261) |
| P2PKH address type (bech32m) | 0xb0 (176) | Pay-to-public-key-hash bech32m encoding type byte | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/address_funds/platform_address.rs#L280) |
| P2SH address type (bech32m) | 0x80 (128) | Pay-to-script-hash bech32m encoding type byte | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/address_funds/platform_address.rs#L282) |

### Transaction Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Min output amount | 500,000 credits | Minimum output per address | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L40) |
| Min input amount | 100,000 credits | Minimum input per address | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L41) |
| Max fee strategies | 4 | Maximum fee strategy steps | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L46) |
| Max address inputs | 16 | Maximum input addresses per address-based transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L44) |
| Max address outputs | 128 | Maximum output addresses per address-based transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L45) |
| Max asset lock transaction inputs | 100 | Maximum L1 transaction inputs in an asset lock proof | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v3.rs#L25) |

## Epoch and Time Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Genesis epoch index | 0 | First epoch number | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/epoch/mod.rs#L45) |
| Perpetual storage eras | 50 | Number of storage eras (~50 years) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/epoch/mod.rs#L49) |
| Default epochs per era | 40 | Epochs in each era (~1 year) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/epoch/mod.rs#L51) |
| Epoch key offset | 256 | Offset for epoch keys | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/block/epoch/mod.rs#L6) |
| Max epoch | 65,279 | Maximum epoch number (u16::MAX - 256) | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/block/epoch/mod.rs#L9) |

## Refund Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Min refund limit | 32 bytes | Minimum bytes for refund | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/fee/fee_result/refunds.rs#L23) |

## Withdrawal Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Min withdrawal amount | 1,000,000 credits | 1,000 duffs minimum per withdrawal (protocol version 12 and later; raised from 190,000 credits in earlier versions) | [rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v3.rs#L24) |
| Min core fee per byte | 1 | Must be Fibonacci number | [rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/mod.rs#L39) |
