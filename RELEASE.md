# Release Guide

## Prerequisites

1. **Apple Developer ID certificate** installed in Keychain
2. **Environment variables** - Copy and fill in:
   ```bash
   cp .env.local.example .env.local
   ```

## One-Command Release

```bash
./Scripts/release.sh 0.2.0
```

This script:
1. Updates `Info.plist` version
2. Commits and pushes version bump
3. Builds, notarizes, creates DMG (`make release`)
4. Creates GitHub release with DMG
5. Updates website version and pushes

## Manual Steps

If you prefer manual release:

### 1. Update version

```bash
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 0.2.0" Resources/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 0.2.0" Resources/Info.plist
```

### 2. Build and Notarize

```bash
make release
```

### 3. Publish to GitHub

```bash
gh release create v0.2.0 Hinto.dmg --title "Hinto v0.2.0" --generate-notes
```

### 4. Update Website

```bash
cd ../hinto-site
# Edit src/pages/index.astro: const version = "v0.2.0"
git add -A && git commit -m "Update to v0.2.0" && git push
```
