```{eval-rst}
.. _protocol-ref-constants:
```

# Protocol Constants

This page provides a comprehensive reference for all constants, limits, and default values defined in the Dash Platform Protocol implementation (rs-dpp).

## System Limits

Maximum sizes and limits for various platform components.

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max contract size | 16,384 bytes (16 KiB) | Maximum serialized data contract | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L133) |
| Max field value size | 5,120 bytes (5 KiB) | Maximum single field value | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L134) |
| Max document value depth | 256 nested containers | Maximum nesting depth within a document property value (protocol version 13 and later; unbounded earlier) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L137) |
| Max state transition size | 20,480 bytes (20 KiB) | Maximum serialized state transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L145) |
| Max transitions in documents batch | 1 | Maximum transitions per batch state transition (document and token transitions counted together) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L148) |
| Withdrawals per block | 4 | Maximum withdrawal transactions per block | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L149) |
| Retry signing expired withdrawals per block | 1 | Max expired withdrawal retries per block | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L150) |
| Max withdrawal amount | 50,000,000,000,000 credits | 500 Dash maximum per withdrawal | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L151) |
| Daily withdrawal limit | Protocol versions 8-13: 200,000,000,000,000 credits (2000 Dash)<br>Protocol version 14+: 15% of the credits Platform held one day earlier, never below the max withdrawal amount (500 Dash) | The relative limit added in 5.0.0 is `max(day-old total × 15%, max withdrawal amount)` and has no fixed upper bound; credits minted since the day-old total was recorded are added to the base, so the limit counts net outflow. Until a full day of credit history is available after activation, the previous 2000-Dash limit remains in effect. Withdrawals must also fit the Core credit pool unlock limit below. | [v8-v13](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/withdrawal/daily_withdrawal_limit/v1/mod.rs#L6-L9), [v14+](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/withdrawal/daily_withdrawal_limit/v2/mod.rs#L23-L47) |
| Core credit pool unlock limit | 15% of Core's credit pool balance at the window start, at least 150,000,000,000,000 credits (1500 Dash) | **Added in 5.0.0.** Platform pools a withdrawal only while Core's credit pool would drop by at most this amount over the Core credit pool window, counting withdrawals already queued or broadcast but not yet completed. A stricter copy of Core v24's unlock rule (20%, 2000-Dash floor), so Platform does not pool more than Core will mine | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L153-L154) |
| Core credit pool window | 576 Core blocks (100 on regtest) | **Added in 5.0.0.** Window over which the Core credit pool unlock limit is measured (Core's `CreditPoolPeriodBlocks`) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L155-L156) |
| Max group member count | 256 | Maximum members of a change-control group defined in a data contract (renamed from `max_contract_group_size` in 5.0.0; unrelated to [contract groups](#contract-groups-and-moderation)) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L160) |
| Max token redemption cycles | 128 | Maximum redemption cycles | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L178) |
| Max contenders per contest | 1,000 | **Added in 5.0.0.** Maximum contenders a contested document vote poll accepts | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L177) |
| Max shielded transition actions | 16 | Consensus cap on [actions](shielded-pool.md#actions) per shielded transition. The effective limit is 6 - the Halo 2 proof grows ~2,681 bytes per action, so larger transitions exceed the max state transition size | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L187) |
| Max time-range overlap factor | 24 | **Added in 5.0.0.** Maximum `range / step` for a [timeRange](data-contract-document.md#document-indices) index, so at most 24 windows overlap at any timestamp | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L189) |
| Max time-range TTL | 604,800 seconds (1 week) | **Added in 5.0.0.** Maximum `ttl` a [timeRange](data-contract-document.md#document-indices) index may declare | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L190) |
| Min time-range TTL drop operations per write | 32 | **Added in 5.0.0.** Minimum expired-entry cleanup operations Drive performs on each write into a `ttl` index | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L191) |
| Max time-range phase | 31,536,000 seconds (365 days) | **Added in 5.0.0.** Maximum `phase` offset a [timeRange](data-contract-document.md#document-indices) index may declare | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/index/mod.rs#L103) |
| Core dust relay fee | 3,000 duffs/kB | **Added in 5.0.0.** Used to compute the Core dust threshold of a withdrawal's output script (546 duffs for P2PKH). An expired withdrawal whose whole amount is below it is marked `FAILED` instead of being re-signed | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L158) |
| Min GroveDB proof envelope version | 1 | **Added in 5.0.0.** Client-side proof verification policy, not a consensus rule: clients reject the legacy V0 proof envelope at every protocol version. Nodes have served V1 since protocol version 12 | [rs-drive](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-drive/src/verify/grovedb_proof_envelope.rs#L14) |
| Max CBOR encoded length | 16,384 bytes (16 KiB) | Maximum CBOR encoding size (defined as `MAX_ENCODED_KBYTE_LENGTH = 16` kibibytes) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/util/cbor_serializer.rs#L8) |
| Contract deserialization limit | 15,000 | Maximum contract deserialization | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/serialized_version/mod.rs#L42) |

## Credit System

Credits are the unit of account for fees on Dash Platform. They are created from Dash locked on the Core blockchain.

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `CREDITS_PER_DUFF` | 1,000 | Credits created per duff (satoshi) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/balances/credits.rs#L43) |
| `MAX_CREDITS` | 9,223,372,036,854,775,807 | Maximum credit value (i64::MAX) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/balances/credits.rs#L41) |

**Conversion:** 1 Dash = 100,000,000 duffs = 100,000,000,000 credits

## Protocol Fees

### Base Processing

These constants define the base costs for state transition processing.

| Constant | Value (Credits) | Description | Source |
|----------|-----------------|-------------|--------|
| `BASE_ST_PROCESSING_FEE` | 10,000 | Base state transition processing fee | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L3) |
| `DEFAULT_USER_TIP` | 0 | Default priority tip | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L4) |
| `STORAGE_CREDIT_PER_BYTE` | 5,000 | Storage cost per byte | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L5) |
| `PROCESSING_CREDIT_PER_BYTE` | 12 | Processing cost per byte | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L6) |
| `DELETE_BASE_PROCESSING_COST` | 2,000 | Base deletion cost | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L7) |
| `READ_BASE_PROCESSING_COST` | 8,400 | Base read cost | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L8) |
| `WRITE_BASE_PROCESSING_COST` | 6,000 | Base write cost | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/default_costs/constants.rs#L9) |

