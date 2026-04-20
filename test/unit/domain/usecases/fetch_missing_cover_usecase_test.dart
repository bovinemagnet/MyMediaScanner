import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/fetch_missing_cover_usecase.dart';

class _MockMetadata extends Mock implements IMetadataRepository {}

class _MockItems extends Mock implements IMediaItemRepository {}

MediaItem _item({
  String id = 'item-1',
  String barcode = '1234567890123',
  String title = 'The Matrix',
  String? coverUrl,
}) =>
    MediaItem(
      id: id,
      barcode: barcode,
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: title,
      coverUrl: coverUrl,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

MetadataResult _metadata({String? coverUrl}) => MetadataResult(
      barcode: '1234567890123',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: 'The Matrix',
      coverUrl: coverUrl,
    );

void main() {
  late _MockMetadata metadata;
  late _MockItems items;
  late FetchMissingCoverUseCase usecase;

  setUpAll(() {
    registerFallbackValue(_item());
  });

  setUp(() {
    metadata = _MockMetadata();
    items = _MockItems();
    usecase = FetchMissingCoverUseCase(
      metadataRepository: metadata,
      mediaItemRepository: items,
      now: () => DateTime.fromMillisecondsSinceEpoch(999),
    );
    when(() => items.update(any())).thenAnswer((_) async {});
  });

  group('FetchMissingCoverUseCase', () {
    test('returns alreadyHasCover without touching the network', () async {
      final item = _item(coverUrl: 'https://example.com/cover.jpg');
      final outcome = await usecase.execute(item);
      expect(outcome, FetchCoverOutcome.alreadyHasCover);
      verifyZeroInteractions(metadata);
      verifyNever(() => items.update(any()));
    });

    test('updates item when barcode lookup returns a cover', () async {
      final item = _item();
      when(() => metadata.lookupBarcode(any(), typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => ScanResult.single(
                metadata: _metadata(coverUrl: 'https://tmdb/a.jpg'),
                isDuplicate: false,
              ));

      final outcome = await usecase.execute(item);

      expect(outcome, FetchCoverOutcome.updated);
      final captured = verify(() => items.update(captureAny())).captured.single
          as MediaItem;
      expect(captured.coverUrl, 'https://tmdb/a.jpg');
      expect(captured.updatedAt, 999);
      verifyNever(() =>
          metadata.searchByTitle(any(), any(), any(), typeHint: any(named: 'typeHint')));
    });

    test('falls back to title search when barcode has no cover', () async {
      final item = _item();
      when(() => metadata.lookupBarcode(any(), typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => ScanResult.single(
                metadata: _metadata(), // no coverUrl
                isDuplicate: false,
              ));
      when(() => metadata.searchByTitle(any(), any(), any(),
              typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => ScanResult.single(
                metadata: _metadata(coverUrl: 'https://fanart/b.jpg'),
                isDuplicate: false,
              ));

      final outcome = await usecase.execute(item);

      expect(outcome, FetchCoverOutcome.updated);
      final captured = verify(() => items.update(captureAny())).captured.single
          as MediaItem;
      expect(captured.coverUrl, 'https://fanart/b.jpg');
    });

    test('skips barcode lookup when barcode is empty', () async {
      final item = _item(barcode: '');
      when(() => metadata.searchByTitle(any(), any(), any(),
              typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => ScanResult.single(
                metadata: _metadata(coverUrl: 'https://ol/c.jpg'),
                isDuplicate: false,
              ));

      final outcome = await usecase.execute(item);

      expect(outcome, FetchCoverOutcome.updated);
      verifyNever(() => metadata.lookupBarcode(any(),
          typeHint: any(named: 'typeHint')));
    });

    test('returns notFound when every path misses', () async {
      final item = _item();
      when(() => metadata.lookupBarcode(any(), typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => const ScanResult.notFound(
                barcode: '1234567890123',
                barcodeType: 'ean13',
              ));
      when(() => metadata.searchByTitle(any(), any(), any(),
              typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => const ScanResult.notFound(
                barcode: '1234567890123',
                barcodeType: 'ean13',
              ));

      final outcome = await usecase.execute(item);

      expect(outcome, FetchCoverOutcome.notFound);
      verifyNever(() => items.update(any()));
    });

    test('returns notFound when metadata throws on both paths', () async {
      final item = _item();
      when(() => metadata.lookupBarcode(any(), typeHint: any(named: 'typeHint')))
          .thenThrow(Exception('network'));
      when(() => metadata.searchByTitle(any(), any(), any(),
              typeHint: any(named: 'typeHint')))
          .thenThrow(Exception('network'));

      final outcome = await usecase.execute(item);

      expect(outcome, FetchCoverOutcome.notFound);
      verifyNever(() => items.update(any()));
    });

    test('treats empty coverUrl as missing (runs lookup)', () async {
      final item = _item(coverUrl: '');
      when(() => metadata.lookupBarcode(any(), typeHint: any(named: 'typeHint')))
          .thenAnswer((_) async => ScanResult.single(
                metadata: _metadata(coverUrl: 'https://tmdb/a.jpg'),
                isDuplicate: false,
              ));

      final outcome = await usecase.execute(item);

      expect(outcome, FetchCoverOutcome.updated);
    });
  });
}
