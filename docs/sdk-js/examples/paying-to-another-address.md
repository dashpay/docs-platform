# Paying to another address

In order to pay, you need to have an [existing balance](https://dashplatform.readme.io/docs/dash-sdk-examples-receive-money-and-check-balance).  
The below code will allow you to pay to a single address a specific amount of satoshis.

```js
const Dash = require('dash');

const mnemonic = ''; // your mnemonic here.
const client = new Dash.Client({
  wallet: {
    mnemonic,
  },
});

async function payToRecipient(account) {
  const transaction = account.createTransaction({
    recipient: 'yNPbcFfabtNmmxKdGwhHomdYfVs6gikbPf',
    satoshis: 10000,
  });
  const transactionId = await account.broadcastTransaction(transaction);
}

client.wallet.getAccount().then(payToRecipient);

```

See more on create [transaction options here](https://dashpay.github.io/platform/Wallet-library/account/createTransaction/).