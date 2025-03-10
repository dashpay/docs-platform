# Contract Documents

The `documents` object defines each type of document required by the data contract. At a minimum, a document must consist of 1 or more properties. Documents may also define [indices](#document-indices) and a list of [required properties](#required-properties-optional). The `additionalProperties` properties keyword must be included as described in the [constraints](./data-contract.md#additional-properties) section.

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

## Document Properties

The `properties` object defines each field that will be used by a document. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`). Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data.

**Note:** The `object` type is required to have properties defined. For example, the body property shown below is an object containing a single string property (objectProperty):

```javascript
const contractDocuments = {
  message: {
    "type": "object",
    properties: {
      body: {
        type: "object",
        properties: {
          objectProperty: {
            type: "string",
            position: 0
          },
        },
        additionalProperties: false,
      },
      header: {
        type: "string",
        position: 1
      }
    },
    additionalProperties: false
  }
};
```

**Note:** A full explanation of the capabilities of JSON Schema is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

## Keyword Constraints

There are a variety of constraints currently defined for performance and security reasons. The
following constraints are applicable to document definitions. Unless otherwise noted, these
constraints are defined in the platform's JSON Schema rules (e.g. [rs-dpp document meta
schema](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json)).

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

### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| ----------- | ----- |
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L22) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L23) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L20) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L20) |
| Property name characters     | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hyphen (`-`) <br>Underscore (`_`) |

### Required Properties (Optional)

Each document may have some fields that are required for the document to be valid and other fields that are optional. Required fields are defined via the `required` array which consists of a list of the field names from the document that must be present. The `required` object should be excluded for documents without any required properties.

```json
"required": [
  "<field name a>",
  "<field name b>"
]
```

**Example**  
The following example (excerpt from the DPNS contract's `domain` document) demonstrates a document that has 6 required fields:

```json
"required": [
  "label",
  "normalizedLabel",
  "normalizedParentDomainName",
  "preorderSalt",
  "records",
  "subdomainRules"
]
```

## Document Indices

Document indices may be defined if indexing on document fields is required.

The `indices` array consists of:

- One or more objects that each contain:
  - A unique `name` for the index
  - A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: `asc` only for Dash Platform v0.23)
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
| Minimum/maximum length of index `name` | [1](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L311) / [32](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L312) |
| Maximum number of indices | [10](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L390) |
| Maximum number of unique indices | [10](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v2.rs#L24) |
| Maximum number of properties in a single index | [10](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json#L331) |
| Maximum length of indexed string property | [63](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/v0/mod.rs#L72) |
| Maximum number of contested indices | [1](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-platform-version/src/version/dpp_versions/dpp_validation_versions/v2.rs#L22) |
| Usage of `$id` in an index [disallowed](https://github.com/dashpay/platform/pull/178) | N/A |
| **Note: Dash Platform v0.22+ [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225).**<br>Maximum length of indexed byte array property | [255](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/v0/mod.rs#L73) |
| **Note: Dash Platform v0.22+ [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225).**<br>Maximum number of indexed array items         | [1024](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/src/data_contract/document_type/class_methods/try_from_schema/v0/mod.rs#L74) |

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

## Document Schema

Full document schema details may be found in the [rs-dpp document meta schema](https://github.com/dashpay/platform/blob/v1.7.1/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json).