### State Transition Pricing

These constants define minimum values required for a state transition to be considered valid.

| State Transition | Min Fee (Credits) | Min Fee (Dash) | Source |
|------------------|-------------------|----------------|--------|
| Credit Transfer | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L4) |
| Credit Transfer to Addresses | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L5) |
| Credit Withdrawal | 400,000,000 | 0.004 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L6) |
| Identity Update | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L7) |
| Document Batch (per sub-transition) | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L8) |
| Contract Create | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L9) |
| Contract Update | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L10) |
| Masternode Vote | 100,000 | 0.000001 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L11) |
| Address Credit Withdrawal | 400,000,000 | 0.004 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L13) |
| Address Funds Transfer (per input) | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L14) |
| Address Funds Transfer (per output) | 6,000,000 | 0.00006 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L15) |
| Identity Create (base) | 2,000,000 | 0.00002 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L16) |
| Identity Key (per key at creation) | 6,500,000 | 0.000065 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L17) |
| Identity TopUp (base) | 500,000 | 0.000005 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/state_transition_min_fees/v1.rs#L18) |

### Execution and Resource Pricing

These fees meter execution and resource usage. They do not affect validity, but determine total cost.

#### Processing

Fees for specific operations during state transition processing.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Fetch identity balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L4) |
| Fetch identity revision | 9,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L5) |
| Fetch identity balance and revision | 15,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L6) |
| Fetch identity key by ID | 9,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L7) |
| Fetch identity token balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L8) |
| Fetch prefunded specialized balance | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L9) |
| Fetch key with type, nonce and balance | 12,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L10) |
| Fetch single identity key | 10,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L11) |
| Network threshold signing | 100,000,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L12) |
| Validate key structure | 50 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/processing/v1.rs#L13) |

#### Storage

