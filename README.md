# Transparent SOPS Git Encryption

A transparent git encryption tool using [SOPS](https://github.com/getsops/sops).
Inspired by `git-crypt` and `transcrypt`.

## Features

- **Transparent Encryption**: Files are encrypted on `git add` and decrypted on `git checkout`.
- **Git Diff Support**: View cleartext diffs of encrypted files using `git diff`.
- **Strict Mode**: Ensures safety by failing if files matching the pattern cannot be decrypted (prevents accidental plaintext commits or corrupted states).
- **Standard SOPS**: Uses your existing `.sops.yaml` configuration.


## Requirements

- **Bash**
- **Git**
- **SOPS**: Version 3.0+ (Must support `--input-type binary`).
- **Key Management**: Age, GPG, or a cloud provider KMS configured in your environment.

## Installation

#### Homebrew (macOS/Linux)

You can install `transparent-sops` via a custom Homebrew tap:

```bash
# Add the tap
brew tap jcwaters/transparent-sops

# Install the tool
brew install transparent-sops
```

#### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/jcwaters/transparent-sops.git
   cd transparent-sops
   ```
2. Run installation:
   ```bash
   ./sops-crypt init
   ```

## Usage

1. **Initialize**: In any repo you want to use this with:
   ```bash
   sops-crypt init
   ```

2. **Configure Keys**: Ensure you have a valid `.sops.yaml` in your repository root and that you have access to the valid keys (e.g., export `SOPS_AGE_KEY_FILE`).

3. **Track Files**: Add patterns to your `.gitattributes` file using the `sops-crypt` filter and diff driver.

```gitattributes
# Encrypt all .env files
.env filter=sops-crypt diff=sops-crypt

# Encrypt specific secrets
config/prod.yaml.secret filter=sops-crypt diff=sops-crypt
```

3. **Work as Usual**:
    - `git add`: Files are automatically encrypted.
    - `git checkout`: Files are automatically decrypted.
    - `git diff`: Shows plaintext diffs.

## Uninstall

To remove the git configuration settings:

```bash
sops-crypt uninstall
```

## How it Works

- **Clean Filter** (`git add`): Streams file content to `sops --encrypt`.
- **Smudge Filter** (`git checkout`): Streams encrypted content to `sops --decrypt`. **Strict Safe**: Fails if decryption fails.
- **Diff Filter** (`git diff`): Decrypts temporary blobs for display. Falls back to raw content if decryption fails (e.g., comparing against a plaintext worktree file).

# Development

## Release Process

Releases are automated via GitHub Actions.

1.  **Tag a new version**:
    ```bash
    git tag v0.1.0
    git push origin v0.1.0
    ```

2.  **Automation**:
    - The `Release` workflow creates a GitHub Release with source archives.
    - It sends the new version's SHA256 sum to the Homebrew Formula in this repository.
    - It commits the updated `Formula/transparent-sops.rb` back to the `main` branch.
