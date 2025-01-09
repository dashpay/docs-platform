```{eval-rst}
.. _tutorials-building-platform:
```

# Building Dash Platform

The following instructions explain how to prepare Ubuntu to build Dash Platform.

## Install prerequisites

### Linux packages

``` shell
sudo apt install -y build-essential libssl-dev pkg-config clang cmake llvm unzip jq
```

### NodeJS

``` shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 20
```

### Docker

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

### Rust

Execute the following script to install Rust. Use the default options during the setup process.

``` shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Protocol buffers

``` shell
wget https://github.com/protocolbuffers/protobuf/releases/download/v27.3/protoc-27.3-linux-x86_64.zip
sudo unzip protoc-*-linux-x86_64.zip -d /usr/local
```

### WASM CLI

``` shell
cargo install wasm-bindgen-cli@0.2.99
```

### Check versions

Run the following commands to see what version of each package is installed:

``` shell
node --version
docker --version
protoc --version
rustc --version
```

## Build Platform

``` shell
git clone https://github.com/dashpay/platform.git
cd platform/
corepack enable
yarn setup
```