Fees related to data storage operations.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Storage disk usage (per byte) | 27,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs#L6) |
| Storage processing (per byte) | 400 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs#L7) |
| Storage load (per byte) | 20 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs#L8) |
| Non-storage load (per byte) | 10 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs#L9) |
| Storage seek | 2,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs#L10) |
| TTL ephemeral disk usage (per byte) | 270 | **Added in 5.0.0.** Charged as processing for bytes written under a [timeRange `ttl`](data-contract-document.md#document-indices) index instead of the storage rate; not refunded on removal. [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/storage/v1.rs#L23) |

#### Cryptographic Operations

##### Signature Verification

Fees for verifying different signature types.

| Key Type | Verification Fee (Credits) | Source |
|----------|----------------------------|--------|
| ECDSA Secp256k1 | 15,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs#L4) |
| BLS 12-381 | 300,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs#L5) |
| ECDSA Hash160 | 15,500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs#L6) |
| BIP13 Script Hash | 300,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs#L7) |
| EdDSA 25519 Hash160 | 3,500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/signature/v1.rs#L8) |

##### Hashing

Fees for cryptographic hash operations.

| Operation | Fee (Credits) | Source |
|-----------|---------------|--------|
| Single SHA256 (base) | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L4) |
| Blake3 (base) | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L5) |
| SHA256 + RIPEMD160 (base) | 6,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L6) |
| SHA256 (per block) | 5,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L7) |
| Blake3 (per block) | 300 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L8) |
| RIPEMD160 (per block) | 5,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L9) |
| Sinsemilla (base) | 40,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/hashing/v1.rs#L10) |

#### Data Contract Validation

Fees for validating data contract structure during state transition processing.

| Fee Type | Amount (Credits) | Source |
|----------|------------------|--------|
| Document type base fee | 500 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L5) |
| Schema size fee (per byte) | 10 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L6) |
| Per property fee | 40 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L7) |
| Non-unique index base fee | 50 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L8) |
| Non-unique index per property fee | 30 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L9) |
| Unique index base fee | 100 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L10) |
| Unique index per property fee | 60 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_validation/v1.rs#L11) |

#### Document TTL

:::{versionadded} 5.0.0
:::

Documents of a type that declares a `ttl` are stored without a storage refund. Instead of the perpetual storage rate, each byte the document writes is priced by its remaining lifetime, and the document prepays the processing cost of its eventual deletion.

| Fee | Amount (Credits) | Source |
|-----|------------------|--------|
| Lifetime up to 1 hour (per byte) | 1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L15-L18) |
| Lifetime up to 1 day (per byte) | 4 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L19-L22) |
| Lifetime up to 2 days (per byte) | 8 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L23-L26) |
| Lifetime up to 4 days (per byte) | 15 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L27-L30) |
| Lifetime up to 7 days (per byte) | 26 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L31-L34) |
| Longer lifetimes (per byte, per 788,400-second period spanned, rounded up) | 34 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L36-L37) |
| Deletion prepayment (base) | 1,200,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L41) |
| Deletion prepayment (per index level) | 400,000 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L42) |
| Deletion prepayment (per document byte) | 420 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_ttl/v1.rs#L47) |

#### Document References

:::{versionadded} 5.0.0
:::

| Fee | Amount (Credits) | Description | Source |
|-----|------------------|-------------|--------|
| `chooseFirst` candidate | 100,000 | Charged per competing document a `refersTo` `chooseFirst` scan reads. Check tx requires the signer to hold the full budget (100,000 credits × max `chooseFirst` candidates) beyond the estimated fee, but only the scan actually performed is charged | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_reference/v1.rs#L17) |
| `where` list element | 100 | Charged per list element a `refersTo` `where` entry reads | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/document_reference/v1.rs#L18) |

### Voting

Fees related to contested document voting.

