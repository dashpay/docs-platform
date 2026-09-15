```{eval-rst}
.. _protocol-ref-data-contract:
```

# Data Contract

## Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts. All data contracts must define at least one [document](#data-contract-documents) or [token](#data-contract-tokens). A contract may define multiple documents and/or tokens.

### Fees

Dash Platform charges fees for registering data contracts based on complexity. These fees compensate evonodes for their role in storing and processing contract-related data.

The table below outlines the current fee structure for various data contract components. Fees are denominated in DASH and are charged at registration time based on the structure of the contract. The amounts are [defined in rs-platform-version](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/fee/data_contract_registration/v2.rs#L4-L15).

| Fee Component                                          | Amount (DASH) | Description |
|--------------------------------------------------------|-------------------|---------|
| `base_contract_registration_fee`                       | 0.1  | Fixed fee for every data contract. Covers the baseline cost of anchoring a contract into platform state. |
| `document_type_registration_fee`                       | 0.02 | Charged per [document type](./data-contract-document.md#contract-documents). Reflects indexing and storage schema overhead. |
| `document_type_base_non_unique`<br>`_index_registration_fee` | 0.01 | Per non-unique [index](./data-contract-document.md#document-indices) in a document type. Supports query operations. |
| `document_type_base_unique_index`<br>`_registration_fee`            | 0.01 | Per unique [index](./data-contract-document.md#document-indices). Enforces uniqueness and adds validation complexity. |
| `document_type_base_contested`<br>`_index_registration_fee`         | 1.0  | Per [contested index](./data-contract-document.md#contested-indices). Used for identity/username resolution; requires voting and [conflict resolution](../explanations/dpns.md#conflict-resolution) by masternodes and evonodes. |
| `token_registration_fee`                                      | 0.1  | Per token defined in the contract. Reflects additional overhead from managing balances, transfers, and supply. |
| `token_uses_perpetual`<br>`_distribution_fee`                       | 0.1  | Additional fee for tokens that use perpetual (e.g., block-based) distribution mechanisms. These create ongoing state changes triggered by network events. |
| `token_uses_pre_programmed`<br>`_distribution_fee`                  | 0.1  | Charged when tokens use scheduled distributions (e.g., airdrops). Adds periodic complexity. |
| `search_keyword_fee`                                          | 0.1 per keyword   | Charged per search keyword defined. Keywords enable reverse lookups and indexing, increasing on-chain storage and filtering load. |

These fees are additive, but each index pays only one of the three index fees: the contested fee if the index is contested, otherwise the unique fee if it is unique, otherwise the non-unique fee. A contested index is always unique and pays only the contested fee. For example, a contract that defines two document types, each with one unique index, and one token using a perpetual distribution will incur the following total fee:

```text
0.1 (base contract) + 0.02×2 (document types) + 0.01×2 (1 unique index per document type × 2) = 0.16 DASH
0.1 (token registration) + 0.1 (perpetual distribution) = 0.2 DASH

Total fee: 0.16 + 0.2 = 0.36 DASH
```

### General Constraints

There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts.

#### Data Size

| Parameter | Size |
| - | - |
| Estimated maximum serialized data contract size | [16384 bytes (16 KB)](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L39) |
| Maximum field value size | [5120 bytes (5 KB)](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L40) |
| Maximum state transition size | [20480 bytes (20 KB)](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L44) |

A document cannot exceed the maximum state transition size in any case. For example, although it is
possible to define a data contract with 10 document fields that each support the maximum field size
(5120), it is not possible to create a document where all 10 fields contain the full 5120 bytes.
This is because the overall document and state transition containing it would be too large (5120 *
10 = 51200 bytes).

#### Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined (including within document properties of type `object`).

Include the following at the same level as the `properties` keyword to ensure proper validation:

```json
"additionalProperties": false
```

## Data Contract Object

The data contract object consists of the following fields as defined in the Rust reference client ([rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/v1/data_contract.rs#L77-L121)):

| Property        | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| [id](#data-contract-id)         | array of bytes | 32 bytes      | Contract ID generated from `ownerId` and identity nonce (content media type: `application/x.dash.dpp.identifier`) |
| [version](#data-contract-version) | unsigned integer        | 32 bits      | The data contract version |
| ownerId         | array of bytes | 32 bytes      | [Identity](../protocol-ref/identity.md) that registered the data contract defining the document (content media type: `application/x.dash.dpp.identifier`) |
| [documents](./data-contract-document.md) | object         | Varies    | (Optional \*) Document definitions (see [Contract Documents](./data-contract-document.md) for details) |
| [config](#data-contract-config) | DataContractConfig | Varies | (Optional) Internal configuration for the contract |
| $defs           | object         | Varies       | (Optional) Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with \<= 100 valid properties) |
| [groups](#data-contract-groups) | Group | Varies | (Optional) Groups that allow for specific multiparty actions on the contract. |
| [tokens](./data-contract-token.md) | object         | Varies    | (Optional \*) Token definitions (see [Contract Tokens](./data-contract-token.md) for details) |
| keywords | array of strings | Varies | (Optional) Keywords associated with the contract to improve searchability. Maximum of 50 keywords. Each keyword must be 3-50 bytes, must not contain control or whitespace characters, and must be unique within the array. |
| description | string | 3-100 bytes on create<br>3-100 characters on update | (Optional) Brief description of the contract. The length limit is measured in bytes at registration and in characters on update, so the two bounds differ for non-ASCII text. |
| createdAt | unsigned integer | 64 bits | (Read-only) Timestamp in milliseconds when the contract was created. Set by platform. |
| updatedAt | unsigned integer | 64 bits | (Read-only) Timestamp in milliseconds when the contract was last updated. Set by platform. |
| createdAtBlockHeight | unsigned integer | 64 bits | (Read-only) Block height at contract creation. Set by platform. |
| updatedAtBlockHeight | unsigned integer | 64 bits | (Read-only) Block height at last contract update. Set by platform. |
| createdAtEpoch | unsigned integer | 16 bits | (Read-only) Epoch index at contract creation. Set by platform. |
| updatedAtEpoch | unsigned integer | 16 bits | (Read-only) Epoch index at last contract update. Set by platform. |

\* The data contract object must define documents or tokens. It may include both documents and tokens.

### Document type meta-schema

Each document type defined within a data contract is validated against the document meta-schema. The meta-schema version is determined by the protocol version in effect:

| Meta-schema | Protocol version |
| - | - |
| v3 | 14 and later |
| v2 | 13 |
| v1 | 12 |
| v0 | 11 and earlier |

This page reflects the v3 meta-schema, which adds the `refersTo` and `requiredSince` property keywords, the `indexOnly` document type flag, and the `rankedCountable`, `rankedSummable`, `rankedAverageable`, `skipIfAbsent`, `preallocated`, `terminal` and `timeRange` index keywords on top of the v2 [document history flags](./data-contract-document.md#document-history-flags). The full schema is [defined in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/schema/meta_schemas/document/v3/document-meta.json) and can be viewed by expanding this dropdown:

::: {dropdown} Full schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v1/document-meta.json",
  "$comment": "EDITABLE UNTIL THE RELEASE CARRYING PROTOCOL V14 SHIPS — FROZEN AFTER. This v3 document meta-schema activates with protocol v14 (CONTRACT_VERSIONS_V6). It is v2 plus the ranked index keywords (rankedCountable, rankedSummable, rankedAverageable), the refersTo reference keyword on identifier properties, the requiredSince property keyword (the contract version a property is required from), and the timeRange index transform, and admits every v14+ contract written to disk. v2 stays in place for protocol v13, where those keys still fail an index entry's `additionalProperties: false`. Once the release carrying protocol v14 ships, mutating it would change historical validation results and break consensus replay. After release, any new top-level property or rule MUST go in a newer meta-schema version (v4+). The $id above deliberately still names the v1 path: v1, v2 and v3 all share that identity, and it is the exact string `enrich_with_base_schema` injects as every PV12+ document schema's `$schema`, so bumping it here would be a wire-visible change rather than a documentation fix.",
  "type": "object",
  "$defs": {
    "documentProperties": {
      "type": "object",
      "patternProperties": {
        "^[a-zA-Z0-9-_]{1,64}$": {
          "type": "object",
          "allOf": [
            {
              "$ref": "#/$defs/documentSchema"
            }
          ],
          "unevaluatedProperties": false
        }
      },
      "propertyNames": {
        "pattern": "^[a-zA-Z0-9-_]{1,64}$"
      },
      "minProperties": 1,
      "maxProperties": 100
    },
    "documentSchemaArray": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "allOf": [
          {
            "$ref": "#/$defs/documentSchema"
          }
        ],
        "unevaluatedProperties": false
      }
    },
    "documentSchema": {
      "type": "object",
      "properties": {
        "$id": {
          "type": "string",
          "pattern": "^#",
          "minLength": 1
        },
        "$ref": {
          "type": "string",
          "pattern": "^#",
          "minLength": 1
        },
        "$comment": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/core#/properties/$comment"
        },
        "description": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/meta-data#/properties/description"
        },
        "examples": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/meta-data#/properties/examples"
        },
        "multipleOf": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/multipleOf"
        },
        "maximum": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/maximum"
        },
        "exclusiveMaximum": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/exclusiveMaximum"
        },
        "minimum": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/minimum"
        },
        "exclusiveMinimum": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/exclusiveMinimum"
        },
        "maxLength": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/maxLength"
        },
        "minLength": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/minLength"
        },
        "pattern": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/pattern"
        },
        "maxItems": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/maxItems"
        },
        "minItems": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/minItems"
        },
        "uniqueItems": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/uniqueItems"
        },
        "refersTo": {
          "type": "object",
          "properties": {
            "type": {
              "enum": [
                "identity",
                "contract",
                "token",
                "permanentDocument",
                "identityPublicKey"
              ]
            },
            "contractId": {
              "description": "The id of the data contract the referenced document lives in, as a base58 string or a 32-byte array; when absent the reference targets the declaring contract itself",
              "oneOf": [
                {
                  "type": "string",
                  "minLength": 32,
                  "maxLength": 44,
                  "pattern": "^[123456789A-HJ-NP-Za-km-z]{32,44}$"
                },
                {
                  "type": "array",
                  "minItems": 32,
                  "maxItems": 32,
                  "items": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 255
                  }
                }
              ]
            },
            "documentType": {
              "description": "The name of the referenced document type; it must forbid deletion (canBeDeleted: false)",
              "type": "string",
              "minLength": 1,
              "maxLength": 64,
              "pattern": "^[a-zA-Z0-9-_]{1,64}$"
            },
            "keyIdProperty": {
              "description": "The property of the same document type whose value carries the referenced key id; the reference property's value carries the identity id",
              "type": "string",
              "minLength": 1,
              "maxLength": 256,
              "pattern": "^[a-zA-Z0-9-_]{1,64}(\\.[a-zA-Z0-9-_]{1,64})*$"
            },
            "propertyAgreement": {
              "description": "permanentDocument references only: each { referring property: referenced property } pair must hold as an equality between the referring document's value and the referenced document's value, enforced by consensus at document write time; both properties must exist and share one property type, validated at contract registration",
              "type": "object",
              "minProperties": 1,
              "maxProperties": 10,
              "propertyNames": {
                "pattern": "^[a-zA-Z0-9-_]{1,64}(\\.[a-zA-Z0-9-_]{1,64})*$"
              },
              "additionalProperties": {
                "type": "string",
                "minLength": 1,
                "maxLength": 256,
                "pattern": "^[a-zA-Z0-9-_]{1,64}(\\.[a-zA-Z0-9-_]{1,64})*$"
              }
            }
          },
          "required": [
            "type"
          ],
          "additionalProperties": false,
          "allOf": [
            {
              "if": {
                "properties": { "type": { "const": "permanentDocument" } },
                "required": ["type"]
              },
              "then": {
                "required": ["type", "documentType"]
              },
              "else": {
                "properties": {
                  "contractId": false,
                  "documentType": false
                }
              }
            },
            {
              "if": {
                "properties": { "type": { "const": "identityPublicKey" } },
                "required": ["type"]
              },
              "then": {
                "required": ["type", "keyIdProperty"]
              },
              "else": {
                "properties": {
                  "keyIdProperty": false
                }
              }
            }
          ]
        },
        "contains": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/applicator#/properties/contains"
        },
        "maxProperties": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/maxProperties"
        },
        "minProperties": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/minProperties"
        },
        "required": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/required"
        },
        "additionalProperties": {
          "type": "boolean",
          "const": false
        },
        "properties": {
          "$ref": "#/$defs/documentProperties"
        },
        "dependentRequired": {
          "type": "object",
          "minProperties": 1,
          "additionalProperties": {
            "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/$defs/stringArray"
          }
        },
        "const": true,
        "enum": {
          "type": "array",
          "items": true,
          "minItems": 1,
          "uniqueItems": true
        },
        "type": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/validation#/properties/type"
        },
        "format": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/format-annotation#/properties/format"
        },
        "contentMediaType": {
          "$ref": "https://json-schema.org/draft/2020-12/meta/content#/properties/contentMediaType"
        },
        "byteArray": {
          "type": "boolean",
          "const": true
        },
        "position": {
          "type": "integer",
          "minimum": 0
        },
        "requiredSince": {
          "type": "integer",
          "minimum": 1,
          "maximum": 4294967295
        }
      },
      "dependentSchemas": {
        "byteArray": {
          "description": "should be used only with array type",
          "properties": {
            "type": {
              "type": "string",
              "const": "array"
            }
          }
        },
        "contentMediaType": {
          "if": {
            "properties": {
              "contentMediaType": {
                "const": "application/x.dash.dpp.identifier"
              }
            }
          },
          "then": {
            "properties": {
              "byteArray": {
                "const": true
              },
              "minItems": {
                "const": 32
              },
              "maxItems": {
                "const": 32
              }
            },
            "required": [
              "byteArray",
              "minItems",
              "maxItems"
            ]
          }
        },
        "pattern": {
          "description": "prevent slow pattern matching of large strings",
          "properties": {
            "maxLength": {
              "type": "integer",
              "minimum": 0,
              "maximum": 50000
            }
          },
          "required": [
            "maxLength"
          ]
        },
        "refersTo": {
          "description": "refersTo is only allowed on identifier properties",
          "properties": {
            "type": {
              "const": "array"
            },
            "byteArray": {
              "const": true
            },
            "contentMediaType": {
              "const": "application/x.dash.dpp.identifier"
            },
            "minItems": {
              "const": 32
            },
            "maxItems": {
              "const": 32
            }
          },
          "required": [
            "type",
            "byteArray",
            "contentMediaType",
            "minItems",
            "maxItems"
          ]
        },
        "format": {
          "description": "prevent slow format validation of large strings",
          "properties": {
            "maxLength": {
              "type": "integer",
              "minimum": 0,
              "maximum": 50000
            }
          },
          "required": [
            "maxLength"
          ]
        }
      },
      "allOf": [
        {
          "$comment": "require index for object properties",
          "if": {
            "properties": {
              "type": {
                "const": "object"
              }
            },
            "required": [
              "type"
            ]
          },
          "then": {
            "properties": {
              "properties": {
                "type": "object",
                "additionalProperties": {
                  "type": "object",
                  "properties": {
                    "position": true
                  },
                  "required": [
                    "position"
                  ]
                }
              }
            }
          }
        },
        {
          "$comment": "allow only byte arrays",
          "if": {
            "properties": {
              "type": {
                "const": "array"
              }
            },
            "required": [
              "type"
            ]
          },
          "then": {
            "properties": {
              "byteArray": true
            },
            "required": [
              "byteArray"
            ]
          }
        },
        {
          "$comment": "all object properties must be defined",
          "if": {
            "properties": {
              "type": {
                "const": "object"
              }
            },
            "not": {
              "properties": {
                "$ref": true
              },
              "required": [
                "$ref"
              ]
            }
          },
          "then": {
            "properties": {
              "properties": {
                "$ref": "#/$defs/documentProperties"
              },
              "additionalProperties": {
                "$ref": "#/$defs/documentSchema/properties/additionalProperties"
              }
            },
            "required": [
              "properties",
              "additionalProperties"
            ]
          }
        }
      ]
    },
    "documentActionTokenCost": {
      "type": "object",
      "properties": {
        "contractId": {
          "type": "array",
          "contentMediaType": "application/x.dash.dpp.identifier",
          "byteArray": true,
          "minItems": 32,
          "maxItems": 32
        },
        "tokenPosition": {
          "type": "integer",
          "minimum": 0,
          "maximum": 65535
        },
        "amount": {
          "type": "integer",
          "minimum": 1,
          "maximum": 281474976710655
        },
        "effect": {
          "type": "integer",
          "enum": [
            0,
            1
          ],
          "description": "0 - TransferTokenToContractOwner (default), 1 - Burn"
        },
        "gasFeesPaidBy": {
          "type": "integer",
          "enum": [
            0,
            1,
            2
          ],
          "description": "0 - DocumentOwner (default), 1 - ContractOwner, 2 - PreferContractOwner"
        }
      },
      "required": [
        "tokenPosition",
        "amount"
      ],
      "additionalProperties": false
    }
  },
  "properties": {
    "type": {
      "type": "string",
      "const": "object"
    },
    "$schema": {
      "type": "string",
      "const": "https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v1/document-meta.json"
    },
    "$defs": {
      "$ref": "#/$defs/documentProperties"
    },
    "indices": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 32
          },
          "properties": {
            "type": "array",
            "items": {
              "type": "object",
              "propertyNames": {
                "maxLength": 256
              },
              "additionalProperties": {
                "type": "string",
                "enum": [
                  "asc"
                ]
              },
              "minProperties": 1,
              "maxProperties": 1
            },
            "minItems": 1,
            "maxItems": 10
          },
          "unique": {
            "type": "boolean"
          },
          "nullSearchable": {
            "type": "boolean"
          },
          "contested": {
            "type": "object",
            "properties": {
              "fieldMatches": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "field": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 256
                    },
                    "regexPattern": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 256
                    }
                  },
                  "additionalProperties": false,
                  "required": [
                    "field",
                    "regexPattern"
                  ]
                },
                "minItems": 1
              },
              "resolution": {
                "type": "integer",
                "enum": [
                  0
                ],
                "description": "Resolution. 0 - Masternode Vote"
              },
              "description": {
                "type": "string",
                "minLength": 1,
                "maxLength": 256
              }
            },
            "required": [
              "resolution"
            ],
            "additionalProperties": false
          },
          "countable": {
            "oneOf": [
              {
                "type": "boolean",
                "description": "Legacy form. true == \"countable\", false == \"notCountable\". Kept for back-compat with contracts written before the enum form was introduced."
              },
              {
                "type": "string",
                "enum": ["notCountable", "countable", "countableAllowingOffset"],
                "description": "\"countable\" — index uses a CountTree (O(1) totals). \"countableAllowingOffset\" — index uses a ProvableCountTree (totals + future O(log n) range / offset queries). \"notCountable\" — plain NormalTree (no count fast path)."
              }
            ],
            "description": "Whether and how the index supports count fast paths. Adds extra storage cost for non-default values."
          },
          "rangeCountable": {
            "type": "boolean",
            "description": "When true, the property-name level becomes a ProvableCountTree and value trees become CountTrees so range-count queries on the indexed property are O(log n). Requires `countable` to be \"countable\" or \"countableAllowingOffset\"."
          },
          "summable": {
            "type": "string",
            "minLength": 1,
            "maxLength": 64,
            "description": "Name of an integer document property whose values are aggregated into a sum at the index. When set, the index's value trees become SumTrees and each per-document index reference is a ReferenceWithSumItem contributing the named property's value to ancestor sum-bearing trees. The property must exist on the document type, be in `required`, and have an integer type."
          },
          "rangeSummable": {
            "type": "boolean",
            "description": "When true, the property-name level becomes a ProvableSumTree (or ProvableCountProvableSumTree when paired with `rangeCountable: true`) so range-sum queries on the indexed property are O(log n) via the `AggregateSumOnRange` proof primitive. Requires `summable` to be set."
          },
          "averageable": {
            "type": "string",
            "minLength": 1,
            "maxLength": 64,
            "description": "Syntactic sugar: `averageable: \"<prop>\"` is shorthand for `countable: \"countable\"` + `summable: \"<prop>\"`. Enables average queries (which return `(count, sum)` pairs the client divides) without forcing authors to think in terms of count + sum. Same on-disk layout as setting both underlying flags. If you set both `averageable` and `summable`, they must name the same property."
          },
          "rangeAverageable": {
            "type": "boolean",
            "description": "Syntactic sugar: `rangeAverageable: true` is shorthand for `rangeCountable: true` + `rangeSummable: true`. Requires `averageable` to be set."
          },
          "rankedCountable": {
            "oneOf": [
              {
                "type": "boolean",
                "description": "When true, the index's terminal property-name tree also carries an ordered secondary tree keyed by each group's document count, so \"top / bottom K groups by count\" queries are O(log n + k) with proofs."
              },
              {
                "type": "object",
                "properties": {
                  "at": {
                    "oneOf": [
                      {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 256
                      },
                      {
                        "type": "array",
                        "items": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 256
                        },
                        "minItems": 1,
                        "maxItems": 10,
                        "uniqueItems": true
                      }
                    ],
                    "description": "Name of the index property (or array of properties) whose levels carry Count rankings. Each must be one of the index's properties (an index has at most 10, hence maxItems); naming the last property is equivalent to the boolean form. A non-terminal property places a ranking at that prefix level: its values are ranked by whole-subtree document count (e.g. on [hashtag, postId], at: \"hashtag\" ranks hashtags by total count across all their posts), and every level from the shallowest ranked one down to the terminal is laid out count-bearing so each write's delta propagates up through the chain. ANY subset of levels may be named — e.g. [\"hashtag\", \"postId\"] declares both rankings on one index, and a fully ranked index ranks every level."
                  }
                },
                "required": ["at"],
                "additionalProperties": false,
                "description": "Level-addressed form: places Count rankings at the named properties' levels. Cannot be combined with rankedSummable or rankedAverageable when a non-terminal level is named, and no other index of the document type may share a non-terminal ranked level or any level below it."
              }
            ],
            "description": "Count ranking axis. Requires `rangeCountable: true`. Independent of the Sum and Avg axes (`rankedSummable` / `rankedAverageable`), which stay terminal-level booleans."
          },
          "rankedSummable": {
            "type": "boolean",
            "description": "When true, the index's terminal property-name tree also carries an ordered secondary tree keyed by each group's sum of the `summable` property, so \"top / bottom K groups by sum\" queries are O(log n + k) with proofs. Requires `rangeSummable: true`. Adds the Sum ranking axis only."
          },
          "rankedAverageable": {
            "type": "boolean",
            "description": "When true, the index's terminal property-name tree also carries an ordered secondary tree keyed by each group's average (count + sum pair) of the `averageable` property, so \"top / bottom K groups by average\" queries are O(log n + k) with proofs. Requires `rangeAverageable: true` (which itself implies `rangeCountable` + `rangeSummable`). Adds the Avg ranking axis only — it does NOT imply `rankedCountable` or `rankedSummable`; each ranking axis costs its own secondary tree and is opted into separately."
          },
          "timeRange": {
            "type": "object",
            "properties": {
              "on": {
                "type": "string",
                "minLength": 1,
                "maxLength": 256,
                "description": "Name of the timestamp index property to bucket. Must be this index's first property and name one of the system timestamps ($createdAt, $updatedAt or $transferredAt). A timeRange index may be unique only when range equals step (non-overlapping windows) and `on` is $createdAt."
              },
              "range": {
                "type": "integer",
                "minimum": 1,
                "description": "Length of each time range window, in seconds. Must be an exact multiple of `step`."
              },
              "step": {
                "type": "integer",
                "minimum": 1,
                "description": "Interval between successive range starts, in seconds. When `range` > `step` the ranges overlap and a document is indexed under `range / step` bucket-start values, bounded by a protocol-versioned cap (24 at protocol version 14)."
              },
              "phase": {
                "type": "integer",
                "minimum": 0,
                "description": "Grid alignment phase, in seconds. Range starts are `phase + k * step`; must be strictly less than `step` (a larger value would be a redundant spelling of `phase % step`) and strictly less than one year (31536000 — a phase further out could sit past current block time on a huge step, leaving valid timestamps before the grid's first bucket). A pure alignment offset — it moves where window boundaries fall (e.g. daily windows cut at 06:00 UTC instead of midnight) and never excludes any real timestamp. Defaults to 0."
              },
              "ttl": {
                "type": "integer",
                "minimum": 1,
                "description": "Time to live, in seconds: entries under this index exist for at most this long past their bucket's start, plus a bounded drainage lag — every write into the index continues draining the oldest expired bucket under a per-write operation budget, and expired windows are not queryable (a byStart selection past the horizon is rejected), so every queryable window is complete. Must be at least `range` (a window still able to receive consensus-timestamped writes can never expire) and at most a protocol-versioned cap (604800 — one week — at protocol version 14). Indexes bucketing one field with the same grid share its storage level and must declare the same ttl. Bytes written under a TTL'd index bill to processing at an ephemeral-bytes rate instead of to storage, carry no storage flags, and refund nothing on removal. Omitted means entries live forever. Available from protocol version 14."
              }
            },
            "required": ["on", "range", "step"],
            "additionalProperties": false,
            "description": "Buckets the first index property's timestamp into fixed-length, regularly-spaced (possibly overlapping) time ranges. The window parameters (`range`, `step`, `phase`) are declared in seconds, since a bucket is selected from block time and the target block interval is five seconds; the stored key is the range start as a u64 millisecond timestamp, so it stays directly comparable to the source timestamp it buckets. Enables trending/leaderboard queries within the newest/oldest active range. A system-timestamp source must be listed in the document type's required fields. Several indexes may bucket the same timestamp with different grids — each grid gets its own index subtree, keyed by the property name qualified with the grid parameters. Available from protocol version 14."
          },
          "terminal": {
            "type": "string",
            "minLength": 1,
            "maxLength": 256,
            "description": "Only on indexOnly document types: names the property whose value is this index entry's member key — the docId-analog terminal key under the index's storage marker, stored as an Item instead of a Reference because there is no primary-storage row. Either \"$ownerId\" (the default when omitted) or an identifier property carrying a refersTo declaration (identity, contract, token, or permanentDocument). Must not repeat one of the index's listed properties. Available from protocol version 14."
          },
          "preallocated": {
            "type": "boolean",
            "description": "Only on indexOnly document types whose index path is fully determined by a same-contract permanentDocument refersTo declaration: every index property must be either the referring property itself (its value is the referenced document's $id) or a key of that declaration's propertyAgreement (consensus-equal to a referenced-document property). When true, creating a referenced document also creates this index's dynamic trees for entries referencing it — paid by the referenced document's creator — and deleting the last entry keeps them, so every entry insert costs the same as the first. Available from protocol version 14."
          },
          "skipIfAbsent": {
            "type": "boolean",
            "description": "Only on indexOnly document types: when true, a document that omits this index's first property writes no entry into this index (and a delete recomputes the same skip), so the index holds only documents carrying the property. The first property is the skip trigger: it must be a top-level schema property NOT listed in `required` (making it the only way an indexOnly property may be optional), and every index involving an optional property must be skipIfAbsent with that property first. Every other property that is not a skip trigger must still appear in at least one non-skipIfAbsent index, and at least one $createdAt-free index must remain non-skipIfAbsent (the executed-transition proof index). An absent trigger is distinct from an empty value: absence skips the index, while any present value — empty included — indexes normally. Available from protocol version 14."
          }
        },
        "required": [
          "properties",
          "name"
        ],
        "dependentRequired": {
          "rangeCountable": ["countable"],
          "rangeSummable": ["summable"],
          "rangeAverageable": ["averageable"]
        },
        "$comment": "The ranked prerequisites are value-sensitive, unlike the range* rows above: `dependentRequired` fires on key *presence*, so listing them there would make an explicit `\"rankedCountable\": false` — a written-out opt-out, which the structural parser accepts as such — demand a `rangeCountable` the index does not need. The range* rows keep presence semantics because that is what they shipped with in v2 and changing them would move historical validation results.",
        "allOf": [
          {
            "if": {
              "properties": {
                "rankedCountable": {
                  "anyOf": [{ "const": true }, { "type": "object" }]
                }
              },
              "required": ["rankedCountable"]
            },
            "then": { "required": ["rangeCountable"] }
          },
          {
            "if": {
              "properties": { "rankedSummable": { "const": true } },
              "required": ["rankedSummable"]
            },
            "then": { "required": ["rangeSummable"] }
          },
          {
            "if": {
              "properties": { "rankedAverageable": { "const": true } },
              "required": ["rankedAverageable"]
            },
            "then": { "required": ["rangeAverageable"] }
          }
        ],
        "additionalProperties": false
      },
      "minItems": 1,
      "maxItems": 10
    },
    "signatureSecurityLevelRequirement": {
      "type": "integer",
      "enum": [
        1,
        2,
        3
      ],
      "description": "Public key security level. 1 - Critical, 2 - High, 3 - Medium. If none specified, High level is used"
    },
    "documentsKeepHistory": {
      "type": "boolean",
      "description": "True if the documents keep all their history, default is false"
    },
    "keepsTransferHistory": {
      "type": "boolean",
      "description": "True if transfers of these documents are recorded in the document history system contract, default is false"
    },
    "keepsPurchaseHistory": {
      "type": "boolean",
      "description": "True if purchases of these documents are recorded in the document history system contract, default is false"
    },
    "keepsPricingHistory": {
      "type": "boolean",
      "description": "True if price updates on these documents are recorded in the document history system contract, default is false"
    },
    "documentsMutable": {
      "type": "boolean",
      "description": "True if the documents are mutable, default is true"
    },
    "canBeDeleted": {
      "type": "boolean",
      "description": "True if the documents can be deleted, default is true"
    },
    "transferable": {
      "type": "integer",
      "enum": [
        0,
        1
      ],
      "description": "Transferable without a marketplace sell. 0 - Never, 1 - Always"
    },
    "tradeMode": {
      "type": "integer",
      "enum": [
        0,
        1
      ],
      "description": "Built in marketplace system. 0 - None, 1 - Direct purchase (The user can buy the item without the need for an approval)"
    },
    "creationRestrictionMode": {
      "type": "integer",
      "enum": [
        0,
        1,
        2
      ],
      "description": "Restrictions of document creation. 0 - No restrictions, 1 - Owner only, 2 - No creation (System Only)"
    },
    "requiresIdentityEncryptionBoundedKey": {
      "type": "integer",
      "enum": [
        0,
        1,
        2
      ],
      "description": "Key requirements. 0 - Unique Non Replaceable, 1 - Multiple, 2 - Multiple with reference to latest key."
    },
    "requiresIdentityDecryptionBoundedKey": {
      "type": "integer",
      "enum": [
        0,
        1,
        2
      ],
      "description": "Key requirements. 0 - Unique Non Replaceable, 1 - Multiple, 2 - Multiple with reference to latest key."
    },
    "documentsCountable": {
      "type": "boolean",
      "description": "When true, the primary key tree uses a CountTree enabling O(1) total document count queries."
    },
    "rangeCountable": {
      "type": "boolean",
      "description": "When true, the primary key tree uses a ProvableCountTree enabling range countable. Implies documentsCountable."
    },
    "documentsSummable": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64,
      "description": "Name of an integer document property aggregated into the primary-key SumTree (one sum per document type). Stores documents as `ItemWithSumItem` so the primary-key tree's root sum is the total of the named property across all docs of this type. Property must exist on the document type, be in `required`, and have an integer type. Composes with `documentsKeepHistory: true` — keep-history doctypes get a `SumTree` per-document subtree with a `ReferenceWithSumItem` on the `0`-key carrying the current version's value, so the doctype-level root aggregate reflects current versions only (historical versions don't double-count)."
    },
    "rangeSummable": {
      "type": "boolean",
      "description": "When true, the primary key tree uses a ProvableSumTree (or ProvableCountProvableSumTree paired with rangeCountable: true) enabling O(log n) range-sum queries over the primary axis. Requires `documentsSummable` to be set. Rarely useful — range-sum on the primary key with no where-clause filter is unusual; most callers want per-index `rangeSummable` instead. Set this only when you need a provable global range-sum tree."
    },
    "documentsAverageable": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64,
      "description": "Syntactic sugar: `documentsAverageable: \"<prop>\"` is shorthand for `documentsCountable: true` + `documentsSummable: \"<prop>\"`. Enables doctype-wide average queries (returns `(count, sum)` the client divides) without authors having to compose the count + sum flags. Same on-disk layout. If you set both `documentsAverageable` and `documentsSummable`, they must name the same property. Composes with `documentsKeepHistory: true` via the per-doc SumTree + ReferenceWithSumItem layout described under `documentsSummable`."
    },
    "rangeAverageable": {
      "type": "boolean",
      "description": "Syntactic sugar: `rangeAverageable: true` is shorthand for `rangeCountable: true` + `rangeSummable: true`. Requires `documentsAverageable` to be set. Same caveat as `rangeSummable` — rarely useful on the primary key; per-index `rangeAverageable` is what most callers want."
    },
    "indexOnly": {
      "type": "boolean",
      "description": "When true, documents of this type are never written to primary storage: the index entries are the rows, each terminating in an Item keyed by the index's `terminal` property instead of a Reference keyed by the document id. Only what is in the indexes exists and is recoverable. Requires: every property required and appearing in at least one index (except a `skipIfAbsent` index's optional first property), $ownerId in at least one index (as a property or terminal), documentsMutable: false, no transfers/trading/history/transient properties, and no doctype-level aggregate keywords (use the index-level count flags). Available from protocol version 14."
    },
    "tokenCost": {
      "type": "object",
      "properties": {
        "create": {
          "$ref": "#/$defs/documentActionTokenCost"
        },
        "replace": {
          "$ref": "#/$defs/documentActionTokenCost"
        },
        "delete": {
          "$ref": "#/$defs/documentActionTokenCost"
        },
        "transfer": {
          "$ref": "#/$defs/documentActionTokenCost"
        },
        "update_price": {
          "$ref": "#/$defs/documentActionTokenCost"
        },
        "purchase": {
          "$ref": "#/$defs/documentActionTokenCost"
        }
      },
      "additionalProperties": false
    },
    "properties": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "allOf": [
          {
            "$ref": "#/$defs/documentSchema"
          }
        ],
        "unevaluatedProperties": false
      },
      "properties": {
        "$id": true,
        "$ownerId": true,
        "$revision": true,
        "$createdAt": true,
        "$updatedAt": true,
        "$transferredAt": true,
        "$createdAtBlockHeight": true,
        "$updatedAtBlockHeight": true,
        "$transferredAtBlockHeight": true,
        "$createdAtCoreBlockHeight": true,
        "$updatedAtCoreBlockHeight": true,
        "$transferredAtCoreBlockHeight": true
      },
      "propertyNames": {
        "oneOf": [
          {
            "type": "string",
            "pattern": "^[a-zA-Z0-9-_]{1,64}$"
          },
          {
            "type": "string",
            "enum": [
              "$id",
              "$ownerId",
              "$revision",
              "$createdAt",
              "$updatedAt",
              "$transferredAt",
              "$createdAtBlockHeight",
              "$updatedAtBlockHeight",
              "$transferredAtBlockHeight",
              "$createdAtCoreBlockHeight",
              "$updatedAtCoreBlockHeight",
              "$transferredAtCoreBlockHeight"
            ]
          }
        ]
      },
      "minProperties": 1,
      "maxProperties": 100
    },
    "transient": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "additionalProperties": {
      "type": "boolean",
      "const": false
    },
    "required": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "uniqueItems": true
    },
    "$comment": {
      "type": "string"
    },
    "description": {
      "type": "string"
    },
    "minProperties": {
      "type": "integer",
      "minimum": 0
    },
    "maxProperties": {
      "type": "integer",
      "minimum": 0
    },
    "dependentRequired": {
      "type": "object",
      "additionalProperties": {
        "type": "array",
        "items": {
          "type": "string"
        },
        "uniqueItems": true
      }
    }
  },
  "required": [
    "$schema",
    "type",
    "properties",
    "additionalProperties"
  ],
  "dependentRequired": {
    "rangeSummable": ["documentsSummable"],
    "rangeAverageable": ["documentsAverageable"]
  },
  "additionalProperties": false
}
```

:::

:::{note}
`keywords` is a contract-level field (shown in the [data contract object table](#data-contract-object)), with a maximum of 50 enforced by Rust validation. It is not a document-type property.
:::

### Data Contract id

The data contract `id` is a hash of the `ownerId` and `identity_nonce` as shown in the [rs-dpp implementation](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/generate_data_contract.rs).

```rust
// From the Rust reference implementation (rs-dpp)
// generate_data_contract.rs
/// Generate data contract id based on owner id and identity nonce
pub fn generate_data_contract_id_v0(
    owner_id: impl AsRef<[u8]>,
    identity_nonce: IdentityNonce,
) -> Identifier {
    let mut b: Vec<u8> = vec![];
    let _ = b.write(owner_id.as_ref());
    let _ = b.write(identity_nonce.to_be_bytes().as_slice());
    Identifier::from(hash_double(b))
}
```

### Data Contract version

The data contract `version` is an integer representing the current version of the contract. This  
property must be incremented if the contract is updated.

### Data Contract documents

See the [data contract documents](./data-contract-document.md) page for details, including the [aggregate query flags](./data-contract-document.md#aggregate-query-flags) that opt document types into count/sum/average queries.

### Data Contract config

The data contract config defines configuration options for data contracts, controlling their lifecycle, mutability, history management, and encryption requirements. Data contracts support three categories of configuration options to provide flexibility in contract design. It is only necessary to include them in a data contract when non-default values are used. The default values for these configuration options are defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/config/fields.rs).

| Contract option                         | Default | Description |
|-----------------------------------------|---------|-------------|
| `canBeDeleted`                          | `false` | Determines if the data contract itself can be deleted. Note: documents have a separate `canBeDeleted` option (default: `true`) defined per document type in [data-contract-document.md](./data-contract-document.md). |
| `readonly`                              | `false` | Determines if the contract is read-only. Read-only contracts cannot be updated. |
| `keepsHistory`                          | `false` | Determines if changes to the contract itself are tracked, maintaining a historical record of contract modifications. |
| `sizedIntegerTypes`                     | `true`  | Enables sized integer types for the contract. |

| Document default option                 | Default | Description |
|-----------------------------------------|---------|-------------|
| `documentsKeepHistory`<br>`ContractDefault`   | `false` | Sets the default behavior for tracking historical changes of documents within the contract |
| `documentsMutable`<br>`ContractDefault`       | `true`  | Sets the default mutability of documents within the contract, indicating if documents can be edited. |
| `documentsCanBeDeleted`<br>`ContractDefault`  | `true`  | Sets the default behavior for whether documents within the contract can be deleted |

#### Key Management

Dash Platform provides an advanced level of security and control by enabling the isolation of encryption and decryption keys on a contract-specific or document-specific basis. This granular approach to key management enables developers to configure their applications for whatever level of security they require.

| Security option                         | Description |
|-----------------------------------------|-------------|
| `requiresIdentity`<br>`EncryptionBoundedKey`  | Indicates the contract requires a contract-specific identity encryption key. Key options:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest  |
| `requiresIdentity`<br>`DecryptionBoundedKey`  | Indicates the contract requires a contract-specific identity decryption key. Key options:<br>`0` - Unique non-replaceable<br>`1` - Multiple<br>`2` - Multiple with reference to latest |

:::{tip}
These security options can be set at the root level of the data contract or the root level of specific documents within the contract depending on requirements.
:::

**Example**

The following example (from the [DashPay contract's `contactRequest` document](https://github.com/dashpay/platform/blob/v4.2-dev/packages/dashpay-contract/schema/v1/dashpay.schema.json#L142-L146)) demonstrates the use of both key-related options at the document level:

``` json
"contactRequest": {
  "requiresIdentityEncryptionBoundedKey": 2,
  "requiresIdentityDecryptionBoundedKey": 2,
}
```

See the data contract [config implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/config/v1/mod.rs#L23-L50) for more details, and the [config update rules](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/config/methods/validate_update/v1/mod.rs) for what may change after registration.

### Data Contract groups

Groups can be used to distribute contract configuration and update authorization across multiple identities. They are particularly useful for contracts where multiple parties are involved in controlling or managing contract-specific features. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action.

#### Group Structure

| Field | Type | Description |
|-------|------|-------------|
| `members` | Map\<Identifier, MemberPower\> | Map of identity IDs to their voting power |
| `requiredPower` | GroupRequiredPower | Threshold power needed to authorize actions |

#### Group Constants

| Constant | Value | Description |
|----------|-------|-------------|
| Minimum group size | [2](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/group/v0/mod.rs#L111-L114) | Minimum members per group |
| `max_contract_group_size` | [256](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-platform-version/src/version/system_limits/v4.rs#L55) | Maximum members per group |
| Maximum member power | 65,535 (u32; cap enforced at u16::MAX) | Maximum voting power per member. Each member's power must also not exceed the group's [`requiredPower`](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/group/v0/mod.rs#L133-L138) value. |
| Maximum required power | 65,535 (u32; cap enforced at u16::MAX) | Maximum threshold power |

Groups are also checked against these rules at contract registration:

- No member may have a power of `0`.
- `requiredPower` must be greater than `0`.
- The powers of all members must add up to at least `requiredPower`.
- If any members have power below `requiredPower` and therefore cannot act alone,
  their combined power must reach `requiredPower`. This prevents a group where one
  member can act alone but all remaining members together cannot reach the threshold.

#### Group Action Info

When submitting a group-authorized action, the transition includes:

| Field | Type | Description |
|-------|------|-------------|
| `$groupContractPosition` | u16 | Position of the group in the contract |
| `$groupActionId` | Identifier (32 bytes) | The action identifier |
| `$groupActionIsProposer` | bool | Whether the signer is the action proposer |

#### Use Cases

- **Multi-party token control**: Require multiple administrators to approve minting or burning
- **Governance**: Implement weighted voting for configuration changes
- **Security**: Distribute control to prevent single points of failure

**Example: 2-of-3 Multisig**

```json
{
  "groups": {
    "0": {
      "members": {
        "<identity_id_1>": 1,
        "<identity_id_2>": 1,
        "<identity_id_3>": 1
      },
      "requiredPower": 2
    }
  }
}
```

In this example, any two of the three members can authorize an action.

See the [groups implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/data_contract/group/v0/mod.rs#L40-L43) for more details.

### Data Contract tokens

:::{versionadded} 2.0.0
:::

- Tokens provide token-related functionality within the contract, such as base supply, maximum supply, and manual minting/burning rules.  
- Token configurations include change control rules, ensuring proper governance for modifying supply limits and token-related settings.
- This enables contracts to define and manage tokens while ensuring compliance with governance rules (e.g., who can mint or burn tokens).

### Document history system contract

:::{versionadded} 4.1.0
:::

The document history contract is a [system data contract](https://github.com/dashpay/platform/blob/v4.2-dev/packages/data-contracts/src/lib.rs) that records document transfers, purchases and price updates for document types that opt in via the [document history flags](./data-contract-document.md#document-configuration).

| Property | Value |
| - | - |
| Contract ID | `6voHRaoiPcfmMhbqCA9dixH98xcgPQ9UEcuaXjpVu3LD` |
| Owner ID | `11111111111111111111111111111111` |

Its documents are written by the protocol while applying the corresponding document transition; they cannot be created directly (`creationRestrictionMode` 2). All three document types are immutable (`documentsMutable` false) and cannot be deleted (`canBeDeleted` false).

| Document type | Recorded properties |
| - | - |
| `transfer` | `dataContractId`, `documentTypeName`, `documentId`, `toIdentityId` |
| `purchase` | `dataContractId`, `documentTypeName`, `documentId`, `sellerId`, `price` |
| `priceUpdate` | `dataContractId`, `documentTypeName`, `documentId`, `price` |

See the [contract schema in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/document-history-contract/schema/v1/document-history-contract-documents.json).

## Data Contract State Transition Details

There are two data contract-related state transitions: [data contract create](#data-contract-create) and [data contract update](#data-contract-update). Details are provided in this section.

### Data Contract Create

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract create state transition consisting of:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $formatVersion  | unsigned integer | 16 bits | The state transition format version (currently `0`) |
| type            | unsigned integer | 8 bits  | State transition type (`0` for data contract create)  |
| dataContract    | [data contract object](#data-contract-object) | Varies | Object containing the data contract details |
| identityNonce   | unsigned integer | 64 bits | Identity nonce for this transition to prevent replay attacks |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |
| signature            | array of bytes | 65 bytes | Signature of state transition data |

See the [data contract create implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_create_transition/v0/mod.rs#L36-L44) for more details.

### Data Contract Update

Existing data contracts can be updated in certain backwards-compatible ways. The following aspects
of a data contract can be updated:

- Adding a new document
- Adding a new property to an existing document type. The property may be optional, or required if it carries a `requiredSince` value equal to the contract version the update creates. Existing properties and system (`$`-prefixed) fields cannot become required, and required fields cannot be removed. Document types added by the update must set `requiredSince` to that same version on any required property, and on contract creation `requiredSince` may only be `1`.
- Reordering the `indices` array. Index definitions are immutable once the document type is registered: an index cannot be added, removed, or changed (including its `unique`, `properties`, aggregate, or ranked flags).
- Adding a new token at a previously unused position
- Adding a new group at a previously unused position
- Changing the `keywords` array
- Changing the `description`
- Enabling `sizedIntegerTypes`. This is a one-way change; it cannot be disabled once enabled
- Changing `canBeDeleted` from `true` to `false` on a document type whose `documentsKeepHistory` is `true`. This is the only document type config change allowed after registration

Existing tokens and groups cannot be removed or modified once the contract is registered.

Data contracts are updated on the platform by submitting the modified [data contract  
object](#data-contract-object) in a data contract update state transition consisting of:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $formatVersion  | unsigned integer | 16 bits | The state transition format version (currently `0`) |
| type            | unsigned integer | 8 bits  | State transition type (`4` for data contract update)  |
| dataContract    | [data contract object](#data-contract-object) | Varies | Object containing the updated data contract details<br>**Note:** the data contract's [`version` property](#data-contract-version) must be incremented with each update |
| identityContractNonce | unsigned integer | 64 bits | Identity contract nonce for replay protection |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |
| signature            | array of bytes | 65 bytes | Signature of state transition data |

See the [data contract update implementation in rs-dpp](https://github.com/dashpay/platform/blob/v4.2-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_update_transition/v0/mod.rs#L31-L43) for more details.

### Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract owner's identity. See the [state transition signing](./state-transition.md#state-transition-signing) page for full signing details.

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

data-contract-document
data-contract-token
```
