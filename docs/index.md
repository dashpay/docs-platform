```{eval-rst}
.. _platform-index:
```

# Platform docs

Welcome to the Dash Platform developer documentation. You'll find guides and documentation to help
you start working with Dash Platform and building decentralized applications on Dash. This site
focuses on the developer-facing concepts, tutorials, and API references for working with Platform's
public network and open-source tooling.

:::{note}
Looking for the current source tree or lower-level implementation details? See the
[Dash Platform monorepo](https://github.com/dashpay/platform) and the
[Dash Platform Book](https://dashpay.github.io/platform/).
:::

```{eval-rst}
.. grid:: 1 2 3 3

    .. grid-item-card:: 💡 Introduction
        :margin: 2 2 auto auto
        :link-type: ref
        :link: intro-index
        
        Background information about Dash
        
        +++
        :ref:`Click to begin <intro-index>`

    .. grid-item-card:: 💻 Tutorials
        :margin: 2 2 auto auto
        :link-type: ref
        :link: tutorials-intro
        
        Hands-on guides for connecting to Platform and submitting data

        +++
        :ref:`Click to begin <tutorials-intro>`

    .. grid-item-card:: 📑 Explanations
        :margin: 2 2 auto auto
        :link-type: ref
        :link: explanations-dapi
        
        Descriptions of Dash Platform features
        
        +++
        :ref:`Click to begin <explanations-dapi>`

    .. grid-item-card:: 📚 Reference
        :margin: 2 2 auto auto
        :link-type: ref
        :link: reference-dapi-endpoints
        
        API endpoint details and technical information
        
        +++
        :ref:`Click to begin <reference-dapi-endpoints>`

    .. grid-item-card:: 🔍 Platform Protocol Reference
        :margin: 2 2 auto auto
        :link-type: ref
        :link: protocol-ref-overview
        
        Dash Platform protocol reference
        
        +++
        :ref:`Click to begin <protocol-ref-overview>`

    .. grid-item-card:: 📖 Resources
        :margin: 2 2 auto auto
        :link-type: ref
        :link: resources-faq
        
        Links to helpful sites and tools
        
        +++
        :ref:`Click to begin <resources-faq>`
```

```{toctree}
:maxdepth: 2
:caption: Introduction
:hidden:

intro/what-is-dash
intro/what-is-dash-platform
intro/testnet
```

```{toctree}
:maxdepth: 2
:titlesonly:
:caption: Tutorials
:hidden:

tutorials/introduction
tutorials/connecting-to-testnet
tutorials/create-and-fund-a-wallet
tutorials/setup-sdk-client
tutorials/identities-and-names
tutorials/contracts-and-documents
tutorials/example-apps
tutorials/send-funds
tutorials/setup-a-node
tutorials/tui/index
tutorials/building-platform
```

```{toctree}
:maxdepth: 2
:titlesonly:
:caption: Explanations
:hidden:

explanations/dapi
explanations/platform-protocol
explanations/identity
explanations/dpns
explanations/drive
explanations/platform-consensus
explanations/dashpay
explanations/fees
explanations/tokens
explanations/nft
explanations/query
```

```{toctree}
:maxdepth: 2
:titlesonly:
:caption: Reference
:hidden:

reference/dapi-endpoints
reference/query-syntax
reference/data-contracts
reference/glossary
```

```{toctree}
:maxdepth: 2
:titlesonly:
:caption: Platform Protocol Reference
:hidden:

protocol-ref/overview
protocol-ref/identity
protocol-ref/data-contract
protocol-ref/state-transition
protocol-ref/document
protocol-ref/token
protocol-ref/data-trigger
protocol-ref/address-system
protocol-ref/protocol-constants
protocol-ref/errors
```

```{toctree}
:maxdepth: 2
:titlesonly:
:caption: Resources
:hidden:

resources/faq
resources/repository-overview
Dash Platform Monorepo <https://github.com/dashpay/platform>
Dash Platform Book <https://dashpay.github.io/platform/>
Platform Bridge <https://bridge.thepasta.org/>
Platform Explorer <https://platform-explorer.com/>
Testnet Block Explorer <https://insight.testnet.networks.dash.org/insight/>
Testnet Faucet <https://faucet.testnet.networks.dash.org/>
Previous Version of Docs <https://docs.dash.org/projects/platform/en/2.0.0/docs/>
```

```{toctree}
:maxdepth: 2
:titlesonly:
:caption: Rust SDK
:hidden:

sdk-rs/overview
sdk-rs/quick-start
```
