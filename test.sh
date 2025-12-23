#!/usr/bin/env bash
set -e

# Test script for transparent-sops

TEST_DIR=$(mktemp -d -t transparent-sops-test.XXXXXX)
INITIAL_DIR=$(pwd)
: "${TOOL_PATH:="$(pwd)/transparent-sops"}"

echo "Running tests in $TEST_DIR"

cleanup() {
    echo "Cleaning up..."
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

cd "$TEST_DIR" || exit 1

# 1. Setup minimal requirements
# Ensure no env vars pollute the test
unset SOPS_AGE_RECIPIENTS
unset SOPS_AGE_KEY_FILE

echo "Generating Age key..."
age-keygen -o key.txt
export SOPS_AGE_KEY_FILE="$TEST_DIR/key.txt"
PUBLIC_KEY=$(grep "public key" key.txt | awk '{print $NF}')

# 2. Initialize Git Repo
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 3. Configure SOPS
cat > .sops.yaml <<EOF
creation_rules:
  - path_regex: .*
    age: $PUBLIC_KEY
EOF

# 4. Initialize transparent-sops
echo "Initializing transparent-sops..."
"$TOOL_PATH" init

# 5. Setup .gitattributes
echo "*.secret filter=sops-crypt diff=sops-crypt" > .gitattributes
git add .gitattributes
git commit -m "Add attributes"

# 6. Test Encryption (Clean Filter)
echo "Testing Encryption..."
echo "This is a secret" > test.secret
git add test.secret

# Check if the blob in git is encrypted
BLOB_HASH=$(git ls-files -s test.secret | awk '{print $2}')
if git cat-file -p "$BLOB_HASH" | grep -q "sops"; then
    echo "SUCCESS: File is encrypted in git index."
else
    echo "FAILURE: File is NOT encrypted in git index."
    git cat-file -p "$BLOB_HASH"
    exit 1
fi

git commit -m "Add secret"

# 7. Test Decryption (Smudge Filter)
echo "Testing Decryption..."
rm test.secret
git checkout test.secret

if grep -q "This is a secret" test.secret; then
    echo "SUCCESS: File was decrypted on checkout."
else
    echo "FAILURE: File was NOT decrypted on checkout."
    cat test.secret
    exit 1
fi

# 8. Test Diff (Diff Filter)
echo "Testing Diff..."
echo "This is a changed secret" > test.secret
# git diff should use the textconv filter to show plaintext diff
# We look for the plaintext diff output
DIFF_OUTPUT=$(git diff)

if echo "$DIFF_OUTPUT" | grep -q "This is a changed secret"; then
    echo "SUCCESS: Git diff shows plaintext content."
else
    echo "FAILURE: Git diff does NOT show plaintext content."
    echo "$DIFF_OUTPUT"
    exit 1
fi

# 9. Test Plaintext Pass-through (Smudge Filter)
echo "Testing Plaintext Rejection (Strict Mode)..."
echo "Not a sops file" > plaintext.txt
# Manually invoke smudge filter to check behavior
# Resolve real path in case TOOL_PATH is a symlink (like in an install)
REAL_TOOL_PATH=$(readlink -f "$TOOL_PATH" || echo "$TOOL_PATH")
if cat plaintext.txt | "$(dirname "$REAL_TOOL_PATH")/filters/smudge_filter.sh" > /dev/null 2>&1; then
    echo "FAILURE: Smudge filter should have failed on plaintext input."
    exit 1
else
    echo "SUCCESS: Smudge filter correctly failed on plaintext input."
fi

echo "ALL TESTS PASSED"
cd "$INITIAL_DIR"
rm -rf "$TEST_DIR"
