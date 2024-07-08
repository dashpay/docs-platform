# Quick Start

## Prerequisites

### Install dependencies

Several packages are required to use the Dash SDK. Install them by running:

```shell
# Install required packages
sudo apt-get install clang cmake gcc unzip
# Install recent protobuf version
wget https://github.com/protocolbuffers/protobuf/releases/download/v26.1/protoc-26.1-linux-x86_64.zip
sudo unzip protoc-*-linux-x86_64.zip -d /usr/local
```

### Install Rustup

Rustup is the [recommended tool](https://www.rust-lang.org/tools/install) to install Rust and keep
it updated. To download Rustup and install Rust, run the following in your terminal, then follow the
on-screen instructions:
  
```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

After installation, ensure that your system's environment variables are updated. Restart your
terminal or run:

```shell
. "$HOME/.cargo/env"
```

Check if Rust is installed correctly by running:

```shell
rustc --version
```

You should see the installed version of Rust.

### Install Dash Core

Currently, the SDK is dependent on a Dash Core full node to support proof verification and provide
wallet access. Follow the instructions below to install Dash Core and run it on Testnet. **Note:**
it is possible, although not recommended, to retrieve data from Dash Platform without proof

- [Dash Core installation instructions](inv:user:std#dashcore-installation)
- [Running Dash Core on Testnet](inv:user:std#dashcore-testnet)

Locate the `dash.conf` file by right-clicking the Dash Core icon and selecting `Open Wallet
Configuration File`. Configure it as shown below (replace `<username>` and `<password>` with values
of your choice):

```ini
testnet=1

[test]
server=1
listen=1
rpcallowip=127.0.0.1
rpcuser=<user>
rpcpassword=<password>
```

Restart Dash Core to apply the changes.

> 🚧 **Using Dash Platform without Dash Core**
>
> The Rust SDK requests proofs for all data retrieved from Platform. This makes it the recommended
> (most secure) option, but also is why a Dash Core full node is currently required.
>
> The [JavaScript SDK](../tutorials/introduction.md) provides access to Dash Platform without
> requiring a full node; however, it **_does not support Dash Platform's proofs_**. The Rust DAPI
> client can also perform read operations without a full node if proofs are not requested. See the
> [DAPI client example](#dapi-client-example) below for details.

## Create a new project

Rust comes with a build tool and package manager called Cargo. Use it to create a new project by
running the following command in your terminal. Replacing `dash_project` with your desired project
name:

```shell
cargo new dash_project
```

Change into your new project's directory:

```shell
cd dash_project
```

Add the following dependencies to `Cargo.toml`:

``` toml
[dependencies]
dash-sdk = { git = "https://github.com/dashpay/platform" }
tokio = { version = "1", features = ["full"] }
dapi-grpc = { git = "https://github.com/dashpay/platform", features = ["client",] }
rs-dapi-client = { git = "https://github.com/dashpay/platform" }
dpp = { git = "https://github.com/dashpay/platform", features = ["client",] }
```

Open `src/main.rs` and replace the contents with this code:

```rust
use dash_sdk::{
    platform::{Fetch, Identifier},
    Sdk, SdkBuilder,
};
use dpp::{
    identity::accessors::IdentityGettersV0, platform_value::string_encoding::Encoding,
    prelude::Identity,
};
use rs_dapi_client::{AddressList, Uri};
use std::error::Error;

pub fn setup_sdk() -> Result<Sdk, Box<dyn Error>> {
    let dapi_addresses = "https://52.42.202.128:1443";
    let sdk = SdkBuilder::new(AddressList::from_iter([dapi_addresses.parse::<Uri>()?]))
        .with_core("127.0.0.1", 19998, "user", "pass")
        .build()
        .expect("Failed to build SDK");

    Ok(sdk)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let sdk = setup_sdk()?;

    let identity_id = Identifier::from_string(
        "2rEwrPmMBqdYzFwtofrPd8RtMCotcKFxRoATkqqQeW7P",
        Encoding::Base58,
    )?;

    match Identity::fetch(&sdk, identity_id).await {
        Ok(Some(identity)) => {
            println!("Identity id: {}", identity.id());
            println!("Identity balance: {}", identity.balance());
        }
        Ok(None) => {
            eprintln!("Identity not found: {}", identity_id);
        }
        Err(e) => {
            eprintln!("Error fetching data from Platform: {}", e);
        }
    }

    Ok(())
}
```

Build and run the project:

```shell
cargo run
```

You should see output similar to:

```text
Identity id: 2rEwrPmMBqdYzFwtofrPd8RtMCotcKFxRoATkqqQeW7P
Identity balance: 932523994
```

## SDK documentation

> 🚧 Work in progress
>
> SDK documentation will be available on docs.rs once the Dash SDK crate is published. Meanwhile,
> the [pre-release documentation](https://dashpay.github.io/docs-platform/dash_sdk/) is available
> for reference. Please keep in mind that it is incomplete and may be outdated.

## DAPI client example

This example demonstrates how to retrieve an identity from Dash Platform using the Rust DAPI client.
It does not request or check proofs for the retrieved data, but it does not require a connection to
a Dash Core full node.

Add the following dependencies to `Cargo.toml`:

``` toml
[dependencies]
dash-sdk = { git = "https://github.com/dashpay/platform" }
tokio = { version = "1", features = ["full"] }
dapi-grpc = { git = "https://github.com/dashpay/platform", features = ["client",] }
rs-dapi-client = { git = "https://github.com/dashpay/platform" }
dpp = { git = "https://github.com/dashpay/platform", features = ["client",] }
```

Open `src/main.rs` and replace the contents with this code:

```rust
use dapi_grpc::platform::v0::{
    get_identity_request::GetIdentityRequestV0, get_identity_response::GetIdentityResponseV0,
    get_identity_response::Version as GetIdentityResponseVersion, GetIdentityRequest,
    GetIdentityResponse, ResponseMetadata,
};
use dash_sdk::platform::Identifier;
use dash_sdk::{Sdk, SdkBuilder};
use dpp::platform_value::string_encoding::Encoding;
use rs_dapi_client::{DapiRequest, Uri};
use std::error::Error;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let sdk = SdkBuilder::new(rs_dapi_client::AddressList::from_iter([
        "https://52.42.202.128:1443".parse::<Uri>()?,
    ]))
    .build()
    .expect("Failed to build SDK");

    let identity_id = Identifier::from_string(
        "2rEwrPmMBqdYzFwtofrPd8RtMCotcKFxRoATkqqQeW7P",
        Encoding::Base58,
    )?;

    let result = fetch_identity(identity_id, &sdk).await;
    match result {
        Ok(_) => println!("Identity fetched successfully."),
        Err(e) => eprintln!("Error fetching identity: {:?}", e),
    }

    Ok(())
}

