import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/marketplace_price.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_current_value_source.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/lookup_current_value_usecase.dart';

class _MockSource extends Mock implements ICurrentValueSource {}

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

  late _MockSource source;
  late _MockRepo repo;
  late LookupCurrentValueUseCase useCase;

  setUp(() {
    source = _MockSource();
    repo = _MockRepo();
    useCase = LookupCurrentValueUseCase(source: source, repository: repo);
    when(() => source.supportsDiscogs).thenReturn(true);
    when(() => source.supportsPriceCharting).thenReturn(false);
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

  test('returns null when Discogs is not configured', () async {
    when(() => source.supportsDiscogs).thenReturn(false);
    final result =
        await useCase.execute(musicItem(id: '1', extraMetadata: const {
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

  test('fetches price and persists currentValue + currentValueAsOf on success',
      () async {
    when(() => source.lookupDiscogsPrice(
          releaseId: 12345,
          fetchedAt: any(named: 'fetchedAt'),
        )).thenAnswer((invocation) async => MarketplacePrice(
          value: 19.99,
          currency: 'USD',
          numForSale: 4,
          source: 'discogs_marketplace',
          fetchedAt:
              invocation.namedArguments[const Symbol('fetchedAt')] as int,
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
      'records currentValueAsOf with null currentValue when lookup returns no '
      'usable price', () async {
    when(() => source.lookupDiscogsPrice(
          releaseId: 99,
          fetchedAt: any(named: 'fetchedAt'),
        )).thenAnswer((_) async => null);

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

  test('returns null and does not persist on lookup error', () async {
    when(() => source.lookupDiscogsPrice(
          releaseId: 12345,
          fetchedAt: any(named: 'fetchedAt'),
        )).thenThrow(Exception('network down'));

    final item = musicItem(id: '1', extraMetadata: const {
      'discogs_release_id': 12345,
    });

    final price = await useCase.execute(item);

    expect(price, isNull);
    verifyNever(() => repo.update(any()));
  });

  test('parses string release id from extraMetadata', () async {
    when(() => source.lookupDiscogsPrice(
          releaseId: 777,
          fetchedAt: any(named: 'fetchedAt'),
        )).thenAnswer((invocation) async => MarketplacePrice(
          value: 2.0,
          currency: 'GBP',
          numForSale: 1,
          source: 'discogs_marketplace',
          fetchedAt:
              invocation.namedArguments[const Symbol('fetchedAt')] as int,
        ));

    final item = musicItem(id: '3', extraMetadata: const {
      'discogs_release_id': '777',
    });

    final price = await useCase.execute(item);

    expect(price, isNotNull);
    expect(price!.value, 2.0);
  });

  test('routes game items to PriceCharting', () async {
    when(() => source.supportsPriceCharting).thenReturn(true);
    when(() => source.lookupGamePrice(
          productId: any(named: 'productId'),
          barcode: any(named: 'barcode'),
          fetchedAt: any(named: 'fetchedAt'),
        )).thenAnswer((invocation) async => MarketplacePrice(
          value: 30.0,
          currency: 'USD',
          numForSale: 0,
          source: 'pricecharting',
          fetchedAt:
              invocation.namedArguments[const Symbol('fetchedAt')] as int,
        ));

    const item = MediaItem(
      id: 'g1',
      barcode: '045496830434',
      barcodeType: 'UPC-A',
      mediaType: MediaType.game,
      title: 'Game',
      extraMetadata: {'pricecharting_id': 'PC-1'},
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

    final price = await useCase.execute(item);

    expect(price, isNotNull);
    expect(price!.value, 30.0);
    verify(() => source.lookupGamePrice(
          productId: 'PC-1',
          barcode: '045496830434',
          fetchedAt: any(named: 'fetchedAt'),
        )).called(1);
  });
}
