#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

setup_test_dir "transparent-sops-clone"

# 1. Setup minimal requirements
setup_age

# 2. Setup "Source" Repository
SOURCE_DIR="$TEST_DIR/source-repo"
mkdir -p "$SOURCE_DIR"
cd "$SOURCE_DIR"
setup_git

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
