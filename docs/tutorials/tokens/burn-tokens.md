```{eval-rst}
.. tutorials-burn-tokens:
```

# Burn tokens

The purpose of this tutorial is to walk through the steps necessary to burn (permanently destroy) [tokens](../../explanations/tokens.md), reducing the total supply.

## Overview

Burning permanently removes tokens from circulation, decreasing the token's total supply. Burning is only possible when the token contract authorizes it, which the [Register a token contract](register-a-token-contract.md) tutorial sets up. Additional details are available in the [tokens explanation](../../explanations/tokens.md) and the [token protocol reference](../../protocol-ref/token.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A registered token contract with a balance to burn: [Tutorial: Register a token contract](register-a-token-contract.md). Set the resulting contract ID as the `TOKEN_CONTRACT_ID` environment variable.

## Code

```{code-block} javascript
:caption: token-burn.mjs

import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

// TOKEN_CONTRACT_ID comes from token-register.mjs.
const dataContractId = process.env.TOKEN_CONTRACT_ID;
const tokenPosition = 0;
const amount = 1n; // Token amounts are bigint values

try {
  if (!dataContractId) {
    throw new Error(
      'Set TOKEN_CONTRACT_ID in .env from token-register.mjs output.',
    );
  }

  const tokenId = await sdk.tokens.calculateId(dataContractId, tokenPosition);

  await sdk.tokens.burn({
    dataContractId,
    tokenPosition,
    amount,
    identityId: identity.id.toString(),
    identityKey,
    signer,
  });

  const balances = await sdk.tokens.identityBalances(identity.id, [tokenId]);
  const totalSupply = await sdk.tokens.totalSupply(tokenId);

  console.log(`Burned ${amount} token`);
  console.log('Token ID:', tokenId);
  console.log(`Identity token balance: ${balances.get(tokenId) ?? 0n}`);
  console.log('Total token supply:', totalSupply?.totalSupply ?? 0n);
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

## What's Happening

After connecting to the client, we get the auth key signer with `keyManager.getAuth()`. We then call `sdk.tokens.burn()` with the contract ID, token position, amount, and signing credentials to destroy 1 token from our balance. Token amounts are `bigint` values, which is why `1n` is written with the `n` suffix.

After burning, we read back the identity's balance with `sdk.tokens.identityBalances()` and the new total supply with `sdk.tokens.totalSupply()` to confirm both have decreased.
