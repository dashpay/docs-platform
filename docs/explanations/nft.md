```{eval-rst}
.. _explanations-nft:
```

# Non-Fungible Tokens (NFTs)

## Overview

An NFT, or [Non-Fungible Token](https://en.wikipedia.org/wiki/Non-fungible_token), is a type of digital asset that represents something or someone in a unique way. Unlike cryptocurrencies such as Dash, where each unit is the same as every other unit, NFTs are unique and not interchangeable.

Although Dash Platform was not designed with NFTs in mind, it provides a solid foundation for NFT support. [Platform documents](../explanations/platform-protocol-document.md) share essential characteristics with NFTs and provide the core of Platform's NFT system. Each document has a unique identifier, similar to the token ID for ERC-721 NFTs. Documents store various data types, can be queried and indexed for efficient data retrieval and management, and allow ownership changes.

Platform's flexible design also provides more built-in management abilities than many alternative NFT solutions. For example, NFT creators can decide to make [mutable](#mutate) or [deletable](#delete) NFTs if their use-case benefits from those features. Also, the simple integrated [purchase system](#transfer-and-trade) provides NFT owners with a safe, decentralized option for selling their NFTs.

## Dash NFT Features

The following sections describe the features and options available for NFT creators using Dash Platform.

### Transfer and Trade

NFTs can be directly transferred or traded without the need for a marketplace:

* Transferring allows the owner to simply assign a new owner without making the NFT available for purchase.
* Trading involves a two-step process where the seller sets the NFT's price, and the first buyer that matches this price receives the NFT automatically. Once the transaction is complete, the price is reset to prevent further immediate purchases, ensuring a non-interactive and seamless trading experience.

### Creation Restrictions

To preserve the authenticity of NFTs, Dash Platform includes creation restriction options. This ensures that only authorized entities can create certain types of NFTs. For example, in the case of land ownership NFTs, a designated authority may be the only one that can issue tokens. Restriction options are:

* **Owner Only**: Only the contract owner can create NFTs (**_Note: this is the only option implemented for the initial release_**)
* **System Only**: Only the system can create NFTs (used for specific system contracts)
* **No Restrictions**: Anyone can create NFTs for the contract

### Mutate

NFTs can be immutable or mutable, depending on their intended use. Immutable NFTs cannot be altered after creation. This is crucial for items like digital artwork, where authenticity and originality are necessary. Mutable NFTs can be helpful in scenarios like updating a character in a game or altering a digital asset.

### Delete

Since some NFTs may represent transient or consumable things, Dash Platform allows NFTs to be deleted. This is more efficient than the "burn" mechanism many projects use to make an NFT unusable and  provides flexibility in managing assets that may no longer be needed or valid.

## NFT Creation

Creating an NFT on Dash Platform consists of creating a data contract, registering it on the network, and then creating NFT documents based on the schema defined in the data contract.

### Contract Setup

Structurally, there is no difference between an NFT contract and a non-NFT contract. While an NFT contract may set options that other contracts are unlikely to use, there is no other difference.

NFT contracts will often set document creation restrictions and enable document transfers. Default options for modifying, deleting, and transferring documents can be specified at the contract level and overridden as-needed for specific document types.

Once the data contract design is completed, the contract can be registered on the network in preparation for NFT document creation.

### Minting NFTs

Tokens are minted by creating new documents under the data contract. Each token is an instance of one of the document types defined in the contract.

## Operational Mechanisms

### State Transitions

NFTs change states through predefined transactions:

- **Creation**: A new NFT is minted when a document is created under a specific contract with its unique properties.
- **Update Price**: Sellers can set or update the price of an NFT, preparing it for sale.
- **Purchase**: Transfer of ownership occurs through a purchase transaction where the buyer matches the set price, and ownership details are updated atomically.

## Practical Use Cases

Dash's flexible NFT framework supports various use cases from digital art and collectibles to more complex applications like real estate and identity verification. Each use case can utilize the core features of the NFT system, customized through the platform document properties to meet specific needs.

## Conclusion

Dash's NFT system leverages the blockchain's inherent security and transparency features while providing a flexible and robust framework for managing non-fungible assets. This system not only facilitates the easy creation and trade of digital assets but also ensures that they can be managed with high levels of trust and efficiency.
