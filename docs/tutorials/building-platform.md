```{eval-rst}
.. _tutorials-building-platform:
```

# Building Dash Platform

The following instructions explain how to create and run a development build of Dash Platform on Ubuntu. The instructions have been tested on Ubuntu 22.04 and 24.04.

## Install prerequisites

:::{note}
Building and running Dash Platform in a local development mode requires significant storage. A minimum of 30 GB is recommended.
:::

### Linux packages

Install these required build and utility packages:

``` shell
sudo apt install -y build-essential libssl-dev pkg-config clang cmake llvm unzip jq
```

### NodeJS

Install the [Node Version Manager](https://github.com/nvm-sh/nvm) and use it to install NodeJS:

``` shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 20.18
```

### Docker

:::{warning}
Only complete the following steps if you do not already have Docker installed. Otherwise, just make sure you have a version that meets the requirements in the [Platform book's Getting Started section](https://github.com/dashpay/platform/blob/v5.0.1/book/src/getting-started.md).
:::

``` shell
# Remove distribution-provided Docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Install Docker
# See https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://get.docker.com -o get-docker.sh && sh ./get-docker.sh

# Add current user to the docker group to allow use without sudo
sudo usermod -aG docker $USER
newgrp docker
```

### Protocol buffers

``` shell
wget https://github.com/protocolbuffers/protobuf/releases/download/v32.0/protoc-32.0-linux-x86_64.zip
sudo unzip protoc-*-linux-x86_64.zip -d /usr/local
```

### Rust

Execute the following script to install Rust. Use the default options during the setup process.

``` shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
rustup default 1.98.1
```

### WASM CLI

``` shell
cargo install wasm-bindgen-cli@0.2.108
```

:::{note}
The `wasm-bindgen-cli` version must match the `wasm-bindgen` version in the platform repository's `Cargo.lock`, or the build will stop at a version check. Confirm the required version with `grep 'name = "wasm-bindgen"' -A1 Cargo.lock`.
:::

### Check versions

Run the following commands to see what version of each package is installed:

``` shell
node --version
docker --version
docker compose version
protoc --version
rustc --version
wasm-bindgen --version
```

## Configure firewall

If you have the UFW firewall enabled, add rules to allow the required ports:

``` shell
# Core p2p ports
sudo ufw allow 20001
sudo ufw allow 20101
sudo ufw allow 20201
sudo ufw allow 20301
# Platform (Tenderdash) ports
sudo ufw allow 46656
sudo ufw allow 46756
sudo ufw allow 46856
```

Reload UFW to apply the firewall changes:

``` shell
sudo ufw reload
```

## Build Platform

Run the following command to clone the repository:

``` shell
git clone https://github.com/dashpay/platform.git
cd platform/
```

Next, build and complete the initial setup:

``` shell
corepack enable
yarn setup
```

# Running Dash Platform

Run the following command to start Platform. Occasionally, this command will fail on first run. If it fails, run the command again as needed. If the command consistently fails on the same step, further debugging may be required.

``` shell
yarn start
```

## Check endpoint availability

Endpoints can be checked using [gRPCurl](https://github.com/fullstorydev/grpcurl). Install it by running:

``` shell
wget https://github.com/fullstorydev/grpcurl/releases/download/v1.9.3/grpcurl_1.9.3_linux_amd64.deb
sudo apt install ./grpcurl_1.9.3_linux_amd64.deb
```

Core endpoint:

``` shell
grpcurl -insecure -proto packages/dapi-grpc/protos/core/v0/core.proto 127.0.0.1:2443 org.dash.platform.dapi.v0.Core/getBestBlockHeight
```

Platform endpoint:

``` shell
grpcurl -insecure -proto packages/dapi-grpc/protos/platform/v0/platform.proto -d '{ "v0": {} }' 127.0.0.1:2443 org.dash.platform.dapi.v0.Platform/getStatus
```

## Stopping Dash Platform

``` shell
yarn stop
```

If the node is actively participating in a distributed key generation (DKG) session, it will not stop. To force it to stop, run:

``` shell
yarn stop --force
```

# Executing tests

Install Firefox and Chrome:

``` shell
sudo apt install firefox 
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt update
sudo apt install ./google-chrome-stable_current_amd64.deb
```

Run tests with the following command:

``` shell
yarn test
```

# Developer Utilities

## Get Core RPC password

To connect to the Dash Core RPC server (e.g., using the [Dash Evo Tool](inv:user:std#evo-tool)), get the Core RPC password for the `dashmate` user from the dashmate config:

``` shell
yarn dashmate config get core.rpc.users.dashmate --config=local_seed
```

## Remove broken build

:::{warning}
Only use these commands if you are certain your system is not running other Dashmate nodes or Docker services. The commands delete the dashmate configuration and all unused Docker containers, networks, and volumes.
:::

For broken builds that cannot be repaired using `yarn reset`, the following commands will remove Docker and Dashmate data and may allow you to start over with `yarn setup`:

``` shell
docker kill $(docker ps -q) # Stop all running containers
docker volume prune -a      # Removes all unused volumes
docker system prune         # Removes unused Docker data
rm -rf ~/.dashmate          # Deletes the Dashmate configuration
```

## Use JS SDK

To connect to the local network with the [Dash Evo SDK](https://www.npmjs.com/package/@dashevo/evo-sdk), use the `localTrusted()` factory method. It connects to the local network's DAPI and uses the quorum sidecar that `yarn setup` enables on the seed node. See [Connect to a Local Devnet](./connecting-to-testnet.md#connect-to-a-local-devnet) for more detail. Install the SDK with `npm install @dashevo/evo-sdk` and save the example as an `.mjs` file, since it uses ES modules and top-level `await`.

```js
import { EvoSDK } from '@dashevo/evo-sdk';

try {
  const sdk = EvoSDK.localTrusted();
  await sdk.connect();
  const status = await sdk.system.status();
  console.log('Connected. System status:\n', status.toJSON());
} catch (e) {
  console.error('Failed to fetch system status:', e.message);
}
```
