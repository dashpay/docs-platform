[block:image]
{
  "images": [
    {
      "image": [
        "https://files.readme.io/92cc368-how-it-works-2.svg",
        "how-it-works-2.svg",
        132,
        150,
        "#e9f8ff"
      ]
    }
  ]
}
[/block]

[block:html]
{
  "html": "<div></div>\n\n<style>\n .markdown-body img {\n float: right;\n margin-left: 30px;\n /*width: 25%;*/\n max-width: 25%; /*400px;*/\n height: auto;  \n}\n</style>"
}
[/block]
Dash is the world's first and longest-running [DAO](https://www.investopedia.com/tech/what-dao/), a cryptocurrency that has stood the test of time, a truly decentralized and open source project built without a premine, [ICO](https://www.investopedia.com/terms/i/initial-coin-offering-ico.asp), or venture capital investment. Dash is the only solution on the market today developing a decentralized API as an integral part of its [Web3](https://en.wikipedia.org/wiki/Web3) stack, making it the first choice for developers creating unstoppable apps. 

Dash is built on battle-tested technology including Bitcoin and Cosmos Tendermint, and implements cutting-edge threshold signing features on masternodes to guarantee transaction finality in little more than a second. Dash is fast, private, secure, decentralized, and open-source, your first choice for truly decentralized Web3 services and for earning yield in return for providing infrastructure services.

# Key Advantages

## Industry Leading Security

The Dash network is the most secure blockchain-based payments network, thanks to technological innovations such as [ChainLocks](#chainlocks). This mitigates the risk of 51% attacks, forcing any would-be malicious actor to successfully attack both the mining layer and the [masternode](#masternodes) layer. To attack both layers, a malicious actor would have to spend a large amount of Dash in order to dictate false entries to the blockchain, thereby raising the price of Dash in the process. Therefore, a successful attack would be cost prohibitive due to the large percentage of Dash's total market required to attempt it.

## Stable and Long Lasting Governance

The Dash [decentralized autonomous organization (DAO)](reference-glossary#decentralized-autonomous-organization-dao) is the oldest and most successful example of decentralized governance. In that regard, one of Dash's most notable innovations is the creation of a treasury, which funds project proposals that advance the Dash network and ecosystem. This treasury is funded by 10% of the block reward, which is a combination of transaction fees collected on the network and newly minted Dash awarded to miners for securing the blockchain. Nodes that maintain a minimum of 1000 Dash ([masternodes](#masternodes)) receive voting rights on how to distribute treasury funds. Voting on project proposals encourages engagement with the overall network and ecosystem, resulting in numerous projects being funded that advance Dash in terms of technology development, marketing, and business development.

## Established History of Technological Innovation

Most of Dash's technical innovations are described in greater detail elsewhere in this developer hub. However, its record speaks for itself with innovations in governance ([masternodes](https://docs.dash.org/en/stable/introduction/features.html#masternodes), [treasury system](https://docs.dash.org/en/stable/introduction/features.html#decentralized-governance)), security ([ChainLocks](https://docs.dash.org/en/stable/introduction/features.html#chainlocks)), usability (automatic [InstantSend](https://docs.dash.org/en/stable/introduction/features.html#instantsend)), and scalability ([long-living masternode quorums](reference-glossary#long-living-masternode-quorum-llmq)).

## Instantly Confirmed Transactions

All transactions are automatically sent and received instantly at no extra cost. Transaction security and decentralization are not compromised, due to the ChainLocks innovation. As a result, using Dash to transact means getting the speed and fungibility of fiat currency, while simultaneously having the lower costs, privacy, and security of funds of a blockchain-based network.

# Key Features
## Masternodes

The most important differentiating feature of the Dash payments network is the concept of a **masternode**. On a traditional p2p network, nodes participate equally in the sharing of data and network resources. These nodes are all compensated equally for their contributions toward preserving the network. 

However, the Dash network has a second layer of network participants that provide enhanced functionality in exchange for greater compensation. This second layer of masternodes is the reason why Dash is the most secure payments network, and can provide industry-leading features such as instant transaction settlement and usernames.

## Long-Living Masternode Quorums

Dash's [long-living masternode quorums](https://dashcore.readme.io/docs/core-guide-dash-features-masternode-quorums) (LLMQs) are used to facilitate the operation of masternode-provided features in a decentralized, deterministic way. These LLMQs are deterministic subsets of the overall masternode list that are formed via a [distributed key generation](reference-glossary#distributed-key-generation-dkg) protocol and remain active for long periods of time (e.g. hours to days). The main task of LLMQs is to perform threshold signing of consensus-related messages for features like InstantSend and ChainLocks.

## InstantSend

InstantSend provides a way to lock transaction inputs and enable secure, instantaneous transactions. Long-living masternode quorums check whether or not a submitted transaction is valid. If it is valid, the masternodes “lock” the inputs to that specific transaction and broadcast this information to the network, effectively promising that the transaction will be included in subsequently mined blocks and not allowing any other transaction to spend any of the locked inputs.

## ChainLocks

ChainLocks are a feature provided by the Dash Network which provides certainty when accepting payments. This technology, particularly when used in parallel with InstantSend, creates an environment in which payments can be accepted immediately and without the risk of “Blockchain Reorganization Events”.

The risk of blockchain reorganization is typically addressed by requiring multiple “confirmations” before a transaction can be safely accepted as payment. This type of indirect security is effective, but at a cost of time and user experience. ChainLocks are a solution for this problem.

## Proof-of-Service

The Proof of Service (PoSe) scoring system helps incentivize masternodes to provide network services. Masternodes that fail to participate in quorums that provide core services are penalized, which eventually results in them being excluded from masternode payment eligibility.