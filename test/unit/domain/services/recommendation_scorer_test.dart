import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/taste_profile.dart';
import 'package:mymediascanner/domain/services/recommendation_scorer.dart';

MediaItem _item({
  required String id,
  List<String> genres = const [],
  String? seriesId,
  double? rating,
  int dateAdded = 0,
  Map<String, dynamic> extra = const {},
}) =>
    MediaItem(
      id: id,
      barcode: id,
      barcodeType: 'EAN13',
      mediaType: MediaType.film,
      title: id,
      genres: genres,
      seriesId: seriesId,
      userRating: rating,
      extraMetadata: extra,
      dateAdded: dateAdded,
      dateScanned: dateAdded,
      updatedAt: dateAdded,
    );

void main() {
  // Fixed clock anchored well after any test dateAdded values.
  final fixedNow = DateTime.utc(2026, 4, 15);
  final scorer = RecommendationScorer(clock: () => fixedNow);

  test('zero score with empty profile and empty item', () {
    final result = scorer.score(_item(id: '1'), TasteProfile.empty);
    expect(result.score, 0);
    expect(result.reasons, isEmpty);
  });

  test('genre overlap contributes a reason and weight', () {
    const profile = TasteProfile(
      lovedGenres: {'Sci-Fi': 1.0},
      lovedTags: {},
      collectedSeriesIds: {},
      averageRating: 4.5,
      totalRatedItems: 4,
    );
    final item = _item(id: '1', genres: ['Sci-Fi']);

    final result = scorer.score(item, profile);

    expect(result.reasons.first.label, contains('Sci-Fi'));
    expect(result.score, closeTo(0.45, 0.001));
  });

  test('series collecting adds full series weight', () {
    const profile = TasteProfile(
      lovedGenres: {},
      lovedTags: {},
      collectedSeriesIds: {'mcu'},
      averageRating: null,
      totalRatedItems: 0,
    );
    final item = _item(id: '1', seriesId: 'mcu');

    final result = scorer.score(item, profile);

    expect(result.score, closeTo(0.20, 0.001));
    expect(result.reasons.single.label, contains('series you collect'));
  });

  test('recency decays linearly across the 90-day window', () {
    const profile = TasteProfile.empty;
    final fortyFiveDaysAgo =
        fixedNow.subtract(const Duration(days: 45)).millisecondsSinceEpoch;
    final item = _item(id: '1', dateAdded: fortyFiveDaysAgo);

    final result = scorer.score(item, profile);
    // Half-window → roughly half of 0.10 weight.
    expect(result.score, closeTo(0.05, 0.005));
  });

  test('items older than the window get no recency boost', () {
    const profile = TasteProfile.empty;
    final hundredDaysAgo =
        fixedNow.subtract(const Duration(days: 100)).millisecondsSinceEpoch;
    final item = _item(id: '1', dateAdded: hundredDaysAgo);
    expect(scorer.score(item, profile).score, 0);
  });

  test('user rating contributes proportionally', () {
    const profile = TasteProfile.empty;
    final item = _item(id: '1', rating: 4.0);
    final result = scorer.score(item, profile);
    expect(result.score, closeTo(0.04, 0.001));
    expect(result.reasons.single.label, contains('4.0'));
  });

  test('total score caps at 1.0 even with all signals firing', () {
    const profile = TasteProfile(
      lovedGenres: {'A': 1.0, 'B': 1.0},
      lovedTags: {'t': 1.0},
      collectedSeriesIds: {'s'},
      averageRating: 5,
      totalRatedItems: 10,
    );
    final item = _item(
      id: '1',
      genres: ['A', 'B'],
      seriesId: 's',
      rating: 5.0,
      dateAdded: fixedNow.millisecondsSinceEpoch,
      extra: const {
        'tags': ['t']
      },
    );
    final result = scorer.score(item, profile);
    expect(result.score, lessThanOrEqualTo(1.0));
    expect(result.reasons.length, greaterThanOrEqualTo(4));
  });
}
