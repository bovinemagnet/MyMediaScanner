# Review Suggestions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Address 5 code review suggestions: context menu actions, analyse-all button, Freezed state classes, deeper rip status tests, and transaction safety for playlist reorder.

**Architecture:** Small, independent improvements across existing providers and UI widgets. No new tables or entities. Freezed conversion requires build_runner regeneration.

**Tech Stack:** Flutter, Riverpod 3.x, Drift, Freezed, mocktail

---

## Task 1: Context Menu Actions (Play Next, Add to Queue, Add to Playlist)

**Files:**
- Modify: `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart` (add popup menu to track tiles)

- [x] **Step 1: Read the current track tile implementation**

Read `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart` to understand the `_TrackTile` widget structure, particularly the `trailing` Row around line 554 and the `onTap` handler.

- [x] **Step 2: Add a PopupMenuButton to each track tile**

In the `_TrackTile` widget's `trailing` Row, add a `PopupMenuButton` with three entries before the expand/collapse button:

```dart
PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, size: 18),
  tooltip: 'Track actions',
  onSelected: (action) {
    final queueItem = QueueItem(
      album: album,
      track: track,
      source: QueueItemSource.manual,
    );
    switch (action) {
      case 'play_next':
        ref.read(queueProvider.notifier).playNext(queueItem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing "${track.title ?? "Track"}" next')),
        );
      case 'add_to_queue':
        ref.read(queueProvider.notifier).addAlbumToQueue(album, [track]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added "${track.title ?? "Track"}" to queue')),
        );
      case 'add_to_playlist':
        _showAddToPlaylistDialog(context, ref, track.id);
    }
  },
  itemBuilder: (context) => const [
    PopupMenuItem(value: 'play_next', child: Text('Play Next')),
    PopupMenuItem(value: 'add_to_queue', child: Text('Add to Queue')),
    PopupMenuItem(value: 'add_to_playlist', child: Text('Add to Playlist...')),
  ],
),
```

The `_TrackTile` needs access to the `RipAlbum album` — pass it through the constructor if not already available.

- [x] **Step 3: Add the "Add to Playlist" dialog helper**

Add a top-level helper function (or method on the dialog state) that shows a dialog listing all playlists from `allPlaylistsProvider`:

```dart
void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, String trackId) {
  final playlistsAsync = ref.read(allPlaylistsProvider);
  final playlists = playlistsAsync.value ?? [];

  if (playlists.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No playlists yet. Create one first.')),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Add to Playlist'),
      children: playlists.map((p) => SimpleDialogOption(
        onPressed: () {
          ref.read(playlistCrudProvider.notifier).addTracksToPlaylist(p.id, [trackId]);
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to "${p.name}"')),
          );
        },
        child: Text(p.name),
      )).toList(),
    ),
  );
}
```

- [x] **Step 4: Add imports**

Add these imports to `rip_album_detail_dialog.dart`:
```dart
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';
```

- [x] **Step 5: Verify**

Run: `flutter analyze`
Expected: No errors.

- [x] **Step 6: Commit**

```bash
git add lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart
git commit -m "feat: add Play Next, Add to Queue, and Add to Playlist track actions"
```

---

## Task 2: "Analyse All Un-analysed" Button

**Files:**
- Modify: `lib/data/local/dao/rip_library_dao.dart` (add query for un-analysed albums)
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` (add button)
- Test: `test/unit/data/dao/rip_library_dao_test.dart` (test new query)

- [x] **Step 1: Add DAO method to find un-analysed album IDs**

In `lib/data/local/dao/rip_library_dao.dart`, add a method that returns album IDs where at least one track has no `qualityCheckedAt`:

```dart
/// Returns IDs of non-deleted albums that have at least one track
/// without a quality check.
Future<List<String>> getUnanalysedAlbumIds() async {
  final query = customSelect(
    'SELECT DISTINCT ra.id FROM rip_albums ra '
    'INNER JOIN rip_tracks rt ON rt.rip_album_id = ra.id '
    'WHERE ra.deleted = 0 AND rt.quality_checked_at IS NULL',
  );
  final rows = await query.get();
  return rows.map((row) => row.read<String>('id')).toList();
}
```

- [x] **Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [x] **Step 3: Write test for the new DAO method**

Add a test to `test/unit/data/dao/rip_library_dao_test.dart`:

```dart
test('getUnanalysedAlbumIds returns albums with unchecked tracks', () async {
  // Seed an album with tracks (no qualityCheckedAt)
  // Call getUnanalysedAlbumIds()
  // Expect the album ID to be in the list
});
```

Read the existing test file to follow the setup pattern (in-memory DB, seed albums and tracks).

- [x] **Step 4: Run test**

Run: `flutter test test/unit/data/dao/rip_library_dao_test.dart`
Expected: PASS.

- [x] **Step 5: Add "Analyse All" button to library view toolbar**

In `lib/presentation/screens/rips/widgets/rip_library_view.dart`, in the toolbar area (after the "Scan Library" button, before the view mode toggle), add:

```dart
FilledButton.tonal(
  onPressed: batchState.status == BatchStatus.running
      ? null
      : () async {
          final dao = ref.read(ripLibraryDaoProvider);
          final unanalysed = await dao.getUnanalysedAlbumIds();
          if (unanalysed.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All albums already analysed')),
              );
            }
            return;
          }
          ref.read(batchAnalysisProvider.notifier).queueAlbums(unanalysed);
          ref.read(batchAnalysisProvider.notifier).startAnalysis();
        },
  child: const Text('Analyse All'),
),
```

This button should be visible when NOT in selection mode. Add the necessary imports and watch `batchAnalysisProvider` for the `batchState`.

- [x] **Step 6: Verify**

Run: `flutter analyze`
Expected: No errors.

- [x] **Step 7: Commit**

```bash
git add lib/data/local/dao/rip_library_dao.dart \
        lib/data/local/dao/rip_library_dao.g.dart \
        lib/presentation/screens/rips/widgets/rip_library_view.dart \
        test/unit/data/dao/rip_library_dao_test.dart
