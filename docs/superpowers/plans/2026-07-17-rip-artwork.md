# Rip Library Album Artwork Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show album cover art on rip album cards and the album detail dialog, sourced from a folder image file or an embedded FLAC PICTURE block, cached locally during the library scan.

**Architecture:** The scanner (which already reads every FLAC) extracts one cover per album — folder image preferred, embedded picture as fallback — and writes it to `<ApplicationSupport>/rip_covers/<md5-of-relative-path>.<ext>`. The cached path is stored in a new `rip_albums.cover_path` column (schema v24) and rendered by a small reusable `RipCoverThumb` widget.

**Tech Stack:** Flutter/Dart, Drift (SQLite), Riverpod 3 hand-written notifiers, `dart_metaflac` (via existing `FlacReader`), `crypto` (md5), `path_provider`, mocktail tests.

**Spec:** `docs/superpowers/specs/2026-07-17-rip-artwork-design.md`

## Global Constraints

- British spelling in all prose, comments, and messages.
- Doc headers use `Author: Paul Snow` and `Since: 0.0.0`.
- No Claude/Anthropic references in code or commit messages.
- TDD: write the failing test first, watch it fail, then implement.
- After changing Drift tables or Freezed entities run:
  `dart run build_runner build --delete-conflicting-outputs`
- Migration chain rules: every `addColumn` in `onUpgrade` must use the
  `_addColumnIfMissing` helper (the v17 branch recreates the rip tables
  from the current Dart definition, so later columns may already exist).
- Cover extraction must never fail or slow the scan visibly; all
  failures degrade to `coverPath == null`.
- The `Isolate.run` closure in `ScanRipLibraryUseCase.execute` may only
  capture sendable values (plain `String`s) — never `this` or fields.

---

### Task 1: Schema v24 — `rip_albums.cover_path`

**Files:**
- Modify: `lib/data/local/database/tables/rip_albums_table.dart`
- Modify: `lib/data/local/database/app_database.dart` (schemaVersion, `_runUpgrade`)
- Modify: `lib/domain/entities/rip_album.dart`
- Modify: `lib/data/repositories/rip_library_repository_impl.dart`
- Test: `test/unit/data/local/database/migration_v24_test.dart` (create)

**Interfaces:**
- Consumes: `_addColumnIfMissing(Migrator m, TableInfo table, GeneratedColumn column)` — existing private helper in `AppDatabase`.
- Produces: `RipAlbum.coverPath` (`String?`) persisted through insert/update/read; `rip_albums.cover_path TEXT NULL` column; `schemaVersion == 24`.

- [ ] **Step 1: Write the failing migration test**

Create `test/unit/data/local/database/migration_v24_test.dart`:

```dart
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for the v24 migration adding
/// `rip_albums.cover_path`.
///
/// The v17 branch drops and recreates `rip_albums` from the current
/// Dart definition, so upgrades from < 17 arrive at the v24 branch
/// with the column already present — the add must be guarded.
///
/// Author: Paul Snow
/// Since: 0.0.0
void main() {
  test('fresh v24 schema exposes rip_albums.cover_path', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    expect(await _ripAlbumColumns(db), contains('cover_path'));
  });

  test('v23 → v24 upgrade adds cover_path once', () async {
    final dbFile = await _writeStubRipSchema(userVersion: 23);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumColumns(db);
    expect(cols.where((c) => c == 'cover_path').length, 1);
  });

  test('pre-v17 upgrade (drop-and-recreate path) does not duplicate '
      'cover_path', () async {
    // At user_version 16 the v17 branch recreates rip_albums from the
    // current definition (which already has cover_path); the v24
    // branch must then be a no-op instead of a duplicate-column error.
    final dbFile = await _writeStubRipSchema(userVersion: 16);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumColumns(db);
    expect(cols.where((c) => c == 'cover_path').length, 1);
  });
}

Future<List<String>> _ripAlbumColumns(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM pragma_table_info('rip_albums')")
      .get();
  return rows.map((r) => r.data['name'] as String).toList();
}

/// Minimal rip tables at their pre-cover_path shape.
Future<File> _writeStubRipSchema({required int userVersion}) async {
  final tempDir = await Directory.systemTemp.createTemp('mms_mig_v24_');
  final dbFile = File('${tempDir.path}/app.sqlite');
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final raw = sqlite3.open(dbFile.path);
  raw.execute('''
    CREATE TABLE rip_albums (
      id TEXT NOT NULL PRIMARY KEY,
      library_path TEXT NOT NULL,
      artist TEXT NULL,
      album_title TEXT NULL,
      barcode TEXT NULL,
      track_count INTEGER NOT NULL,
      disc_count INTEGER NOT NULL DEFAULT 1,
      total_size_bytes INTEGER NOT NULL,
      media_item_id TEXT NULL,
      last_scanned_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      cue_file_path TEXT NULL,
      gnudb_disc_id TEXT NULL,
      deleted INTEGER NOT NULL DEFAULT 0
    )
  ''');
  raw.execute('''
    CREATE TABLE rip_tracks (
      id TEXT NOT NULL PRIMARY KEY,
      rip_album_id TEXT NOT NULL,
      disc_number INTEGER NOT NULL DEFAULT 1,
      track_number INTEGER NOT NULL,
      title TEXT NULL,
      file_path TEXT NOT NULL,
      duration_ms INTEGER NULL,
      file_size_bytes INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  raw.execute('PRAGMA user_version = $userVersion');
  raw.close();
  return dbFile;
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/unit/data/local/database/migration_v24_test.dart`
Expected: FAIL — `cover_path` not in columns (fresh schema test), and the
v23 test fails the same way.

