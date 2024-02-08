# gRPC Overview

The gRPC endpoints provide access to information from Dash Platform (layer 2) as well as streaming of events related to blocks and transactions/transitions.

## Connecting to gRPC

### Auto-generated Clients

Clients for a number of languages are built automatically from the protocol definitions and are available in the `packages/dapi-grpc/clients` folder of the [platform](https://github.com/dashpay/platform/tree/master/packages/dapi-grpc/clients) repository. The protocol definitions are available in the [`protos` folder](https://github.com/dashpay/platform/tree/master/packages/dapi-grpc/protos). Pull requests are welcome to add support for additional languages that are not currently being built.

### Command Line Examples

Some examples shown in the endpoint details pages use a command-line tool named [gRPCurl](https://github.com/fullstorydev/grpcurl) that allows interacting with gRPC servers in a similar way as `curl` does for the [JSON-RPCs](../reference/dapi-endpoints-json-rpc-endpoints.md). Additional information may be found in the [gRPC documentation](https://grpc.io/docs/guides/).

To use gRPCurl as shown in the detailed examples, clone the [platform](https://github.com/dashevo/platform/) repository and execute the example requests from the `packages/dapi-grpc` directory of that repository as shown in this example:

```shell
## Clone the dapi-grpc repository
git clone https://github.com/dashpay/platform.git
cd platform/packages/dapi-grpc

## Execute gRPCurl command
grpcurl -plaintext -proto protos/...
```

## Data Encoding

The data submitted/received from the gRPC endpoints is encoded using both [CBOR](https://tools.ietf.org/html/rfc7049) and Base64. Data is first encoded with CBOR and the resulting output is then encoded in Base64 before being sent. 

Canonical encoding is used for state transitions, identities, data contracts, and documents. This puts the object's data fields in a sorted order to ensure the same hash is produced every time regardless of the actual order received by the encoder. Reproducible hashes are necessary to support validation of request/response data.

Libraries such as [`cbor` (JavaScript)](https://www.npmjs.com/package/cbor) and [`cbor2` (Python)](https://pypi.org/project/cbor2/) can be used to encode/decode data for DAPI gRPC endpoints.

The examples below use the response from a [`getIdentity` gPRC request](../reference/dapi-endpoints-platform-endpoints.md#getidentity) to demonstrate how to both encode data for sending and decode received data:

::::{tab-set}
:::{tab-item} NodeJS - Decode Identity
```javascript
const cbor = require('cbor');

const grpc_identity_response = 'o2JpZHgsQ2JZVnlvS25HeGtIYUJydWNDQWhQRUJjcHV6OGoxNWNuWVlpdjFDRUhCTnhkdHlwZQFqcHVibGljS2V5c4GkYmlkAWRkYXRheCxBbXpSMkZNNGZZd0NtWnhHWjFOMnRhMkZmdUo5NU93K0xMQXJaREx1WUJqdGR0eXBlAWlpc0VuYWJsZWT1'

const identity_cbor = Buffer.from(grpc_identity_response, 'base64').toJSON();
const identity = cbor.decode(Buffer.from(identity_cbor));

console.log('Identity details');
console.dir(identity);
```
:::

:::{tab-item} Python - Decode Identity
```python
# Python - Decode Identity
from base64 import b64decode, b64encode
import json
import cbor2

grpc_identity_response = 'o2JpZHgsQ2JZVnlvS25HeGtIYUJydWNDQWhQRUJjcHV6OGoxNWNuWVlpdjFDRUhCTnhkdHlwZQFqcHVibGljS2V5c4GkYmlkAWRkYXRheCxBbXpSMkZNNGZZd0NtWnhHWjFOMnRhMkZmdUo5NU93K0xMQXJaREx1WUJqdGR0eXBlAWlpc0VuYWJsZWT1'

identity_cbor = b64decode(grpc_identity_response)
identity = cbor2.loads(identity_cbor)

print('Identity details:\n{}\n'.format(json.dumps(identity, indent=2)))
```
:::

:::{tab-item} Python - Encode Identity
```python
# Python - Encode Identity
from base64 import b64decode, b64encode
import json
import cbor2

## Encode an identity
identity = {
  "id": "CbYVyoKnGxkHaBrucCAhPEBcpuz8j15cnYYiv1CEHBNx",  
  "type": 1,
  "publicKeys": [
    {
      "id": 1,
      "data": "AmzR2FM4fYwCmZxGZ1N2ta2FfuJ95Ow+LLArZDLuYBjt",
      "type": 1,
      "isEnabled": True
    }
  ]
}

identity_cbor = cbor2.dumps(identity)
identity_grpc = b64encode(identity_cbor)
print('Identity gRPC data: {}'.format(identity_grpc))
```
:::
::::
