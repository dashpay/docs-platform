```{eval-rst}
.. _protocol-ref-overview:
```

# Overview

## Introduction

The Dash Platform Protocol (DPP) defines a protocol for the data objects (e.g.  [identities](../protocol-ref/identity.md), data contracts, documents, state transitions) that can be stored on [Dash's layer 2 platform](../intro/what-is-dash-platform.md). All data stored on Dash Platform is governed by DPP to ensure data consistency and integrity is maintained.

Dash Platform data objects consist of JSON and are validated using the JSON Schema specification via pre-defined JSON Schemas and meta-schemas described in these sections. The meta-schemas allow for creation of DPP-compliant schemas which define fields for third-party Dash Platform applications.

In addition to ensuring data complies with predefined JSON Schemas, DPP also defines rules for hashing and serialization of these objects.

## Reference Implementation

The current reference implementation is the (Rust) [rs-dpp](https://github.com/dashpay/platform/tree/master/packages/rs-dpp) library. The schemas and meta-schemas referred to in this specification can be found here in the reference implementation: <https://github.com/dashpay/platform/tree/master/packages/rs-dpp/src/schema>.

## Release Notes

Release notes for past versions are located on the [dashpay/platform GitHub release page](https://github.com/dashpay/platform/releases). They provide information about breaking changes, features, and fixes.

## Topics

[Identities](../protocol-ref/identity.md)

- [Create](../protocol-ref/identity.md#identity-creation)
- [TopUp](../protocol-ref/identity.md#identity-topup)

[Data Contracts](../protocol-ref/data-contract.md)

- [Documents](../protocol-ref/data-contract.md#data-contract-documents)
  - [Properties](../protocol-ref/data-contract.md#document-properties)
  - [Indices](../protocol-ref/data-contract.md#document-indices)
- [Definitions](../protocol-ref/data-contract.md#data-contract-definitions)

[Document](../protocol-ref/document.md)

[State Transitions](../protocol-ref/state-transition.md)

- [Overview / general structure](../protocol-ref/state-transition.md)
- Types
  - [Identity Create ST](../protocol-ref/identity.md#identity-creation)
  - [Data Contract ST](../protocol-ref/data-contract.md#data-contract-creation)
  - [Batch ST](../protocol-ref/document.md)
    - Document Transitions
      - [Document Transition Base](../protocol-ref/document.md#document-base-transition)
      - [Document Create Transition](../protocol-ref/document.md#document-create-transition)
      - [Document Replace Transition](../protocol-ref/document.md#document-replace-transition)
      - [Document Delete Transition](../protocol-ref/document.md#document-delete-transition)
- [Signing](../protocol-ref/state-transition.md#state-transition-signing)

[Data Triggers](../protocol-ref/data-trigger.md)
