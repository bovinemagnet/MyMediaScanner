#!/usr/bin/env bash
set -euo pipefail

APP_NAME="MyMediaScanner"
VERSION="${1:-1.0.0}"
BUILD_DIR="build/macos/Build/Products/Release"
DMG_NAME="${APP_NAME}-${VERSION}-macOS.dmg"

# Build release
flutter build macos --release

# Create DMG using create-dmg (brew install create-dmg)
create-dmg \
  --volname "${APP_NAME}" \
  --volicon "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 175 190 \
  --app-drop-link 425 190 \
  --hide-extension "${APP_NAME}.app" \
  "build/${DMG_NAME}" \
  "${BUILD_DIR}/${APP_NAME}.app"

echo "Created: build/${DMG_NAME}"