| Fee Type | Amount (Credits) | Amount (Dash) | Source |
|----------|------------------|---------------|--------|
| Contested document vote resolution fund | **Updated in 5.0.0.**<br>Through protocol version 13: 20,000,000,000<br>Protocol version 14+: 10,000,000,000 | 0.2<br>0.1 | [through v13](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs#L4), [v14+](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v2.rs#L6) |
| Contested document unlock fund | 400,000,000,000 | 4.0 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs#L5) |
| Single vote cost | **Updated in 5.0.0.**<br>Through protocol version 13: 10,000,000<br>Protocol version 14+: 2,000,000 | 0.0001<br>0.00002 | [through v13](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v1.rs#L6), [v14+](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v2.rs#L8) |
| Moderation election vote resolution fund | 50,000,000,000 | 0.5 | **Added in 5.0.0.** Paid by each application in a moderation team election. [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v2.rs#L10) |

**Added in 5.0.0.** Starting in protocol version 14, the first [250 contenders](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v2.rs#L14) of a contest pay the vote resolution fund, and the fund then doubles for every [50 additional contenders](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/vote_resolution_fund_fees/v2.rs#L15) (twice the fund for the 251st to 300th contender, up to 32,768 times the fund for the 951st to 1,000th).

## Identity Model

### Identity Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max public keys per identity | 15,000 | Maximum keys an identity can have | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/identity/fields.rs#L7) |
| Max keys in creation | 6 | Keys allowed at identity creation | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L23) |
| Identity nonce value filter | 0xFFFFFFFFFF | 40-bit nonce filter | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/identity/identity_nonce.rs#L15) |
| Max missing identity revisions | 24 | Maximum revision gaps | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/identity/identity_nonce.rs#L17) |

### Identity Create Fees

| Requirement | Value | Description | Source |
|-------------|-------|-------------|--------|
| Min asset lock balance | 200,000 duffs | 0.002 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L25) |
| Min top-up balance | 50,000 duffs | 0.0005 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L26) |
| Min address funding balance | 50,000 duffs | 0.0005 Dash minimum | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L27) |
| Min identity funding amount | 200,000 credits | Minimum for address-based creation | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L48) |
| Max asset-lock transaction inputs | 100 | Maximum Core inputs in an asset-lock transaction used to fund an identity or top-up (introduced in protocol v3 to prevent stuck funds; v1/v2 had no effective limit) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L30) |

## Document & Data Contract Model

### Document and Index Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max indexed string length | 63 characters | Maximum indexable string | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L77) |
| Max indexed byte array length | 255 bytes | Maximum indexable byte array | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L78) |
| Max indexed array items | 1,024 | Maximum items in indexed array | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L79) |
| Max index size | 255 bytes | Maximum total index size | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L45) |
| Default hash size | 32 bytes | Standard hash size | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L42) |
| Default float size | 8 bytes | Standard float size | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L43) |
| Empty tree storage size | 33 bytes | Storage for empty tree | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L44) |
| Storage flags size | 2 bytes | Size of storage flags | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L46) |
| Contract version stamp size | 5 bytes | **Added in 5.0.0.** Extra bytes document serialization format 3 adds to the estimated document size | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L49) |

### Document Type Limits

:::{versionadded} 5.0.0
:::

Limits on the document type keywords added in protocol version 14, enforced when a data contract is registered or updated unless noted otherwise.

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max typed array items | 1,024 | Maximum `maxItems` a typed array property may declare | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L138) |
| Max indexed typed array items | 16 | Maximum `maxItems` of a typed array whose elements an index keys documents by | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L198) |
| Max windowed indexed typed array items | 4 | Maximum `maxItems` of an indexed typed array when the same index also has a `timeRange` or `integerRange` window | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L199) |
| Max index entries per document | 256 | Maximum index entries one document of a type with an indexed typed array can write across all of the type's indexes | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L200) |
| Max references per document | 256 | Maximum `refersTo` references one document of a type can carry. A typed array of references counts as its `maxItems` | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L139) |
| Max reference operands | 4 | Maximum operands in one `refersTo` `anyOf` or `allOf` list | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L140) |
| Max reference expression depth | 4 | Maximum nesting of `anyOf` / `allOf` combinators in a `refersTo` expression | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L141) |
| Max `chooseFirst` candidates | 1,000 | Maximum competing documents a create reads for a `refersTo` `chooseFirst` (enforced when the document is created) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L201) |
| Max `chooseFirst` order properties | 10 | Maximum properties a `chooseFirst` orders commitments by (`by`) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/property/reference_lookup.rs#L140) |
| Max property constraints | 16 | Maximum `propertyConstraints` rules per document type | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L142) |
| Max property constraint nodes | 32 | Maximum nodes (comparisons, operators, properties, and values) in one `propertyConstraints` rule | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L143) |
| Max property constraint aggregates | 4 | Maximum distinct `countOf` and `sumOf` totals the `propertyConstraints` rules of one document type read | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L144) |
| Min document TTL | 3,600 seconds (1 hour) | Minimum `ttl` a document type may declare | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L192) |
| Max document TTL | 31,536,000 seconds (365 days) | Maximum `ttl` a document type may declare | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L193) |
| Max document expirations per block | 128 | Maximum expired documents Platform deletes in one block; the rest wait for later blocks, oldest first | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L194) |
| Max document expiration weight per block | 1,024 | Maximum expiry cleanup work per block, where each deleted document weighs 1 plus the weighted index levels of its type | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L195) |
| Max contested summed value magnitude | 134,217,728 (2^27) | A summed property of a document type with a contested index must declare a `maximum` and `minimum` within ±2^27 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L196) |
| Max expiring signed summed value magnitude | 134,217,728 (2^27) | A summed property that may be negative, on a document type with a `ttl`, must declare a `maximum` and `minimum` within ±2^27 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L197) |

