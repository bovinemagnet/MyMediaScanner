// Playlist CRUD providers — wrap PlaylistDao for reactive playlist management.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/dao/playlist_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// DAO provider
// ---------------------------------------------------------------------------

final playlistDaoProvider = Provider<PlaylistDao>((ref) {
  return ref.watch(databaseProvider).playlistDao;
});

// ---------------------------------------------------------------------------
// Read providers
// ---------------------------------------------------------------------------

/// Stream of all non-deleted playlists, ordered by most recently updated.
final allPlaylistsProvider =
    StreamProvider<List<PlaylistsTableData>>((ref) {
  return ref.watch(playlistDaoProvider).watchAll();
});

/// Tracks for a specific playlist, ordered by sort_order ascending.
final playlistTracksProvider =
    FutureProvider.family<List<PlaylistTracksTableData>, String>(
        (ref, playlistId) {
  return ref.watch(playlistDaoProvider).getTracksForPlaylist(playlistId);
});

/// Rip track rows for a specific playlist, joined directly in SQL.
///
/// Returns [RipTracksTableData] in playlist sort order, avoiding the
/// O(albums * tracks) lookup loop in the UI layer.
final playlistRipTracksProvider =
    FutureProvider.family<List<RipTracksTableData>, String>(
        (ref, playlistId) {
  return ref.watch(playlistDaoProvider).getRipTracksForPlaylist(playlistId);
});

// ---------------------------------------------------------------------------
// Selected playlist
// ---------------------------------------------------------------------------

final selectedPlaylistProvider =
    NotifierProvider<SelectedPlaylistNotifier, String?>(
  SelectedPlaylistNotifier.new,
);

class SelectedPlaylistNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
  void clear() => state = null;
}

// ---------------------------------------------------------------------------
// CRUD notifier
// ---------------------------------------------------------------------------

final playlistCrudProvider =
    NotifierProvider<PlaylistCrudNotifier, void>(PlaylistCrudNotifier.new);

class PlaylistCrudNotifier extends Notifier<void> {
  static const _uuid = Uuid();

  @override
  void build() {}

  PlaylistDao get _dao => ref.read(playlistDaoProvider);

  /// Creates a new playlist with [name] and optional [description].
  /// Returns the new playlist's ID.
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

  /// Renames an existing playlist.
  Future<void> renamePlaylist(String id, String newName) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.updatePlaylist(PlaylistsTableCompanion(
      id: Value(id),
      name: Value(newName),
      updatedAt: Value(now),
    ));
    ref.invalidate(allPlaylistsProvider);
  }

  /// Soft-deletes a playlist.
  Future<void> deletePlaylist(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.softDeletePlaylist(id, now);
    ref.invalidate(allPlaylistsProvider);
    // Clear selection if the deleted playlist was selected.
    if (ref.read(selectedPlaylistProvider) == id) {
      ref.read(selectedPlaylistProvider.notifier).clear();
    }
  }

  /// Appends [trackIds] to [playlistId], assigning sequential sort orders
  /// after any existing tracks.
  Future<void> addTracksToPlaylist(
      String playlistId, List<String> trackIds) async {
    if (trackIds.isEmpty) return;
    final existing = await _dao.getTracksForPlaylist(playlistId);
    final maxOrder =
        existing.isEmpty ? 0 : existing.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b);
    final now = DateTime.now().millisecondsSinceEpoch;
    final companions = trackIds.indexed.map((entry) {
      final (index, ripTrackId) = entry;
      return PlaylistTracksTableCompanion.insert(
        id: _uuid.v4(),
        playlistId: playlistId,
        ripTrackId: ripTrackId,
        sortOrder: maxOrder + index + 1,
        addedAt: now,
      );
    }).toList();
    await _dao.insertPlaylistTracks(companions);
    ref.invalidate(playlistTracksProvider(playlistId));
  }

  /// Removes a single playlist track entry by its [playlistTrackId].
  Future<void> removeTrackFromPlaylist(
      String playlistId, String playlistTrackId) async {
    await _dao.removeTrackFromPlaylist(playlistTrackId);
    ref.invalidate(playlistTracksProvider(playlistId));
  }

  /// Reorders playlist tracks by replacing the full track list with new
  /// [orderedPlaylistTrackIds] reflecting the desired sort order.
  Future<void> reorderPlaylistTracks(
      String playlistId, List<String> orderedPlaylistTrackIds) async {
    final existing = await _dao.getTracksForPlaylist(playlistId);
    final byId = {for (final t in existing) t.id: t};
    final now = DateTime.now().millisecondsSinceEpoch;

    // Build companions in the desired order then atomically clear + re-insert.
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
}
