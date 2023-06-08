# Retrieve an account's identities

In this tutorial we will retrieve the list of identities associated with a specified mnemonic-based account. Since multiple identities may be created using the same mnemonic, it is helpful to have a way to quickly retrieve all these identities (e.g. if importing the mnemonic into a new device).

## Prerequisites
- [General prerequisites](tutorials-introduction#prerequisites) (Node.js / Dash SDK installed)
- A wallet mnemonic
- A Dash Platform Identity: [Tutorial: Register an Identity](tutorial-register-an-identity) 

# Code

```javascript
const Dash = require('dash');

const client = new Dash.Client({
  network: 'testnet',
  wallet: {
    mnemonic: 'a Dash wallet mnemonic with testnet funds goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
});

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
  '6Jz8pFZFhssKSTacgQmZP14zGZNnFYZFKSbx4WVAJFy3',
  '8XoJHG96Vfm3eGh1A7HiDpMb1Jw2B9opRJe8Z38urapt',
  'CEPMcuBgAWeaCXiP2gJJaStANRHW6b158UPvL1C8zw2W',
  'GTGZrkPC72tWeBaqopSCKgiBkVVQR3s3yBsVeMyUrmiY'
]
``` 

# What's Happening

After we initialize the Client and getting the account, we call `account.identities.getIdentityIds()` to retrieve a list of all identities created with the wallet mnemonic. The list of identities is output to the console.

> 📘 Wallet Operations
>
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
>
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.