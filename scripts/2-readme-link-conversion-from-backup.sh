#!/bin/bash

# Introduction

# Tutorials

# Explanations
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints-platform-endpoints~](\.\./reference/dapi-endpoints-platform-endpoints.md~g' {} +


# Reference
find . -iname "*.md" -exec sed -i 's~](reference-dapi-endpoints~](\.\./reference/dapi-endpoints.md~g' {} +

# Platform Protocol Reference
find . -iname "*.md" -exec sed -i 's~](platform-protocol-reference-data-contract#~](\.\./protocol-ref/data-contract.md#~g' {} +

# Resources

