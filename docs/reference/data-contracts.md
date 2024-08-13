```{eval-rst}
.. _reference-data-contracts:
```

# Data Contracts

## Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the submitted contract-related data.

The following sections provide details that developers need to construct valid contracts. All data contracts must define one or more [documents](#documents) that conform to the [general data contract constraints](#general-constraints).

## Documents

The `documents` object defines each type of document required by the data contract. At a minimum, a document must consist of 1 or more [properties](#document-properties). Documents may also define [indices](#document-indices) and a list of [required properties](#required-properties-optional). The `additionalProperties` properties keyword must be included as described in the [constraints](#additional-properties) section.

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

### Document Properties

The `properties` object defines each field that a document will use. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`) and a [`position`](#assigning-property-position).

Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data. A full explanation of JSON Schema capabilities is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

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

#### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| ----------- | ----- |
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L22) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L23) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L20) (Note: minimum length was 3 prior to v0.23) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L20) |
| Property name characters     | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hyphen (`-`) <br>Underscore (`_`) |

Prior to Dash Platform v0.23 there were stricter limitations on minimum property name length and the characters that could be used in property names.

#### Required Properties (Optional)

Each document may have some fields that are required for the document to be valid and other optional fields. Required fields are defined via the `required` array, which contains a list of the field names that must be present in the document. The `required` object should only be included for documents with at least one required property.

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
  "nameHash",
  "label",
  "normalizedLabel",
  "normalizedParentDomainName",
  "preorderSalt",
  "records"
],
```

### Document Indices

Document indices may be defined if indexing on document fields is required. The `indices` object should only be included for documents with at least one index.

The `indices` array consists of:

* One or more objects that each contain:
  * A unique `name` for the index
  * A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: [`asc` only](https://github.com/dashpay/platform/pull/435) for Dash Platform v0.23)
  * An (optional) `unique` element that determines if duplicate values are allowed for the document

> 🚧 Compound Indices
>
> When defining an index with multiple properties (i.e a compound index), the order in which the properties are listed is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details regarding the significance of the order as it relates to querying capabilities. Dash uses [GroveDB](https://github.com/dashpay/grovedb), which works similarly but does require listing all the index's fields in query order by statements.

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
