# About Screen Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Add an About screen accessible from Settings, showing app info, author, GitHub link, features, and open-source licences.

**Architecture:** New `StatelessWidget` with `FutureBuilder<PackageInfo>` for version info, routed as `/settings/about` with full-screen push. Follows the same structure as the RepFoundary sibling project's About screen.

**Tech Stack:** Flutter, GoRouter, package_info_plus, url_launcher, Material 3

**Spec:** `docs/superpowers/specs/2026-03-17-about-screen-design.md`

---

### Task 1: Add Dependencies

**Files:**
- Modify: `pubspec.yaml:30-57` (dependencies), `pubspec.yaml:86` (assets)
- Modify: `macos/Runner/DebugProfile.entitlements`
- Modify: `macos/Runner/Release.entitlements`
- Modify: `android/app/src/main/AndroidManifest.xml:42-47` (queries)

- [x] **Step 1: Add package_info_plus and url_launcher to pubspec.yaml**

Add after the `data_table_2` line (line 57):

```yaml
  package_info_plus: ^8.3.0
  url_launcher: ^6.3.1
```

- [x] **Step 2: Add macOS network client entitlement**

In `macos/Runner/DebugProfile.entitlements`, add before the closing `</dict>`:

```xml
	<key>com.apple.security.network.client</key>
	<true/>
```

In `macos/Runner/Release.entitlements`, add before the closing `</dict>`:

```xml
	<key>com.apple.security.network.client</key>
	<true/>
```

- [x] **Step 3: Add Android intent query for url_launcher**

In `android/app/src/main/AndroidManifest.xml`, add inside the existing `<queries>` block (after line 46, before `</queries>`):

```xml
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
```

Without this, `launchUrl` will fail silently on Android 11+ (API 30).

- [x] **Step 4: Run flutter pub get**

Run: `flutter pub get`
Expected: Dependencies resolved successfully.

- [x] **Step 5: Add app icon asset to pubspec.yaml**

The `assets/icon/app_icon.png` file exists but is not declared as a Flutter asset. In the `flutter:` section (after line 86, replacing the commented-out assets block), add:

```yaml
  assets:
    - assets/icon/app_icon.png
```

- [x] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements android/app/src/main/AndroidManifest.xml
git commit -m "feat: add package_info_plus, url_launcher deps and platform config for About screen"
```

---

### Task 2: Add GitHub URL Constant

**Files:**
- Modify: `lib/core/constants/app_constants.dart`

- [x] **Step 1: Add githubUrl constant**

Add after line 3 (`static const databaseName`):

```dart
  static const githubUrl = 'https://github.com/bovinemagnet/MyMediaScanner';
```

- [x] **Step 2: Commit**

```bash
git add lib/core/constants/app_constants.dart
git commit -m "feat: add GitHub URL to AppConstants"
```

---

### Task 3: Create About Screen Widget

**Files:**
- Create: `lib/presentation/screens/about/about_screen.dart`

- [x] **Step 1: Create the About screen**

Create `lib/presentation/screens/about/about_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('About ${AppConstants.appName}')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '1.0.0';
          final buildNumber = snapshot.data?.buildNumber ?? '';
          final versionDisplay =
              buildNumber.isNotEmpty ? '$version+$buildNumber' : version;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              // App icon and name
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version $versionDisplay',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'A cross-platform app for scanning barcodes on '
                        'physical media and building a personal collection '
                        'catalogue.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),

              // Author
              const ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Author'),
                subtitle: Text('Paul Snow'),
              ),

              // GitHub
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub Repository'),
                subtitle: const Text(AppConstants.githubUrl),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openUrl(AppConstants.githubUrl),
              ),

              const Divider(),

              // Features
              _SectionHeader(title: 'Features'),
              const _FeatureTile(
                icon: Icons.qr_code_scanner,
                text: 'Barcode scanning for CDs, DVDs, Blu-rays, books and games',
              ),
              const _FeatureTile(
                icon: Icons.devices,
                text: 'Multi-platform support (Android, iOS, macOS, Windows, Linux)',
              ),
              const _FeatureTile(
                icon: Icons.swap_horiz,
                text: 'Lending tracker for borrowed media',
              ),
              const _FeatureTile(
                icon: Icons.album,
                text: 'FLAC rip library scanner with coverage comparison',
              ),
              const _FeatureTile(
                icon: Icons.sync,
                text: 'PostgreSQL sync for multi-device collections',
              ),
              const _FeatureTile(
                icon: Icons.bar_chart,
                text: 'Statistics dashboard with CSV/JSON export',
              ),

              const Divider(),

              // Built with
              ListTile(
                leading: const FlutterLogo(size: 24),
                title: const Text('Built with Flutter'),
              ),

              // Licences
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Open-source licences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: versionDisplay,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
```

- [x] **Step 2: Commit**

```bash
git add lib/presentation/screens/about/about_screen.dart
git commit -m "feat: create About screen widget"
```

---

### Task 4: Wire Up Route and Settings Tile

**Files:**
- Modify: `lib/app/router.dart:1-14` (imports), `lib/app/router.dart:97-104` (settings routes)
- Modify: `lib/presentation/screens/settings/settings_screen.dart:57-69`

- [x] **Step 1: Add route in router.dart**

Add import at line 14 (before the `app_scaffold` import):

```dart
import 'package:mymediascanner/presentation/screens/about/about_screen.dart';
```

Add nested route after the postgres route (after line 103, before the closing `],`):

```dart
                GoRoute(
                  path: 'about',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const AboutScreen(),
                ),
```

- [x] **Step 2: Add About tile in settings_screen.dart**

After the Data section's Reset & Re-sync `ListTile` (after line 68), add:

```dart
          const Divider(height: 32),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('About ${AppConstants.appName}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/about'),
          ),
```

Add the import at the top of `settings_screen.dart`:

```dart
import 'package:mymediascanner/core/constants/app_constants.dart';
```

- [x] **Step 3: Verify the app compiles**

Run: `flutter analyze`
Expected: No issues found.

- [x] **Step 4: Commit**

```bash
git add lib/app/router.dart lib/presentation/screens/settings/settings_screen.dart
git commit -m "feat: wire About screen into settings navigation"
```

---

### Task 5: Write Widget Tests

**Files:**
- Create: `test/presentation/screens/about/about_screen_test.dart`

- [x] **Step 1: Write widget tests**

Create `test/presentation/screens/about/about_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/presentation/screens/about/about_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const MaterialApp(
      home: AboutScreen(),
    );
  }

  testWidgets('renders app name', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
  });

  testWidgets('renders author name', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Paul Snow'), findsOneWidget);
  });

  testWidgets('renders GitHub repository tile', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('GitHub Repository'), findsOneWidget);
    expect(find.text(AppConstants.githubUrl), findsOneWidget);
  });

  testWidgets('renders features section', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('renders open-source licences tile', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Open-source licences'), findsOneWidget);
  });

  testWidgets('renders built with Flutter tile', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Built with Flutter'), findsOneWidget);
    expect(find.byType(FlutterLogo), findsOneWidget);
  });
}
```

- [x] **Step 2: Run the tests**

Run: `flutter test test/presentation/screens/about/about_screen_test.dart`
Expected: All tests pass.

- [x] **Step 3: Run the full test suite**

Run: `flutter test`
Expected: All ~94+ tests pass, no regressions.

- [x] **Step 4: Commit**

```bash
git add test/presentation/screens/about/about_screen_test.dart
git commit -m "test: add About screen widget tests"
```
