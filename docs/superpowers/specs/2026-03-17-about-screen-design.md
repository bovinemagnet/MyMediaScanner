# About Screen Design

## Summary

Add an About screen accessible from the Settings screen, providing users with app information, version, author details, a link to the GitHub repository, key features, and open-source licence information.

## Access

- A `ListTile` at the bottom of the Settings screen navigates to `/settings/about`
- Icon: `Icons.info_outline`, title: "About MyMediaScanner", trailing chevron

## Screen Layout

`StatefulWidget` using `FutureBuilder<PackageInfo>` for version info. Top-to-bottom in a `ListView`:

### 1. App Header
- App icon from `Image.asset('assets/icon/app_icon.png', width: 64, height: 64)`
- App name: "MyMediaScanner" (from `AppConstants.appName`)
- Version string: "Version X.Y.Z (build)" via `package_info_plus`

### 2. Description
- "A cross-platform app for scanning barcodes on physical media and building a personal collection catalogue."

### 3. Author
- Icon: `Icons.person_outline`
- Label: "Author"
- Value: "Paul Snow"

### 4. GitHub Repository
- Icon: `Icons.code`
- Label: "GitHub Repository"
- Tappable — opens `https://github.com/bovinemagnet/MyMediaScanner` via `url_launcher`
- Trailing external link icon (`Icons.open_in_new`)

### 5. Features
- Section header: "Features"
- List of `ListTile` items with leading icons:
  - Barcode scanning for CDs, DVDs, Blu-rays, books and games
  - Multi-platform support (Android, iOS, macOS, Windows, Linux)
  - Lending tracker for borrowed media
  - FLAC rip library scanner with coverage comparison
  - PostgreSQL sync for multi-device collections
  - Statistics dashboard with CSV/JSON export

### 6. Built With
- `FlutterLogo(size: 24)` with adjacent text "Built with Flutter"

### 7. Open-Source Licences
- `ListTile` that calls `showLicensePage()` with app name, version, and app icon

## Architecture

### New Files
- `lib/presentation/screens/about/about_screen.dart` — `StatefulWidget` with `FutureBuilder<PackageInfo>` for async version retrieval

### Modified Files
- `lib/app/router.dart` — add nested route `/settings/about` with `parentNavigatorKey: _rootNavigatorKey` (matching the existing `/settings/postgres` pattern for full-screen push outside the navigation shell)
- `lib/presentation/screens/settings/settings_screen.dart` — add About list tile at bottom
- `pubspec.yaml` — add `package_info_plus` (latest stable) and `url_launcher` (latest stable) dependencies

### Constants
- Add `static const githubUrl = 'https://github.com/bovinemagnet/MyMediaScanner';` to `AppConstants`

### Platform Configuration
- `url_launcher` requires platform-specific setup: Android intent filters and macOS `com.apple.security.network.client` entitlement. Verify these are present or add them during implementation.

## Design Decisions

- **No localisation:** MyMediaScanner does not use l10n, so strings are hardcoded or in constants
- **StatefulWidget + FutureBuilder:** Simplest approach for async version info without adding a Riverpod provider
- **Full-screen route:** Uses `parentNavigatorKey` to push outside the navigation shell, matching the postgres config screen pattern
- **Uses Flutter built-in licence page:** `showLicensePage()` automatically collects all package licences
- **Theme-aware:** Respects Material 3 colour scheme and text themes
- **App icon from asset:** Uses the existing launcher icon rather than a generic Material icon

## Testing

- Widget test verifying the screen renders key elements (app name, author, GitHub link, licences button)
- Widget test verifying GitHub link tap triggers `launchUrl`

## Dependencies

- `package_info_plus` — retrieve app version and build number at runtime
- `url_launcher` — open GitHub URL in external browser
