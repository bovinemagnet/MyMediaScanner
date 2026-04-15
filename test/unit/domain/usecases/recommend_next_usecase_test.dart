import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/services/recommendation_scorer.dart';
import 'package:mymediascanner/domain/usecases/recommend_next_usecase.dart';

MediaItem _item({
  required String id,
  List<String> genres = const [],
  double? rating,
  bool consumed = false,
  int? startedAt,
  int? completedAt,
  OwnershipStatus status = OwnershipStatus.owned,
  bool deleted = false,
  int dateAdded = 0,
}) =>
    MediaItem(
      id: id,
      barcode: id,
      barcodeType: 'EAN13',
      mediaType: MediaType.film,
      title: id,
      genres: genres,
      userRating: rating,
      consumed: consumed,
      startedAt: startedAt,
      completedAt: completedAt,
      ownershipStatus: status,
      deleted: deleted,
      dateAdded: dateAdded,
      dateScanned: dateAdded,
      updatedAt: dateAdded,
    );

void main() {
  final fixedNow = DateTime.utc(2026, 4, 15);
  final usecase = RecommendNextUseCase(
    scorer: RecommendationScorer(clock: () => fixedNow),
  );

  test('returns empty list when collection is empty', () {
    expect(usecase.rank([]), isEmpty);
  });

  test('excludes consumed items', () {
    final result = usecase.rank([
      _item(id: 'consumed', rating: 5.0, genres: ['Sci-Fi'], consumed: true),
      _item(id: 'unread', rating: 5.0, genres: ['Sci-Fi']),
    ]);
    expect(result.map((r) => r.item.id), ['unread']);
  });

  test('excludes in-progress items', () {
    final result = usecase.rank([
      _item(
        id: 'in-progress',
        rating: 5.0,
        genres: ['Sci-Fi'],
        startedAt: 1,
      ),
      _item(id: 'fresh', rating: 5.0, genres: ['Sci-Fi']),
    ]);
    expect(result.map((r) => r.item.id), ['fresh']);
  });

  test('excludes wishlist items even if rated highly', () {
    final result = usecase.rank([
      _item(
          id: 'wishlist',
          rating: 5.0,
          genres: ['Sci-Fi'],
          status: OwnershipStatus.wishlist),
      _item(id: 'owned', rating: 5.0, genres: ['Sci-Fi']),
    ]);
    expect(result.map((r) => r.item.id), ['owned']);
  });

  test('respects limit', () {
    final items = [
      for (var i = 0; i < 10; i++)
        _item(id: '$i', rating: 5.0, genres: const ['Sci-Fi']),
    ];
    expect(usecase.rank(items, limit: 3), hasLength(3));
  });

  test('orders by descending score', () {
    // Profile loves Sci-Fi (built from items rated >= 4 with that genre).
    final items = [
      _item(id: 'high', rating: 4.5, genres: const ['Sci-Fi']),
      _item(id: 'mid', rating: 4.0, genres: const ['Sci-Fi', 'Romance']),
      _item(id: 'low', genres: const ['Romance']),
    ];
    final result = usecase.rank(items, limit: 3);
    expect(result.first.item.id, 'high');
    expect(result.first.score, greaterThanOrEqualTo(result.last.score));
  });
}
