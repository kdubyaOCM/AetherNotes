# Secrets Policy — AetherNotes

## 1. No Plaintext Secrets

Secrets (API keys, tokens, passwords, PEM private keys) must **never** appear in:

- Source code, including test fixtures
- Documentation or `Docs/` files
- Log output (use redaction; never log full keys)
- SwiftData, UserDefaults, or on-disk files

## 2. In-App Secret Storage

Use **Secure Enclave** (where available) combined with **Keychain** access control and envelope encryption.
Refer to `Docs/ADR/` for architecture decisions on key management.

## 3. Secret Scanning CI

A GitHub Actions workflow (`.github/workflows/secret-scan.yml`) runs on every push and pull request. It executes `.github/scripts/secret_scan.py` to scan all tracked text files for patterns that look like secrets.

### Detected patterns

| Rule | Example | Pattern |
|---|---|---|
| OpenAI-style key | `sk-abc123…` | `\bsk-[A-Za-z0-9]{20,}\b` |
| Anthropic-style key | `sk-ant-abc123…` | `\bsk-ant-[A-Za-z0-9_-]{20,}\b` |
| Generic API key assignment | `API_KEY = "…"` | `(API_KEY\|APIKEY\|SECRET\|TOKEN)\s*=\s*['"][^'"]{12,}['"]` |
| PEM private key header | `-----BEGIN RSA KEY-----` | `-----BEGIN (RSA\|EC\|OPENSSH\|PRIVATE) KEY-----` | <!-- secretscan:ignore -->
| AWS access key ID | `AKIAIOSFODNN7EXAMPLE` | `\bAKIA[0-9A-Z]{16}\b` | <!-- secretscan:ignore -->

### How it works

1. The scanner lists all git-tracked files.
2. Binary files and common build directories (`.git`, `DerivedData`, `.build`, `.swiftpm`, `Pods`, `Carthage`, `fastlane`, `node_modules`, `.xcassets`) and binary extensions (`.png`, `.jpg`, `.zip`, `.pdf`, `.xcarchive`) are skipped.
3. Each remaining file is scanned line by line against the patterns above.
4. If any match is found, the CI job fails with a readable report showing file, line number, rule name, and a redacted match.

## 4. Suppressing False Positives

### Inline suppression

Add the exact comment `secretscan:ignore` anywhere on the line to suppress all matches on that line:

```swift
let placeholder = "sk-test00000000000000000000" // secretscan:ignore
```

### Allowlist file

Create or edit `.github/scripts/secret_scan_allowlist.txt`. Each non-empty, non-comment line is a regex. If a detected match is **fully matched** by any allowlist regex, it is suppressed.

```text
# Allow the AWS example key used in documentation
AKIAIOSFODNN7EXAMPLE  # secretscan:ignore
```

Lines starting with `#` are comments and are ignored.

## 5. What To Do If the Scanner Flags Something

1. **If it is a real secret** — rotate the secret immediately, remove it from the code, and store it in a secure vault (Keychain / environment variable / CI secret).
2. **If it is a false positive** — add an inline `secretscan:ignore` comment or add an entry to the allowlist file, then push again.
3. **If you are unsure** — ask the team in the PR before merging.

## 6. Running Locally

```bash
# Scan the repo
python3 .github/scripts/secret_scan.py --mode local

# Run the built-in self-test
python3 .github/scripts/secret_scan.py --mode selftest
```
