```{eval-rst}
.. _reference-data-contracts:
```

# Data Contracts

## Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the submitted contract-related data. This minimal example shows a data contract for a simple note-taking application, where each document represents a note with a single text message.

:::{code-block} json
:caption: Note application data contract
{
  "note": {
    "properties": {
      "message": {
        "type": "string",
        "position": 0,
        "description": "Stores a note message"
      }
    },
    "additionalProperties": false
  }
}
:::

The following sections provide details that developers need to configure and construct valid contracts. All data contracts must define at least one [document](#documents) or token, each conforming to the [general data contract constraints](#general-constraints). Additionally, several contract-level [configuration parameters](#contract-configuration) can be set to modify the mutability, retention, and security behavior of the contract and its documents.

## Contract Configuration

Data contracts support three categories of configuration options to provide flexibility in contract design. It is only necessary to include them in a data contract when non-default values are used. The default values for these configuration options are defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/src/data_contract/config/fields.rs).

| Contract option                         | Default | Description |
|-----------------------------------------|---------|-------------|
| `canBeDeleted`                          | `false` | Determines if the contract can be deleted |
| `readonly`                              | `false` | Determines if the contract is read-only. Read-only contracts cannot be updated. |
| `keepsHistory`                          | `false` | Enables or disables the storing of contract update history |
| `sized_integer_types`                   | `true`  | Use sized integer types for `integer` properties based on their validation rules. Note that this key is snake_case, unlike the other contract configuration keys. |
| `moderation`                            | None    | (Optional) Declares the contract's moderation lists and moderators. Requires protocol version 14. See [Contract Moderation](../protocol-ref/data-contract.md#contract-moderation). |

| Document default option                 | Default | Description |
|-----------------------------------------|---------|-------------|
| `documentsKeepHistory`<br>`ContractDefault`   | `false` | Sets the default behavior for whether documents keep history within the contract|
| `documentsMutable`<br>`ContractDefault`       | `true`  | Sets the default mutability of documents within the contract |
| `documentsCanBeDeleted`<br>`ContractDefault`  | `true`  | Sets the default behavior for whether documents within the contract can be deleted|

Data contracts may also define the following top-level fields:

