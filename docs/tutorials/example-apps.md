```{eval-rst}
.. _tutorials-example-apps:
```

# Example apps

The tutorials in this section walk through complete, end-to-end applications built on Dash Platform. Unlike the single-operation tutorials elsewhere (for example, [Submit documents](contracts-and-documents/submit-documents.md) or [Register an identity](identities-and-names/register-an-identity.md)), each walkthrough shows how many SDK operations compose together inside a real app.

Each app is a stand-alone project in the [`platform-tutorials/example-apps/`](https://github.com/dashpay/platform-tutorials/tree/main/example-apps) directory. The walkthroughs here tour the code alongside the commands needed to run it locally.

::::{grid} 1 1 2 2
:gutter: 3

:::{grid-item-card} DashMint Lab
:img-top: example-apps/img/dashmint-collection.png
:class-card: example-app-card

Explore a live NFT marketplace that demonstrates minting, transfers, pricing, purchases, burns,
and token-powered document creation.

```{button-link} https://dashpay.github.io/platform-tutorials/dashmint-lab/
:color: primary
:shadow:

Try DashMint Lab live
```

[Read the walkthrough →](example-apps/dashmint-lab.md)
:::

:::{grid-item-card} Dashnote
:img-top: example-apps/img/dashnote.png
:class-card: example-app-card

Try a complete mutable-document workflow with note creation, queries, editing, deletion, and
read-only browsing.

```{button-link} https://dashpay.github.io/platform-tutorials/dashnote/
:color: primary
:shadow:

Try Dashnote live
```

[Read the walkthrough →](example-apps/dashnote.md)
:::
::::

If you are looking for a focused snippet for one SDK call, the per-operation tutorials under [Identities and names](identities-and-names.md) and [Contracts and documents](contracts-and-documents.md) are a better starting point.

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

example-apps/dashmint-lab
example-apps/dashnote
example-apps/dashmint-lite
example-apps/dashnote-lite
example-apps/dashproof-lite
```
