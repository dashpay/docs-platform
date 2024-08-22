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

The following sections provide details that developers need to configure and construct valid contracts. All data contracts must define one or more [documents](#documents) that conform to the [general data contract constraints](#general-constraints). Additionally, several contract-level [configuration parameters](#contract-configuration) can be set to modify the mutability, retention, and security behavior of the contract and its documents.

## Contract Configuration

Data contracts support three categories of configuration options to provide flexibility in contract design. It is only necessary to include them in a data contract when non-default values are used.

| Contract option                         | Default | Description |
|-----------------------------------------|---------|-------------|
| `canBeDeleted`                          | `false` | Determines if the contract can be deleted |
| `readonly`                              | `false` | Determines if the contract is read-only |
| `keepsHistory`                          | `false` | Enables or disables the storing of contract update history |

| Document default option                 | Default | Description |
|-----------------------------------------|---------|-------------|
| `documentsKeepHistory`<br>`ContractDefault`   | `false` | Sets the default behavior for whether documents keep history within the contract|
| `documentsMutable`<br>`ContractDefault`       | `true`  | Sets the default mutability of documents within the contract |
| `documentsCanBeDeleted`<br>`ContractDefault`  | `true`  | Sets the default behavior for whether documents within the contract can be deleted|

| Security option                         | Description |
|-----------------------------------------|-------------|
| `requiresIdentity`<br>`EncryptionBoundedKey`  | Indicates the contract requires a contract-specific identity encryption key. Key options:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest  |
| `requiresIdentity`<br>`DecryptionBoundedKey`  | Indicates the contract requires a contract-specific identity decryption key. Key options:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest |

The default values for these configuration options are defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/src/data_contract/config/fields.rs).

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
| `canBeDeleted`                       | boolean  | If true, documents can be deleted. Default: true. |
| `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always |
| `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval) |
| `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No creation (System Only). |

| Security option | Type | Description |
|-----------------|------|-------------|
| `requiresIdentity`<br>`EncryptionBoundedKey` | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| `requiresIdentity`<br>`DecryptionBoundedKey` | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |

:::{dropdown} List of all usable document properties

  This list of properties is defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/v1.0.2/packages/rs-dpp/src/data_contract/document_type/mod.rs#L31) and the [document meta-schema](https://github.com/dashpay/platform/blob/v1.0.2/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json).

  | Property Name | Type | Description |
  |---------------|------|-------------|
  | `type`                               | string   | Specifies the type of the document, constrained to "object". |
  | `$schema`                            | string   | The schema URL reference for the document. |
  | `$defs`                              | object   | References the `documentProperties` definition. |
  | [`indices`](#document-indices)       | array    | Defines indices for the document with properties like `name`, `unique`, `nullSearchable`, and `contested`. |
  | `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |
  | `documentsKeepHistory`               | boolean  | If true, documents keep a history of all changes. Default: false. |
  | `documentsMutable`                   | boolean  | If true, documents are mutable. Default: true. |
  | `canBeDeleted`                       | boolean  | If true, documents can be deleted. Default: true. |
  | `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always |
  | `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval) |
  | `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No creation (System Only). |
  | `requiresIdentity`<br>`EncryptionBoundedKey` | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | `requiresIdentity`<br>`DecryptionBoundedKey` | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`properties`](#document-properties) | object   | Defines the properties of the document. |
  | [`transient`](#transient-properties) | array    | An array of strings specifying transient properties that are validated by Platform but not stored. |
  | [`additionalProperties`](#additional-properties) | boolean  | Specifies whether additional properties are allowed. Must be set to false, meaning no additional properties are allowed beyond those defined. |
:::

**Example**

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json)) demonstrates several the use of several configuration options:

```json
{
  "domain": {
    "documentsMutable": false,
    "canBeDeleted": true,
    "transferable": 1,
    "tradeMode": 1,
    "..."
  }
}
```

### Document Properties

The `properties` object defines each field that a document will use. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`) and a [`position`](#assigning-property-position).

Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data. A full explanation of JSON Schema capabilities is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

#### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| ----------- | ----- |
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L22) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L23) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L9) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L9) |
| Property name characters     | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hyphen (`-`) <br>Underscore (`_`) |

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
The following example (excerpt from the DPNS contract's `domain` document) demonstrates a document that has 6 required fields:

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

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json)) demonstrates a document that has 1 transient field:

```json
    "transient": [
      "preorderSalt"
    ]
```

### Document Indices

Document indices may be defined if indexing on document fields is required. The `indices` object should only be included for documents with at least one index.

