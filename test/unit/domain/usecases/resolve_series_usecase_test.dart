import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_series_repository.dart';
import 'package:mymediascanner/domain/usecases/resolve_series_usecase.dart';

class _MockSeries extends Mock implements ISeriesRepository {}

class _MockMedia extends Mock implements IMediaItemRepository {}

void main() {
  late ResolveSeriesUseCase usecase;
  late _MockSeries series;
  late _MockMedia media;

  const item = MediaItem(
    id: 'item-1',
    barcode: '123',
    barcodeType: 'EAN13',
    mediaType: MediaType.film,
    title: 'Iron Man',
    dateAdded: 0,
    dateScanned: 0,
    updatedAt: 0,
  );

  setUpAll(() {
    registerFallbackValue(item);
    registerFallbackValue(MediaType.unknown);
  });

  setUp(() {
    series = _MockSeries();
    media = _MockMedia();
    usecase = ResolveSeriesUseCase(
      seriesRepository: series,
      mediaItemRepository: media,
    );
    when(() => media.update(any())).thenAnswer((_) async {});
  });

  test('no-op when metadata has no seriesExternalId', () async {
    const meta = MetadataResult(
      barcode: '123',
      barcodeType: 'EAN13',
      title: 'Iron Man',
    );

    final result = await usecase.execute(item, meta);

    expect(result, item);
    verifyNever(() => series.upsert(
          externalId: any(named: 'externalId'),
          name: any(named: 'name'),
          mediaType: any(named: 'mediaType'),
          source: any(named: 'source'),
        ));
    verifyNever(() => media.update(any()));
  });

  test('upserts series and updates item when metadata has series ref',
      () async {
    when(() => series.upsert(
          externalId: 'tmdb:86311',
          name: 'The Avengers Collection',
          mediaType: MediaType.film,
          source: 'tmdb',
        )).thenAnswer((_) async => 'series-id-1');

    const meta = MetadataResult(
      barcode: '123',
      barcodeType: 'EAN13',
      title: 'Iron Man',
      seriesExternalId: 'tmdb:86311',
      seriesName: 'The Avengers Collection',
      seriesPosition: 1,
    );

    final result = await usecase.execute(item, meta);

    expect(result.seriesId, 'series-id-1');
    expect(result.seriesPosition, 1);
    final captured = verify(() => media.update(captureAny())).captured.single
        as MediaItem;
    expect(captured.seriesId, 'series-id-1');
    expect(captured.seriesPosition, 1);
  });

  test('derives source from external id prefix', () async {
    when(() => series.upsert(
          externalId: 'mb:rg-42',
          name: 'OK Computer',
          mediaType: MediaType.music,
          source: 'mb',
        )).thenAnswer((_) async => 's2');

    const musicItem = MediaItem(
      id: 'm',
      barcode: '1',
      barcodeType: 'EAN13',
      mediaType: MediaType.music,
      title: 'OK Computer',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );
    const meta = MetadataResult(
      barcode: '1',
      barcodeType: 'EAN13',
      title: 'OK Computer',
      seriesExternalId: 'mb:rg-42',
      seriesName: 'OK Computer',
    );

    await usecase.execute(musicItem, meta);

    verify(() => series.upsert(
          externalId: 'mb:rg-42',
          name: 'OK Computer',
          mediaType: MediaType.music,
          source: 'mb',
        )).called(1);
  });
}
