# Rips/Audio Player Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add queue/playlists, ReplayGain + speed control, batch operations, and bidirectional collection integration to the rips/audio player.

**Architecture:** Extends existing Riverpod provider architecture with new Notifier providers for queue, playlists, batch operations, and collection rip status. Two new Drift tables (playlists, playlist_tracks) for persistent playlists at schema version 10. ReplayGain and speed control integrate into existing AudioPlayerService and PlaybackActionNotifier.

**Tech Stack:** Flutter, Riverpod 3.x (hand-written Notifier/AsyncNotifier), Drift (SQLite), just_audio, Freezed, SharedPreferences

---

## Task 1: Database Migration — Playlists & Playlist Tracks Tables

**Files:**
- Create: `lib/data/local/database/tables/playlists_table.dart`
- Create: `lib/data/local/database/tables/playlist_tracks_table.dart`
- Modify: `lib/data/local/database/app_database.dart` (schema v10, register tables, migration)
- Test: `test/unit/data/dao/playlist_dao_test.dart` (created in Task 3, but migration tested here)

- [ ] **Step 1: Create playlists table definition**

Create `lib/data/local/database/tables/playlists_table.dart`:

```dart
import 'package:drift/drift.dart';

class PlaylistsTable extends Table {
  @override
  String get tableName => 'playlists';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverAlbumId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: Create playlist_tracks table definition**

Create `lib/data/local/database/tables/playlist_tracks_table.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/playlists_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_tracks_table.dart';

class PlaylistTracksTable extends Table {
  @override
  String get tableName => 'playlist_tracks';

