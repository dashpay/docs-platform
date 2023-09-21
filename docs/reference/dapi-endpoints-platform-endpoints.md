# Platform gRPC Endpoints

Please refer to the [gRPC Overview](../reference/dapi-endpoints-grpc-overview.md) for details regarding running the examples shown below, encoding/decoding the request/response data, and clients available for several languages.

## Data Proofs and Metadata

Since Dash Platform 0.20.0, Platform gRPC endpoints can provide [proofs](https://github.com/dashpay/platform/blob/master/packages/dapi-grpc/protos/platform/v0/platform.proto#L17-L22) so the data returned for a request can be verified as being valid. Full support is not yet available in the JavaScript client, but can be used via the low level [dapi-grpc library](https://github.com/dashevo/platform/tree/master/packages/dapi-grpc).

Some [additional metadata](https://github.com/dashevo/platform/blob/master/packages/dapi-grpc/protos/platform/v0/platform.proto#L30-L33) is also provided with responses:

| Metadata field          | Description                                           |
| :---------------------- | :---------------------------------------------------- |
| `height`                | Last committed platform chain height                  |
| `coreChainLockedHeight` | Height of the most recent ChainLock on the core chain |
| `timeMs`                | Unix timestamp in milliseconds for the response       |
| `protocolVersion`       | Platform protocol version                             |

## Endpoint Details

### broadcastStateTransition

> 📘 
> 
> **Note:** The [`waitForStateTransitionResult` endpoint](#waitforstatetransitionresult) should be used in conjunction with this one for instances where proof of block confirmation is required.

Broadcasts a [state transition](../explanations/platform-protocol-state-transition.md) to the platform via DAPI to make a change to layer 2 data. The `broadcastStateTransition` call returns once the state transition has been accepted into the mempool. 

**Returns**: Nothing or error

**Parameters**:

| Name               | Type           | Required | Description                                                          |
| ------------------ | -------------- | -------- | -------------------------------------------------------------------- |
| `state_transition` | Bytes (Base64) | Yes      | A [state transition](../explanations/platform-protocol-state-transition.md) |

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\nJavaScript (dapi-client) example (old)\nconst DAPIClient = require('@dashevo/dapi-client');\nconst DashPlatformProtocol = require('@dashevo/dpp');\n\nconst client = new DAPIClient();\nconst dpp = new DashPlatformProtocol();\n\n// Data Contract Create State Transition (JSON)\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    client.platform.broadcastStateTransition(stateTransition.toBuffer())\n      .then(() => console.log('State Transition broadcast successfully'));\n  });\n-->\n\n<!--\nJavaScript (dapi-grpc) example (old)\nconst {\n  v0: {\n    PlatformPromiseClient,\n    BroadcastStateTransitionRequest,\n  },\n} = require('@dashevo/dapi-grpc');\nconst DashPlatformProtocol = require('@dashevo/dpp');\n\nconst platformPromiseClient = new PlatformPromiseClient(\n  'https://seed-1.testnet.networks.dash.org:1443',\n);\n\nconst dpp = new DashPlatformProtocol();\n\n// Data Contract Create State Transition (JSON)\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\nconst broadcastStateTransitionRequest = new BroadcastStateTransitionRequest();\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    console.log(stateTransition);\n    broadcastStateTransitionRequest.setStateTransition(stateTransition.toBuffer());\n\n    platformPromiseClient.broadcastStateTransition(broadcastStateTransitionRequest)\n      .then(() => console.log('State Transition broadcast successfully'))\n      .catch((e) => {\n        console.error(e);\n        console.error(e.metadata);\n      });\n  })\n  .catch((e) => console.error(e));\n-->\n\n<!--\ngRPCurl example (old)\n# Submit an identity create State Transition\n# `state_transition` must be represented in base64\n# Replace `state_transition` with your own state transition object before running\ngrpcurl -proto protos/platform/v0/platform.proto \\\n  -d '{\n    \"state_transition\":\"pWR0eXBlAmlzaWduYXR1cmV4WEg3TWhFWDQ0Z3JzMVIwTE9XTU5IZjAxWFNpYVFQcUlVZ1JLRXQyMkxHVERsUlUrZ1BwQUlUZk5JUmhXd3IvYTVHd0lzWm1idGdYVVFxcVhjbW9lQWtUOD1qcHVibGljS2V5c4GkYmlkAGRkYXRheCxBdzh2UmYxeFFCTlVLbzNiY2llaHlaR2NhM0hBSThkY0ZvVWJTK3hLb0lITmR0eXBlAGlpc0VuYWJsZWT1bmxvY2tlZE91dFBvaW50eDBLT1VUSHB5YnFPek9DNnhEVUhFWm9uc1lNSVpqcGppTHFZNnkxYmlWNWxRQUFBQUFvcHJvdG9jb2xWZXJzaW9uAA==\"\n\n    }' \\\n  seed-1.testnet.networks.dash.org:1443 \\\n  org.dash.platform.dapi.v0.Platform/broadcastStateTransition\n-->"
  }
  [/block]
```

**Response**: No response except on error

### getIdentity

> 🚧 Breaking changes
> 
> As of Dash Platform 0.24 the `protocolVersion` is no longer included in the CBOR-encoded data. It is instead prepended as a varint to the data following CBOR encoding.

**Returns**: [Identity](../explanations/identity.md) information for the requested identity  
**Parameters**:

| Name    | Type    | Required | Description                                                           |
| ------- | ------- | -------- | --------------------------------------------------------------------- |
| `id`    | Bytes   | Yes      | An identity `id`                                                      |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested identity |

> 📘 
> 
> **Note**: When requesting proofs, the data requested will be encoded as part of the proof in the response.

** Example Request and Response **

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');
const Identifier = require('@dashevo/dpp/lib/Identifier');
const cbor = require('cbor');
const varint = require('varint');

const client = new DAPIClient();

const identityId = Identifier.from('4EfA9Jrvv3nnCFdSf7fad59851iiTRZ6Wcu6YVJ4iSeF');
client.platform.getIdentity(identityId).then((response) => {
  // Strip off protocol version (leading varint) and decode
  const identityBuffer = Buffer.from(response.getIdentity());
  const protocolVersion = varint.decode(identityBuffer);
  const identity = cbor.decode(
    identityBuffer.slice(varint.encodingLength(protocolVersion), identityBuffer.length),
  );
  console.log(identity);
});
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: { PlatformPromiseClient, GetIdentityRequest },
} = require('@dashevo/dapi-grpc');
const Identifier = require('@dashevo/dpp/lib/Identifier');
const cbor = require('cbor');
const varint = require('varint');

const platformPromiseClient = new PlatformPromiseClient(
  'https://seed-1.testnet.networks.dash.org:1443',
);

const id = Identifier.from('4EfA9Jrvv3nnCFdSf7fad59851iiTRZ6Wcu6YVJ4iSeF');
const idBuffer = Buffer.from(id);
const getIdentityRequest = new GetIdentityRequest();
getIdentityRequest.setId(idBuffer);
getIdentityRequest.setProve(false);

platformPromiseClient.getIdentity(getIdentityRequest)
  .then((response) => {
    // Strip off protocol version (leading varint) and decode
    const identityBuffer = Buffer.from(response.getIdentity());
    const protocolVersion = varint.decode(identityBuffer);
    const decodedIdentity = cbor.decode(
      identityBuffer.slice(varint.encodingLength(protocolVersion), identityBuffer.length),
    );
    console.log(decodedIdentity);  
  })
  .catch((e) => console.error(e));
```
```shell gRPCurl
# gRPCurl
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "id":"MBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/aw="
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentity
```

::::

::::{tab-set-code}

```json Response (JavaScript)
// Response (JavaScript)
{
  "id": "<Buffer 30 12 c1 9b 98 ec 00 33 ad db 36 cd 64 b7 f5 10 67 0f 2a 35 1a 43 04 b5 f6 99 41 44 28 6e fd ac>",
  "balance": 5255234422,
  "revision": 0,
  "publicKeys": [
    {
      "id": 0,
      "data": "<Buffer 02 c8 b4 74 7b 52 8c ac 5f dd f7 a6 cc 63 70 2e e0 4e d7 d1 33 29 04 e0 85 10 34 3e a0 0d ce 54 6a>",
      "type": 0,
      "purpose": 0,
      "readOnly": false,
      "securityLevel": 0
    },
    {
      "id": 1,
      "data": "<Buffer 02 01 ee 28 f8 4f 54 85 39 05 67 e9 39 c2 b5 86 01 0b 63 a6 9e c9 2c ab 53 5d c9 6a 8c 71 91 36 02>",
      "type": 0,
      "purpose": 0,
      "readOnly": false,
      "securityLevel": 2
    }
  ]
}
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "identity": "AaRiaWRYIDASwZuY7AAzrds2zWS39RBnDyo1GkMEtfaZQUQobv2sZ2JhbGFuY2UbAAAAATk8g3ZocmV2aXNpb24AanB1YmxpY0tleXOCpmJpZABkZGF0YVghAsi0dHtSjKxf3femzGNwLuBO19EzKQTghRA0PqANzlRqZHR5cGUAZ3B1cnBvc2UAaHJlYWRPbmx59G1zZWN1cml0eUxldmVsAKZiaWQBZGRhdGFYIQIB7ij4T1SFOQVn6TnCtYYBC2Omnsksq1NdyWqMcZE2AmR0eXBlAGdwdXJwb3NlAGhyZWFkT25sefRtc2VjdXJpdHlMZXZlbAI=",
  "metadata": {
    "height": "4217",
    "coreChainLockedHeight": 858833,
    "timeMs": "1688058824358",
    "protocolVersion": 1
  }
}
```

::::

### getIdentitiesByPublicKeyHashes

**Returns**: [Identity](../explanations/identity.md) an array of identities associated with the provided public key hashes  
**Parameters**:

| Name                | Type    | Required | Description                                                             |
| ------------------- | ------- | -------- | ----------------------------------------------------------------------- |
| `public_key_hashes` | Bytes   | Yes      | Public key hashes (sha256-ripemd160) of identity public keys            |
| `prove`             | Boolean | No       | Set to `true` to receive a proof that contains the requested identities |

> 📘 
> 
> **Note**: When requesting proofs, the data requested will be encoded as part of the proof in the response.

> 📘 Public key hash
> 
> Note: the hash must be done using all fields of the identity public key object - e.g.
> 
> ```json
> {
>   "id": 0,
>   "type": 0,
>   "purpose": 0,
>   "securityLevel": 0,
>   "data": "A2GTAJk9eAWkMXVCb+rRKXH99POtR5OaW6zqZl7/yozp",
>   "readOnly": false
> }
> ```
> 
> When using the js-dpp library, the hash can be accessed via the [IdentityPublicKey object's](https://github.com/dashevo/platform/blob/master/packages/js-dpp/lib/identity/IdentityPublicKey.js) `hash` method (e.g. `identity.getPublicKeyById(0).hash()`).

** Example Request and Response **

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');
const {
  default: loadDpp, DashPlatformProtocol,
} = require('@dashevo/wasm-dpp');

const client = new DAPIClient();
loadDpp();
const dpp = new DashPlatformProtocol();

const publicKeyHash = 'b8d1591aa74d440e0af9c0be16c55bbc141847f7';
const publicKeysBuffer = [Buffer.from(publicKeyHash, 'hex')];

client.platform.getIdentitiesByPublicKeyHashes(publicKeysBuffer)
  .then((response) => {
    const retrievedIdentity = dpp.identity.createFromBuffer(response.identities[0]);
    console.log(retrievedIdentity.toJSON());
  });
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: { PlatformPromiseClient, GetIdentitiesByPublicKeyHashesRequest },
} = require('@dashevo/dapi-grpc');
const DashPlatformProtocol = require('@dashevo/dpp');

const dpp = new DashPlatformProtocol();

dpp.initialize()
  .then(() => {
    const platformPromiseClient = new PlatformPromiseClient(
      'https://seed-1.testnet.networks.dash.org:1443',
    );

    const publicKeyHash = 'b8d1591aa74d440e0af9c0be16c55bbc141847f7';
    const publicKeysBuffer = [Buffer.from(publicKeyHash, 'hex')];

    const getIdentitiesByPublicKeyHashesRequest = new GetIdentitiesByPublicKeyHashesRequest();
    getIdentitiesByPublicKeyHashesRequest.setPublicKeyHashesList(publicKeysBuffer);

    platformPromiseClient.getIdentitiesByPublicKeyHashes(getIdentitiesByPublicKeyHashesRequest)
      .then((response) => {
        const identitiesResponse = response.getIdentitiesList();
      	console.log(dpp.identity.createFromBuffer(Buffer.from(identitiesResponse[0])).toJSON());
      })
      .catch((e) => console.error(e));
  	});
```
```shell gRPCurl
# gRPCurl
# `public_key_hashes` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
      "public_key_hashes":"uNFZGqdNRA4K+cC+FsVbvBQYR/c="
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getIdentitiesByPublicKeyHashes
```

::::

::::{tab-set-code}

```json Response (JavaScript)
// Response (JavaScript)
{
  "$version": "0",
  "id": "4EfA9Jrvv3nnCFdSf7fad59851iiTRZ6Wcu6YVJ4iSeF",
  "publicKeys": [
    {
      "$version": "0",
      "id": 0,
      "purpose": 0,
      "securityLevel": 0,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "Asi0dHtSjKxf3femzGNwLuBO19EzKQTghRA0PqANzlRq",
      "disabledAt": null
    },
    {
      "$version": "0",
      "id": 1,
      "purpose": 0,
      "securityLevel": 2,
      "contractBounds": null,
      "type": 0,
      "readOnly": false,
      "data": "AgHuKPhPVIU5BWfpOcK1hgELY6aeySyrU13JaoxxkTYC",
      "disabledAt": null
    }
  ],
  "balance": 2344694260,
  "revision": 0
}
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "identities": [
    "AaRiaWRYIDASwZuY7AAzrds2zWS39RBnDyo1GkMEtfaZQUQobv2sZ2JhbGFuY2UbAAAAATk8g3ZocmV2aXNpb24AanB1YmxpY0tleXOCpmJpZABkZGF0YVghAsi0dHtSjKxf3femzGNwLuBO19EzKQTghRA0PqANzlRqZHR5cGUAZ3B1cnBvc2UAaHJlYWRPbmx59G1zZWN1cml0eUxldmVsAKZiaWQBZGRhdGFYIQIB7ij4T1SFOQVn6TnCtYYBC2Omnsksq1NdyWqMcZE2AmR0eXBlAGdwdXJwb3NlAGhyZWFkT25sefRtc2VjdXJpdHlMZXZlbAI="
  ],
  "metadata": {
    "height": "4216",
    "coreChainLockedHeight": 858832,
    "timeMs": "1688058626337",
    "protocolVersion": 1
  }
}
```

::::

### getDataContract

**Returns**: [Data Contract](../explanations/platform-protocol-data-contract.md) information for the requested data contract  
**Parameters**:

| Name    | Type    | Required | Description                                                                |
| ------- | ------- | -------- | -------------------------------------------------------------------------- |
| `id`    | Bytes   | Yes      | A data contract `id`                                                       |
| `prove` | Boolean | No       | Set to `true` to receive a proof that contains the requested data contract |

> 📘 
> 
> **Note**: When requesting proofs, the data requested will be encoded as part of the proof in the response.

** Example Request and Response **

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');
const Identifier = require('@dashevo/dpp/lib/Identifier');
const cbor = require('cbor');
const varint = require('varint');

const client = new DAPIClient();

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
client.platform.getDataContract(contractId).then((response) => {
    // Strip off protocol version (leading varint) and decode
    const contractBuffer = Buffer.from(response.getDataContract());
    const protocolVersion = varint.decode(contractBuffer);
    const contract = cbor.decode(
      contractBuffer.slice(varint.encodingLength(protocolVersion), contractBuffer.length),
    );
  console.dir(contract, { depth: 10 });
});
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: { PlatformPromiseClient, GetDataContractRequest },
} = require('@dashevo/dapi-grpc');
const Identifier = require('@dashevo/dpp/lib/Identifier');
const cbor = require('cbor');
const varint = require('varint');

const platformPromiseClient = new PlatformPromiseClient(
  'https://seed-1.testnet.networks.dash.org:1443',
);

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
const contractIdBuffer = Buffer.from(contractId);
const getDataContractRequest = new GetDataContractRequest();
getDataContractRequest.setId(contractIdBuffer);

platformPromiseClient.getDataContract(getDataContractRequest)
  .then((response) => {
    // Strip off protocol version (leading varint) and decode
    const contractBuffer = Buffer.from(response.getDataContract());
    const protocolVersion = varint.decode(contractBuffer);
    const decodedDataContract = cbor.decode(
      contractBuffer.slice(varint.encodingLength(protocolVersion), contractBuffer.length),
    );
    console.dir(decodedDataContract, { depth: 5 });
  })
  .catch((e) => console.error(e));
```
```shell gRPCurl
# gRPCurl
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "id":"5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU="
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDataContract
```

::::

::::{tab-set-code}

```json Response (JavaScript)
// Response (JavaScript)
{
  "$id": "Buffer(32) [Uint8Array] [
    230, 104, 198,  89, 175, 102, 174, 225,
    231,  44,  24, 109, 222, 123,  91, 126,
     10,  29, 113,  42,   9, 196,  13,  87,
     33, 246,  34, 191,  83, 197,  49,  85
  ]",
  "$schema": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
  "ownerId": "Buffer(32) [Uint8Array] [
     48,  18, 193, 155, 152, 236,   0,  51,
    173, 219,  54, 205, 100, 183, 245,  16,
    103,  15,  42,  53,  26,  67,   4, 181,
    246, 153,  65,  68,  40, 110, 253, 172
  ]",
  "version": 1,
  "documents": {
    "domain": {
      "type": "object",
      "indices": [
        {
          "name": "parentNameAndLabel",
          "unique": true,
          "properties": [
            { "normalizedParentDomainName": "asc" },
            { "normalizedLabel": "asc" }
          ]
        },
        {
          "name": "dashIdentityId",
          "unique": true,
          "properties": [ { "records.dashUniqueIdentityId": "asc" } ]
        },
        {
          "name": "dashAlias",
          "properties": [ { "records.dashAliasIdentityId": "asc" } ]
        }
      ],
      "$comment": "In order to register a domain you need to create a preorder. The preorder step is needed to prevent man-in-the-middle attacks. normalizedLabel + '.' + normalizedParentDomain must not be longer than 253 chars length as defined by RFC 1035. Domain documents are immutable: modification and deletion are restricted",
      "required": [
        "label",
        "normalizedLabel",
        "normalizedParentDomainName",
        "preorderSalt",
        "records",
        "subdomainRules"
      ],
      "properties": {
        "label": {
          "type": "string",
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$",
          "maxLength": 63,
          "minLength": 3,
          "description": "Domain label. e.g. 'Bob'."
        },
        "records": {
          "type": "object",
          "$comment": "Constraint with max and min properties ensure that only one identity record is used - either a `dashUniqueIdentityId` or a `dashAliasIdentityId`",
          "properties": {
            "dashAliasIdentityId": {
              "type": "array",
              "$comment": "Must be equal to the document owner",
              "maxItems": 32,
              "minItems": 32,
              "byteArray": true,
              "description": "Identity ID to be used to create alias names for the Identity",
              "contentMediaType": "application/x.dash.dpp.identifier"
            },
            "dashUniqueIdentityId": {
              "type": "array",
              "$comment": "Must be equal to the document owner",
              "maxItems": 32,
              "minItems": 32,
              "byteArray": true,
              "description": "Identity ID to be used to create the primary name the Identity",
              "contentMediaType": "application/x.dash.dpp.identifier"
            }
          },
          "maxProperties": 1,
          "minProperties": 1,
          "additionalProperties": false
        },
        "preorderSalt": {
          "type": "array",
          "maxItems": 32,
          "minItems": 32,
          "byteArray": true,
          "description": "Salt used in the preorder document"
        },
        "subdomainRules": {
          "type": "object",
          "required": [ "allowSubdomains" ],
          "properties": {
            "allowSubdomains": {
              "type": "boolean",
              "$comment": "Only the domain owner is allowed to create subdomains for non top-level domains",
              "description": "This option defines who can create subdomains: true - anyone; false - only the domain owner"
            }
          },
          "description": "Subdomain rules allow domain owners to define rules for subdomains",
          "additionalProperties": false
        },
        "normalizedLabel": {
          "type": "string",
          "pattern": "^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$",
          "$comment": "Must be equal to the label in lowercase. This property will be deprecated due to case insensitive indices",
          "maxLength": 63,
          "description": "Domain label in lowercase for case-insensitive uniqueness validation. e.g. 'bob'"
        },
        "normalizedParentDomainName": {
          "type": "string",
          "pattern": "^$|^[a-z0-9][a-z0-9-\\.]{0,61}[a-z0-9]$",
          "$comment": "Must either be equal to an existing domain or empty to create a top level domain. Only the data contract owner can create top level domains.",
          "maxLength": 63,
          "minLength": 0,
          "description": "A full parent domain name in lowercase for case-insensitive uniqueness validation. e.g. 'dash'"
        }
      },
      "additionalProperties": false
    },
    "preorder": {
      "type": "object",
      "indices": [
        {
          "name": "saltedHash",
          "unique": true,
          "properties": [ { "saltedDomainHash": "asc" } ]
        }
      ],
      "$comment": "Preorder documents are immutable: modification and deletion are restricted",
      "required": [ "saltedDomainHash" ],
      "properties": {
        "saltedDomainHash": {
          "type": "array",
          "maxItems": 32,
          "minItems": 32,
          "byteArray": true,
          "description": "Double sha-256 of the concatenation of a 32 byte random salt and a normalized domain name"
        }
      },
      "additionalProperties": false
    }
  }
}
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "dataContract": "AaVjJGlkWCDmaMZZr2au4ecsGG3ee1t+Ch1xKgnEDVch9iK/U8UxVWckc2NoZW1heDRodHRwczovL3NjaGVtYS5kYXNoLm9yZy9kcHAtMC00LTAvbWV0YS9kYXRhLWNvbnRyYWN0Z293bmVySWRYIDASwZuY7AAzrds2zWS39RBnDyo1GkMEtfaZQUQobv2sZ3ZlcnNpb24BaWRvY3VtZW50c6JmZG9tYWlupmR0eXBlZm9iamVjdGdpbmRpY2Vzg6NkbmFtZXJwYXJlbnROYW1lQW5kTGFiZWxmdW5pcXVl9Wpwcm9wZXJ0aWVzgqF4Gm5vcm1hbGl6ZWRQYXJlbnREb21haW5OYW1lY2FzY6Fvbm9ybWFsaXplZExhYmVsY2FzY6NkbmFtZW5kYXNoSWRlbnRpdHlJZGZ1bmlxdWX1anByb3BlcnRpZXOBoXgccmVjb3Jkcy5kYXNoVW5pcXVlSWRlbnRpdHlJZGNhc2OiZG5hbWVpZGFzaEFsaWFzanByb3BlcnRpZXOBoXgbcmVjb3Jkcy5kYXNoQWxpYXNJZGVudGl0eUlkY2FzY2gkY29tbWVudHkBN0luIG9yZGVyIHRvIHJlZ2lzdGVyIGEgZG9tYWluIHlvdSBuZWVkIHRvIGNyZWF0ZSBhIHByZW9yZGVyLiBUaGUgcHJlb3JkZXIgc3RlcCBpcyBuZWVkZWQgdG8gcHJldmVudCBtYW4taW4tdGhlLW1pZGRsZSBhdHRhY2tzLiBub3JtYWxpemVkTGFiZWwgKyAnLicgKyBub3JtYWxpemVkUGFyZW50RG9tYWluIG11c3Qgbm90IGJlIGxvbmdlciB0aGFuIDI1MyBjaGFycyBsZW5ndGggYXMgZGVmaW5lZCBieSBSRkMgMTAzNS4gRG9tYWluIGRvY3VtZW50cyBhcmUgaW1tdXRhYmxlOiBtb2RpZmljYXRpb24gYW5kIGRlbGV0aW9uIGFyZSByZXN0cmljdGVkaHJlcXVpcmVkhmVsYWJlbG9ub3JtYWxpemVkTGFiZWx4Gm5vcm1hbGl6ZWRQYXJlbnREb21haW5OYW1lbHByZW9yZGVyU2FsdGdyZWNvcmRzbnN1YmRvbWFpblJ1bGVzanByb3BlcnRpZXOmZWxhYmVspWR0eXBlZnN0cmluZ2dwYXR0ZXJueCpeW2EtekEtWjAtOV1bYS16QS1aMC05LV17MCw2MX1bYS16QS1aMC05XSRpbWF4TGVuZ3RoGD9pbWluTGVuZ3RoA2tkZXNjcmlwdGlvbngZRG9tYWluIGxhYmVsLiBlLmcuICdCb2InLmdyZWNvcmRzpmR0eXBlZm9iamVjdGgkY29tbWVudHiQQ29uc3RyYWludCB3aXRoIG1heCBhbmQgbWluIHByb3BlcnRpZXMgZW5zdXJlIHRoYXQgb25seSBvbmUgaWRlbnRpdHkgcmVjb3JkIGlzIHVzZWQgLSBlaXRoZXIgYSBgZGFzaFVuaXF1ZUlkZW50aXR5SWRgIG9yIGEgYGRhc2hBbGlhc0lkZW50aXR5SWRganByb3BlcnRpZXOic2Rhc2hBbGlhc0lkZW50aXR5SWSnZHR5cGVlYXJyYXloJGNvbW1lbnR4I011c3QgYmUgZXF1YWwgdG8gdGhlIGRvY3VtZW50IG93bmVyaG1heEl0ZW1zGCBobWluSXRlbXMYIGlieXRlQXJyYXn1a2Rlc2NyaXB0aW9ueD1JZGVudGl0eSBJRCB0byBiZSB1c2VkIHRvIGNyZWF0ZSBhbGlhcyBuYW1lcyBmb3IgdGhlIElkZW50aXR5cGNvbnRlbnRNZWRpYVR5cGV4IWFwcGxpY2F0aW9uL3guZGFzaC5kcHAuaWRlbnRpZmllcnRkYXNoVW5pcXVlSWRlbnRpdHlJZKdkdHlwZWVhcnJheWgkY29tbWVudHgjTXVzdCBiZSBlcXVhbCB0byB0aGUgZG9jdW1lbnQgb3duZXJobWF4SXRlbXMYIGhtaW5JdGVtcxggaWJ5dGVBcnJhefVrZGVzY3JpcHRpb254PklkZW50aXR5IElEIHRvIGJlIHVzZWQgdG8gY3JlYXRlIHRoZSBwcmltYXJ5IG5hbWUgdGhlIElkZW50aXR5cGNvbnRlbnRNZWRpYVR5cGV4IWFwcGxpY2F0aW9uL3guZGFzaC5kcHAuaWRlbnRpZmllcm1tYXhQcm9wZXJ0aWVzAW1taW5Qcm9wZXJ0aWVzAXRhZGRpdGlvbmFsUHJvcGVydGllc/RscHJlb3JkZXJTYWx0pWR0eXBlZWFycmF5aG1heEl0ZW1zGCBobWluSXRlbXMYIGlieXRlQXJyYXn1a2Rlc2NyaXB0aW9ueCJTYWx0IHVzZWQgaW4gdGhlIHByZW9yZGVyIGRvY3VtZW50bnN1YmRvbWFpblJ1bGVzpWR0eXBlZm9iamVjdGhyZXF1aXJlZIFvYWxsb3dTdWJkb21haW5zanByb3BlcnRpZXOhb2FsbG93U3ViZG9tYWluc6NkdHlwZWdib29sZWFuaCRjb21tZW50eE9Pbmx5IHRoZSBkb21haW4gb3duZXIgaXMgYWxsb3dlZCB0byBjcmVhdGUgc3ViZG9tYWlucyBmb3Igbm9uIHRvcC1sZXZlbCBkb21haW5za2Rlc2NyaXB0aW9ueFtUaGlzIG9wdGlvbiBkZWZpbmVzIHdobyBjYW4gY3JlYXRlIHN1YmRvbWFpbnM6IHRydWUgLSBhbnlvbmU7IGZhbHNlIC0gb25seSB0aGUgZG9tYWluIG93bmVya2Rlc2NyaXB0aW9ueEJTdWJkb21haW4gcnVsZXMgYWxsb3cgZG9tYWluIG93bmVycyB0byBkZWZpbmUgcnVsZXMgZm9yIHN1YmRvbWFpbnN0YWRkaXRpb25hbFByb3BlcnRpZXP0b25vcm1hbGl6ZWRMYWJlbKVkdHlwZWZzdHJpbmdncGF0dGVybnghXlthLXowLTldW2EtejAtOS1dezAsNjF9W2EtejAtOV0kaCRjb21tZW50eGlNdXN0IGJlIGVxdWFsIHRvIHRoZSBsYWJlbCBpbiBsb3dlcmNhc2UuIFRoaXMgcHJvcGVydHkgd2lsbCBiZSBkZXByZWNhdGVkIGR1ZSB0byBjYXNlIGluc2Vuc2l0aXZlIGluZGljZXNpbWF4TGVuZ3RoGD9rZGVzY3JpcHRpb254UERvbWFpbiBsYWJlbCBpbiBsb3dlcmNhc2UgZm9yIGNhc2UtaW5zZW5zaXRpdmUgdW5pcXVlbmVzcyB2YWxpZGF0aW9uLiBlLmcuICdib2IneBpub3JtYWxpemVkUGFyZW50RG9tYWluTmFtZaZkdHlwZWZzdHJpbmdncGF0dGVybngmXiR8XlthLXowLTldW2EtejAtOS1cLl17MCw2MX1bYS16MC05XSRoJGNvbW1lbnR4jE11c3QgZWl0aGVyIGJlIGVxdWFsIHRvIGFuIGV4aXN0aW5nIGRvbWFpbiBvciBlbXB0eSB0byBjcmVhdGUgYSB0b3AgbGV2ZWwgZG9tYWluLiBPbmx5IHRoZSBkYXRhIGNvbnRyYWN0IG93bmVyIGNhbiBjcmVhdGUgdG9wIGxldmVsIGRvbWFpbnMuaW1heExlbmd0aBg/aW1pbkxlbmd0aABrZGVzY3JpcHRpb254XkEgZnVsbCBwYXJlbnQgZG9tYWluIG5hbWUgaW4gbG93ZXJjYXNlIGZvciBjYXNlLWluc2Vuc2l0aXZlIHVuaXF1ZW5lc3MgdmFsaWRhdGlvbi4gZS5nLiAnZGFzaCd0YWRkaXRpb25hbFByb3BlcnRpZXP0aHByZW9yZGVypmR0eXBlZm9iamVjdGdpbmRpY2VzgaNkbmFtZWpzYWx0ZWRIYXNoZnVuaXF1ZfVqcHJvcGVydGllc4GhcHNhbHRlZERvbWFpbkhhc2hjYXNjaCRjb21tZW50eEpQcmVvcmRlciBkb2N1bWVudHMgYXJlIGltbXV0YWJsZTogbW9kaWZpY2F0aW9uIGFuZCBkZWxldGlvbiBhcmUgcmVzdHJpY3RlZGhyZXF1aXJlZIFwc2FsdGVkRG9tYWluSGFzaGpwcm9wZXJ0aWVzoXBzYWx0ZWREb21haW5IYXNopWR0eXBlZWFycmF5aG1heEl0ZW1zGCBobWluSXRlbXMYIGlieXRlQXJyYXn1a2Rlc2NyaXB0aW9ueFlEb3VibGUgc2hhLTI1NiBvZiB0aGUgY29uY2F0ZW5hdGlvbiBvZiBhIDMyIGJ5dGUgcmFuZG9tIHNhbHQgYW5kIGEgbm9ybWFsaXplZCBkb21haW4gbmFtZXRhZGRpdGlvbmFsUHJvcGVydGllc/Q=",
  "metadata": {
    "height": "4253",
    "coreChainLockedHeight": 889435,
    "timeMs": "1684440772828",
    "protocolVersion": 1
  }
}
```

::::

### getDocuments

**Returns**: [Document](../explanations/platform-protocol-document.md) information for the requested document(s)  
**Parameters**:

> 🚧 - Parameter constraints
> 
> The `where`, `order_by`, `limit`, `start_at`, and `start_after` parameters must comply with the limits defined on the [Query Syntax](../reference/query-syntax.md) page.
> 
> Additionally, note that `where` and `order_by` must be [CBOR](https://tools.ietf.org/html/rfc7049) encoded.

| Name                    | Type    | Required | Description                                                                                      |
| ----------------------- | ------- | -------- | ------------------------------------------------------------------------------------------------ |
| `data_contract_id`      | Bytes   | Yes      | A data contract `id`                                                                             |
| `document_type`         | String  | Yes      | A document type defined by the data contract (e.g. `preorder` or `domain` for the DPNS contract) |
| `where` \*              | Bytes   | No       | Where clause to filter the results (**must be CBOR encoded**)                                    |
| `order_by` \*           | Bytes   | No       | Sort records by the field(s) provided (**must be CBOR encoded**)                                 |
| `limit`                 | Integer | No       | Maximum number of results to return                                                              |
| ----------              |         |          |                                                                                                  |
| _One_ of the following: |         |          |                                                                                                  |
| `start_at`              | Integer | No       | Return records beginning with the index provided                                                 |
| `start_after`           | Integer | No       | Return records beginning after the index provided                                                |
| ----------              |         |          |                                                                                                  |
| `prove`                 | Boolean | No       | Set to `true` to receive a proof that contains the requested document(s)                         |

> 📘 
> 
> **Note**: When requesting proofs, the data requested will be encoded as part of the proof in the response.

** Example Request and Response **

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');
const Identifier = require('@dashevo/dpp/lib/Identifier');
const cbor = require('cbor');
const varint = require('varint');

const client = new DAPIClient();

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
client.platform.getDocuments(contractId, 'domain', { limit: 10 }).then((response) => {
  for (const rawData of response.documents) {
    // Strip off protocol version (leading varint) and decode
    const documentBuffer = Buffer.from(rawData);
    const protocolVersion = varint.decode(documentBuffer);
    const document = cbor.decode(
      documentBuffer.slice(varint.encodingLength(protocolVersion), documentBuffer.length),
    );
    console.log(document);
  }
});
```
```javascript JavaScript (dapi-grpc)
// JavaScript (dapi-grpc)
const {
  v0: { PlatformPromiseClient, GetDocumentsRequest },
} = require('@dashevo/dapi-grpc');
const cbor = require('cbor');
const Identifier = require('@dashevo/dpp/lib/Identifier');
const varint = require('varint');

const platformPromiseClient = new PlatformPromiseClient(
  'https://seed-1.testnet.networks.dash.org:1443',
);

const contractId = Identifier.from('GWRSAVFMjXx8HpQFaNJMqBV7MBgMK4br5UESsB4S31Ec');
const contractIdBuffer = Buffer.from(contractId);
const getDocumentsRequest = new GetDocumentsRequest();
const type = 'domain';
const limit = 10;

getDocumentsRequest.setDataContractId(contractIdBuffer);
getDocumentsRequest.setDocumentType(type);
// getDocumentsRequest.setWhere(whereSerialized);
// getDocumentsRequest.setOrderBy(orderBySerialized);
getDocumentsRequest.setLimit(limit);
// getDocumentsRequest.setStartAfter(startAfter);
// getDocumentsRequest.setStartAt(startAt);

platformPromiseClient.getDocuments(getDocumentsRequest)
  .then((response) => {
    for (const document of response.getDocumentsList()) {
      // Strip off protocol version (leading varint) and decode
      const documentBuffer = Buffer.from(document);
      const protocolVersion = varint.decode(documentBuffer);
      const decodedDocument = cbor.decode(
        documentBuffer.slice(varint.encodingLength(protocolVersion), documentBuffer.length),
      );
      console.log(decodedDocument);      
    }
  })
  .catch((e) => console.error(e));
```
```shell Request (gRPCurl)
# gRPCurl
# Request documents
# `id` must be represented in base64
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "data_contract_id":"5mjGWa9mruHnLBht3ntbfgodcSoJxA1XIfYiv1PFMVU=",
    "document_type":"domain",
    "limit":1
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/getDocuments
```

::::

::::{tab-set-code}

```json Response (JavaScript)
// Response (JavaScript)
{
  "$id": "<Buffer 01 a0 7c 69 43 82 cf fe 93 97 be c9 f4 be cd 67 81 8f 60 d2 a7 56 48 08 11 80 49 84 0b 2e 2c 5d>",
  "$type": "domain",
  "label": "Dash01",
  "records": {
    "dashUniqueIdentityId": "<Buffer f5 50 ed 37 1a 12 3f 54 00 59 31 84 f7 f7 37 f1 f4 b1 5d 05 6f 9c a8 0e 5f 00 52 82 08 77 7c 4a>"
  },
  "$ownerId": "<Buffer f5 50 ed 37 1a 12 3f 54 00 59 31 84 f7 f7 37 f1 f4 b1 5d 05 6f 9c a8 0e 5f 00 52 82 08 77 7c 4a>",
  "$revision": 1,
  "preorderSalt": "<Buffer 2c b4 1b e9 f4 40 03 9b 47 2f 31 74 46 df 7f 4f 43 fe 14 80 be ca 84 0d 63 0f a6 65 23 b9 9c a1>",
  "subdomainRules": { "allowSubdomains": false },
  "$dataContractId": "<Buffer e6 68 c6 59 af 66 ae e1 e7 2c 18 6d de 7b 5b 7e 0a 1d 71 2a 09 c4 0d 57 21 f6 22 bf 53 c5 31 55>",
  "normalizedLabel": "dash01",
  "normalizedParentDomainName": "dash"
}
```
```json Response (gRPCurl)
// Response (gRPCurl)
{
  "documents": [
    "AatjJGlkWCACod79ik2tILNnybx5VepoaX2cceXDSogwSgxdWi9zYmUkdHlwZWZkb21haW5lbGFiZWx0Yzg4OWMyM2FiY2ZkYzU3NGNmZWJncmVjb3Jkc6FzZGFzaEFsaWFzSWRlbnRpdHlJZFggMBLBm5jsADOt2zbNZLf1EGcPKjUaQwS19plBRChu/axoJG93bmVySWRYIDASwZuY7AAzrds2zWS39RBnDyo1GkMEtfaZQUQobv2saSRyZXZpc2lvbgFscHJlb3JkZXJTYWx0WCAkJyav6iQVX7hFrUFagKC+xddHsyA5Wo/NdvejXt6aSG5zdWJkb21haW5SdWxlc6FvYWxsb3dTdWJkb21haW5z9W8kZGF0YUNvbnRyYWN0SWRYIOZoxlmvZq7h5ywYbd57W34KHXEqCcQNVyH2Ir9TxTFVb25vcm1hbGl6ZWRMYWJlbHRjODg5YzIzYWJjZmRjNTc0Y2ZlYngabm9ybWFsaXplZFBhcmVudERvbWFpbk5hbWVg"
  ],
  "metadata": {
    "height": "4254",
    "coreChainLockedHeight": 889435,
    "timeMs": "1684440970270",
    "protocolVersion": 1
  }
}
```

::::

### waitForStateTransitionResult

**Returns**: The state transition hash and either a proof that the state transition was confirmed in a block or an error.  
**Parameters**:

| Name                    | Type    | Required | Description                      |
| ----------------------- | ------- | -------- | -------------------------------- |
| `state_transition_hash` | Bytes   | Yes      | Hash of the state transition     |
| `prove`                 | Boolean | Yes      | Set to `true` to request a proof |

> 📘 
> 
> **Note**: When requesting proofs, the data requested will be encoded as part of the proof in the response.

** Example Request**

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\nJavaScript (dapi-client) example (old)\nconst DAPIClient = require('@dashevo/dapi-client');\nconst DashPlatformProtocol = require('@dashevo/dpp');\nconst crypto = require('crypto');\n\nconst client = new DAPIClient();\nconst dpp = new DashPlatformProtocol();\n\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    //  Calculate state transition hash\n    const hash = crypto.createHash('sha256')\n      .update(stateTransition.toBuffer())\n      .digest();\n\n    console.log(`Requesting proof of state transition with hash:\\n\\t${hash.toString('hex')}`);\n\n    client.platform.waitForStateTransitionResult(hash, { prove: true })\n      .then((response) => {\n        console.log(response);\n      });\n  });\n-->\n\n<!--\nJavaScript (dapi-grpc) example (old)\nconst {\n  v0: {\n    PlatformPromiseClient,\n    WaitForStateTransitionResultRequest,\n  },\n} = require('@dashevo/dapi-grpc');\nconst DashPlatformProtocol = require('@dashevo/dpp');\nconst crypto = require('crypto');\n\nconst platformPromiseClient = new PlatformPromiseClient(\n  'https://seed-1.testnet.networks.dash.org:1443',\n);\n\nconst dpp = new DashPlatformProtocol();\n\n// Replace with your own state transition object before running\nconst stateTransitionObject = {\n  protocolVersion: 0,\n  type: 0,\n  signature: 'HxAipUsLWQBE++C1suSRNQiQh91rI1LZbblvQhk2erUaIvRneAagxGYYsXXYNvEeO+lBzlF1a9KHGGTHgnO/8Ts=',\n  signaturePublicKeyId: 0,\n  dataContract: {\n    protocolVersion: 0,\n    '$id': 'CMc7RghKkHeHtFdwfSX5Hzy7CUdpCEJnwsbfHdsbmJ32',\n    '$schema': 'https://schema.dash.org/dpp-0-4-0/meta/data-contract',\n    ownerId: '8Z3ps3tNoGoPEDYerUNCd4yi7zDwgBh2ejgSMExxvkfD',\n    documents: {\n      note: {\n        properties: { message: { type: 'string' } },\n        additionalProperties: false,\n      },\n    },\n  },\n  entropy: '+RqUArypdL8f/gCMAo4b6c3CoQvxHzsQG0BdYrT5QT0=',\n};\n\n// Convert signature and entropy to buffer\nstateTransitionObject.signature = Buffer.from(stateTransitionObject.signature, 'base64');\nstateTransitionObject.entropy = Buffer.from(stateTransitionObject.entropy, 'base64');\n\ndpp.stateTransition.createFromObject(stateTransitionObject, { skipValidation: true })\n  .then((stateTransition) => {\n    //  Calculate state transition hash\n    const hash = crypto.createHash('sha256')\n      .update(stateTransition.toBuffer())\n      .digest();\n\n    const waitForStateTransitionResultRequest = new WaitForStateTransitionResultRequest();\n    waitForStateTransitionResultRequest.setStateTransitionHash(hash);\n    waitForStateTransitionResultRequest.setProve(true);\n\n    console.log(`Requesting proof of state transition with hash:\\n\\t${hash.toString('hex')}`);\n\n    platformPromiseClient.waitForStateTransitionResult(waitForStateTransitionResultRequest)\n      .then((response) => {\n        const rootTreeProof = Buffer.from(response.getProof().getRootTreeProof());\n        const storeTreeProof = Buffer.from(response.getProof().getStoreTreeProof());\n        console.log(`Root tree proof: ${rootTreeProof.toString('hex')}`);\n        console.log(`Store tree proof: ${storeTreeProof.toString('hex')}`);\n      })\n  \t\t.catch((e) => console.error(e));\n  });\n-->\n\n<!--\ngRPCurl example (old)\n# `state_transition_hash` must be represented in base64\n# Replace `state_transition_hash` with your own before running\ngrpcurl -proto protos/platform/v0/platform.proto \\\n  -d '{\n    \"state_transition_hash\":\"wEiwFu9WvAtylrwTph5v0uXQm743N+75C+C9DhmZBkw=\",\n    \"prove\": \"true\"\n    }' \\\n  seed-1.testnet.networks.dash.org:1443 \\\n  org.dash.platform.dapi.v0.Platform/waitForStateTransitionResult\n-->"
  }
  [/block]
```

::::{tab-set-code}

```javascript JavaScript (dapi-client)
// JavaScript (dapi-client)
const DAPIClient = require('@dashevo/dapi-client');

const client = new DAPIClient();

// Replace <YOUR_STATE_TRANSITION_HASH> with your actual hash
const hash = <YOUR_STATE_TRANSITION_HASH>;
client.platform.waitForStateTransitionResult(hash, { prove: true })
  .then((response) => {
    console.log(response);
  });

```
```shell Request (gRPCurl)
# gRPCurl
# Replace `your_state_transition_hash` with your own before running
# `your_state_transition_hash` must be represented in base64
#    Example: wEiwFu9WvAtylrwTph5v0uXQm743N+75C+C9DhmZBkw=
grpcurl -proto protos/platform/v0/platform.proto \
  -d '{
    "state_transition_hash":your_state_transition_hash,
    "prove": "true"
    }' \
  seed-1.testnet.networks.dash.org:1443 \
  org.dash.platform.dapi.v0.Platform/waitForStateTransitionResult
```

::::

```{eval-rst}
..
  Commented out info
  [block:html]
  {
    "html": "<!--\ndapi-client\n{\n  proof: {\n    rootTreeProof: <Buffer 01 00 00 00 03 26 e0 35 e0 31 82 7e 7c 27 b0 91 23 41 ed d2 11 bf 3b 90 54 70 11 2c 68 5a 8e 76 8c 68 bb 39 21 3d cf 46 6d 09 d0 7a 28 e3 e9 0b 2b 0e ... 17 more bytes>,\n    storeTreeProof: <Buffer 01 0b ee 31 ce ca 2a bd 44 6a db d4 9f 13 4a 7d 70 25 96 a9 b9 02 6e c4 e1 90 95 f7 a1 b4 c9 de 1f e4 63 e6 ce f7 58 3a 5b c3 10 01 78 9b 4f 98 9a c9 ... 526 more bytes>\n  }\n}\n-->\n<!--\ndapi-grpc\nRequesting proof of state transition with hash:\n        8ae93b89c272455f3ce8d01dba99a3a28c9550262a602c6ba44de08e545d3aa9\nRoot tree proof: 010000000326e035e031827e7c27b0912341edd211bf3b905470112c685a8e768c68bb39213dcf466d09d07a28e3e90b2b0e1d1510dede30214f68e32f8cf498220101\nStore tree proof: 010bee31ceca2abd446adbd49f134a7d702596a9b9026ec4e19095f7a1b4c9de1fe463e6cef7583a5bc31001789b4f989ac9f8f524f1247fed372502d8c54a3c026072d5239f074422621673c250d1c74eadbb304a10013fb54a99ef641b9a7585d6d28dd443875e435a35022d92a0711f56ae23bc13f4a630a1455970451e3f1001fe2b060fca69ce2eb3d784cec28c0f575690f131026df252af068635bdf08f5448ea67c23d9a9a02831001a7df0a9f392682d7d7d0a29bd43d932c16b0d6530320a8b7df4cadb6cdfd5b5d1bb31cbb488d241e91d60cc1341cd686a3fbb6291f19e800a5632469645820a8b7df4cadb6cdfd5b5d1bb31cbb488d241e91d60cc1341cd686a3fbb6291f196724736368656d61783468747470733a2f2f736368656d612e646173682e6f72672f6470702d302d342d302f6d6574612f646174612d636f6e7472616374676f776e657249645820703796bfd3e2bbd54505a8e04929bb05b8aecfb1cd5c013ef8a8b84511770e0c69646f63756d656e7473a1646e6f7465a26a70726f70657274696573a1676d657373616765a1647479706566737472696e67746164646974696f6e616c50726f70657274696573f46f70726f746f636f6c56657273696f6e001001d94cd40044b8485e962d80e57c1992c77a182a1611111102abe7e3f7231ed71b8c4fd7ee09d4a1f970a51cd4100139312feadce145313ef34f720e940892d0ed2405111102245c6aaaf192b51207333be85ab77c9c9393af47100128ef7d4479e4f488373d92280fe8e52a9a48a6621111\n-->\n<!--\ngRPCurl\n{\n  \"proof\": {\n    \"merkleProof\": \"AQAAAAAAAAJHAV8NeFRgf0cWRiCIIVsbJcNs+bALwShVQEkXV2jRCueIAkeoHTKeU60+Jm2oiHbGSkOL8ui06Nj27SLz2raMF29iEAHKnCrDvO67hcJV79tfQwqQSFcxJOek9Fa/x3oYvwQrQQL8lxVOSAkZSC1qhI8LJa6PtR+u8TifMMmRCRY2dXrSUBABihjPBDgD9SM/d9JgWkYyT+sUp4FdgotmwHhZIB1rJVUCkaeftxRkQ/B0FU26ojDJirY/SwZ8RcU1/3pnbJbA+5EQBCBkeRNzJuVLjOKnDOmG48wnSzjHg5lLdlA5JSBD79rQxQAFAgEBAAAYUfu7+1iqqIwjkszndZ6Vm8pli6pjt4XxvvgKCcE3ygI+G8nIsflGKoZQOaWGcFBmXDzAwJqjGlMxSIWNSEgoQBACAQd7xuP4BzKoaf75MNyQQC6Q7e94Vg2IdQe2LFJysA4QAZ2mq+ad/rNJ7n2fPiJgHi4NMT9Wht6Kb5J8qF20hajJEQKz2VnGsgYNwMjY9kadWb63Tjk3nTqFttgjLnoz4PCpQBABpdWVJ9sfU+o+OEcUuFcDOV+y4gYFoao3kVNLZ+Yz7Y4RAuVHBoF21TyNc9DUDHmAfcaJf6K+/VzqIzfnJ7iGqXN+EAGvNlkFsWw+DjFg+MLjzo2MzUaWk7sA63+rG3FQJ7LO2hERERECPImih8uZnpEfew+qLeKrdEig5TR6g5VsfuHI9U2WuvsQAU7qdWenHDisDf3TNzJQytKJYaeyhmy2LEo11zZVwsoREQIAAAAAAAAA/wMBAAD6APcBAAAApGJpZFggZHkTcyblS4zipwzphuPMJ0s4x4OZS3ZQOSUgQ+/a0MVnYmFsYW5jZRo7mmxAaHJldmlzaW9uAGpwdWJsaWNLZXlzgqZiaWQAZGRhdGFYIQLlz7I9IuqDAf1fp2xiyvGiApsvgANo2ldfmrWv6MsfG2R0eXBlAGdwdXJwb3NlAGhyZWFkT25sefRtc2VjdXJpdHlMZXZlbACmYmlkAWRkYXRhWCECrq7odM9OoHGEyM1D19ZAaEPf50OKLwsxL2D4SpnLZllkdHlwZQBncHVycG9zZQBocmVhZE9ubHn0bXNlY3VyaXR5TGV2ZWwCAAEAAAAAAAAA0QQBAAAkAgEgbaBpE46QX8+EXS6Sl5CG4r+JuiXVDhxZeZy/TS8qnQEAUw2uiB7scatAs99mQfB5VfVb0lMSywDMHXpmUgNfONsC4OEPflWGlZAqBSOhaKD0/SfPJHbOOMEfCjTtBV1jjgwQARdKA3tf2c8gP3H7tRKcRMHXfljTH/4L8L63tbZk5FX/EQL+TedZ8kFHQEuNY8e9pfmaLI36Y7rHe1hAjVBSh9U95BABfPfYq74T0N0ygKE4spKvSQkekrnH0Ge8Ot0FEDsq2rcR\",\n    \"signatureLlmqHash\": \"AAAA1h0X9yUNsXpD0/iKlsPvVb+VezkZAIkQIzmGqoc=\",\n    \"signature\": \"jeByZ8qlZvID/C3LVVy/mZGHlRu2QhN3MZO09hCOjAH0gn1tqrAX6BXaJf6qRLw9APv0+nInObRF3JhstvsByPK8QOHCCl9M3NpcgI/HCECpqMMG8S9DPtJYI6HwQO5I\"\n  },\n  \"metadata\": {\n    \"height\": \"1221\",\n    \"coreChainLockedHeight\": 802939\n  }\n}\n-->"
  }
  [/block]
```

## Deprecated Endpoints

No endpoints were deprecated in Dash Platform v0.24, but the previous version of documentation can be [viewed here](https://dashplatform.readme.io/v0.23.0/docs/reference-dapi-endpoints-platform-endpoints).

## Code Reference

Implementation details related to the information on this page can be found in:

- The [Platform repository](https://github.com/dashevo/platform/tree/master/packages/dapi) `packages/dapi/lib/grpcServer/handlers/core` folder
- The [Platform repository](https://github.com/dashevo/platform/tree/master/packages/dapi-grpc) `packages/dapi-grpc/protos` folder