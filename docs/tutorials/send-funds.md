# Send funds

Once you have a wallet and some funds ([tutorial](tutorial-create-and-fund-a-wallet)), another common task is sending Dash to an address. (Sending Dash to a contact or a DPNS identity requires the Dashpay app, which has not been registered yet.)

# Code

> 📘 Wallet Operations
>
> The JavaScript SDK does not cache wallet information. It re-syncs the entire Core chain for some wallet operations (e.g. `client.getWalletAccount()`) which can result in wait times of  5+ minutes. 
>
> A future release will add caching so that access is much faster after the initial sync. For now, the `skipSynchronizationBeforeHeight` option can be used to sync the wallet starting at a certain block height.

```javascript
const Dash = require('dash');

const clientOpts = {
  network: 'testnet',
  wallet: {
    mnemonic: 'your wallet mnemonic goes here',
    unsafeOptions: {
      skipSynchronizationBeforeHeight: 650000, // only sync from early-2022
    },
  },
};
const client = new Dash.Client(clientOpts);

const sendFunds = async () => {
  const account = await client.getWalletAccount();

  const transaction = account.createTransaction({
    recipient: 'yP8A3cbdxRtLRduy5mXDsBnJtMzHWs6ZXr', // Testnet2 faucet
    satoshis: 100000000, // 1 Dash
  });
  return account.broadcastTransaction(transaction);
};

sendFunds()
  .then((d) => console.log('Transaction broadcast!\nTransaction ID:', d))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());

// Handle wallet async errors
client.on('error', (error, context) => {
  console.error(`Client error: ${error.name}`);
  console.error(context);
});
``` 

# What's Happening

After initializing the Client, we build a new transaction with `account.createTransaction`. It requires a recipient and an amount in satoshis (often called "duffs" in Dash). 100 million satoshis equals one Dash. We pass the transaction to `account.broadcastTransaction` and wait for it to return. Then we output the result, which is a transaction ID. After that we disconnect from the Client so node can exit.