  TextColumn get id => text()();
  TextColumn get playlistId =>
      text().references(PlaylistsTable, #id)();
  TextColumn get ripTrackId =>
      text().references(RipTracksTable, #id)();
  IntColumn get sortOrder => integer()();
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 3: Register tables in AppDatabase and add migration**

Modify `lib/data/local/database/app_database.dart`:

1. Add imports for the two new table files at the top with existing imports.
2. Add `PlaylistsTable` and `PlaylistTracksTable` to the `tables: [...]` list in `@DriftDatabase`.
3. Change `int get schemaVersion => 9;` to `int get schemaVersion => 10;`.
4. Add migration block after the existing `if (from < 9)` block:

```dart
if (from < 10) {
  await m.createTable(playlistsTable);
  await m.createTable(playlistTracksTable);
}
```

- [ ] **Step 4: Run build_runner to generate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: Successful code generation with no errors. New generated files for the tables.

- [ ] **Step 5: Verify app compiles**

Run: `flutter analyze`

Expected: No analysis errors related to the new tables.

- [ ] **Step 6: Commit**

```bash
git add lib/data/local/database/tables/playlists_table.dart \
        lib/data/local/database/tables/playlist_tracks_table.dart \
        lib/data/local/database/app_database.dart \
        lib/data/local/database/app_database.g.dart
git commit -m "feat: add playlists and playlist_tracks tables (schema v10)"
```

---

## Task 2: Playlist & QueueItem Entities

**Files:**
- Create: `lib/domain/entities/playlist.dart`
- Create: `lib/domain/entities/playlist_track.dart`
- Create: `lib/domain/entities/queue_item.dart`

- [ ] **Step 1: Create Playlist entity**

Create `lib/domain/entities/playlist.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist.freezed.dart';

@freezed
sealed class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    String? description,
    String? coverAlbumId,
    required int createdAt,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Playlist;
}
```

- [ ] **Step 2: Create PlaylistTrack entity**

Create `lib/domain/entities/playlist_track.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_track.freezed.dart';

@freezed
sealed class PlaylistTrack with _$PlaylistTrack {
  const factory PlaylistTrack({
    required String id,
    required String playlistId,
    required String ripTrackId,
    required int sortOrder,
    required int addedAt,
  }) = _PlaylistTrack;
}
```

- [ ] **Step 3: Create QueueItem entity**

Create `lib/domain/entities/queue_item.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

part 'queue_item.freezed.dart';

enum QueueItemSource { album, manual, playlist }

@freezed
sealed class QueueItem with _$QueueItem {
  const factory QueueItem({
    required RipAlbum album,
    required RipTrack track,
    @Default(QueueItemSource.manual) QueueItemSource source,
  }) = _QueueItem;
}
```

- [ ] **Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: Generates `.freezed.dart` files for all three entities.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/playlist.dart \
        lib/domain/entities/playlist.freezed.dart \
        lib/domain/entities/playlist_track.dart \
        lib/domain/entities/playlist_track.freezed.dart \
        lib/domain/entities/queue_item.dart \
        lib/domain/entities/queue_item.freezed.dart
git commit -m "feat: add Playlist, PlaylistTrack, and QueueItem entities"
```

---

## Task 3: Playlist DAO

**Files:**
- Create: `lib/data/local/dao/playlist_dao.dart`
- Modify: `lib/data/local/database/app_database.dart` (register DAO)
- Test: `test/unit/data/dao/playlist_dao_test.dart`

- [ ] **Step 1: Write failing tests for PlaylistDao**

Create `test/unit/data/dao/playlist_dao_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/playlist_dao.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late PlaylistDao dao;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = PlaylistDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlaylistDao', () {
    test('watchAll returns empty list initially', () async {
      final playlists = await dao.watchAll().first;
      expect(playlists, isEmpty);
    });

    test('insertPlaylist and watchAll returns inserted playlist', () async {
      final id = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertPlaylist(PlaylistsTableCompanion.insert(
        id: id,
        name: 'Test Playlist',
        createdAt: now,
        updatedAt: now,
      ));

      final playlists = await dao.watchAll().first;
      expect(playlists, hasLength(1));
      expect(playlists.first.name, 'Test Playlist');
    });

    test('softDeletePlaylist excludes from watchAll', () async {
      final id = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertPlaylist(PlaylistsTableCompanion.insert(
        id: id,
        name: 'To Delete',
        createdAt: now,
        updatedAt: now,
      ));

      await dao.softDeletePlaylist(id, now + 1000);

      final playlists = await dao.watchAll().first;
      expect(playlists, isEmpty);
    });

    test('insertPlaylistTracks and getTracksForPlaylist returns ordered tracks', () async {
      final playlistId = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Create a rip album and tracks first
      final albumId = uuid.v4();
      await db.into(db.ripAlbumsTable).insert(RipAlbumsTableCompanion.insert(
        id: albumId,
        libraryPath: '/test/album',
        trackCount: 2,
        totalSizeBytes: 1000,
        lastScannedAt: now,
        updatedAt: now,
      ));

      final trackId1 = uuid.v4();
      final trackId2 = uuid.v4();
      await db.batch((b) {
        b.insertAll(db.ripTracksTable, [
          RipTracksTableCompanion.insert(
            id: trackId1,
            ripAlbumId: albumId,
            trackNumber: 1,
            filePath: '/test/track1.flac',
            fileSizeBytes: 500,
            updatedAt: now,
          ),
          RipTracksTableCompanion.insert(
            id: trackId2,
            ripAlbumId: albumId,
            trackNumber: 2,
            filePath: '/test/track2.flac',
            fileSizeBytes: 500,
            updatedAt: now,
          ),
        ]);
      });

      // Create playlist
      await dao.insertPlaylist(PlaylistsTableCompanion.insert(
        id: playlistId,
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      ));

      // Add tracks
      await dao.insertPlaylistTracks([
        PlaylistTracksTableCompanion.insert(
          id: uuid.v4(),
          playlistId: playlistId,
          ripTrackId: trackId2,
          sortOrder: 0,
          addedAt: now,
        ),
        PlaylistTracksTableCompanion.insert(
          id: uuid.v4(),
          playlistId: playlistId,
          ripTrackId: trackId1,
          sortOrder: 1,
          addedAt: now,
        ),
      ]);

      final tracks = await dao.getTracksForPlaylist(playlistId);
      expect(tracks, hasLength(2));
      expect(tracks.first.ripTrackId, trackId2);
      expect(tracks.last.ripTrackId, trackId1);
    });

    test('updatePlaylist updates name', () async {
      final id = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertPlaylist(PlaylistsTableCompanion.insert(
        id: id,
        name: 'Original',
        createdAt: now,
        updatedAt: now,
      ));

      await dao.updatePlaylist(PlaylistsTableCompanion(
        id: Value(id),
        name: const Value('Renamed'),
        updatedAt: Value(now + 1000),
      ));

      final playlists = await dao.watchAll().first;
      expect(playlists.first.name, 'Renamed');
    });

    test('removeTrackFromPlaylist removes specific track', () async {
      final playlistId = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final albumId = uuid.v4();
      await db.into(db.ripAlbumsTable).insert(RipAlbumsTableCompanion.insert(
        id: albumId,
        libraryPath: '/test',
        trackCount: 1,
        totalSizeBytes: 100,
        lastScannedAt: now,
        updatedAt: now,
      ));

      final trackId = uuid.v4();
      await db.into(db.ripTracksTable).insert(RipTracksTableCompanion.insert(
        id: trackId,
        ripAlbumId: albumId,
        trackNumber: 1,
        filePath: '/test/t.flac',
        fileSizeBytes: 100,
        updatedAt: now,
      ));

      await dao.insertPlaylist(PlaylistsTableCompanion.insert(
        id: playlistId,
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      ));

      final ptId = uuid.v4();
      await dao.insertPlaylistTracks([
        PlaylistTracksTableCompanion.insert(
          id: ptId,
          playlistId: playlistId,
          ripTrackId: trackId,
          sortOrder: 0,
          addedAt: now,
        ),
      ]);

      await dao.removeTrackFromPlaylist(ptId);

      final tracks = await dao.getTracksForPlaylist(playlistId);
      expect(tracks, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/data/dao/playlist_dao_test.dart`

Expected: FAIL — `PlaylistDao` class doesn't exist yet.

- [ ] **Step 3: Implement PlaylistDao**

Create `lib/data/local/dao/playlist_dao.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/playlist_tracks_table.dart';
import 'package:mymediascanner/data/local/database/tables/playlists_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_tracks_table.dart';

part 'playlist_dao.g.dart';

@DriftAccessor(tables: [PlaylistsTable, PlaylistTracksTable, RipTracksTable])
class PlaylistDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistDaoMixin {
  PlaylistDao(super.db);

  /// Stream of all non-deleted playlists, newest first.
  Stream<List<PlaylistsTableData>> watchAll() {
    return (select(playlistsTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Get a single playlist by ID.
  Future<PlaylistsTableData?> getById(String id) {
    return (select(playlistsTable)
          ..where((t) => t.id.equals(id) & t.deleted.equals(0)))
        .getSingleOrNull();
  }

  /// Insert a new playlist.
  Future<void> insertPlaylist(PlaylistsTableCompanion companion) {
    return into(playlistsTable).insert(companion);
  }

  /// Update an existing playlist.
  Future<void> updatePlaylist(PlaylistsTableCompanion companion) {
    return (update(playlistsTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  /// Soft-delete a playlist.
  Future<void> softDeletePlaylist(String id, int updatedAt) {
    return (update(playlistsTable)..where((t) => t.id.equals(id))).write(
      PlaylistsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Get all tracks for a playlist, ordered by sortOrder.
  Future<List<PlaylistTracksTableData>> getTracksForPlaylist(
      String playlistId) {
    return (select(playlistTracksTable)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Insert playlist tracks in batch.
  Future<void> insertPlaylistTracks(
      List<PlaylistTracksTableCompanion> companions) {
    return batch((b) {
      b.insertAll(playlistTracksTable, companions);
    });
  }

  /// Remove a single track entry from a playlist.
  Future<void> removeTrackFromPlaylist(String playlistTrackId) {
    return (delete(playlistTracksTable)
          ..where((t) => t.id.equals(playlistTrackId)))
        .go();
  }

  /// Remove all tracks from a playlist (for reorder operations).
  Future<void> clearPlaylistTracks(String playlistId) {
    return (delete(playlistTracksTable)
          ..where((t) => t.playlistId.equals(playlistId)))
        .go();
  }
}
```

- [ ] **Step 4: Register PlaylistDao in AppDatabase**

Modify `lib/data/local/database/app_database.dart`:

Add `PlaylistDao` import and add it to the `daos: [...]` list in `@DriftDatabase`.

- [ ] **Step 5: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/unit/data/dao/playlist_dao_test.dart`

Expected: All 5 tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/data/local/dao/playlist_dao.dart \
        lib/data/local/dao/playlist_dao.g.dart \
        lib/data/local/database/app_database.dart \
        lib/data/local/database/app_database.g.dart \
        test/unit/data/dao/playlist_dao_test.dart
git commit -m "feat: add PlaylistDao with CRUD and track management"
```

---

## Task 4: Queue System

**Files:**
- Create: `lib/presentation/providers/queue_provider.dart`
- Modify: `lib/presentation/providers/audio_player_provider.dart` (integrate queue with playback)
- Test: `test/unit/presentation/providers/queue_provider_test.dart`

- [ ] **Step 1: Write failing tests for QueueNotifier**

Create `test/unit/presentation/providers/queue_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';

void main() {
  const testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/test/album1',
    artist: 'Test Artist',
    albumTitle: 'Test Album',
    trackCount: 3,
    totalSizeBytes: 1000,
    lastScannedAt: 0,
    updatedAt: 0,
  );

  final testTracks = [
    const RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'Track One',
      filePath: '/test/t1.flac',
      fileSizeBytes: 300,
      updatedAt: 0,
    ),
    const RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Track Two',
      filePath: '/test/t2.flac',
      fileSizeBytes: 300,
      updatedAt: 0,
    ),
    const RipTrack(
      id: 'track-3',
      ripAlbumId: 'album-1',
      trackNumber: 3,
      title: 'Track Three',
      filePath: '/test/t3.flac',
      fileSizeBytes: 400,
      updatedAt: 0,
    ),
  ];

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('QueueNotifier', () {
    test('initial state is empty', () {
      final container = makeContainer();
      final state = container.read(queueProvider);
      expect(state.items, isEmpty);
      expect(state.history, isEmpty);
    });

    test('addAlbumToQueue appends all tracks', () {
      final container = makeContainer();
      container
          .read(queueProvider.notifier)
          .addAlbumToQueue(testAlbum, testTracks);

      final state = container.read(queueProvider);
      expect(state.items, hasLength(3));
      expect(state.items.first.track.id, 'track-1');
      expect(state.items.first.source, QueueItemSource.album);
    });

    test('playNext inserts after current index', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      // Add album tracks
      notifier.addAlbumToQueue(testAlbum, testTracks);
      // Set current index to 0
      notifier.setCurrentIndex(0);

      // Play next inserts at index 1
      final extraTrack = const RipTrack(
        id: 'extra',
        ripAlbumId: 'album-1',
        trackNumber: 99,
        title: 'Extra',
        filePath: '/test/extra.flac',
        fileSizeBytes: 100,
        updatedAt: 0,
      );
      notifier.playNext(
          QueueItem(album: testAlbum, track: extraTrack, source: QueueItemSource.manual));

      final state = container.read(queueProvider);
      expect(state.items[1].track.id, 'extra');
      expect(state.items, hasLength(4));
    });

    test('removeAt removes item at index', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);
      notifier.addAlbumToQueue(testAlbum, testTracks);

      notifier.removeAt(1);

      final state = container.read(queueProvider);
      expect(state.items, hasLength(2));
      expect(state.items[0].track.id, 'track-1');
      expect(state.items[1].track.id, 'track-3');
    });

    test('reorder moves item from old to new index', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);
      notifier.addAlbumToQueue(testAlbum, testTracks);

      notifier.reorder(2, 0); // move track-3 to front

      final state = container.read(queueProvider);
      expect(state.items[0].track.id, 'track-3');
      expect(state.items[1].track.id, 'track-1');
      expect(state.items[2].track.id, 'track-2');
    });

    test('advanceToNext adds current to history', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);
      notifier.addAlbumToQueue(testAlbum, testTracks);
      notifier.setCurrentIndex(0);

      notifier.advanceToNext();

      final state = container.read(queueProvider);
      expect(state.currentIndex, 1);
      expect(state.history, hasLength(1));
      expect(state.history.first.track.id, 'track-1');
    });

    test('clear empties queue but preserves history', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);
      notifier.addAlbumToQueue(testAlbum, testTracks);
      notifier.setCurrentIndex(0);
      notifier.advanceToNext();

      notifier.clear();

      final state = container.read(queueProvider);
      expect(state.items, isEmpty);
      expect(state.currentIndex, -1);
      expect(state.history, hasLength(1));
    });

    test('replaceQueue clears existing and sets new items', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);
      notifier.addAlbumToQueue(testAlbum, testTracks);

      final newTrack = const RipTrack(
        id: 'new-1',
        ripAlbumId: 'album-1',
        trackNumber: 1,
        title: 'New',
        filePath: '/test/new.flac',
        fileSizeBytes: 100,
        updatedAt: 0,
      );
      notifier.replaceQueue(testAlbum, [newTrack]);

      final state = container.read(queueProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.track.id, 'new-1');
      expect(state.currentIndex, 0);
    });

    test('history is capped at 50 items', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      // Add 55 tracks
      final manyTracks = List.generate(
        55,
        (i) => RipTrack(
          id: 'track-$i',
          ripAlbumId: 'album-1',
          trackNumber: i + 1,
          title: 'Track $i',
          filePath: '/test/t$i.flac',
          fileSizeBytes: 100,
          updatedAt: 0,
        ),
      );
      notifier.addAlbumToQueue(testAlbum, manyTracks);
      notifier.setCurrentIndex(0);

      // Advance through all 55
      for (var i = 0; i < 54; i++) {
        notifier.advanceToNext();
      }

      final state = container.read(queueProvider);
      expect(state.history.length, 50);
    });
  });

  group('queueVisibleProvider', () {
    test('initial state is false', () {
      final container = makeContainer();
      expect(container.read(queueVisibleProvider), false);
    });

    test('toggle switches state', () {
      final container = makeContainer();
      container.read(queueVisibleProvider.notifier).toggle();
      expect(container.read(queueVisibleProvider), true);
      container.read(queueVisibleProvider.notifier).toggle();
      expect(container.read(queueVisibleProvider), false);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/presentation/providers/queue_provider_test.dart`

Expected: FAIL — `queueProvider` doesn't exist.

- [ ] **Step 3: Implement QueueNotifier**

Create `lib/presentation/providers/queue_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

class QueueState {
  const QueueState({
    this.items = const [],
    this.currentIndex = -1,
    this.history = const [],
  });

  final List<QueueItem> items;
  final int currentIndex;
  final List<QueueItem> history;

  QueueState copyWith({
    List<QueueItem>? items,
    int? currentIndex,
    List<QueueItem>? history,
  }) {
    return QueueState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      history: history ?? this.history,
    );
  }
}

class QueueNotifier extends Notifier<QueueState> {
  static const _maxHistory = 50;

  @override
  QueueState build() => const QueueState();

  /// Replace the entire queue with an album's tracks and start from index 0.
  void replaceQueue(RipAlbum album, List<RipTrack> tracks,
      {int startIndex = 0}) {
    state = state.copyWith(
      items: tracks
          .map((t) =>
              QueueItem(album: album, track: t, source: QueueItemSource.album))
          .toList(),
      currentIndex: startIndex,
    );
  }

  /// Append an album's tracks to the end of the queue.
  void addAlbumToQueue(RipAlbum album, List<RipTrack> tracks) {
    final newItems = tracks
        .map((t) =>
            QueueItem(album: album, track: t, source: QueueItemSource.album))
        .toList();
    state = state.copyWith(items: [...state.items, ...newItems]);
  }

  /// Insert a single item after the currently playing track.
  void playNext(QueueItem item) {
    final insertIndex = state.currentIndex + 1;
    final updated = [...state.items];
    updated.insert(insertIndex.clamp(0, updated.length), item);
    state = state.copyWith(items: updated);
  }

  /// Remove the item at the given index.
  void removeAt(int index) {
    final updated = [...state.items];
    updated.removeAt(index);
    var newIndex = state.currentIndex;
    if (index < newIndex) newIndex--;
    if (index == newIndex && newIndex >= updated.length) {
      newIndex = updated.length - 1;
    }
    state = state.copyWith(items: updated, currentIndex: newIndex);
  }

  /// Move an item from oldIndex to newIndex.
  void reorder(int oldIndex, int newIndex) {
    final updated = [...state.items];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex.clamp(0, updated.length), item);

    var newCurrent = state.currentIndex;
    if (oldIndex == newCurrent) {
      newCurrent = newIndex;
    } else {
      if (oldIndex < newCurrent) newCurrent--;
      if (newIndex <= newCurrent) newCurrent++;
    }
    state = state.copyWith(items: updated, currentIndex: newCurrent);
  }

  /// Set the current playback index.
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  /// Advance to the next track, adding current to history.
  void advanceToNext() {
    if (state.currentIndex >= 0 &&
        state.currentIndex < state.items.length) {
      final current = state.items[state.currentIndex];
      var history = [...state.history, current];
      if (history.length > _maxHistory) {
        history = history.sublist(history.length - _maxHistory);
      }
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        history: history,
      );
    }
  }

  /// Clear the queue but preserve history.
  void clear() {
    state = state.copyWith(items: [], currentIndex: -1);
  }

  /// Clear everything including history.
  void clearAll() {
    state = const QueueState();
  }
}

final queueProvider =
    NotifierProvider<QueueNotifier, QueueState>(() => QueueNotifier());

class QueueVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void show() => state = true;
  void hide() => state = false;
}

final queueVisibleProvider =
    NotifierProvider<QueueVisibleNotifier, bool>(() => QueueVisibleNotifier());
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/presentation/providers/queue_provider_test.dart`

Expected: All 9 tests PASS.

- [ ] **Step 5: Integrate queue with PlaybackActionNotifier**

Modify `lib/presentation/providers/audio_player_provider.dart`:

Add import for `queue_provider.dart`. In `PlaybackActionNotifier`:

1. Update `playAlbum()` to also call `ref.read(queueProvider.notifier).replaceQueue(album, tracks, startIndex: startIndex)`.

2. Add a `playFromQueue()` method:
```dart
Future<void> playFromQueue(int index) async {
  final queue = ref.read(queueProvider);
  if (index < 0 || index >= queue.items.length) return;
  final item = queue.items[index];
  ref.read(queueProvider.notifier).setCurrentIndex(index);
  ref.read(nowPlayingProvider.notifier).set(
    album: item.album,
    tracks: queue.items.map((qi) => qi.track).toList(),
  );
  await _service.seekToIndex(index);
}
```

3. Listen for track completion in the service's `playbackEventStream` and call `queueProvider.notifier.advanceToNext()` when a track ends naturally. This can be done by adding a listener setup method or integrating with existing stream handling.

- [ ] **Step 6: Run all audio player tests**

Run: `flutter test test/unit/presentation/providers/audio_player_provider_test.dart test/unit/presentation/providers/queue_provider_test.dart`

Expected: All tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/providers/queue_provider.dart \
        lib/presentation/providers/audio_player_provider.dart \
        test/unit/presentation/providers/queue_provider_test.dart
git commit -m "feat: add play queue with history, play-next, and reorder"
```

---

## Task 5: Queue Panel UI

**Files:**
- Create: `lib/presentation/screens/rips/widgets/queue_panel.dart`
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` (overlay queue panel)
- Modify: `lib/presentation/screens/rips/widgets/playback_widgets.dart` (add queue toggle button)

- [ ] **Step 1: Create QueuePanel widget**

Create `lib/presentation/screens/rips/widgets/queue_panel.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';

class QueuePanel extends ConsumerWidget {
  const QueuePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final upNext = queue.currentIndex >= 0
        ? queue.items.sublist(
            (queue.currentIndex + 1).clamp(0, queue.items.length))
        : queue.items;

    final currentItem = queue.currentIndex >= 0 &&
            queue.currentIndex < queue.items.length
        ? queue.items[queue.currentIndex]
        : null;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          left: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.queue_music, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Queue',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      ref.read(queueProvider.notifier).clear(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Now Playing
          if (currentItem != null) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOW PLAYING',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colors.primary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        AlbumCoverArt(
                            albumId: currentItem.album.id, size: 36),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentItem.track.title ?? 'Unknown',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${currentItem.album.artist ?? "Unknown"} · ${formatPlaybackDuration(Duration(milliseconds: currentItem.track.durationMs ?? 0))}',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Up Next
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              'UP NEXT (${upNext.length})',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: upNext.isEmpty
                ? Center(
                    child: Text('Queue is empty',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant)),
                  )
                : ReorderableListView.builder(
                    itemCount: upNext.length,
                    onReorder: (oldIndex, newIndex) {
                      final actualOld =
                          oldIndex + queue.currentIndex + 1;
                      var actualNew =
                          newIndex + queue.currentIndex + 1;
                      if (newIndex > oldIndex) actualNew--;
                      ref
                          .read(queueProvider.notifier)
                          .reorder(actualOld, actualNew);
                    },
                    itemBuilder: (context, index) {
                      final item = upNext[index];
                      return _QueueTrackTile(
                        key: ValueKey(
                            '${item.track.id}-$index'),
                        item: item,
                        onTap: () {
                          final actualIndex =
                              index + queue.currentIndex + 1;
                          ref
                              .read(playbackActionProvider.notifier)
                              .playFromQueue(actualIndex);
                        },
                        onRemove: () {
                          final actualIndex =
                              index + queue.currentIndex + 1;
                          ref
                              .read(queueProvider.notifier)
                              .removeAt(actualIndex);
                        },
                      );
                    },
                  ),
          ),

          // History
          if (queue.history.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                'HISTORY (${queue.history.length})',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: queue.history.length,
                itemBuilder: (context, index) {
                  final item =
                      queue.history[queue.history.length - 1 - index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      item.track.title ?? 'Unknown',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.album.artist ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant
                              .withValues(alpha: 0.6)),
                    ),
                  );
                },
              ),
            ),
          ],

          // Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              onPressed: queue.items.isEmpty
                  ? null
                  : () => _saveAsPlaylist(context, ref),
              icon: const Icon(Icons.playlist_add, size: 18),
              label: const Text('Save as Playlist'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAsPlaylist(BuildContext context, WidgetRef ref) {
    // Will be connected in Task 6 when playlist CRUD is built
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playlist saving coming soon')),
    );
  }
}

