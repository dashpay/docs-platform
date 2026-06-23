```{eval-rst}
.. tutorials-transfer-tokens-to-identity:
```

# Transfer tokens to an identity

The purpose of this tutorial is to walk through the steps necessary to transfer [tokens](../../explanations/tokens.md) from one identity to another.

## Overview

Transferring moves tokens from the sender's balance to a recipient identity. The total supply is unchanged; only the balances of the two identities are affected. Additional details are available in the [tokens explanation](../../explanations/tokens.md) and the [token protocol reference](../../protocol-ref/token.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A registered token contract with a balance to transfer: [Tutorial: Register a token contract](register-a-token-contract.md). Set the resulting contract ID as the `TOKEN_CONTRACT_ID` environment variable.
- A second Dash Platform Identity to receive the tokens: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```{code-block} javascript
:caption: token-transfer.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getTransfer();

// TOKEN_CONTRACT_ID comes from token-register.mjs.
const dataContractId = process.env.TOKEN_CONTRACT_ID;
const tokenPosition = 0;

// Default recipient (testnet). Replace or override via RECIPIENT_ID.
const recipientId =
  process.env.RECIPIENT_ID || '7XcruVSsGQVSgTcmPewaE4tXLutnW1F6PXxwMbo8GYQC';
const amount = 1n;

try {
  if (!dataContractId) {
    throw new Error(
      'Set TOKEN_CONTRACT_ID in .env from token-register.mjs output.',
    );
  }

  const senderId = identity.id.toString();
  if (recipientId === senderId) {
    throw new Error('Cannot transfer tokens to yourself.');
  }

  const tokenId = await sdk.tokens.calculateId(dataContractId, tokenPosition);
  const balancesBefore = await sdk.tokens.identityBalances(recipientId, [
    tokenId,
  ]);

  console.log(
    `Recipient token balance before transfer: ${balancesBefore.get(tokenId) ?? 0n}`,
  );

  await sdk.tokens.transfer({
    dataContractId,
    tokenPosition,
    amount,
    senderId,
    recipientId,
    identityKey,
    signer,
  });

  const balancesAfter = await sdk.tokens.identityBalances(recipientId, [
    tokenId,
  ]);

  console.log(
    `Transferred ${amount} token${amount === 1n ? '' : 's'} from ${senderId} to ${recipientId}`,
  );
  console.log('Token ID:', tokenId);
  console.log(
    `Recipient token balance after transfer: ${balancesAfter.get(tokenId) ?? 0n}`,
  );
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we get the transfer key signer with `keyManager.getTransfer()`. Token transfers are authorized with the identity's transfer key rather than its auth key.

We derive the token ID with `sdk.tokens.calculateId()` and read the recipient's balance before the transfer so the change is visible. A guard rejects transfers where the recipient matches the sender, since an identity cannot transfer tokens to itself.

We then call `sdk.tokens.transfer()` with the contract ID, token position, amount, sender ID, recipient ID, and signing credentials to move 1 token. After the transfer, we read the recipient's balance again with `sdk.tokens.identityBalances()` to confirm it increased. The recipient defaults to a demo testnet identity, but set `RECIPIENT_ID` in the .env file to your own second identity when you want to verify a transfer to an identity you control.

:::{tip}
See this in an example app: [DashMint Lab — Transfer DashMint tokens](../example-apps/dashmint-lab.md#transfer-dashmint-tokens).
:::
