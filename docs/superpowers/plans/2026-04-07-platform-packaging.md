# Platform Packaging Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Deliver production-quality platform packaging across all six targets — Android, iOS, macOS, Windows, Linux, and web — including branded app icons, splash screens, store listing metadata, and native installers, with CI/CD pipelines for each.

**Architecture:** Uses `flutter_launcher_icons` (already a dev dependency) and `flutter_native_splash` for asset generation. Platform-specific installer tooling (create-dmg, MSIX, AppImage/Flatpak) wrapped in shell scripts under `packaging/` and driven by GitHub Actions workflows.

**Tech Stack:** Flutter, flutter_launcher_icons 0.14.x, flutter_native_splash 2.x, GitHub Actions, create-dmg (macOS), msix (Windows pub package), appimagetool (Linux), flatpak-builder (Linux)

**Author:** Paul Snow

---

## Current State Assessment

| Area | Status | Notes |
|------|--------|-------|
| **Source icon** | Partial | `assets/icon/app_icon.png` and `app_icon_foreground.png` exist; SVG source (`app_icon.svg`, `app_icon_foreground.svg`) also present |
| **Android icons** | Done | `flutter_launcher_icons` config in `pubspec.yaml`; adaptive icon with `#0E0E0E` background; mipmap densities generated |
| **iOS icons** | Done | Full set in `AppIcon.appiconset` (20–1024pt) |
| **macOS icons** | Done | 16–1024px in `AppIcon.appiconset` |
| **Windows icon** | Partial | `app_icon.ico` exists in `windows/runner/resources/` but is the default Flutter icon — needs replacing with branded icon |
| **Linux icon** | Missing | No icon file; `CMakeLists.txt` copies `app_icon.png` from `assets/icon/` at install time but no `.desktop` file exists |
| **Splash screens** | Missing | Android `launch_background.xml` is default white; iOS `LaunchImage` set contains blank PNGs; no `flutter_native_splash` configured |
| **Android CI** | Done | `release-android.yml` builds APK on tag push, creates GitHub Release |
| **iOS CI** | Missing | No workflow |
| **macOS CI** | Missing | No workflow |
| **Windows CI** | Missing | No workflow |
| **Linux CI** | Missing | No workflow |
| **Store metadata** | Missing | No Fastlane, no Play Store listing, no App Store metadata |
| **Installers** | Missing | No DMG, MSIX, AppImage, or Flatpak configuration |
| **Android adaptive background** | Needs fix | `colors.xml` sets `ic_launcher_background` to `#1565C0` (blue) but `pubspec.yaml` specifies `#0E0E0E` (obsidian) — mismatch |

---

## Task 1: Fix Icon Colour Mismatch and Regenerate Icons

**Files:**
- Modify: `android/app/src/main/res/values/colors.xml`
- Modify: `pubspec.yaml` (add Windows + Linux launcher icon config)
- Regenerate: all platform icon assets

- [x] **Step 1: Fix Android adaptive icon background colour**

Update `android/app/src/main/res/values/colors.xml` to match the `pubspec.yaml` config:

```xml
<color name="ic_launcher_background">#0E0E0E</color>
```

- [x] **Step 2: Extend `flutter_launcher_icons` config for Windows and Linux**

In `pubspec.yaml`, update the `flutter_launcher_icons:` section:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  remove_alpha_ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#0E0E0E"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  macos:
    generate: true
    image_path: "assets/icon/app_icon.png"
  windows:
    generate: true
    image_path: "assets/icon/app_icon.png"
    icon_size: 48
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
```

- [x] **Step 3: Regenerate icons**

```bash
dart run flutter_launcher_icons
```

Verify that `windows/runner/resources/app_icon.ico` is overwritten with the branded icon.

- [x] **Step 4: Create Linux `.desktop` file**

Create `linux/com.paulsnow.mymediascanner.desktop`:

```ini
[Desktop Entry]
Name=MyMediaScanner
Comment=Scan barcodes on physical media and build a personal collection catalogue
Exec=mymediascanner
Icon=com.paulsnow.mymediascanner
Terminal=false
Type=Application
Categories=Utility;AudioVideo;Database;
Keywords=barcode;media;scanner;collection;dvd;bluray;cd;vinyl;
```

- [x] **Step 5: Update Linux `CMakeLists.txt` to install `.desktop` and icon**

Add install rules for the `.desktop` file and a correctly-named icon:

```cmake
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/com.paulsnow.mymediascanner.desktop"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../assets/icon/app_icon.png"
  RENAME "com.paulsnow.mymediascanner.png"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)
