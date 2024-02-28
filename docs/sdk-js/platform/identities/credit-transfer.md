# Credit Transfer

**Usage**: `await client.platform.identities.creditTransfer(identity, recipientId, amount)`

**Description**: Transfers credits from one identity to another within the Dash Platform.

Parameters:

| Parameters   | Type                | Required | Description                                                                 |
| ------------ | ------------------- | -------- | --------------------------------------------------------------------------- |
| **identity** | Identity            | Yes      | The identity object initiating the transfer.                                |
| **recipientId** | Identifier \| string | Yes      | The identifier of the recipient identity. Can be an Identifier object or a string. |
| **amount**   | number              | Yes      | The amount of credits to transfer.                                          |

**Example**:

```js
const identity = await client.platform.identities.get('yourIdentityId');
const recipientId = 'recipientIdentityId'; // The recipient's identity ID.
const amount = 1000; // Amount of credits to transfer.

await client.platform.identities.creditTransfer(identity, recipientId, amount);
```

**Note**:

- Ensure both the sender and recipient identities are registered on Dash Platform.
- The amount must be less than the available balance of the identity initiating the transfer.
- Transfers are irreversible once broadcasted.

Returns: A promise that resolves to `true` upon successful execution of the credit transfer.