- [ ] **Step 3: Add the column, bump the schema, add the guarded branch**

In `lib/data/local/database/tables/rip_albums_table.dart`, after
`gnudbDiscId`:

```dart
  TextColumn get gnudbDiscId => text().nullable()();
  TextColumn get coverPath => text().nullable()();
```

In `lib/data/local/database/app_database.dart`:

```dart
  @override
  int get schemaVersion => 24;
```

At the end of `_runUpgrade`, after the `from < 23` block:

```dart
    if (from < 24) {
      // Rip library artwork: path of the locally cached cover image.
      // Guarded because the v17 branch above recreates rip_albums from
      // the current Dart definition, which already includes the
      // column for upgrades that came through it.
      await _addColumnIfMissing(m, ripAlbumsTable, ripAlbumsTable.coverPath);
    }
```

- [ ] **Step 4: Regenerate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes with no errors; `app_database.g.dart` gains `coverPath`.

- [ ] **Step 5: Add the entity field and repository plumbing**

In `lib/domain/entities/rip_album.dart` add after `gnudbDiscId`:

```dart
    String? gnudbDiscId,
    String? coverPath,
```

Re-run: `dart run build_runner build --delete-conflicting-outputs`
(regenerates `rip_album.freezed.dart`).

In `lib/data/repositories/rip_library_repository_impl.dart` add
`coverPath: Value(album.coverPath),` to each of the three
`RipAlbumsTableCompanion(` constructions (`insertAlbum` ~line 34,
`updateAlbum` ~line 53, `updateAlbumAndReplaceTracks` ~line 127 —
place it next to `cueFilePath`), and add `coverPath: row.coverPath,`
to `_albumFromRow` (~line 188, next to `cueFilePath`).

- [ ] **Step 6: Run the migration test to verify it passes**

Run: `flutter test test/unit/data/local/database/migration_v24_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 7: Run the full suite and analyser**

Run: `flutter test` then `flutter analyze`
Expected: all tests pass, no analyser issues.

- [ ] **Step 8: Commit**

```bash
git add lib/data/local/database/tables/rip_albums_table.dart \
  lib/data/local/database/app_database.dart \
  lib/data/local/database/app_database.g.dart \
  lib/domain/entities/rip_album.dart \
  lib/domain/entities/rip_album.freezed.dart \
  lib/data/repositories/rip_library_repository_impl.dart \
  test/unit/data/local/database/migration_v24_test.dart
