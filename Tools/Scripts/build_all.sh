#!/usr/bin/env bash
# build_all.sh — local CI verification for AetherNotes Phase 01+
# Runs swift build and swift test for AetherNotesKit, then attempts
# xcodebuild for each app scheme if the toolchain is available.
# Exits 0 only if all attempted builds succeed.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PACKAGE_DIR="$REPO_ROOT/Packages/AetherNotesKit"
PROJECT="$REPO_ROOT/AetherNotes.xcodeproj"

echo "=== AetherNotes build_all.sh ==="
echo "Repo root: $REPO_ROOT"
echo ""

# ─── Swift package: build ───────────────────────────────────────────────────
echo "--- Swift package build ---"
if ! swift build --package-path "$PACKAGE_DIR" 2>&1; then
    echo "ERROR: swift build failed for AetherNotesKit"
    exit 1
fi
echo "Swift package build: OK"
echo ""

# ─── Swift package: test ────────────────────────────────────────────────────
echo "--- Swift package tests ---"
if ! swift test --package-path "$PACKAGE_DIR" 2>&1; then
    echo "ERROR: swift test failed for AetherNotesKit"
    exit 1
fi
echo "Swift package tests: OK"
echo ""

# ─── xcodebuild: app schemes ────────────────────────────────────────────────
if ! command -v xcodebuild &>/dev/null; then
    echo "xcodebuild not found — skipping Xcode scheme builds."
    echo "Install Xcode and Xcode Command Line Tools to enable full builds."
    echo ""
    echo "=== Done (package only) ==="
    exit 0
fi

SCHEMES=(
    "AetherNotes-iOS"
    "AetherNotes-iPadOS"
    "AetherNotes-macOS"
    "AetherNotes-watchOS"
    "AetherNotes-Widgets"
)

SDK_MAP=(
    "iphoneos"
    "iphoneos"
    "macosx"
    "watchos"
    "iphoneos"
)

FAILED_SCHEMES=()

for i in "${!SCHEMES[@]}"; do
    SCHEME="${SCHEMES[$i]}"
    SDK="${SDK_MAP[$i]}"

    echo "--- xcodebuild: $SCHEME ($SDK) ---"
    if ! xcodebuild \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -sdk "$SDK" \
        -configuration Debug \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        build 2>&1 | tail -20; then
        echo "WARNING: $SCHEME build failed — continuing."
        FAILED_SCHEMES+=("$SCHEME")
    else
        echo "$SCHEME: OK"
    fi
    echo ""
done

echo "=== Summary ==="
echo "Swift package: OK"
if [ ${#FAILED_SCHEMES[@]} -eq 0 ]; then
    echo "All Xcode schemes: OK"
    echo "=== Done ==="
    exit 0
else
    echo "Failed schemes: ${FAILED_SCHEMES[*]}"
    echo "=== Done with warnings ==="
    exit 1
fi