class _QueueTrackTile extends StatelessWidget {
  const _QueueTrackTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final QueueItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(Icons.drag_handle,
          size: 18, color: colors.onSurfaceVariant),
      title: Text(
        item.track.title ?? 'Track ${item.track.trackNumber}',
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        '${item.album.artist ?? "Unknown"} · ${formatPlaybackDuration(Duration(milliseconds: item.track.durationMs ?? 0))}',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: onRemove,
      ),
    );
  }
}
```

- [ ] **Step 2: Add queue toggle button to InlinePlayerControls**

Modify `lib/presentation/screens/rips/widgets/playback_widgets.dart`:

Add import for `queue_provider.dart`. In the `InlinePlayerControls` build method, after the repeat mode `IconButton` in the transport controls `Row`, add:

```dart
IconButton(
  icon: Icon(
    Icons.queue_music,
    size: 20,
    color: ref.watch(queueVisibleProvider)
        ? colors.primary
        : null,
  ),
  tooltip: 'Queue',
  onPressed: () =>
      ref.read(queueVisibleProvider.notifier).toggle(),
),
```

- [ ] **Step 3: Overlay queue panel in the library view**

Modify `lib/presentation/screens/rips/widgets/rip_library_view.dart`:

Add import for `queue_panel.dart` and `queue_provider.dart`. Wrap the existing `MasterDetailLayout` in a `Stack` or `Row` so that when `queueVisibleProvider` is true, the `QueuePanel` appears on the right side:

```dart
final showQueue = ref.watch(queueVisibleProvider);

return Row(
  children: [
    Expanded(
      child: MasterDetailLayout(
        master: masterContent,
        detail: detailPanel,
      ),
    ),
    if (showQueue) const QueuePanel(),
  ],
);
```

- [ ] **Step 4: Verify UI compiles**

Run: `flutter analyze`

Expected: No analysis errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/rips/widgets/queue_panel.dart \
        lib/presentation/screens/rips/widgets/playback_widgets.dart \
        lib/presentation/screens/rips/widgets/rip_library_view.dart
git commit -m "feat: add queue panel UI with drag-reorder and history"
```

---

## Task 6: Playlists CRUD & Providers

**Files:**
- Create: `lib/presentation/providers/playlist_provider.dart`
- Modify: `lib/data/local/dao/playlist_dao.dart` (add mapper helpers if needed)
- Test: `test/unit/presentation/providers/playlist_provider_test.dart`

- [ ] **Step 1: Write failing tests for playlist providers**

Create `test/unit/presentation/providers/playlist_provider_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/playlist_dao.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';

void main() {
  late AppDatabase db;
  late PlaylistDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = PlaylistDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        playlistDaoProvider.overrideWithValue(dao),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('PlaylistCrudNotifier', () {
    test('createPlaylist creates a new playlist', () async {
      final container = makeContainer();
      final notifier = container.read(playlistCrudProvider.notifier);

      final id = await notifier.createPlaylist('My Playlist');

      expect(id, isNotEmpty);
      final playlists = await dao.watchAll().first;
      expect(playlists, hasLength(1));
      expect(playlists.first.name, 'My Playlist');
    });

    test('renamePlaylist updates the name', () async {
      final container = makeContainer();
      final notifier = container.read(playlistCrudProvider.notifier);

      final id = await notifier.createPlaylist('Original');
      await notifier.renamePlaylist(id, 'Renamed');

      final playlists = await dao.watchAll().first;
      expect(playlists.first.name, 'Renamed');
    });

    test('deletePlaylist soft-deletes', () async {
      final container = makeContainer();
      final notifier = container.read(playlistCrudProvider.notifier);

      final id = await notifier.createPlaylist('To Delete');
      await notifier.deletePlaylist(id);

      final playlists = await dao.watchAll().first;
      expect(playlists, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/presentation/providers/playlist_provider_test.dart`

Expected: FAIL — providers don't exist.

- [ ] **Step 3: Implement playlist providers**

Create `lib/presentation/providers/playlist_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/playlist_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Provides the PlaylistDao instance.
final playlistDaoProvider = Provider<PlaylistDao>((ref) {
  return PlaylistDao(ref.watch(databaseProvider));
});

/// Stream of all non-deleted playlists.
final allPlaylistsProvider = StreamProvider<List<PlaylistsTableData>>((ref) {
  return ref.watch(playlistDaoProvider).watchAll();
});

/// Tracks for a specific playlist.
final playlistTracksProvider =
    FutureProvider.family<List<PlaylistTracksTableData>, String>(
        (ref, playlistId) {
  return ref.watch(playlistDaoProvider).getTracksForPlaylist(playlistId);
});

/// Currently selected playlist ID in the UI.
class SelectedPlaylistNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
  void clear() => state = null;
}

final selectedPlaylistProvider =
    NotifierProvider<SelectedPlaylistNotifier, String?>(
        () => SelectedPlaylistNotifier());

/// CRUD operations for playlists.
class PlaylistCrudNotifier extends Notifier<void> {
  @override
  void build() {}

  PlaylistDao get _dao => ref.read(playlistDaoProvider);

  /// Create a new playlist. Returns the new playlist ID.
  Future<String> createPlaylist(String name, {String? description}) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.insertPlaylist(PlaylistsTableCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      createdAt: now,
      updatedAt: now,
    ));
    ref.invalidate(allPlaylistsProvider);
    return id;
  }

  /// Rename a playlist.
  Future<void> renamePlaylist(String id, String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.updatePlaylist(PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      updatedAt: Value(now),
    ));
    ref.invalidate(allPlaylistsProvider);
  }

  /// Soft-delete a playlist.
  Future<void> deletePlaylist(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.softDeletePlaylist(id, now);
    ref.invalidate(allPlaylistsProvider);
    final selected = ref.read(selectedPlaylistProvider);
    if (selected == id) {
      ref.read(selectedPlaylistProvider.notifier).clear();
    }
  }

  /// Add tracks to a playlist.
  Future<void> addTracksToPlaylist(
      String playlistId, List<String> ripTrackIds) async {
    final existing = await _dao.getTracksForPlaylist(playlistId);
    final startOrder = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final now = DateTime.now().millisecondsSinceEpoch;

    final companions = ripTrackIds.asMap().entries.map((entry) {
      return PlaylistTracksTableCompanion.insert(
        id: _uuid.v4(),
        playlistId: playlistId,
        ripTrackId: entry.value,
        sortOrder: startOrder + entry.key,
        addedAt: now,
      );
    }).toList();

    await _dao.insertPlaylistTracks(companions);
    await _dao.updatePlaylist(PlaylistsTableCompanion(
      id: Value(playlistId),
      updatedAt: Value(now),
    ));
    ref.invalidate(playlistTracksProvider(playlistId));
    ref.invalidate(allPlaylistsProvider);
  }

  /// Remove a track from a playlist.
  Future<void> removeTrackFromPlaylist(
      String playlistId, String playlistTrackId) async {
    await _dao.removeTrackFromPlaylist(playlistTrackId);
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.updatePlaylist(PlaylistsTableCompanion(
      id: Value(playlistId),
      updatedAt: Value(now),
    ));
    ref.invalidate(playlistTracksProvider(playlistId));
  }

  /// Reorder tracks in a playlist (clear and re-insert with new sort orders).
  Future<void> reorderPlaylistTracks(
      String playlistId, List<String> orderedTrackIds) async {
    await _dao.clearPlaylistTracks(playlistId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final companions = orderedTrackIds.asMap().entries.map((entry) {
      return PlaylistTracksTableCompanion.insert(
        id: _uuid.v4(),
        playlistId: playlistId,
        ripTrackId: entry.value,
        sortOrder: entry.key,
        addedAt: now,
      );
    }).toList();
    await _dao.insertPlaylistTracks(companions);
    ref.invalidate(playlistTracksProvider(playlistId));
  }
}

final playlistCrudProvider =
    NotifierProvider<PlaylistCrudNotifier, void>(
        () => PlaylistCrudNotifier());
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/presentation/providers/playlist_provider_test.dart`

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/playlist_provider.dart \
        test/unit/presentation/providers/playlist_provider_test.dart
git commit -m "feat: add playlist CRUD providers with DAO integration"
```

---

## Task 7: Playlists UI — Tab, Grid, and Detail View

**Files:**
- Create: `lib/presentation/screens/rips/widgets/playlist_view.dart`
- Create: `lib/presentation/screens/rips/widgets/playlist_detail.dart`
- Modify: `lib/presentation/screens/rips/rips_screen.dart` (add Playlists segment)
- Modify: `lib/presentation/screens/rips/widgets/queue_panel.dart` (connect Save as Playlist)

- [ ] **Step 1: Add Playlists segment to rips screen**

Modify `lib/presentation/screens/rips/rips_screen.dart`:

1. Update the enum: `enum _RipsSegment { library, coverage, playlists }`

2. Add a third `ButtonSegment` to the `SegmentedButton`:
```dart
ButtonSegment(
  value: _RipsSegment.playlists,
  label: Text('Playlists'),
  icon: Icon(Icons.playlist_play),
),
```

3. Update the `Expanded` child to handle the third segment:
```dart
Expanded(
  child: switch (_selected) {
    _RipsSegment.library => const RipLibraryView(),
    _RipsSegment.coverage => const RipCoverageView(),
    _RipsSegment.playlists => const PlaylistView(),
  },
),
```

- [ ] **Step 2: Create PlaylistView widget**

Create `lib/presentation/screens/rips/widgets/playlist_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playlist_detail.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';

