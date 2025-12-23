#!/usr/bin/env bash

# Common setup for transparent-sops tests

INITIAL_DIR=$(pwd)
: "${TOOL_PATH:="$(pwd)/transparent-sops"}"

setup_test_dir() {
    local prefix="${1:-transparent-sops-test}"
    TEST_DIR=$(mktemp -d -t "${prefix}.XXXXXX")
    echo "Running tests in $TEST_DIR"
    trap 'cleanup' EXIT
}

cleanup() {
    echo "Cleaning up..."
    cd "$INITIAL_DIR"
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

setup_git() {
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
}

setup_age() {
    # Ensure no env vars pollute the test
    unset SOPS_AGE_RECIPIENTS
    unset SOPS_AGE_KEY_FILE
    
    echo "Generating Age key..."
    age-keygen -o "$TEST_DIR/key.txt"
    export SOPS_AGE_KEY_FILE="$TEST_DIR/key.txt"
    PUBLIC_KEY=$(grep "public key" "$TEST_DIR/key.txt" | awk '{print $NF}')
}