### Contract Groups and Moderation

:::{versionadded} 5.0.0
:::

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max contract group memberships per contract | 16 | Maximum contract group memberships a data contract create transition may declare | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L161) |
| Max contract group admins | 16 | Maximum admins a contract group may name besides its owner | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L162) |
| Max contract group name length | 64 characters | Maximum length of a contract group name | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L163) |
| Max contract group description length | 256 characters | Maximum length of a contract group description | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L164) |
| Max contract moderators | 16 | Maximum moderator identities a moderated data contract may name (the owner counts when named) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L165) |
| Max suspension end time | 9,007,199,254,740,991 ms (2^53 - 1) | Latest block time a contract suspension may run until | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L166) |
| Max moderation reason length | 1,024 bytes | Maximum UTF-8 length of the text of a ban, suspension, warning, or moderator document deletion reason | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L167) |
| Max warnings per identity | 16 | Maximum warnings one identity may carry on a contract at a time | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L168) |
| Max moderation reason documents | 16 | Maximum documents a moderation reason may cite | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L169) |
| Election window (join and vote) | Min: 86,400 seconds (1 day) on mainnet, none on other networks<br>Max: 2,419,200 seconds (4 weeks) | Bounds on the join window and vote window of an elected moderation team declaration | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L170-L171) |
| Default election window | 604,800 seconds (1 week) | Join window and vote window of an elected moderation team declaration that omits them | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/config/moderation/elected.rs#L32) |
| Challenge cool-down | Min: 1,209,600 seconds (2 weeks)<br>Max: 94,608,000 seconds (3 years) | Bounds on how long a seated moderation team is safe from a challenge after a seat change | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L172-L173) |
| Document restore window | 604,800,000 ms (7 days) | How long after a moderator deletes a document the contract's moderators may restore it | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L174) |
| Max added moderators | 15 | Maximum members an elected moderation declaration may let a seated team's leader add (`maxAddedModerators`) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L175) |
| Max charter elected members | 15 | Maximum members a moderation charter elects besides its leader | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L176) |

### Data Contract Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Initial contract version | 1 | Starting version number | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/mod.rs#L82) |

### Data Contract Registration Fees

One-time fees for registering data contracts and their components.

| Component | Fee (Credits) | Fee (Dash) | Source |
|-----------|---------------|------------|--------|
| Base contract registration | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L6) |
| Document type registration | 2,000,000,000 | 0.02 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L7) |
| Non-unique index registration | 1,000,000,000 | 0.01 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L8) |
| Unique index registration | 1,000,000,000 | 0.01 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L9) |
| Contested index registration | 100,000,000,000 | 1.0 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L10) |
| Token registration | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L11) |
| Token perpetual distribution | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L12) |
| Token pre-programmed distribution | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L13) |
| Token once-per-identity distribution | **Updated in 5.0.0.**<br>Through protocol version 13: 0<br>Protocol version 14+: 10,000,000,000 | 0<br>0.1 | [through v13](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L14), [v14+](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v3.rs#L8) |
| Search keyword (per keyword) | 10,000,000,000 | 0.1 | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L15) |

### Tokens

Tokens are defined within data contracts and share the same lifecycle, versioning, and validation model as documents.

