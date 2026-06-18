```{eval-rst}
.. tutorials-mint-tokens:
```

# Mint tokens

The purpose of this tutorial is to walk through the steps necessary to mint (issue) new [tokens](../../explanations/tokens.md), increasing the total supply.

## Overview

Minting issues new tokens to the contract owner, increasing the token's total supply up to its maximum. Minting is only possible when the token contract authorizes it, which the [Register a token contract](register-a-token-contract.md) tutorial sets up. Additional details are available in the [tokens explanation](../../explanations/tokens.md) and the [token protocol reference](../../protocol-ref/token.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A registered token contract: [Tutorial: Register a token contract](register-a-token-contract.md). Set the resulting contract ID as the `TOKEN_CONTRACT_ID` environment variable.

## Code

```{code-block} javascript
:caption: token-mint.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

// TOKEN_CONTRACT_ID comes from token-register.mjs.
const dataContractId = process.env.TOKEN_CONTRACT_ID;
const tokenPosition = 0;
const amount = 10n; // Token amounts are bigint values

try {
  if (!dataContractId) {
    throw new Error(
      'Set TOKEN_CONTRACT_ID in .env from token-register.mjs output.',
    );
  }

  const tokenId = await sdk.tokens.calculateId(dataContractId, tokenPosition);

  await sdk.tokens.mint({
    dataContractId,
    tokenPosition,
    amount,
    identityId: identity.id.toString(),
    identityKey,
    signer,
  });

  const balances = await sdk.tokens.identityBalances(identity.id, [tokenId]);
  const totalSupply = await sdk.tokens.totalSupply(tokenId);

  console.log(`Minted ${amount} tokens`);
  console.log('Token ID:', tokenId);
  console.log(`Identity token balance: ${balances.get(tokenId) ?? 0n}`);
  console.log('Total token supply:', totalSupply?.totalSupply ?? 0n);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we get the auth key signer with `keyManager.getAuth()`. We then call `sdk.tokens.mint()` with the contract ID, token position, amount, and signing credentials to issue 10 new tokens to our identity. Token amounts are `bigint` values, which is why `10n` is written with the `n` suffix.

After minting, we read back the identity's balance with `sdk.tokens.identityBalances()` and the new total supply with `sdk.tokens.totalSupply()` to confirm both have increased.
