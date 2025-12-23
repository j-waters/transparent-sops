#!/usr/bin/env bash
set -e

# LS-CRYPT test for transparent-sops

TEST_DIR=$(mktemp -d -t transparent-sops-ls-test.XXXXXX)
INITIAL_DIR=$(pwd)
: "${TOOL_PATH:="$(pwd)/transparent-sops"}"

echo "Running ls-crypt tests in $TEST_DIR"

cleanup() {
    echo "Cleaning up..."
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

cd "$TEST_DIR" || exit 1

# 1. Initialize Git Repo
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 2. Setup .gitattributes
echo "*.secret filter=sops-crypt diff=sops-crypt" > .gitattributes
echo "*.keep filter=other" >> .gitattributes

# 3. Create files
touch normal.txt
touch secret.secret
touch another_secret.secret
touch ignore.keep

git add .

# 4. Test ls-crypt
echo "Testing ls-crypt..."
OUTPUT=$("$TOOL_PATH" ls-crypt)

echo "Output of ls-crypt:"
echo "$OUTPUT"

if echo "$OUTPUT" | grep -q "secret.secret" && echo "$OUTPUT" | grep -q "another_secret.secret"; then
    echo "SUCCESS: Found both secret files."
else
    echo "FAILURE: Did not find secret files or found incorrect ones."
    exit 1
fi

if echo "$OUTPUT" | grep -q "normal.txt" || echo "$OUTPUT" | grep -q "ignore.keep"; then
    echo "FAILURE: Found non-secret files."
    exit 1
fi

echo "LS-CRYPT TEST PASSED"
cd "$INITIAL_DIR"
