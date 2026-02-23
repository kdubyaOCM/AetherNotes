#!/usr/bin/env python3
"""Secret scanner for AetherNotes CI.

Scans tracked text files for likely secrets and fails if any are found.

Usage:
    python3 .github/scripts/secret_scan.py --mode ci       # CI mode (scan repo)
    python3 .github/scripts/secret_scan.py --mode local    # local mode (scan repo)
    python3 .github/scripts/secret_scan.py --mode selftest # run in-memory self-tests
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import List, NamedTuple, Optional

# ---------------------------------------------------------------------------
# Patterns
# ---------------------------------------------------------------------------

RULES: list[tuple[str, re.Pattern[str]]] = [
    ("OpenAI-style key", re.compile(r"\bsk-[A-Za-z0-9]{20,}\b")),
    ("Anthropic-style key", re.compile(r"\bsk-ant-[A-Za-z0-9_-]{20,}\b")),
    (
        "Generic API key assignment",
        re.compile(r"(API_KEY|APIKEY|SECRET|TOKEN)\s*=\s*['\"][^'\"]{12,}['\"]"),
    ),
    ("PEM private key header", re.compile(r"-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----")),
    ("AWS access key ID", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
]

INLINE_SUPPRESSION = "secretscan:ignore"

# Directories and extensions to skip
SKIP_DIRS: set[str] = {
    ".git",
    "DerivedData",
    ".build",
    ".swiftpm",
    "Pods",
    "Carthage",
    "fastlane",
    "node_modules",
    ".xcassets",
}

SKIP_EXTENSIONS: set[str] = {".png", ".jpg", ".zip", ".pdf", ".xcarchive"}

ALLOWLIST_PATH = Path(".github/scripts/secret_scan_allowlist.txt")

# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------


class Finding(NamedTuple):
    file: str
    line: int
    rule: str
    matched: str


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def redact(value: str) -> str:
    """Show first 4 and last 4 characters, mask the rest."""
    if len(value) <= 8:
        return value[:2] + "***" + value[-2:]
    return value[:4] + "***" + value[-4:]


def load_allowlist(repo_root: Path) -> list[re.Pattern[str]]:
    """Load allowlist regexes from the allowlist file."""
    path = repo_root / ALLOWLIST_PATH
    if not path.is_file():
        return []
    patterns: list[re.Pattern[str]] = []
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        patterns.append(re.compile(line))
    return patterns


def is_allowlisted(match_text: str, allowlist: list[re.Pattern[str]]) -> bool:
    """Return True if the matched text is fully matched by any allowlist regex."""
    for pat in allowlist:
        if pat.fullmatch(match_text):
            return True
    return False


def should_skip_path(path: str) -> bool:
    """Return True if the path should be skipped."""
    parts = Path(path).parts
    for part in parts:
        if part in SKIP_DIRS:
            return True
    ext = Path(path).suffix.lower()
    if ext in SKIP_EXTENSIONS:
        return True
    return False


def is_binary(filepath: Path) -> bool:
    """Heuristic: read a small chunk and check for null bytes."""
    try:
        chunk = filepath.read_bytes()[:8192]
        return b"\x00" in chunk
    except (OSError, PermissionError):
        return True


def tracked_files(repo_root: Path) -> list[str]:
    """Return list of git-tracked files."""
    result = subprocess.run(
        ["git", "ls-files"],
        capture_output=True,
        text=True,
        cwd=repo_root,
    )
    return [f for f in result.stdout.splitlines() if f]


def scan_file(
    filepath: Path, relative: str, allowlist: list[re.Pattern[str]]
) -> list[Finding]:
    """Scan a single file for secrets."""
    findings: list[Finding] = []
    try:
        text = filepath.read_text(errors="replace")
    except (OSError, PermissionError):
        return findings

    for line_no, line in enumerate(text.splitlines(), start=1):
        if INLINE_SUPPRESSION in line:
            continue
        for rule_name, pattern in RULES:
            for m in pattern.finditer(line):
                matched = m.group(0)
                if is_allowlisted(matched, allowlist):
                    continue
                findings.append(Finding(relative, line_no, rule_name, matched))
    return findings


def scan_repo(repo_root: Path) -> list[Finding]:
    """Scan all tracked text files in the repo."""
    allowlist = load_allowlist(repo_root)
    findings: list[Finding] = []

    for rel_path in tracked_files(repo_root):
        if should_skip_path(rel_path):
            continue
        full_path = repo_root / rel_path
        if not full_path.is_file():
            continue
        if is_binary(full_path):
            continue
        findings.extend(scan_file(full_path, rel_path, allowlist))

    return findings


def print_findings(findings: list[Finding]) -> None:
    """Print findings in a human-readable format."""
    print(f"\n{'='*70}")
    print(f"  Secret scan found {len(findings)} potential secret(s)")
    print(f"{'='*70}\n")
    for f in findings:
        print(f"  File:    {f.file}")
        print(f"  Line:    {f.line}")
        print(f"  Rule:    {f.rule}")
        print(f"  Match:   {redact(f.matched)}")
        print()


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------


def run_selftest() -> int:
    """Run in-memory self-tests against sample strings."""
    samples: list[tuple[str, str, bool]] = [
        ("OpenAI-style key", "sk-abc123def456ghi789jkl012mno345pqr678", True),
        ("Anthropic-style key", "sk-ant-abcdef1234567890ABCDEFGH", True),
        (
            "Generic API key assignment",
            'API_KEY = "supersecretvalue123"',
            True,
        ),
        (
            "Generic API key assignment",
            "TOKEN = 'mytoken1234567890'",
            True,
        ),
        ("PEM private key header", "-----BEGIN RSA KEY-----", True),
        ("PEM private key header", "-----BEGIN PRIVATE KEY-----", True),
        ("AWS access key ID", "AKIAIOSFODNN7EXAMPLE", True),
        # Negative cases
        ("OpenAI-style key", "sk-short", False),
        ("AWS access key ID", "AKIA1234", False),
    ]

    passed = 0
    failed = 0

    for rule_name, sample, should_match in samples:
        matched_any = False
        for rn, pattern in RULES:
            if rn == rule_name and pattern.search(sample):
                matched_any = True
                break

        if matched_any == should_match:
            passed += 1
            status = "PASS"
        else:
            failed += 1
            status = "FAIL"

        expected = "match" if should_match else "no match"
        actual = "matched" if matched_any else "no match"
        print(f"  [{status}] Rule: {rule_name:<30} Expected: {expected:<10} Got: {actual}")

    print(f"\nSelf-test results: {passed} passed, {failed} failed")

    # Test inline suppression
    test_line = 'API_KEY = "mysecretvalue123"  # secretscan:ignore'
    suppressed = INLINE_SUPPRESSION in test_line
    if suppressed:
        print("  [PASS] Inline suppression detected")
        passed += 1
    else:
        print("  [FAIL] Inline suppression not detected")
        failed += 1

    # Test redaction
    redacted = redact("sk-abc123def456ghi789jkl012")
    if redacted.startswith("sk-a") and redacted.endswith("l012") and "***" in redacted:
        print("  [PASS] Redaction works correctly")
        passed += 1
    else:
        print(f"  [FAIL] Redaction unexpected: {redacted}")
        failed += 1

    print(f"\nFinal results: {passed} passed, {failed} failed")
    return 1 if failed > 0 else 0


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(description="Secret scanner for AetherNotes")
    parser.add_argument(
        "--mode",
        choices=["ci", "local", "selftest"],
        required=True,
        help="Run mode: ci (fail on findings), local (scan repo), selftest (in-memory tests)",
    )
    args = parser.parse_args()

    if args.mode == "selftest":
        return run_selftest()

    repo_root = Path(
        subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
        ).stdout.strip()
    )

    findings = scan_repo(repo_root)

    if findings:
        print_findings(findings)
        if args.mode == "ci":
            print("CI FAILURE: Secrets detected. See above for details.")
            print("Use allowlist or inline '# secretscan:ignore' to suppress false positives.")
        return 1

    print("Secret scan passed — no secrets detected.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