```

- [x] **Step 6: Commit**

```
feat: fix icon colour mismatch and extend launcher icons to all platforms
```

---

## Task 2: Branded Splash Screens

**Files:**
- Modify: `pubspec.yaml` (add `flutter_native_splash` dependency and config)
- Create: `assets/icon/splash_icon.png` (centred logo, no background — 1152×1152 recommended)
- Regenerate: Android `launch_background.xml`, iOS `LaunchImage`, macOS/Windows/Linux splash assets

- [x] **Step 1: Add `flutter_native_splash` dev dependency**

```yaml
  flutter_native_splash: ^2.4.6
```

- [x] **Step 2: Add splash screen configuration to `pubspec.yaml`**

```yaml
flutter_native_splash:
  color: "#0e0e0e"
  color_dark: "#0e0e0e"
  image: assets/icon/app_icon.png
  android: true
  ios: true
  web: false
  android_12:
    color: "#0e0e0e"
    icon_background_color: "#0e0e0e"
    image: assets/icon/app_icon_foreground.png
```

The Obsidian surface colour `#0e0e0e` is used as the background for both light and dark modes to maintain brand consistency during launch.

- [x] **Step 3: Generate splash assets**

```bash
dart run flutter_native_splash:create
```

- [x] **Step 4: Verify iOS `LaunchImage` assets are replaced**

Check that `ios/Runner/Assets.xcassets/LaunchImage.imageset/` now contains branded PNGs rather than blank placeholders.

- [x] **Step 5: Verify Android `launch_background.xml` is updated**

The drawable should reference the branded splash rather than `@android:color/white`.

- [x] **Step 6: Commit**

```
feat: add branded splash screens for Android and iOS
```

---

## Task 3: Windows MSIX Installer

**Files:**
- Modify: `pubspec.yaml` (add `msix` dev dependency and config)
- Modify: `windows/runner/Runner.rc` (update branding strings)
- Create: `.github/workflows/release-windows.yml`

- [x] **Step 1: Update Windows `Runner.rc` branding**

Update the `StringFileInfo` block:

```c
VALUE "CompanyName", "Paul Snow" "\0"
VALUE "FileDescription", "MyMediaScanner" "\0"
VALUE "InternalName", "MyMediaScanner" "\0"
VALUE "LegalCopyright", "Copyright (C) 2026 Paul Snow. All rights reserved." "\0"
VALUE "OriginalFilename", "MyMediaScanner.exe" "\0"
VALUE "ProductName", "MyMediaScanner" "\0"
```

- [x] **Step 2: Add `msix` dev dependency**

```yaml
  msix: ^3.16.8
```

- [x] **Step 3: Add MSIX configuration to `pubspec.yaml`**

```yaml
msix_config:
  display_name: MyMediaScanner
  publisher_display_name: Paul Snow
  identity_name: com.paulsnow.mymediascanner
  msix_version: 1.0.0.0
  logo_path: assets/icon/app_icon.png
  capabilities: internetClient
  languages: en-gb
```

- [x] **Step 4: Test local MSIX build**

```bash
dart run msix:create
```

- [x] **Step 5: Create Windows release workflow**

Create `.github/workflows/release-windows.yml`:

- Trigger on tags `v*.*.*` and `workflow_dispatch`
- Runs on `windows-latest`
- Steps: checkout → setup Flutter → pub get → build_runner → analyse → test → `flutter build windows --release` → `dart run msix:create` → upload MSIX artefact → create GitHub Release

- [x] **Step 6: Commit**

```
feat: add Windows MSIX installer configuration and CI workflow
```

---

## Task 4: macOS DMG Installer

**Files:**
- Create: `packaging/macos/create-dmg.sh`
- Create: `packaging/macos/dmg-background.png` (optional branded background)
- Create: `.github/workflows/release-macos.yml`

- [x] **Step 1: Create DMG packaging script**

Create `packaging/macos/create-dmg.sh`:

```bash
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
```

- [x] **Step 2: Create macOS release workflow**

Create `.github/workflows/release-macos.yml`:

- Trigger on tags `v*.*.*` and `workflow_dispatch`
- Runs on `macos-latest`
- Steps: checkout → setup Flutter → pub get → build_runner → analyse → test → `flutter build macos --release` → install `create-dmg` via Homebrew → run DMG script → upload DMG artefact → create GitHub Release
- Note: code signing and notarisation are out of scope for v1; add as follow-up

- [x] **Step 3: Commit**

```
feat: add macOS DMG packaging script and CI workflow
```

---

## Task 5: Linux AppImage and Flatpak

**Files:**
- Create: `packaging/linux/AppImageBuilder.yml`
- Create: `packaging/linux/com.paulsnow.mymediascanner.yml` (Flatpak manifest)
- Create: `packaging/linux/com.paulsnow.mymediascanner.metainfo.xml` (AppStream metadata)
- Create: `.github/workflows/release-linux.yml`

- [x] **Step 1: Create AppStream metadata**

