#!/usr/bin/env bash
set -e

# clean_filter.sh
# Input: stdin (plaintext)
# Output: stdout (ciphertext)

# Read stdin and encrypt to stdout
# sops --encrypt --input-type binary --output-type binary /dev/stdin
sops --encrypt --input-type binary --output-type binary /dev/stdin