The `indices` array consists of:

* One or more objects that each contain:
  * A unique `name` for the index
  * A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: [`asc` only](https://github.com/dashpay/platform/pull/435) for Dash Platform v0.23)
  * An (optional) `unique` element that determines if duplicate values are allowed for the document

:::{admonition} Compound Indices
:class: attention
When defining an index with multiple properties (i.e a compound index), the order in which the properties are listed is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details regarding the significance of the order as it relates to querying capabilities. Dash uses [GroveDB](https://github.com/dashpay/grovedb), which works similarly but does require listing all the index's fields in query order by statements.
:::

```json
"indices": [ 
  {
    "properties": [
      { "<field name a>": "<asc"|"desc>" },
      { "<field name b>": "<asc"|"desc>" }
    ], 
    "unique": true|false
  },
  {
    "properties": [
      { "<field name c>": "<asc"|"desc>" },
    ], 
  }    
]
```

#### Contested indices

Contested unique indices provide a way for multiple identities to compete for ownership when a new document field matches a predefined pattern. This system enables fair distribution of valuable documents through community-driven decision-making.

A two week contest begins when a match occurs. For the first week, additional contenders can join by paying a fee of 0.2 Dash. During this period, masternodes and evonodes vote on the outcome. The contest can result in the awarding of the document to the winner, a locked vote where no document is awarded, or potentially a restart of the contest if specific conditions are met.

The table below describes the properties used to configure a contested index:

| Property Name | Type | Description |
|-|-|-|
| fieldMatches | array | Array containing conditions to check |
| fieldMatches.field | string | Name of the field to check for matches |
| fieldMatches.regexPattern | string | Regex used to check for matches |
| resolution | integer | Method to resolve the contest:<br>`0` - masternode voting |

**Example**

This example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json)) demonstrates the use of a contested index:

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

#### Index Constraints

For performance and security reasons, indices have the following constraints. These constraints are subject to change over time.

| Description | Value |
| ----------- | ----- |
| Minimum/maximum length of index `name` | [1](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L413) / [32](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L414) |
| Maximum number of indices | [10](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L446) |
| Maximum number of unique indices | [3](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L40) |
| Maximum number of properties in a single index | [10](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L433) |
| Maximum length of indexed string property | [63](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L39) |
| **Note: Dash Platform v0.22+. [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225)**<br>Maximum length of indexed byte array property | [255](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L43) |
| **Note: Dash Platform v0.22+. [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225)**<br>Maximum number of indexed array items | [1024](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L44) |
| Usage of `$id` in an index [disallowed](https://github.com/dashpay/platform/pull/178) | N/A |

**Example**  
The following example (excerpt from the DPNS contract's `preorder` document) creates an index on `saltedDomainHash` that also enforces uniqueness across all documents of that type:

```json
"indices": [
  {
    "properties": [
      { "saltedDomainHash": "asc" }
    ],
    "unique": true
  }
],
```

### Full Document Syntax

This example syntax shows the structure of a documents object that defines two documents, an index, and a required field.

```json
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
```

## General Constraints

There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [rs-dpp data contract meta schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json)).

### Keyword

> 🚧
>
> The `$ref` keyword has been [disabled](https://github.com/dashpay/platform/pull/300) since Platform v0.22.

| Keyword | Constraint |
| ------- | ---------- |
| `default`                                              | Restricted - cannot be used (defined in DPP logic) |
| `propertyNames`                                        | Restricted - cannot be used (defined in DPP logic) |
| `uniqueItems: true`                                    | `maxItems` must be defined (maximum: 100000) |
| `pattern: <something>`                                 | `maxLength` must be defined (maximum: 50000) |
| `format: <something>`                                  | `maxLength` must be defined (maximum: 50000) |
| `$ref: <something>`                                    | Disabled for data contracts |
| `if`, `then`, `else`, `allOf`, `anyOf`, `oneOf`, `not` | Disabled for data contracts |
| `dependencies`                                         | Not supported. Use `dependentRequired` and `dependentSchema` instead |
| `additionalItems`                                      | Not supported. Use `items: false` and `prefixItems` instead |
| `patternProperties`                                    | Restricted - cannot be used for data contracts |
| `pattern`                                              | Accept only [RE2](https://github.com/google/re2/wiki/Syntax) compatible regular expressions (defined in DPP logic) |

### Data Size

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/util/serializer.rs#L8).

### Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined (including within document properties of type `object`).

Include the following at the same level as the `properties` keyword to ensure proper validation:

```json
"additionalProperties": false
```