git commit -m "feat: add Analyse All button for un-analysed albums"
```

---

## Task 3: Convert State Classes to Freezed

**Files:**
- Modify: `lib/presentation/providers/queue_provider.dart` (QueueState → @freezed)
- Modify: `lib/presentation/providers/batch_analysis_provider.dart` (BatchAnalysisState → @freezed)
- Modify: `lib/presentation/providers/batch_metadata_edit_provider.dart` (BatchMetadataEditState → @freezed)

- [x] **Step 1: Convert QueueState to Freezed**

In `lib/presentation/providers/queue_provider.dart`:

1. Add `import 'package:freezed_annotation/freezed_annotation.dart';`
2. Add `part 'queue_provider.freezed.dart';`
3. Replace the manual `QueueState` class with:

```dart
@freezed
sealed class QueueState with _$QueueState {
  const factory QueueState({
    @Default([]) List<QueueItem> items,
    @Default(-1) int currentIndex,
    @Default([]) List<QueueItem> history,
  }) = _QueueState;
}
```

4. Remove the manual `copyWith` method.

- [x] **Step 2: Convert BatchAnalysisState to Freezed**

In `lib/presentation/providers/batch_analysis_provider.dart`:

1. Add freezed import and part directive
2. Replace `BatchAnalysisState` with:

```dart
@freezed
sealed class BatchAnalysisState with _$BatchAnalysisState {
  const factory BatchAnalysisState({
    @Default(BatchStatus.idle) BatchStatus status,
    @Default({}) Map<String, AlbumAnalysisStatus> albumStatuses,
  }) = _BatchAnalysisState;
}
```

- [x] **Step 3: Convert BatchMetadataEditState to Freezed**

In `lib/presentation/providers/batch_metadata_edit_provider.dart`:

1. Add freezed import and part directive
2. Replace `BatchMetadataEditState` with:

```dart
@freezed
sealed class BatchMetadataEditState with _$BatchMetadataEditState {
  const factory BatchMetadataEditState({
    @Default(BatchEditStatus.idle) BatchEditStatus status,
    @Default({}) Map<String, Map<String, String>> pendingChanges,
    @Default({}) Map<String, Map<String, String>> originalValues,
    @Default(0) int affectedTrackCount,
    @Default(0) int affectedAlbumCount,
    String? error,
  }) = _BatchMetadataEditState;
}
```

- [x] **Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `.freezed.dart` files for all three.

- [x] **Step 5: Run all tests**

Run: `flutter test`
Expected: All tests pass — Freezed's generated `copyWith` is API-compatible with the manual one.

- [x] **Step 6: Commit**

```bash
git add lib/presentation/providers/queue_provider.dart \
        lib/presentation/providers/queue_provider.freezed.dart \
        lib/presentation/providers/batch_analysis_provider.dart \
        lib/presentation/providers/batch_analysis_provider.freezed.dart \
        lib/presentation/providers/batch_metadata_edit_provider.dart \
        lib/presentation/providers/batch_metadata_edit_provider.freezed.dart
git commit -m "refactor: convert state classes to Freezed for consistency"
```

---

## Task 4: Deeper Tests for Rip Status Providers

**Files:**
- Modify: `test/unit/presentation/providers/collection_rip_status_provider_test.dart`

- [x] **Step 1: Read current tests and provider logic**

Read `test/unit/presentation/providers/collection_rip_status_provider_test.dart` and `lib/presentation/providers/collection_rip_status_provider.dart` to understand what's tested vs what needs testing.

- [x] **Step 2: Add functional tests**

Expand the test file with these test groups:

```dart
group('RipStatusFilterNotifier', () {
  test('initial state is all', () {
    final container = makeContainer();
    expect(container.read(ripStatusFilterProvider), RipStatusFilter.all);
  });

  test('set updates state', () {
    final container = makeContainer();
    container.read(ripStatusFilterProvider.notifier).set(RipStatusFilter.hasRip);
    expect(container.read(ripStatusFilterProvider), RipStatusFilter.hasRip);
  });

  test('set to same value is idempotent', () {
    final container = makeContainer();
    container.read(ripStatusFilterProvider.notifier).set(RipStatusFilter.noRip);
    container.read(ripStatusFilterProvider.notifier).set(RipStatusFilter.noRip);
    expect(container.read(ripStatusFilterProvider), RipStatusFilter.noRip);
  });
});

