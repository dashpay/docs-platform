# Credit Withdrawal

**Usage**: `await client.platform.identities.creditWithdrawal(identity, amount, to, options)`

**Description**: This method facilitates the withdrawal of platform credits from a specified identity to a Dash address.

Parameters:

| Parameters        | Type              | Required | Description |
| ----------------- | ----------------- | -------- | ----------- |
| **identity**      | Identity          | Yes      | The identity withdrawing credits. |
| **amount**        | number            | Yes      | The amount of credits to withdraw. |
| **to**            | string            | Yes      | The Dash address receiving the withdrawn value. |
| **options**       | WithdrawalOptions | No       | Optional settings for the withdrawal, including `signingKeyIndex` (default: 2) to specify the key used for signing. |

**Example**:

```js
const identity = await client.platform.identities.get('yourIdentityId');
const toAddress = 'XyZ...abc'; // Dash L1 address to receive the withdrawn credits
const amount = 1000000; // Amount of credits to withdraw

await client.platform.identities.creditWithdrawal(identity, amount, toAddress, { signingKeyIndex: 2 });
```

**Note**:

- The `amount` must be greater than the `MINIMAL_WITHDRAWAL_AMOUNT` (190000 credits) to avoid dust errors from the Dash network.
- The `to` address must be valid in the specified Dash network environment (e.g., mainnet, testnet).

Returns: A promise that resolves to `true` upon successful execution of the credit withdrawal.
