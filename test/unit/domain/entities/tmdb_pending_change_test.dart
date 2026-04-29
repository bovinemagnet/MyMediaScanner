import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';

void main() {
  group('derivePendingActions', () {
    test('rating only', () {
      final actions = derivePendingActions(
        watchlist: false,
        favorite: false,
        localRatingSnapshot: 4.5,
      );
      expect(actions, [const TmdbPendingAction.rating(4.5)]);
    });

    test('watchlist + favourite (no rating)', () {
      final actions = derivePendingActions(
        watchlist: true,
        favorite: true,
        localRatingSnapshot: null,
      );
      expect(actions, [
        const TmdbPendingAction.watchlist(),
        const TmdbPendingAction.favourite(),
      ]);
    });

    test('all three', () {
      final actions = derivePendingActions(
        watchlist: true,
        favorite: true,
        localRatingSnapshot: 3.0,
      );
      expect(actions, [
        const TmdbPendingAction.rating(3.0),
        const TmdbPendingAction.watchlist(),
        const TmdbPendingAction.favourite(),
      ]);
    });

    test('all-default returns empty list', () {
      final actions = derivePendingActions(
        watchlist: false,
        favorite: false,
        localRatingSnapshot: null,
      );
      expect(actions, isEmpty);
    });
  });

  group('TmdbPendingChange.hasFailed', () {
    test('null lastError → false', () {
      const c = TmdbPendingChange(
        tmdbId: 1,
        mediaType: 'movie',
        title: 'Fight Club',
        actions: [],
        lastPushedAt: null,
        lastError: null,
      );
      expect(c.hasFailed, isFalse);
    });

    test('non-null lastError → true', () {
      const c = TmdbPendingChange(
        tmdbId: 1,
        mediaType: 'movie',
        title: 'Fight Club',
        actions: [],
        lastPushedAt: null,
        lastError: 'connection failed',
      );
      expect(c.hasFailed, isTrue);
    });
  });
}
