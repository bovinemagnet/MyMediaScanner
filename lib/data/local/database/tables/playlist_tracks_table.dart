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
