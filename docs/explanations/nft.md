```{eval-rst}
.. _explanations-nft:
```

# Non-Fungible Tokens (NFTs)

## Overview

The Non-Fungible Token (NFT) system on Dash utilizes platform's unique capability of handling "platform documents" to manage and operationalize NFTs. Below, we detail the core aspects of how NFTs are implemented within the Dash ecosystem, focusing on their creation, management, and usage.

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
