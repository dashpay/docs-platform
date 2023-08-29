# Update an identity

Since Dash Platform v0.23, it is possible to update identities to add new keys or disable existing ones. Platform retains disabled keys so that any existing data they signed can still be verified while preventing them from signing new data. 

# Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic with some funds in it: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

# Code

The two examples below demonstrate updating an existing identity to add a new key and disabling an existing key:

> 🚧 
> 
> The current SDK version signs all state transitions with public key id `1`. If it is disabled, the SDK will be unable to use the identity. Future SDK versions will provide a way to also sign using keys added in an identity update.

::::{tab-set-code}

```javascript Disable identity key
// Disable identity key
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },    
  },
};
const client = new Dash.Client(clientOpts);

const updateIdentityDisableKey = async () => {
  const identityId = 'an identity ID goes here';
  const keyId = 'a public key ID goes here'; // One of the identity's public key IDs

  // Retrieve the identity to be updated and the public key to disable
  const existingIdentity = await client.platform.identities.get(identityId);
  const publicKeyToDisable = existingIdentity.getPublicKeyById(keyId);

  const updateDisable = {
    disable: [publicKeyToDisable],
  };

  await client.platform.identities.update(existingIdentity, updateDisable);
  return client.platform.identities.get(identityId);
}

updateIdentityDisableKey()
  .then((d) => console.log('Identity updated:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```
```javascript Add identity key
// Add identity key
const Dash = require('dash');
const { IdentityPublicKey, IdentityPublicKeyWithWitness } = require('@dashevo/wasm-dpp');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },    
  },
};
const client = new Dash.Client(clientOpts);

const updateIdentityAddKey = async () => {
  const identityId = 'an identity ID goes here';
  const existingIdentity = await client.platform.identities.get(identityId);
  const newKeyId = existingIdentity.toJSON().publicKeys.length;

  // Get an unused identity index
  const account = await client.platform.client.getWalletAccount();
  const identityIndex = await account.getUnusedIdentityIndex();

  // Get unused private key and construct new identity public key
  const { privateKey: identityPrivateKey } =
    account.identities.getIdentityHDKeyByIndex(identityIndex, 0);

  const identityPublicKey = identityPrivateKey.toPublicKey().toBuffer();

  const newPublicKey = new IdentityPublicKeyWithWitness({
    id: newKeyId,
    type: IdentityPublicKey.TYPES.ECDSA_SECP256K1,
    data: identityPublicKey,
    purpose: IdentityPublicKey.PURPOSES.AUTHENTICATION,
    securityLevel: IdentityPublicKey.SECURITY_LEVELS.CRITICAL,
    readOnly: false,
    signature: Buffer.alloc(0),
  });

  const updateAdd = {
    add: [newPublicKey],
  };

  // Submit the update signed with the new key
  await client.platform.identities.update(existingIdentity, updateAdd, {
    [newPublicKey.getId()]: identityPrivateKey,
  });

  return client.platform.identities.get(identityId);};
};

updateIdentityAddKey()
  .then((d) => console.log('Identity updated:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

::::

# What's Happening

## Disabling keys

After we initialize the Client, we retrieve our existing identity and provide the `id` of one (or more) of the identity keys to disable. The update is submitted to DAPI using the `platform.identities.update` method with two arguments:

1. An identity
2. An object containing the key(s) to be disabled

Internally, the method creates a State Transition containing the updated identity, signs the state transition, and submits the signed state transition to DAPI. After the identity is updated, we output it to the console.

## Adding keys

After we initialize the Client, we retrieve our existing identity and set an `id` for the key to be added. Next, we get an unused private key from our wallet and use it to derive a public key to add to our identity. The update is submitted to DAPI using the `platform.identities.update` method with three arguments:

1. An identity
2. An object containing the key(s) to be added
3. An object containing the id and private key for each public key being added

> 📘 
> 
> When adding new public keys, they must be signed using the associated private key to prove ownership of the keys.

Internally, the method creates a State Transition containing the updated identity, signs the state transition, and submits the signed state transition to DAPI. After the identity is updated, we output it to the console.