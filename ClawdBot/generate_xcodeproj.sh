#!/bin/bash
#
# generate_xcodeproj.sh
# Generates ClawdBot.xcodeproj using XcodeGen from project.yml
#
# Usage: ./generate_xcodeproj.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── 1. Check / install XcodeGen ──────────────────────────────────────────────

if ! command -v xcodegen &>/dev/null; then
    echo "XcodeGen not found. Installing via Homebrew..."

    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew is required to install XcodeGen."
        echo "Install Homebrew first: https://brew.sh"
        exit 1
    fi

    brew install xcodegen
    echo ""
fi

echo "Using XcodeGen $(xcodegen version)"

# ── 2. Verify project.yml exists ─────────────────────────────────────────────

if [ ! -f "project.yml" ]; then
    echo "Error: project.yml not found in $SCRIPT_DIR"
    exit 1
fi

# ── 3. Generate the Xcode project ────────────────────────────────────────────

echo "Generating ClawdBot.xcodeproj..."
xcodegen generate

echo ""
echo "Done! ClawdBot.xcodeproj has been generated."
echo ""
echo "Next steps:"
echo "  1. Open ClawdBot.xcodeproj in Xcode"
echo "  2. Select your development team under Signing & Capabilities"
echo "  3. Build and run on a simulator or device (iOS 26+)"
