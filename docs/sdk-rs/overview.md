# Overview

Dash Platform is a Layer 2 cryptocurrency technology that builds upon the Dash layer 1 network. The
Rust SDK provides an abstraction layer to simplify usage of the Dash Platform along with data models
based on the Dash Platform Protocol (DPP).

See the [Quick Start page](quick-start.md) for example setup and use of the SDK.

## Usage

### Cargo.toml

To use this crate, define it as a dependency in your `Cargo.toml`:

```toml
[dependencies]

dash-sdk = { git="https://github.com/dashpay/platform" }
```

### Examples

You can inspect tests in the
[`tests/`](https://github.com/dashpay/platform/tree/v1.0-dev/packages/rs-sdk/tests/) folder for
detailed examples or see a simple example in the
[`examples/`](https://github.com/dashpay/platform/tree/v1.0-dev/packages/rs-sdk/examples) folder.
See the [Platform Terminal User Interface (TUI)](https://github.com/dashpay/platform-tui/) for an
application that uses the SDK to execute various state transitions.

:::{attention}
SDK documentation will be available on docs.rs once the Dash SDK crate is published. Meanwhile,
the [pre-release documentation](https://dashpay.github.io/docs-platform/dash_sdk/) is available
for reference. Please keep in mind that it is incomplete and may be outdated.
:::

### Mocking

The Dash Platform SDK supports mocking through the `mocks` feature which provides a convenient way
to define mock expectations and use the SDK without a connection to Platform.

You can see examples of mocking in
[mock_fetch.rs](https://github.com/dashpay/platform/blob/master/packages/rs-sdk/tests/fetch/mock_fetch.rs)
and
[mock_fetch_many.rs](https://github.com/dashpay/platform/blob/master/packages/rs-sdk/tests/fetch/mock_fetch_many.rs).