async fn fetch_identity(identity_id: Identifier, sdk: &Sdk) -> Result<(), Box<dyn Error>> {
    let request = GetIdentityRequest {
        version: Some(dapi_grpc::platform::v0::get_identity_request::Version::V0(
            GetIdentityRequestV0 {
                id: identity_id.to_vec(),
                prove: false, // Request data without proof
            },
        )),
    };

    let identity_response = request
        .execute(sdk, rs_dapi_client::RequestSettings::default())
        .await;
    println!("Identity fetch result: {:?}", identity_response);

    match identity_response {
        Ok(GetIdentityResponse {
            version: Some(GetIdentityResponseVersion::V0(GetIdentityResponseV0 {
                result: Some(dapi_grpc::platform::v0::get_identity_response::get_identity_response_v0::Result::Identity(bytes)),
                metadata: Some(ResponseMetadata { protocol_version, .. })
            })),
        }) => {
            println!("Identity bytes: {:?}", bytes);
            println!("Protocol version: {}", protocol_version);
        },
        _ => eprintln!("No identity was received"),
    }

    Ok(())
}
```

Build and run the project:

```shell
cargo run
```

You should see output similar to:

```
Identity fetch result: Ok(GetIdentityResponse { version: Some(V0(GetIdentityResponseV0 { metadata: Some(ResponseMetadata { height: 3545, core_chain_locked_height: 1057533, epoch: 194, time_ms: 1720037818812, protocol_version: 1, chain_id: "dash-testnet-46" }), result: Some(Identity([0, 27, 120, 234, 64, 77, 128, 39, 95, 97, 84, 3, 190, 94, 195, 152, 119, 222, 62, 61, 205, 74, 127, 72, 225, 59, 150, 72, 50, 141, 143, 28, 62, 5, 0, 0, 0, 0, 0, 0, 0, 0, 33, 3, 245, 177, 206, 91, 24, 183, 208, 204, 116, 210, 242, 219, 243, 121, 210, 10, 68, 97, 215, 187, 132, 58, 19, 181, 158, 50, 100, 15, 176, 234, 25, 217, 0, 1, 0, 1, 0, 2, 0, 0, 0, 33, 2, 104, 172, 93, 255, 84, 19, 139, 70, 252, 113, 120, 50, 176, 83, 194, 52, 126, 43, 96, 84, 254, 37, 130, 85, 104, 52, 185, 24, 91, 113, 235, 178, 0, 2, 0, 2, 0, 1, 0, 0, 0, 33, 3, 249, 77, 70, 255, 0, 223, 110, 197, 2, 109, 8, 113, 134, 141, 168, 174, 23, 211, 232, 222, 88, 59, 226, 189, 73, 43, 85, 11, 157, 27, 65, 199, 0, 3, 0, 3, 3, 1, 0, 0, 0, 33, 2, 244, 30, 16, 91, 151, 102, 49, 150, 212, 147, 93, 14, 112, 139, 176, 68, 241, 49, 95, 207, 238, 146, 176, 115, 53, 108, 7, 228, 237, 103, 13, 227, 0, 4, 0, 4, 0, 3, 0, 0, 0, 33, 3, 178, 111, 125, 30, 123, 61, 172, 86, 142, 6, 184, 161, 236, 83, 52, 10, 100, 169, 210, 150, 84, 61, 164, 190, 201, 62, 104, 218, 191, 7, 118, 57, 1, 253, 0, 0, 1, 144, 85, 175, 57, 216, 252, 55, 149, 47, 218, 2])) })) })
Identity bytes: [0, 27, 120, 234, 64, 77, 128, 39, 95, 97, 84, 3, 190, 94, 195, 152, 119, 222, 62, 61, 205, 74, 127, 72, 225, 59, 150, 72, 50, 141, 143, 28, 62, 5, 0, 0, 0, 0, 0, 0, 0, 0, 33, 3, 245, 177, 206, 91, 24, 183, 208, 204, 116, 210, 242, 219, 243, 121, 210, 10, 68, 97, 215, 187, 132, 58, 19, 181, 158, 50, 100, 15, 176, 234, 25, 217, 0, 1, 0, 1, 0, 2, 0, 0, 0, 33, 2, 104, 172, 93, 255, 84, 19, 139, 70, 252, 113, 120, 50, 176, 83, 194, 52, 126, 43, 96, 84, 254, 37, 130, 85, 104, 52, 185, 24, 91, 113, 235, 178, 0, 2, 0, 2, 0, 1, 0, 0, 0, 33, 3, 249, 77, 70, 255, 0, 223, 110, 197, 2, 109, 8, 113, 134, 141, 168, 174, 23, 211, 232, 222, 88, 59, 226, 189, 73, 43, 85, 11, 157, 27, 65, 199, 0, 3, 0, 3, 3, 1, 0, 0, 0, 33, 2, 244, 30, 16, 91, 151, 102, 49, 150, 212, 147, 93, 14, 112, 139, 176, 68, 241, 49, 95, 207, 238, 146, 176, 115, 53, 108, 7, 228, 237, 103, 13, 227, 0, 4, 0, 4, 0, 3, 0, 0, 0, 33, 3, 178, 111, 125, 30, 123, 61, 172, 86, 142, 6, 184, 161, 236, 83, 52, 10, 100, 169, 210, 150, 84, 61, 164, 190, 201, 62, 104, 218, 191, 7, 118, 57, 1, 253, 0, 0, 1, 144, 85, 175, 57, 216, 252, 55, 149, 47, 218, 2]
Protocol version: 1
Identity fetched successfully.
```
