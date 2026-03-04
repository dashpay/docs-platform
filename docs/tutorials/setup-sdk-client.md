# Setup SDK Client

In this tutorial we will show how to configure the client and key managers for use in the remaining
tutorials.

## Prerequisites

- [General prerequisites](../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)

## Code

Save the following module in a file named `sdkClient.mjs` for use in later tutorials. It exports
three things:

| Export | Purpose |
| ------ | -------- |
| `createClient()` | Connects to the network |
| `IdentityKeyManager` | Derives identity keys and provides signers for write operations |
| `AddressKeyManager` | Derives platform address keys for address operations |

```{code-block} javascript
:caption: sdkClient.mjs
:name: sdkClient.mjs

import {
  EvoSDK,
  IdentityPublicKeyInCreation,
  IdentitySigner,
  KeyType,
  PlatformAddressSigner,
  PrivateKey,
  Purpose,
  SecurityLevel,
  wallet,
} from '@dashevo/evo-sdk';

// ---------------------------------------------------------------------------
// SDK client helpers
// ---------------------------------------------------------------------------

export async function createClient(network = 'testnet') {
  const factories = {
    testnet: () => EvoSDK.testnetTrusted(),
    mainnet: () => EvoSDK.mainnetTrusted(),
    local: () => EvoSDK.localTrusted(),
  };

  const factory = factories[network];
  if (!factory) {
    throw new Error(
      `Unknown network "${network}". Use: ${Object.keys(factories).join(', ')}`,
    );
  }

  const sdk = factory();
  await sdk.connect();
  return sdk;
}

// ---------------------------------------------------------------------------
// IdentityKeyManager
// ---------------------------------------------------------------------------

const KEY_SPECS = [
  { keyId: 0, purpose: Purpose.AUTHENTICATION, securityLevel: SecurityLevel.MASTER },
  { keyId: 1, purpose: Purpose.AUTHENTICATION, securityLevel: SecurityLevel.HIGH },
  { keyId: 2, purpose: Purpose.AUTHENTICATION, securityLevel: SecurityLevel.CRITICAL },
  { keyId: 3, purpose: Purpose.TRANSFER, securityLevel: SecurityLevel.CRITICAL },
  { keyId: 4, purpose: Purpose.ENCRYPTION, securityLevel: SecurityLevel.MEDIUM },
];

class IdentityKeyManager {
  constructor(sdk, identityId, keys, identityIndex) {
    this.sdk = sdk;
    this.id = identityId;
    this.keys = keys;
    this.identityIndex = identityIndex ?? 0;
  }

  get identityId() {
    return this.id;
  }

  /**
   * Create from a BIP39 mnemonic for an existing on-chain identity.
   * If identityId is omitted, it is auto-resolved from the mnemonic.
   */
  static async create({
    sdk,
    identityId,
    mnemonic,
    network = 'testnet',
    identityIndex = 0,
  }) {
    const coin = network === 'testnet' ? 1 : 5;
    const derive = (keyIndex) =>
      wallet.deriveKeyFromSeedWithPath({
        mnemonic,
        path: `m/9'/${coin}'/5'/0'/0'/${identityIndex}'/${keyIndex}'`,
        network,
      });

    const [masterKey, authHighKey, authKey, transferKey, encryptionKey] =
      await Promise.all([derive(0), derive(1), derive(2), derive(3), derive(4)]);

    let resolvedId = identityId;
    if (!resolvedId) {
      const privateKey = PrivateKey.fromWIF(masterKey.toObject().privateKeyWif);
      const identity = await sdk.identities.byPublicKeyHash(
        privateKey.getPublicKeyHash(),
      );
      if (!identity) {
        throw new Error(
          'No identity found for the given mnemonic (key 0 public key hash)',
        );
      }
      resolvedId = identity.id.toString();
    }

    return new IdentityKeyManager(
      sdk,
      resolvedId,
      {
        master: { keyId: 0, privateKeyWif: masterKey.toObject().privateKeyWif },
        authHigh: { keyId: 1, privateKeyWif: authHighKey.toObject().privateKeyWif },
        auth: { keyId: 2, privateKeyWif: authKey.toObject().privateKeyWif },
        transfer: { keyId: 3, privateKeyWif: transferKey.toObject().privateKeyWif },
        encryption: { keyId: 4, privateKeyWif: encryptionKey.toObject().privateKeyWif },
      },
      identityIndex,
    );
  }

  /** Find the first unused DIP-9 identity index for a mnemonic. */
  static async findNextIndex(sdk, mnemonic, network = 'testnet') {
    const coin = network === 'testnet' ? 1 : 5;
    for (let i = 0; ; i += 1) {
      const key = await wallet.deriveKeyFromSeedWithPath({
        mnemonic,
        path: `m/9'/${coin}'/5'/0'/0'/${i}'/0'`,
        network,
      });
      const privateKey = PrivateKey.fromWIF(key.toObject().privateKeyWif);
      const existing = await sdk.identities.byPublicKeyHash(
        privateKey.getPublicKeyHash(),
      );
      if (!existing) return i;
    }
  }

  /**
   * Create for a new (not yet registered) identity.
   * Derives keys and stores public key data needed for identity creation.
   */
  static async createForNewIdentity({
    sdk,
    mnemonic,
    network = 'testnet',
    identityIndex,
  }) {
    const idx = identityIndex ??
      (await IdentityKeyManager.findNextIndex(sdk, mnemonic, network));
    const coin = network === 'testnet' ? 1 : 5;
    const derive = (keyIndex) =>
      wallet.deriveKeyFromSeedWithPath({
        mnemonic,
        path: `m/9'/${coin}'/5'/0'/0'/${idx}'/${keyIndex}'`,
        network,
      });

    const derivedKeys = await Promise.all(
      KEY_SPECS.map((spec) => derive(spec.keyId)),
    );

    const keys = {
      master: {
        keyId: 0,
        privateKeyWif: derivedKeys[0].toObject().privateKeyWif,
        publicKey: derivedKeys[0].toObject().publicKey,
      },
      authHigh: {
        keyId: 1,
        privateKeyWif: derivedKeys[1].toObject().privateKeyWif,
        publicKey: derivedKeys[1].toObject().publicKey,
      },
      auth: {
        keyId: 2,
        privateKeyWif: derivedKeys[2].toObject().privateKeyWif,
        publicKey: derivedKeys[2].toObject().publicKey,
      },
      transfer: {
        keyId: 3,
        privateKeyWif: derivedKeys[3].toObject().privateKeyWif,
        publicKey: derivedKeys[3].toObject().publicKey,
      },
      encryption: {
        keyId: 4,
        privateKeyWif: derivedKeys[4].toObject().privateKeyWif,
        publicKey: derivedKeys[4].toObject().publicKey,
      },
    };

    return new IdentityKeyManager(sdk, null, keys, idx);
  }

  /** Build IdentityPublicKeyInCreation objects for all 5 keys (for identity creation). */
  getKeysInCreation() {
    return KEY_SPECS.map((spec) => {
      const key = Object.values(this.keys).find((k) => k.keyId === spec.keyId);
      if (!key?.publicKey) {
        throw new Error(
          `Public key data not available for key ${spec.keyId}. Use createForNewIdentity().`,
        );
      }
      const pubKeyData = Uint8Array.from(Buffer.from(key.publicKey, 'hex'));
      return new IdentityPublicKeyInCreation({
        keyId: spec.keyId,
        purpose: spec.purpose,
        securityLevel: spec.securityLevel,
        keyType: KeyType.ECDSA_SECP256K1,
        data: pubKeyData,
      });
    });
  }

  /** Build an IdentitySigner loaded with all 5 key WIFs (for identity creation). */
  getFullSigner() {
    const signer = new IdentitySigner();
    Object.values(this.keys).forEach((key) => {
      signer.addKeyFromWif(key.privateKeyWif);
    });
    return signer;
  }

  /** Fetch identity and build { identity, identityKey, signer } for a given key. */
  async getSigner(keyName) {
    const key = this.keys[keyName];
    const identity = await this.sdk.identities.fetch(this.id);
    const identityKey = identity.getPublicKeyById(key.keyId);
    const signer = new IdentitySigner();
    signer.addKeyFromWif(key.privateKeyWif);
    return { identity, identityKey, signer };
  }

  /** CRITICAL auth (key 2) -- contracts, documents, names. */
  async getAuth() {
    return this.getSigner('auth');
  }

  /** HIGH auth (key 1) -- documents, names. */
  async getAuthHigh() {
    return this.getSigner('authHigh');
  }

  /** TRANSFER (key 3) -- credit transfers, withdrawals. */
  async getTransfer() {
    return this.getSigner('transfer');
  }

  /** ENCRYPTION (key 4) -- encrypted messaging/data. */
  async getEncryption() {
    return this.getSigner('encryption');
  }

  /** MASTER (key 0) -- identity updates (add/disable keys). */
  async getMaster(additionalKeyWifs) {
    const result = await this.getSigner('master');
    if (additionalKeyWifs) {
      additionalKeyWifs.forEach((wif) => result.signer.addKeyFromWif(wif));
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// AddressKeyManager
// ---------------------------------------------------------------------------

class AddressKeyManager {
  constructor(sdk, addresses, network) {
    this.sdk = sdk;
    this.addresses = addresses;
    this.network = network;
  }

  get primaryAddress() {
    return this.addresses[0];
  }

  /**
   * Create from a BIP39 mnemonic. Derives platform address keys using BIP44 paths.
   */
  static async create({ sdk, mnemonic, network = 'testnet', count = 1 }) {
    const coin = network === 'testnet' ? 1 : 5;
    const addresses = [];

    for (let i = 0; i < count; i += 1) {
      const path = `m/44'/${coin}'/0'/0/${i}`;
      const keyInfo = await wallet.deriveKeyFromSeedWithPath({
        mnemonic,
        path,
        network,
      });
      const obj = keyInfo.toObject();
      const privateKey = PrivateKey.fromWIF(obj.privateKeyWif);
      const signer = new PlatformAddressSigner();
      const platformAddress = signer.addKey(privateKey);

      addresses.push({
        address: platformAddress,
        bech32m: platformAddress.toBech32m(network),
        privateKeyWif: obj.privateKeyWif,
        path,
      });
    }

    return new AddressKeyManager(sdk, addresses, network);
  }

  /** Create a PlatformAddressSigner with the primary key loaded. */
  getSigner() {
    const signer = new PlatformAddressSigner();
    const privateKey = PrivateKey.fromWIF(this.primaryAddress.privateKeyWif);
    signer.addKey(privateKey);
    return signer;
  }

  /** Create a PlatformAddressSigner with all derived keys loaded. */
  getFullSigner() {
    const signer = new PlatformAddressSigner();
    this.addresses.forEach((addr) => {
      const privateKey = PrivateKey.fromWIF(addr.privateKeyWif);
      signer.addKey(privateKey);
    });
    return signer;
  }

  /** Fetch current balance and nonce for the primary address. */
  async getInfo() {
    return this.sdk.addresses.get(this.primaryAddress.bech32m);
  }
}

export { IdentityKeyManager, AddressKeyManager };
```

## What's Happening

The `sdkClient.mjs` module consolidates three concerns:

- **`createClient()`** handles connecting to the network. It creates an SDK instance configured for
  the chosen network (testnet, mainnet, or local) and establishes the connection.

- **`IdentityKeyManager`** derives 5 standard identity keys from your mnemonic using DIP-9 key
  paths. Each key serves a specific purpose (authentication, transfers, encryption). When you need
  to perform a write operation, you call a method like `getAuth()` which returns
  `{ identity, identityKey, signer }` -- everything the SDK needs to sign and submit the
  transaction.

- **`AddressKeyManager`** derives platform address keys from your mnemonic using BIP44 paths. These
  addresses hold credits on the L2 platform layer and are used for identity creation, top-ups, and
  credit transfers between addresses.

This module is imported in the following tutorials to streamline them and avoid repeating
client initialization and key management details.
