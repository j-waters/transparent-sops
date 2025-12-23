#!/usr/bin/env bash
set -e

# Clone test for transparent-sops
# This test verifies behavior when cloning a repo already configured with transparent-sops

TEST_DIR=$(mktemp -d -t transparent-sops-clone-test.XXXXXX)
INITIAL_DIR=$(pwd)
: "${TOOL_PATH:="$(pwd)/transparent-sops"}"

echo "Running clone tests in $TEST_DIR"

cleanup() {
    echo "Cleaning up..."
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# 1. Setup minimal requirements
# Ensure no env vars pollute the test
unset SOPS_AGE_RECIPIENTS
unset SOPS_AGE_KEY_FILE

echo "Generating Age key..."
age-keygen -o "$TEST_DIR/key.txt"
export SOPS_AGE_KEY_FILE="$TEST_DIR/key.txt"
PUBLIC_KEY=$(grep "public key" "$TEST_DIR/key.txt" | awk '{print $NF}')

# 2. Setup "Source" Repository
SOURCE_DIR="$TEST_DIR/source-repo"
mkdir -p "$SOURCE_DIR"
cd "$SOURCE_DIR"
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 3. Configure SOPS in source
cat > .sops.yaml <<EOF
creation_rules:
  - path_regex: .*
    age: $PUBLIC_KEY
EOF
git add .sops.yaml
git commit -m "Add .sops.yaml"

# 4. Initialize transparent-sops in source
echo "Initializing transparent-sops in source..."
"$TOOL_PATH" init

# 5. Setup .gitattributes and a secret file
echo "*.secret filter=sops-crypt diff=sops-crypt" > .gitattributes
echo "This is a source secret" > test.secret
git add .gitattributes .sops.yaml test.secret
git commit -m "Initial commit with secret"

# Verify it's encrypted in source git index
BLOB_HASH=$(git ls-files -s test.secret | awk '{print $2}')
if git cat-file -p "$BLOB_HASH" | grep -q "sops"; then
    echo "SUCCESS: File is encrypted in source repo."
else
    echo "FAILURE: File is NOT encrypted in source repo."
    exit 1
fi

# 6. Clone to "Target" Repository
TARGET_DIR="$TEST_DIR/target-repo"
echo "Cloning source to target..."
git clone "$SOURCE_DIR" "$TARGET_DIR"

cd "$TARGET_DIR"
# Note: In a real clone, the user would need to run `transparent-sops init` 
# or have it globally installed and configured. 
# We are testing what happens on a fresh clone.

echo "Checking test.secret in cloned repo..."
if grep -q "This is a source secret" test.secret; then
    echo "SUCCESS: File was decrypted on clone (Wait, how? Did the filters run implicitly?)"
else
    echo "FAILURE: File remains encrypted on clone (This is the expected failure if init hasn't been run)."
    cat test.secret
fi

# 7. Try to "fix" the clone by running init
echo "Running init in cloned repo..."
"$TOOL_PATH" init
# After init, tools should have automatically decrypted the files!

echo "Checking test.secret after init..."
if grep -q "This is a source secret" test.secret; then
    echo "SUCCESS: File is decrypted automatically after init."
else
    echo "FAILURE: File is still encrypted after init, even though it should have been auto-decrypted."
    cat test.secret
    exit 1
fi

echo "CLONE TEST COMPLETED"
cd "$INITIAL_DIR"
