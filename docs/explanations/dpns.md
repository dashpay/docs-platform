```{eval-rst}
.. _explanations-dpns:
```

# Name Service (DPNS)

## Overview

Dash Platform Name Service (DPNS) is a service used to register names on Dash Platform. It is a general service that is used to provide usernames and application names for [identities](../explanations/identity.md) but can also be extended in the future to resolve other cryptocurrency addresses, websites, and more. DPNS is implemented as an application on top of the platform and leverages platform capabilities.

:::{tip}
The [DPNS Dash Improvement Proposal (DIP)](https://github.com/dashpay/dips/blob/master/dip-0012.md) provides more extensive background information and details.
:::

### Relationship to identities

DPNS names and [Identities](../explanations/identity.md) are tightly integrated. Identities provide a foundation that DPNS builds on to enable name-based interactions -- a user experience similar to what is found in non-cryptocurrency applications. With DPNS, users or application developers register a name and associate it with an identity. Once linked, the identity's private keys allow them to prove ownership of the name to establish trust when they interact with other users and applications.

## Details

Given the DNS-compatible nature of DPNS, all DPNS names are technically domain names and are registered under a top-level DPNS domain (`.dash`). Some applications may abstract the top-level domain away, but it is important to be aware that it exists.

### Name Registration Process

To prevent [front-running](https://en.wikipedia.org/wiki/Domain_name_front_running), name registration is split into a two phase process consisting of:

1. Pre-ordering the domain name
2. Registering the domain name

#### Domain pre-order

In the pre-order phase, a random 32-byte salt is placed in front of the normalized domain name and the pair is hashed with a double SHA-256 (e.g. the hash of the salt followed by `a11ce.dash`). Only that hash is submitted to Platform, preventing observers from identifying the requested name and front-running its registration. Once the pre-order document has been accepted by Platform, the registration can proceed.

#### Domain registration

In the registration phase, the domain name (e.g. `alice.dash`) is once again submitted along with the salt used in the pre-order. The salt serves as proof that the registration is from the user that submitted the pre-order. This registration also references the identity being associated with the domain name to complete the identity-domain link.

### Conflict resolution

Since some names may be popular, the registration process includes a voting mechanism to resolve conflicts when multiple identities request the same name. Identities requesting premium names must pay a fee (0.2 DASH) to cover the masternode voting costs.

:::{note}
This process only applies to valid names that meet the following conditions:

* Between 3 and 19 characters long (i.e. "alice", "quantumexplorer") AND
* Contain no numbers other than 0 and/or 1, and no characters besides letters and hyphens (i.e. "bob", "carol01", "quantum-explorer")

All other available names can be registered immediately.
:::

#### Timeline

On mainnet, a two-week voting window begins when a name matching the criteria above is requested. Additional identities can request the same name during the first week of the voting window. Test networks use much shorter windows (currently 90 minutes, with a 45-minute join period). Both durations are versioned protocol parameters.

#### Voting details

As with governance voting, evonode votes are worth four, and regular masternode votes are worth one. Voting is done using the voting key assigned in the provider transaction used to register or update the node. Masternodes and evonodes can:

1. Vote for one of the identities.
1. Vote to abstain. These votes are not counted when determining the outcome.
1. Vote to lock the request. Locked names are not awarded to anyone.

#### Vote outcome

After voting ends, the name is either awarded to one of the identities or locked. The outcome is based on which item receives the most votes.

Assuming masternodes do not vote to lock, the identity receiving the most votes takes ownership of the name. However, if the vote locks the name, no identity receives it. If only one identity requests the name, they will receive it even if no masternodes vote. If lock votes tie with the leading identity, the identity wins; ties between identities are resolved deterministically by the protocol.

:::{note}
Locked names cannot currently be re-requested or awarded. This policy may be revisited in future Platform releases.
:::

### Name transfers and sales

Registering a name is not necessarily the end of its lifecycle. A registered name can be transferred to another identity or offered for sale and bought by another identity. The DPNS contract has always declared names transferable and available for direct purchase, but Platform's validation rules rejected those operations until protocol version 13 (introduced in Dash Platform v4.1) lifted the restriction. Once ownership changes, the name resolves to its new owner, and that identity's private keys are what prove ownership from then on.

The name record itself remains immutable and permanent: it cannot be edited or deleted, only transferred or sold. A name's transfer, purchase, and listing history is recorded, so the chain of ownership and the prices it was offered at can be retrieved and verified.

### Implementation

DPNS names have several constraints as defined in the [DPNS data contract](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json). The constraints provide compatibility with DNS and protection from homograph attacks:

1. Minimum length - 3 characters
1. Maximum length - 63 characters
1. Usable characters - `0-9`, `-` (hyphen), `a-z`, and `A-Z` (case sensitive)
    * Note: Use of `-` as a prefix/suffix to a name is _not_ allowed (e.g. `-name` or `name-`). This constraint is defined by this JSON-Schema [pattern](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json#L47) in the DPNS data contract: `"^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$"`
1. Domain labels are converted to lowercase for case-insensitive uniqueness validation.
1. To mitigate [homograph attacks](https://en.wikipedia.org/wiki/IDN_homograph_attack), `o` is replaced with `0` and `i`/`l` are replaced with `1`. For example, "Alice" is normalized to "a11ce".

Additional validation rules related to the `domain` document are enforced by the DPNS [data triggers](../explanations/platform-protocol-data-trigger.md) defined in [rs-drive-abci](https://github.com/dashpay/platform/tree/master/packages/rs-drive-abci/src/execution/validation/state_transition/state_transitions/batch/data_triggers/triggers/dpns). Note: as a system data
contract, the version active on a network is determined by that network's active protocol version.

```{eval-rst}
..
  Commented out info
  ### Contract Diagram

  This is a visualization of the JSON data contract as UML class diagram for better understanding of the structure. The left side shows the `domain` document and the right side shows the `preorder` document:
```

```{eval-rst}
..
  Commented out info - obsolete
  .. figure:: ./img/dpns-uml.png
    :class: no-scaled-link
    :align: center
    :width: 90%
    :alt: DPNS Contract Diagram

    DPNS Contract Diagram
```

```{eval-rst}
..
  Commented out info - obsolete
  View [a full-size copy of this diagram](./img/dpns-uml.png).
```
