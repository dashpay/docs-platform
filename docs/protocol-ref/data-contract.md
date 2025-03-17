```{eval-rst}
.. _protocol-ref-data-contract:
```

# Data Contract

## Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts. All data contracts must define one or more [documents](#data-contract-documents) or [tokens](#data-contract-tokens), whereas definitions are optional and may not be used for simple contracts.

### General Constraints

There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts.

#### Data Size

| Parameter | Size |
| - | - |
| Maximum serialized data contract size | [16384 bytes (16 KB)](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L4) |
| Maximum field value size | [5120 bytes (5 KB)](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L5) |
| Maximum state transition size | [20480 bytes (20 KB)](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-platform-version/src/version/system_limits/v1.rs#L6) |

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

The data contract object consists of the following fields as defined in the Rust reference client ([rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/v1/data_contract.rs#L67-L105)):

| Property        | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version | unsigned integer      | 32 bits | The platform protocol version ([currently `8`](https://github.com/dashpay/platform/blob/v1.8.0/packages/rs-platform-version/src/version/mod.rs#L26)) |
| [$schema](#data-contract-schema) | string         | Varies      | A valid URL |
| [id](#data-contract-id)         | array of bytes | 32 bytes      | Contract ID generated from `ownerId` and entropy (content media type: `application/x.dash.dpp.identifier`) |
| [version](#data-contract-version) | unsigned integer        | Yes      | The data contract version |
| ownerId         | array of bytes | 32 bytes      | [Identity](../protocol-ref/identity.md) that registered the data contract defining the document (content media type: `application/x.dash.dpp.identifier`) |
| [documents](./data-contract-document.md) | object         | Varies    | (Optional \*) Document definitions (see [Contract Documents](./data-contract-document.md) for details) |
| [config](#data-contract-config) | DataContractConfig | Varies | (Optional) Internal configuration for the contract |
| $defs           | object         | Varies       | (Optional) Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with \<= 100 valid properties) |
| [groups](#data-contract-groups) | Group | Varies | (Optional) Groups that allow for specific multiparty actions on the contract. |
| [tokens](./data-contract-token.md) | object         | Varies    | (Optional \*) Token definitions (see [Contract Tokens](./data-contract-token.md) for details) |

\* The data contract object must define documents or tokens. It may include both documents and tokens.

### Data Contract schema

The full schema is [defined is rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/document_type/schema/enrich_with_base_schema/v0/mod.rs#L6-L7), hosted on [GitHub](https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json), and can be viewed by expanding this dropdown:

::: {dropdown} Full schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json",
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
                  "required": ["position"]
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
    }
  },
  "properties": {
    "type": {
      "type": "string",
      "const": "object"
    },
    "$schema": {
      "type": "string",
      "const": "https://github.com/dashpay/platform/blob/master/packages/rs-dpp/schema/meta_schemas/document/v0/document-meta.json"
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
            "required": ["resolution"],
            "additionalProperties": false
          }
        },
        "required": [
          "properties",
          "name"
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
    }
  },
  "required": [
    "$schema",
    "type",
    "properties",
    "additionalProperties"
  ]
}
```

:::

### Data Contract id

The data contract `id` is a hash of the `ownerId` and entropy as shown [here](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/generate_data_contract.rs).

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

See the [data contract documents](./data-contract-document.md) page for details.

### Data Contract config

The data contract config defines configuration options for data contracts, controlling their lifecycle, mutability, history management, and encryption requirements. Data contracts support three categories of configuration options to provide flexibility in contract design. It is only necessary to include them in a data contract when non-default values are used. The default values for these configuration options are defined in the [Rust DPP implementation](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/config/fields.rs).

| Contract option                         | Default | Description |
|-----------------------------------------|---------|-------------|
| `canBeDeleted`                          | `false` | Determines if the contract can be deleted |
| `readonly`                              | `false` | Determines if the contract is read-only. Read-only contracts cannot be updated. |
| `keepsHistory`                          | `false` | Determines if changes to the contract itself are tracked, maintaining a historical record of contract modifications. |

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

The following example (from the [DashPay contract's `contactRequest` document](https://github.com/dashpay/platform/blob/master/packages/dashpay-contract/schema/v1/dashpay.schema.json#L142-L146)) demonstrates the use of both key-related options at the document level:

``` json
"contactRequest": {
  "requiresIdentityEncryptionBoundedKey": 2,
  "requiresIdentityDecryptionBoundedKey": 2,
}
```

See the data contract [config implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/config/v0/mod.rs#L17-L42) for more details.

### Data Contract groups

Groups can be used to distribute contract configuration and update authorization across multiple identities. They are particularly useful for contracts where multiple parties are involved in controlling or managing contract-specific features. Each group defines a set of member identities, the voting power of each member, and the required power threshold to authorize an action.

- Each member is assigned an integer power.
- The group itself has a required power threshold to authorize an action.
- Groups can have up to 256 members, each with a maximum power of 2^16 - 1.
- Changes to a token (e.g., mint, burn, freeze) can be configured so they require group authorization.
  - Example: "2-of-3 multisig” among three admins, each with certain voting power.

See the [groups implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/data_contract/group/v0/mod.rs#L31-L34) for more details.

### Data Contract tokens

- Tokens provide token-related functionality within the contract, such as base supply, maximum supply, and manual minting/burning rules.  
- Token configurations include change control rules, ensuring proper governance for modifying supply limits and token-related settings.
- This enables contracts to define and manage tokens while ensuring compliance with governance rules (e.g., who can mint or burn tokens).

## Data Contract State Transition Details

There are two data contract-related state transitions: [data contract create](#data-contract-create) and [data contract update](#data-contract-update). Details are provided in this section.

### Data Contract Create

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract create state transition consisting of:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version        | unsigned integer | 32 bits | The platform protocol version (currently `1`) |
| type            | unsigned integer | 8 bits  | State transition type (`0` for data contract create)  |
| dataContract    | [data contract object](#data-contract-object) | Varies | Object containing the data contract details |
| identityNonce   | unsigned integer     | 64 bits | Identity nonce for this transition to prevent replay attacks |
| entropy         | array of bytes | 32 bytes | Entropy used to generate the data contract ID. Generated as [shown here](../protocol-ref/state-transition.md#entropy-generation). |
| userFeeIncrease | unsigned integer | 16 bits | Extra fee to prioritize processing if the mempool is full. Typically set to zero. |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |
| signature            | array of bytes | 65 bytes | Signature of state transition data |

See the [data contract create implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_create_transition/v0/mod.rs#L37-L45) for more details.

### Data Contract Update

Existing data contracts can be updated in certain backwards-compatible ways. The following aspects
of a data contract can be updated:

- Adding a new document
- Adding a new optional property to an existing document
- Adding non-unique indices for properties added in the update

Data contracts are updated on the platform by submitting the modified [data contract  
object](#data-contract-object) in a data contract update state transition consisting of:

| Field           | Type           | Size | Description |
| --------------- | -------------- | ---- | ----------- |
| $version        | unsigned integer | 32 bits | The platform protocol version (currently `1`) |
| type            | unsigned integer | 8 bits  | State transition type (`4` for data contract update)  |
| dataContract    | [data contract object](#data-contract-object) | Varies | Object containing the updated data contract details<br>**Note:** the data contract's [`version` property](#data-contract-version) must be incremented with each update |
| signaturePublicKeyId | unsigned integer | 32 bits | The `id` of the [identity public key](../protocol-ref/identity.md#identity-publickeys) that signed the state transition (`=> 0`) |
| signature            | array of bytes | 65 bytes | Signature of state transition data |

See the [data contract update implementation in rs-dpp](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/state_transition/state_transitions/contract/data_contract_update_transition/v0/mod.rs#L33-L45) for more details.

### Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract owner's identity. See the [state transition signing](./state-transition.md#state-transition-signing) page for full signing details.

```{toctree}
:maxdepth: 2
:titlesonly:
:hidden:

data-contract-document
data-contract-token
```