#### Token Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Max token note length | 2,048 bytes | Maximum note/memo length | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/tokens/mod.rs#L19) |
| Max token pool notes for outgoing | 250 | **Added in 5.0.0.** Highest `minimumPoolNotesForOutgoing` a token configuration may set for its [shielded pool](shielded-pool.md) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L188) |
| Max evonode reward claim epochs | 100 | **Added in 5.0.0.** Maximum finalized epochs one `EvonodesByParticipation` perpetual distribution claim reads, unless a single distribution cycle spans more. An evonode further behind is paid over several claims | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L179) |

#### Token Distribution Function Limits

These limits apply to token perpetual distribution function parameters.

| Parameter | Min | Max | Source |
|-----------|-----|-----|--------|
| `MAX_DISTRIBUTION_PARAM` | 1 | 281,474,976,710,655 (2^48 - 1) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L18) |
| `MAX_DISTRIBUTION_CYCLES_PARAM` | 1 | 32,767 (2^(63-48) - 1) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L24) |
| Linear slope A | -255 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial M | -8 | 8 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial N | 0 | 32 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Polynomial A | -255 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Log A | -32,766 | 32,767 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential A | 1 | 256 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential M | -8 | 8 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Exponential N | 0 | 32 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs) |
| Default step decreasing max cycles | 128 | 128 | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/associated_token/token_perpetual_distribution/distribution_function/mod.rs#L26) |

## Address System

:::{versionadded} 3.0.0
:::

### Address Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Address hash size | 20 bytes | Size of address hash | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L28) |
| Platform HRP (mainnet) | "dash" | Human-readable prefix | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L263) |
| Platform HRP (non-mainnet) | "tdash" | Human-readable prefix used for testnet, devnet, and regtest | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L265) |
| P2PKH address type (bech32m) | 0xb0 (176) | Pay-to-public-key-hash bech32m encoding type byte | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L284) |
| P2SH address type (bech32m) | 0x80 (128) | Pay-to-script-hash bech32m encoding type byte | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/address_funds/platform_address.rs#L286) |

### Transaction Limits

| Limit | Value | Description | Source |
|-------|-------|-------------|--------|
| Min output amount | 500,000 credits | Minimum output per address | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L46) |
| Min input amount | 100,000 credits | Minimum input per address | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L47) |
| Max fee strategies | 4 | Maximum fee strategy steps | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L55) |
| Max address inputs | 16 | Maximum input addresses per address-based transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L53) |
| Max address outputs | 128 | Maximum output addresses per address-based transition | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L54) |
| Max asset lock transaction inputs | 100 | Maximum L1 transaction inputs in an asset lock proof | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_state_transition_versions/v4.rs#L30) |

## Epoch and Time Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Genesis epoch index | 0 | First epoch number | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/epoch/mod.rs#L45) |
| Perpetual storage eras | 50 | Number of storage eras (~50 years) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/epoch/mod.rs#L49) |
| Default epochs per era | 40 | Epochs in each era (~1 year) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/epoch/mod.rs#L51) |
| Epoch key offset | 256 | Offset for epoch keys | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/block/epoch/mod.rs#L10) |
| Max epoch | 65,279 | Maximum epoch number (u16::MAX - 256) | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/block/epoch/mod.rs#L13) |

## Refund Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Min refund limit | 32 bytes | Minimum bytes for refund | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/fee/fee_result/refunds.rs#L23) |

## Withdrawal Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| Min withdrawal amount | 1,000,000 credits | 1,000 duffs minimum per withdrawal (protocol version 12 and later; raised from 190,000 credits in earlier versions). Starting in protocol version 14, the Core transaction fee is deducted from the withdrawn amount, so a withdrawal must be at least this minimum plus the Core fee (190-byte asset unlock transaction × `coreFeePerByte` × 1,000 credits) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L157) |
| Min core fee per byte | 1 | Must be Fibonacci number | [rs-dpp](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_withdrawal_transition/mod.rs#L39) |
| Max core fee per byte | 6,765 | **Added in 5.0.0.** Highest `coreFeePerByte` a withdrawal may set (protocol version 14 and later; uncapped earlier) | [rs-platform-version](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L159) |
