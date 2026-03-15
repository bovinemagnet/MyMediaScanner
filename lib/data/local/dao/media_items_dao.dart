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

  /// Full-text search using FTS5.
  Future<List<MediaItemsTableData>> search(String query) async {
    final ftsQuery = _buildFtsQuery(query);
    if (ftsQuery.isEmpty) return [];
    final results = await customSelect(
      'SELECT m.* FROM media_items m '
      'INNER JOIN media_items_fts f ON m.rowid = f.rowid '
      'WHERE media_items_fts MATCH ? AND m.deleted = 0 '
      'ORDER BY rank',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {mediaItemsTable},
    ).get();
    return results.map((row) => mediaItemsTable.map(row.data)).toList();
  }

  /// Reactive full-text search using FTS5.
  Stream<List<MediaItemsTableData>> watchSearch(String query) {
    final ftsQuery = _buildFtsQuery(query);
    if (ftsQuery.isEmpty) return Stream.value([]);
    return customSelect(
      'SELECT m.* FROM media_items m '
      'INNER JOIN media_items_fts f ON m.rowid = f.rowid '
      'WHERE media_items_fts MATCH ? AND m.deleted = 0 '
      'ORDER BY rank',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {mediaItemsTable},
    )
        .watch()
        .map((rows) => rows.map((row) => mediaItemsTable.map(row.data)).toList());
  }

  /// Builds an FTS5 query with prefix matching on the last word.
  String _buildFtsQuery(String input) {
    final words = input.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || (words.length == 1 && words.first.isEmpty)) return '';
    final parts = words.asMap().entries.map((e) {
      final word = e.value.replaceAll('"', '""');
      return e.key == words.length - 1 ? '"$word"*' : '"$word"';
    });
    return parts.join(' ');
  }
}
