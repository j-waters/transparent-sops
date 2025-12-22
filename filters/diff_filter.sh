#!/usr/bin/env bash
set -e

# diff_filter.sh
# Input: file path (ciphertext)
# Output: stdout (plaintext)

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

# Strict Mode note: For diffs, we often compare the encrypted HEAD version (which decrypts fine)
# against the local plaintext worktree version (which fails decryption).
# To make `git diff` usable, we MUST fall back to 'cat' if decryption fails.

if sops --decrypt --input-type binary --output-type binary "$FILE_PATH" 2>/dev/null; then
    : # Success
else
    cat "$FILE_PATH"
fi
