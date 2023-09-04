# Name Service (DPNS)

## Overview

Dash Platform Name Service (DPNS) is a service used to register names on Dash Platform. It is a general service that is used to provide usernames and application names for [identities](../explanations/identity.md) but can also be extended in the future to resolve other cryptocurrency addresses, websites, and more. DPNS is implemented as an application on top of the platform and leverages platform capabilities.

> 👍 DPNS DIP
>
> The [DPNS Dash Improvement Proposal (DIP)](https://github.com/dashpay/dips/blob/master/dip-0012.md) provides more extensive background information and details.

###  Relationship to identities
DPNS names and [Identities](../explanations/identity.md) are tightly integrated. Identities provide a foundation that DPNS builds on to enable name-based interactions -- a user experience similar to what is found in non-cryptocurrency applications. With DPNS, users or application developers register a name and associate it with an identity. Once linked, the identity's private keys allow them to prove ownership of the name to establish trust when they interact with other users and applications.

## Details

### Name Registration Process

> 📘
>
> Given the DNS-compatible nature of DPNS, all DPNS names are technically domain names and are registered under a top-level DPNS domain (`.dash`). Some applications may abstract the top-level domain away, but it is important to be aware that it exists.

To prevent [front-running](https://en.wikipedia.org/wiki/Domain_name_front_running), name registration is split into a two phase process consisting of:
1. Pre-ordering the domain name
2. Registering the domain name

In the pre-order phase, the domain name is salted to obscure the actual domain name being registered (e.g. `hash('alice.dash' + salt)`) and submitted to platform. This is done to prevent masternodes from seeing the names being registered and "stealing" them for later resale. Once the pre-order receives a sufficient number of confirmations, the registration can proceed.

In the registration phase, the domain name (e.g. `alice.dash`) is once again submitted along with the salt used in the pre-order. The salt serves as proof that the registration is from the user that submitted the pre-order. This registration also references the identity being associated with the domain name to complete the identity-domain link.

### Implementation

DPNS names currently have several constraints as defined in the [DPNS data contract](https://github.com/dashevo/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json). The constraints exist to maintain compatibility with DNS:
* Maximum length - 63 characters
* Character set - `0-9`, `-` (hyphen), and `A-Z` (case insensitive)

> 📘
>
> Note: Use of `-` as a prefix/suffix to a name is _not_ allowed (e.g. `-name` or `name-`). This constraint is defined by this JSON-Schema [pattern](https://github.com/dashevo/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json#L35) in the DPNS data contract:
> ```
> "^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$"
> ```

Additionally, the DPNS [data triggers](../explanations/platform-protocol-data-trigger.md) defined in [js-dpp](https://github.com/dashevo/platform/tree/master/packages/js-dpp/lib/dataTrigger) enforce additional validation rules related to the `domain` document.

For more implementation details, please reference the open-source JavaScript DPNS client reference implementation found in the [js-dpns-client](https://github.com/dashevo/js-dpns-client) repository. Additionally, the DPNS data contract is available in the [dpns-contract](https://github.com/dashevo/platform/blob/master/packages/dpns-contract/schema/dpns-contract-documents.json) repository.

### Contract Diagram

This is a visualization of the JSON data contract as UML class diagram for better understanding of the structure. The left side shows the `domain` document and the right side shows the `preorder` document:

```{eval-rst}
.. figure:: ./img/dpns-uml.png
   :class: no-scaled-link
   :align: center
   :width: 90%
   :alt: DPNS Contract Diagram

   DPNS Contract Diagram
```

View [a full-size copy of this diagram](./img/dpns-uml.png).
