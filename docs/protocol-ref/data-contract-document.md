# Contract Documents

## Contract Document Overview

The `documents` object defines each type of document in the data contract. At a minimum, a document must consist of 1 or more properties. Documents may also define [indices](#document-indices) and a list of [required properties](#required-properties). The `additionalProperties` properties keyword must be included as described in the [constraints](./data-contract.md#additional-properties) section.

The following example shows a minimal `documents` object defining a single document (`note`) that has one property (`message`).

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

## Constraints

There are a variety of constraints currently defined for performance and security reasons. The
following constraints are applicable to document definitions. Unless otherwise noted, these
constraints are defined in the platform's JSON Schema rules (e.g. [rs-dpp document meta
schema](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json)).

### Keyword Constraints

| Keyword | Constraint |
| ------- | ---------- |
| `default`                   | Restricted - cannot be used (defined in DPP logic)  |
| `propertyNames`             | Restricted - cannot be used (defined in DPP logic) |
| `uniqueItems: true`         | `maxItems` must be defined (maximum: 100000) |
| `pattern: <something>`      | `maxLength` must be defined (maximum: 50000) |
| `format: <something>`       | `maxLength` must be defined (maximum: 50000) |
| `$ref: <something>`         | **Disabled**<br>`$ref` can only reference `$defs` - <br> remote references not supported |
| `if`, `then`, `else`, `allOf`, `anyOf`, `oneOf`, `not` | Disabled for data contracts |
| `dependencies`              | Not supported. Use `dependentRequired` and `dependentSchema` instead |
| `additionalItems`           | Not supported. Use `items: false` and `prefixItems` instead |
| `patternProperties`         | Restricted - cannot be used for data contracts |
| `pattern`                   | Accept only [RE2](https://github.com/google/re2/wiki/Syntax) compatible regular expressions (defined in DPP logic) |

## Document properties

The `properties` object defines each field that will be used by a document. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`).

Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data. A full explanation of the capabilities of JSON Schema is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| ----------- | ----- |
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L22) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L23) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L20) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L20) |
| Property name characters     | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hyphen (`-`) <br>Underscore (`_`) |

### Assigning property `position`

Each property in a level must be assigned a unique `position` value, with ordering starting at zero and incrementing with each property. When using nested objects, position counting resets to zero for each level. This structure supports backward compatibility in data contracts by [ensuring consistent ordering](https://github.com/dashpay/platform/pull/1594) for serialization and deserialization processes.

### Special requirements for `object` properties

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

Each document may have some fields that are required for the document to be valid and other fields that are optional. Required fields are defined via the `required` array which consists of a list of the field names from the document that must be present. The `required` object should be excluded for documents without any required properties.

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

### Transient Properties

Each document may have transient fields that require validation but do not need to be stored by the system once validated. Transient fields are defined in the `transient` array. The `transient` object should only be included for documents with at least one transient property.

**Example**  

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json)) demonstrates a document that has 1 transient field:

```json
    "transient": [
      "preorderSalt"
    ]
```

## Document Configuration

Documents support the following configuration options to provide flexibility in contract design. It is only necessary to include them in a data contract when non-default values are used.

| Document option | Type | Description |
|-----------------|------|-------------|
| `documentsKeepHistory`               | boolean  | If true, documents keep a history of all changes. Default: false. |
| `documentsMutable`                   | boolean  | If true, documents are mutable. Default: true. |
| `canBeDeleted`                       | boolean  | If true, documents can be deleted. Default: true. |
| `transferable`                       | integer  | Transferable without a marketplace sell:<br>`0` - Never<br>`1` - Always<br>See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details |
| `tradeMode`                          | integer  | Built-in marketplace system:<br>`0` - None<br>`1` - Direct purchase (the purchaser can buy the item without requiring approval)<br>See the [NFT page](../explanations/nft.md#transfer-and-trade) for more details |
| `creationRestrictionMode`            | integer  | Restriction of document creation:<br>`0` - No restrictions<br>`1` - Contract owner only<br>`2` - No creation (System Only)<br>See the [NFT page](../explanations/nft.md#creation-restrictions) for more details |

| Security option | Type | Description |
|-----------------|------|-------------|
| [`requiresIdentity`<br>`EncryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| [`requiresIdentity`<br>`DecryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
| `signatureSecurity`<br>`LevelRequirement`  | integer  | Public key security level:<br>`1` - Critical<br>`2` - High<br>`3` - Medium. Default is High if none specified. |

:::{dropdown} List of all usable document properties

  This list of properties is defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/src/data_contract/document_type/mod.rs#L31) and the [document meta-schema](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json).

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
  | [`requiresIdentity`<br>`EncryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity encryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`requiresIdentity`<br>`DecryptionBoundedKey`](./data-contract.md#key-management) | integer  | Key requirements for identity decryption:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest key |
  | [`properties`](#document-properties) | object   | Defines the properties of the document. |
  | [`transient`](#transient-properties) | array    | An array of strings specifying transient properties that are validated by Platform but not stored. |
  | [`additionalProperties`](./data-contract.md#additional-properties) | boolean  | Specifies whether additional properties are allowed. Must be set to false, meaning no additional properties are allowed beyond those defined. |

:::

**Example**

The following example (from the [DPNS contract's `domain` document](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json)) demonstrates the use of several configuration options:

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

## Document indices

Document indices may be defined if indexing on document fields is required.

The `indices` array consists of:

- One or more objects that each contain:
  - A unique `name` for the index
  - A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: `asc` only)
  - An (optional) `unique` element that determines if duplicate values are allowed for the document type

**Note:**

- The `indices` object should be excluded for documents that do not require indices.
- When defining an index with multiple properties (i.e a compound index), the order in which the properties are listed is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details regarding the significance of the order as it relates to querying capabilities. Dash uses [GroveDB](https://github.com/dashpay/grovedb) which works similarly but does requiring listing _all_ the index's fields in query order by statements.

```json
"indices": [
  {
    "name": "Index1",
    "properties": [
      { "<field name a>": "asc" },
      { "<field name b>": "asc" }
    ],
    "unique": true|false
  },
  {
    "name": "Index2",
    "properties": [
      { "<field name c>": "asc" },
    ],
  }
]
```

### Index Constraints

For performance and security reasons, indices have the following constraints. These constraints are subject to change over time.

| Description | Value |
| ----------- | ----- |
| Minimum/maximum length of index `name` | [1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L311) / [32](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L312) |
| Maximum number of indices | [10](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L390) |
| Maximum number of unique indices | [10](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v2.rs#L26) |
| Maximum number of contested indices | [1](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v2.rs#L26) |
| Maximum number of properties in a single index | [10](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L331) |
| Maximum length of indexed string property | [63](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/v0/mod.rs#L72) |
| Usage of `$id` in an index [disallowed](https://github.com/dashpay/platform/pull/178) | N/A |
| **Note: Dash Platform [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225).**<br>Maximum length of indexed byte array property | [255](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/v0/mod.rs#L73) |
| **Note: Dash Platform [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225).**<br>Maximum number of indexed array items         | [1024](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/v0/mod.rs#L74) |

**Example**  
The following example (excerpt from the DPNS contract's `preorder` document) creates an index named `saltedHash` on the `saltedDomainHash` property that also enforces uniqueness across all documents of that type:

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

## Full Document Syntax

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
```

## Document Schema

Full document schema details may be found in the [rs-dpp document meta schema](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json).
