```{eval-rst}
.. tutorials-create-wallet:
```

# Create and fund a wallet

In order to make create an identity on Dash Platform, you need a platform address with a balance. This tutorial explains how to generate a new wallet, derive a platform address from it, and transfer test funds to the address.

## Prerequisites

- [General prerequisites](../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)

# Code

```{code-block} javascript
:caption: generateWallet.mjs

import { wallet, PlatformAddressSigner, PrivateKey } from '@dashevo/evo-sdk';

const network = 'testnet';

try {
  const mnemonic = await wallet.generateMnemonic();
  const pathInfo = network === 'testnet'
  ? await wallet.derivationPathBip44Testnet(0, 0, 0)
  : await wallet.derivationPathBip44Mainnet(0, 0, 0);

  // Derive the first BIP44 key to get a platform address
  const keyInfo = await wallet.deriveKeyFromSeedWithPath({
    mnemonic,
    path: pathInfo.path,
    network,
  });

  // Get the platform address (bech32m) from the private key
  const privateKey = PrivateKey.fromWIF(keyInfo.toObject().privateKeyWif);
  const signer = new PlatformAddressSigner();
  const address = signer.addKey(privateKey).toBech32m(network);

  // ⚠️ Never log mnemonics in real applications
  console.log('Mnemonic:', mnemonic);
  console.log('Platform address:', address);
  console.log('Fund address using:', `https://bridge.thepasta.org/?address=${address}`);
} catch (e) {
  console.error('Something went wrong:', e.message);
}
```

```text
Mnemonic: toilet kingdom uncover super company economy jump fence car later exact multiply
Platform address: tdash1kpk3fhjfj884gz6zmjj42m9udmvp2mg5rsdx8zhr
Fund address using: https://bridge.thepasta.org/?address=tdash1kpk3fhjfj884gz6zmjj42m9udmvp2mg5rsdx8zhr
```

:::{attention}
Please save your mnemonic for the next step and for re-use in subsequent tutorials throughout the documentation.
:::

# What's Happening

We use the SDK's `wallet` utilities to generate a BIP39 mnemonic phrase, then derive a platform
address from it using the BIP44 derivation path. Platform addresses are bech32m-encoded addresses
(prefixed with `tdash1` on testnet) that hold credits directly on Dash Platform.

# Next Step

Using the [Core -> Platform bridge](https://bridge.thepasta.org/), send test funds to the platform
address from the console output.
