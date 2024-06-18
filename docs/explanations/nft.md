```{eval-rst}
.. _explanations-nft:
```

# Non-Fungible Tokens (NFTs)

## Overview

An NFT, or [Non-Fungible Token](https://en.wikipedia.org/wiki/Non-fungible_token), is a type of digital asset that represents something or someone in a unique way. Unlike cryptocurrencies such as Dash, where each unit is the same as every other unit, NFTs are unique and not interchangeable.

Although Dash Platform was not designed with NFTs in mind, it provides a solid foundation for NFT support since [Platform documents](../explanations/platform-protocol-document.md) share essential characteristics with NFTs. Platform's flexible design also provides more built-in management abilities (e.g., mutating and deleting NFTs) than many alternative NFT solutions.

## Details

Documents provide the core of Dash Platform's NFT system. Each document has a unique identifier, similar to the token ID for ERC-721 NFTs. Documents store various data types, can be queried and indexed for efficient data retrieval and management, and allow ownership changes.

### Dash NFT Features

The following sections describe the features and options available for NFT creators using Dash Platform.

#### Transfer and Trade

NFTs can be transferred between parties without the need for a centralized marketplace. Currently, Dash Platform provides two ways to change ownership:

1. Transfer: NFT owners can directly assign a new owner without making the NFT available for purchase
2. Trade: NFT owners can make the NFT available for direct purchase or use a marketplace. Initially, only direct purchases will be supported.
   * Direct purchase: The owner sets the desired price. Anyone can purchase it for the requested price and receive ownership immediately (non-interactive)

#### Creation Restrictions

To preserve the authenticity of NFTs, Dash Platform includes creation restriction options. This ensures that only authorized entities can create certain types of NFTs. For example, in the case of land ownership NFTs, only a designated authority can issue these tokens. Restriction options are:

* **Owner Only**: Only the contract owner can create NFTs (**_Note: this is the only option implemented for the initial release_**)
* **System Only**: Only the system can create NFTs (used for specific system contracts)
* **No Restrictions**: Anyone can create NFTs for the contract

#### Mutate

NFTs can be immutable or mutable, depending on their intended use. Immutable NFTs cannot be altered after creation. This is crucial for items like digital artwork, where authenticity and originality are necessary. Mutable NFTs can be helpful in scenarios like updating a character in a game or altering a digital asset.

#### Delete

Since some NFTs may represent transient or consumable things, Dash Platform allows NFTs to be deleted. This is more efficient than the "burn" mechanism many projects use to make an NFT unusable. Deleting the NFT reduces storage overhead and lowers overall cost.


## NFT Definition and Structure

In the Dash system, NFTs are treated as specialized instances of platform documents. These documents are data structures that can represent any digital or real-world asset uniquely within the blockchain. Each NFT (document) is identifiable by a unique identifier, ensuring its distinctiveness across the platform.

### Key Properties of NFTs

1. **Unique Identifier**: Each NFT has a unique identifier, ensuring that no two NFTs are identical. This identifier is crucial for tracking, trading, and verifying ownership.

2. **Transferability**: NFTs can be transferred between parties without the need for a centralized marketplace. This transferability is implemented through specific state transitions that update the ownership status within the blockchain ledger.

3. **Mutability and Deletability**: NFTs can be configured to be mutable or immutable depending on the requirements of the asset they represent. For instance, a mutable NFT may allow updates to some of its data fields, while an immutable NFT does not permit any changes once created. Additionally, NFTs can be deletable, providing flexibility in managing assets that may no longer be needed or valid.

## Creation and Management of NFTs

The creation and ongoing management of NFTs are governed by specific rules and restrictions to maintain the integrity and value of the assets they represent.

### Creation Restrictions

To prevent unauthorized or fraudulent creation of high-value NFTs (such as those representing property or exclusive digital art), Dash implements creation restrictions. These restrictions can be set to allow only certain entities, such as verified administrators or smart contracts, to create NFTs. This ensures that the NFT marketplace remains trusted and verifiable.

### Administrative Control

NFTs on Dash can be administered at various levels:

- **Contract Level**: At the contract level, defaults can be set for properties like transferability, mutability, and deletability.
- **Document Type Level**: These settings can be overridden at the document type level for finer control, accommodating the specific needs of different NFT categories.

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
