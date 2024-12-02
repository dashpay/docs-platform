```{eval-rst}
.. _resources-faq:
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

::::{dropdown} Can I register multiple names?

:::{note}
**Note**: the mobile apps do not currently support registering more than one name under the same
mnemonic.
:::

Yes, each [identity](../explanations/identity.md) can have multiple names.
::::

:::{dropdown} How can I check if a specific name is available?

You can search for the name on the [Platform Explorer](https://platform-explorer.com/). You can also
check [https://dash.vote](https://dash.vote) for the list of contested names currently being voted
on.

:::

:::{dropdown} How long does it take to register and receive a name?

Regular (non-premium) names are registered and received immediately. [Premium
names](../explanations/dpns.md#conflict-resolution) must go through a two-week voting period before
receiving the name.
:::

:::{dropdown} What characters are valid in names?

Names can contain the characters `0-9`, `-` (hyphen), `a-z`, and `A-Z`. Names cannot begin or end
with a hyphen (e.g. `-name` or `name-`).
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

:::{dropdown} How do I prove my identity if requesting a contested name?

Masternode and evonode owners have not settled on a specific process; however, this forum page was created to assist with establishing consensus on who should receive contested names: [Dash Forum Contested Usernames page](https://www.dash.org/forum/index.php?threads/contested-usernames-view-discuss-gain-support.55367/).

:::

:::{dropdown} What are locked names and why are they locked?

Locked names are [contested (premium) names](../explanations/dpns.md#conflict-resolution) that were
previously requested and voted on by masternodes and evonodes. The voters decided the name should
not be awarded to the person requesting it. Some examples of names that may be locked are:

* Businesses or brands (e.g., Coke, Google, IBM)
* Potentially controversial names (political, religious, etc.)
* Well-known community members or celebrities if the source of the request is unknown
:::

:::{dropdown} Can locked names be requested by someone else later?

Locked names can no longer be requested or awarded in Dash Platform v1. The plan is to change this
in future updates, but the exact details have not been defined.
:::

:::{dropdown} What happens if there is a tie vote?

If there is a tie, the first identity requesting the name will receive it. This applies even if
there is a tie between votes for an identity and votes to lock the name.
:::

:::{dropdown} Can usernames be transferred?

Currently, usernames are non-transferrable. Future updates may enable transfers.

:::

:::{dropdown} How many times can a masternode change their vote for a name?

Masternodes and evonodes can vote a total of 5 times per name. At the end of the voting period, the
most recent vote is the one that is counted.
:::

:::{dropdown} Is it necessary to have a DPNS name to use Platform apps?

No, apps can interact with an identity whether or not it has a DPNS name registered. Someone may create an app that requires names, but it is not a platform requirement.
:::

## DashPay

:::{dropdown} Can someone tell when Dash is sent from one username to another?

No. Although contact requests are public in Dash Platform, the extended public keys are encrypted in
such a way that only the two users involved in a contact's two way relationship can decrypt those
keys. This ensures that when any two users make payments in DashPay, only they know the sender and
receiver while 3rd parties do not. This means that outside observers cannot link the identities
involved in the transaction.

See the [DashPay DIP](https://github.com/dashpay/dips/blob/master/dip-0015.md) for more details.

:::

:::{dropdown} What info is encrypted, how is it encrypted and who can decrypt it?

Your extended public (xPub) key is encrypted with an ECDH shared key when you send a contact request
to someone else. Only the recipient of the contact request can decrypt the information in the
document.

See the [DashPay DIP](https://github.com/dashpay/dips/blob/master/dip-0015.md#the-contact-request)
for more details.

:::

