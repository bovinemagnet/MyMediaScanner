import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

class MockMetadataRepository extends Mock implements IMetadataRepository {}

class ApiKeysNotifierStub extends ApiKeysNotifier {
  @override
  Future<Map<String, String?>> build() async => <String, String?>{};
}

void main() {
  late MockMediaItemRepository mockMediaItemRepo;
  late MockMetadataRepository mockMetadataRepo;

  setUp(() {
    mockMediaItemRepo = MockMediaItemRepository();
    mockMetadataRepo = MockMetadataRepository();

    registerFallbackValue(const MetadataCandidate(
      sourceApi: '',
      sourceId: '',
      title: '',
    ));
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        mediaItemRepositoryProvider.overrideWithValue(mockMediaItemRepo),
        metadataRepositoryProvider.overrideWithValue(mockMetadataRepo),
        apiKeysProvider.overrideWith(
          () => ApiKeysNotifierStub(),
        ),
      ],
    );
  }

  group('ScannerNotifier', () {
    group('onBarcodeScanned with multi-match', () {
      test('sets disambiguating state when not in batch mode', () async {
        const barcode = '5099902894225';
        const multiResult = ScanResult.multiMatch(
          candidates: [
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '1',
              title: 'Album A',
            ),
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '2',
              title: 'Album B',
            ),
          ],
          barcode: barcode,
          barcodeType: 'ean13',
        );

        when(() => mockMediaItemRepo.barcodeExists(barcode))
            .thenAnswer((_) async => false);
        when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
            .thenAnswer((_) async => multiResult);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        await notifier.onBarcodeScanned(barcode);

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.disambiguating);
        expect(state.result, isA<MultiMatchScanResult>());
        final multi = state.result! as MultiMatchScanResult;
        expect(multi.candidates.length, 2);
      });

      test('auto-selects first candidate in batch mode', () async {
        const barcode = '5099902894225';
        const multiResult = ScanResult.multiMatch(
          candidates: [
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '1',
              title: 'Album A',
            ),
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '2',
              title: 'Album B',
            ),
          ],
          barcode: barcode,
          barcodeType: 'ean13',
        );
        const detail = MetadataResult(
          barcode: barcode,
          barcodeType: 'ean13',
          title: 'Album A',
          mediaType: MediaType.music,
        );

        when(() => mockMediaItemRepo.barcodeExists(barcode))
            .thenAnswer((_) async => false);
        when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
            .thenAnswer((_) async => multiResult);
        when(() => mockMetadataRepo.fetchCandidateDetail(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => detail);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        notifier.toggleBatchMode();
        await notifier.onBarcodeScanned(barcode);

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.found);
        expect(state.result, isA<SingleScanResult>());
        final single = state.result! as SingleScanResult;
        expect(single.metadata.title, 'Album A');
      });

      test('batch mode falls back to notFound when detail fetch fails',
          () async {
        const barcode = '5099902894225';
        const multiResult = ScanResult.multiMatch(
          candidates: [
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '1',
              title: 'Album A',
            ),
          ],
          barcode: barcode,
          barcodeType: 'ean13',
        );

        when(() => mockMediaItemRepo.barcodeExists(barcode))
            .thenAnswer((_) async => false);
        when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
            .thenAnswer((_) async => multiResult);
        when(() => mockMetadataRepo.fetchCandidateDetail(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => null);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        notifier.toggleBatchMode();
        await notifier.onBarcodeScanned(barcode);

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.notFound);
      });
    });

    group('onCandidateSelected', () {
      test('transitions to found with selected metadata', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        const metadata = MetadataResult(
          barcode: '123',
          barcodeType: 'ean13',
          title: 'Selected Album',
          mediaType: MediaType.music,
        );

        notifier.onCandidateSelected(metadata);

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.found);
        expect(state.result, isA<SingleScanResult>());
        final single = state.result! as SingleScanResult;
        expect(single.metadata.title, 'Selected Album');
        expect(single.isDuplicate, isFalse);
      });
    });

    group('onNoneSelected', () {
      test('transitions to found with barcode-only stub', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        notifier.onNoneSelected('5099902894225', 'ean13');

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.found);
        expect(state.result, isA<SingleScanResult>());
        final single = state.result! as SingleScanResult;
        expect(single.metadata.barcode, '5099902894225');
        expect(single.metadata.title, isNull);
        expect(single.isDuplicate, isFalse);
      });
    });

    group('searchByTitle', () {
      test('transitions to found when title search returns single', () async {
        const searchResult = ScanResult.single(
          metadata: MetadataResult(
            barcode: '9325336120538',
            barcodeType: 'ean13',
            title: 'Harry Potter',
            mediaType: MediaType.film,
          ),
          isDuplicate: false,
        );

        when(() => mockMetadataRepo.searchByTitle(
              'Harry Potter',
              '9325336120538',
              'ean13',
              typeHint: null,
            )).thenAnswer((_) async => searchResult);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        await notifier.searchByTitle(
            'Harry Potter', '9325336120538', 'ean13');

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.found);
        expect(state.result, isA<SingleScanResult>());
      });

      test('transitions to disambiguating when title search returns multi',
          () async {
        const multiResult = ScanResult.multiMatch(
          candidates: [
            MetadataCandidate(
                sourceApi: 'tmdb', sourceId: '1', title: 'HP 1'),
            MetadataCandidate(
                sourceApi: 'tmdb', sourceId: '2', title: 'HP 2'),
          ],
          barcode: '9325336120538',
          barcodeType: 'ean13',
        );

        when(() => mockMetadataRepo.searchByTitle(
              'Harry Potter',
              '9325336120538',
              'ean13',
              typeHint: null,
            )).thenAnswer((_) async => multiResult);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        await notifier.searchByTitle(
            'Harry Potter', '9325336120538', 'ean13');

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.disambiguating);
      });

      test('transitions to notFound when title search returns nothing',
          () async {
        const notFoundResult = ScanResult.notFound(
          barcode: '9325336120538',
          barcodeType: 'ean13',
        );

        when(() => mockMetadataRepo.searchByTitle(
              'Nonexistent',
              '9325336120538',
              'ean13',
              typeHint: null,
            )).thenAnswer((_) async => notFoundResult);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        await notifier.searchByTitle(
            'Nonexistent', '9325336120538', 'ean13');

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.notFound);
      });

      test('transitions to error on exception', () async {
        when(() => mockMetadataRepo.searchByTitle(
              any(),
              any(),
              any(),
              typeHint: any(named: 'typeHint'),
            )).thenThrow(Exception('Network error'));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        await notifier.searchByTitle('Test', '000', 'ean13');

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.error);
      });
    });

    group('cancel', () {
      test('resets state to idle from lookingUp', () async {
        const barcode = '5099902894225';
        final completer = Completer<ScanResult>();

        when(() => mockMediaItemRepo.barcodeExists(barcode))
            .thenAnswer((_) async => false);
        when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
            .thenAnswer((_) => completer.future);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        final future = notifier.onBarcodeScanned(barcode);

        // Should be looking up now
        expect(container.read(scannerProvider).state, ScanState.lookingUp);

        // Cancel before the lookup completes
        notifier.cancel();
        expect(container.read(scannerProvider).state, ScanState.idle);

        // Complete the lookup — result should be discarded
        completer.complete(const ScanResult.single(
          metadata: MetadataResult(
            barcode: barcode,
            barcodeType: 'ean13',
            title: 'Late Result',
          ),
          isDuplicate: false,
        ));
        await future;

        // State should still be idle, not found
        expect(container.read(scannerProvider).state, ScanState.idle);
        expect(container.read(scannerProvider).result, isNull);
      });

      test('preserves batch mode and media types after cancel', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        notifier.toggleBatchMode();
        // Default is all 5 types. Remove all except music.
        notifier.toggleMediaType(MediaType.film);
        notifier.toggleMediaType(MediaType.tv);
        notifier.toggleMediaType(MediaType.book);
        notifier.toggleMediaType(MediaType.game);

        notifier.cancel();

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.idle);
        expect(state.batchMode, isTrue);
        expect(state.enabledMediaTypes, {MediaType.music});
      });

      test('discards stale searchByTitle result after cancel', () async {
        final completer = Completer<ScanResult>();

        when(() => mockMetadataRepo.searchByTitle(
              any(),
              any(),
              any(),
              typeHint: any(named: 'typeHint'),
            )).thenAnswer((_) => completer.future);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        final future = notifier.searchByTitle('Test', '000', 'ean13');

        expect(container.read(scannerProvider).state, ScanState.lookingUp);

        notifier.cancel();
        expect(container.read(scannerProvider).state, ScanState.idle);

        completer.complete(const ScanResult.single(
          metadata: MetadataResult(
            barcode: '000',
            barcodeType: 'ean13',
            title: 'Late',
          ),
          isDuplicate: false,
        ));
        await future;

        expect(container.read(scannerProvider).state, ScanState.idle);
      });
    });

    group('startCoverScan', () {
      test('transitions to coverScan state', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        notifier.startCoverScan();

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.coverScan);
      });
    });

    group('onCoverTextRecognised', () {
      test('delegates to searchByTitle', () async {
        const searchResult = ScanResult.single(
          metadata: MetadataResult(
            barcode: '000',
            barcodeType: 'ean13',
            title: 'Cover Title',
            mediaType: MediaType.film,
          ),
          isDuplicate: false,
        );

        when(() => mockMetadataRepo.searchByTitle(
              'Cover Title',
              '000',
              'ean13',
              typeHint: null,
            )).thenAnswer((_) async => searchResult);

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(scannerProvider.notifier);
        await notifier.onCoverTextRecognised('Cover Title', '000', 'ean13');

        final state = container.read(scannerProvider);
        expect(state.state, ScanState.found);
      });
    });
  });
}