git commit -m "feat(rips): add rip_albums.cover_path (schema v24)"
```

---

### Task 2: `FlacReader` exposes embedded cover art

**Files:**
- Modify: `lib/core/utils/flac_reader.dart`
- Create: `test/helpers/flac_fixtures.dart`
- Modify: `test/unit/core/flac_reader_test.dart`

**Interfaces:**
- Consumes: `dart_metaflac`'s `FlacMetadataDocument.pictures` (`List<PictureBlock>`, each with `Uint8List data` and `String mimeType`).
- Produces: `FlacMetadata.coverArt` (`Uint8List?`) and `FlacMetadata.coverArtMimeType` (`String?`); shared test fixture `buildFlacFixture({Map<String,String>? tags, Uint8List? pictureData, String pictureMimeType = 'image/jpeg', ...})` in `test/helpers/flac_fixtures.dart`.

- [ ] **Step 1: Extract the fixture builder into a shared helper**

Create `test/helpers/flac_fixtures.dart` by moving the entire fixture
section from `test/unit/core/flac_reader_test.dart` (everything from
`buildFlacFixture` down to `_uint32LE`, with the `dart:typed_data`
import) into the new file with a library header:

```dart
/// Shared in-memory FLAC fixture builders for tests.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:typed_data';
```

Then extend `buildFlacFixture` with picture support. The new signature
and body:

```dart
Uint8List buildFlacFixture({
  Map<String, String>? tags,
  int sampleRate = 44100,
  int totalSamples = 441000, // 10 seconds at 44100
  bool includeVorbisComment = true,
  bool isLastBlockStreamInfo = false,
  Uint8List? pictureData,
  String pictureMimeType = 'image/jpeg',
}) {
  final builder = BytesBuilder();

  // Magic: fLaC
  builder.add([0x66, 0x4C, 0x61, 0x43]);

  final hasVorbis = includeVorbisComment && tags != null;
  final hasPicture = pictureData != null;

  // STREAMINFO block (type 0, 34 bytes)
  final streamInfo = _buildStreamInfoBlock(
    sampleRate: sampleRate,
    totalSamples: totalSamples,
    isLast: (isLastBlockStreamInfo || !hasVorbis) && !hasPicture,
  );
  builder.add(streamInfo);

  // VORBIS_COMMENT block (type 4) if requested
  if (hasVorbis) {
    final vorbisComment =
        _buildVorbisCommentBlock(tags, isLast: !hasPicture);
    builder.add(vorbisComment);
  }

  // PICTURE block (type 6) if requested — always last when present.
  if (hasPicture) {
    builder.add(_buildPictureBlock(pictureData, pictureMimeType));
  }

  return builder.toBytes();
}

/// Builds a PICTURE block (type 6) marked as the last metadata block.
Uint8List _buildPictureBlock(Uint8List data, String mimeType) {
  final payload = BytesBuilder();
  payload.add(_uint32BE(3)); // picture type: front cover
  final mimeBytes = mimeType.codeUnits;
  payload.add(_uint32BE(mimeBytes.length));
  payload.add(mimeBytes);
  payload.add(_uint32BE(0)); // description length (empty)
  payload.add(_uint32BE(1)); // width
  payload.add(_uint32BE(1)); // height
  payload.add(_uint32BE(24)); // colour depth
  payload.add(_uint32BE(0)); // indexed colours
  payload.add(_uint32BE(data.length));
  payload.add(data);

  final payloadBytes = payload.toBytes();
  final block = BytesBuilder();
  block.addByte(0x80 | 6); // type 6, last-block flag set
  block.addByte((payloadBytes.length >> 16) & 0xFF);
  block.addByte((payloadBytes.length >> 8) & 0xFF);
  block.addByte(payloadBytes.length & 0xFF);
  block.add(payloadBytes);
  return block.toBytes();
}

Uint8List _uint32BE(int value) {
  return Uint8List(4)
    ..[0] = (value >> 24) & 0xFF
    ..[1] = (value >> 16) & 0xFF
    ..[2] = (value >> 8) & 0xFF
    ..[3] = value & 0xFF;
}
```

Keep `_buildStreamInfoBlock`, `_buildVorbisCommentBlock`, and
`_uint32LE` exactly as they were. In
`test/unit/core/flac_reader_test.dart` delete the moved fixture code
and import the helper instead:

```dart
import '../../helpers/flac_fixtures.dart';
```

Run: `flutter test test/unit/core/flac_reader_test.dart`
Expected: PASS (pure refactor — existing tests still green).

- [ ] **Step 2: Write the failing cover-art tests**

Append to the `main()` group in
`test/unit/core/flac_reader_test.dart`:

```dart
    group('cover art', () {
      test('exposes the first embedded picture and its MIME type', () {
        final art = Uint8List.fromList([1, 2, 3, 4, 5]);
        final bytes = buildFlacFixture(
          tags: {'ARTIST': 'Cappella'},
          pictureData: art,
          pictureMimeType: 'image/png',
        );

        final metadata = FlacReader.readMetadataFromBytes(bytes);

        expect(metadata, isNotNull);
        expect(metadata!.coverArt, art);
        expect(metadata.coverArtMimeType, 'image/png');
      });

      test('coverArt is null when no picture block exists', () {
        final bytes = buildFlacFixture(tags: {'ARTIST': 'Cappella'});

        final metadata = FlacReader.readMetadataFromBytes(bytes);

        expect(metadata!.coverArt, isNull);
        expect(metadata.coverArtMimeType, isNull);
      });
    });
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `flutter test test/unit/core/flac_reader_test.dart --name "cover art"`
Expected: FAIL — `coverArt` getter not defined (compile error is
acceptable RED for a missing field; fix by implementing).

