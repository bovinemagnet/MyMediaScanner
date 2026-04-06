# MyMediaScanner Slice 1: Scaffold + Core Infrastructure

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Create the Flutter project scaffold with full directory structure, database, domain entities, core utilities, theme, navigation, and adaptive layout — a runnable app shell on macOS.

**Architecture:** Clean architecture with domain/data/presentation layers. Riverpod v3 codegen for state, Drift for SQLite, Freezed for entities, GoRouter for navigation.

**Tech Stack:** Flutter 3.41, Dart 3.11, Riverpod 3.x, Drift 2.x, Freezed 2.x, GoRouter 14.x

**Author:** Paul Snow

---

## File Structure (Slice 1)

```
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
      app_theme.dart
      app_colors.dart
  core/
    constants/
      api_constants.dart
      app_constants.dart
    errors/
      app_exception.dart
      failure.dart
    extensions/
      string_extensions.dart
      datetime_extensions.dart
    utils/
      barcode_utils.dart
      platform_utils.dart
  data/
    local/
      database/
        app_database.dart
        tables/
          media_items_table.dart
          tags_table.dart
          media_item_tags_table.dart
          shelves_table.dart
          shelf_items_table.dart
          barcode_cache_table.dart
          sync_log_table.dart
      dao/
        media_items_dao.dart
        tags_dao.dart
        shelves_dao.dart
        barcode_cache_dao.dart
        sync_log_dao.dart
  domain/
    entities/
      media_item.dart
      media_type.dart
      metadata_result.dart
      tag.dart
      shelf.dart
    repositories/
      i_media_item_repository.dart
      i_metadata_repository.dart
      i_tag_repository.dart
      i_shelf_repository.dart
      i_sync_repository.dart
  presentation/
    providers/
      database_provider.dart
      repository_providers.dart
    screens/
      collection/
        collection_screen.dart
      scanner/
        scanner_screen.dart
      shelves/
        shelves_screen.dart
      settings/
        settings_screen.dart
    widgets/
      app_scaffold.dart
      empty_state.dart
      error_state.dart
      loading_indicator.dart
test/
  unit/
    core/
      barcode_utils_test.dart
    data/
      dao/
        media_items_dao_test.dart
  widget/
    presentation/
      app_scaffold_test.dart
```

---

## Task 1: Create Flutter Project

**Files:**
- Create: entire project scaffold via `flutter create`

- [x] **Step 1: Create Flutter project**

```bash
cd /Users/paul/gitHub
rm -rf MyMediaScanner/.git MyMediaScanner/CLAUDE.md MyMediaScanner/docs
# Preserve docs and CLAUDE.md
mv MyMediaScanner/docs /tmp/mms_docs_backup
mv MyMediaScanner/CLAUDE.md /tmp/mms_claude_backup
```

Actually, since the repo already exists with docs and CLAUDE.md, we create the Flutter project in a temp location and move files in:

```bash
cd /tmp
flutter create --org com.paulsnow --project-name mymediascanner --platforms android,macos mymediascanner_tmp
```

Then copy Flutter project files into the existing repo:

```bash
cp -r /tmp/mymediascanner_tmp/* /Users/paul/gitHub/MyMediaScanner/
cp /tmp/mymediascanner_tmp/.gitignore /Users/paul/gitHub/MyMediaScanner/
cp -r /tmp/mymediascanner_tmp/.metadata /Users/paul/gitHub/MyMediaScanner/
rm -rf /tmp/mymediascanner_tmp
```

- [x] **Step 2: Verify project runs on macOS**

```bash
cd /Users/paul/gitHub/MyMediaScanner
flutter run -d macos --debug
```

Expected: Default Flutter counter app launches on macOS.

- [x] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: scaffold Flutter project for Android and macOS"
```

---

## Task 2: Add Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [x] **Step 1: Add all dependencies**

```bash
cd /Users/paul/gitHub/MyMediaScanner

# Main dependencies
flutter pub add flutter_riverpod riverpod_annotation go_router \
  drift drift_flutter sqlite3_flutter_libs \
  postgres dio retrofit \
  mobile_scanner flutter_secure_storage cached_network_image \
  freezed_annotation json_annotation uuid intl path_provider

# Note: drift_flutter is required for cross-platform database setup (driftDatabase function)

# Dev dependencies
flutter pub add --dev build_runner drift_dev riverpod_generator \
  freezed json_serializable retrofit_generator mocktail
```

- [x] **Step 2: Verify resolution**

```bash
flutter pub get
```

Expected: No version conflicts.

- [x] **Step 3: Update analysis_options.yaml**

Replace contents of `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
    sort_constructors_first: true
    unawaited_futures: true
```

- [x] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml
git commit -m "feat: add all project dependencies"
```

---

## Task 3: Core — Error Types

**Files:**
- Create: `lib/core/errors/app_exception.dart`
- Create: `lib/core/errors/failure.dart`

- [x] **Step 1: Create app_exception.dart**

