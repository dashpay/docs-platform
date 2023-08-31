#!/bin/bash

RENAME_ARGS="-d"

find docs/dapi-client-js -iname "*.md" -type f -name 'dapi-client-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dapi-client-//'
find docs/dapi-client-js/usage -iname "*.md" -type f -name 'usage-*' -print0 | xargs -0 rename $RENAME_ARGS 's/usage-//'
find docs/explanations -iname "*.md" -type f -name 'explanation-*' -print0 | xargs -0 rename $RENAME_ARGS 's/explanation-//'
find docs/intro -iname "*.md" -type f -name 'introduction-*' -print0 | xargs -0 rename $RENAME_ARGS 's/introduction-//'
find docs/intro -iname "*.md" -type f -name 'intro-*' -print0 | xargs -0 rename $RENAME_ARGS 's/intro-//'
find docs/protocol-ref -iname "*.md" -type f -name 'platform-protocol-reference-*' -print0 | xargs -0 rename $RENAME_ARGS 's/platform-protocol-reference-//'
find docs/reference -iname "*.md" -type f -name 'reference-*' -print0 | xargs -0 rename $RENAME_ARGS 's/reference-//'
find docs/resources -iname "*.md" -type f -name 'resources-*' -print0 | xargs -0 rename $RENAME_ARGS 's/resources-//'
find docs/sdk-js -iname "*.md" -type f -name 'dash-sdk-overview*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-//'
find docs/sdk-js/examples -iname "*.md" -type f -name 'dash-sdk-examples-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-examples-//'
find docs/sdk-js/getting-started -iname "*.md" -type f -name 'dash-sdk-getting-started-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-getting-started-//'
find docs/sdk-js/platform -iname "*.md" -type f -name 'dash-sdk-contracts-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-contracts-//'
find docs/sdk-js/platform -iname "*.md" -type f -name 'dash-sdk-documents-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-documents-//'
find docs/sdk-js/platform -iname "*.md" -type f -name 'dash-sdk-identities-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-identities-//'
find docs/sdk-js/platform -iname "*.md" -type f -name 'dash-sdk-names-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-names-//'
find docs/sdk-js/usage -iname "*.md" -type f -name 'dash-sdk-usage-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-usage-//'
find docs/sdk-js/wallet -iname "*.md" -type f -name 'dash-sdk-wallet-*' -print0 | xargs -0 rename $RENAME_ARGS 's/dash-sdk-wallet-//'
find docs/tutorials -iname "*.md" -type f -name 'tutorials-*' -print0 | xargs -0 rename $RENAME_ARGS 's/tutorials-//'
find docs/tutorials -iname "*.md" -type f -name 'tutorial-*' -print0 | xargs -0 rename $RENAME_ARGS 's/tutorial-//'
