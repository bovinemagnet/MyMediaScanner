import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';

void main() {
  group('SyncConflict', () {
    test('creates with required fields', () {
      const conflict = SyncConflict(
        entityType: 'media_item',
        entityId: 'abc-123',
        fieldName: 'title',
        localValue: 'Local Title',
        remoteValue: 'Remote Title',
        localUpdatedAt: 1000,
        remoteUpdatedAt: 2000,
      );

      expect(conflict.entityType, 'media_item');
      expect(conflict.entityId, 'abc-123');
      expect(conflict.fieldName, 'title');
      expect(conflict.localValue, 'Local Title');
      expect(conflict.remoteValue, 'Remote Title');
      expect(conflict.localUpdatedAt, 1000);
      expect(conflict.remoteUpdatedAt, 2000);
      expect(conflict.resolution, ConflictResolution.keepLocal);
    });

    test('defaults resolution to keepLocal', () {
      const conflict = SyncConflict(
        entityType: 'media_item',
        entityId: 'abc-123',
        fieldName: 'title',
        localValue: 'A',
        remoteValue: 'B',
        localUpdatedAt: 1000,
        remoteUpdatedAt: 2000,
      );

      expect(conflict.resolution, ConflictResolution.keepLocal);
    });

    test('copyWith changes resolution', () {
      const conflict = SyncConflict(
        entityType: 'media_item',
        entityId: 'abc-123',
        fieldName: 'title',
        localValue: 'A',
        remoteValue: 'B',
        localUpdatedAt: 1000,
        remoteUpdatedAt: 2000,
      );

      final resolved = conflict.copyWith(
        resolution: ConflictResolution.keepRemote,
      );

      expect(resolved.resolution, ConflictResolution.keepRemote);
      expect(resolved.fieldName, 'title');
    });

    test('serialises to and from JSON', () {
      const conflict = SyncConflict(
        entityType: 'media_item',
        entityId: 'abc-123',
        fieldName: 'year',
        localValue: 2020,
        remoteValue: 2021,
        localUpdatedAt: 1000,
        remoteUpdatedAt: 2000,
        resolution: ConflictResolution.keepRemote,
      );

      final json = conflict.toJson();
      final restored = SyncConflict.fromJson(json);

      expect(restored.entityType, conflict.entityType);
      expect(restored.entityId, conflict.entityId);
      expect(restored.fieldName, conflict.fieldName);
      expect(restored.localValue, conflict.localValue);
      expect(restored.remoteValue, conflict.remoteValue);
      expect(restored.resolution, ConflictResolution.keepRemote);
    });

    test('equality works correctly', () {
      const a = SyncConflict(
        entityType: 'media_item',
        entityId: 'abc-123',
        fieldName: 'title',
        localValue: 'A',
        remoteValue: 'B',
        localUpdatedAt: 1000,
        remoteUpdatedAt: 2000,
      );

      const b = SyncConflict(
        entityType: 'media_item',
        entityId: 'abc-123',
        fieldName: 'title',
        localValue: 'A',
        remoteValue: 'B',
        localUpdatedAt: 1000,
        remoteUpdatedAt: 2000,
      );

      expect(a, equals(b));
    });
  });

  group('ConflictResolution', () {
    test('has three values', () {
      expect(ConflictResolution.values.length, 3);
      expect(ConflictResolution.values,
          contains(ConflictResolution.keepLocal));
      expect(ConflictResolution.values,
          contains(ConflictResolution.keepRemote));
      expect(ConflictResolution.values,
          contains(ConflictResolution.keepBoth));
    });
  });
}
