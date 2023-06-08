# Retrieve an identity

In this tutorial we will retrieve the identity created in the [Register an Identity tutorial](tutorial-register-an-identity).

## Prerequisites
- [General prerequisites](tutorials-introduction#prerequisites) (Node.js / Dash SDK installed)
- A Dash Platform Identity: [Tutorial: Register an Identity](tutorial-register-an-identity) 

# Code

```javascript
const Dash = require('dash');

const client = new Dash.Client({ network: 'testnet' });

const retrieveIdentity = async () => {
  return client.platform.identities.get('an identity ID goes here');
};

retrieveIdentity()
  .then((d) => console.log('Identity retrieved:\n', d.toJSON()))
  .catch((e) => console.error('Something went wrong:\n', e))
  .finally(() => client.disconnect());
``` 

# Example Identity

The following example response shows a retrieved identity:

```json
{
   "protocolVersion":0,
   "id":"6Jz8pFZFhssKSTacgQmZP14zGZNnFYZFKSbx4WVAJFy3",
   "publicKeys":[
      {
         "id":0,
         "type":0,
         "data":"A4zZl0EaRBB6IlDbyR80YUM2l02qqNUCoIizkQxubtxi"
      }
   ],
   "balance":10997588,
   "revision":0
}
``` 

# What's Happening

After we initialize the Client, we request an identity. The `platform.identities.get` method takes a single argument: an identity ID. After the identity is retrieved, it is displayed on the console.