| Contract field | Type | Description |
|----------------|------|-------------|
| `tokens`       | object | (Optional) Token definitions keyed by token contract position. Each entry configures base supply, maximum supply, minting and burning rules, and change control. See [Contract Tokens](../protocol-ref/data-contract-token.md). |
| `groups`       | object | (Optional) Groups that allow for specific multiparty actions on the contract. See [Data Contract groups](../protocol-ref/data-contract.md#data-contract-groups). |
| `keywords`     | array of strings | (Optional) Keywords associated with the contract to improve searchability via the `search` system contract. Maximum of 50 unique keywords. |
| `description`  | string | (Optional) Brief human-readable description of the contract (3-100 characters). Also added to the `search` system contract. |

## Key Management

Dash Platform provides an advanced level of security and control by enabling the isolation of encryption and decryption keys on a contract-specific or document-specific basis. This granular approach to key management enables developers to configure their applications for whatever level of security they require.

| Security option                         | Description |
|-----------------------------------------|-------------|
| `requiresIdentity`<br>`EncryptionBoundedKey`  | Indicates the contract requires a contract-specific identity encryption key. Key options:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest  |
| `requiresIdentity`<br>`DecryptionBoundedKey`  | Indicates the contract requires a contract-specific identity decryption key. Key options:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest |

:::{tip}
These security options can be set at the root level of the data contract or the root level of specific documents within the contract depending on requirements.
:::

**Example**

The following example (from the [DashPay contract's `contactRequest` document](https://github.com/dashpay/platform/blob/v5.0.1/packages/dashpay-contract/schema/v2/dashpay.schema.json#L166-L170)) demonstrates the use of both key-related options at the document level:

``` json
"contactRequest": {
  "requiresIdentityEncryptionBoundedKey": 2,
  "requiresIdentityDecryptionBoundedKey": 2,
}
```

## Documents

The `documents` object defines each type of document required by the data contract. At a minimum, a document must consist of 1 or more [properties](#document-properties). Documents may also define [indices](#document-indices) and a list of [required properties](#required-properties). The `additionalProperties` properties keyword must be included as described in the [constraints](#additional-properties) section.

The following example shows a minimal `documents` object defining a single document (`note`) with one property (`message`).

```json
{
  "note": {
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

### Document Configuration

Documents support the following configuration options to provide flexibility in contract design. It is only necessary to include them in a data contract when non-default values are used.

| Document option | Type | Description |
|-----------------|------|-------------|
| `documentsKeepHistory`               | boolean  | If true, documents keep a history of all changes. Default: false. |
| `documentsMutable`                   | boolean  | If true, documents are mutable. Default: true. |
| `canBeDeleted`                       | boolean or string | Whether a document's owner can delete it: `true`, `false`, or `"onlyWhenConsumed"` (requires protocol version 14; the owner cannot delete it directly, but a create that consumes it does). See [Document Removal](../protocol-ref/data-contract-document.md#document-removal). Default: true. |
| `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always<br>See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details |
| `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval)<br>See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details |
| `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No Creation Allowed<br>See the [NFT page](../explanations/nft.md#creation-restrictions) for more details |
| `keepsTransferHistory`               | boolean  | If true, transfers of these documents are recorded in the document history system contract. Default: false. |
| `keepsPurchaseHistory`               | boolean  | If true, purchases of these documents are recorded in the document history system contract. Default: false. |
| `keepsPricingHistory`                | boolean  | If true, price updates on these documents are recorded in the document history system contract. Default: false. |
| `indexOnly`                          | boolean  | If true, documents are never written to primary storage - the index entries are the rows. Requires protocol version 14; see [indexOnly document types](#indexonly-document-types). Default: false. |

| Security option | Type | Description |
|-----------------|------|-------------|
| [`requiresIdentity`<br>`EncryptionBoundedKey`](#key-management) | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| [`requiresIdentity`<br>`DecryptionBoundedKey`](#key-management) | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |

Document types may also define a `tokenCost` object requiring token payment per operation. See [Token Costs](../protocol-ref/data-contract-document.md#token-costs) in the protocol reference for the full schema.

:::{versionadded} 4.0.0
Document types can opt into aggregate queries with the flags `documentsCountable`, `documentsSummable`, `documentsAverageable`, and their `range*` variants, which enable `COUNT`/`SUM`/`AVG` support. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags) in the protocol reference for the full schema.
:::

:::{dropdown} List of all usable document properties

  This list of properties is defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/mod.rs#L51) and the [document meta-schema](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json).

  | Property Name | Type | Description |
  |---------------|------|-------------|
  | `type`                               | string   | Specifies the type of the document, constrained to "object". |
  | `$schema`                            | string   | The schema URL reference for the document. |
  | `$defs`                              | object   | References the `documentProperties` definition. |
  | [`indices`](#document-indices)       | array    | Defines indices for the document with properties like `name`, `unique`, `nullSearchable`, and `contested`. |
  | `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |
  | `documentsKeepHistory`               | boolean  | If true, documents keep a history of all changes. Default: false. |
  | `documentsMutable`                   | boolean  | If true, documents are mutable. Default: true. |
  | `canBeDeleted`                       | boolean or string | Whether a document's owner can delete it: `true`, `false`, or `"onlyWhenConsumed"` (requires protocol version 14). See [Document Removal](../protocol-ref/data-contract-document.md#document-removal). Default: true. |
  | `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always |
  | `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval) |
  | `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No Creation Allowed. |
  | `keepsTransferHistory`               | boolean  | If true, transfers of these documents are recorded in the document history system contract. Default: false. |
  | `keepsPurchaseHistory`               | boolean  | If true, purchases of these documents are recorded in the document history system contract. Default: false. |
  | `keepsPricingHistory`                | boolean  | If true, price updates on these documents are recorded in the document history system contract. Default: false. |
  | [`requiresIdentity`<br>`EncryptionBoundedKey`](#key-management) | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`requiresIdentity`<br>`DecryptionBoundedKey`](#key-management) | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`properties`](#document-properties) | object   | Defines the properties of the document. |
  | [`transient`](#transient-properties) | array    | An array of strings specifying transient properties that are validated by Platform but not stored. |
  | `tokenCost`                          | object   | Defines token costs for document operations (create, replace, update_price, delete, transfer, purchase). See [Token Costs](../protocol-ref/data-contract-document.md#token-costs). |
  | [`documentsCountable`](../protocol-ref/data-contract-document.md#aggregate-query-flags) | boolean | Doctype-wide count support. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags). |
  | [`rangeCountable`](../protocol-ref/data-contract-document.md#aggregate-query-flags) | boolean | Per-index range counts. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags). |
  | [`documentsSummable`](../protocol-ref/data-contract-document.md#aggregate-query-flags) | string | Doctype-wide sums of the named integer property. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags). |
  | [`rangeSummable`](../protocol-ref/data-contract-document.md#aggregate-query-flags) | boolean | Per-index range sums. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags). |
  | [`documentsAverageable`](../protocol-ref/data-contract-document.md#aggregate-query-flags) | string | Doctype-wide averages of the named integer property. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags). |
  | [`rangeAverageable`](../protocol-ref/data-contract-document.md#aggregate-query-flags) | boolean | Per-index range averages. See [Aggregate Query Flags](../protocol-ref/data-contract-document.md#aggregate-query-flags). |
  | [`additionalProperties`](#additional-properties) | boolean  | Specifies whether additional properties are allowed. Must be set to false, meaning no additional properties are allowed beyond those defined. |
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

#### indexOnly document types

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

An `indexOnly` document type is never written to primary storage. Its index entries *are* the rows: each terminates in a value keyed by the index's [`terminal`](#indexonly-index-keywords) rather than a reference keyed by a document ID. Only what the indices hold exists and is recoverable, which makes the type cheaper to store at the cost of being queryable only along its declared indices.

Declaring `indexOnly: true` carries co-requirements:

* Every property must be required and appear in at least one index that sets neither `skipIfAbsent` nor `outlivesDelete`. The exception is a property in a [`skipIfAbsent`](#indexonly-index-keywords) skip set, which may be optional.
* Except for a `summableOffCountIndex` index, every index must include `$ownerId`, either as one of its properties or in its `terminal`.
* `documentsMutable` must be false.
* Transfers, trading, history, and transient properties are not allowed.
* Document-type-level aggregate keywords are not allowed; use the [index-level flags](#aggregate-index-flags) instead.
* Indices cannot be `unique`, contested, or `nullSearchable: false`, and only the `$ownerId` and `$createdAt` system properties may be indexed.
* At least one index must be free of `$createdAt` and not `skipIfAbsent` - the index the executed-transition proof relies on.

`indexOnly` types are the inner half of a [chained query](../reference/query-syntax.md#chained-queries).

### Document Properties

The `properties` object defines each field that a document will use. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`) and a [`position`](#assigning-property-position).

Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data. A full explanation of JSON Schema capabilities is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

#### Platform-specific property keywords

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

Beyond the standard JSON Schema constraints, Dash Platform defines its own property keywords.

**`refersTo`** declares that a property - typically an identifier - points at another Platform object, so consensus can enforce that the target exists and stays consistent. Its `type` names what is referenced - `identity`, `contract`, `token`, `identityPublicKey`, or a document (`permanentDocument`, `moderatedDocument`, or `deletableDocument`, depending on how the referenced document type's documents can be [removed](../protocol-ref/data-contract-document.md#document-removal)). Further members such as `findBy`, `where`, `inList`, `consume`, and `keyRequirements` refine the target, and `anyOf` / `allOf` combine declarations. See [Property References](../protocol-ref/data-contract-document.md#property-references) for the full grammar. The earlier `lookup` and `propertyAgreement` keywords and the `listElement` type are rejected.

A `permanentDocument` `refersTo` is what makes a property usable as the join property of a [chained query](../reference/query-syntax.md#chained-queries) or the by-ID binding of a [composite query](../reference/query-syntax.md#composite-queries).

**`requiredSince`** is an integer naming the contract version from which the property is required, letting a later contract version add a required property without invalidating documents written under earlier versions. On a contract update, a newly required property must carry a `requiredSince` equal to the new contract version; an existing property cannot become required.

Other property keywords - `maxBytes`, `generatedFrom`, `distinctFrom`, and `encryptedFor` - are described in [Additional Property Keywords](../protocol-ref/data-contract-document.md#additional-property-keywords).

Document types can also declare Platform-specific keywords at the type level: `ownerRefersTo` and `creatorRefersTo` ([Property References](../protocol-ref/data-contract-document.md#property-references)), `propertyConstraints`, `immutable`, `retractedWhen`, and `entryPayload` ([Document Configuration](../protocol-ref/data-contract-document.md#document-configuration)), `deleteConstraints` and `ttl` ([Document Removal](../protocol-ref/data-contract-document.md#document-removal)), `moderatorAbilities` ([Moderator Abilities](../protocol-ref/data-contract-document.md#moderator-abilities)), and `actionFees` ([Action Fees](../protocol-ref/data-contract-document.md#action-fees)).

#### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| ----------- | ----- |
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2761) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2762) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2740) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2740) |
| Property name characters     | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Underscore (`_`)<br>Hyphen (`-`) allowed only before protocol version 14 |

#### Assigning property `position`

Each property in a level must be assigned a unique `position` value, with ordering starting at zero and incrementing with each property. When using nested objects, position counting resets to zero for each level. This structure supports backward compatibility in data contracts by [ensuring consistent ordering](https://github.com/dashpay/platform/pull/1594) for serialization and deserialization processes.

#### Special requirements for `object` properties

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

#### Required Properties

Each document may have some fields that are required for the document to be valid and other optional fields. Required fields are defined via the `required` array, which contains a list of the field names that must be present in the document. The `required` object should only be included for documents with at least one required property.

**Example**  
The following example (excerpt from the DPNS contract's `domain` document) demonstrates a document that has defined required fields:

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
],
```

#### Transient Properties

Each document may have transient fields that require validation but do not need to be stored by the system once validated. Transient fields are defined in the `transient` array. The `transient` object should only be included for documents with at least one transient property.

**Example**  

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v2/dpns-contract-documents.json)) demonstrates a document that has 1 transient field:

```json
    "transient": [
      "preorderSalt"
    ]
```

### Document Indices

Document indices may be defined if indexing on document fields is required. The `indices` object should only be included for documents with at least one index.

The `indices` array consists of one or more objects that each contain:

* A unique `name` for the index
* A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index
  
  :::{admonition} Compound Indices
  :class: attention
  When defining an index with multiple properties, the ordering of properties is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details. Dash uses [GroveDB](https://github.com/dashpay/grovedb), which works similarly but requires listing all the index's fields in query order by statements.
  :::
* An optional `unique` element that determines if duplicate values are allowed for the document
* An optional `nullSearchable` element that indicates whether the index allows searching for NULL values. If nullSearchable is false (default: true) and all properties of the index are null then no reference is added.
* An optional `contested` element that configures a masternode-voting contest over documents whose field values match a defined pattern (see [Contested indices](#contested-indices)). It is an object composed of `fieldMatches` (field and `regexPattern` conditions) and a `resolution` method.
* Optional aggregate flags that let the index answer `COUNT` / `SUM` / `AVG` queries without walking every document (see [Aggregate index flags](#aggregate-index-flags)).
* Optional ranked, time-range, `skipIfAbsent`, and `indexOnly` keywords added at protocol version 14 (see [Ranked index flags](#ranked-index-flags) and [indexOnly index keywords](#indexonly-index-keywords)).

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
    "countable": "countable"|"countableAllowingOffset",
    "rangeCountable": true|false,
    "summable": "<integer field name>",
    "rangeSummable": true|false,
    "averageable": "<integer field name>",
    "rangeAverageable": true|false,
    "rankedCountable": true|false|{ "at": "<property>" },
    "rankedSummable": true|false,
    "rankedAverageable": true|false,
    "timeRange": { "on": "<$createdAt|$updatedAt|$transferredAt>", "range": <seconds>, "step": <seconds>, "phase": <seconds>, "ttl": <seconds> },
    "integerRange": { "on": "<integer property>", "range": <number>, "step": <number>, "phase": <number> },
    "terminal": "$ownerId"|"<property>"|["<property>", ...],
    "preallocated": true|false,
    "skipIfAbsent": true|false|["<property>", ...],
    "outlivesDelete": true|false,
    "summableOffCountIndex": "<index name>",
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
  }
]
:::

#### Contested indices

Contested unique indices provide a way for multiple identities to compete for ownership when a new document field matches a predefined pattern. This system enables fair distribution of valuable documents through community-driven decision-making.

A two week contest begins when a match occurs. For the first week, additional contenders can join by paying the [contested document vote resolution fund](../protocol-ref/protocol-constants.md#voting) fee (0.1 Dash from protocol version 14; 0.2 Dash in earlier versions). Starting in protocol version 14, the fee doubles for every 50 contenders beyond the first 250, and a contest accepts at most [1,000](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L177) contenders. During this period, masternodes and evonodes vote on the outcome. The contest can result in the awarding of the document to the winner, a locked vote where no document is awarded, or potentially a restart of the contest if specific conditions are met.

The table below describes the properties used to configure a contested index:

| Property Name | Type | Description |
|-|-|-|
| fieldMatches | array | Array containing conditions to check |
| fieldMatches.field | string | Name of the field to check for matches |
| fieldMatches.regexPattern | string | Regex used to check for matches |
| resolution | integer | Method to resolve the contest:<br>`0` - masternode voting |

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

#### Aggregate index flags

An index can carry aggregate flags so the node answers `COUNT`, `SUM`, and `AVG` queries from the index itself rather than by walking every matching document. See [Aggregate Queries](../reference/query-syntax.md#aggregate-queries) for the query side.

| Keyword | Type | Description |
|-|-|-|
| countable | string or boolean | Whether and how the index supports count fast paths - `notCountable`, `countable`, or `countableAllowingOffset`. Legacy booleans are accepted (`true` means `countable`). Adds storage cost for non-default values. |
| rangeCountable | boolean | Makes range-count queries on the indexed property O(log n). Requires `countable`. |
| summable | string | Names an integer document property whose values are aggregated into a sum at the index. The property must exist on the document type, be listed in `required`, and have a signed-or-unsigned integer type other than `u64` - values above `i64::MAX` cannot be represented in the sum tree. Every `summable` declaration on a document type must name the same property. |
| rangeSummable | boolean | Makes range-sum queries on the indexed property O(log n). Requires `summable`. |
| averageable | string | Shorthand for `countable: "countable"` plus `summable: "<property>"`, enabling average queries. If both `averageable` and `summable` are set they must name the same property. |
| rangeAverageable | boolean | Shorthand for `rangeCountable: true` plus `rangeSummable: true`. Requires `averageable`. |

#### Ranked index flags

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

Ranking axes let an index answer "top / bottom K groups by aggregate" queries with proofs. Each axis adds its own ordered secondary tree keyed by the group's aggregate, and each is opted into separately - none implies another. See [Ranked aggregate queries](../reference/query-syntax.md#ranked-aggregate-queries).

| Keyword | Type | Description |
|-|-|-|
| rankedCountable | boolean or object | Adds the Count ranking axis. Requires `rangeCountable: true`. The level-addressed form, `{"at": "<property>"}` or `{"at": ["<property>", ...]}`, places rankings at the named properties' levels instead of the terminal one; it cannot combine with `rankedSummable` or `rankedAverageable` when a non-terminal level is named. |
| rankedSummable | boolean | Adds the Sum ranking axis. Requires `rangeSummable: true`. |
| rankedAverageable | boolean | Adds the Avg ranking axis. Requires `rangeAverageable: true`. |

An index may also declare a `timeRange` transform, which buckets the first index property's timestamp into fixed-length, regularly spaced (possibly overlapping) windows:

| Property | Type | Required | Description |
|-|-|-|-|
| on | string | Yes | The timestamp property to bucket. Must be the index's first property and name one of `$createdAt`, `$updatedAt`, or `$transferredAt`. |
| range | integer | Yes | Window length in seconds. Must be an exact multiple of `step`. |
| step | integer | Yes | Spacing between consecutive window starts, in seconds. When `range` is greater than `step` the windows overlap. |
| phase | integer | No | Offset of the grid's origin, in seconds. Must be less than `step` and less than one year. Defaults to 0. |
| ttl | integer | No | Entry lifetime in seconds, measured from the start of its window. Must be at least `range` and at most [604,800](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L190) (one week) at protocol version 14. Indices that bucket the same timestamp on the same grid must all declare the same `ttl` or all omit it. Expired windows cannot be queried. Omit it for entries that live forever. |

The stored key is each window's start as a millisecond timestamp. Several indices may bucket the same timestamp with different grids; each grid gets its own subtree. At most 24 windows may overlap a single timestamp at protocol version 14. A time-range index may be unique only when `range` equals `step` and `on` is `$createdAt`, and it cannot be contested. A single-property time-range index cannot be ranked, because its only level is the bucketed one, and a time-range index cannot declare `preallocated`. Query these windows with the [`inTimeRange` operator](../reference/query-syntax.md#time-range-selection).

Bytes written under a `ttl` index are charged as processing at the [TTL ephemeral rate](../protocol-ref/protocol-constants.md#storage) instead of as storage, and are not refunded when removed.

Indices may also declare `integerRange`, which buckets the first index property's integer value into fixed-length windows, and, on `indexOnly` types, `summableOffCountIndex` and (for a `timeRange` index with a `ttl`) `outlivesDelete`. See [Optional Index Fields](../protocol-ref/data-contract-document.md#optional-index-fields).

An index may declare `skipIfAbsent`, so that a document omitting a property of the index's skip set writes no entry and the index holds only documents carrying every skip property. `true` makes the skip set every optional property of the index; an array names the skip set explicitly. A skip property may sit at any position in the index and must not be listed in `required`. An absent property is distinct from an empty value: absence skips the index, while any present value indexes normally. On a stored type, a skip index cannot be contested or set `nullSearchable: false`; `indexOnly` types add the [rules below](#indexonly-index-keywords).

#### indexOnly index keywords

:::{versionadded} 5.0.0
Requires protocol version 14.
:::

`terminal` and `preallocated` apply only to [`indexOnly` document types](#document-configuration), which also add rules to `skipIfAbsent`. See [Index-Only Options](../protocol-ref/data-contract-document.md#index-only-options) for details.

| Keyword | Type | Description |
|-|-|-|
| skipIfAbsent | boolean or array | The skip set must hold every optional property of the index, and every optional property needs a skip index whose skip set is that property alone and that has no `timeRange`. This is the only way an `indexOnly` property may be optional. |
| terminal | string or array | The property, or ordered list of up to 10 properties, whose values key each index entry - the analog of a document ID. Each component is `$ownerId` (the default) or a schema property an index could hold (no arrays or objects); every component but the last must be fixed width, and the whole key is at most 255 bytes. Must not repeat one of the index's properties. |
| preallocated | boolean | When true, creating a referenced document also creates this index's trees for entries referencing it, paid by that document's creator, so every entry insert costs the same as the first. Every index property must be either the referring property of a same-contract `permanentDocument` or `moderatedDocument` reference or a referring value of that reference's `where`. |

#### Index Constraints

For performance and security reasons, indices have the following constraints. These constraints are subject to change over time.

| Description | Value |
| ----------- | ----- |
| Minimum / maximum length of index `name` | [1](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2067) / [32](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2068) |
| Maximum number of indices | [10](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2456) |
| Maximum number of unique indices | [10](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v3.rs#L29) |
| Maximum number of properties in a single index | [10](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L2087) |
| Maximum length of indexed string property | [63](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L77) |
| Maximum length of indexed byte array property | [255](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/mod.rs#L78) |
| Maximum number of elements in an indexed typed array | [16](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L198), or [4](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L199) when the index also has a `timeRange` or `integerRange` (protocol version 14) |
| Usage of `$id` in an index [disallowed](https://github.com/dashpay/platform/pull/178) | N/A |

**Example**  
The following example (excerpt from the DPNS contract's `preorder` document) creates an index on `saltedDomainHash` that also enforces uniqueness across all documents of that type:

```json
"indices": [
  {
    "name": "saltedHash",
    "properties": [
      { "saltedDomainHash": "asc" }
    ],
    "unique": true
  }
],
```

### Full Document Syntax

This example syntax shows the structure of a document object including the most commonly used optional properties.

It is not exhaustive. The [aggregate index flags](#aggregate-index-flags), and the keywords added at protocol version 14 - [`indexOnly`](#indexonly-document-types), the [ranked and time-range index flags](#ranked-index-flags), the [`indexOnly` index keywords](#indexonly-index-keywords), and the [`refersTo` and `requiredSince`](#platform-specific-property-keywords) property keywords - are documented in their own sections above. For the authoritative set, see the [document meta-schema](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json).

::::{dropdown} Document schema
:open:

:::{code-block} json
:force:

{
  "<document name a>": {
    "documentsKeepHistory": true|false,
    "documentsMutable": true|false,
    "canBeDeleted": true|false|"onlyWhenConsumed",
    "transferable": 0|1,
    "tradeMode": 0|1,
    "creationRestrictionMode": 0|1|2,
    "requiresIdentityEncryptionBoundedKey": 0|1|2,
    "requiresIdentityDecryptionBoundedKey": 0|1|2,
    "signatureSecurityLevelRequirement": 1|2|3,
    "type": "object",
    "properties": {
      "<property name b>": {
        "type": "<property data type>",
        "position": "<number>"
      },
      "<property name c>": {
        "type": "<property data type>",
        "position": "<number>"
      },
    },
    "indices": [
      {
        "name": "<index name>",
        "properties": [
          { "<property name c>": "asc" },
        ], 
        "unique": true|false,
        "nullSearchable": true|false,
        "contested": {
          "fieldMatches": [
            {
              "field": "<property name c>",
              "regexPattern": "<regex>"
            }
          ],
          "resolution": 0
        }
      },
    ],
    "required": [
      "<field name c>"
    ],
    "transient": [
      "<field name b>"
    ]
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
::::

## General Constraints

There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [rs-dpp document meta schema](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json)).

### Keyword

| Keyword | Constraint |
| ------- | ---------- |
| `default`             | Restricted - cannot be used (defined in DPP logic) |
| `propertyNames`       | Restricted - cannot be used (defined in DPP logic) |
| `pattern: <something>` | `maxLength` must be defined (maximum: [50000](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L1838)) |
| `format: <something>` | `maxLength` must be defined (maximum: [50000](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json#L1851)) |
| `$ref: <something>`   | Internal references only - the value must begin with `#` (e.g. `#/$defs/myType`). External and remote references, and reference cycles, are rejected |
| `if`, `then`, `else`, `allOf`, `anyOf`, `oneOf`, `not` | Disabled for data contracts |
| `dependencies`        | Not supported. Use `dependentRequired` instead |
| `dependentSchemas`    | Not supported. Schema-based dependencies are not available in document schemas; use `dependentRequired` for property-presence dependencies |
| `type: array`         | Must be a byte array (`byteArray: true`) or, from protocol version 14 (5.0.0), a typed array whose `items` is an element schema of one scalar type: integer, number, string, boolean, or byte array (including identifiers). Objects and arrays of arrays are not allowed as elements. A typed array must define `maxItems`, at most [1024](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L138). See [Keyword Constraints](../protocol-ref/data-contract-document.md#keyword-constraints) |
| `additionalItems`     | Not supported. `prefixItems` is not available in document schemas, and `items` is limited to the typed array element schema described above |
| `patternProperties`   | Restricted - cannot be used for data contracts |
| `pattern`             | Accept only [RE2](https://github.com/google/re2/wiki/Syntax) compatible regular expressions (defined in DPP logic) |

### Data Size

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

A state transition is limited to a maximum size of [20 KiB](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L145) (`max_state_transition_size`). Oversized transitions are rejected.

An individual document field value is limited to [5 KiB](https://github.com/dashpay/platform/blob/v5.0.1/packages/rs-platform-version/src/version/system_limits/v4.rs#L134) (`max_field_value_size`).

### Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined (including within document properties of type `object`).

Include the following at the same level as the `properties` keyword to ensure proper validation:

```json
"additionalProperties": false
```
