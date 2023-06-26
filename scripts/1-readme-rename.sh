#!/bin/bash

RENAME_ARGS="-d"

find docs/explanations -iname "*.md" -type f -name 'explanation-*' -print0 | xargs -0 rename $RENAME_ARGS 's/explanation-//'
find docs/intro -iname "*.md" -type f -name 'introduction-*' -print0 | xargs -0 rename $RENAME_ARGS 's/introduction-//'
find docs/intro -iname "*.md" -type f -name 'intro-*' -print0 | xargs -0 rename $RENAME_ARGS 's/intro-//'
find docs/protocol-ref -iname "*.md" -type f -name 'platform-protocol-reference-*' -print0 | xargs -0 rename $RENAME_ARGS 's/platform-protocol-reference-//'
find docs/reference -iname "*.md" -type f -name 'reference-*' -print0 | xargs -0 rename $RENAME_ARGS 's/reference-//'
find docs/resources -iname "*.md" -type f -name 'resources-*' -print0 | xargs -0 rename $RENAME_ARGS 's/resources-//'
find docs/tutorials -iname "*.md" -type f -name 'tutorials-*' -print0 | xargs -0 rename $RENAME_ARGS 's/tutorials-//'
find docs/tutorials -iname "*.md" -type f -name 'tutorial-*' -print0 | xargs -0 rename $RENAME_ARGS 's/tutorial-//'
