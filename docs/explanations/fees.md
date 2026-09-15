```{eval-rst}
.. _explanations-fees:
```

# Fees

## Overview

Since Dash Platform is a decentralized system with inherent costs to its functionality, an adequate fee system is necessary in order to incentive the hosts (masternodes) to maintain it.

Fees on Dash Platform are divided into two main categories:

* Storage fees
* Processing fees

Storage fees cover the costs to store the various types of data throughout the network, while processing fees cover the computational costs incurred by the masternodes to process state transitions. For everyday use, processing fees are minuscule compared to storage fees. However, they are important in the prevention of attacks on the network, in which case they become prohibitively expensive.

:::{tip}
For the implementation-level constants and limits currently used by Platform, see the
[protocol constants reference](../protocol-ref/protocol-constants.md).
:::

## Costs

The current cost schedule is outlined in the table below:

| Operation | Cost (credits) |
| - | - |
| Permanent storage | 27000 / byte |
| Base processing fee | 10000 |
| Write to storage | 400 / byte |
| Load from storage | 20 / byte |
| Seek storage | 2000 |
| Load from memory | 10 / byte |
| Blake3 hash function | 100 base + 300 / 64-byte block |

Processing fees vary by operation. The value shown is a representative base cost; the total processing fee for a state transition is the sum of the individual per-operation costs incurred while validating and applying it. See the [protocol constants reference](../protocol-ref/protocol-constants.md) for the full cost schedule.

:::{note}
Refer to the [Identity explanation](../explanations/identity.md) section for information regarding how credits are created.
:::

## Fee Multiplier

The *Fee Multiplier* provides a mechanism to balance the cost of fees against network hosting requirements as the Dash price fluctuates. It is recorded per epoch and reported alongside epoch accounting information. At the active fee version it is a reserved parameter: it is not applied when distributing collected fees from the credit pools.

The multiplier does not scale the fee a user is charged. The active fee version fixes it at 1.0x,
and the final fee charged for a state transition is calculated using the complete formula below,
including any user fee increase and storage refund.

Fee parameters, including the multiplier, are fixed by the active fee version. They change only when the network activates a new protocol version, which happens once enough evonodes signal the newer version and the threshold is met at an epoch change.

<!-- Uncomment once link available
An in-depth look at the Fee Multiplier can be found at **link**
-->

## Storage Refund

In an attempt to minimize Dash Platform's storage requirements, users are incentivized to remove data that they no longer want to be stored in the Dash Platform state for a refund. Data storage fees are distributed to masternodes over the data's lifetime which is 50 years for permanent storage. Therefore, at any time before the data's fees are entirely distributed, there will be fees remaining which can be refunded to the user if they decide to delete the data.

Distribution is front-loaded rather than spread evenly across those 50 years, so the refundable remainder falls fastest in the early years. Removals below a small minimum byte threshold are not refunded at all. See the [protocol constants reference](../protocol-ref/protocol-constants.md) for the storage era counts and the refund threshold.

## Minimum and Fixed Fees

In addition to the usage-based costs above, most identity- and address-funded transitions require a protocol-defined minimum balance before processing. This is a balance floor rather than a flat charge; the fee actually deducted is still the storage and processing total.

[Shielded pool](../explanations/shielded-pool.md) transitions that pay from the pool (shielded transfers, unshields, and shielded withdrawals) are the exception. Their costs cannot be charged to an address balance, so they pay a fixed schedule from the pool: a proof verification fee, a per-action fee, and a per-action storage allowance. Transitions that shield funds are charged for storage normally and add only the proof verification and per-action components. These constants are versioned protocol parameters and were rebalanced at protocol version 14. See the [protocol constants reference](../protocol-ref/protocol-constants.md) for the current values.

## User Fee Increase

Platform supports a user fee increase that can be used to incentivize inclusion of a state
transition in the next block, especially during periods of high traffic. This is expressed as an
integer percentage increase applied to the processing fee.

## Formula

The high level formula for a state transition's fee is:

```text
    fee = storageFee + processingFee + (processingFee * userFeeIncrease / 100) - storageRefund
```

The storage refund is netted against the total rather than clamped at zero. A state transition that frees more storage than it consumes produces a net credit to the identity instead of a charge.

<!-- Uncomment once DIP available
See *DIPXX: Dash Platform Fee System* for a detailed breakdown of each component.
-->
