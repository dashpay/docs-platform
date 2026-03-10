```{eval-rst}
.. tutorials-update-identity:
```

# Update an identity

It is possible to update identities to add new keys or disable existing ones. Platform retains disabled keys so that any existing data they signed can still be verified while preventing them from signing new data.

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

The two examples below demonstrate updating an existing identity to disable an existing key and to add a new key:

:::{attention}
The identity's master key must be used to sign identity update state transitions.
:::

::::{tab-set}
:::{tab-item} Disable identity key

```{code-block} javascript
:caption: identity-update-disable-key.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, signer } = await keyManager.getMaster();

const KEY_ID = 99; // Replace with one of the identity's existing public key IDs

console.log(`Disabling key ${KEY_ID} on identity ${keyManager.identityId}...`);

try {
  await sdk.identities.update({
    identity,
    disablePublicKeys: [KEY_ID], // Disable public key id KEY_ID
    signer,
  });

  const updatedIdentity = await sdk.identities.fetch(keyManager.identityId);
  console.log('Identity updated:\n', updatedIdentity.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```
:::

:::{tab-item} Add identity key

```{code-block} javascript
:caption: identity-update-add-key.mjs

import {
  IdentityPublicKeyInCreation,
  KeyType,
  Purpose,
  SecurityLevel,
  wallet,
} from '@dashevo/evo-sdk';
import { setupDashClient, clientConfig, dip13KeyPath } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();

// Fetch identity to determine the next available key ID
const { identity, signer } = await keyManager.getMaster();
const existingKeys = identity.toJSON().publicKeys;
const newKeyId = Math.max(...existingKeys.map((k) => k.id)) + 1;

console.log(`Adding key ${newKeyId} to identity ${keyManager.identityId}...`);

// Derive the new key using the standard DIP-13 path
const newKeyPath = await dip13KeyPath(
  clientConfig.network,
  keyManager.identityIndex,
  newKeyId,
);
const newKeyInfo = await wallet.deriveKeyFromSeedWithPath({
  mnemonic: clientConfig.mnemonic,
  path: newKeyPath,
  network: clientConfig.network,
});
const newKeyObj = newKeyInfo.toObject();

// Build the new public key
const newPublicKey = new IdentityPublicKeyInCreation({
  keyId: newKeyId,
  purpose: Purpose.AUTHENTICATION,
  securityLevel: SecurityLevel.HIGH,
  keyType: KeyType.ECDSA_SECP256K1,
  data: Uint8Array.from(Buffer.from(newKeyObj.publicKey, 'hex')),
});

// Add the new key's WIF to the signer so it can co-sign
signer.addKeyFromWif(newKeyObj.privateKeyWif);

try {
  await sdk.identities.update({
    identity,
    addPublicKeys: [newPublicKey],
    signer,
  });

  const updatedIdentity = await sdk.identities.fetch(keyManager.identityId);
  console.log('Identity updated:\n', updatedIdentity.toJSON());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```
:::
::::

## What's Happening

### Disabling keys

After connecting to the client, we get the master key signer from the key manager. We specify the key ID to disable and call `sdk.identities.update()` with an array of key IDs to disable. The updated identity is then fetched and logged to confirm the change.

### Adding keys

After connecting to the client, we get the master key signer and inspect the identity's existing keys to determine the next available key ID. We then derive a new key using the DIP-13 derivation path, build an `IdentityPublicKeyInCreation` object, and add the new key's WIF to the signer so it can co-sign (proving ownership). Finally, we call `sdk.identities.update()` with the new public key to add.

:::{note}
When adding new public keys, they must be signed using the associated private key to prove ownership of the keys.
:::
