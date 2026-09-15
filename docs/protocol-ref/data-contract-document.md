# Contract Documents

## Contract Document Overview

The `documents` object defines each type of document in the data contract. At a minimum, a document must consist of 1 or more properties. The `additionalProperties` properties keyword must be included as described in the [constraints](./data-contract.md#additional-properties) section and each property must be [assigned a position](#assigning-position).

:::{note}
The `$schema` property is required for each document type but is automatically injected by the platform during [contract enrichment](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/schema/enrich_with_base_schema/v0/mod.rs). Do not include it in user-submitted document type definitions — providing it will result in a validation error.
:::

The following example shows a minimal `documents` object defining a single document (`note`) with one property (`message`).

```json
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string",
        "position": 0
      }
    },
    "additionalProperties": false
  }
}
```

Documents may also define [indices](#document-indices), a list of [required](#required-properties) or [transient](#transient-properties) properties, and a custom [configuration](#document-configuration). Refer to this table for a brief description of the major document sections:

| Feature    | Description                                   |
|------------|-----------------------------------------------|
| [Configuration](#document-configuration) | Document-level settings affecting behavior such as mutability, deletion, and transferability  |
| [Properties](#document-properties) | Definitions and constraints for each field within a document  |
| [Indices](#document-indices)       | Definitions for indexing document fields to support efficient querying |

## Document Properties

The `properties` object defines each field that a document will use. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`).

Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data. A full explanation of JSON Schema capabilities is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

### Assigning Position

Each property in a level must be assigned a unique `position` value, with ordering starting at zero and incrementing with each property. When using nested objects, position counting resets to zero for each level. This structure supports backward compatibility in data contracts by [ensuring consistent ordering](https://github.com/dashpay/platform/pull/1594) for serialization and deserialization processes.

### Object Properties

The `object` type cannot be an empty object but must have one or more defined properties. For example, the `body` property shown below is an object containing a single string property (`objectProperty`):

```javascript
const contractDocuments = {
  message: {
    type: "object",
    properties: {
      body: {
        type: "object",
        position: 0,
        properties: {
          objectProperty: {
            type: "string",
            "position": 0
          },
        },
        additionalProperties: false,
      },
      header: {
        type: "string",
        "position": 1
      }
    },
    additionalProperties: false
  }
};
```

### Required Properties

Each document may have some fields that are required for the document to be valid and other fields that are optional. Required fields are defined via the `required` array, which consists of a list of the field names from the document that must be present. Exclude the `required` object for documents without required properties.

```json
"required": [
  "<field name a>",
  "<field name b>"
]
```

**Example**  
The following example (excerpt from the DPNS contract's `domain` document) demonstrates a document with required fields:

```json
"required": [
  "$createdAt",
  "$updatedAt",
  "$transferredAt",
  "label",
  "normalizedLabel",
  "normalizedParentDomainName",
  "preorderSalt",
  "records",
  "subdomainRules"
]
```

#### Adding required properties in a contract update

:::{versionadded} 4.2.0
:::

A contract update may add a property to `required` only if the property also sets `requiredSince` to the contract version from which it is required. The value is an integer from 1 to 4294967295 and may not exceed the version of the contract that carries it. `requiredSince` is allowed only on top-level properties that are listed in `required`.

```json
"properties": {
  "avatarUrl": {
    "type": "string",
    "maxLength": 2048,
    "position": 3,
    "requiredSince": 2
  }
}
```

### Transient Properties

Each document may have transient fields that require validation but do not need to be stored by the system once validated. Transient fields are defined in the `transient` array. Only include the `transient` object for documents with at least one transient property.

**Example**  

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json)) demonstrates a document that has 1 transient field:

```json
    "transient": [
      "preorderSalt"
    ]
```

### Property References

:::{versionadded} 4.2.0
:::

An identifier property (`type: array`, `byteArray: true`, `contentMediaType: application/x.dash.dpp.identifier`, `minItems` and `maxItems` of 32) may declare a `refersTo` object. Platform then checks at document write time that the referenced entity exists. Setting `refersTo` on any other property type is rejected.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | `identity`, `contract`, `token`, `permanentDocument`, or `identityPublicKey` |
| `contractId` | string or array (32 bytes) | No | `permanentDocument` only. Contract holding the referenced document type. Defaults to the declaring contract. |
| `documentType` | string (1-64 chars) | Yes, for `permanentDocument` | Name of the referenced document type. The referenced type must set `canBeDeleted: false`. |
| `propertyAgreement` | object (1-10 entries) | No | `permanentDocument` only. Maps a property of this document to a property of the referenced document. Both values must be equal when the document is written, and both properties must have the same type. |
| `keyIdProperty` | string (1-256 chars) | Yes, for `identityPublicKey` | Property of this document that holds the referenced key id. The `refersTo` property itself holds the identity id. |

`contractId`, `documentType`, and `propertyAgreement` are rejected unless `type` is `permanentDocument`; `keyIdProperty` is rejected unless `type` is `identityPublicKey`.

### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| ----------- | ----- |
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L23) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L24) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L21) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L21) |
| Property name characters     | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hyphen (`-`) <br>Underscore (`_`) |

## Document Indices

Document indices may be defined if indexing on document fields is required. The `indices` array should only be included for documents with at least one index.

### Required Index Fields

Each object in the `indices` array requires two fields:

| Field | Description |
| --- | --- |
| `name` | A unique name for the index. |
| `properties` | An ordered array containing one `<field name: sort order>` object for each indexed document field. Only `asc` is currently supported. |

:::{admonition} Compound Indices
:class: attention
When defining an index with multiple properties, the ordering of properties is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details. Dash uses [GroveDB](https://github.com/dashpay/grovedb), which works similarly but requires listing all the index's fields in query order by statements.
:::

### Optional Index Fields

In addition to `name` and `properties`, an index may contain the following optional fields:

| Option | Purpose | Details |
| --- | --- | --- |
| `unique` | Determines whether duplicate values are allowed. | Defaults to `false`. |
| `nullSearchable` | Determines whether the index includes entries whose properties are all null. | Defaults to `true`. When `false`, no reference is added if all indexed properties are null. |
| `contested` | Makes matching values on a unique index subject to a masternode vote instead of first-come ownership. | See [Contested Indices](#contested-indices). |
| Aggregate flags | Enable count, sum, and average fast paths. | `countable`, `rangeCountable`, `summable`, `rangeSummable`, `averageable`, and `rangeAverageable`. See [Aggregate Query Flags](#aggregate-query-flags). |
| Ranked aggregate flags | Enable top or bottom K queries. Added in 4.2.0. | `rankedCountable`, `rankedSummable`, and `rankedAverageable`. See [Index-level Flags](#index-level-flags). |
| `timeRange` | Buckets the first index property into fixed-length time windows. Added in 4.2.0. | See [Time-Range Indices](#time-range-indices). |
| `skipIfAbsent` | Omits an index entry when the first property is absent. Added in 4.2.0. | Available only on `indexOnly` document types. See [Index-Only Options](#index-only-options). |
| `terminal` | Selects the value that keys each index entry. Added in 4.2.0. | Available only on `indexOnly` document types. See [Index-Only Options](#index-only-options). |
| `preallocated` | Creates index trees before referenced documents produce entries. Added in 4.2.0. | Available only on `indexOnly` document types. See [Index-Only Options](#index-only-options). |

Index objects do not accept any properties beyond those listed above. Starting with Dash Platform 4.2.0 (protocol version 14), index objects also accept the ranked aggregate keywords, `timeRange`, and the `indexOnly`-specific keywords `terminal`, `preallocated`, and `skipIfAbsent`. Under earlier protocol versions those keywords are rejected.

The following template shows the required shape and commonly used optional fields:

:::{code-block} json
:force:

"indices": [
  {
    "name": "<index name a>",
    "properties": [
      { "<field name a>": "asc" },
      { "<field name b>": "asc" }
    ],
    "unique": true|false,
    "nullSearchable": true|false,
    "contested": {
      "fieldMatches": [
        {
          "field": "<field name a>",
          "regexPattern": "<regex>"
        }
      ],
      "resolution": 0
    }
  },
  {
    "name": "<index name b>",
    "properties": [
      { "<field name c>": "asc" },
    ],
    "countable": "countable"|"countableAllowingOffset"|"notCountable",
    "rangeCountable": true|false,
    "summable": "<integer field name>",
    "rangeSummable": true|false,
    "averageable": "<integer field name>",
    "rangeAverageable": true|false
  }
]
:::

**Example**

The following example (excerpt from the DPNS contract's `preorder` document) creates an index named `saltedHash` on the `saltedDomainHash` property and enforces uniqueness across all documents of that type:

```json
"indices": [
  {
    "name": "saltedHash",
    "properties": [
      {
        "saltedDomainHash": "asc"
      }
    ],
    "unique": true
  }
]
```

#### Time-Range Indices

:::{versionadded} 4.2.0
Protocol version 14 added time-range indices.
:::

The optional `timeRange` object buckets an index's first property into fixed-length time windows. It contains the following fields:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `on` | string | Yes | The first index property. It must be `$createdAt`, `$updatedAt`, or `$transferredAt` and must be listed in the document type's `required` array. |
| `range` | integer | Yes | Window length in seconds. It must be a multiple of `step`. |
| `step` | integer | Yes | Number of seconds between window starts. |
| `phase` | integer | No | Grid offset in seconds. It must be less than `step` and less than 31,536,000. Defaults to `0`. |
| `ttl` | integer | No | Entry lifetime in seconds, measured from the start of its window. It must be at least `range` and, under protocol version 14, at most 604,800 (one week). Omit it for entries that live forever. |

When `ttl` is set, an entry lives at most `ttl` seconds past the start of its window, plus a bounded cleanup lag. Expired windows cannot be queried. Indexes that bucket the same field on the same grid must all declare the same `ttl`, or all omit it.

Bytes written under a `ttl` index are charged as processing at the [TTL ephemeral rate](protocol-constants.md#storage) instead of storage and are not refunded on removal.

A time-range index may be `unique` only when `range` equals `step` and `on` is `$createdAt`. It cannot be `contested`, set `nullSearchable` to `false`, or be combined with `preallocated`.

#### Index-Only Options

The following options are available only on document types with [`indexOnly: true`](#document-configuration):

| Option | Behavior and constraints |
| --- | --- |
| `skipIfAbsent` | When true, a document that omits the index's first property writes no entry into this index. The first property must be a top-level property that is not in `required`, and every index containing an optional property must place that property first and set `skipIfAbsent`. Every other property must still appear in at least one index without `skipIfAbsent`, and at least one index without `$createdAt` must not use `skipIfAbsent`. |
| `terminal` | Names the property whose value keys each index entry. It may be `$ownerId` (the default) or an identifier property with a `refersTo` type of `identity`, `contract`, `token`, or `permanentDocument`. It must not repeat an index property. |
| `preallocated` | Creates the index trees for entries referencing a document when that document is created. Every index property must be either the referring property of a same-contract `permanentDocument` reference or a key of its `propertyAgreement`. It cannot be combined with `timeRange`. |

#### Contested Indices

Contested unique indices provide a way for multiple identities to compete for ownership when a new document field matches a predefined pattern. This system enables fair distribution of valuable documents, such as [premium DPNS names](../explanations/dpns.md#conflict-resolution), through community-driven decision-making.

A two week contest begins when a match occurs. For the first week, additional contenders can join by paying the [contested document vote resolution fund](protocol-constants.md#voting) fee (0.1 Dash from protocol version 14; 0.2 Dash in earlier versions). During this period, masternodes and evonodes vote on the outcome. The contest can result in the awarding of the document to the winner, a locked vote where no document is awarded, or potentially a restart of the contest if specific conditions are met.

The table below describes the properties used to configure a contested index:

| Property Name | Type | Description |
|-|-|-|
| fieldMatches | array | Array containing conditions to check |
| fieldMatches.field | string | Name of the field to check for matches (1-256 characters) |
| fieldMatches.regexPattern | string | Regex used to check for matches (1-256 characters) |
| resolution | integer | Method to resolve the contest:<br>`0` - masternode voting |
| description | string | Optional free-text note (1-256 characters) |

**Example**

This example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json)) demonstrates the use of a contested index:

``` json
"contested": {
  "fieldMatches": [
    {
      "field": "normalizedLabel",
      "regexPattern": "^[a-zA-Z01-]{3,19}$"
    }
  ],
  "resolution": 0,
  "description": "If the normalized label part of this index is less than 20 characters (all alphabet a-z, A-Z, 0, 1, and -) then a masternode vote contest takes place to give out the name"
}
```

### Index Constraints

For performance and security reasons, indices have the following constraints. These constraints are subject to change over time.

| Description | Value |
| ----------- | ----- |
| Minimum/maximum length of index `name` | [1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L358) / [32](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L359) |
| Maximum number of indices | [10](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L482) |
| Maximum number of unique indices | [10](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v2.rs#L27) |
| Maximum number of contested indices | [1](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v2.rs#L26) |
| Maximum number of properties in a single index | [10](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json#L378) |
| Maximum `timeRange` overlap factor (`range / step`) (added in 4.2.0) | [24](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L65) |
| Maximum `timeRange` `ttl` (added in 4.2.0) | [604,800](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L66) seconds (1 week) |
| Maximum length of indexed string property | [63](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L28) |
| Usage of `$id` in an index [disallowed](https://github.com/dashpay/platform/pull/178) | N/A |
| **Note: Dash Platform [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225).**<br>Maximum length of indexed byte array property | [255](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L29) |
| **Note: Dash Platform [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225).**<br>Maximum number of indexed array items         | [1024](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L30) |

:::{seealso}
For all protocol constants, see [Protocol Constants](protocol-constants.md).
:::

## Document Configuration

Documents support the following configuration options to provide flexibility in contract design. Only include configuration options in a data contract when using non-default values.

| Document option | Type | Description |
|-----------------|------|-------------|
| `documentsKeepHistory`               | boolean  | If true, documents keep a history of all changes. Default: false. |
| `documentsMutable`                   | boolean  | If true, documents are mutable. Default: true. |
| `canBeDeleted`                       | boolean  | If true, documents can be deleted. Default: true. |
| `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always<br>See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details |
| `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval)<br>See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details |
| `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No Creation Allowed<br>See the [NFT page](../explanations/nft.md#creation-restrictions) for more details |
| `keepsTransferHistory`               | boolean  | If true, transfers of these documents are recorded in the [document history contract](#document-history-flags). Default: false. |
| `keepsPurchaseHistory`               | boolean  | If true, purchases of these documents are recorded in the [document history contract](#document-history-flags). Default: false. |
| `keepsPricingHistory`                | boolean  | If true, price updates on these documents are recorded in the [document history contract](#document-history-flags). Default: false. |
| `indexOnly`                          | boolean  | **Added in 4.2.0.** If true, documents of this type are stored only as index entries; there is no primary document row. Requires `documentsMutable: false`, `transferable: 0`, `tradeMode: 0`, no history flags, no `transient` properties, no document-type aggregate flags, at least one index, and every property required and indexed (see `skipIfAbsent` for the one exception). Indices on such a type cannot be `unique`, `contested`, or set `nullSearchable: false`, and every index must include `$ownerId` as a property or as its terminal. Default: false. |

| Security option | Type | Description |
|-----------------|------|-------------|
| [`requiresIdentity`<br>`EncryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| [`requiresIdentity`<br>`DecryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |

:::{versionchanged} 4.2.0
A document type with `documentsKeepHistory: true` must also set `canBeDeleted: false`. Since `canBeDeleted` defaults to true, leaving it unset on a keep-history type is rejected when the contract is validated.
:::

### Token Costs

The `tokenCost` option allows document types to require token payment for operations. When configured, users must pay a specified amount of tokens to perform each operation type. Each operation cost is defined as a [documentActionTokenCost](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L294-L337) object with the following properties:

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `contractId` | array (32 bytes) | No | Identifier of the contract containing the payment token. Omit it for a token in the current contract; setting it to the contract's own id is rejected. |
| `tokenPosition` | integer (0–65535) | Yes | Position of the token within the contract |
| `amount` | integer (1–281474976710655) | Yes | Number of tokens required for the operation |
| `effect` | integer | No | Token disposition after payment:<br>`0` - Transfer to contract owner (default)<br>`1` - Burn (tokens destroyed). Burning is allowed only for a token in the current contract, so `1` is rejected when `contractId` is set. |
| `gasFeesPaidBy` | integer | No | Who pays gas fees for the operation:<br>`0` - Document owner (default)<br>`1` - Contract owner<br>`2` - Prefer contract owner (falls back to document owner if insufficient) |

The following operation types can each have an independent cost configuration:

| Operation | Description |
|-----------|-------------|
| `create` | Creating a new document |
| `replace` | Replacing an existing document |
| `delete` | Deleting a document |
| `transfer` | Transferring document ownership |
| `update_price` | Updating a document's purchase price |
| `purchase` | Purchasing a document |

:::{dropdown} List of all usable document properties

  This list of properties is defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/document_type/mod.rs#L48) and the [document meta-schema](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json).

  | Property Name | Type | Description |
  |---------------|------|-------------|
  | `type`                               | string   | Specifies the type of the document, constrained to "object". |
  | `$schema`                            | string   | Platform-injected during enrichment; not accepted in user submissions. |
  | `$defs`                              | object   | References the `documentProperties` definition. |
  | [`indices`](#document-indices)       | array    | Defines indices for the document with properties like `name`, `unique`, `nullSearchable`, and `contested`. |
  | `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |
  | `documentsKeepHistory`               | boolean  | If true, documents keep a history of all changes. Default: false. |
  | `documentsMutable`                   | boolean  | If true, documents are mutable. Default: true. |
  | `canBeDeleted`                       | boolean  | If true, documents can be deleted. Default: true. |
  | `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always |
  | `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval) |
  | `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No Creation Allowed. |
  | [`requiresIdentity`<br>`EncryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`requiresIdentity`<br>`DecryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`properties`](#document-properties) | object   | Defines the properties of the document. |
  | [`transient`](#transient-properties) | array    | An array of strings specifying transient properties that are validated by Platform but not stored. |
  | `tokenCost`                          | object   | Defines token costs for document operations (create, replace, update_price, delete, transfer, purchase) |
  | [`documentsCountable`](#aggregate-query-flags) | boolean | Doctype-wide count support. See [Aggregate Query Flags](#aggregate-query-flags). |
  | [`rangeCountable`](#aggregate-query-flags) | boolean | Per-index range counts. See [Aggregate Query Flags](#aggregate-query-flags). |
  | [`documentsSummable`](#aggregate-query-flags) | string | Doctype-wide sums of the named integer property. See [Aggregate Query Flags](#aggregate-query-flags). |
  | [`rangeSummable`](#aggregate-query-flags) | boolean | Per-index range sums. See [Aggregate Query Flags](#aggregate-query-flags). |
  | [`documentsAverageable`](#aggregate-query-flags) | string | Doctype-wide averages of the named integer property. See [Aggregate Query Flags](#aggregate-query-flags). |
  | [`rangeAverageable`](#aggregate-query-flags) | boolean | Per-index range averages. See [Aggregate Query Flags](#aggregate-query-flags). |
  | [`keepsTransferHistory`](#document-history-flags) | boolean | Records transfers in the document history contract. See [Document History Flags](#document-history-flags). |
  | [`keepsPurchaseHistory`](#document-history-flags) | boolean | Records purchases in the document history contract. See [Document History Flags](#document-history-flags). |
  | [`keepsPricingHistory`](#document-history-flags) | boolean | Records price updates in the document history contract. See [Document History Flags](#document-history-flags). |
  | `indexOnly` | boolean | If true, index entries are the only storage for this document type. See [Document Configuration](#document-configuration). |
  | `required`                           | array    | Standard JSON Schema keyword listing required property names. |
  | `description`                        | string   | Standard JSON Schema keyword describing the document type. |
  | `$comment`                           | string   | Standard JSON Schema keyword for a schema comment. |
  | `minProperties`                      | integer  | Standard JSON Schema keyword bounding the minimum number of properties. |
  | `maxProperties`                      | integer  | Standard JSON Schema keyword bounding the maximum number of properties. |
  | `dependentRequired`                  | object   | Standard JSON Schema keyword declaring conditionally required properties. |
  | [`additionalProperties`](./data-contract.md#additional-properties) | boolean  | Specifies whether additional properties are allowed. Must be set to false, meaning no additional properties are allowed beyond those defined. |

:::

**Example**

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json)) demonstrates the use of several configuration options:

```json
{
  "domain": {
    "documentsMutable": false,
    "canBeDeleted": true,
    "transferable": 1,
    "tradeMode": 1,
    "keepsTransferHistory": true,
    "keepsPurchaseHistory": true,
    "keepsPricingHistory": true,
    "..."
  }
}
```

## Aggregate Query Flags

:::{versionadded} 4.0.0
:::

Document types can opt into aggregate query support (count / sum / average) through flags at the document-type root and on individual [index objects](#document-indices). These flags control the underlying storage layout — once set on a published contract they cannot be changed by a contract update.

### Document-type flags

Document-type flags configure aggregates on the primary-key tree and are set at the document-type root alongside options such as `documentsKeepHistory`.

| Flag | Type | Purpose |
| - | - | - |
| `documentsCountable` | Boolean | Enables total document counts on the primary-key tree. |
| `rangeCountable` | Boolean | Enables range counts on the primary-key tree and implies `documentsCountable`. |
| `documentsSummable` | String | Enables total sums of the named integer property. |
| `rangeSummable` | Boolean | Enables range sums on the primary-key tree. Requires `documentsSummable`. |
| `documentsAverageable` | String | Syntactic sugar for `documentsCountable: true` plus `documentsSummable: "<property>"`. |
| `rangeAverageable` | Boolean | Syntactic sugar for root-level `rangeCountable: true` plus `rangeSummable: true`. Requires `documentsAverageable`. |

### Index-level flags

Index-level flags configure aggregates along a specific index path. Set them on the index object alongside `name`, `properties`, `unique`, and `contested`, not on an individual `{ "field": "asc" }` property entry.

| Flag | Type | Purpose |
| - | - | - |
| `countable` | Boolean or string | Enables count fast paths for the index. String values are `notCountable`, `countable`, and `countableAllowingOffset`; the last uses a provable count tree that also supports future range and offset queries. |
| `rangeCountable` | Boolean | Enables range counts over the indexed property. Requires `countable` to be enabled on the same index. |
| `summable` | String | Enables sums of the named integer document property through the index. |
| `rangeSummable` | Boolean | Enables range sums over the indexed property. Requires `summable` on the same index. |
| `averageable` | String | Syntactic sugar for index-level `countable: "countable"` plus `summable: "<property>"`. |
| `rangeAverageable` | Boolean | Syntactic sugar for index-level `rangeCountable: true` plus `rangeSummable: true`. Requires `averageable` on the same index. |
| `rankedCountable` | Boolean or object | **Added in 4.2.0.** Ranks groups by document count for top or bottom K queries. `true` ranks the last index property. The object form `{"at": "<property>"}` or `{"at": ["<property>", ...]}` (1-10 unique names, each an index property) places a count ranking at the named level(s); a non-terminal level ranks its values by whole-subtree count. Requires `rangeCountable: true`. A non-terminal `at` cannot be combined with `rankedSummable` or `rankedAverageable`, and no other index of the type may share that level. |
| `rankedSummable` | Boolean | **Added in 4.2.0.** Ranks groups by the sum of the `summable` property. Requires `rangeSummable: true`. |
| `rankedAverageable` | Boolean | **Added in 4.2.0.** Ranks groups by the average of the `averageable` property. Requires `rangeAverageable: true`. Does not imply `rankedCountable` or `rankedSummable`. |

Properties named by `documentsSummable`, `documentsAverageable`, `summable`, or `averageable` must exist on the document type, be listed in `required`, and have an integer type.

The averageable flags desugar to the underlying count + sum flags during contract parsing — same on-disk layout — so authors who think in terms of averages get a single flag and downstream code paths (insert, query, estimation) stay unchanged. If both `documentsAverageable` and `documentsSummable` are set, they must name the same property.

These flags were introduced in the v1 document meta-schema and carry forward unchanged into v2 and v3. They are rejected when applied to pre-v12 contracts. The current v3 meta-schema, including these flags and the ranked keywords, is defined [in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json).

See the [`getDocuments` reference](../reference/dapi-endpoints-platform-endpoints.md#getdocuments) for the request/response shapes that consume these flags.

## Document History Flags

:::{versionadded} 4.1.0
:::

Document types can opt into recording ownership and pricing events in the [document history system contract](./data-contract.md#document-history-system-contract) by setting flags at the document-type level. Each flag is a boolean defaulting to false, set at the document type root alongside other doctype options like `documentsKeepHistory`. These are distinct from the token-level [token history properties](./data-contract-token.md#history-properties), which share the `keepsTransferHistory` name but default to true and record into token history.

| Flag | Type | Purpose |
| - | - | - |
| `keepsTransferHistory` | Boolean | Records each transfer of these documents. |
| `keepsPurchaseHistory` | Boolean | Records each purchase of these documents. |
| `keepsPricingHistory` | Boolean | Records each price update on these documents. |

Like the [aggregate query flags](#aggregate-query-flags), these cannot be changed by a contract update once set on a published contract.

The flags are read only when the contract validates against the v2 or later document meta-schema (protocol version 13 or later). Under earlier meta-schema versions they are treated as false. The current v3 meta-schema is defined [in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json).

## Keyword Constraints

There are a variety of keyword constraints currently defined for performance and security reasons. The
following constraints apply to document definitions. Unless otherwise noted, these
constraints are defined in the platform's JSON Schema rules (e.g., [rs-dpp document meta
schema](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json)).

| Keyword | Constraint |
| ------- | ---------- |
| `default`                   | Restricted - cannot be used (defined in DPP logic)  |
| `propertyNames`             | Restricted - cannot be used (defined in DPP logic) |
| `pattern: <something>`      | `maxLength` must be defined (maximum: 50000) |
| `format: <something>`       | `maxLength` must be defined (maximum: 50000) |
| `$ref: <something>`         | Internal references only - the value must begin with `#` (e.g. `#/$defs/myType`). External and remote references, and reference cycles, are rejected |
| `if`, `then`, `else`, `allOf`, `anyOf`, `oneOf`, `not` | Disabled for data contracts |
| `dependencies`              | Not supported. Use `dependentRequired` instead |
| `dependentSchemas`          | Not supported. Schema-based dependencies are not available in document schemas; use `dependentRequired` for property-presence dependencies |
| `type: array`               | Only byte arrays are supported. `byteArray: true` must be defined; schemas for individual array items are not available |
| `additionalItems`           | Not supported. Per-item array schemas (`items` / `prefixItems`) are not available in document schemas; constrain arrays with `minItems`, `maxItems`, `uniqueItems`, `contains`, and `byteArray` |
| `patternProperties`         | Restricted - cannot be used for data contracts |
| `pattern`                   | Patterns are compiled with the Rust [`regex`](https://docs.rs/regex/latest/regex/) crate, whose semantics match [RE2](https://github.com/google/re2/wiki/Syntax) (no backtracking, lookaround, or backreferences), with a 5 MiB compiled-pattern size limit. Patterns using unsupported constructs or exceeding the size limit are rejected as JSON schema compilation errors |

## Example Syntax

This example syntax shows the structure of a documents object that defines two documents, an index, and a required field.

:::{code-block} json
:force:

{
  "<document name a>": {
    "type": "object",
    "properties": {
      "<field name b>": {
        "type": "<field data type>",
        "position": "<number>"
      },
      "<field name c>": {
        "type": "<field data type>",
        "position": "<number>"
      },
    },
    "indices": [
      {
        "name": "<index name>",
        "properties": [
          {
            "<field name c>": "asc"
          }
        ],
        "unique": true|false
      },
    ],
    "required": [
      "<field name c>"
    ],
    "additionalProperties": false
  },
  "<document name x>": {
    "type": "object",
    "properties": {
      "<property name y>": {
        "type": "<property data type>",
        "position": "<number>"
      },
      "<property name z>": {
        "type": "<property data type>",
        "position": "<number>"
      },
    },
    "additionalProperties": false
  },    
}
:::

## Document Schema

See full document schema details in the rs-dpp document meta schema. Protocol version 13 (Dash Platform 4.1) validates against the [v2 meta-schema](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v2/document-meta.json). Protocol version 14 (Dash Platform 4.2.0) validates against the [v3 meta-schema](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json), which adds the ranked index keywords, `refersTo`, `requiredSince`, `timeRange`, and the `indexOnly` keywords.
