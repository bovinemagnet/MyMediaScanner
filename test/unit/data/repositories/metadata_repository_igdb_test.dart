import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_api.dart';
import 'package:mymediascanner/data/remote/api/igdb/models/igdb_game_dto.dart';
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';
import 'package:mymediascanner/data/remote/api/upc/upcitemdb_api.dart';
import 'package:mymediascanner/data/repositories/metadata_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

class _MockCacheDao extends Mock implements BarcodeCacheDao {}

class _MockIgdbApi extends Mock implements IgdbApi {}

class _MockUpcApi extends Mock implements UpcitemdbApi {}

IgdbGameDto _game({
  int id = 1,
  String name = 'Test Game',
  String? platform = 'PC',
  String? publisher,
  int? year,
}) {
  return IgdbGameDto(
    id: id,
    name: name,
    platforms: platform != null
        ? [IgdbPlatformDto(name: platform)]
        : const [],
    involvedCompanies: publisher != null
        ? [
            IgdbInvolvedCompanyDto(
              company: IgdbCompanyDto(name: publisher),
              publisher: true,
            ),
          ]
        : const [],
    firstReleaseDate: year != null
        ? DateTime.utc(year).millisecondsSinceEpoch ~/ 1000
        : null,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      BarcodeCacheTableCompanion(
        barcode: const Value(''),
        mediaTypeHint: const Value(null),
        responseJson: const Value('{}'),
        sourceApi: const Value(''),
        cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  });

  late _MockCacheDao cache;
  late _MockIgdbApi igdb;
  late _MockUpcApi upc;

  setUp(() {
    cache = _MockCacheDao();
    igdb = _MockIgdbApi();
    upc = _MockUpcApi();
    when(() => cache.getByBarcode(any())).thenAnswer((_) async => null);
    when(() => cache.upsert(any())).thenAnswer((_) async {});
  });

  group('searchByTitle with typeHint: game', () {
    test('returns a single ScanResult when IGDB returns one game', () async {
      final repo = MetadataRepositoryImpl(cacheDao: cache, igdbApi: igdb);
      when(() => igdb.searchByTitle('Elden Ring')).thenAnswer(
        (_) async => [
          _game(
            id: 119133,
            name: 'Elden Ring',
            platform: 'PlayStation 5',
            publisher: 'Bandai Namco',
            year: 2022,
          ),
        ],
      );

      final result = await repo.searchByTitle(
        'Elden Ring',
        '0722674120432',
        'ean13',
        typeHint: MediaType.game,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Elden Ring');
      expect(single.metadata.publisher, 'Bandai Namco');
      expect(single.metadata.mediaType, MediaType.game);
    });

    test('returns a MultiMatchScanResult when IGDB returns 2+ games',
        () async {
      final repo = MetadataRepositoryImpl(cacheDao: cache, igdbApi: igdb);
      when(() => igdb.searchByTitle('Zelda')).thenAnswer(
        (_) async => [
          _game(id: 1, name: 'The Legend of Zelda: BOTW'),
          _game(id: 2, name: 'The Legend of Zelda: TOTK'),
          _game(id: 3, name: 'The Legend of Zelda: Skyward Sword'),
        ],
      );

      final result = await repo.searchByTitle(
        'Zelda',
        '0000000000000',
        'ean13',
        typeHint: MediaType.game,
      );

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, greaterThanOrEqualTo(3));
      expect(multi.candidates.first.sourceApi, 'igdb');
    });

    test('returns notFound when IGDB is not configured', () async {
      final repo = MetadataRepositoryImpl(cacheDao: cache);

      final result = await repo.searchByTitle(
        'anything',
        '0000000000000',
        'ean13',
        typeHint: MediaType.game,
      );

      expect(result, isA<NotFoundScanResult>());
    });
  });

  group('lookupBarcode with typeHint: game', () {
    const barcode = '0711719541592';

    test('UPCitemdb title → IGDB enrichment on single match', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: cache,
        upcitemdbApi: upc,
        igdbApi: igdb,
      );
      when(() => upc.lookup(barcode)).thenAnswer(
        (_) async => const UpcSearchResponseDto(
          code: 'OK',
          total: 1,
          items: [
            UpcItemDto(
              ean: barcode,
              title: 'Horizon Zero Dawn',
              category: 'Toys & Hobbies > Video Games',
            ),
          ],
        ),
      );
      when(() => igdb.searchByTitle('Horizon Zero Dawn')).thenAnswer(
        (_) async => [
          _game(
            id: 19560,
            name: 'Horizon Zero Dawn',
            platform: 'PlayStation 4',
            publisher: 'Sony Interactive',
            year: 2017,
          ),
        ],
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.game,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Horizon Zero Dawn');
      expect(single.metadata.publisher, 'Sony Interactive');
      expect(single.metadata.sourceApis, ['igdb']);
    });

    test('falls back to UPCitemdb result when IGDB finds nothing', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: cache,
        upcitemdbApi: upc,
        igdbApi: igdb,
      );
      when(() => upc.lookup(barcode)).thenAnswer(
        (_) async => const UpcSearchResponseDto(
          code: 'OK',
          total: 1,
          items: [
            UpcItemDto(
              ean: barcode,
              title: 'Obscure Game',
              category: 'Toys & Hobbies > Video Games',
            ),
          ],
        ),
      );
      when(() => igdb.searchByTitle('Obscure Game'))
          .thenAnswer((_) async => const []);

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.game,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Obscure Game');
    });

    test('falls back to UPCitemdb result when IGDB is not configured',
        () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: cache,
        upcitemdbApi: upc,
      );
      when(() => upc.lookup(barcode)).thenAnswer(
        (_) async => const UpcSearchResponseDto(
          code: 'OK',
          total: 1,
          items: [
            UpcItemDto(
              ean: barcode,
              title: 'Obscure Game',
              category: 'Toys & Hobbies > Video Games',
            ),
          ],
        ),
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.game,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Obscure Game');
    });
  });
}
