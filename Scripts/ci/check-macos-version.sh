#!/bin/bash
set -euo pipefail

# Check that MACOS_MIN_VERSION is consistent across the project
#
# Locations checked:
#   - Config/base.xcconfig (MACOSX_DEPLOYMENT_TARGET)
#   - .github/workflows/release.yml (MACOS_MIN_VERSION)

echo "=== Checking macOS minimum version consistency ==="

# Extract versions from each source
XCCONFIG_VERSION=$(grep "MACOSX_DEPLOYMENT_TARGET" Config/base.xcconfig | sed 's/.*= *//' | tr -d ' ')
RELEASE_YML_VERSION=$(grep "MACOS_MIN_VERSION:" .github/workflows/release.yml | head -1 | sed 's/.*: *"//' | sed 's/".*//')

echo "Config/base.xcconfig:           $XCCONFIG_VERSION"
echo ".github/workflows/release.yml:  $RELEASE_YML_VERSION"

# Compare versions
ERRORS=0

if [ "$XCCONFIG_VERSION" != "$RELEASE_YML_VERSION" ]; then
    echo ""
    echo "ERROR: Version mismatch between base.xcconfig and release.yml"
    ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "=== FAILED: Found $ERRORS inconsistencies ==="
    echo "Please ensure MACOS_MIN_VERSION is the same in all locations."
    exit 1
fi

echo ""
echo "=== PASSED: All versions match ($XCCONFIG_VERSION) ==="
