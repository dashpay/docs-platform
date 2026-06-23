```{eval-rst}
.. tutorials-retrieve-token-info:
```

# Retrieve token info

The purpose of this tutorial is to walk through the steps necessary to retrieve information about a [token](../../explanations/tokens.md), including its contract details, total supply, status, and identity balances.

## Overview

Once a token contract is registered, its metadata and balances can be queried without submitting a state transition. This tutorial retrieves the token's contract info, total supply, status, and the token balances held by two identities. Additional details are available in the [tokens explanation](../../explanations/tokens.md) and the [token protocol reference](../../protocol-ref/token.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A registered token contract: [Tutorial: Register a token contract](register-a-token-contract.md). Set the resulting contract ID as the `TOKEN_CONTRACT_ID` environment variable.

## Code

```{code-block} javascript
:caption: token-info.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();

// TOKEN_CONTRACT_ID comes from token-register.mjs.
const dataContractId = process.env.TOKEN_CONTRACT_ID;
const tokenPosition = 0;

// Default recipient (testnet). Replace or override via RECIPIENT_ID.
const recipientId =
  process.env.RECIPIENT_ID || '7XcruVSsGQVSgTcmPewaE4tXLutnW1F6PXxwMbo8GYQC';

try {
  if (!dataContractId) {
    throw new Error(
      'Set TOKEN_CONTRACT_ID in .env from token-register.mjs output.',
    );
  }

  const tokenId = await sdk.tokens.calculateId(dataContractId, tokenPosition);
  const contractInfo = await sdk.tokens.contractInfo(tokenId);
  const totalSupply = await sdk.tokens.totalSupply(tokenId);
  const statuses = await sdk.tokens.statuses([tokenId]);
  const identityBalances = await sdk.tokens.identityBalances(
    keyManager.identityId,
    [tokenId],
  );
  const recipientBalances = await sdk.tokens.identityBalances(recipientId, [
    tokenId,
  ]);

  // A token only has a status record once one is published on-chain (e.g. via
  // an emergency pause), so the Map is empty for a freshly registered token.
  const status = statuses.get(tokenId);

  console.log('Token ID:', tokenId);
  console.log('Token contract info:\n', contractInfo?.toJSON());
  console.log(
    'Token status:',
    status ? status.isPaused : '(no status published)',
  );
  console.log('Total token supply:', totalSupply?.totalSupply ?? 0n);
  console.log(`Identity token balance: ${identityBalances.get(tokenId) ?? 0n}`);
  console.log(
    `Recipient token balance: ${recipientBalances.get(tokenId) ?? 0n}`,
  );
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we derive the token ID from the contract ID and token position with `sdk.tokens.calculateId()`. We then query several pieces of information:

- `sdk.tokens.contractInfo()` returns the token's contract metadata.
- `sdk.tokens.totalSupply()` returns the number of tokens currently in circulation.
- `sdk.tokens.statuses()` returns a Map of token statuses. A status record only exists once one is published on-chain (for example, after an emergency pause), so the Map is empty for a freshly registered token. We fall back to `(no status published)` in that case.
- `sdk.tokens.identityBalances()` returns each identity's token balance, keyed by token ID.

The recipient defaults to a demo testnet identity so the script can run without extra setup. Set `RECIPIENT_ID` in the .env file to your own second identity when you want the recipient balance check to reflect an identity you control.

:::{tip}
See this in an example app: [DashMint Lab — DashMint token flow](../example-apps/dashmint-lab.md#dashmint-token-flow) reads the signed-in identity's token balance to display remaining mint capacity.
:::
