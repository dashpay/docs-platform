```{eval-rst}
.. _reference-faq:
```

# FAQ

## DPNS names

:::{tip}
See the [Name Service (DPNS)](../explanations/dpns.md) page for additional information on the
Dash Platform Name Service (DPNS).
:::

:::{dropdown} How can I register a name?

Currently, names can be registered using several technical tools; however, the upcoming [DashPay
Android](https://play.google.com/store/apps/details?id=hashengineering.darkcoin.wallet) update will
provide a much easier way to do this.

Developers and other technical users may want to experiment with registering names using the [JS
SDK](https://docs.dash.org/projects/platform/en/stable/docs/tutorials/identities-and-names/register-a-name-for-an-identity.html)
or [Platform TUI](https://github.com/dashpay/platform-tui/).
:::

:::{dropdown} How long does it take to register and receive a name?

Regular (non-premium) names are registered and received immediately. [Premium
names](../explanations/dpns.md#conflict-resolution) must go through a two-week voting period before
receiving the name.
:::

::::{dropdown} Can I register multiple names?

:::{note}
**Note**: the mobile apps do not currently support registering more than one name under the same
mnemonic.
:::

Yes, each [identity](../explanations/identity.md) can have multiple names.
::::

:::{dropdown} What characters are valid in names?

Names can contain the characters `0-9`, `-` (hyphen), and `A-Z` (case insensitive). Names cannot
begin or end with a hyphen (e.g. `-name` or `name-`).
:::

:::{dropdown} Why do names have "0" and "1" in them when viewed in some apps?

Some apps display the normalized name instead of the requested (display) name. To mitigate
[homograph attacks](https://en.wikipedia.org/wiki/IDN_homograph_attack), `o` is replaced with `0`
and `i`/`l` are replaced with `1` internally for validation. For example, "Alice" is normalized to
"a11ce".

Once any iteration of the normalized name is registered, the alternatives cannot be registered. For
example, once "Alice" is registered, none of the following will be available:

* alice
* a1ice
* a11ce
* al1ce

:::

:::{dropdown} What is a contested (premium) name?

Any name meeting the following criteria is considered premium:

* Less than 20 characters long (i.e. "alice", "quantumexplorer") AND
* Contain no numbers or only contain the number(s) 0 and/or 1 (i.e. "bob", "carol01")

These names require a two-week waiting period during which masternodes and evonodes vote to
determine who (if anyone) receives the name. To pay for the voting, anyone requesting the name must
pay a 0.2 DASH name request fee.
:::

:::{dropdown} What happens if no one votes for a contested username request?

If no one votes, the first identity requesting the name will receive it.
:::

:::{dropdown} Can locked names be requested by someone else later?

Locked names can no longer be requested or awarded in Dash Platform v1. The plan is to change this
in future updates, but the exact details have not been defined.
:::

:::{dropdown} What happens if there is a tie vote?

If there is a tie, the first identity requesting the name will receive it. This applies even if
there is a tie between votes for an identity and votes to lock the name.
:::

:::{dropdown} How many times can a masternode change their vote for a name?

Masternodes and evonodes can vote a total of 5 times per name. At the end of the voting period, the
most recent vote is the one that is counted.
:::

:::{dropdown} Is it necessary to have a DPNS name to use Platform apps?

No, apps can interact with an identity whether or not it has a DPNS name registered. Someone may create an app that requires names, but it is not a platform requirement.
:::