```dart
/// Sealed exception hierarchy for the data layer.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.cause]);
}

class ApiException extends AppException {
  const ApiException(String message, {this.statusCode, Object? cause})
      : super(message, cause);

  final int? statusCode;
}

class SyncException extends AppException {
  const SyncException(super.message, [super.cause]);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.cause]);
}
```

- [x] **Step 2: Create failure.dart**

```dart
/// Domain-layer failure types surfaced via Riverpod AsyncError.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error']);
}

class ApiFailure extends Failure {
  const ApiFailure([super.message = 'API error']);

  const ApiFailure.notFound() : this('Resource not found');
}

class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Sync error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}
```

- [x] **Step 3: Commit**

```bash
git add lib/core/errors/
git commit -m "feat: add sealed exception and failure hierarchies"
```

---

## Task 4: Core — Constants

**Files:**
- Create: `lib/core/constants/api_constants.dart`
- Create: `lib/core/constants/app_constants.dart`

- [x] **Step 1: Create api_constants.dart**

```dart
abstract final class ApiConstants {
  // TMDB
  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Discogs
  static const discogsBaseUrl = 'https://api.discogs.com';

  // Google Books
  static const googleBooksBaseUrl = 'https://www.googleapis.com/books/v1';

  // Open Library
  static const openLibraryBaseUrl = 'https://openlibrary.org';
  static const openLibraryCoverUrl = 'https://covers.openlibrary.org';

  // UPCitemdb
  static const upcItemDbBaseUrl = 'https://api.upcitemdb.com/prod/trial';

  // Cache
  static const cacheDurationDays = 7;
}
```

- [x] **Step 2: Create app_constants.dart**

```dart
abstract final class AppConstants {
  static const appName = 'MyMediaScanner';
  static const databaseName = 'mymediascanner.db';

  // Rating
  static const minRating = 1.0;
  static const maxRating = 5.0;

  // Breakpoints (Material 3)
  static const compactBreakpoint = 600.0;
  static const expandedBreakpoint = 1200.0;

  // Sync
  static const defaultPostgresPort = 5432;
}
```

- [x] **Step 3: Commit**

```bash
git add lib/core/constants/
git commit -m "feat: add API and app constants"
```

---

## Task 5: Core — Platform Utils

**Files:**
- Create: `lib/core/utils/platform_utils.dart`

- [x] **Step 1: Create platform_utils.dart**

```dart
import 'package:flutter/foundation.dart';

/// Platform capability detection.
/// Never use dart:io Platform directly in presentation layer.
abstract final class PlatformCapability {
  static bool get canUseCamera =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get usesKeyboardScanner => isDesktop;
}
```

- [x] **Step 2: Commit**

```bash
git add lib/core/utils/platform_utils.dart
git commit -m "feat: add platform capability detection utility"
```

---

## Task 6: Core — Barcode Utils with Tests

**Files:**
- Create: `lib/core/utils/barcode_utils.dart`
- Create: `test/unit/core/barcode_utils_test.dart`

- [x] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/barcode_utils.dart';

