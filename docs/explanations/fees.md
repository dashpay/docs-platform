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

Given fluctuations of the Dash price, a variable *Fee Multiplier* provides a way to balance the cost of fees with network hosting requirements. All fees are multiplied by the Fee Multiplier:

```text
    feePaid = initialFee * feeMultiplier
```

The Fee Multiplier is subject to change at any time via network governance and protocol updates.

<!-- Uncomment once link available
An in-depth look at the Fee Multiplier can be found at **link**
-->

## Storage Refund

In an attempt to minimize Dash Platform's storage requirements, users are incentivized to remove data that they no longer want to be stored in the Dash Platform state for a refund. Data storage fees are distributed to masternodes over the data's lifetime which is 50 years for permanent storage. Therefore, at any time before the data's fees are entirely distributed, there will be fees remaining which can be refunded to the user if they decide to delete the data.

## User Fee Increase

Platform supports a user fee increase that can be used to incentivize inclusion of a state
transition in the next block, especially during periods of high traffic. This is expressed as an
integer percentage increase applied to the processing fee.

## Formula

The high level formula for a state transition's fee is:

```text
    fee = storageFee + processingFee + (processingFee * userFeeIncrease / 100) - storageRefund
```

<!-- Uncomment once DIP available
See *DIPXX: Dash Platform Fee System* for a detailed breakdown of each component.
-->
