```{eval-rst}
.. _protocol-ref-address-transitions:
```

# Platform Address System

:::{attention}
Address-based state transitions were introduced in **Protocol Version 11**. These transitions enable direct operations using Platform addresses without requiring a pre-existing identity for some operations.
:::

## Overview

Address-based state transitions provide an alternative funding and transfer mechanism using Platform addresses. Unlike identity-signed transactions that require an existing identity with keys, address-based operations can work directly with cryptographic proofs tied to address ownership.

There are six address-based state transition types:

| Type | Name | Description |
|------|------|-------------|
| 9 | [Identity Credit Transfer to Addresses](#identity-credit-transfer-to-addresses) | Transfer credits from identity to Platform addresses |
| 10 | [Identity Create from Addresses](#identity-create-from-addresses) | Create identity funded from Platform addresses |
| 11 | [Identity Top-Up from Addresses](#identity-top-up-from-addresses) | Top up existing identity from Platform addresses |
| 12 | [Address Funds Transfer](#address-funds-transfer) | Transfer between Platform addresses |
| 13 | [Address Funding from Asset Lock](#address-funding-from-asset-lock) | Fund Platform addresses from asset lock |
| 14 | [Address Credit Withdrawal](#address-credit-withdrawal) | Withdraw from Platform addresses to Core |

## Common Components

### Platform Address

Platform addresses are derived from standard Bitcoin/Dash address formats and encoded using bech32m per [DIP-0018](https://github.com/dashpay/dips/blob/master/dip-0018.md).

| Variant  | Type Byte | Size     | Description                                          |
| ------- | ---- | -------- | ---------------------------------------------------- |
| `P2PKH` | 0xb0 | 21 bytes | Pay-to-Public-Key-Hash (1 type byte + 20 hash bytes) |
| `P2SH`  | 0x80 | 21 bytes | Pay-to-Script-Hash (1 type byte + 20 hash bytes)     |

**Encoding:**

- **Mainnet HRP:** `dash`
- **Testnet HRP:** `tdash` (also used for Devnet and Regtest)

**Derivation:** Standard Bitcoin derivation using `Hash160(compressed_pubkey)` where Hash160 = RIPEMD160(SHA256(x)).

See the [Platform address implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/address_funds/platform_address.rs).

### Address Witness

Witnesses provide cryptographic proof of address ownership. Each input in an address-based transition requires a corresponding witness.

| Variant  | Size     | Fields                   | Description                                     |
|----------|----------|--------------------------|------------------------------------------------ |
| `P2pkh`  | 65 bytes | signature                | Recoverable ECDSA signature                     |
| `P2sh`   | Varies   | signatures, redeemScript | Multiple signatures with multisig redeem script |

**P2PKH Verification:**

1. Double-SHA256 hash the signable bytes
2. Recover public key from recoverable signature
3. Hash160 the recovered pubkey
4. Compare with address hash

**P2SH Multisig Verification:**

1. Verify redeem script hashes to address
2. Parse script for threshold (M) and public keys (N)
3. Double-SHA256 hash the signable bytes (reused for all signatures)
4. Match M signatures to N public keys in order

See the [witness implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/address_funds/witness.rs).

### Fee Strategy

The fee strategy specifies how transaction fees are deducted from inputs or outputs.

| Step Type         | Type             | Size    | Description                              |
|-------------------|------------------|---------|------------------------------------------|
| `DeductFromInput` | unsigned integer | 16 bits | Deduct fee from input at specified index |
| `ReduceOutput`    | unsigned integer | 16 bits | Reduce output amount to cover fee        |

:::{note}
Fee strategy cannot be empty. Maximum steps: 4 (`max_address_fee_strategies`). No duplicate steps allowed. Steps are processed in sequence until the fee is fully covered.
:::

See the [fee strategy implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/address_funds/fee_strategy/mod.rs).

### Common Type Aliases

| Type              | Definition       | Size    | Description                                      |
|-------------------|------------------|---------|--------------------------------------------------|
| `AddressNonce`    | unsigned integer | 32 bits | Sequential counter per address (prevents replay) |
| `Credits`         | unsigned integer | 64 bits | Platform credit unit                             |
| `UserFeeIncrease` | unsigned integer | 16 bits | User-specified fee multiplier                    |

## Platform Address State Transition Details

### Identity Credit Transfer to Addresses

Transfer credits from an existing identity to one or more Platform addresses.

| Field                | Type             | Size     | Description                                                                                   |
|----------------------|------------------|----------|-----------------------------------------------------------------------------------------------|
| identityId           | array of bytes   | 32 bytes | An [Identity ID](identity.md#identity-id) for the identity sending credits                    |
| recipientAddresses   | map              | Varies   | Map of destination [Platform addresses](#platform-address) to credit amounts                  |
| nonce                | unsigned integer | 64 bits  | Identity nonce for this transition to prevent replay attacks                                  |
| userFeeIncrease      | unsigned integer | 16 bits  | Extra fee to prioritize processing if the mempool is full                                     |
| signaturePublicKeyId | unsigned integer | 32 bits  | The ID of the [public key](identity.md#identity-publickeys) used to sign the state transition |
| signature            | array of bytes   | 65 bytes | Signature of state transition data                                                            |

:::{note}
Minimum recipients: 1. Maximum recipients: `max_address_outputs`. Minimum per recipient: 500,000 credits. Minimum fee: 500,000 credits.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_credit_transfer_to_addresses_transition/).

### Identity Create from Addresses

Create a new identity funded from Platform address balances.

| Field           | Type             | Size    | Description                                                                      |
|-----------------|------------------|---------|----------------------------------------------------------------------------------|
| publicKeys      | array of keys    | Varies  | [Public key(s)](identity.md#identity-publickeys) for the new identity (1-6 keys) |
| inputs          | map              | Varies  | Map of source [Platform addresses](#platform-address) to (nonce, credits) pairs  |
| output          | tuple            | Varies  | (Optional) Change output as (Platform address, credits)                          |
| feeStrategy     | array            | Varies  | [Fee deduction strategy](#fee-strategy)                                          |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full                        |
| inputWitnesses  | array            | Varies  | [Address witnesses](#address-witness) for each input                             |

:::{note}
**Constraints:** Minimum inputs: 1. Maximum inputs: `max_address_inputs`. Maximum public keys: 6. Minimum per input: 100,000 credits. Minimum output: 500,000 credits. Minimum funding: input sum ≥ output sum + 200,000 credits.

**Cost:** Base cost 2,000,000 + 6,500,000 per key. Example: 2 keys = 15,000,000 credits.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_create_from_addresses_transition/).

### Identity Top-Up from Addresses

Add credits to an existing identity from Platform address balances.

| Field           | Type             | Size     | Description                                                                     |
|-----------------|------------------|----------|---------------------------------------------------------------------------------|
| identityId      | array of bytes   | 32 bytes | An [Identity ID](identity.md#identity-id) for the identity receiving the top-up |
| inputs          | map              | Varies   | Map of source [Platform addresses](#platform-address) to (nonce, credits) pairs |
| output          | tuple            | Varies   | (Optional) Change output as (Platform address, credits)                         |
| feeStrategy     | array            | Varies   | [Fee deduction strategy](#fee-strategy)                                         |
| userFeeIncrease | unsigned integer | 16 bits  | Extra fee to prioritize processing if the mempool is full                       |
| inputWitnesses  | array            | Varies   | [Address witnesses](#address-witness) for each input                            |

:::{note}
**Constraints:** Minimum inputs: 1. Maximum inputs: `max_address_inputs`. Minimum per input: 100,000 credits. Minimum output: 500,000 credits. Minimum top-up: input sum ≥ output sum + 200,000 credits.

**Fee:** Base top-up cost: 500,000 credits.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/state_transition/state_transitions/identity/identity_topup_from_addresses_transition/).

### Address Funds Transfer

Transfer credits between Platform addresses.

| Field           | Type             | Size    | Description                                                                     |
|-----------------|------------------|---------|---------------------------------------------------------------------------------|
| inputs          | map              | Varies  | Map of source [Platform addresses](#platform-address) to (nonce, credits) pairs |
| outputs         | map              | Varies  | Map of destination [Platform addresses](#platform-address) to credit amounts    |
| feeStrategy     | array            | Varies  | [Fee deduction strategy](#fee-strategy)                                         |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full                       |
| inputWitnesses  | array            | Varies  | [Address witnesses](#address-witness) for each input                            |

:::{important}
Unlike other address transitions, fund transfers enforce strict balance preservation. The total input amount must exactly equal the total output amount (before fee deduction).
:::

:::{note}
**Constraints:** Minimum inputs: 1. Maximum inputs: `max_address_inputs`. Minimum outputs: 1. Maximum outputs: `max_address_outputs`. Minimum per input: 100,000 credits. Minimum per output: 500,000 credits. No output can also be an input.

**Fee:** 500,000 credits per input + 6,000,000 credits per output.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/state_transition/state_transitions/address_funds/address_funds_transfer_transition/).

### Address Funding from Asset Lock

Fund Platform addresses from a Core chain asset lock special transaction.

| Field           | Type             | Size     | Description                                                                          |
|-----------------|------------------|----------|--------------------------------------------------------------------------------------|
| assetLockProof  | object           | Varies   | [Asset lock proof](identity.md#asset-lock) proving locked funds (Instant or Chain)   |
| inputs          | map              | Varies   | (Optional) Map of existing [Platform addresses](#platform-address) to combine        |
| outputs         | map              | Varies   | Map of destination addresses to credits (one must be None for remainder)             |
| feeStrategy     | array            | Varies   | [Fee deduction strategy](#fee-strategy)                                              |
| userFeeIncrease | unsigned integer | 16 bits  | Extra fee to prioritize processing if the mempool is full                            |
| signature       | array of bytes   | 65 bytes | Asset lock signature                                                                 |
| inputWitnesses  | array            | Varies   | [Address witnesses](#address-witness) for any existing address inputs                |

This transition uses **dual signing**: an asset lock signature proves ownership of locked funds, and address witnesses prove ownership of any existing address inputs (if combining funds).

:::{important}
Exactly one output must have a `None` value. This remainder output receives whatever funds remain after explicit outputs and fees are satisfied, ensuring full consumption of the asset lock.
:::

:::{note}
**Constraints:** Minimum outputs: 1. Maximum inputs: `max_address_inputs`. Maximum outputs: `max_address_outputs`. Minimum per input: 100,000 credits. Minimum per explicit output: 500,000 credits. No output can also be an input.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/state_transition/state_transitions/address_funds/address_funding_from_asset_lock_transition/).

### Address Credit Withdrawal

Withdraw credits from Platform addresses back to the Core chain.

| Field           | Type             | Size     | Description                                                                                                          |
|-----------------|------------------|----------|----------------------------------------------------------------------------------------------------------------------|
| inputs          | map              | Varies   | Map of source [Platform addresses](#platform-address) to (nonce, credits) pairs                                      |
| output          | tuple            | Varies   | (Optional) Change output as (Platform address, credits)                                                              |
| feeStrategy     | array            | Varies   | [Fee deduction strategy](#fee-strategy)                                                                              |
| coreFeePerByte  | unsigned integer | 32 bits  | Core transaction fee per byte (must be a [Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_sequence) ≥ 1)   |
| pooling         | unsigned integer | 8 bits   | Pooling mode: `0` = Never (required), `1` = IfAvailable, `2` = Standard                                              |
| outputScript    | array of bytes   | Varies   | Core chain destination script (P2PKH or P2SH only)                                                                   |
| userFeeIncrease | unsigned integer | 16 bits  | Extra fee to prioritize processing if the mempool is full                                                            |
| inputWitnesses  | array            | Varies   | [Address witnesses](#address-witness) for each input                                                                 |

:::{note}
**Constraints:** Minimum inputs: 1. Maximum inputs: `max_address_inputs`. Minimum per input: 100,000 credits. Minimum output: 500,000 credits. Pooling must be `Never` (others not yet implemented). Output script must be P2PKH or P2SH.

**Fee:** 400,000,000 credits. Withdrawal fees are significantly higher due to the complexity and finality of moving funds back to the Core chain.
:::

See the [implementation in rs-dpp](https://github.com/dashpay/platform/blob/v3.0.0/packages/rs-dpp/src/state_transition/state_transitions/address_funds/address_credit_withdrawal_transition/).

### Address State Transition Signing

Address-based state transitions use different signing methods depending on the type. See the [state transition signing](./state-transition.md#state-transition-signing) page for full signing details.

| Category                    | Transitions          | Signer                                     |
|-----------------------------|----------------------|--------------------------------------------|
| Identity-signed             | Type 9               | Existing identity key                      |
| Address-witness-signed      | Types 10, 11, 12, 14 | Address owner(s)                           |
| Dual (Asset lock + Address) | Type 13              | Asset lock owner + optional address owners |

## Related Constants

For complete constants reference, see [Protocol Constants](protocol-constants.md).

| Constant                     | Value           | Size    | Description                           |
|------------------------------|-----------------|---------|---------------------------------------|
| `min_input_amount`           | 100,000 credits | 64 bits | Minimum per input                     |
| `min_output_amount`          | 500,000 credits | 64 bits | Minimum per output                    |
| `min_identity_funding_amount`| 200,000 credits | 64 bits | Minimum for identity creation/top-up  |
| `max_address_inputs`         | 16              | 16 bits | Maximum inputs per transition (Protocol Version 11+) |
| `max_address_outputs`        | 128             | 16 bits | Maximum outputs per transition (Protocol Version 11+) |
| `max_address_fee_strategies` | 4               | 16 bits | Maximum fee strategy steps            |

For related identity operations, see [Identity](identity.md) and [State Transitions](state-transition.md).