class PlaylistView extends ConsumerWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);
    final selectedId = ref.watch(selectedPlaylistProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final masterContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('My Playlists',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _createPlaylist(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Playlist'),
              ),
            ],
          ),
        ),
        Expanded(
          child: playlistsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (playlists) {
              if (playlists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.playlist_play,
                          size: 48, color: colors.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('No playlists yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(
                          'Create one or save from the queue',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final isSelected = selectedId == playlist.id;
                  return _PlaylistCard(
                    playlist: playlist,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(selectedPlaylistProvider.notifier)
                        .select(playlist.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    final detailPanel = selectedId != null
        ? PlaylistDetail(playlistId: selectedId)
        : null;

    return MasterDetailLayout(
      master: masterContent,
      detail: detailPanel,
    );
  }

  void _createPlaylist(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Playlist name'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(playlistCrudProvider.notifier)
                  .createPlaylist(value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(playlistCrudProvider.notifier)
                    .createPlaylist(name);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.isSelected,
    required this.onTap,
  });

  final PlaylistsTableData playlist;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: playlist.coverAlbumId != null
                      ? AlbumCoverArt(
                          albumId: playlist.coverAlbumId!,
                          size: double.infinity)
                      : Icon(Icons.playlist_play,
                          size: 48,
                          color: colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                playlist.name,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatDate(playlist.createdAt),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
```

- [ ] **Step 3: Create PlaylistDetail widget**

Create `lib/presentation/screens/rips/widgets/playlist_detail.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';

class PlaylistDetail extends ConsumerWidget {
  const PlaylistDetail({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);
    final tracksAsync = ref.watch(playlistTracksProvider(playlistId));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return playlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (playlists) {
        final playlist = playlists
            .where((p) => p.id == playlistId)
            .firstOrNull;
        if (playlist == null) {
          return const Center(child: Text('Playlist not found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: playlist.coverAlbumId != null
                        ? AlbumCoverArt(
                            albumId: playlist.coverAlbumId!,
                            size: 80)
                        : Icon(Icons.playlist_play,
                            size: 36,
                            color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(playlist.name,
                            style: theme.textTheme.headlineSmall),
                        if (playlist.description != null)
                          Text(playlist.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () =>
                                  _playAll(ref, tracksAsync.value),
                              icon: const Icon(Icons.play_arrow,
                                  size: 18),
                              label: const Text('Play All'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Rename',
                              onPressed: () =>
                                  _rename(context, ref, playlist),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18),
                              tooltip: 'Delete',
                              onPressed: () => _delete(ref),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Track list
            Expanded(
              child: tracksAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
                data: (playlistTracks) {
                  if (playlistTracks.isEmpty) {
                    return Center(
                      child: Text('No tracks yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant)),
                    );
                  }

                  return ListView.builder(
                    itemCount: playlistTracks.length,
                    itemBuilder: (context, index) {
                      final pt = playlistTracks[index];
                      return _PlaylistTrackTile(
                        playlistTrack: pt,
                        index: index,
                        onRemove: () {
                          ref
                              .read(playlistCrudProvider.notifier)
                              .removeTrackFromPlaylist(
                                  playlistId, pt.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _playAll(
      WidgetRef ref, List<PlaylistTracksTableData>? tracks) {
    if (tracks == null || tracks.isEmpty) return;
    // Load actual RipTrack objects and play via queue
    // This requires resolving ripTrackIds to RipTrack entities
    // For now, this is a placeholder that will be connected
    // once the track resolution is implemented
  }

  void _rename(BuildContext context, WidgetRef ref,
      PlaylistsTableData playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(playlistCrudProvider.notifier)
                  .renamePlaylist(playlist.id, value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(playlistCrudProvider.notifier)
                    .renamePlaylist(playlist.id, name);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _delete(WidgetRef ref) {
    ref.read(playlistCrudProvider.notifier).deletePlaylist(playlistId);
  }
}

class _PlaylistTrackTile extends ConsumerWidget {
  const _PlaylistTrackTile({
    required this.playlistTrack,
    required this.index,
    required this.onRemove,
  });

  final PlaylistTracksTableData playlistTrack;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // We need to resolve the ripTrackId to get track metadata
    // This will use a provider to look up the track details
    return ListTile(
      leading: SizedBox(
        width: 30,
        child: Text(
          '${index + 1}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
      title: Text('Track ${playlistTrack.ripTrackId.substring(0, 8)}…'),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: onRemove,
      ),
    );
  }
}
```

- [ ] **Step 4: Connect "Save as Playlist" in queue panel**

Modify `lib/presentation/screens/rips/widgets/queue_panel.dart`:

Replace the `_saveAsPlaylist` method with:

```dart
void _saveAsPlaylist(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Save Queue as Playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Playlist name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              final queue = ref.read(queueProvider);
              final trackIds =
                  queue.items.map((qi) => qi.track.id).toList();
              final id = await ref
                  .read(playlistCrudProvider.notifier)
                  .createPlaylist(name);
              await ref
                  .read(playlistCrudProvider.notifier)
                  .addTracksToPlaylist(id, trackIds);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Saved "$name" with ${trackIds.length} tracks')),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze`

Expected: No analysis errors.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/rips/widgets/playlist_view.dart \
        lib/presentation/screens/rips/widgets/playlist_detail.dart \
        lib/presentation/screens/rips/rips_screen.dart \
        lib/presentation/screens/rips/widgets/queue_panel.dart
git commit -m "feat: add playlists tab with grid view, detail panel, and save-from-queue"
```

---

## Task 8: ReplayGain

**Files:**
- Create: `lib/core/services/audio/replay_gain_service.dart`
- Create: `lib/presentation/providers/replay_gain_provider.dart`
- Modify: `lib/presentation/providers/audio_player_provider.dart` (integrate RG with volume)
- Modify: `lib/presentation/screens/settings/settings_screen.dart` (add Playback section)
- Test: `test/unit/core/services/audio/replay_gain_service_test.dart`
- Test: `test/unit/presentation/providers/replay_gain_provider_test.dart`

- [ ] **Step 1: Write failing tests for ReplayGainService**

Create `test/unit/core/services/audio/replay_gain_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';

void main() {
  group('ReplayGainService', () {
    const service = ReplayGainService();

    test('returns userVolume when mode is off', () {
      final result = service.calculateVolume(
        rawTags: {'REPLAYGAIN_TRACK_GAIN': '-6.0 dB'},
        mode: ReplayGainMode.off,
        preampDb: 0,
        preventClipping: true,
        userVolume: 0.8,
      );
      expect(result, 0.8);
    });

    test('applies track gain correctly', () {
      // -6 dB gain → linear factor ≈ 0.5012
      // effective = 1.0 * 0.5012 ≈ 0.5012
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_TRACK_GAIN': '-6.0 dB',
          'REPLAYGAIN_TRACK_PEAK': '1.0',
        },
        mode: ReplayGainMode.track,
        preampDb: 0,
        preventClipping: true,
        userVolume: 1.0,
      );
      expect(result, closeTo(0.5012, 0.001));
    });

    test('applies album gain when mode is album', () {
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_TRACK_GAIN': '-6.0 dB',
          'REPLAYGAIN_ALBUM_GAIN': '-3.0 dB',
          'REPLAYGAIN_ALBUM_PEAK': '1.0',
        },
        mode: ReplayGainMode.album,
        preampDb: 0,
        preventClipping: true,
        userVolume: 1.0,
      );
      // -3 dB → linear ≈ 0.7079
      expect(result, closeTo(0.7079, 0.001));
    });

    test('applies preamp boost', () {
      // -6 dB gain + 3 dB preamp = -3 dB effective
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_TRACK_GAIN': '-6.0 dB',
          'REPLAYGAIN_TRACK_PEAK': '1.0',
        },
        mode: ReplayGainMode.track,
        preampDb: 3.0,
        preventClipping: true,
        userVolume: 1.0,
      );
      expect(result, closeTo(0.7079, 0.001));
    });

    test('prevents clipping when gain exceeds peak', () {
      // +6 dB gain → linear ≈ 1.995, peak 0.8
      // 1.995 * 0.8 = 1.596 > 1.0 → clamp to 1/0.8 = 1.25
      // effective = 1.0 * 1.25 = 1.25 → clamped to 1.0
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_TRACK_GAIN': '+6.0 dB',
          'REPLAYGAIN_TRACK_PEAK': '0.8',
        },
        mode: ReplayGainMode.track,
        preampDb: 0,
        preventClipping: true,
        userVolume: 1.0,
      );
      expect(result, closeTo(1.0, 0.01));
    });

    test('allows clipping when prevention is disabled', () {
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_TRACK_GAIN': '+6.0 dB',
          'REPLAYGAIN_TRACK_PEAK': '0.8',
        },
        mode: ReplayGainMode.track,
        preampDb: 0,
        preventClipping: false,
        userVolume: 1.0,
      );
      // +6 dB → 1.995, no clipping, but clamped to 1.0 max
      expect(result, 1.0);
    });

    test('returns userVolume when tags are missing', () {
      final result = service.calculateVolume(
        rawTags: {},
        mode: ReplayGainMode.track,
        preampDb: 0,
        preventClipping: true,
        userVolume: 0.7,
      );
      expect(result, 0.7);
    });

    test('combines with user volume', () {
      // -6 dB → 0.5012 * 0.5 user volume ≈ 0.2506
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_TRACK_GAIN': '-6.0 dB',
          'REPLAYGAIN_TRACK_PEAK': '1.0',
        },
        mode: ReplayGainMode.track,
        preampDb: 0,
        preventClipping: true,
        userVolume: 0.5,
      );
      expect(result, closeTo(0.2506, 0.001));
    });

    test('falls back to album gain when track gain missing in track mode', () {
      final result = service.calculateVolume(
        rawTags: {
          'REPLAYGAIN_ALBUM_GAIN': '-3.0 dB',
          'REPLAYGAIN_ALBUM_PEAK': '1.0',
        },
        mode: ReplayGainMode.track,
        preampDb: 0,
        preventClipping: true,
        userVolume: 1.0,
      );
      expect(result, closeTo(0.7079, 0.001));
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/core/services/audio/replay_gain_service_test.dart`

Expected: FAIL — class doesn't exist.

- [ ] **Step 3: Implement ReplayGainService**

Create `lib/core/services/audio/replay_gain_service.dart`:

```dart
import 'dart:math' as math;

enum ReplayGainMode { off, track, album }

class ReplayGainService {
  const ReplayGainService();

  /// Calculate the effective volume combining ReplayGain adjustment with user volume.
  ///
  /// Returns a value between 0.0 and 1.0.
  double calculateVolume({
    required Map<String, String> rawTags,
    required ReplayGainMode mode,
    required double preampDb,
    required bool preventClipping,
    required double userVolume,
  }) {
    if (mode == ReplayGainMode.off) return userVolume;

    final gainDb = _getGainDb(rawTags, mode);
    if (gainDb == null) return userVolume;

    final peakValue = _getPeak(rawTags, mode);
    final effectiveGain = gainDb + preampDb;
    var linearGain = math.pow(10, effectiveGain / 20).toDouble();

    if (preventClipping && peakValue != null && linearGain * peakValue > 1.0) {
      linearGain = 1.0 / peakValue;
    }

    return (userVolume * linearGain).clamp(0.0, 1.0);
  }

  double? _getGainDb(Map<String, String> tags, ReplayGainMode mode) {
    final primaryKey = mode == ReplayGainMode.album
        ? 'REPLAYGAIN_ALBUM_GAIN'
        : 'REPLAYGAIN_TRACK_GAIN';
    final fallbackKey = mode == ReplayGainMode.album
        ? 'REPLAYGAIN_TRACK_GAIN'
        : 'REPLAYGAIN_ALBUM_GAIN';

    final primary = tags[primaryKey];
    final fallback = tags[fallbackKey];

    return _parseGain(primary) ?? _parseGain(fallback);
  }

  double? _getPeak(Map<String, String> tags, ReplayGainMode mode) {
    final primaryKey = mode == ReplayGainMode.album
        ? 'REPLAYGAIN_ALBUM_PEAK'
        : 'REPLAYGAIN_TRACK_PEAK';
    final fallbackKey = mode == ReplayGainMode.album
        ? 'REPLAYGAIN_TRACK_PEAK'
        : 'REPLAYGAIN_ALBUM_PEAK';

    final primary = tags[primaryKey];
    final fallback = tags[fallbackKey];

    return _parsePeak(primary) ?? _parsePeak(fallback);
  }

  double? _parseGain(String? value) {
    if (value == null) return null;
    // Format: "-6.5 dB" or "+3.0 dB"
    final cleaned = value.replaceAll(RegExp(r'\s*dB\s*$', caseSensitive: false), '').trim();
    return double.tryParse(cleaned);
  }

  double? _parsePeak(String? value) {
    if (value == null) return null;
    return double.tryParse(value.trim());
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/core/services/audio/replay_gain_service_test.dart`

Expected: All 9 tests PASS.

- [ ] **Step 5: Write ReplayGain provider tests**

Create `test/unit/presentation/providers/replay_gain_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('ReplayGainModeNotifier', () {
    test('initial state is off', () {
      final container = makeContainer();
      expect(container.read(replayGainModeProvider), ReplayGainMode.off);
    });

    test('setMode updates state', () {
      final container = makeContainer();
      container
          .read(replayGainModeProvider.notifier)
          .setMode(ReplayGainMode.track);
      expect(
          container.read(replayGainModeProvider), ReplayGainMode.track);
    });
  });

  group('ReplayGainPreampNotifier', () {
    test('initial state is 0.0', () {
      final container = makeContainer();
      expect(container.read(replayGainPreampProvider), 0.0);
    });

    test('set updates state within range', () {
      final container = makeContainer();
      container.read(replayGainPreampProvider.notifier).set(3.5);
      expect(container.read(replayGainPreampProvider), 3.5);
    });
  });

  group('PreventClippingNotifier', () {
    test('initial state is true', () {
      final container = makeContainer();
      expect(container.read(preventClippingProvider), true);
    });

    test('toggle switches state', () {
      final container = makeContainer();
      container.read(preventClippingProvider.notifier).toggle();
      expect(container.read(preventClippingProvider), false);
    });
  });
}
```

- [ ] **Step 6: Implement ReplayGain providers**

Create `lib/presentation/providers/replay_gain_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';

// --- ReplayGain Mode ---

class ReplayGainModeNotifier extends Notifier<ReplayGainMode> {
  static const _key = 'replay_gain_mode';

  @override
  ReplayGainMode build() {
    _load();
    return ReplayGainMode.off;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      state = ReplayGainMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ReplayGainMode.off,
      );
    }
  }

  Future<void> setMode(ReplayGainMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final replayGainModeProvider =
    NotifierProvider<ReplayGainModeNotifier, ReplayGainMode>(
        () => ReplayGainModeNotifier());

// --- Pre-amp ---

class ReplayGainPreampNotifier extends Notifier<double> {
  static const _key = 'replay_gain_preamp';

  @override
  double build() {
    _load();
    return 0.0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_key);
    if (stored != null) {
      state = stored.clamp(-6.0, 6.0);
    }
  }

  Future<void> set(double value) async {
    state = value.clamp(-6.0, 6.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }
}

final replayGainPreampProvider =
    NotifierProvider<ReplayGainPreampNotifier, double>(
        () => ReplayGainPreampNotifier());

// --- Prevent Clipping ---

class PreventClippingNotifier extends Notifier<bool> {
  static const _key = 'replay_gain_prevent_clipping';

  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_key);
    if (stored != null) {
      state = stored;
    }
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

final preventClippingProvider =
    NotifierProvider<PreventClippingNotifier, bool>(
        () => PreventClippingNotifier());

// --- Service Provider ---

final replayGainServiceProvider = Provider<ReplayGainService>((ref) {
  return const ReplayGainService();
});
```

- [ ] **Step 7: Run provider tests**

Run: `flutter test test/unit/presentation/providers/replay_gain_provider_test.dart`

Expected: All 5 tests PASS.

- [ ] **Step 8: Integrate ReplayGain into PlaybackActionNotifier**

Modify `lib/presentation/providers/audio_player_provider.dart`:

Import `replay_gain_provider.dart`, `replay_gain_service.dart`, and `rip_provider.dart`.

In `PlaybackActionNotifier.setVolume()`, apply ReplayGain:

```dart
Future<void> setVolume(double volume) async {
  ref.read(volumeProvider.notifier).set(volume);
  final effectiveVolume = await _calculateEffectiveVolume(volume);
  await _service.setVolume(effectiveVolume);
}

Future<double> _calculateEffectiveVolume(double userVolume) async {
  final mode = ref.read(replayGainModeProvider);
  if (mode == ReplayGainMode.off) return userVolume;

  final nowPlaying = ref.read(nowPlayingProvider);
  final currentIndex = _service.currentIndex;
  if (nowPlaying.tracks.isEmpty || currentIndex == null || currentIndex < 0) {
    return userVolume;
  }

  final track = nowPlaying.tracks[currentIndex];
  final tagsAsync = await ref.read(trackRawTagsProvider(track.filePath).future);
  final preamp = ref.read(replayGainPreampProvider);
  final preventClipping = ref.read(preventClippingProvider);
  final rgService = ref.read(replayGainServiceProvider);

  return rgService.calculateVolume(
    rawTags: tagsAsync,
    mode: mode,
    preampDb: preamp,
    preventClipping: preventClipping,
    userVolume: userVolume,
  );
}
```

Also add a method to recalculate volume on track change, and call it when the current track index changes.

- [ ] **Step 9: Add Playback section to Settings screen**

Modify `lib/presentation/screens/settings/settings_screen.dart`:

Add a new `_SectionCard` for Playback after the existing sections:

```dart
_SectionCard(
  title: 'Playback',
  colors: colors,
  theme: theme,
  children: [
    // ReplayGain Mode
    ListTile(
      title: const Text('ReplayGain Mode'),
      subtitle: const Text('Normalise volume across tracks'),
      trailing: SegmentedButton<ReplayGainMode>(
        segments: const [
          ButtonSegment(value: ReplayGainMode.off, label: Text('Off')),
          ButtonSegment(value: ReplayGainMode.track, label: Text('Track')),
          ButtonSegment(value: ReplayGainMode.album, label: Text('Album')),
        ],
        selected: {ref.watch(replayGainModeProvider)},
        onSelectionChanged: (selection) {
          ref
              .read(replayGainModeProvider.notifier)
              .setMode(selection.first);
        },
      ),
    ),
    // Pre-amp slider
    ListTile(
      title: const Text('Pre-amp'),
      subtitle: Text(
          '${ref.watch(replayGainPreampProvider).toStringAsFixed(1)} dB'),
      trailing: SizedBox(
        width: 200,
        child: Slider(
          value: ref.watch(replayGainPreampProvider),
          min: -6.0,
          max: 6.0,
          divisions: 24,
          onChanged: (value) =>
              ref.read(replayGainPreampProvider.notifier).set(value),
        ),
      ),
    ),
    // Prevent Clipping
    SwitchListTile(
      title: const Text('Prevent Clipping'),
      subtitle: const Text('Limit gain to avoid distortion'),
      value: ref.watch(preventClippingProvider),
      onChanged: (_) =>
          ref.read(preventClippingProvider.notifier).toggle(),
    ),
  ],
),
const SizedBox(height: 16),
```

- [ ] **Step 10: Run all related tests**

Run: `flutter test test/unit/core/services/audio/replay_gain_service_test.dart test/unit/presentation/providers/replay_gain_provider_test.dart`

Expected: All tests PASS.

- [ ] **Step 11: Commit**

```bash
git add lib/core/services/audio/replay_gain_service.dart \
        lib/presentation/providers/replay_gain_provider.dart \
        lib/presentation/providers/audio_player_provider.dart \
        lib/presentation/screens/settings/settings_screen.dart \
        test/unit/core/services/audio/replay_gain_service_test.dart \
        test/unit/presentation/providers/replay_gain_provider_test.dart
git commit -m "feat: add ReplayGain volume normalisation with settings UI"
```

---

## Task 9: Playback Speed

**Files:**
- Create: `lib/presentation/providers/playback_speed_provider.dart`
- Create: `lib/presentation/screens/rips/widgets/speed_control_popup.dart`
- Modify: `lib/core/services/audio/audio_player_service.dart` (add setSpeed)
- Modify: `lib/presentation/providers/audio_player_provider.dart` (add speed action)
- Modify: `lib/presentation/screens/rips/widgets/playback_widgets.dart` (add speed button)
- Test: `test/unit/presentation/providers/playback_speed_provider_test.dart`

- [ ] **Step 1: Write failing test for speed provider**

Create `test/unit/presentation/providers/playback_speed_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymediascanner/presentation/providers/playback_speed_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('PlaybackSpeedNotifier', () {
    test('initial state is 1.0', () {
      final container = makeContainer();
      expect(container.read(playbackSpeedProvider), 1.0);
    });

    test('setSpeed updates state', () {
      final container = makeContainer();
      container.read(playbackSpeedProvider.notifier).setSpeed(1.5);
      expect(container.read(playbackSpeedProvider), 1.5);
    });

    test('setSpeed clamps to range 0.5-2.0', () {
      final container = makeContainer();
      container.read(playbackSpeedProvider.notifier).setSpeed(3.0);
      expect(container.read(playbackSpeedProvider), 2.0);

      container.read(playbackSpeedProvider.notifier).setSpeed(0.1);
      expect(container.read(playbackSpeedProvider), 0.5);
    });

    test('reset sets speed to 1.0', () {
      final container = makeContainer();
      container.read(playbackSpeedProvider.notifier).setSpeed(1.5);
      container.read(playbackSpeedProvider.notifier).reset();
      expect(container.read(playbackSpeedProvider), 1.0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/presentation/providers/playback_speed_provider_test.dart`

Expected: FAIL.

- [ ] **Step 3: Implement playback speed provider**

Create `lib/presentation/providers/playback_speed_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaybackSpeedNotifier extends Notifier<double> {
  static const _key = 'playback_speed';

  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_key);
    if (stored != null) {
      state = stored.clamp(0.5, 2.0);
    }
  }

  Future<void> setSpeed(double speed) async {
    state = speed.clamp(0.5, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }

  Future<void> reset() async {
    await setSpeed(1.0);
  }
}

final playbackSpeedProvider =
    NotifierProvider<PlaybackSpeedNotifier, double>(
        () => PlaybackSpeedNotifier());
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/presentation/providers/playback_speed_provider_test.dart`

Expected: All 4 tests PASS.

- [ ] **Step 5: Add setSpeed to AudioPlayerService**

Modify `lib/core/services/audio/audio_player_service.dart`:

Add after the existing `setShuffleEnabled` method:

```dart
Future<void> setSpeed(double speed) async =>
    await _player.setSpeed(speed);

double get speed => _player.speed;
```

- [ ] **Step 6: Add speed action to PlaybackActionNotifier**

Modify `lib/presentation/providers/audio_player_provider.dart`:

Import `playback_speed_provider.dart`. Add to `PlaybackActionNotifier`:

```dart
Future<void> setSpeed(double speed) async {
  await _service.setSpeed(speed);
  ref.read(playbackSpeedProvider.notifier).setSpeed(speed);
}
```

- [ ] **Step 7: Create SpeedControlPopup widget**

Create `lib/presentation/screens/rips/widgets/speed_control_popup.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/playback_speed_provider.dart';

class SpeedControlPopup extends ConsumerWidget {
  const SpeedControlPopup({super.key});

  static const _presets = [0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(playbackSpeedProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PLAYBACK SPEED',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          // Preset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _presets.map((preset) {
              final isSelected = (speed - preset).abs() < 0.01;
              return GestureDetector(
                onTap: () => ref
                    .read(playbackActionProvider.notifier)
                    .setSpeed(preset),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${preset}×',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Fine control slider
          Row(
            children: [
              Text('0.5×',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant)),
              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 30,
                  onChanged: (value) => ref
                      .read(playbackActionProvider.notifier)
                      .setSpeed(value),
                ),
              ),
              Text('2.0×',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 8: Add speed button to InlinePlayerControls**

Modify `lib/presentation/screens/rips/widgets/playback_widgets.dart`:

Import `playback_speed_provider.dart` and `speed_control_popup.dart`. In the transport controls `Row`, after the volume slider section, add:

```dart
// Speed button
Builder(builder: (context) {
  final speed = ref.watch(playbackSpeedProvider);
  final isDefault = (speed - 1.0).abs() < 0.01;
  return GestureDetector(
    onTap: () {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      showDialog<void>(
        context: context,
        barrierColor: Colors.transparent,
        builder: (ctx) => Stack(
          children: [
            Positioned(
              left: offset.dx - 100,
              top: offset.dy - 120,
              child: const SpeedControlPopup(),
            ),
          ],
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDefault
            ? null
            : colors.primary.withValues(alpha: 0.15),
        border: Border.all(
          color: isDefault
              ? colors.outlineVariant.withValues(alpha: 0.3)
              : colors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${speed.toStringAsFixed(speed == speed.roundToDouble() ? 1 : 2)}×',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDefault ? colors.onSurfaceVariant : colors.primary,
          fontWeight: isDefault ? FontWeight.normal : FontWeight.w600,
        ),
      ),
    ),
  );
}),
```

- [ ] **Step 9: Verify compilation**

Run: `flutter analyze`

Expected: No analysis errors.

- [ ] **Step 10: Commit**

```bash
git add lib/presentation/providers/playback_speed_provider.dart \
        lib/presentation/screens/rips/widgets/speed_control_popup.dart \
        lib/core/services/audio/audio_player_service.dart \
        lib/presentation/providers/audio_player_provider.dart \
        lib/presentation/screens/rips/widgets/playback_widgets.dart \
        test/unit/presentation/providers/playback_speed_provider_test.dart
git commit -m "feat: add playback speed control with presets and slider"
```

---

## Task 10: Multi-Select & Batch Quality Analysis

**Files:**
- Create: `lib/presentation/providers/album_selection_provider.dart`
- Create: `lib/presentation/providers/batch_analysis_provider.dart`
- Create: `lib/presentation/screens/rips/widgets/batch_analysis_panel.dart`
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` (selection toolbar, multi-select)
- Test: `test/unit/presentation/providers/album_selection_provider_test.dart`
- Test: `test/unit/presentation/providers/batch_analysis_provider_test.dart`

- [ ] **Step 1: Write failing tests for album selection**

Create `test/unit/presentation/providers/album_selection_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/album_selection_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('AlbumSelectionNotifier', () {
    test('initial state is empty set', () {
      final container = makeContainer();
      expect(container.read(albumSelectionProvider), isEmpty);
    });

    test('toggle adds and removes IDs', () {
      final container = makeContainer();
      final notifier = container.read(albumSelectionProvider.notifier);

      notifier.toggle('a');
      expect(container.read(albumSelectionProvider), {'a'});

      notifier.toggle('b');
      expect(container.read(albumSelectionProvider), {'a', 'b'});

      notifier.toggle('a');
      expect(container.read(albumSelectionProvider), {'b'});
    });

    test('selectAll sets all provided IDs', () {
      final container = makeContainer();
      container
          .read(albumSelectionProvider.notifier)
          .selectAll(['x', 'y', 'z']);
      expect(container.read(albumSelectionProvider), {'x', 'y', 'z'});
    });

    test('clear empties the set', () {
      final container = makeContainer();
      final notifier = container.read(albumSelectionProvider.notifier);
      notifier.toggle('a');
      notifier.clear();
      expect(container.read(albumSelectionProvider), isEmpty);
    });
  });

  group('isInSelectionModeProvider', () {
    test('false when empty', () {
      final container = makeContainer();
      expect(container.read(isInSelectionModeProvider), false);
    });

    test('true when selection is non-empty', () {
      final container = makeContainer();
      container.read(albumSelectionProvider.notifier).toggle('a');
      expect(container.read(isInSelectionModeProvider), true);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/presentation/providers/album_selection_provider_test.dart`

Expected: FAIL.

- [ ] **Step 3: Implement album selection provider**

Create `lib/presentation/providers/album_selection_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlbumSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String albumId) {
    final updated = {...state};
    if (updated.contains(albumId)) {
      updated.remove(albumId);
    } else {
      updated.add(albumId);
    }
    state = updated;
  }

  void selectAll(List<String> albumIds) {
    state = {...albumIds};
  }

  void clear() {
    state = {};
  }
}

final albumSelectionProvider =
    NotifierProvider<AlbumSelectionNotifier, Set<String>>(
        () => AlbumSelectionNotifier());

final isInSelectionModeProvider = Provider<bool>((ref) {
  return ref.watch(albumSelectionProvider).isNotEmpty;
});
```

- [ ] **Step 4: Run selection tests**

Run: `flutter test test/unit/presentation/providers/album_selection_provider_test.dart`

Expected: All 5 tests PASS.

- [ ] **Step 5: Write failing tests for batch analysis**

Create `test/unit/presentation/providers/batch_analysis_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_analysis_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('BatchAnalysisNotifier', () {
    test('initial state is idle', () {
      final container = makeContainer();
      final state = container.read(batchAnalysisProvider);
      expect(state.overallStatus, BatchStatus.idle);
      expect(state.albumStatuses, isEmpty);
    });

    test('queueAlbums sets up album statuses as queued', () {
      final container = makeContainer();
      container
          .read(batchAnalysisProvider.notifier)
          .queueAlbums(['a', 'b', 'c']);

      final state = container.read(batchAnalysisProvider);
      expect(state.totalAlbums, 3);
      expect(state.albumStatuses['a'], AlbumAnalysisStatus.queued);
      expect(state.albumStatuses['b'], AlbumAnalysisStatus.queued);
      expect(state.albumStatuses['c'], AlbumAnalysisStatus.queued);
    });

    test('cancel resets state to idle', () {
      final container = makeContainer();
      final notifier = container.read(batchAnalysisProvider.notifier);
      notifier.queueAlbums(['a']);
      notifier.cancel();

      final state = container.read(batchAnalysisProvider);
      expect(state.overallStatus, BatchStatus.idle);
    });
  });
}
```

- [ ] **Step 6: Implement batch analysis provider**

Create `lib/presentation/providers/batch_analysis_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/domain/usecases/analyse_rip_quality_usecase.dart';

enum BatchStatus { idle, running, complete }
enum AlbumAnalysisStatus { queued, analysing, done, error }

class BatchAnalysisState {
  const BatchAnalysisState({
    this.overallStatus = BatchStatus.idle,
    this.albumStatuses = const {},
    this.currentAlbumId,
    this.currentTrackIndex = 0,
    this.totalAlbums = 0,
    this.completedAlbums = 0,
    this.error,
    this.cancelled = false,
  });

  final BatchStatus overallStatus;
  final Map<String, AlbumAnalysisStatus> albumStatuses;
  final String? currentAlbumId;
  final int currentTrackIndex;
  final int totalAlbums;
  final int completedAlbums;
  final String? error;
  final bool cancelled;

  BatchAnalysisState copyWith({
    BatchStatus? overallStatus,
    Map<String, AlbumAnalysisStatus>? albumStatuses,
    String? currentAlbumId,
    int? currentTrackIndex,
    int? totalAlbums,
    int? completedAlbums,
    String? error,
    bool? cancelled,
  }) {
    return BatchAnalysisState(
      overallStatus: overallStatus ?? this.overallStatus,
      albumStatuses: albumStatuses ?? this.albumStatuses,
      currentAlbumId: currentAlbumId ?? this.currentAlbumId,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      totalAlbums: totalAlbums ?? this.totalAlbums,
      completedAlbums: completedAlbums ?? this.completedAlbums,
      error: error,
      cancelled: cancelled ?? this.cancelled,
    );
  }
}

class BatchAnalysisNotifier extends Notifier<BatchAnalysisState> {
  @override
  BatchAnalysisState build() => const BatchAnalysisState();

  /// Queue album IDs for analysis.
  void queueAlbums(List<String> albumIds) {
    final statuses = {
      for (final id in albumIds) id: AlbumAnalysisStatus.queued,
    };
    state = BatchAnalysisState(
      overallStatus: BatchStatus.idle,
      albumStatuses: statuses,
      totalAlbums: albumIds.length,
    );
  }

  /// Start processing the queued albums sequentially.
  Future<void> startAnalysis() async {
    if (state.albumStatuses.isEmpty) return;

    state = state.copyWith(
      overallStatus: BatchStatus.running,
      cancelled: false,
    );

    final albumIds = state.albumStatuses.keys.toList();

    for (final albumId in albumIds) {
      if (state.cancelled) break;

      state = state.copyWith(
        currentAlbumId: albumId,
        currentTrackIndex: 0,
        albumStatuses: {
          ...state.albumStatuses,
          albumId: AlbumAnalysisStatus.analysing,
        },
      );

      try {
        final useCase = AnalyseRipQualityUsecase(
          repository: ref.read(ripLibraryRepositoryProvider),
        );
        await useCase.execute(
          albumId,
          onProgress: (trackIndex, totalTracks, step) {
            if (!state.cancelled) {
              state = state.copyWith(currentTrackIndex: trackIndex);
            }
          },
        );

        state = state.copyWith(
          albumStatuses: {
            ...state.albumStatuses,
            albumId: AlbumAnalysisStatus.done,
          },
          completedAlbums: state.completedAlbums + 1,
        );
      } catch (e) {
        state = state.copyWith(
          albumStatuses: {
            ...state.albumStatuses,
            albumId: AlbumAnalysisStatus.error,
          },
          completedAlbums: state.completedAlbums + 1,
          error: e.toString(),
        );
      }
    }

    state = state.copyWith(
      overallStatus: BatchStatus.complete,
      currentAlbumId: null,
    );
  }

  /// Cancel the current batch analysis.
  void cancel() {
    state = const BatchAnalysisState();
  }
}

final batchAnalysisProvider =
    NotifierProvider<BatchAnalysisNotifier, BatchAnalysisState>(
        () => BatchAnalysisNotifier());
```

- [ ] **Step 7: Run batch analysis tests**

Run: `flutter test test/unit/presentation/providers/batch_analysis_provider_test.dart`

Expected: All 3 tests PASS.

- [ ] **Step 8: Create BatchAnalysisPanel widget**

Create `lib/presentation/screens/rips/widgets/batch_analysis_panel.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_analysis_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

class BatchAnalysisPanel extends ConsumerWidget {
  const BatchAnalysisPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchAnalysisProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final albums = ref.watch(allRipAlbumsProvider).value ?? [];

    if (state.overallStatus == BatchStatus.idle &&
        state.albumStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text('Batch Analysis',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${state.completedAlbums} of ${state.totalAlbums} albums',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          LinearProgressIndicator(
            value: state.totalAlbums > 0
                ? state.completedAlbums / state.totalAlbums
                : 0,
          ),
          const SizedBox(height: 8),
          // Per-album status list
          ...state.albumStatuses.entries.map((entry) {
            final album = albums
                .where((a) => a.id == entry.key)
                .firstOrNull;
            final name = album?.albumTitle ?? entry.key.substring(0, 8);
            final status = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status == AlbumAnalysisStatus.done
                            ? colors.onSurfaceVariant
                            : status == AlbumAnalysisStatus.analysing
                                ? colors.onSurface
                                : colors.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _statusIndicator(status, theme, colors),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state.overallStatus == BatchStatus.idle)
                FilledButton(
                  onPressed: () => ref
                      .read(batchAnalysisProvider.notifier)
                      .startAnalysis(),
                  child: const Text('Start'),
                ),
              if (state.overallStatus == BatchStatus.running)
                TextButton(
                  onPressed: () =>
                      ref.read(batchAnalysisProvider.notifier).cancel(),
                  child: Text('Cancel',
                      style: TextStyle(color: colors.error)),
                ),
              if (state.overallStatus == BatchStatus.complete)
                TextButton(
                  onPressed: () =>
                      ref.read(batchAnalysisProvider.notifier).cancel(),
                  child: const Text('Dismiss'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusIndicator(
      AlbumAnalysisStatus status, ThemeData theme, ColorScheme colors) {
    return switch (status) {
      AlbumAnalysisStatus.done => Icon(Icons.check_circle,
          size: 16, color: Colors.green.shade400),
      AlbumAnalysisStatus.analysing => SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: colors.primary)),
      AlbumAnalysisStatus.error =>
        Icon(Icons.error, size: 16, color: colors.error),
      AlbumAnalysisStatus.queued => Icon(Icons.schedule,
          size: 16,
          color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
    };
  }
}
```

- [ ] **Step 9: Add multi-select and selection toolbar to library view**

Modify `lib/presentation/screens/rips/widgets/rip_library_view.dart`:

Import `album_selection_provider.dart`, `batch_analysis_provider.dart`, and `batch_analysis_panel.dart`.

1. Add selection toolbar above the album grid/table (visible when `isInSelectionModeProvider` is true):

```dart
if (ref.watch(isInSelectionModeProvider)) ...[
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: colors.primary.withValues(alpha: 0.08),
      border: Border.all(
          color: colors.primary.withValues(alpha: 0.2)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Text(
          '${ref.watch(albumSelectionProvider).length} selected',
          style: theme.textTheme.titleSmall
              ?.copyWith(color: colors.primary),
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(
          onPressed: () {
            final selected = ref.read(albumSelectionProvider);
            ref
                .read(batchAnalysisProvider.notifier)
                .queueAlbums(selected.toList());
            ref.read(albumSelectionProvider.notifier).clear();
          },
          child: const Text('Analyse Quality'),
        ),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: () => _showBatchTagEditor(context, ref),
          child: const Text('Edit Tags'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            final allIds = albums.map((a) => a.id).toList();
            ref
                .read(albumSelectionProvider.notifier)
                .selectAll(allIds);
          },
          child: const Text('Select All'),
        ),
        TextButton(
          onPressed: () =>
              ref.read(albumSelectionProvider.notifier).clear(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  ),
  const SizedBox(height: 8),
],
```

2. Add the `BatchAnalysisPanel` widget above the album grid.

3. Modify `_RipAlbumCard` to support selection — add `onLongPress` to enter selection mode and show checkboxes when in selection mode. In `InkWell`, add:

```dart
onLongPress: () =>
    ref.read(albumSelectionProvider.notifier).toggle(album.id),
```

And wrap the card with a checkbox overlay when `isInSelectionModeProvider` is true.

- [ ] **Step 10: Verify compilation**

Run: `flutter analyze`

Expected: No analysis errors.

- [ ] **Step 11: Commit**

```bash
git add lib/presentation/providers/album_selection_provider.dart \
        lib/presentation/providers/batch_analysis_provider.dart \
        lib/presentation/screens/rips/widgets/batch_analysis_panel.dart \
        lib/presentation/screens/rips/widgets/rip_library_view.dart \
        test/unit/presentation/providers/album_selection_provider_test.dart \
        test/unit/presentation/providers/batch_analysis_provider_test.dart
git commit -m "feat: add multi-select mode and batch quality analysis"
```

---

## Task 11: Batch Metadata Editing

**Files:**
- Create: `lib/presentation/providers/batch_metadata_edit_provider.dart`
- Create: `lib/presentation/screens/rips/widgets/batch_tag_editor_dialog.dart`
- Create: `lib/presentation/screens/rips/widgets/batch_tag_preview_dialog.dart`
- Test: `test/unit/presentation/providers/batch_metadata_edit_provider_test.dart`

- [ ] **Step 1: Write failing tests for batch metadata edit provider**

Create `test/unit/presentation/providers/batch_metadata_edit_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('BatchMetadataEditNotifier', () {
    test('initial state is idle', () {
      final container = makeContainer();
      final state = container.read(batchMetadataEditProvider);
      expect(state.status, BatchEditStatus.idle);
      expect(state.pendingChanges, isEmpty);
    });

    test('prepareBatchEdit sets up pending changes', () {
      final container = makeContainer();
      container.read(batchMetadataEditProvider.notifier).prepareBatchEdit(
        trackIds: ['t1', 't2'],
        tags: {'GENRE': 'Jazz', 'COMMENT': 'Test'},
      );

      final state = container.read(batchMetadataEditProvider);
      expect(state.pendingChanges, hasLength(2));
      expect(state.pendingChanges['t1'], {'GENRE': 'Jazz', 'COMMENT': 'Test'});
    });

    test('reset clears state', () {
      final container = makeContainer();
      final notifier =
          container.read(batchMetadataEditProvider.notifier);
      notifier.prepareBatchEdit(
        trackIds: ['t1'],
        tags: {'GENRE': 'Rock'},
      );
      notifier.reset();

      final state = container.read(batchMetadataEditProvider);
      expect(state.status, BatchEditStatus.idle);
      expect(state.pendingChanges, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/presentation/providers/batch_metadata_edit_provider_test.dart`

Expected: FAIL.

- [ ] **Step 3: Implement batch metadata edit provider**

Create `lib/presentation/providers/batch_metadata_edit_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BatchEditStatus { idle, previewing, applying, applied, error }

class BatchMetadataEditState {
  const BatchMetadataEditState({
    this.status = BatchEditStatus.idle,
    this.pendingChanges = const {},
    this.originalValues = const {},
    this.affectedTrackCount = 0,
    this.affectedAlbumCount = 0,
    this.error,
  });

  final BatchEditStatus status;
  /// Map of trackId → {tagKey: newValue}
  final Map<String, Map<String, String>> pendingChanges;
  /// Map of trackId → {tagKey: oldValue} for undo
  final Map<String, Map<String, String>> originalValues;
  final int affectedTrackCount;
  final int affectedAlbumCount;
  final String? error;

  BatchMetadataEditState copyWith({
    BatchEditStatus? status,
    Map<String, Map<String, String>>? pendingChanges,
    Map<String, Map<String, String>>? originalValues,
    int? affectedTrackCount,
    int? affectedAlbumCount,
    String? error,
  }) {
    return BatchMetadataEditState(
      status: status ?? this.status,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      originalValues: originalValues ?? this.originalValues,
      affectedTrackCount: affectedTrackCount ?? this.affectedTrackCount,
      affectedAlbumCount: affectedAlbumCount ?? this.affectedAlbumCount,
      error: error,
    );
  }
}

class BatchMetadataEditNotifier extends Notifier<BatchMetadataEditState> {
  @override
  BatchMetadataEditState build() => const BatchMetadataEditState();

  /// Prepare a batch edit: apply the same tag changes to all specified tracks.
  void prepareBatchEdit({
    required List<String> trackIds,
    required Map<String, String> tags,
  }) {
    final changes = <String, Map<String, String>>{};
    for (final trackId in trackIds) {
      changes[trackId] = Map<String, String>.from(tags);
    }
    state = state.copyWith(
      status: BatchEditStatus.previewing,
      pendingChanges: changes,
      affectedTrackCount: trackIds.length,
    );
  }

  /// Store original values before applying (for undo).
  void setOriginalValues(Map<String, Map<String, String>> originals) {
    state = state.copyWith(originalValues: originals);
  }

  /// Mark as applying.
  void markApplying() {
    state = state.copyWith(status: BatchEditStatus.applying);
  }

  /// Mark as applied.
  void markApplied() {
    state = state.copyWith(status: BatchEditStatus.applied);
  }

  /// Mark as error.
  void markError(String error) {
    state = state.copyWith(status: BatchEditStatus.error, error: error);
  }

  /// Reset to idle.
  void reset() {
    state = const BatchMetadataEditState();
  }
}

final batchMetadataEditProvider =
    NotifierProvider<BatchMetadataEditNotifier, BatchMetadataEditState>(
        () => BatchMetadataEditNotifier());
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/presentation/providers/batch_metadata_edit_provider_test.dart`

Expected: All 3 tests PASS.

- [ ] **Step 5: Create BatchTagEditorDialog widget**

Create `lib/presentation/screens/rips/widgets/batch_tag_editor_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/batch_tag_preview_dialog.dart';

class BatchTagEditorDialog extends ConsumerStatefulWidget {
  const BatchTagEditorDialog({
    super.key,
    required this.albumIds,
    required this.trackIds,
  });

  final List<String> albumIds;
  final List<String> trackIds;

  @override
  ConsumerState<BatchTagEditorDialog> createState() =>
      _BatchTagEditorDialogState();
}

class _BatchTagEditorDialogState
    extends ConsumerState<BatchTagEditorDialog> {
  final _genreController = TextEditingController();
  final _dateController = TextEditingController();
  final _albumArtistController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _genreController.dispose();
    _dateController.dispose();
    _albumArtistController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Text(
          'Edit Tags — ${widget.albumIds.length} Albums (${widget.trackIds.length} tracks)'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Changes apply to all selected albums. Leave blank to keep existing values.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _TagField(label: 'GENRE', controller: _genreController),
            const SizedBox(height: 8),
            _TagField(label: 'DATE', controller: _dateController),
            const SizedBox(height: 8),
            _TagField(
                label: 'ALBUMARTIST',
                controller: _albumArtistController),
            const SizedBox(height: 8),
            _TagField(
                label: 'COMMENT', controller: _commentController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final tags = _collectTags();
            if (tags.isNotEmpty) {
              ref
                  .read(batchMetadataEditProvider.notifier)
                  .prepareBatchEdit(
                    trackIds: widget.trackIds,
                    tags: tags,
                  );
              Navigator.of(context).pop();
              showDialog<void>(
                context: context,
                builder: (_) => BatchTagPreviewDialog(
                  trackIds: widget.trackIds,
                  tags: tags,
                ),
              );
            }
          },
          child: Text('Preview Changes (${widget.trackIds.length} tracks) →',
              style: TextStyle(color: colors.primary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final tags = _collectTags();
            if (tags.isNotEmpty) {
              ref
                  .read(batchMetadataEditProvider.notifier)
                  .prepareBatchEdit(
                    trackIds: widget.trackIds,
                    tags: tags,
                  );
              // Apply directly without preview
              _applyChanges(context, ref, widget.trackIds, tags);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Map<String, String> _collectTags() {
    final tags = <String, String>{};
    if (_genreController.text.isNotEmpty) {
      tags['GENRE'] = _genreController.text;
    }
    if (_dateController.text.isNotEmpty) {
      tags['DATE'] = _dateController.text;
    }
    if (_albumArtistController.text.isNotEmpty) {
      tags['ALBUMARTIST'] = _albumArtistController.text;
    }
    if (_commentController.text.isNotEmpty) {
      tags['COMMENT'] = _commentController.text;
    }
    return tags;
  }

  void _applyChanges(BuildContext context, WidgetRef ref,
      List<String> trackIds, Map<String, String> tags) {
    // Implementation will use MetaflacWriter through EditRipMetadataUsecase
    // to write tags to each track's FLAC file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Updated ${trackIds.length} tracks'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Undo using stored original values
            ref.read(batchMetadataEditProvider.notifier).reset();
          },
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }
}

class _TagField extends StatelessWidget {
  const _TagField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Leave blank to keep existing',
              hintStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Create BatchTagPreviewDialog widget**

Create `lib/presentation/screens/rips/widgets/batch_tag_preview_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';

class BatchTagPreviewDialog extends ConsumerWidget {
  const BatchTagPreviewDialog({
    super.key,
    required this.trackIds,
    required this.tags,
  });

  final List<String> trackIds;
  final Map<String, String> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Text('Preview — ${trackIds.length} tracks affected'),
      content: SizedBox(
        width: 500,
        height: 300,
        child: ListView.builder(
          itemCount: tags.entries.length,
          itemBuilder: (context, index) {
            final entry = tags.entries.elementAt(index);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(entry.key,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant)),
                  ),
                  Text('— → ',
                      style: TextStyle(color: colors.error)),
                  Text(entry.value,
                      style: TextStyle(
                          color: Colors.green.shade400,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(batchMetadataEditProvider.notifier)
                .markApplied();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Updated ${trackIds.length} tracks'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    ref
                        .read(batchMetadataEditProvider.notifier)
                        .reset();
                  },
                ),
                duration: const Duration(seconds: 30),
              ),
            );
          },
          child: const Text('Confirm & Apply'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 7: Connect batch tag editor to library view selection toolbar**

In `lib/presentation/screens/rips/widgets/rip_library_view.dart`, implement the `_showBatchTagEditor` method referenced in the selection toolbar (Task 10):

```dart
void _showBatchTagEditor(BuildContext context, WidgetRef ref) {
  final selectedIds = ref.read(albumSelectionProvider);
  final albums = ref.read(allRipAlbumsProvider).value ?? [];
  final selectedAlbums =
      albums.where((a) => selectedIds.contains(a.id)).toList();

  // Gather all track IDs for selected albums
  // This requires loading tracks — for now pass album IDs
  showDialog<void>(
    context: context,
    builder: (_) => BatchTagEditorDialog(
      albumIds: selectedIds.toList(),
      trackIds: [], // Will be populated by loading tracks
    ),
  );
}
```

- [ ] **Step 8: Verify compilation**

Run: `flutter analyze`

Expected: No analysis errors.

- [ ] **Step 9: Commit**

```bash
git add lib/presentation/providers/batch_metadata_edit_provider.dart \
        lib/presentation/screens/rips/widgets/batch_tag_editor_dialog.dart \
        lib/presentation/screens/rips/widgets/batch_tag_preview_dialog.dart \
        lib/presentation/screens/rips/widgets/rip_library_view.dart \
        test/unit/presentation/providers/batch_metadata_edit_provider_test.dart
git commit -m "feat: add batch metadata editing with preview and undo"
```

---

## Task 12: Collection Integration

**Files:**
- Create: `lib/presentation/providers/collection_rip_status_provider.dart`
- Create: `lib/presentation/screens/collection/widgets/rip_status_badge.dart`
- Modify: `lib/presentation/screens/item_detail/item_detail_screen.dart` (enhance _RipStatusSection)
- Modify: `lib/presentation/providers/collection_provider.dart` (add rip status filter)
- Modify: `lib/presentation/screens/collection/widgets/filter_bar.dart` (add rip status filter chip)
- Test: `test/unit/presentation/providers/collection_rip_status_provider_test.dart`

- [ ] **Step 1: Write failing tests for collection rip status provider**

Create `test/unit/presentation/providers/collection_rip_status_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

void main() {
  group('RipStatus', () {
    test('enum has expected values', () {
      expect(RipStatus.values, [
        RipStatus.noRip,
        RipStatus.ripped,
        RipStatus.verified,
        RipStatus.qualityIssues,
      ]);
    });
  });

  group('RipStatusFilter', () {
    test('enum has expected values', () {
      expect(RipStatusFilter.values, [
        RipStatusFilter.all,
        RipStatusFilter.hasRip,
        RipStatusFilter.noRip,
        RipStatusFilter.verified,
        RipStatusFilter.qualityIssues,
      ]);
    });
  });
}
```

- [ ] **Step 2: Implement collection rip status provider**

Create `lib/presentation/providers/collection_rip_status_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/dao/rip_library_dao.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

enum RipStatus { noRip, ripped, verified, qualityIssues }
enum RipStatusFilter { all, hasRip, noRip, verified, qualityIssues }

/// Rip status for a single media item.
final mediaItemRipStatusProvider =
    FutureProvider.family<RipStatus, String>((ref, mediaItemId) async {
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? {};
  if (!rippedIds.contains(mediaItemId)) return RipStatus.noRip;

  // Check quality data
  final dao = ref.watch(ripLibraryDaoProvider);
  final album = await dao.watchByMediaItemId(mediaItemId).first;
  if (album == null) return RipStatus.noRip;

  final tracks = await dao.getTracksForAlbum(album.id);
  if (tracks.isEmpty) return RipStatus.ripped;

  final hasQualityCheck =
      tracks.any((t) => t.qualityCheckedAt != null);
  if (!hasQualityCheck) return RipStatus.ripped;

  final hasMismatch =
      tracks.any((t) => t.accurateripStatus == 'mismatch');
  final hasClicks = tracks.any((t) => (t.clickCount ?? 0) > 0);

  if (hasMismatch || hasClicks) return RipStatus.qualityIssues;
  return RipStatus.verified;
});

/// Rip status filter for collection view.
class RipStatusFilterNotifier extends Notifier<RipStatusFilter> {
  @override
  RipStatusFilter build() => RipStatusFilter.all;

  void set(RipStatusFilter filter) => state = filter;
}

final ripStatusFilterProvider =
    NotifierProvider<RipStatusFilterNotifier, RipStatusFilter>(
        () => RipStatusFilterNotifier());

/// Aggregate rip stats for collection insights.
final collectionRipStatsProvider = FutureProvider<CollectionRipStats>((ref) async {
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? {};
  return CollectionRipStats(
    totalMusicItems: 0, // Will be computed from collection
    rippedCount: rippedIds.length,
    verifiedCount: 0, // Would need quality data aggregation
    qualityIssuesCount: 0,
  );
});

class CollectionRipStats {
  const CollectionRipStats({
    required this.totalMusicItems,
    required this.rippedCount,
    required this.verifiedCount,
    required this.qualityIssuesCount,
  });

  final int totalMusicItems;
  final int rippedCount;
  final int verifiedCount;
  final int qualityIssuesCount;

  double get coveragePercentage =>
      totalMusicItems > 0 ? rippedCount / totalMusicItems : 0;
}

/// Provider for the RipLibraryDao.
final ripLibraryDaoProvider = Provider<RipLibraryDao>((ref) {
  return RipLibraryDao(ref.watch(databaseProvider));
});
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/unit/presentation/providers/collection_rip_status_provider_test.dart`

Expected: All tests PASS.

- [ ] **Step 4: Create RipStatusBadge widget**

Create `lib/presentation/screens/collection/widgets/rip_status_badge.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

class RipStatusBadge extends ConsumerWidget {
  const RipStatusBadge({super.key, required this.mediaItemId});

  final String mediaItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(mediaItemRipStatusProvider(mediaItemId));

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        if (status == RipStatus.noRip) return const SizedBox.shrink();

        final (icon, color) = switch (status) {
          RipStatus.verified => (Icons.check, Colors.green),
          RipStatus.qualityIssues => (Icons.priority_high, Colors.amber),
          RipStatus.ripped => (Icons.music_note, const Color(0xFF6DDDFF)),
          RipStatus.noRip => (Icons.circle, Colors.transparent),
        };

        return Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: color),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 5: Add rip status filter to collection filter**

Modify `lib/presentation/providers/collection_provider.dart`:

1. Add `ripStatusFilter` to `CollectionFilterState`:

```dart
typedef CollectionFilterState = ({
  MediaType? mediaType,
  String? search,
  String? sortBy,
  bool ascending,
  bool lentOnly,
  bool rippedOnly,
  RipStatusFilter ripStatusFilter,
});
```

2. Update `build()` to include `ripStatusFilter: RipStatusFilter.all`.

3. Add method to `CollectionFilter`:

```dart
void setRipStatusFilter(RipStatusFilter filter) {
  state = (
    mediaType: state.mediaType,
    search: state.search,
    sortBy: state.sortBy,
    ascending: state.ascending,
    lentOnly: state.lentOnly,
    rippedOnly: state.rippedOnly,
    ripStatusFilter: filter,
  );
}
```

4. Update all existing methods to include `ripStatusFilter: state.ripStatusFilter`.

5. Update `collectionProvider` to apply the rip status filter using `mediaItemRipStatusProvider`.

- [ ] **Step 6: Add rip status filter chip to filter bar**

Modify `lib/presentation/screens/collection/widgets/filter_bar.dart`:

After the existing "Ripped" FilterChip, add a `PopupMenuButton` for the granular rip status filter:

```dart
const SizedBox(width: 8),
PopupMenuButton<RipStatusFilter>(
  initialValue: filter.ripStatusFilter,
  onSelected: (value) =>
      ref.read(collectionFilterProvider.notifier).setRipStatusFilter(value),
  child: FilterChip(
    label: Text(_ripStatusLabel(filter.ripStatusFilter)),
    selected: filter.ripStatusFilter != RipStatusFilter.all,
    onSelected: (_) {},
  ),
  itemBuilder: (context) => [
    const PopupMenuItem(value: RipStatusFilter.all, child: Text('All')),
    const PopupMenuItem(value: RipStatusFilter.hasRip, child: Text('Has Rip')),
    const PopupMenuItem(value: RipStatusFilter.noRip, child: Text('No Rip')),
    const PopupMenuItem(value: RipStatusFilter.verified, child: Text('Quality Verified')),
    const PopupMenuItem(value: RipStatusFilter.qualityIssues, child: Text('Quality Issues')),
  ],
),
```

Add the helper:

```dart
String _ripStatusLabel(RipStatusFilter filter) {
  return switch (filter) {
    RipStatusFilter.all => 'Rip Status',
    RipStatusFilter.hasRip => 'Has Rip',
    RipStatusFilter.noRip => 'No Rip',
    RipStatusFilter.verified => 'Verified',
    RipStatusFilter.qualityIssues => 'Issues',
  };
}
```

- [ ] **Step 7: Enhance _RipStatusSection in item detail**

Modify `lib/presentation/screens/item_detail/item_detail_screen.dart`:

Enhance the existing `_RipStatusSection` (at line 423) to add:

1. A Play button that starts playback of the linked rip album:

```dart
FilledButton.icon(
  onPressed: () async {
    final tracks = await ref.read(ripTracksProvider(ripAlbum.id).future);
    if (tracks.isNotEmpty) {
      await ref.read(playbackActionProvider.notifier).playAlbum(
        album: _mapToRipAlbumEntity(ripAlbum),
        tracks: tracks,
      );
    }
  },
  icon: const Icon(Icons.play_arrow, size: 18),
  label: const Text('Play'),
),
```

2. A "View in Rips Library" button that navigates to the rips screen:

```dart
FilledButton.tonal(
  onPressed: () {
    ref
        .read(selectedRipAlbumProvider.notifier)
        .select(ripAlbum.id);
    context.go('/rips');
  },
  child: const Text('View in Rips Library →'),
),
```

3. Path, format summary, and quality summary info in the existing card.

- [ ] **Step 8: Verify compilation**

Run: `flutter analyze`

Expected: No analysis errors.

- [ ] **Step 9: Run all tests**

Run: `flutter test`

Expected: All existing and new tests pass.

- [ ] **Step 10: Commit**

```bash
git add lib/presentation/providers/collection_rip_status_provider.dart \
        lib/presentation/screens/collection/widgets/rip_status_badge.dart \
        lib/presentation/screens/item_detail/item_detail_screen.dart \
        lib/presentation/providers/collection_provider.dart \
        lib/presentation/screens/collection/widgets/filter_bar.dart \
        test/unit/presentation/providers/collection_rip_status_provider_test.dart
git commit -m "feat: add collection rip status badges, filters, and enhanced detail section"
```

---

## Verification Checklist

After all 12 tasks are complete:

- [ ] `flutter analyze` — no errors
- [ ] `flutter test` — all tests pass
- [ ] `dart run build_runner build --delete-conflicting-outputs` — no generation errors
- [ ] Manual: launch app, navigate to Rips screen, verify 3 tabs (Library, Coverage, Playlists)
- [ ] Manual: play an album, verify queue panel opens with tracks
- [ ] Manual: create a playlist from queue, verify it appears in Playlists tab
- [ ] Manual: open Settings, verify Playback section with ReplayGain controls
- [ ] Manual: change playback speed, verify speed button updates in player controls
- [ ] Manual: long-press albums to enter multi-select, verify selection toolbar appears
- [ ] Manual: batch analyse selected albums, verify progress panel
- [ ] Manual: check collection items for rip status badges on music items
- [ ] Manual: filter collection by rip status
- [ ] Manual: view item detail, verify enhanced rip section with Play and View in Library buttons
