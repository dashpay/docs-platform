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

:::{admonition} **Using Dash Platform without Dash Core**
:class: attention
The Rust SDK requests proofs for all data retrieved from Platform. This makes it the recommended
(most secure) option, but also is why a Dash Core full node is currently required.

The [JavaScript SDK](../tutorials/introduction.md) provides access to Dash Platform without
requiring a full node; however, it **_does not support Dash Platform's proofs_**. The Rust DAPI
client can also perform read operations without a full node if proofs are not requested. See the
[DAPI client example](#dapi-client-example) below for details.
:::

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
dpp = { git = "https://github.com/dashpay/platform", features = ["client",] }
rs-dapi-client = { git = "https://github.com/dashpay/platform" }
tokio = { version = "1", features = ["full"] }
```

Open `src/main.rs` and replace the contents with this code:

```rust
use dash_sdk::{
    platform::{Fetch, Identifier},
    sdk::Uri,
    Sdk, SdkBuilder,
};
use dpp::{
    identity::accessors::IdentityGettersV0, platform_value::string_encoding::Encoding,
    prelude::Identity,
};
use rs_dapi_client::AddressList;
use std::error::Error;

pub fn setup_sdk() -> Result<Sdk, Box<dyn Error>> {
    let dapi_addresses = "https://52.42.202.128:1443";
    let sdk = SdkBuilder::new(AddressList::from_iter([dapi_addresses.parse::<Uri>()?]))
        // Update the username and password parameters to match your Core dash.conf values
        .with_core("127.0.0.1", 19998, "user", "pass")
        .build()
        .expect("Failed to build SDK");

    Ok(sdk)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let sdk = setup_sdk()?;

    let identity_id = Identifier::from_string(
        // Replace with the ID of a previously created identity
        "HiCs4fEtVPQgGETMR5Fy8TnXmidPCV7YqhiH19Q6z8Kf",
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
Identity id: HiCs4fEtVPQgGETMR5Fy8TnXmidPCV7YqhiH19Q6z8Kf
Identity balance: 932523994
```

## SDK documentation

:::{attention}
SDK documentation will be available on docs.rs once the Dash SDK crate is published. Meanwhile,
the [pre-release documentation](https://dashpay.github.io/docs-platform/dash_sdk/) is available
for reference. Please keep in mind that it is incomplete and may be outdated.
:::

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
        // Replace with the ID of a previously created identity
        "HiCs4fEtVPQgGETMR5Fy8TnXmidPCV7YqhiH19Q6z8Kf",
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

```text
Identity fetch result: Ok(GetIdentityResponse { version: Some(V0(GetIdentityResponseV0 { metadata: Some(ResponseMetadata { height: 2708, core_chain_locked_height: 1069713, epoch: 141, time_ms: 1721747660363, protocol_version: 1, chain_id: "dash-testnet-47" }), result: Some(Identity([0, 248, 73, 55, 187, 179, 2, 208, 226, 193, 60, 251, 127, 202, 201, 181, 51, 29, 158, 220, 75, 231, 210, 170, 54, 27, 19, 61, 159, 186, 248, 97, 206, 5, 0, 0, 0, 0, 0, 0, 0, 0, 33, 3, 119, 203, 119, 226, 18, 167, 211, 196, 50, 203, 3, 117, 225, 31, 76, 160, 111, 140, 92, 52, 83, 2, 96, 212, 249, 71, 123, 87, 205, 27, 192, 182, 0, 1, 0, 1, 0, 2, 0, 0, 0, 33, 3, 56, 77, 243, 20, 16, 105, 69, 199, 84, 119, 140, 151, 231, 62, 18, 193, 89, 84, 185, 46, 126, 190, 107, 62, 183, 53, 188, 133, 165, 16, 151, 154, 0, 2, 0, 2, 0, 1, 0, 0, 0, 33, 2, 208, 58, 73, 170, 43, 52, 241, 248, 142, 48, 230, 54, 102, 106, 97, 182, 10, 206, 0, 55, 247, 88, 45, 205, 119, 209, 194, 234, 99, 203, 147, 8, 0, 3, 0, 3, 3, 1, 0, 0, 0, 33, 3, 84, 46, 195, 16, 171, 134, 40, 27, 101, 183, 31, 2, 16, 139, 184, 51, 3, 58, 166, 201, 181, 27, 217, 255, 58, 198, 35, 61, 29, 76, 211, 97, 0, 4, 0, 4, 0, 3, 0, 0, 0, 33, 3, 175, 53, 236, 245, 214, 227, 67, 39, 97, 215, 166, 6, 153, 198, 188, 132, 160, 227, 138, 114, 206, 39, 232, 215, 38, 230, 130, 85, 129, 71, 90, 153, 1, 253, 0, 0, 1, 144, 219, 194, 139, 188, 252, 59, 62, 20, 78, 2])) })) })
Identity bytes: [0, 248, 73, 55, 187, 179, 2, 208, 226, 193, 60, 251, 127, 202, 201, 181, 51, 29, 158, 220, 75, 231, 210, 170, 54, 27, 19, 61, 159, 186, 248, 97, 206, 5, 0, 0, 0, 0, 0, 0, 0, 0, 33, 3, 119, 203, 119, 226, 18, 167, 211, 196, 50, 203, 3, 117, 225, 31, 76, 160, 111, 140, 92, 52, 83, 2, 96, 212, 249, 71, 123, 87, 205, 27, 192, 182, 0, 1, 0, 1, 0, 2, 0, 0, 0, 33, 3, 56, 77, 243, 20, 16, 105, 69, 199, 84, 119, 140, 151, 231, 62, 18, 193, 89, 84, 185, 46, 126, 190, 107, 62, 183, 53, 188, 133, 165, 16, 151, 154, 0, 2, 0, 2, 0, 1, 0, 0, 0, 33, 2, 208, 58, 73, 170, 43, 52, 241, 248, 142, 48, 230, 54, 102, 106, 97, 182, 10, 206, 0, 55, 247, 88, 45, 205, 119, 209, 194, 234, 99, 203, 147, 8, 0, 3, 0, 3, 3, 1, 0, 0, 0, 33, 3, 84, 46, 195, 16, 171, 134, 40, 27, 101, 183, 31, 2, 16, 139, 184, 51, 3, 58, 166, 201, 181, 27, 217, 255, 58, 198, 35, 61, 29, 76, 211, 97, 0, 4, 0, 4, 0, 3, 0, 0, 0, 33, 3, 175, 53, 236, 245, 214, 227, 67, 39, 97, 215, 166, 6, 153, 198, 188, 132, 160, 227, 138, 114, 206, 39, 232, 215, 38, 230, 130, 85, 129, 71, 90, 153, 1, 253, 0, 0, 1, 144, 219, 194, 139, 188, 252, 59, 62, 20, 78, 2]
Protocol version: 1
Identity fetched successfully.
```
