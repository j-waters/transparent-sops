#!/usr/bin/env bash

# Unified test runner for transparent-sops

set -e

FAILED_TESTS=()
PASSED_TESTS=()

echo "Running all tests..."

for test_script in tests/*.sh; do
    echo "------------------------------------------------"
    echo "Running $test_script..."
    if ./"$test_script"; then
        PASSED_TESTS+=("$test_script")
    else
        FAILED_TESTS+=("$test_script")
    fi
done

echo "------------------------------------------------"
echo "Test Summary:"
echo "Passed: ${#PASSED_TESTS[@]}"
for t in "${PASSED_TESTS[@]}"; do echo "  - $t"; done

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo "Failed: ${#FAILED_TESTS[@]}"
    for t in "${FAILED_TESTS[@]}"; do echo "  - $t"; done
    exit 1
else
    echo "All tests passed!"
fi
