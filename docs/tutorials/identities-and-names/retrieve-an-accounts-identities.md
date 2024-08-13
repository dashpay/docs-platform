```{eval-rst}
.. tutorials-retrieve-accounts-identities:
```

# Retrieve an account's identities

In this tutorial we will retrieve the list of identities associated with a specified mnemonic-based account. Since multiple identities may be created using the same mnemonic, it is helpful to have a way to quickly retrieve all these identities (e.g. if importing the mnemonic into a new device).

## Prerequisites

- [General prerequisites](../../tutorials/introduction.md#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic
- A configured client: [Setup SDK Client](../setup-sdk-client.md)
- A Dash Platform Identity: [Tutorial: Register an Identity](../../tutorials/identities-and-names/register-an-identity.md)

## Code

```javascript
const setupDashClient = require('../setupDashClient');

const client = setupDashClient();

const retrieveIdentityIds = async () => {
  const account = await client.getWalletAccount();
  return account.identities.getIdentityIds();
};

retrieveIdentityIds()
  .then((d) => console.log('Mnemonic identities:\n', d))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
```

Example Response

```json
[
  "6Jz8pFZFhssKSTacgQmZP14zGZNnFYZFKSbx4WVAJFy3",
  "8XoJHG96Vfm3eGh1A7HiDpMb1Jw2B9opRJe8Z38urapt",
  "CEPMcuBgAWeaCXiP2gJJaStANRHW6b158UPvL1C8zw2W",
  "GTGZrkPC72tWeBaqopSCKgiBkVVQR3s3yBsVeMyUrmiY"
]
```

## What's Happening

After we initialize the Client and getting the account, we call `account.identities.getIdentityIds()` to retrieve a list of all identities created with the wallet mnemonic. The list of identities is output to the console.

:::{note}
Since the SDK does not cache wallet information, lengthy re-syncs (5+ minutes) may be required for some Core chain wallet operations. See [Wallet Operations](../setup-sdk-client.md#wallet-operations) for options.
:::
