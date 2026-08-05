// Guards the iOS release configuration that only fails at runtime on a device
// or at upload time in App Store Connect — neither of which the rest of the
// suite can reach.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

const _infoPlistPath = 'ios/Runner/Info.plist';
const _privacyManifestPath = 'ios/Runner/PrivacyInfo.xcprivacy';
const _pubspecPath = 'pubspec.yaml';

/// Purpose strings iOS demands before a plugin may touch a protected
/// resource. Reaching one of these APIs without its string terminates the
/// app, so the pairing is a hard requirement rather than store paperwork.
const _purposeStringsByPlugin = <String, List<String>>{
  // ImageSource.camera / ImageSource.gallery in cover_ocr_helper.dart.
  'image_picker': ['NSCameraUsageDescription', 'NSPhotoLibraryUsageDescription'],
  'mobile_scanner': ['NSCameraUsageDescription'],
  // Sync connects straight to a Postgres host, which is typically on the
  // user's LAN. iOS 14+ denies those connections without this string.
  'postgres': ['NSLocalNetworkUsageDescription'],
};

/// Required-reason API declarations Apple expects in the app's own privacy
/// manifest. Values are the reason codes for the APIs this app reaches
/// through path_provider, shared_preferences and disk-space checks.
const _requiredApiReasons = <String, String>{
  'NSPrivacyAccessedAPICategoryFileTimestamp': 'C617.1',
  'NSPrivacyAccessedAPICategoryUserDefaults': 'CA92.1',
  'NSPrivacyAccessedAPICategoryDiskSpace': 'E174.1',
};

/// Top-level key/value pairs of a plist `<dict>`, with values returned as
/// their raw XML elements so callers can inspect type as well as content.
Map<String, XmlElement> _topLevelDict(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    fail('$path is missing');
  }
  final dict = XmlDocument.parse(file.readAsStringSync())
      .rootElement
      .childElements
      .firstWhere((e) => e.name.local == 'dict',
          orElse: () => fail('$path has no top-level <dict>'));

  final entries = <String, XmlElement>{};
  final children = dict.childElements.toList();
  for (var i = 0; i + 1 < children.length; i += 2) {
    if (children[i].name.local != 'key') continue;
    entries[children[i].innerText] = children[i + 1];
  }
  return entries;
}

/// Direct dependencies declared in pubspec.yaml. Deliberately crude — it only
/// needs to spot a plugin name, and a YAML parser would pull in a dependency
/// for no gain.
Set<String> _declaredDependencies() {
  final lines = File(_pubspecPath).readAsLinesSync();
  final names = <String>{};
  for (final line in lines) {
    final match = RegExp(r'^  ([a-z0-9_]+):').firstMatch(line);
    if (match != null) names.add(match.group(1)!);
  }
  return names;
}

void main() {
  group('Info.plist', () {
    final info = _topLevelDict(_infoPlistPath);
    final dependencies = _declaredDependencies();

    for (final entry in _purposeStringsByPlugin.entries) {
      test('declares the purpose strings ${entry.key} requires', () {
        if (!dependencies.contains(entry.key)) {
          markTestSkipped('${entry.key} is no longer a dependency');
          return;
        }
        for (final key in entry.value) {
          final value = info[key];
          expect(
            value,
            isNotNull,
            reason: '$key is missing from $_infoPlistPath, so iOS will block '
                'the resource ${entry.key} needs — media pickers terminate '
                'the app outright, local-network connections just fail',
          );
          expect(value!.name.local, 'string', reason: '$key must be a string');
          expect(
            value.innerText.trim(),
            isNotEmpty,
            reason: '$key must explain why access is needed; App Store review '
                'rejects empty purpose strings',
          );
        }
      });
    }

    test('declares export compliance so uploads are not held up', () {
      final value = info['ITSAppUsesNonExemptEncryption'];
      expect(
        value,
        isNotNull,
        reason: 'without this key App Store Connect asks the export '
            'compliance question on every single upload',
      );
      expect(value!.name.local, anyOf('true', 'false'));
    });

    test('uses the product name for the home-screen label', () {
      expect(info['CFBundleDisplayName']?.innerText, 'MyMediaScanner');
    });
  });

  group('privacy manifest', () {
    test('exists in the app target', () {
      expect(
        File(_privacyManifestPath).existsSync(),
        isTrue,
        reason: 'App Store Connect rejects uploads without the app\'s own '
            'PrivacyInfo.xcprivacy (ITMS-91053); the pods\' manifests do not '
            'cover the app target',
      );
    });

    test('declares tracking and collected data types', () {
      final manifest = _topLevelDict(_privacyManifestPath);

      expect(manifest['NSPrivacyTracking']?.name.local, 'false',
          reason: 'this app does not track users');
      expect(manifest['NSPrivacyTrackingDomains']?.name.local, 'array');
      expect(manifest['NSPrivacyCollectedDataTypes']?.name.local, 'array');
    });

    test('declares a reason for every required-reason API it uses', () {
      final manifest = _topLevelDict(_privacyManifestPath);
      final accessed = manifest['NSPrivacyAccessedAPITypes'];
      expect(accessed?.name.local, 'array',
          reason: 'NSPrivacyAccessedAPITypes is missing');

      // Each entry is a dict of API category -> array of reason codes.
      final declared = <String, List<String>>{};
      for (final item in accessed!.childElements) {
        final children = item.childElements.toList();
        String? category;
        final reasons = <String>[];
        for (var i = 0; i + 1 < children.length; i += 2) {
          final key = children[i].innerText;
          final value = children[i + 1];
          if (key == 'NSPrivacyAccessedAPIType') {
            category = value.innerText;
          } else if (key == 'NSPrivacyAccessedAPITypeReasons') {
            reasons.addAll(value.childElements.map((e) => e.innerText));
          }
        }
        if (category != null) declared[category] = reasons;
      }

      for (final entry in _requiredApiReasons.entries) {
        expect(
          declared[entry.key],
          contains(entry.value),
          reason: '${entry.key} must declare reason ${entry.value}',
        );
      }
    });
  });
}
