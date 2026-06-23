```{eval-rst}
.. tutorials-register-token-contract:
```

# Register a token contract

The purpose of this tutorial is to walk through the steps necessary to register a [token](../../explanations/tokens.md) on Dash Platform.

## Overview

Tokens on Dash Platform are defined inside a [data contract](../../explanations/platform-protocol-data-contract.md). A single contract can carry one or more tokens alongside its document types, and each token is identified by its position within the contract. Registering the contract creates the token, sets its supply limits, and establishes the rules that control who may mint, burn, transfer, or otherwise manage it.

This tutorial registers an issuer-managed token: the contract owner controls minting and burning, and newly minted tokens always go to the owner identity. The token is not configured with advanced options. That keeps this tutorial focused on the normal token lifecycle used by the remaining token tutorials. Additional details are available in the [tokens explanation](../../explanations/tokens.md) and the [token protocol reference](../../protocol-ref/token.md).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A platform address with a balance: [Tutorial: Create and Fund a Wallet](../../tutorials/create-and-fund-a-wallet.md)
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```{code-block} javascript
:caption: token-register.mjs

import {
  AuthorizedActionTakers,
  ChangeControlRules,
  DataContract,
  TokenConfiguration,
  TokenConfigurationConvention,
  TokenConfigurationLocalization,
  TokenDistributionRules,
  TokenKeepsHistoryRules,
  TokenMarketplaceRules,
  TokenTradeMode,
} from '@dashevo/evo-sdk';
import { setupDashClient } from '../setupDashClient.mjs';

const { sdk, keyManager } = await setupDashClient();
const { identity, identityKey, signer } = await keyManager.getAuth();

const TOKEN_POSITION = 0;
const TOKEN_NAME = 'TutorialToken';
const TOKEN_PLURAL = 'TutorialTokens';
const TOKEN_BASE_SUPPLY = 100n; // Token amounts are bigint values
const TOKEN_MAX_SUPPLY = 1000n;

// This contract includes one small document type so learners can still use the
// standard document tutorials with the same contract if they want to.
const documentSchemas = {
  note: {
    type: 'object',
    properties: {
      message: {
        type: 'string',
        position: 0,
      },
    },
    additionalProperties: false,
  },
};

function createTutorialTokenConfiguration(ownerId) {
  const contractOwner = AuthorizedActionTakers.ContractOwner();
  const noOne = AuthorizedActionTakers.NoOne();

  const ownerRules = new ChangeControlRules({
    authorizedToMakeChange: contractOwner,
    adminActionTakers: contractOwner,
    isChangingAuthorizedActionTakersToNoOneAllowed: true,
    isChangingAdminActionTakersToNoOneAllowed: true,
    isSelfChangingAdminActionTakersAllowed: true,
  });
  const lockedRules = new ChangeControlRules({
    authorizedToMakeChange: noOne,
    adminActionTakers: noOne,
  });

  return new TokenConfiguration({
    conventions: new TokenConfigurationConvention(
      {
        en: new TokenConfigurationLocalization(false, TOKEN_NAME, TOKEN_PLURAL),
      },
      0,
    ),
    conventionsChangeRules: ownerRules,
    baseSupply: TOKEN_BASE_SUPPLY,
    maxSupply: TOKEN_MAX_SUPPLY,
    keepsHistory: new TokenKeepsHistoryRules({
      isKeepingBurningHistory: true,
      isKeepingMintingHistory: true,
      isKeepingTransferHistory: true,
    }),
    maxSupplyChangeRules: lockedRules,
    distributionRules: new TokenDistributionRules({
      newTokensDestinationIdentity: ownerId,
      newTokensDestinationIdentityRules: ownerRules,
      mintingAllowChoosingDestination: false,
      mintingAllowChoosingDestinationRules: ownerRules,
      perpetualDistributionRules: lockedRules,
      changeDirectPurchasePricingRules: lockedRules,
    }),
    marketplaceRules: new TokenMarketplaceRules(
      TokenTradeMode.NotTradeable(),
      lockedRules,
    ),
    // Minting and burning are enabled so the next tutorials can demonstrate
    // the normal issuer-managed token lifecycle.
    manualMintingRules: ownerRules,
    manualBurningRules: ownerRules,
    freezeRules: lockedRules,
    unfreezeRules: lockedRules,
    destroyFrozenFundsRules: lockedRules,
    emergencyActionRules: lockedRules,
    mainControlGroupCanBeModified: noOne,
    description: 'Issuer-managed token for Platform token tutorials.',
  });
}

try {
  const identityNonce = await sdk.identities.nonce(identity.id.toString());

  const dataContract = new DataContract({
    ownerId: identity.id,
    identityNonce: (identityNonce || 0n) + 1n,
    schemas: documentSchemas,
    tokens: {
      [TOKEN_POSITION]: createTutorialTokenConfiguration(
        identity.id.toString(),
      ),
    },
    fullValidation: true,
  });

  const publishedContract = await sdk.contracts.publish({
    dataContract,
    identityKey,
    signer,
  });

  const contractId =
    publishedContract.id?.toString() || publishedContract.toJSON?.()?.id;

  if (!contractId) {
    const publishResult = publishedContract.toJSON?.() ?? publishedContract;
    throw new Error(
      `Contract publish returned no id: ${JSON.stringify(publishResult)}`,
    );
  }

  const tokenId = await sdk.tokens.calculateId(contractId, TOKEN_POSITION);

  console.log('Token contract registered:\n', publishedContract.toJSON());
  console.log('Token position:', TOKEN_POSITION);
  console.log('Token ID:', tokenId);
  console.log('Initial owner token balance:', TOKEN_BASE_SUPPLY.toString());
  console.log('Maximum token supply:', TOKEN_MAX_SUPPLY.toString());
} catch (e) {
  console.error('Something went wrong:\n', e.message);
}
```

