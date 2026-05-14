import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_marketplace_stats_dto.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/lookup_current_value_usecase.dart';

class _MockDiscogsApi extends Mock implements DiscogsApi {}

class _MockRepo extends Mock implements IMediaItemRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const MediaItem(
      id: 'fallback',
      barcode: 'b',
      barcodeType: 'EAN-13',
      mediaType: MediaType.music,
      title: 't',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    ));
  });

  late _MockDiscogsApi api;
  late _MockRepo repo;
  late LookupCurrentValueUseCase useCase;

  setUp(() {
    api = _MockDiscogsApi();
    repo = _MockRepo();
    useCase = LookupCurrentValueUseCase(discogsApi: api, repository: repo);
    when(() => repo.update(any())).thenAnswer((_) async {});
  });

  MediaItem musicItem({
    required String id,
    Map<String, dynamic>? extraMetadata,
  }) {
    return MediaItem(
      id: id,
      barcode: 'b$id',
      barcodeType: 'EAN-13',
      mediaType: MediaType.music,
      title: 'Album $id',
      extraMetadata: extraMetadata ?? const {},
      dateAdded: 1700000000,
      dateScanned: 1700000000,
      updatedAt: 1700000000,
    );
  }

  test('returns null when discogsApi is null', () async {
    final fallback = LookupCurrentValueUseCase(
      discogsApi: null,
      repository: repo,
    );
    final result =
        await fallback.execute(musicItem(id: '1', extraMetadata: const {
      'discogs_release_id': 12345,
    }));

    expect(result, isNull);
    verifyNever(() => repo.update(any()));
  });

  test('returns null when item has no discogs_release_id', () async {
    final result = await useCase.execute(musicItem(id: '1'));

    expect(result, isNull);
    verifyNever(() => repo.update(any()));
  });

  test('fetches stats and persists currentValue + currentValueAsOf on success',
      () async {
    when(() => api.getMarketplaceStats(12345,
            currencyAbbreviation: any(named: 'currencyAbbreviation')))
        .thenAnswer((_) async => const DiscogsMarketplaceStatsDto(
              lowestPrice: DiscogsMoneyDto(value: 19.99, currency: 'USD'),
              numForSale: 4,
              blockedFromSale: false,
            ));

    final item = musicItem(id: '1', extraMetadata: const {
      'discogs_release_id': 12345,
    });

    final price = await useCase.execute(item);

    expect(price, isNotNull);
    expect(price!.value, 19.99);
    expect(price.currency, 'USD');

    final captured = verify(() => repo.update(captureAny())).captured;
    expect(captured, hasLength(1));
    final saved = captured.first as MediaItem;
    expect(saved.id, '1');
    expect(saved.currentValue, 19.99);
    expect(saved.currentValueAsOf, isNotNull);
  });

  test(
      'records currentValueAsOf with null currentValue when stats return no '
      'usable price', () async {
    when(() => api.getMarketplaceStats(99,
            currencyAbbreviation: any(named: 'currencyAbbreviation')))
        .thenAnswer((_) async => const DiscogsMarketplaceStatsDto(
              lowestPrice: null,
              numForSale: 0,
              blockedFromSale: false,
            ));

    final item = musicItem(id: '2', extraMetadata: const {
      'discogs_release_id': 99,
    });

    final price = await useCase.execute(item);

    expect(price, isNull);
    final saved = verify(() => repo.update(captureAny())).captured.single
        as MediaItem;
    expect(saved.currentValue, isNull);
    expect(saved.currentValueAsOf, isNotNull);
  });

  test('returns null and does not persist on API error', () async {
    when(() => api.getMarketplaceStats(12345,
            currencyAbbreviation: any(named: 'currencyAbbreviation')))
        .thenThrow(Exception('network down'));

    final item = musicItem(id: '1', extraMetadata: const {
      'discogs_release_id': 12345,
    });

    final price = await useCase.execute(item);

    expect(price, isNull);
    verifyNever(() => repo.update(any()));
  });

  test('parses string release id from extraMetadata', () async {
    when(() => api.getMarketplaceStats(777,
            currencyAbbreviation: any(named: 'currencyAbbreviation')))
        .thenAnswer((_) async => const DiscogsMarketplaceStatsDto(
              lowestPrice: DiscogsMoneyDto(value: 2.0, currency: 'GBP'),
              numForSale: 1,
            ));

    final item = musicItem(id: '3', extraMetadata: const {
      'discogs_release_id': '777',
    });

    final price = await useCase.execute(item);

    expect(price, isNotNull);
    expect(price!.value, 2.0);
  });
}
