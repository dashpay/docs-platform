In order to successfully develop a Dash Platform Application, developers will need to know how to communicate their data infrastructure to the Dash network, structure their application data, interact with usernames, and pay for various data operations.

# Operation Costs

In any decentralized network, nodes are compensated for the activities they undertake to maintain the network. Consequently, any action taken by an application to store, retrieve, or manipulate data involves a cost that will be paid to the masternodes. Sometimes this cost will be the same as a traditional currency exchange on the Dash network ( < $0.01 USD), and sometimes this cost will be slightly higher as a result of the quantity of data being stored or retrieved.

In order to pay for these various operations, Dash must be spent by either the application administrator or user. Obviously, this represents a paradigm shift for how most consumers interact with an application. Therefore, managing the payment of various data operations is a matter of choice for the developer, by choosing to sponsor costs on behalf of a user or by passing the cost of the data operation onto the user.

# Data Contracts

A data contract is an agreement between your application and the Dash network as to how your data should be stored and validated by the Dash network. The concept is analogous to creating a schema for a document-oriented database. Data contracts are JSON objects, and an example contract for the [Dash Platform Naming Service (DPNS)](https://github.com/dashpay/platform/blob/master/packages/dpns-contract/schema/v1/dpns-contract-documents.json) is included below:

```json
{
    "domain": {
        "indices": [
            {
                "properties": [
                    { "$userId": "asc" },
                    { "nameHash": "asc" }
                ],
                "unique": true
            }
        ],
        "properties": {
            "nameHash": {
                "type": "string",
                "minLength": 1
            },
            "label": {
                "type": "string",
                "pattern": "^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9])$"
            },
            "normalizedLabel": {
                "type": "string",
                "pattern": "^((?!-)[a-z0-9-]{0,62}[a-z0-9])$"
            },
            "normalizedParentDomainName": {
                "type": "string",
                "minLength": 1
            },
            "preorderSalt": {
                "type": "string",
                "minLength": 1
            },
            "records": {
                "type": "object",
                "properties": {
                    "dashIdentity": {
                        "type": "string",
                        "minLength": 64,
                        "maxLength": 64
                    }
                },
                "minProperties": 1,
                "additionalProperties": false
            }
       },
       "required": [
           "nameHash",
           "label",
           "normalizedLabel",
           "normalizedParentDomainName",
           "preorderSalt",
           "records"
        ],
        "additionalProperties": false
    },
    "preorder": {
        "indices": [
            {
                "properties": [
                    { "$userId": "asc" },
                    { "saltedDomainHash": "asc" }
                ],
                "unique": true
            }
        ],
        "properties": {
           "saltedDomainHash": {
                "type": "string",
                "minLength": 1
           }
        },
        "required": [
            "saltedDomainHash"
        ],
        "additionalProperties": false
    }
}
```

As your application evolves, changes to your data contract might be required. Consequently, data contracts can be versioned in order to prevent breaking changes in your application.

# State Transitions

At any given point in time, your application has a specific state regarding the type and content of its data. Whenever you create, update, or delete data, your application undergoes a state transition. Data is stored on Dash Platform when an application submits a state transition to the Dash network. This state transition is a JSON-formatted object that corresponds to the structure defined in the application’s data contract.

Based on the validation rules described in the data contract, Dash Platform will validate and either accept or reject a state transition based on the previously defined criteria.

# Identities and Names

A major feature of Dash Platform is the ability to associate users with human-readable usernames, which has been notoriously difficult to implement in decentralized systems. In order to work with usernames in a Dash Platform application, it is important to understand the difference between identities and usernames.

Identities are unique identifiers that are stored on the Dash blockchain. It is important to understand that identities represent the core identifier for an individual, business, or application. In that regard, identities in the Dash network are analogous to DNA. Two individuals might share the same name, but their core identities will still be different.

Usernames are human-readable names that are stored in Dash Platform Name Service, a Dash Platform application. The application takes an identity stored on the Dash blockchain and resolves that identifier to a username, similar to how DNS works for a website URL and its corresponding IP address. Usernames are an attribute of an identity, which is why they are architecturally separate from identity and stored in a Dash Platform application. This separation allows for a decentralized identity ecosystem to develop around the Dash network.