:::{attention}
Make a note of the returned contract ID. The remaining token tutorials read it from the `TOKEN_CONTRACT_ID` environment variable, so set it before running them.

Use the contract ID from the published contract output, not the token ID printed at the end:

```text
TOKEN_CONTRACT_ID=<contract-id-from-token-register-output>
```
:::

## What's Happening

After initializing the client, we get the auth key signer from the key manager. We then register a data contract that carries a token at position 0. The token starts with a base supply of 100 (minted to the owner) and a maximum supply of 1,000. Token amounts are always `bigint` values, which is why they are written with the `n` suffix (for example, `100n`).

Minting and burning are enabled and restricted to the contract owner, so the [mint](mint-tokens.md) and [burn](burn-tokens.md) tutorials work out of the box. The token also keeps a full history of mints, burns, and transfers.

To register the contract, we fetch the identity's current nonce and increment it, build a `DataContract` with the document schemas and the token configuration, and call `sdk.contracts.publish()`. Finally, we derive the token ID from the contract ID and token position with `sdk.tokens.calculateId()`.

:::{dropdown} Token configuration details
The token's behaviour is defined by a `TokenConfiguration`. Each group of rules is a `ChangeControlRules` object that says who may perform an action and who may change that permission. The tutorial uses two presets:

- `ownerRules` — the contract owner is authorized (`AuthorizedActionTakers.ContractOwner()`).
- `lockedRules` — no one is authorized (`AuthorizedActionTakers.NoOne()`), permanently disabling the action.

The main groups:

- **Supply** — `baseSupply` is minted to the owner at registration; `maxSupply` caps the total. `maxSupplyChangeRules` is locked, so the cap cannot be changed later.
- **Minting and burning** — `manualMintingRules` and `manualBurningRules` use `ownerRules`, letting the owner issue and destroy tokens.
- **History** — `keepsHistory` records minting, burning, and transfer events so they can be queried later.
- **Distribution** — `distributionRules` sends newly minted tokens to the owner (`newTokensDestinationIdentity`) and prevents minting from choosing a different destination (`mintingAllowChoosingDestination: false`). Perpetual distribution is locked, so there is no automated recurring distribution.
- **Marketplace and pricing** — `marketplaceRules` uses `TokenTradeMode.NotTradeable()`, so the token cannot be listed for direct purchase, and the trade mode itself is locked. The permission to set a direct-purchase price (`changeDirectPurchasePricingRules`, defined with the distribution rules) is also locked.
- **Freeze and emergency actions** — `freezeRules`, `unfreezeRules`, `destroyFrozenFundsRules`, and `emergencyActionRules` are locked in this example.

See the [tokens explanation](../../explanations/tokens.md) and the [token protocol reference](../../protocol-ref/token.md) for the full set of configuration fields.
:::

:::{tip}
See this in an example app: [DashMint Lab — Contract schema](../example-apps/dashmint-lab.md#contract-schema) defines a token alongside its NFT documents, and [DashMint Lab — DashMint token flow](../example-apps/dashmint-lab.md#dashmint-token-flow) shows how the token is used.
:::