Create `packaging/linux/com.paulsnow.mymediascanner.metainfo.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>com.paulsnow.mymediascanner</id>
  <name>MyMediaScanner</name>
  <summary>Scan barcodes on physical media and build a personal collection catalogue</summary>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary</project_license>
  <description>
    <p>
      MyMediaScanner is a cross-platform application for scanning barcodes on
      CDs, DVDs, Blu-rays, books, and video games to build a personal collection
      catalogue. Features include lending tracking, critic scores, FLAC rip
      library scanning, and insights analytics.
    </p>
  </description>
  <launchable type="desktop-id">com.paulsnow.mymediascanner.desktop</launchable>
  <categories>
    <category>Utility</category>
    <category>AudioVideo</category>
  </categories>
  <url type="homepage">https://github.com/bovinemagnet/MyMediaScanner</url>
  <url type="bugtracker">https://github.com/bovinemagnet/MyMediaScanner/issues</url>
  <developer id="com.paulsnow">
    <name>Paul Snow</name>
  </developer>
</component>
```

- [x] **Step 2: Create AppImage configuration**

Create `packaging/linux/AppImageBuilder.yml` using `appimage-builder` format. This bundles the Flutter Linux build output into a portable AppImage:

- AppDir from `build/linux/x64/release/bundle/`
- Desktop file: `com.paulsnow.mymediascanner.desktop`
- Icon: `assets/icon/app_icon.png`
- Runtime: continuous type2

- [x] **Step 3: Create Flatpak manifest**

Create `packaging/linux/com.paulsnow.mymediascanner.yml`:

- Runtime: `org.freedesktop.Platform` 24.08
- SDK: `org.freedesktop.Sdk`
- Finish-args: `--share=ipc`, `--socket=fallback-x11`, `--socket=wayland`, `--device=dri`, `--share=network`
- Build from pre-built Flutter bundle using `simple` buildsystem

- [x] **Step 4: Create Linux release workflow**

Create `.github/workflows/release-linux.yml`:

- Trigger on tags `v*.*.*` and `workflow_dispatch`
- Runs on `ubuntu-latest`
- Steps: checkout → install Linux build deps (`ninja-build`, `libgtk-3-dev`, etc.) → setup Flutter → pub get → build_runner → test → `flutter build linux --release` → build AppImage → upload artefacts → create GitHub Release
- Flatpak build is optional (can be a separate job or manual)

- [x] **Step 5: Commit**

```
feat: add Linux AppImage and Flatpak packaging with CI workflow
```

---

## Task 6: Android Play Store Listing Metadata

**Files:**
- Create: `android/fastlane/Fastfile`
- Create: `android/fastlane/Appfile`
- Create: `android/fastlane/metadata/android/en-GB/full_description.txt`
- Create: `android/fastlane/metadata/android/en-GB/short_description.txt`
- Create: `android/fastlane/metadata/android/en-GB/title.txt`
- Create: `android/fastlane/metadata/android/en-GB/changelogs/1.txt`

- [x] **Step 1: Initialise Fastlane for Android**

Create `android/fastlane/Appfile`:

```ruby
json_key_file("") # Path to service account JSON (set in CI secrets)
package_name("com.paulsnow.mymediascanner")
```

- [x] **Step 2: Create listing metadata files**

`title.txt`:
```
MyMediaScanner
```

`short_description.txt`:
```
Scan barcodes on CDs, DVDs, Blu-rays, books and games to catalogue your collection.
```

`full_description.txt`:
```
MyMediaScanner is a cross-platform app for scanning barcodes on physical media
— CDs, DVDs, Blu-rays, books, and video games — and building a personal
collection catalogue.

Features:
• Camera and Bluetooth/USB barcode scanning
• Automatic metadata lookup from TMDB, Discogs, Google Books, and Open Library
• Lending tracker to manage borrowed items
• Shelf organisation with drag-and-drop reordering
• FLAC rip library scanner with coverage comparison
• Batch scanning mode for rapid cataloguing
• IMDb ID lookup for films and TV series
• Cover OCR text recognition
• Statistics dashboard with CSV/JSON export
• Optional sync to self-hosted PostgreSQL
• Light and dark themes with custom design system

Your collection data is stored locally in SQLite. No account required.
```

`changelogs/1.txt`:
```
Initial release — barcode scanning, metadata lookup, collection management, lending tracker, and insights dashboard.
```

- [x] **Step 3: Create basic Fastfile**

Create `android/fastlane/Fastfile` with lanes for `beta` (internal track) and `release` (production track). Actual Play Store upload requires a service account key configured as a CI secret — document this in the Fastfile comments.

- [x] **Step 4: Commit**

```
feat: add Android Play Store listing metadata via Fastlane
```

---

## Task 7: iOS App Store Metadata

