import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';

void main() {
  group('SyncStrategy', () {
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
}
