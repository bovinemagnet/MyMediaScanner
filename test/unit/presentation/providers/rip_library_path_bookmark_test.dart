/// Unit tests for [RipLibraryPathNotifier] persistence and
/// security-scoped bookmark handling.
///
/// The library path and its bookmark live in SharedPreferences: they are
/// not secrets, and flutter_secure_storage does not survive app
/// relaunches on macOS debug builds (the ad-hoc code signature changes
/// on each rebuild, breaking the Keychain ACL match). On sandboxed
/// macOS the notifier must also persist a security-scoped bookmark
/// alongside the path and restore access on startup. These tests drive
/// that orchestration against mocked SharedPreferences and a mocked
/// [SecureBookmarkService].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/secure_bookmark_service.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSecureBookmarkService extends Mock
    implements SecureBookmarkService {}

const _pathKey = 'rip_library_path';
const _bookmarkKey = 'rip_library_bookmark';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterSecureStorage legacyStorage;
  late MockSecureBookmarkService bookmarks;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(legacyStorage),
        secureBookmarkServiceProvider.overrideWithValue(bookmarks),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    RipLibraryPathNotifier.resetAccessRestoredForTesting();
    SharedPreferences.setMockInitialValues({});
    legacyStorage = MockFlutterSecureStorage();
    bookmarks = MockSecureBookmarkService();
    when(() => legacyStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    // Default: access restore is a no-op; tests that exercise it
    // override this stub with a specific answer.
    when(() => bookmarks.startAccess(any())).thenAnswer((_) async => null);
  });

  Future<String?> readPath(ProviderContainer container) async {
    // Keep the provider alive while awaiting (Riverpod 3 pauses
    // unlistened futures).
    container.listen(ripLibraryPathProvider, (_, _) {});
    return container.read(ripLibraryPathProvider.future);
  }

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  group('setPickedPath', () {
    test('stores path and a freshly created bookmark', () async {
      when(() => bookmarks.isAvailable).thenReturn(true);
      when(() => bookmarks.createBookmark('/vol/music'))
          .thenAnswer((_) async => 'blob-1');
      final container = makeContainer();
      await readPath(container);

      await container
          .read(ripLibraryPathProvider.notifier)
          .setPickedPath('/vol/music');

      expect((await prefs()).getString(_pathKey), '/vol/music');
      expect((await prefs()).getString(_bookmarkKey), 'blob-1');
    });

    test('clears stale bookmark when creation fails', () async {
      SharedPreferences.setMockInitialValues({_bookmarkKey: 'blob-old'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      when(() => bookmarks.createBookmark(any()))
          .thenAnswer((_) async => null);
      final container = makeContainer();
      await readPath(container);

      await container
          .read(ripLibraryPathProvider.notifier)
          .setPickedPath('/vol/music');

      expect((await prefs()).getString(_pathKey), '/vol/music');
      expect((await prefs()).getString(_bookmarkKey), isNull);
    });

    test('skips bookmarking on platforms without sandbox bookmarks',
        () async {
      when(() => bookmarks.isAvailable).thenReturn(false);
      final container = makeContainer();
      await readPath(container);

      await container
          .read(ripLibraryPathProvider.notifier)
          .setPickedPath('/vol/music');

      expect((await prefs()).getString(_pathKey), '/vol/music');
      verifyNever(() => bookmarks.createBookmark(any()));
    });
  });

  group('setPath (typed)', () {
    test('clears the bookmark when the path actually changes', () async {
      SharedPreferences.setMockInitialValues(
          {_pathKey: '/old/path', _bookmarkKey: 'blob-old'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      when(() => bookmarks.startAccess(any()))
          .thenAnswer((_) async => 'blob-old');
      final container = makeContainer();
      await readPath(container);

      await container
          .read(ripLibraryPathProvider.notifier)
          .setPath('/new/path');

      expect((await prefs()).getString(_pathKey), '/new/path');
      expect((await prefs()).getString(_bookmarkKey), isNull);
    });

    test('keeps the bookmark when re-submitting the unchanged path',
        () async {
      SharedPreferences.setMockInitialValues(
          {_pathKey: '/vol/music', _bookmarkKey: 'blob-1'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      when(() => bookmarks.startAccess(any()))
          .thenAnswer((_) async => 'blob-1');
      final container = makeContainer();
      await readPath(container);

      await container
          .read(ripLibraryPathProvider.notifier)
          .setPath('/vol/music');

      expect((await prefs()).getString(_bookmarkKey), 'blob-1');
    });
  });

  group('build', () {
    test('reads the stored path from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({_pathKey: '/vol/music'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      final container = makeContainer();

      expect(await readPath(container), '/vol/music');
    });

    test('migrates a legacy secure-storage path into SharedPreferences',
        () async {
      when(() => bookmarks.isAvailable).thenReturn(false);
      when(() => legacyStorage.read(key: _pathKey))
          .thenAnswer((_) async => '/legacy/path');
      final container = makeContainer();

      final path = await readPath(container);

      expect(path, '/legacy/path');
      expect((await prefs()).getString(_pathKey), '/legacy/path');
    });

    test('starts security-scoped access from the stored bookmark', () async {
      SharedPreferences.setMockInitialValues(
          {_pathKey: '/vol/music', _bookmarkKey: 'blob-1'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      when(() => bookmarks.startAccess('blob-1'))
          .thenAnswer((_) async => 'blob-1');
      final container = makeContainer();

      final path = await readPath(container);

      expect(path, '/vol/music');
      verify(() => bookmarks.startAccess('blob-1')).called(1);
    });

    test('persists the renewed bookmark when the stored one was stale',
        () async {
      SharedPreferences.setMockInitialValues(
          {_pathKey: '/vol/music', _bookmarkKey: 'blob-stale'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      when(() => bookmarks.startAccess('blob-stale'))
          .thenAnswer((_) async => 'blob-renewed');
      final container = makeContainer();

      await readPath(container);

      expect((await prefs()).getString(_bookmarkKey), 'blob-renewed');
    });

    test('does not touch the service when no bookmark is stored', () async {
      SharedPreferences.setMockInitialValues({_pathKey: '/vol/music'});
      when(() => bookmarks.isAvailable).thenReturn(true);
      final container = makeContainer();

      await readPath(container);

      verifyNever(() => bookmarks.startAccess(any()));
    });
  });
}