group('CollectionRipStats', () {
  test('coveragePercentage is 0 when no music items', () {
    const stats = CollectionRipStats(
      totalMusicItems: 0,
      rippedCount: 0,
      verifiedCount: 0,
      qualityIssuesCount: 0,
    );
    expect(stats.coveragePercentage, 0.0);
  });

  test('coveragePercentage calculates correctly', () {
    const stats = CollectionRipStats(
      totalMusicItems: 10,
      rippedCount: 3,
      verifiedCount: 2,
      qualityIssuesCount: 1,
    );
    expect(stats.coveragePercentage, 0.3);
  });
});
```

The `RipStatusFilterNotifier` tests need a `ProviderContainer` — follow the pattern from the queue provider tests. The `CollectionRipStats` tests are pure unit tests on the data class.

- [x] **Step 3: Run tests**

Run: `flutter test test/unit/presentation/providers/collection_rip_status_provider_test.dart`
Expected: All tests PASS.

- [x] **Step 4: Commit**

```bash
git add test/unit/presentation/providers/collection_rip_status_provider_test.dart
git commit -m "test: add functional tests for rip status filter and stats"
```

---

## Task 5: Transaction Safety for Playlist Reorder

**Files:**
- Modify: `lib/data/local/dao/playlist_dao.dart` (add transactional reorder method)
- Modify: `lib/presentation/providers/playlist_provider.dart` (use new DAO method)
- Test: `test/unit/data/dao/playlist_dao_test.dart` (test transactional reorder)

- [x] **Step 1: Add transactional reorder method to PlaylistDao**

In `lib/data/local/dao/playlist_dao.dart`, add:

```dart
/// Atomically reorders tracks in a playlist by clearing and re-inserting
/// within a single transaction.
Future<void> reorderTracks(
    String playlistId, List<PlaylistTracksTableCompanion> companions) {
  return transaction(() async {
    await (delete(playlistTracksTable)
          ..where((t) => t.playlistId.equals(playlistId)))
        .go();
    await batch((b) {
      b.insertAll(playlistTracksTable, companions);
    });
  });
}
```

- [x] **Step 2: Update PlaylistCrudNotifier to use the new method**

In `lib/presentation/providers/playlist_provider.dart`, modify `reorderPlaylistTracks()` to call the new DAO method instead of calling `clearPlaylistTracks()` + `insertPlaylistTracks()` separately:

```dart
Future<void> reorderPlaylistTracks(
    String playlistId, List<String> orderedPlaylistTrackIds) async {
  final existing = await _dao.getTracksForPlaylist(playlistId);
  final byId = {for (final t in existing) t.id: t};
  final now = DateTime.now().millisecondsSinceEpoch;

  final companions = orderedPlaylistTrackIds.indexed.map((entry) {
    final (index, ptId) = entry;
    final original = byId[ptId]!;
    return PlaylistTracksTableCompanion.insert(
      id: ptId,
      playlistId: playlistId,
      ripTrackId: original.ripTrackId,
      sortOrder: index + 1,
      addedAt: now,
    );
  }).toList();

  await _dao.reorderTracks(playlistId, companions);
  ref.invalidate(playlistTracksProvider(playlistId));
}
```

- [x] **Step 3: Add test for transactional reorder**

Add to `test/unit/data/dao/playlist_dao_test.dart`:

```dart
test('reorderTracks atomically clears and re-inserts', () async {
  // Seed playlist with 3 tracks in order A, B, C
  // Call reorderTracks with order C, A, B
  // Verify tracks come back in new order
  // Verify count is still 3 (nothing lost)
});
```

- [x] **Step 4: Run build_runner and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/unit/data/dao/playlist_dao_test.dart`
Expected: All tests PASS.

- [x] **Step 5: Commit**

```bash
git add lib/data/local/dao/playlist_dao.dart \
        lib/data/local/dao/playlist_dao.g.dart \
        lib/presentation/providers/playlist_provider.dart \
        test/unit/data/dao/playlist_dao_test.dart
git commit -m "fix: wrap playlist reorder in Drift transaction for atomicity"
```

---

## Verification

After all 5 tasks:

- [x] `flutter analyze` — no errors
- [x] `flutter test` — all tests pass
- [x] `dart run build_runner build --delete-conflicting-outputs` — no generation errors
