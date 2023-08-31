# Update

**Usage**: `client.platform.contracts.update(contract, identity)`  
**Description**: This method will sign and broadcast an updated valid contract.

Parameters:

| parameters   | type     | required | Description                                                                                                   |
| ------------ | -------- | -------- | ------------------------------------------------------------------------------------------------------------- |
| **contract** | Contract | yes      | A valid [created contract](https://dashplatform.readme.io/docs/dash-sdk-contracts-create)                     |
| **identity** | Identity | yes      | A valid [registered `application` identity](https://dashplatform.readme.io/docs/dash-sdk-identities-register) |

Returns: DataContractUpdateTransition.