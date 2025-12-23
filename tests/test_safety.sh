#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

setup_test_dir "transparent-sops-safety"
cd "$TEST_DIR" || exit 1

# 1. Initialize Git Repo
setup_git

# 2. Create a dirty file
echo "dirty" > dirty.txt

# 3. Try to initialize
echo "Attempting to initialize with dirty tree..."
if "$TOOL_PATH" init 2>&1 | grep -q "Working tree is not clean"; then
    echo "SUCCESS: Init failed as expected."
else
    echo "FAILURE: Init should have failed due to dirty working tree."
    exit 1
fi

# 4. Commit and try again
git add dirty.txt
git commit -m "Commit dirty file"

echo "Attempting to initialize with clean tree..."
if "$TOOL_PATH" init; then
    echo "SUCCESS: Init succeeded with clean tree."
else
    echo "FAILURE: Init should have succeeded with clean tree."
    exit 1
fi

echo "SAFETY TEST PASSED"
