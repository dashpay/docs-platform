#!/bin/bash

# This script converts the readme.io link to one that will work with ReadTheDocs
#
# The format here is:
# 's~](<this is the old link from readme.io>~](\.\./<this is the directory in the repo containing the file>/<this is the actual filename in the repo>~g'
#
# So in this example: 's~](reference-dapi-endpoints-core-grpc-endpoints~](\.\./reference/dapi-endpoints-core-grpc-endpoints.md~g'
# The repo directory is "reference"
# And the file in that repository is "dapi-endpoints-core-grpc-endpoints.md"

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