void main() {
  group('BarcodeUtils', () {
    group('detectBarcodeType', () {
      test('detects ISBN-13 starting with 978', () {
        expect(
          BarcodeUtils.detectBarcodeType('9780141036144'),
          BarcodeType.isbn13,
        );
      });

      test('detects ISBN-13 starting with 979', () {
        expect(
          BarcodeUtils.detectBarcodeType('9791234567890'),
          BarcodeType.isbn13,
        );
      });

      test('detects ISBN-10', () {
        expect(
          BarcodeUtils.detectBarcodeType('0141036141'),
          BarcodeType.isbn10,
        );
      });

      test('detects EAN-13', () {
        expect(
          BarcodeUtils.detectBarcodeType('5051892002172'),
          BarcodeType.ean13,
        );
      });

      test('detects UPC-A (12 digits)', () {
        expect(
          BarcodeUtils.detectBarcodeType('012345678905'),
          BarcodeType.upcA,
        );
      });

      test('returns unknown for invalid barcode', () {
        expect(
          BarcodeUtils.detectBarcodeType('abc'),
          BarcodeType.unknown,
        );
      });
    });

    group('isIsbn', () {
      test('returns true for ISBN-13', () {
        expect(BarcodeUtils.isIsbn('9780141036144'), isTrue);
      });

      test('returns true for ISBN-10', () {
        expect(BarcodeUtils.isIsbn('0141036141'), isTrue);
      });

      test('returns false for EAN-13', () {
        expect(BarcodeUtils.isIsbn('5051892002172'), isFalse);
      });
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

```bash
flutter test test/unit/core/barcode_utils_test.dart
```

Expected: FAIL — `barcode_utils.dart` does not exist yet.

- [x] **Step 3: Write implementation**

```dart
/// Barcode type detection and classification utilities.
enum BarcodeType { ean13, upcA, isbn13, isbn10, unknown }

abstract final class BarcodeUtils {
  /// Detect the barcode type from the raw string value.
  static BarcodeType detectBarcodeType(String barcode) {
    final cleaned = barcode.trim();

    if (cleaned.length == 13 && RegExp(r'^\d{13}$').hasMatch(cleaned)) {
      if (cleaned.startsWith('978') || cleaned.startsWith('979')) {
        return BarcodeType.isbn13;
      }
      return BarcodeType.ean13;
    }

    if (cleaned.length == 12 && RegExp(r'^\d{12}$').hasMatch(cleaned)) {
      return BarcodeType.upcA;
    }

    if (cleaned.length == 10 && RegExp(r'^\d{9}[\dXx]$').hasMatch(cleaned)) {
      return BarcodeType.isbn10;
    }

    return BarcodeType.unknown;
  }

  /// Returns true if the barcode is an ISBN (10 or 13).
  static bool isIsbn(String barcode) {
    final type = detectBarcodeType(barcode);
    return type == BarcodeType.isbn13 || type == BarcodeType.isbn10;
  }
}
```

- [x] **Step 4: Run test to verify it passes**

```bash
flutter test test/unit/core/barcode_utils_test.dart
```

Expected: All tests PASS.

- [x] **Step 5: Commit**

```bash
git add lib/core/utils/barcode_utils.dart test/unit/core/barcode_utils_test.dart
git commit -m "feat: add barcode type detection with tests"
```

---

## Task 7: Core — Extensions

**Files:**
- Create: `lib/core/extensions/string_extensions.dart`
- Create: `lib/core/extensions/datetime_extensions.dart`

- [x] **Step 1: Create string_extensions.dart**

```dart
extension StringExtensions on String {
  /// Capitalise first letter.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Convert to title case.
  String get titleCase =>
      split(' ').map((word) => word.capitalised).join(' ');
}
```

- [x] **Step 2: Create datetime_extensions.dart**

```dart
extension DateTimeExtensions on DateTime {
  /// Unix milliseconds timestamp.
  int get unixMillis => millisecondsSinceEpoch;

  /// Create DateTime from Unix milliseconds.
  static DateTime fromUnixMillis(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis);
}
```

- [x] **Step 3: Commit**

```bash
git add lib/core/extensions/
git commit -m "feat: add string and datetime extensions"
```

---

## Task 8: Domain — Media Type Enum

**Files:**
- Create: `lib/domain/entities/media_type.dart`

- [x] **Step 1: Create media_type.dart**

```dart
/// Media type classification.
enum MediaType {
  film('Film'),
  tv('TV'),
  music('Music'),
  book('Book'),
  game('Game'),
  unknown('Unknown');

  const MediaType(this.label);

  final String label;

  /// Parse from string, defaulting to unknown.
  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => MediaType.unknown,
    );
  }
}
```

- [x] **Step 2: Commit**

```bash
git add lib/domain/entities/media_type.dart
git commit -m "feat: add MediaType enum"
```

---

## Task 9: Domain — Freezed Entities

**Files:**
- Create: `lib/domain/entities/media_item.dart`
- Create: `lib/domain/entities/metadata_result.dart`
- Create: `lib/domain/entities/tag.dart`
- Create: `lib/domain/entities/shelf.dart`

- [x] **Step 1: Create media_item.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'media_item.freezed.dart';

@freezed
sealed class MediaItem with _$MediaItem {
  const factory MediaItem({
    required String id,
    required String barcode,
    required String barcodeType,
    required MediaType mediaType,
    required String title,
    String? subtitle,
    String? description,
    String? coverUrl,
    int? year,
    String? publisher,
    String? format,
    @Default([]) List<String> genres,
    @Default({}) Map<String, dynamic> extraMetadata,
    @Default([]) List<String> sourceApis,
    double? userRating,
    String? userReview,
    required int dateAdded,
    required int dateScanned,
    required int updatedAt,
    int? syncedAt,
    @Default(false) bool deleted,
  }) = _MediaItem;
}
```

- [x] **Step 2: Create metadata_result.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'metadata_result.freezed.dart';

@freezed
sealed class MetadataResult with _$MetadataResult {
  const factory MetadataResult({
    required String barcode,
    required String barcodeType,
    MediaType? mediaType,
    String? title,
    String? subtitle,
    String? description,
    String? coverUrl,
    int? year,
    String? publisher,
    String? format,
    @Default([]) List<String> genres,
    @Default({}) Map<String, dynamic> extraMetadata,
    @Default([]) List<String> sourceApis,
  }) = _MetadataResult;
}
```

- [x] **Step 3: Create tag.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

@freezed
sealed class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String name,
    String? colour,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Tag;
}
```

- [x] **Step 4: Create shelf.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shelf.freezed.dart';

@freezed
sealed class Shelf with _$Shelf {
  const factory Shelf({
    required String id,
    required String name,
    String? description,
    @Default(0) int sortOrder,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Shelf;
}
```

- [x] **Step 5: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates `.freezed.dart` files for all four entities.

- [x] **Step 6: Commit**

```bash
git add lib/domain/entities/
git commit -m "feat: add Freezed domain entities"
```

---

## Task 10: Domain — Repository Interfaces

**Files:**
- Create: `lib/domain/repositories/i_media_item_repository.dart`
- Create: `lib/domain/repositories/i_metadata_repository.dart`
- Create: `lib/domain/repositories/i_tag_repository.dart`
- Create: `lib/domain/repositories/i_shelf_repository.dart`
- Create: `lib/domain/repositories/i_sync_repository.dart`

- [x] **Step 1: Create i_media_item_repository.dart**

```dart
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

abstract interface class IMediaItemRepository {
  Stream<List<MediaItem>> watchAll({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  });

  Future<MediaItem?> getById(String id);
  Future<bool> barcodeExists(String barcode);
  Future<void> save(MediaItem item);
  Future<void> update(MediaItem item);
  Future<void> softDelete(String id);
  Future<List<MediaItem>> getUnsynced();
  Future<void> markSynced(String id, int syncedAt);
}
```

- [x] **Step 2: Create i_metadata_repository.dart**

```dart
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract interface class IMetadataRepository {
  Future<MetadataResult> lookupBarcode(
    String barcode, {
    MediaType? typeHint,
  });
}
```

- [x] **Step 3: Create i_tag_repository.dart**

```dart
import 'package:mymediascanner/domain/entities/tag.dart';

abstract interface class ITagRepository {
  Stream<List<Tag>> watchAll();
  Future<Tag?> getById(String id);
  Future<void> save(Tag tag);
  Future<void> softDelete(String id);
  Future<void> assignToMediaItem(String tagId, String mediaItemId);
  Future<void> removeFromMediaItem(String tagId, String mediaItemId);
  Future<List<String>> getTagIdsForMediaItem(String mediaItemId);
}
```

- [x] **Step 4: Create i_shelf_repository.dart**

```dart
import 'package:mymediascanner/domain/entities/shelf.dart';

abstract interface class IShelfRepository {
  Stream<List<Shelf>> watchAll();
  Future<Shelf?> getById(String id);
  Future<void> save(Shelf shelf);
  Future<void> softDelete(String id);
  Future<void> addItem(String shelfId, String mediaItemId, int position);
  Future<void> removeItem(String shelfId, String mediaItemId);
  Future<List<String>> getMediaItemIdsForShelf(String shelfId);
  Future<void> reorderItem(String shelfId, String mediaItemId, int newPosition);
}
```

- [x] **Step 5: Create i_sync_repository.dart**

```dart
abstract interface class ISyncRepository {
  Future<void> pushChanges();
  Future<void> pullChanges();
  Future<bool> testConnection();
  Future<void> resetLocalDatabase();
  Stream<SyncStatus> watchSyncStatus();
}

class SyncStatus {
  const SyncStatus({
    required this.pendingCount,
    this.lastSyncedAt,
    this.isSyncing = false,
    this.error,
  });

  final int pendingCount;
  final int? lastSyncedAt;
  final bool isSyncing;
  final String? error;
}
```

- [x] **Step 6: Commit**

```bash
git add lib/domain/repositories/
git commit -m "feat: add domain repository interfaces"
```

---

## Task 11: Database — Drift Tables

**Files:**
- Create: `lib/data/local/database/tables/media_items_table.dart`
- Create: `lib/data/local/database/tables/tags_table.dart`
- Create: `lib/data/local/database/tables/media_item_tags_table.dart`
- Create: `lib/data/local/database/tables/shelves_table.dart`
- Create: `lib/data/local/database/tables/shelf_items_table.dart`
- Create: `lib/data/local/database/tables/barcode_cache_table.dart`
- Create: `lib/data/local/database/tables/sync_log_table.dart`

- [x] **Step 1: Create media_items_table.dart**

```dart
import 'package:drift/drift.dart';

class MediaItemsTable extends Table {
  @override
  String get tableName => 'media_items';

  TextColumn get id => text()();
  TextColumn get barcode => text()();
  TextColumn get barcodeType => text()();
  TextColumn get mediaType => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get genres => text().withDefault(const Constant('[]'))();
  TextColumn get extraMetadata => text().withDefault(const Constant('{}'))();
  TextColumn get sourceApis => text().withDefault(const Constant('[]'))();
  RealColumn get userRating => real().nullable()();
  TextColumn get userReview => text().nullable()();
  IntColumn get dateAdded => integer()();
  IntColumn get dateScanned => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get syncedAt => integer().nullable()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [x] **Step 2: Create tags_table.dart**

```dart
import 'package:drift/drift.dart';

class TagsTable extends Table {
  @override
  String get tableName => 'tags';

  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get colour => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [x] **Step 3: Create media_item_tags_table.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/tags_table.dart';

class MediaItemTagsTable extends Table {
  @override
  String get tableName => 'media_item_tags';

  TextColumn get mediaItemId =>
      text().references(MediaItemsTable, #id)();
  TextColumn get tagId =>
      text().references(TagsTable, #id)();

  @override
  Set<Column> get primaryKey => {mediaItemId, tagId};
}
```

- [x] **Step 4: Create shelves_table.dart**

```dart
import 'package:drift/drift.dart';

class ShelvesTable extends Table {
  @override
  String get tableName => 'shelves';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [x] **Step 5: Create shelf_items_table.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/shelves_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';

class ShelfItemsTable extends Table {
  @override
  String get tableName => 'shelf_items';

  TextColumn get shelfId =>
      text().references(ShelvesTable, #id)();
  TextColumn get mediaItemId =>
      text().references(MediaItemsTable, #id)();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {shelfId, mediaItemId};
}
```

- [x] **Step 6: Create barcode_cache_table.dart**

```dart
import 'package:drift/drift.dart';

class BarcodeCacheTable extends Table {
  @override
  String get tableName => 'barcode_cache';

  TextColumn get barcode => text()();
  TextColumn get mediaTypeHint => text().nullable()();
  TextColumn get responseJson => text()();
  TextColumn get sourceApi => text()();
  IntColumn get cachedAt => integer()();

  @override
  Set<Column> get primaryKey => {barcode};
}
```

- [x] **Step 7: Create sync_log_table.dart**

```dart
import 'package:drift/drift.dart';

class SyncLogTable extends Table {
  @override
  String get tableName => 'sync_log';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdAt => integer()();
  IntColumn get attemptedAt => integer().nullable()();
  IntColumn get synced => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [x] **Step 8: Commit**

```bash
git add lib/data/local/database/tables/
git commit -m "feat: add all Drift table definitions"
```

---

## Task 12: Database — DAOs

**Files:**
- Create: `lib/data/local/dao/media_items_dao.dart`
- Create: `lib/data/local/dao/tags_dao.dart`
- Create: `lib/data/local/dao/shelves_dao.dart`
- Create: `lib/data/local/dao/barcode_cache_dao.dart`
- Create: `lib/data/local/dao/sync_log_dao.dart`

- [x] **Step 1: Create media_items_dao.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';

part 'media_items_dao.g.dart';

@DriftAccessor(tables: [MediaItemsTable])
class MediaItemsDao extends DatabaseAccessor<AppDatabase>
    with _$MediaItemsDaoMixin {
  MediaItemsDao(super.db);

  Stream<List<MediaItemsTableData>> watchAll({bool includeDeleted = false}) {
    final query = select(mediaItemsTable);
    if (!includeDeleted) {
      query.where((t) => t.deleted.equals(0));
    }
    return query.watch();
  }

  Future<MediaItemsTableData?> getById(String id) {
    return (select(mediaItemsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> barcodeExists(String barcode) async {
    final query = select(mediaItemsTable)
      ..where((t) => t.barcode.equals(barcode))
      ..where((t) => t.deleted.equals(0))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<void> insertItem(MediaItemsTableCompanion item) {
    return into(mediaItemsTable).insert(item);
  }

  Future<void> updateItem(MediaItemsTableCompanion item) {
    return (update(mediaItemsTable)
          ..where((t) => t.id.equals(item.id.value)))
        .write(item);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(mediaItemsTable)..where((t) => t.id.equals(id))).write(
      MediaItemsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<List<MediaItemsTableData>> getUnsynced() {
    return customSelect(
      'SELECT * FROM media_items WHERE synced_at IS NULL OR updated_at > synced_at',
      readsFrom: {mediaItemsTable},
    ).map((row) => mediaItemsTable.map(row.data)).get();
  }

  Future<void> markSynced(String id, int syncedAt) {
    return (update(mediaItemsTable)..where((t) => t.id.equals(id))).write(
      MediaItemsTableCompanion(syncedAt: Value(syncedAt)),
    );
  }
}
```

- [x] **Step 2: Create tags_dao.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/tags_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_item_tags_table.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [TagsTable, MediaItemTagsTable])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Stream<List<TagsTableData>> watchAll() {
    return (select(tagsTable)..where((t) => t.deleted.equals(0))).watch();
  }

  Future<TagsTableData?> getById(String id) {
    return (select(tagsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertTag(TagsTableCompanion tag) {
    return into(tagsTable).insert(tag);
  }

  Future<void> updateTag(TagsTableCompanion tag) {
    return (update(tagsTable)..where((t) => t.id.equals(tag.id.value)))
        .write(tag);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(tagsTable)..where((t) => t.id.equals(id))).write(
      TagsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> assignToMediaItem(String tagId, String mediaItemId) {
    return into(mediaItemTagsTable).insert(
      MediaItemTagsTableCompanion(
        tagId: Value(tagId),
        mediaItemId: Value(mediaItemId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeFromMediaItem(String tagId, String mediaItemId) {
    return (delete(mediaItemTagsTable)
          ..where(
              (t) => t.tagId.equals(tagId) & t.mediaItemId.equals(mediaItemId)))
        .go();
  }

  Future<List<String>> getTagIdsForMediaItem(String mediaItemId) async {
    final rows = await (select(mediaItemTagsTable)
          ..where((t) => t.mediaItemId.equals(mediaItemId)))
        .get();
    return rows.map((r) => r.tagId).toList();
  }
}
```

- [x] **Step 3: Create shelves_dao.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/shelves_table.dart';
import 'package:mymediascanner/data/local/database/tables/shelf_items_table.dart';

part 'shelves_dao.g.dart';

@DriftAccessor(tables: [ShelvesTable, ShelfItemsTable])
class ShelvesDao extends DatabaseAccessor<AppDatabase>
    with _$ShelvesDaoMixin {
  ShelvesDao(super.db);

  Stream<List<ShelvesTableData>> watchAll() {
    return (select(shelvesTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<ShelvesTableData?> getById(String id) {
    return (select(shelvesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertShelf(ShelvesTableCompanion shelf) {
    return into(shelvesTable).insert(shelf);
  }

  Future<void> updateShelf(ShelvesTableCompanion shelf) {
    return (update(shelvesTable)..where((t) => t.id.equals(shelf.id.value)))
        .write(shelf);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(shelvesTable)..where((t) => t.id.equals(id))).write(
      ShelvesTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> addItem(String shelfId, String mediaItemId, int position) {
    return into(shelfItemsTable).insert(
      ShelfItemsTableCompanion(
        shelfId: Value(shelfId),
        mediaItemId: Value(mediaItemId),
        position: Value(position),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> removeItem(String shelfId, String mediaItemId) {
    return (delete(shelfItemsTable)
          ..where((t) =>
              t.shelfId.equals(shelfId) &
              t.mediaItemId.equals(mediaItemId)))
        .go();
  }

  Future<List<String>> getMediaItemIdsForShelf(String shelfId) async {
    final rows = await (select(shelfItemsTable)
          ..where((t) => t.shelfId.equals(shelfId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => r.mediaItemId).toList();
  }
}
```

- [x] **Step 4: Create barcode_cache_dao.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/barcode_cache_table.dart';

part 'barcode_cache_dao.g.dart';

@DriftAccessor(tables: [BarcodeCacheTable])
class BarcodeCacheDao extends DatabaseAccessor<AppDatabase>
    with _$BarcodeCacheDaoMixin {
  BarcodeCacheDao(super.db);

  Future<BarcodeCacheTableData?> getByBarcode(String barcode) {
    return (select(barcodeCacheTable)
          ..where((t) => t.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  Future<void> upsert(BarcodeCacheTableCompanion entry) {
    return into(barcodeCacheTable).insertOnConflictUpdate(entry);
  }

  Future<void> deleteExpired(int maxAgeMillis) {
    final cutoff = DateTime.now().millisecondsSinceEpoch - maxAgeMillis;
    return (delete(barcodeCacheTable)
          ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
```

- [x] **Step 5: Create sync_log_dao.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/sync_log_table.dart';

part 'sync_log_dao.g.dart';

@DriftAccessor(tables: [SyncLogTable])
class SyncLogDao extends DatabaseAccessor<AppDatabase>
    with _$SyncLogDaoMixin {
  SyncLogDao(super.db);

  Future<List<SyncLogTableData>> getPending() {
    return (select(syncLogTable)
          ..where((t) => t.synced.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<int> watchPendingCount() {
    return (selectOnly(syncLogTable)
          ..where(syncLogTable.synced.equals(0))
          ..addColumns([syncLogTable.id.count()]))
        .map((row) => row.read(syncLogTable.id.count()) ?? 0)
        .watchSingle();
  }

  Future<void> insertLog(SyncLogTableCompanion log) {
    return into(syncLogTable).insert(log);
  }

  Future<void> markSynced(String id) {
    return (update(syncLogTable)..where((t) => t.id.equals(id))).write(
      const SyncLogTableCompanion(synced: Value(1)),
    );
  }

  Future<void> deleteAll() {
    return delete(syncLogTable).go();
  }
}
```

- [x] **Step 6: Commit**

```bash
git add lib/data/local/dao/
git commit -m "feat: add all Drift DAOs"
```

---

## Task 13: Database — AppDatabase + Code Generation

**Files:**
- Create: `lib/data/local/database/app_database.dart`

- [x] **Step 1: Create app_database.dart**

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/tags_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_item_tags_table.dart';
import 'package:mymediascanner/data/local/database/tables/shelves_table.dart';
import 'package:mymediascanner/data/local/database/tables/shelf_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/barcode_cache_table.dart';
import 'package:mymediascanner/data/local/database/tables/sync_log_table.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MediaItemsTable,
    TagsTable,
    MediaItemTagsTable,
    ShelvesTable,
    ShelfItemsTable,
    BarcodeCacheTable,
    SyncLogTable,
  ],
  daos: [
    MediaItemsDao,
    TagsDao,
    ShelvesDao,
    BarcodeCacheDao,
    SyncLogDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: AppConstants.databaseName,
                native: const DriftNativeOptions(
                  shareAcrossIsolates: true,
                ),
              ),
        );

  /// In-memory constructor for testing.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
```

- [x] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates `app_database.g.dart` and all DAO `.g.dart` files.

- [x] **Step 3: Verify compilation**

```bash
flutter analyze
```

Expected: No errors.

- [x] **Step 4: Commit**

```bash
git add lib/data/local/
git commit -m "feat: add AppDatabase with all tables and DAOs"
```

---

## Task 14: Database — DAO Tests

**Files:**
- Create: `test/unit/data/dao/media_items_dao_test.dart`

- [x] **Step 1: Write DAO test**

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;
  late MediaItemsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.mediaItemsDao;
  });

  tearDown(() => db.close());

  group('MediaItemsDao', () {
    MediaItemsTableCompanion createTestItem({
      String id = 'test-id',
      String barcode = '9780141036144',
      int deleted = 0,
    }) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return MediaItemsTableCompanion(
        id: Value(id),
        barcode: Value(barcode),
        barcodeType: const Value('isbn13'),
        mediaType: const Value('book'),
        title: const Value('Test Book'),
        dateAdded: Value(now),
        dateScanned: Value(now),
        updatedAt: Value(now),
        deleted: Value(deleted),
      );
    }

    test('insertItem and getById returns item', () async {
      await dao.insertItem(createTestItem());
      final result = await dao.getById('test-id');
      expect(result, isNotNull);
      expect(result!.title, 'Test Book');
    });

    test('barcodeExists returns true for existing barcode', () async {
      await dao.insertItem(createTestItem());
      expect(await dao.barcodeExists('9780141036144'), isTrue);
    });

    test('barcodeExists returns false for missing barcode', () async {
      expect(await dao.barcodeExists('0000000000000'), isFalse);
    });

    test('softDelete sets deleted flag', () async {
      await dao.insertItem(createTestItem());
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.softDelete('test-id', now);
      final result = await dao.getById('test-id');
      expect(result!.deleted, 1);
    });

    test('watchAll excludes deleted items by default', () async {
      await dao.insertItem(createTestItem(id: 'a'));
      await dao.insertItem(createTestItem(id: 'b', barcode: '1234567890123', deleted: 1));

      final items = await dao.watchAll().first;
      expect(items.length, 1);
      expect(items.first.id, 'a');
    });

    test('watchAll includes deleted when requested', () async {
      await dao.insertItem(createTestItem(id: 'a'));
      await dao.insertItem(createTestItem(id: 'b', barcode: '1234567890123', deleted: 1));

      final items = await dao.watchAll(includeDeleted: true).first;
      expect(items.length, 2);
    });
  });
}
```

- [x] **Step 2: Run tests**

```bash
flutter test test/unit/data/dao/media_items_dao_test.dart
```

Expected: All tests PASS.

- [x] **Step 3: Commit**

```bash
git add test/unit/data/dao/
git commit -m "test: add MediaItemsDao unit tests with in-memory database"
```

---

## Task 15: Theme

**Files:**
- Create: `lib/app/theme/app_colors.dart`
- Create: `lib/app/theme/app_theme.dart`

- [x] **Step 1: Create app_colors.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const seedColor = Color(0xFF1565C0); // Blue 800

  // Media type colours
  static const filmColor = Color(0xFFE53935);
  static const tvColor = Color(0xFFFF7043);
  static const musicColor = Color(0xFF7E57C2);
  static const bookColor = Color(0xFF43A047);
  static const gameColor = Color(0xFF1E88E5);
  static const unknownColor = Color(0xFF757575);
}
```

- [x] **Step 2: Create app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}
```

- [x] **Step 3: Commit**

```bash
git add lib/app/theme/
git commit -m "feat: add Material 3 theme with light and dark variants"
```

---

## Task 16: Shared Widgets

**Files:**
- Create: `lib/presentation/widgets/empty_state.dart`
- Create: `lib/presentation/widgets/error_state.dart`
- Create: `lib/presentation/widgets/loading_indicator.dart`

- [x] **Step 1: Create empty_state.dart**

```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
```

- [x] **Step 2: Create error_state.dart**

```dart
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [x] **Step 3: Create loading_indicator.dart**

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
```

- [x] **Step 4: Commit**

```bash
git add lib/presentation/widgets/
git commit -m "feat: add shared empty, error, and loading widgets"
```

---

## Task 17: Placeholder Screens

**Files:**
- Create: `lib/presentation/screens/collection/collection_screen.dart`
- Create: `lib/presentation/screens/scanner/scanner_screen.dart`
- Create: `lib/presentation/screens/shelves/shelves_screen.dart`
- Create: `lib/presentation/screens/settings/settings_screen.dart`

- [x] **Step 1: Create all four placeholder screens**

Each follows this pattern (example for collection):

```dart
import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Collection — coming in Slice 3'),
    );
  }
}
```

Create `scanner_screen.dart`, `shelves_screen.dart`, `settings_screen.dart` with the same pattern, adjusting the text.

- [x] **Step 2: Commit**

```bash
git add lib/presentation/screens/
git commit -m "feat: add placeholder screens for all routes"
```

---

## Task 18: AppScaffold (Adaptive Navigation)

**Files:**
- Create: `lib/presentation/widgets/app_scaffold.dart`

- [x] **Step 1: Create app_scaffold.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music),
      label: 'Collection',
    ),
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: 'Scan',
    ),
    NavigationDestination(
      icon: Icon(Icons.shelves_outlined),
      selectedIcon: Icon(Icons.shelves),
      label: 'Shelves',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  static const _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music),
      label: Text('Collection'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: Text('Scan'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shelves_outlined),
      selectedIcon: Icon(Icons.shelves),
      label: Text('Shelves'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= AppConstants.compactBreakpoint;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: width >= AppConstants.expandedBreakpoint
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              destinations: _railDestinations,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}
```

- [x] **Step 2: Commit**

```bash
git add lib/presentation/widgets/app_scaffold.dart
git commit -m "feat: add adaptive AppScaffold with nav rail and bottom nav"
```

---

## Task 19: GoRouter Setup

**Files:**
- Create: `lib/app/router.dart`

- [x] **Step 1: Create router.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_screen.dart';
import 'package:mymediascanner/presentation/screens/scanner/scanner_screen.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelves_screen.dart';
import 'package:mymediascanner/presentation/screens/settings/settings_screen.dart';
import 'package:mymediascanner/presentation/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CollectionScreen(),
              routes: [
                GoRoute(
                  path: 'item/:id',
                  builder: (context, state) => Center(
                    child: Text('Item ${state.pathParameters['id']}'),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => Center(
                        child: Text(
                            'Edit item ${state.pathParameters['id']}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scan',
              builder: (context, state) => const ScannerScreen(),
              routes: [
                GoRoute(
                  path: 'confirm',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const Center(child: Text('Confirm metadata')),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shelves',
              builder: (context, state) => const ShelvesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => Center(
                    child: Text(
                        'Shelf ${state.pathParameters['id']}'),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'postgres',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const Center(child: Text('Postgres config')),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
```

- [x] **Step 2: Commit**

```bash
git add lib/app/router.dart
git commit -m "feat: add GoRouter with all routes and adaptive shell"
```

---

## Task 20: Riverpod Providers (Database)

**Files:**
- Create: `lib/presentation/providers/database_provider.dart`
- Create: `lib/presentation/providers/repository_providers.dart`

- [x] **Step 1: Create database_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
MediaItemsDao mediaItemsDao(Ref ref) {
  return ref.watch(databaseProvider).mediaItemsDao;
}

@riverpod
TagsDao tagsDao(Ref ref) {
  return ref.watch(databaseProvider).tagsDao;
}

@riverpod
ShelvesDao shelvesDao(Ref ref) {
  return ref.watch(databaseProvider).shelvesDao;
}

@riverpod
BarcodeCacheDao barcodeCacheDao(Ref ref) {
  return ref.watch(databaseProvider).barcodeCacheDao;
}

@riverpod
SyncLogDao syncLogDao(Ref ref) {
  return ref.watch(databaseProvider).syncLogDao;
}
```

- [x] **Step 2: Create repository_providers.dart (stub)**

This file will be populated as repository implementations are built in later slices. For now, create it empty:

```dart
// Repository provider bindings — populated in Slice 2+.
```

- [x] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [x] **Step 4: Commit**

```bash
git add lib/presentation/providers/
git commit -m "feat: add Riverpod database and DAO providers"
```

---

## Task 21: App Entry Point

**Files:**
- Create: `lib/app/app.dart`
- Modify: `lib/main.dart`

- [x] **Step 1: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/router.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [x] **Step 2: Update main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
```

- [x] **Step 3: Run app on macOS**

```bash
flutter run -d macos --debug
```

Expected: App launches with adaptive navigation (nav rail on macOS), four tabs with placeholder content.

- [x] **Step 4: Commit**

```bash
git add lib/app/app.dart lib/main.dart
git commit -m "feat: add App widget and main entry point with Riverpod"
```

---

## Task 22: Verify Full Build

- [x] **Step 1: Run all code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [x] **Step 2: Run analysis**

```bash
flutter analyze
```

Expected: No errors.

- [x] **Step 3: Run all tests**

```bash
flutter test
```

Expected: All tests pass (barcode_utils_test, media_items_dao_test).

- [x] **Step 4: Run app on macOS**

```bash
flutter run -d macos
```

Expected: App launches with nav rail, four placeholder tabs.

- [x] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: complete Slice 1 — scaffold and core infrastructure"
```
