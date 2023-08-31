# Update

**Usage**: `client.platform.contracts.update(contract, identity)`  
**Description**: This method will sign and broadcast an updated valid contract.

Parameters:

| parameters   | type     | required | Description                                                                                                   |
| ------------ | -------- | -------- | ------------------------------------------------------------------------------------------------------------- |
| **contract** | Contract | yes      | A valid [created contract](../contracts/create.md)                     |
| **identity** | Identity | yes      | A valid [registered `application` identity](../identities/register.md) |

Returns: DataContractUpdateTransition.