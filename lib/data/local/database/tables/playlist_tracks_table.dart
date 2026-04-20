import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/playlists_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_tracks_table.dart';

class PlaylistTracksTable extends Table {
  @override
  String get tableName => 'playlist_tracks';

  TextColumn get id => text()();
  // Cascade on the parent side — if a playlist is deleted, its membership
  // rows disappear with it. Without this the orphan rows keep referencing
  // a non-existent playlist and show up in queries.
  TextColumn get playlistId =>
      text().references(PlaylistsTable, #id, onDelete: KeyAction.cascade)();
  // Cascade on rip-track side too — the v17 migration drops/re-creates
  // rip_tracks wholesale, and we don't want playlists left referencing
  // rows that no longer exist.
  TextColumn get ripTrackId =>
      text().references(RipTracksTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer()();
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