- [ ] **Step 4: Implement `coverArt` on `FlacMetadata`**

In `lib/core/utils/flac_reader.dart`, add to the `FlacMetadata`
constructor and fields (after `rawTags`):

```dart
    this.coverArt,
    this.coverArtMimeType,
```

```dart
  /// Raw bytes of the first embedded PICTURE block, or null when the
  /// file carries no artwork.
  final Uint8List? coverArt;

  /// MIME type of [coverArt] (e.g. `image/jpeg`), or null.
  final String? coverArtMimeType;
```

In `_fromDocument`, before the `return FlacMetadata(`:

```dart
    final picture = doc.pictures.isEmpty ? null : doc.pictures.first;
```

and add to the constructor call:

```dart
      coverArt: picture?.data,
      coverArtMimeType: picture?.mimeType,
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/unit/core/flac_reader_test.dart`
Expected: PASS (all, including the two new tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/utils/flac_reader.dart \
  test/helpers/flac_fixtures.dart \
  test/unit/core/flac_reader_test.dart
git commit -m "feat(rips): expose embedded FLAC cover art via FlacReader"
```

---

### Task 3: `RipCoverExtractor`

**Files:**
- Create: `lib/core/utils/rip_cover_extractor.dart`
- Modify: `pubspec.yaml` (promote `crypto` to a direct dependency)
- Test: `test/unit/core/rip_cover_extractor_test.dart` (create)

**Interfaces:**
- Consumes: `FlacReader.readMetadata(String path)` → `FlacMetadata?` with `coverArt`/`coverArtMimeType` (Task 2); `md5` from `package:crypto`.
- Produces:
  ```dart
  RipCoverExtractor.extractCover({
    required String albumDirPath,   // absolute album directory
    required String relativePath,   // album path relative to library root
    required List<String> audioFilePaths, // sorted absolute paths
    required String cacheDirPath,   // cover cache directory (created if needed)
  }) → Future<String?>              // cached cover path, or null
  ```
  Cache file name: `<lowercase hex md5 of relativePath>.<jpg|png>`.

- [ ] **Step 1: Add crypto as a direct dependency**

In `pubspec.yaml` `dependencies:`, after `csv: ^6.0.0` add:

```yaml
  crypto: ^3.0.3
```

Run: `flutter pub get`
Expected: resolves (crypto is already in the tree transitively).

- [ ] **Step 2: Write the failing tests**

Create `test/unit/core/rip_cover_extractor_test.dart`:

```dart
/// Unit tests for [RipCoverExtractor].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/rip_cover_extractor.dart';

import '../../helpers/flac_fixtures.dart';

void main() {
  late Directory tempDir;
  late Directory albumDir;
  late Directory cacheDir;

  const relativePath = 'Artist/Album';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mms_cover_');
    albumDir = await Directory('${tempDir.path}/Artist/Album')
        .create(recursive: true);
    cacheDir = Directory('${tempDir.path}/cache');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  String expectedCachePath(String ext) {
    final hash = md5.convert(utf8.encode(relativePath)).toString();
    return '${cacheDir.path}/$hash.$ext';
  }

  Future<String> writeFlacWithArt(List<int> art) async {
    final file = File('${albumDir.path}/01 track.flac');
    await file.writeAsBytes(buildFlacFixture(
      tags: {'ARTIST': 'Artist'},
      pictureData: Uint8List.fromList(art),
      pictureMimeType: 'image/png',
    ));
    return file.path;
  }

  test('prefers a folder image over embedded art', () async {
    final folderArt = [10, 20, 30];
    await File('${albumDir.path}/Cover.JPG').writeAsBytes(folderArt);
    final flacPath = await writeFlacWithArt([1, 2, 3]);

    final result = await RipCoverExtractor.extractCover(
      albumDirPath: albumDir.path,
      relativePath: relativePath,
      audioFilePaths: [flacPath],
      cacheDirPath: cacheDir.path,
    );

    expect(result, expectedCachePath('jpg'));
    expect(await File(result!).readAsBytes(), folderArt);
  });

  test('falls back to the embedded picture when no folder image exists',
      () async {
    final embedded = [7, 8, 9];
    final flacPath = await writeFlacWithArt(embedded);

    final result = await RipCoverExtractor.extractCover(
      albumDirPath: albumDir.path,
      relativePath: relativePath,
      audioFilePaths: [flacPath],
      cacheDirPath: cacheDir.path,
    );

    // image/png in the fixture → .png cache extension.
    expect(result, expectedCachePath('png'));
    expect(await File(result!).readAsBytes(), embedded);
  });

  test('returns null when there is no artwork at all', () async {
    final flac = File('${albumDir.path}/01 track.flac');
    await flac.writeAsBytes(buildFlacFixture(tags: {'ARTIST': 'A'}));

    final result = await RipCoverExtractor.extractCover(
      albumDirPath: albumDir.path,
      relativePath: relativePath,
      audioFilePaths: [flac.path],
      cacheDirPath: cacheDir.path,
    );

    expect(result, isNull);
  });

  test('returns null instead of throwing for unreadable inputs',
      () async {
    final result = await RipCoverExtractor.extractCover(
      albumDirPath: '${tempDir.path}/missing',
      relativePath: relativePath,
      audioFilePaths: ['${tempDir.path}/missing/none.flac'],
      cacheDirPath: cacheDir.path,
    );

    expect(result, isNull);
  });
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `flutter test test/unit/core/rip_cover_extractor_test.dart`
Expected: FAIL — `rip_cover_extractor.dart` does not exist.

- [ ] **Step 4: Implement the extractor**

Create `lib/core/utils/rip_cover_extractor.dart`:

```dart
/// Album cover extraction for the rip library scanner.
///
/// Resolves one cover image per album directory — a conventional
/// folder image file first (user-curated art wins), falling back to
/// the first embedded FLAC PICTURE block — and writes a copy into the
/// local cover cache so artwork stays visible when the library volume
/// is unmounted. All failures degrade to `null`; artwork must never
/// fail a scan.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';

class RipCoverExtractor {
  const RipCoverExtractor._();

  /// Folder image base names, in priority order.
  static const _coverFileNames = ['cover', 'folder', 'album', 'front'];

  /// Accepted folder image extensions, in priority order per name.
  static const _coverFileExtensions = ['.jpg', '.jpeg', '.png'];

  /// Extracts the album cover for [albumDirPath] into [cacheDirPath].
  ///
  /// Returns the cached file's path, or null when no artwork was found
  /// or anything went wrong. The cache file name is the md5 of
  /// [relativePath] so rescans overwrite in place.
  static Future<String?> extractCover({
    required String albumDirPath,
    required String relativePath,
    required List<String> audioFilePaths,
    required String cacheDirPath,
  }) async {
    try {
      final source = await _folderImage(albumDirPath) ??
          await _embeddedPicture(audioFilePaths);
      if (source == null) return null;

      await Directory(cacheDirPath).create(recursive: true);
      final hash = md5.convert(utf8.encode(relativePath)).toString();
      final file = File('$cacheDirPath/$hash.${source.extension}');
      await file.writeAsBytes(source.bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<_CoverSource?> _folderImage(String albumDirPath) async {
    final dir = Directory(albumDirPath);
    if (!await dir.exists()) return null;

    // Index files by lowercase name so the name/extension priority
    // order below decides, not directory listing order.
    final byName = <String, File>{};
    await for (final entry in dir.list(followLinks: false)) {
      if (entry is File) {
        byName[entry.uri.pathSegments.last.toLowerCase()] = entry;
      }
    }

    for (final base in _coverFileNames) {
      for (final ext in _coverFileExtensions) {
        final file = byName['$base$ext'];
        if (file != null) {
          return _CoverSource(
            await file.readAsBytes(),
            ext == '.png' ? 'png' : 'jpg',
          );
        }
      }
    }
    return null;
  }

  static Future<_CoverSource?> _embeddedPicture(
      List<String> audioFilePaths) async {
    for (final path in audioFilePaths) {
      if (!path.toLowerCase().endsWith('.flac')) continue;
      final metadata = await FlacReader.readMetadata(path);
      final art = metadata?.coverArt;
      if (art != null && art.isNotEmpty) {
        final mime = metadata!.coverArtMimeType?.toLowerCase();
        return _CoverSource(art, mime == 'image/png' ? 'png' : 'jpg');
      }
    }
    return null;
  }
}

class _CoverSource {
  const _CoverSource(this.bytes, this.extension);

  final List<int> bytes;
  final String extension;
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/unit/core/rip_cover_extractor_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/utils/rip_cover_extractor.dart \
  test/unit/core/rip_cover_extractor_test.dart \
  pubspec.yaml pubspec.lock
git commit -m "feat(rips): add rip cover extractor with folder-image priority"
```

---

### Task 4: Scan pipeline wiring

**Files:**
- Modify: `lib/domain/usecases/scan_rip_library_usecase.dart`
- Modify: `lib/presentation/providers/rip_provider.dart` (`RipScanNotifier.startScan`)
- Test: `test/unit/domain/scan_rip_library_usecase_test.dart` (create)

**Interfaces:**
- Consumes: `RipCoverExtractor.extractCover(...)` (Task 3); `RipAlbum.coverPath` (Task 1); `getApplicationSupportDirectory()` from `package:path_provider`.
- Produces: `ScanRipLibraryUseCase.execute(String rootPath, {String? coverCacheDir})` — when `coverCacheDir` is null, artwork extraction is skipped entirely.

- [ ] **Step 1: Write the failing scan test**

Create `test/unit/domain/scan_rip_library_usecase_test.dart`:

```dart
/// Unit tests for [ScanRipLibraryUseCase] cover-art wiring.
///
/// Uses a real temporary library directory (the scanner walks the
/// filesystem in an isolate) with a mocked repository.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/scan_rip_library_usecase.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class FakeRipAlbum extends Fake implements RipAlbum {}

void main() {
  late MockRipLibraryRepository mockRepo;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(FakeRipAlbum());
    registerFallbackValue(<RipTrack>[]);
  });

  setUp(() async {
    mockRepo = MockRipLibraryRepository();
    tempDir = await Directory.systemTemp.createTemp('mms_scan_cover_');
    when(() => mockRepo.getAllNonDeleted())
        .thenAnswer((_) async => <RipAlbum>[]);
    when(() => mockRepo.insertAlbumWithTracks(any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<Directory> makeAlbumDir() async {
    final albumDir = await Directory(
            '${tempDir.path}/library/Artist/Album')
        .create(recursive: true);
    // The audio file's contents don't matter for cover extraction from
    // a folder image; an unparseable FLAC still forms an album.
    await File('${albumDir.path}/01 track.flac')
        .writeAsBytes([0, 1, 2, 3]);
    return albumDir;
  }

  test('persists coverPath when a folder image exists and a cache dir '
      'is supplied', () async {
    final albumDir = await makeAlbumDir();
    await File('${albumDir.path}/cover.jpg').writeAsBytes([9, 9, 9]);

    final useCase = ScanRipLibraryUseCase(repository: mockRepo);
    await useCase
        .execute('${tempDir.path}/library',
            coverCacheDir: '${tempDir.path}/cache')
        .drain<void>();

    final album = verify(
      () => mockRepo.insertAlbumWithTracks(captureAny(), any()),
    ).captured.single as RipAlbum;
    expect(album.coverPath, isNotNull);
    expect(File(album.coverPath!).existsSync(), isTrue);
  });

  test('coverPath stays null when no cache dir is supplied', () async {
    final albumDir = await makeAlbumDir();
    await File('${albumDir.path}/cover.jpg').writeAsBytes([9, 9, 9]);

    final useCase = ScanRipLibraryUseCase(repository: mockRepo);
    await useCase.execute('${tempDir.path}/library').drain<void>();

    final album = verify(
      () => mockRepo.insertAlbumWithTracks(captureAny(), any()),
    ).captured.single as RipAlbum;
    expect(album.coverPath, isNull);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/unit/domain/scan_rip_library_usecase_test.dart`
Expected: FAIL — `execute` has no `coverCacheDir` parameter (compile
error), or `coverPath` is null once it compiles.

- [ ] **Step 3: Wire extraction through the scanner**

In `lib/domain/usecases/scan_rip_library_usecase.dart`:

Add the import:

```dart
import 'package:mymediascanner/core/utils/rip_cover_extractor.dart';
```

Change the `execute` signature and the isolate call (the closure may
only capture plain strings):

```dart
  Stream<RipScanProgress> execute(
    String rootPath, {
    String? coverCacheDir,
  }) async* {
    // Phase 1: Scan files in an isolate to avoid blocking the UI
    final scanResults =
        await Isolate.run(() => _scanDirectory(rootPath, coverCacheDir));
```

Change `_scanDirectory`'s signature:

```dart
  static Future<List<_AlbumScanResult>> _scanDirectory(
    String rootPath,
    String? coverCacheDir,
  ) async {
```

In the per-directory loop (where `relativePath` is computed, ~line
268), extract the cover after `relativePath` and pass it into the
result:

```dart
      // Make path relative to root for consistent matching
      final relativePath = dirPath.startsWith(rootPath)
          ? dirPath.substring(rootPath.length).replaceAll(RegExp(r'^[/\\]'), '')
          : dirPath;

      String? coverPath;
      if (coverCacheDir != null) {
        coverPath = await RipCoverExtractor.extractCover(
          albumDirPath: dirPath,
          relativePath: relativePath,
          audioFilePaths: files.map((f) => f.path).toList(),
          cacheDirPath: coverCacheDir,
        );
      }

      results.add(_AlbumScanResult(
        directoryPath: relativePath,
        artist: firstTrackMeta?.effectiveArtist,
        albumTitle: firstTrackMeta?.album,
        barcode: firstTrackMeta?.barcode,
        trackCount: tracks.length,
        discCount: maxDisc,
        totalSizeBytes: totalSize,
        tracks: tracks,
        coverPath: coverPath,
      ));
```

Add the field to `_AlbumScanResult`:

```dart
    this.cueFilePath,
    this.coverPath,
  });
  ...
  final String? coverPath;
```

In the upsert loop in `execute`, add `coverPath: result.coverPath,`
to BOTH `RipAlbum(` constructions (the `existing != null` update at
~line 121 and the insert at ~line 144), next to `cueFilePath`.

The CUE-sheet branch immediately below (~line 313) calls
`results.removeLast()` and re-adds its own `_AlbumScanResult` — add
`coverPath: coverPath,` to that construction too (next to
`cueFilePath: cueRelativePath,`; the `coverPath` local is still in
scope).

The later "CUE files in directories with no audio files" loop
(~line 331 onward) also builds `_AlbumScanResult`s. Those directories
can still carry a folder image, so before that loop's `results.add`,
compute:

```dart
      String? cueCoverPath;
      if (coverCacheDir != null) {
        cueCoverPath = await RipCoverExtractor.extractCover(
          albumDirPath: dirPath,
          relativePath: relativePath,
          audioFilePaths: const [],
          cacheDirPath: coverCacheDir,
        );
      }
```

(placed after that loop's own `relativePath` is computed) and pass
`coverPath: cueCoverPath,` into its `_AlbumScanResult`.

- [ ] **Step 4: Run the scan tests to verify they pass**

Run: `flutter test test/unit/domain/scan_rip_library_usecase_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Resolve the cache directory in the scan notifier**

In `lib/presentation/providers/rip_provider.dart`, add the import:

```dart
import 'package:path_provider/path_provider.dart';
```

In `RipScanNotifier.startScan`, resolve the cache directory before
constructing the use case and pass it through:

```dart
  Future<void> startScan(String rootPath) async {
    if (state.status == RipScanStatus.scanning) return;

    state = const RipScanState(status: RipScanStatus.scanning);

    // Resolve the cover cache directory up front; on platforms or in
    // tests where the channel is unavailable, scan without artwork.
    String? coverCacheDir;
    try {
      final supportDir = await getApplicationSupportDirectory();
      coverCacheDir = '${supportDir.path}/rip_covers';
    } catch (_) {
      coverCacheDir = null;
    }

    try {
      final scanUseCase = ScanRipLibraryUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
      );

      await for (final progress
          in scanUseCase.execute(rootPath, coverCacheDir: coverCacheDir)) {
```

(The remainder of the method is unchanged.)

- [ ] **Step 6: Run the full suite and analyser**

Run: `flutter test` then `flutter analyze`
Expected: all tests pass (the existing `rip_scan_notifier_test.dart`
must stay green — the try/catch keeps it channel-free), no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/domain/usecases/scan_rip_library_usecase.dart \
  lib/presentation/providers/rip_provider.dart \
  test/unit/domain/scan_rip_library_usecase_test.dart
git commit -m "feat(rips): extract and cache album covers during library scan"
```

---

### Task 5: `RipCoverThumb` widget + card and dialog wiring

**Files:**
- Create: `lib/presentation/screens/rips/widgets/rip_cover_thumb.dart`
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` (`_RipAlbumCard`, ~line 398)
- Modify: `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart` (~line 286)
- Test: `test/widget/presentation/screens/rips/rip_cover_thumb_test.dart` (create)

**Interfaces:**
- Consumes: `RipAlbum.coverPath` (Task 1).
- Produces: `RipCoverThumb({Key? key, required String? coverPath, double size = 76})` — square, rounded-corner cover image with a disc-icon placeholder for null/broken paths.

- [ ] **Step 1: Write the failing widget test**

Create `test/widget/presentation/screens/rips/rip_cover_thumb_test.dart`:

```dart
/// Widget tests for [RipCoverThumb].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_cover_thumb.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('shows the disc placeholder when coverPath is null',
      (tester) async {
    await pump(tester, const RipCoverThumb(coverPath: null));

    expect(find.byIcon(Icons.album), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the disc placeholder when the file does not exist',
      (tester) async {
    await pump(
      tester,
      const RipCoverThumb(coverPath: '/nonexistent/cover.jpg'),
    );
    await tester.pump();

    // Image.file errors asynchronously; errorBuilder swaps in the icon.
    expect(find.byIcon(Icons.album), findsOneWidget);
  });

  testWidgets('respects the requested size', (tester) async {
    await pump(tester, const RipCoverThumb(coverPath: null, size: 120));

    final box = tester.getSize(find.byType(RipCoverThumb));
    expect(box.width, 120);
    expect(box.height, 120);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget/presentation/screens/rips/rip_cover_thumb_test.dart`
Expected: FAIL — `rip_cover_thumb.dart` does not exist.

- [ ] **Step 3: Implement the widget**

Create `lib/presentation/screens/rips/widgets/rip_cover_thumb.dart`:

```dart
/// Square album-cover thumbnail for the rip library.
///
/// Renders the locally cached cover image at [coverPath]; falls back
/// to a tonal disc-icon placeholder when there is no cover or the
/// cached file cannot be loaded.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

import 'package:flutter/material.dart';

class RipCoverThumb extends StatelessWidget {
  const RipCoverThumb({
    super.key,
    required this.coverPath,
    this.size = 76,
  });

  /// Absolute path of the cached cover image, or null when the album
  /// has no artwork.
  final String? coverPath;

  /// Width and height of the square thumbnail.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: size,
      height: size,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.album,
        size: size * 0.45,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    final path = coverPath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: path == null
          ? placeholder
          : Image.file(
              File(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
```

- [ ] **Step 4: Run the widget tests to verify they pass**

Run: `flutter test test/widget/presentation/screens/rips/rip_cover_thumb_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Wire the thumbnail into the album card**

In `lib/presentation/screens/rips/widgets/rip_library_view.dart` add
the import:

```dart
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_cover_thumb.dart';
```

In `_RipAlbumCard.build` (~line 398), the card body currently starts:

```dart
        child: Stack(
          children: [
            Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
```

Wrap the existing `Column` in a `Row` with the thumbnail leading:

```dart
        child: Stack(
          children: [
            Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RipCoverThumb(coverPath: album.coverPath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ...the existing children, unchanged...
                  ],
                ),
              ),
            ],
          ),
```

Keep every existing child of the old `Column` (artist text, title
text, `Spacer`, the two `Row`s) exactly as they are — only the
indentation moves. Close the new `Expanded`/`Row` brackets where the
old `Column` closed.

- [ ] **Step 6: Wire the cover into the detail dialog**

In `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart`
add the same import, then after the `libraryPath` `Text` block and its
following `const SizedBox(height: 16),` (~line 287), insert:

```dart
              Align(
                alignment: Alignment.centerLeft,
                child: RipCoverThumb(
                  coverPath: widget.album.coverPath,
                  size: 140,
                ),
              ),
              const SizedBox(height: 16),
```

- [ ] **Step 7: Run the full suite and analyser**

Run: `flutter test` then `flutter analyze`
Expected: all tests pass, no issues.

- [ ] **Step 8: Commit**

```bash
git add lib/presentation/screens/rips/widgets/rip_cover_thumb.dart \
  lib/presentation/screens/rips/widgets/rip_library_view.dart \
  lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart \
  test/widget/presentation/screens/rips/rip_cover_thumb_test.dart
git commit -m "feat(rips): show album cover art on rip cards and detail dialog"
```

---

### Task 6: End-to-end verification

**Files:** none (verification only)

**Interfaces:**
- Consumes: everything above.
- Produces: visual confirmation that scanned albums show artwork.

- [ ] **Step 1: Full suite + analyser**

Run: `flutter test` and `flutter analyze`
Expected: all tests pass, no issues.

- [ ] **Step 2: Run the app and rescan**

Run: `flutter run -d macos`, open **Rips**, press **Scan Library**
(the library path and sandbox bookmark persist from settings). Wait
for the scan to complete.

Expected:
- Albums whose FLACs carry embedded pictures (117 of 160 files in the
  reference library) show cover thumbnails on their cards.
- Albums without artwork show the disc-icon placeholder.
- Opening an album shows the larger cover in the detail dialog.
- `~/Library/Containers/com.paulsnow.mymediascanner/Data/Library/Application Support/<app>/rip_covers/`
  contains one image per album with artwork.

- [ ] **Step 3: Verify the database**

Run:
```bash
sqlite3 ~/Library/Containers/com.paulsnow.mymediascanner/Data/Documents/mymediascanner.db.sqlite \
  "SELECT COUNT(*), SUM(cover_path IS NOT NULL) FROM rip_albums WHERE deleted=0;"
```
Expected: 20 albums, most with a non-null `cover_path`.

- [ ] **Step 4: Commit any straggler regenerated files**

```bash
git status --short   # expect clean; commit stragglers if any
```
