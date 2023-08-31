# Fetching an identity from its name

Assuming you have created an identity and attached a name to it (see how to [register an identity](../../tutorials/identities-and-names/register-an-identity.md) and how to [attach it to a name](../../tutorials/identities-and-names/register-a-name-for-an-identity.md)), you will then be able to directly recover an identity from its names. See below: 

```js
const client = new Dash.Client({
  wallet: {
    mnemonic: '', // Your app mnemonic, which holds the identity
  },
});

// This is the name previously registered in DPNS.
const identityName = 'alice';

const nameDocument = await client.platform.names.resolve(`${identityName}.dash`);
const identity = await client.platform.identities.get(nameDocument.ownerId);
```