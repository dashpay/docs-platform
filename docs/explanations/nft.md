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

NFTs can be directly transferred or traded without the need for a marketplace, provided the contract author enabled those options on the document type. Trading is off by default.

* Transferring allows the owner to assign a new owner without making the NFT available for purchase.
* Trading involves a two-step process where the seller sets the NFT's price, and the first buyer that matches this price receives the NFT automatically. Once the transaction is complete, the price is reset to prevent further immediate purchases, ensuring a non-interactive and seamless trading experience.

A document type can also be configured so that each transfer, purchase, and price update is recorded on chain in Platform's document history system contract, giving an NFT a queryable provenance and sale history. Recording is off by default and, like the other document type options, is fixed when the document type is defined in the data contract. See [Document History Flags](../protocol-ref/data-contract-document.md#document-history-flags) in the protocol reference.

On a contract that declares [moderation](../explanations/platform-protocol-data-contract.md#contract-moderation) (protocol version 14+), a banned or suspended identity cannot transfer, buy, or set the price of NFTs from that contract. Transferring an NFT to a barred identity, or buying one that a barred identity has listed, is also refused.

```{eval-rst}
.. _explanations-nft-create-restrict:
```

### Creation Restrictions

To preserve the authenticity of NFTs, Dash Platform includes creation restriction options. This ensures that only authorized entities can create certain types of NFTs. For example, in the case of land ownership NFTs, a designated authority may be the only one that can issue tokens. Restriction options are:

* **Owner Only**: Only the contract owner can create NFTs
* **No Creation Allowed**: NFT creation is disabled for this contract
* **No Restrictions**: Anyone can create NFTs for the contract

```{eval-rst}
.. _explanations-nft-mutate:
```

### Mutate

NFTs can be immutable or mutable, depending on their intended use. Immutable NFTs cannot be altered after creation. This is crucial for items like digital artwork, where authenticity and originality are necessary. Mutable NFTs can be helpful in scenarios like updating a character in a game or altering a digital asset. Mutability is fixed when the document type is defined in the data contract. Since protocol version 14, a mutable NFT can also freeze individual properties, either from creation or only once a condition holds, such as after a value has been set.

```{eval-rst}
.. _explanations-nft-delete:
```

### Delete

Since some NFTs may represent transient or consumable things, Dash Platform allows NFTs to be deleted. This is more efficient than the "burn" mechanism many projects use to make an NFT unusable and provides flexibility in managing assets that may no longer be needed or valid.

Whether deletion is permitted is set when the document type is defined in the data contract and cannot be changed afterward. Document types that keep revision history cannot allow deletion. The one exception is a legacy correction: a contract registered before this rule was enforced may update a history-keeping document type to turn deletion off, since it was never actually possible for that type.

Since protocol version 14, an NFT can also be removed in other ways if its document type allows it. A moderated contract's moderators can delete it if the document type allows anyone to create its documents, or the platform can delete it automatically once its time to live (`ttl`) has passed. See [Document Delete](../explanations/platform-protocol-document.md#document-delete) for each of the ways a document can be removed.

Whether an NFT can be deleted also affects how other documents can reference it. A `permanentDocument` reference only accepts NFTs that can never be removed. Deletable NFTs can be the target of a `deletableDocument` reference instead, which is checked again each time the referring document is replaced. See [property references](../reference/data-contracts.md#platform-specific-property-keywords).

```{eval-rst}
.. _explanations-nft-create:
```

## NFT Creation

Creating an NFT on Dash Platform consists of creating a data contract, registering it on the network, and then creating NFT documents based on the schema defined in the data contract.

### Contract Setup

Structurally, there is no difference between an NFT contract and a non-NFT contract. While an NFT contract may set options that other contracts are unlikely to use, there is no other difference.

NFT contracts will often set document creation restrictions and enable document transfers. Default options for modifying and deleting documents can be specified at the contract level and overridden as needed for specific document types. Transfer and trade options are enabled per document type and are off by default.

Once the data contract design is completed, the contract can be registered on the network in preparation for NFT document creation. See the [contract registration tutorial](../tutorials/contracts-and-documents/register-a-data-contract.md) for example code.

### Minting NFTs

NFTs are minted by creating new documents under the data contract. Each NFT is an instance of one of the document types defined in the contract. See the [submit documents tutorial](../tutorials/contracts-and-documents/submit-documents.md) for example code.

```{eval-rst}
.. _explanations-nft-trade:
```

## NFT Trading

The trading process for Dash Platform NFTs is designed to be user-friendly and efficient by enabling direct transactions between users without requiring trusted third parties.

Once an NFT is created, the owner can set a sale price to indicate the NFT is available for purchase. Interested buyers can then initiate a purchase by matching this set price. Upon completion of the transaction, the ownership of the NFT is automatically transferred to the buyer, and the sale price is reset to indicate the NFT is no longer available for purchase.

Since the functionality needed to set a price, buy, and transfer ownership of NFTs is part of the protocol, the system handles all necessary trading operations directly. This provides an efficient trading experience that is integrated with the indexing and proof capabilities of Dash Platform.

For example code, see the [set a document price](../tutorials/contracts-and-documents/set-a-document-price.md), [purchase documents](../tutorials/contracts-and-documents/purchase-documents.md), and [transfer documents](../tutorials/contracts-and-documents/transfer-documents.md) tutorials.
