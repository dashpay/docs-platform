#!/bin/bash

# This script converts the readme.io link to one that will work with ReadTheDocs
#
# The format here is:
# 's~](<this is the old link from readme.io>~](\.\./<this is the directory in the repo containing the file>/<this is the actual filename in the repo>~g'
#
# So in this example: 's~](reference-dapi-endpoints-core-grpc-endpoints~](\.\./reference/dapi-endpoints-core-grpc-endpoints.md~g'
# The repo directory is "reference"
# And the file in that repository is "dapi-endpoints-core-grpc-endpoints.md"

# Directory-specific changes
#
# These need to be done first because they work on specific directories. This is necessary because
# tutorials have a sub-directory so links in them need to go up 2 levels (../../) to get to the
# right location.

# Reference
find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](reference-glossary~](\.\./\.\./reference/glossary.md~g' {} +
find ./docs/tutorials/node-setup -iname "*.md" -exec sed -i 's~](reference-glossary~](\.\./\.\./reference/glossary.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](reference-data-contracts~](\.\./\.\./reference/data-contracts.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](reference-query-syntax~](\.\./\.\./reference/query-syntax.md~g' {} +

# Explanation
find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](explanation-dpns~](\.\./\.\./explanations/dpns.md~g' {} +
find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](explanation-identity~](\.\./\.\./explanations/identity.md~g' {} +
find ./docs/tutorials/node-setup -iname "*.md" -exec sed -i 's~](docs/explanation-identity~](\.\./\.\./explanations/identity.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](explanation-dapi~](\.\./\.\./explanations/dapi.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](explanation-platform-protocol-data-contract~](\.\./\.\./explanations/platform-protocol-data-contract.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](explanation-platform-protocol-state-transition~](\.\./\.\./explanations/platform-protocol-state-transition.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](explanation-platform-protocol-document~](\.\./\.\./explanations/platform-protocol-document.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](explanation-platform-protocol-data-trigger~](\.\./\.\./explanations/platform-protocol-data-trigger.md~g' {} +

# Tutorials
find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](tutorials-introduction#~](\.\./\.\./tutorials/introduction.md#~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](tutorials-introduction#~](\.\./\.\./tutorials/introduction.md#~g' {} +
find ./docs/tutorials/node-setup -iname "*.md" -exec sed -i 's~](tutorials-introduction~](\.\./\.\./tutorials/introduction.md~g' {} +

find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](tutorial-create-and-fund-a-wallet~](\.\./\.\./tutorials/create-and-fund-a-wallet.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](tutorial-create-and-fund-a-wallet~](\.\./\.\./tutorials/create-and-fund-a-wallet.md~g' {} +
find ./docs/tutorials/node-setup -iname "*.md" -exec sed -i 's~](doc:tutorial-create-and-fund-a-wallet~](\.\./\.\./tutorials/create-and-fund-a-wallet.md~g' {} +

find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](tutorial-register-an-identity~](\.\./\.\./tutorials/identities-and-names/register-an-identity.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](tutorial-register-an-identity~](\.\./\.\./tutorials/identities-and-names/register-an-identity.md~g' {} +
find ./docs/tutorials/identities-and-names -iname "*.md" -exec sed -i 's~](tutorial-register-a-name-for-an-identity~](\.\./\.\./tutorials/identities-and-names/register-a-name-for-an-identity.md~g' {} +

find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](tutorial-submit-documents~](\.\./\.\./tutorials/contracts-and-documents/submit-documents.md~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](tutorial-register-a-data-contract#section-code~](\.\./\.\./tutorials/contracts-and-documents/register-a-data-contract.md#code~g' {} +
find ./docs/tutorials/contracts-and-documents -iname "*.md" -exec sed -i 's~](tutorial-register-a-data-contract~](\.\./\.\./tutorials/contracts-and-documents/register-a-data-contract.md~g' {} +
find ./docs/tutorials/node-setup -iname "*.md" -exec sed -i 's~](tutorial-connecting-to-testnet~](\.\./\.\./tutorials/connecting-to-testnet.md~g' {} +


# General changes (apply to all files in the project)

# Introduction


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

