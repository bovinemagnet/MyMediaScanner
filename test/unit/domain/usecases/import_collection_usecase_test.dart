import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/import_collection_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

class _MockMetadata extends Mock implements IMetadataRepository {}

class _MockMediaRepo extends Mock implements IMediaItemRepository {}

void main() {
  late ImportCollectionUseCase usecase;
  late _MockMetadata metadata;
  late _MockMediaRepo mediaRepo;
  late SaveMediaItemUseCase save;

  setUp(() {
    metadata = _MockMetadata();
    mediaRepo = _MockMediaRepo();
    save = SaveMediaItemUseCase(repository: mediaRepo);
    usecase = ImportCollectionUseCase(
      metadataRepository: metadata,
      mediaItemRepository: mediaRepo,
      saveMediaItem: save,
      lookupDelay: Duration.zero,
    );
  });

  group('parse', () {
    test('routes to GoodreadsCsvParser', () {
      const csv =
          'Book Id,Title,Author,ISBN,ISBN13\n1,"Dune","Frank Herbert",="",="9780441172719"\n';
      final rows = usecase.parse(ImportSource.goodreads, csv);
      expect(rows, hasLength(1));
      expect(rows.first.isbn, '9780441172719');
    });

    test('routes to TraktJsonParser', () {
      const json =
          '[{"movie":{"title":"Dune","year":2021,"ids":{"trakt":1,"imdb":"tt1160419"}}}]';
      final rows = usecase.parse(ImportSource.trakt, json);
      expect(rows, hasLength(1));
      expect(rows.first.imdbId, 'tt1160419');
    });
  });

  group('enrich', () {
    test('marks duplicate when barcodeExists returns true', () async {
      when(() => mediaRepo.barcodeExists('9780441172719'))
          .thenAnswer((_) async => true);

      final input = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          rawTitle: 'Dune',
          isbn: '9780441172719',
        ),
      ];

      final out = await usecase.enrich(input).toList();
      expect(out.single.status, ImportRowStatus.duplicate);
      verifyNever(() => metadata.lookupBarcode(any(), typeHint: any(named: 'typeHint')));
    });

    test('marks enriched when lookupBarcode returns single match', () async {
      when(() => mediaRepo.barcodeExists(any()))
          .thenAnswer((_) async => false);
      const meta = MetadataResult(
        barcode: '9780441172719',
        barcodeType: 'ISBN13',
        title: 'Dune',
      );
      when(() => metadata.lookupBarcode(
            '9780441172719',
            typeHint: MediaType.book,
          )).thenAnswer((_) async =>
          const ScanResult.single(metadata: meta, isDuplicate: false));

      final input = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          rawTitle: 'Dune',
          isbn: '9780441172719',
        ),
      ];

      final out = await usecase.enrich(input).toList();
      expect(out.single.status, ImportRowStatus.enriched);
      expect(out.single.enriched?.title, 'Dune');
    });

    test('falls back to title search when no direct key', () async {
      when(() => mediaRepo.barcodeExists(any()))
          .thenAnswer((_) async => false);
      const meta = MetadataResult(
        barcode: 'import:letterboxd:lx-1',
        barcodeType: 'IMPORT',
        title: 'Parasite',
      );
      when(() => metadata.searchByTitle(
            'Parasite',
            any(),
            'IMPORT',
            typeHint: MediaType.film,
          )).thenAnswer((_) async =>
          const ScanResult.single(metadata: meta, isDuplicate: false));

      final input = <ImportRow>[
        const ImportRow(
          sourceRowId: 'lx-1',
          source: ImportSource.letterboxd,
          mediaType: MediaType.film,
          rawTitle: 'Parasite',
          rawYear: 2019,
        ),
      ];

      final out = await usecase.enrich(input).toList();
      expect(out.single.status, ImportRowStatus.enriched);
    });

    test('marks notFound when search returns NotFound', () async {
      when(() => mediaRepo.barcodeExists(any()))
          .thenAnswer((_) async => false);
      when(() => metadata.searchByTitle(
            any(),
            any(),
            any(),
            typeHint: any(named: 'typeHint'),
          )).thenAnswer((_) async => const ScanResult.notFound(
            barcode: 'x',
            barcodeType: 'IMPORT',
          ));

      final input = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.letterboxd,
          mediaType: MediaType.film,
          rawTitle: 'Nothing Found Film',
        ),
      ];

      final out = await usecase.enrich(input).toList();
      expect(out.single.status, ImportRowStatus.notFound);
    });

    test('marks error when lookup throws', () async {
      when(() => mediaRepo.barcodeExists(any()))
          .thenAnswer((_) async => false);
      when(() => metadata.lookupBarcode(any(),
              typeHint: any(named: 'typeHint')))
          .thenThrow(Exception('network'));

      final input = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          rawTitle: 'Dune',
          isbn: '9780441172719',
        ),
      ];

      final out = await usecase.enrich(input).toList();
      expect(out.single.status, ImportRowStatus.error);
      expect(out.single.errorMessage, contains('network'));
    });
  });

  group('saveAccepted', () {
    setUp(() {
      registerFallbackValue(const MediaItem(
        id: 'fb',
        barcode: 'fb',
        barcodeType: 'fb',
        mediaType: MediaType.unknown,
        title: 'fb',
        dateAdded: 0,
        dateScanned: 0,
        updatedAt: 0,
      ));
      when(() => mediaRepo.save(any())).thenAnswer((_) async {});
    });

    test('skips rows with accepted=false', () async {
      const meta = MetadataResult(
        barcode: 'b',
        barcodeType: 'ISBN13',
        title: 't',
      );
      final rows = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          status: ImportRowStatus.enriched,
          enriched: meta,
          accepted: false,
        ),
      ];
      expect(await usecase.saveAccepted(rows), 0);
      verifyNever(() => mediaRepo.save(any()));
    });

    test('skips rows with no enriched metadata', () async {
      final rows = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          status: ImportRowStatus.notFound,
          accepted: true,
        ),
      ];
      expect(await usecase.saveAccepted(rows), 0);
      verifyNever(() => mediaRepo.save(any()));
    });

    test('saves accepted enriched rows and returns count', () async {
      const meta1 = MetadataResult(
        barcode: 'b1',
        barcodeType: 'ISBN13',
        title: 'A',
      );
      const meta2 = MetadataResult(
        barcode: 'b2',
        barcodeType: 'ISBN13',
        title: 'B',
      );
      final rows = <ImportRow>[
        const ImportRow(
          sourceRowId: '1',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          status: ImportRowStatus.enriched,
          enriched: meta1,
        ),
        const ImportRow(
          sourceRowId: '2',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          status: ImportRowStatus.enriched,
          enriched: meta2,
        ),
      ];
      expect(await usecase.saveAccepted(rows), 2);
      verify(() => mediaRepo.save(any())).called(2);
    });
  });
}

