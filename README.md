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

### Homebrew (macOS/Linux)

You can install `transparent-sops` via my custom Homebrew tap:

```bash
brew install j-waters/tap/transparent-sops
```

### From Source (Makefile)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/j-waters/transparent-sops.git
   cd transparent-sops
   ```

2. **Install via Makefile**:
   ```bash
   sudo make install
   ```

### From Source (Manual)

```bash
curl -Lo transparent-sops https://raw.githubusercontent.com/j-waters/transparent-sops/main/transparent-sops
sudo install -m 755 transparent-sops /usr/local/bin/transparent-sops
rm transparent-sops
```

## Usage

1. **Initialize**: In any repo you want to use this with:
   ```bash
   transparent-sops init
   ```

2. **Configure Keys**: Ensure you have a valid `.sops.yaml` in your repository root and that you have access to the valid keys (e.g., export `SOPS_AGE_KEY_FILE`).

3. **Track Files**: Add patterns to your `.gitattributes` file using the `sops-crypt` filter and diff driver.

```gitattributes
# Encrypt all .env files
.env filter=sops-crypt diff=sops-crypt

# Encrypt specific secrets
config/prod.yaml.secret filter=sops-crypt diff=sops-crypt
```

4. **Work as Usual**:
    - `git add`: Files are automatically encrypted.
    - `git checkout`: Files are automatically decrypted.
    - `git diff`: Shows plaintext diffs.

5. **List Encrypted Files**:
   ```bash
   transparent-sops ls-crypt
   ```
   Lists all files in the current repository that are being tracked by the `sops-crypt` filter.

## Uninstall

To remove the git configuration settings:

```bash
transparent-sops uninstall
```

Note that this will remove the git configuration settings from the current repository, 
but will not uninstall the tool from your system or remove any filters from your 
`.gitattributes` file.

## How it Works

- **Clean Filter** (`git add`): Streams file content to `sops --encrypt`.
- **Smudge Filter** (`git checkout`): Streams encrypted content to `sops --decrypt`. **Strict Safe**: Fails if decryption fails.
- **Diff Filter** (`git diff`): Decrypts temporary blobs for display. Falls back to raw content if decryption fails (e.g., comparing against a plaintext worktree file).

# Development

## Testing

```bash
make test
# or
./test.sh
```

## Release Process

Releases are automated via GitHub Actions.

1.  **Tag a new version**:
    ```bash
    git tag v0.1.0
    git push origin v0.1.0
    ```

2.  **Automation**:
    - The `Release` workflow creates a GitHub Release.
    - It automatically creates a PR to bump the Homebrew formula in the `j-waters/homebrew-tap` repository.
