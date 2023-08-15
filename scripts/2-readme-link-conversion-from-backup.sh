#!/bin/bash

# Introduction

# Tutorials

# Explanations


# Reference
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints-core-grpc-endpoints~](\.\./reference/dapi-endpoints-core-grpc-endpoints.md~g' {} +
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints-grpc-overview~](\.\./reference/dapi-endpoints-grpc-overview.md~g' {} +
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints-json-rpc-endpoints~](\.\./reference/dapi-endpoints-json-rpc-endpoints.md~g' {} +
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints-platform-endpoints~](\.\./reference/dapi-endpoints-platform-endpoints.md~g' {} +
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints~](\.\./reference/dapi-endpoints.md~g' {} +

# Platform Protocol Reference
find . -iname "*.md" -exec sed -i 's~](platform-protocol-reference-data-contract#~](\.\./protocol-ref/data-contract.md#~g' {} +

# Resources

