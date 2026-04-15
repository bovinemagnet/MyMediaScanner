import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/services/taste_profile_builder.dart';

MediaItem _item({
  required String id,
  double? rating,
  List<String> genres = const [],
  String? seriesId,
  Map<String, dynamic> extra = const {},
}) =>
    MediaItem(
      id: id,
      barcode: id,
      barcodeType: 'EAN13',
      mediaType: MediaType.film,
      title: id,
      genres: genres,
      userRating: rating,
      seriesId: seriesId,
      extraMetadata: extra,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

void main() {
  const builder = TasteProfileBuilder();

  test('empty list yields empty profile', () {
    expect(builder.build([]).averageRating, isNull);
    expect(builder.build([]).lovedGenres, isEmpty);
  });

  test('only items rated >= 4.0 contribute to lovedGenres', () {
    final profile = builder.build([
      _item(id: '1', rating: 5.0, genres: ['Sci-Fi']),
      _item(id: '2', rating: 3.0, genres: ['Romance']),
      _item(id: '3', rating: 4.5, genres: ['Sci-Fi', 'Action']),
    ]);
    expect(profile.lovedGenres.keys, unorderedEquals(['Sci-Fi', 'Action']));
    // 2 loved items, Sci-Fi appears in both → 2/2 = 1.0
    expect(profile.lovedGenres['Sci-Fi'], 1.0);
    expect(profile.lovedGenres['Action'], 0.5);
  });

  test('averageRating considers every rated item', () {
    final profile = builder.build([
      _item(id: '1', rating: 5.0),
      _item(id: '2', rating: 3.0),
      _item(id: '3', rating: 4.0),
    ]);
    expect(profile.averageRating, closeTo(4.0, 0.001));
    expect(profile.totalRatedItems, 3);
  });

  test('series with >= 2 owned items become collectedSeriesIds', () {
    final profile = builder.build([
      _item(id: '1', seriesId: 'mcu'),
      _item(id: '2', seriesId: 'mcu'),
      _item(id: '3', seriesId: 'singleton'),
    ]);
    expect(profile.collectedSeriesIds, {'mcu'});
  });

  test('tag counts from extraMetadata only count loved items', () {
    final profile = builder.build([
      _item(
        id: '1',
        rating: 5.0,
        extra: {
          'tags': ['noir', 'gritty']
        },
      ),
      _item(
        id: '2',
        rating: 2.0,
        extra: {
          'tags': ['romcom']
        },
      ),
    ]);
    expect(profile.lovedTags.keys, unorderedEquals(['noir', 'gritty']));
  });
}