**Files:**
- Create: `ios/fastlane/Fastfile`
- Create: `ios/fastlane/Appfile`
- Create: `ios/fastlane/metadata/en-GB/description.txt`
- Create: `ios/fastlane/metadata/en-GB/keywords.txt`
- Create: `ios/fastlane/metadata/en-GB/name.txt`
- Create: `ios/fastlane/metadata/en-GB/subtitle.txt`
- Create: `ios/fastlane/metadata/en-GB/privacy_url.txt`
- Create: `ios/fastlane/metadata/en-GB/release_notes.txt`

- [x] **Step 1: Initialise Fastlane for iOS**

Create `ios/fastlane/Appfile`:

```ruby
app_identifier("com.paulsnow.mymediascanner")
```

- [x] **Step 2: Create App Store listing metadata**

`name.txt`:
```
MyMediaScanner
```

`subtitle.txt`:
```
Catalogue your physical media collection
```

`keywords.txt`:
```
barcode,scanner,media,collection,dvd,bluray,cd,vinyl,books,catalogue
```

`description.txt`: Same content as the Android `full_description.txt` (adapted to App Store tone if needed).

`release_notes.txt`:
```
Initial release.
```

`privacy_url.txt`:
```
https://github.com/bovinemagnet/MyMediaScanner/blob/main/PRIVACY.md
```

- [x] **Step 3: Create basic Fastfile**

Lanes for `beta` (TestFlight) and `release` (App Store). Code signing and provisioning profiles are out of scope — document as placeholders.

- [x] **Step 4: Commit**

```
feat: add iOS App Store listing metadata via Fastlane
```

---

## Task 8: iOS Release Workflow

**Files:**
- Create: `.github/workflows/release-ios.yml`

- [x] **Step 1: Create iOS release workflow**

Create `.github/workflows/release-ios.yml`:

- Trigger on tags `v*.*.*` and `workflow_dispatch`
- Runs on `macos-latest`
- Steps: checkout → setup Flutter → pub get → build_runner → analyse → test → `flutter build ios --release --no-codesign` → upload IPA artefact
- Note: actual App Store deployment requires code signing secrets (certificates, provisioning profiles) — add as environment secrets with documentation in a follow-up

- [x] **Step 2: Commit**

```
feat: add iOS release CI workflow
```

---

## Task 9: Unified Release Workflow

**Files:**
- Create: `.github/workflows/release-all.yml`

- [x] **Step 1: Create orchestrator workflow**

Create `.github/workflows/release-all.yml` that triggers the platform-specific workflows via `workflow_call` or `workflow_dispatch`:

```yaml
name: Release All Platforms
on:
  push:
    tags:
      - 'v*.*.*'
  workflow_dispatch:

jobs:
  android:
    uses: ./.github/workflows/release-android.yml
  windows:
    uses: ./.github/workflows/release-windows.yml
  macos:
    uses: ./.github/workflows/release-macos.yml
  linux:
    uses: ./.github/workflows/release-linux.yml
  ios:
    uses: ./.github/workflows/release-ios.yml
```

This keeps each platform workflow independently runnable whilst also allowing a single-tag release of all platforms.

- [x] **Step 2: Update existing `release-android.yml` to support `workflow_call`**

Add `workflow_call` trigger alongside the existing `push` and `workflow_dispatch` triggers so the orchestrator can invoke it.

- [x] **Step 3: Commit**

```
feat: add unified cross-platform release orchestrator workflow
```

---

## Summary

| Task | Platform | Deliverable |
|------|----------|-------------|
| 1 | All | Fix icon colours, extend launcher icons to Windows/Linux |
| 2 | Android, iOS | Branded splash screens via `flutter_native_splash` |
| 3 | Windows | MSIX installer + CI workflow |
| 4 | macOS | DMG installer + CI workflow |
| 5 | Linux | AppImage + Flatpak config + CI workflow |
| 6 | Android | Play Store listing metadata (Fastlane) |
| 7 | iOS | App Store listing metadata (Fastlane) |
| 8 | iOS | Release CI workflow |
| 9 | All | Unified release orchestrator workflow |

### Out of Scope (Follow-up)

- Apple code signing and notarisation (requires Developer Program membership)
- Play Store service account and automated upload
- Windows code signing certificate
- Flatpak Flathub submission
- Screenshot automation for store listings
- Privacy policy document (`PRIVACY.md`)
- Web deployment (Firebase Hosting / GitHub Pages)

### Dependencies Between Tasks

- Task 1 should be completed first (icons are referenced by all other tasks)
- Task 2 depends on Task 1 (splash uses the same icon assets)
- Tasks 3–8 are independent and can be executed in parallel
- Task 9 depends on Tasks 3–5 and 8 (needs all platform workflows to exist)

