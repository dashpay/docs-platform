# Update

**Usage**: `await client.platform.identities.update(identity, publicKeys, privateKeys)`

**Description**: This method updates an existing identity with new or disabled public keys. It signs and broadcasts an identity update transition to the network.

Parameters:

| Parameters     | Type                                  | Required | Description                                                                                         |
| -------------- | ------------------------------------- | -------- | --------------------------------------------------------------------------------------------------- |
| **identity**   | Identity                              | yes      | The identity object to update.                                                                     |
| **publicKeys** | { add?: IdentityPublicKey[]; disable?: IdentityPublicKey[] } | no       | An object containing arrays of `IdentityPublicKey` objects to add or disable.                      |
| **privateKeys**| Object<string, any>                   | yes when adding keys | An object mapping public key IDs to their corresponding private keys for signing the new keys.     |

**Example**:

```js
const identity = await client.platform.identities.get('yourIdentityId');
const publicKeysToDisable = ['2']; // IDs of public keys to disable

await client.platform.identities.update(identity, { disable: publicKeysToDisable });
```

**Note**:

- Adding a public key requires the corresponding private key to sign the new key addition.
- Disabling a key does not require its private key since the identity's key is used for the update transaction.
- Make sure the identity and keys are valid and the identity has sufficient balance for the transaction fees.

Returns: A promise that resolves to `true` upon successful broadcast of the identity update transition.
