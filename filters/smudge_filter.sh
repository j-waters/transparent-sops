#!/usr/bin/env bash
set -e

# smudge_filter.sh
# Input: stdin (ciphertext)
# Output: stdout (plaintext)

# Strict Mode: We assume input is encrypted. if not, we fail.
# We stream directly from stdin to sops, no temp files needed.
# Bash variables are not used as they cannot safely hold binary data (null bytes).

sops --decrypt --input-type binary --output-type binary /dev/stdin
