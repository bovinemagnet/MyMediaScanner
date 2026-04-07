import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';

void main() {
  group('SyncStrategy.mergeFields', () {
    test('local wins when local updatedAt is newer', () {
      final local = {'title': 'Local Title', 'updated_at': 2000};
      final remote = {'title': 'Remote Title', 'updated_at': 1000};

      final merged = SyncStrategy.mergeFields(local, remote);

      expect(merged['title'], 'Local Title');
    });

    test('remote wins when remote updatedAt is newer', () {
      final local = {'title': 'Local Title', 'updated_at': 1000};
      final remote = {'title': 'Remote Title', 'updated_at': 2000};

      final merged = SyncStrategy.mergeFields(local, remote);

      expect(merged['title'], 'Remote Title');
    });

    test('local wins on equal timestamps', () {
      final local = {'title': 'Local', 'updated_at': 1000};
      final remote = {'title': 'Remote', 'updated_at': 1000};

      final merged = SyncStrategy.mergeFields(local, remote);

      expect(merged['title'], 'Local');
    });
  });

  group('SyncStrategy.detectConflicts', () {
    test('no conflict when timestamps are far apart', () {
      final local = {
        'title': 'Local Title',
        'updated_at': 1000,
      };
      final remote = {
        'title': 'Remote Title',
        'updated_at': 200000, // well beyond default 60s threshold
      };

      final conflicts = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
      );

      expect(conflicts, isEmpty);
    });

    test('detects conflict when timestamps are close and values differ', () {
      final local = {
        'title': 'Local Title',
        'year': 2020,
        'updated_at': 1000,
      };
      final remote = {
        'title': 'Remote Title',
        'year': 2021,
        'updated_at': 1030, // within 60s threshold
      };

      final conflicts = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
      );

      expect(conflicts.length, 2);
      expect(conflicts.map((c) => c.fieldName), containsAll(['title', 'year']));
    });

    test('no conflict when values are identical even if timestamps are close',
        () {
      final local = {
        'title': 'Same Title',
        'year': 2020,
        'updated_at': 1000,
      };
      final remote = {
        'title': 'Same Title',
        'year': 2020,
        'updated_at': 1030,
      };

      final conflicts = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
      );

      expect(conflicts, isEmpty);
    });

    test('ignores meta fields like id and updated_at', () {
      final local = {
        'id': 'local-id',
        'title': 'Local Title',
        'updated_at': 1000,
        'synced_at': 900,
      };
      final remote = {
        'id': 'remote-id',
        'title': 'Remote Title',
        'updated_at': 1030,
        'synced_at': 950,
      };

      final conflicts = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
      );

      // Only title should conflict, not id or synced_at
      expect(conflicts.length, 1);
      expect(conflicts.first.fieldName, 'title');
    });

    test('respects custom threshold', () {
      final local = {
        'title': 'Local',
        'updated_at': 1000,
      };
      final remote = {
        'title': 'Remote',
        'updated_at': 1500,
      };

      // With default threshold (60s = 60000ms), 500ms apart = conflict
      final conflictsDefault = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
      );
      expect(conflictsDefault.length, 1);

      // With tiny threshold (100ms), 500ms apart = no conflict
      final conflictsStrict = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
        thresholdMs: 100,
      );
      expect(conflictsStrict, isEmpty);
    });

    test('multiple field conflicts on the same entity', () {
      final local = {
        'title': 'Local Title',
        'subtitle': 'Local Sub',
        'year': 2020,
        'publisher': 'Local Pub',
        'updated_at': 1000,
      };
      final remote = {
        'title': 'Remote Title',
        'subtitle': 'Remote Sub',
        'year': 2021,
        'publisher': 'Local Pub', // same — no conflict
        'updated_at': 1010,
      };

      final conflicts = SyncStrategy.detectConflicts(
        local,
        remote,
        entityType: 'media_item',
        entityId: 'abc-123',
      );

      expect(conflicts.length, 3);
      final fieldNames = conflicts.map((c) => c.fieldName).toSet();
      expect(fieldNames, {'title', 'subtitle', 'year'});
    });
  });

  group('SyncStrategy.mergeWithResolutions', () {
    test('applies keepLocal resolution', () {
      final local = {'title': 'Local', 'updated_at': 1000};
      final remote = {'title': 'Remote', 'updated_at': 2000};

      final resolutions = [
        const SyncConflict(
          entityType: 'media_item',
          entityId: 'abc',
          fieldName: 'title',
          localValue: 'Local',
          remoteValue: 'Remote',
          localUpdatedAt: 1000,
          remoteUpdatedAt: 2000,
          resolution: ConflictResolution.keepLocal,
        ),
      ];

      final merged =
          SyncStrategy.mergeWithResolutions(local, remote, resolutions);

      expect(merged['title'], 'Local');
    });

    test('applies keepRemote resolution', () {
      final local = {'title': 'Local', 'updated_at': 2000};
      final remote = {'title': 'Remote', 'updated_at': 1000};

      final resolutions = [
        const SyncConflict(
          entityType: 'media_item',
          entityId: 'abc',
          fieldName: 'title',
          localValue: 'Local',
          remoteValue: 'Remote',
          localUpdatedAt: 2000,
          remoteUpdatedAt: 1000,
          resolution: ConflictResolution.keepRemote,
        ),
      ];

      final merged =
          SyncStrategy.mergeWithResolutions(local, remote, resolutions);

      expect(merged['title'], 'Remote');
    });

    test('applies keepBoth resolution for strings', () {
      final local = {'title': 'Local', 'updated_at': 1000};
      final remote = {'title': 'Remote', 'updated_at': 1010};

      final resolutions = [
        const SyncConflict(
          entityType: 'media_item',
          entityId: 'abc',
          fieldName: 'title',
          localValue: 'Local',
          remoteValue: 'Remote',
          localUpdatedAt: 1000,
          remoteUpdatedAt: 1010,
          resolution: ConflictResolution.keepBoth,
        ),
      ];

      final merged =
          SyncStrategy.mergeWithResolutions(local, remote, resolutions);

      expect(merged['title'], 'Local | Remote');
    });

    test('applies keepBoth resolution for non-strings defaults to local', () {
      final local = {'year': 2020, 'updated_at': 1000};
      final remote = {'year': 2021, 'updated_at': 1010};

      final resolutions = [
        const SyncConflict(
          entityType: 'media_item',
          entityId: 'abc',
          fieldName: 'year',
          localValue: 2020,
          remoteValue: 2021,
          localUpdatedAt: 1000,
          remoteUpdatedAt: 1010,
          resolution: ConflictResolution.keepBoth,
        ),
      ];

      final merged =
          SyncStrategy.mergeWithResolutions(local, remote, resolutions);

      expect(merged['year'], 2020);
    });
  });
}
