```{eval-rst}
.. _reference-platform-proofs:
```

# Platform Proofs

>❗️ Platform v0.22.0
>
> Note: As part of the transition from MongoDB to Dash's [GroveDB](https://github.com/dashevo/grovedb), proofs will be not be available for at least the initial version of Platform v0.22.

Since data verification is a critical aspect of Dash Platform, all [Platform endpoints](../reference/dapi-endpoints-platform-endpoints.md) can provide an optional proof that the response is correct. Set the optional `prove` parameter (`"prove": true`) in the request to receive a proof that contains the requested data.

## Proof Structure

Each proof consists of four parts:

| Field | Type | Description |
|-|-|-|
| rootTreeProof | Bytes (base64) | Merkle path to the `storeTreeProof` |
| [storeTreeProof](#store-tree-proof) | Object | Object containing data and proofs from one or more store trees. Currently there are 5 types of trees: identities, public key hash to identity IDs, data contracts, documents, and state transitions. The merk tree proofs contain the store root hash, the merkle path, and the requested data |
| signatureLlmqHash | Bytes (base64) | Hash of the LLMQ that created the `signature` |
| signature | Bytes (base64) | Signature of the merkle root of the `rootTreeProof` |

```json
{
  "proof": {
    "rootTreeProof": "v+99FytmaUPDP65HthQllBL1JDXt2Zu/kzFEQRw66rT6QF8LYwKmAP6fEaXLaSVPe/OHfTDEG2+KoLxjyirQIDmDy4lNl4yhJE5stQZGO2G/74H4MxN/a/luSWkqE1vF",
    "storeTreeProofs": {
      "identitiesProof": "AeFWk/kp1HXlJMzA4Wwov+NifjrocHebDU8863BDtp4aAlHeCG7lcVi52OSo+U5LlykSjARXJ5Rv6hE+mui+RnUFEAGJ24nuRAkAZMjcRp1sbzLPwYxxagTD12YTLksNN+y1cAKxpoxQdHpC/RQN7cq7fE/z6+0ccpoVQbobRPGtfCSj4hABjDZM5byc2NbfTNb7NGWDKm0bAoZjaAHx+C7Gn2cKmfsCIyWhRVW4QDdnoxTDvJuHCKJeK8dWzsrfVuUYTejcw6MQAX4HE7Y1WuXPPAG6uU9vewbilQnhjLzSTYNVLsdkxmLfAmwhTWaLg5A+tuxnzvdPhNU+bmbyMHr4PIL8Z+ScbyikEAFtCRA34Yl9tuEzqAF1EdiY0U9/jNoyEpU2vkPLO7xUYAJEmc3z/snpNWPXQdMrrAAHqWNhwddPRSMrF0epC75qThADIHwTzudaE/98V8XvldeYDIpe0yZOW3s6iK0jdqsoOJz3AIABAAAApGJpZFggfBPO51oT/3xXxe+V15gMil7TJk5bezqIrSN2qyg4nPdnYmFsYW5jZRoAp8O4aHJldmlzaW9uAGpwdWJsaWNLZXlzgaNiaWQAZGRhdGFYIQOF51gOnYk5T+0EdR4DSKUkDo5TmEDMoMxdxOy7FnqKjmR0eXBlABEREQL0H2yuZyiMzKzHmrXCwp/W7DuDkZYlEx7JE5xlYGhJxhABJt9KcGPXHnE7hzz3aQ9PpYDhvILZCDUOu5BBwV66RPYRERECyX/3Cih/TZdB9cVOX8Xmo2UEPNvt9iOufQ4oCmoytwsQAU14wPdQ7t7FfsfXx9fGnwbZk8h1uxoWd0MroZRO0YVXEQ==",
      "publicKeyHashesToIdentityIdsProof": "Afe33zbtlgXiPzJ1+zSjjVttIBmiKHy1iEc7uOKqxVUGAjs/C8gAlTwbVhnRBqbhGFkz0Kg/0Cr8mAV41WXxocBpEAGVsw8werVp7Cka+OSMj3GgkX2Da0FMMGGIJx4aZxPwPhE="
    },
    "signatureLlmqHash": "AAACBMSv9TakRGNdP+yvxw/+VCgIbALhn314jLOpgcY=",
    "signature": "Fhl8Md9MDlB0Tlekgjoj+Qe5PdKeUDyL6svVmcP9ttRu1UB7oeAGaSMAyqJI+k/HA/jAfPFb9+q9gepdZDhj8zHrl5BRSaAiBPEtM6CTQ+eCWUvqOlDENVQfubrXLLdk"
  },
  "metadata": {
    "height": "7986",
    "coreChainLockedHeight": 57585
  }
}
```

### Root tree proof

> 📘
>
> Details regarding the root tree proofs and their verification will be provided in a future update to this page.

### Store tree proof

Store tree proofs are based on a modified version of [Merk](https://github.com/nomic-io/merk/). Some details from the Merk documentation are included below. Additional details are available in the [Algorithms document](https://github.com/nomic-io/merk/blob/develop/docs/algorithms.md) on the Merk repository.

Dash Platform 0.21.0 introduced updates to support returning multiple store tree proofs. Each response that requests proofs will receive one or more of the following:

- `identitiesProof`
- `publicKeyHashesToIdentityIdsProof`
- `dataContractsProof`
- `documentsProof`
- `stateTransitionProof`

> 🚧
>
> Dash Platform 0.21.0 introduced a 4 byte [protocol version](https://github.com/dashevo/js-dpp/pull/325) that is prepended to the binary format and is not part of the CBOR-encoded data. When parsing proofs it is necessary to exclude these bytes before decoding the returned data with CBOR.

#### Structure

Merk proofs are a list of stack-based operators and node data, with 3 possible operators: `Push(node)`, `Parent`, and `Child`. A stream of these operators can be processed by a verifier in order to reconstruct a sparse representation of part of the tree, in a way where the data can be verified against a known root hash.

The value of `node` in a `Push` operation can be one of three types:

- `Hash(hash)` - The hash of a node
- `KVHash(hash)` - The key/value hash of a node
- `KV(key, value)` - The key and value of a node

#### Binary Format

We can efficiently encode these proofs by encoding each operator as follows:

| Operator | Op. Value | Size | Description |
|-|:-:|-|-|
| Push(Hash(hash)) | `0x01` | 32 bytes | Node hash |
| Push(KVHash(hash)) | `0x02` | 32 bytes | Node key/value hash |
| Push(KV(key, value)) | `0x03` | < 1-byte key length ><br>< n-byte key ><br>< 2-byte value length ><br>< n-byte value > | Node key/value |

This results in a compact binary representation, with a very small space overhead (roughly 2 bytes per node in the proof (1 byte for the Push operator type flag, and 1 byte for a Parent or Child operator), plus 3 bytes per key/value pair (1 byte for the key length, and 2 bytes for the value length)).

## Retrieving response data from proofs

The function below shows a simple example of parsing a response's `storeTreeProof` to retrieve the data asked for by the request:

```javascript
// Get data from base64 encoded store tree proof
function getStoreProofData(storeProof) {
  const values = [];
  const buf = Buffer.from(storeProof, 'base64');

  let x = 0;
  let valueFound = false;
  while (x < buf.length) {
    const type = buf.readUInt8(x);
    x += 1;

    switch (type) {
      case 0x01: { // Hash
        x += hashLength;
        break;
      }

      case 0x02: { // Key/value hash
        x += hashLength;
        break;
      }

      case 0x03: { // Key / Value
        const keySize = buf.readUInt8(x);
        x += (1 + keySize);

        const valueSize = buf.readUInt16BE(x);
        x += 2;

        // Value
        // Start at x+4 because the first 4 bytes are the protocol version
        // and are not part of the CBOR value
        const value = buf.toString('hex', x + 4, x + valueSize);
        x += valueSize;
        const map = cbor.decode(value);

        valueFound = true;
        values.push(map);
        break;
      }

      case 0x10: // Parent
        break;

      case 0x11: // Child
        break;

      default:
        console.log(`Unknown type: ${type.toString(16)}`);
        break;
    }
  }
  console.log(`Value found: ${valueFound}`);
  return values;
}
```
