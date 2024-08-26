```{eval-rst}
.. _explanations-nft:
```

# Non-Fungible Tokens (NFTs)

## Overview

An NFT, or [Non-Fungible Token](https://en.wikipedia.org/wiki/Non-fungible_token), is a type of digital asset that represents something or someone in a unique way. Unlike cryptocurrencies such as Dash, where each unit is the same as every other unit, NFTs are unique and not interchangeable.

Although Dash Platform was not designed with NFTs in mind, it provides a solid foundation for NFT support. [Platform documents](../explanations/platform-protocol-document.md) share essential characteristics with NFTs and provide the core of Platform's NFT system. Each document has a unique identifier, similar to the token ID for ERC-721 NFTs. Documents store various data types, can be queried and indexed for efficient data retrieval and management, and allow ownership changes.

Platform's flexible design also provides more built-in management abilities than many alternative NFT solutions. For example, NFT creators can decide to make [mutable](#mutate) or [deletable](#delete) NFTs if their use-case benefits from those features. Also, the simple integrated [purchase system](#transfer-and-trade) provides NFT owners with a safe, decentralized option for selling their NFTs.

```{eval-rst}
.. _explanations-dash-nfts:
```

## Dash NFT Features

The following sections describe the features and options available for NFT creators using Dash Platform.

```{eval-rst}
.. _explanations-nft-transfer:
```

### Transfer and Trade

NFTs can be directly transferred or traded without the need for a marketplace:

* Transferring allows the owner to assign a new owner without making the NFT available for purchase.
* Trading involves a two-step process where the seller sets the NFT's price, and the first buyer that matches this price receives the NFT automatically. Once the transaction is complete, the price is reset to prevent further immediate purchases, ensuring a non-interactive and seamless trading experience.

```{eval-rst}
.. _explanations-nft-create-restrict:
```

### Creation Restrictions

To preserve the authenticity of NFTs, Dash Platform includes creation restriction options. This ensures that only authorized entities can create certain types of NFTs. For example, in the case of land ownership NFTs, a designated authority may be the only one that can issue tokens. Restriction options are:

* **Owner Only**: Only the contract owner can create NFTs (**_Note: this is the only option implemented for the initial release_**)
* **System Only**: Only the system can create NFTs (used for specific system contracts)
* **No Restrictions**: Anyone can create NFTs for the contract

```{eval-rst}
.. _explanations-nft-mutate:
```

### Mutate

NFTs can be immutable or mutable, depending on their intended use. Immutable NFTs cannot be altered after creation. This is crucial for items like digital artwork, where authenticity and originality are necessary. Mutable NFTs can be helpful in scenarios like updating a character in a game or altering a digital asset.

```{eval-rst}
.. _explanations-nft-delete:
```

### Delete

Since some NFTs may represent transient or consumable things, Dash Platform allows NFTs to be deleted. This is more efficient than the "burn" mechanism many projects use to make an NFT unusable and provides flexibility in managing assets that may no longer be needed or valid.

```{eval-rst}
.. _explanations-nft-create:
```

## NFT Creation

Creating an NFT on Dash Platform consists of creating a data contract, registering it on the network, and then creating NFT documents based on the schema defined in the data contract.

### Contract Setup

Structurally, there is no difference between an NFT contract and a non-NFT contract. While an NFT contract may set options that other contracts are unlikely to use, there is no other difference.

NFT contracts will often set document creation restrictions and enable document transfers. Default options for modifying, deleting, and transferring documents can be specified at the contract level and overridden as needed for specific document types.

Once the data contract design is completed, the contract can be registered on the network in preparation for NFT document creation. See the [contract registration tutorial](../tutorials/contracts-and-documents/register-a-data-contract.md) for example code.

### Minting NFTs

Tokens are minted by creating new documents under the data contract. Each token is an instance of one of the document types defined in the contract.

```{eval-rst}
.. _explanations-nft-trade:
```

## NFT Trading

The trading process for Dash Platform NFTs is designed to be user-friendly and efficient by enabling direct transactions between users without requiring trusted third parties.

Once an NFT is created, the owner can set a sale price to indicate the NFT is available for purchase. Interested buyers can then initiate a purchase by matching this set price. Upon completion of the transaction, the ownership of the NFT is automatically transferred to the buyer, and the sale price is reset to indicate the NFT is no longer available for purchase.

Since the functionality needed to set a price, buy, and transfer ownership of NFTs is part of the protocol, the system handles all necessary trading operations directly. This provides an efficient trading experience that is integrated with the indexing and proof capabilities of Dash Platform.
