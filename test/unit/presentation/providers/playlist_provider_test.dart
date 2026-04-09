/// Tests for the playlist CRUD Riverpod providers.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';

void main() {
  late AppDatabase testDb;

  setUp(() {
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDb.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(testDb),
        playlistDaoProvider.overrideWithValue(testDb.playlistDao),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // Helper: subscribe to allPlaylistsProvider and wait for a value to emit.
  Future<List<PlaylistsTableData>> readPlaylists(
      ProviderContainer container) async {
    // Subscribing via listen ensures the StreamProvider is active.
    container.listen(allPlaylistsProvider, (_, __) {});
    for (var i = 0; i < 100; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final asyncVal = container.read(allPlaylistsProvider);
      if (asyncVal.hasValue) return asyncVal.requireValue;
    }
    fail('allPlaylistsProvider did not resolve');
  }

  // ---------------------------------------------------------------------------
  // createPlaylist
  // ---------------------------------------------------------------------------

  group('PlaylistCrudNotifier.createPlaylist', () {
    test('createPlaylist_validName_createsNewPlaylist', () async {
      final container = createContainer();

      await container
          .read(playlistCrudProvider.notifier)
          .createPlaylist('Chill Mix');

      final playlists = await readPlaylists(container);

      expect(playlists.length, 1);
      expect(playlists.first.name, 'Chill Mix');
      expect(playlists.first.deleted, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // renamePlaylist
  // ---------------------------------------------------------------------------

  group('PlaylistCrudNotifier.renamePlaylist', () {
    test('renamePlaylist_existingId_updatesName', () async {
      final container = createContainer();
      final notifier = container.read(playlistCrudProvider.notifier);

      final id = await notifier.createPlaylist('Old Name');
      await notifier.renamePlaylist(id, 'New Name');

      final playlist = await testDb.playlistDao.getById(id);

      expect(playlist, isNotNull);
      expect(playlist!.name, 'New Name');
    });
  });

  // ---------------------------------------------------------------------------
  // deletePlaylist
  // ---------------------------------------------------------------------------

  group('PlaylistCrudNotifier.deletePlaylist', () {
    test('deletePlaylist_existingId_softDeletesRecord', () async {
      final container = createContainer();
      final notifier = container.read(playlistCrudProvider.notifier);

      final id = await notifier.createPlaylist('To Delete');
      await notifier.deletePlaylist(id);

      // watchAll excludes soft-deleted rows.
      final playlists = await readPlaylists(container);
      expect(playlists, isEmpty);

      // Verify the row still exists in the DB with deleted=1.
      final raw = await (testDb.select(testDb.playlistsTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      expect(raw, isNotNull);
      expect(raw!.deleted, 1);
    });
  });
}
