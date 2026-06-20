import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/presentation/providers/disambiguation_provider.dart';
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
        apiKeysProvider.overrideWith(() => ApiKeysNotifierStub()),
      ],
    );
  }

  ScanResult multiMatch(String barcode, List<String> titles) =>
      ScanResult.multiMatch(
        candidates: [
          for (final (i, title) in titles.indexed)
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '$barcode-$i',
              title: title,
            ),
        ],
        barcode: barcode,
        barcodeType: 'ean13',
      );

  void stubScan(String barcode, ScanResult result) {
    when(() => mockMediaItemRepo.barcodeExists(barcode))
        .thenAnswer((_) async => false);
    when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
        .thenAnswer((_) async => result);
  }

  group('DisambiguationNotifier', () {
    test('shows the candidates of the current multi-match scan', () async {
      const barcode = '5099902894225';
      stubScan(barcode, multiMatch(barcode, ['Album A', 'Album B']));

      final container = createContainer();
      addTearDown(container.dispose);
      // Keep the provider alive and rebuilding, as the screen would.
      container.listen(disambiguationProvider, (_, _) {});

      await container.read(scannerProvider.notifier).onBarcodeScanned(barcode);

      final data = container.read(disambiguationProvider);
      expect(data.barcode, barcode);
      expect(data.candidates.map((c) => c.title), ['Album A', 'Album B']);
    });

    test('shows fresh candidates for each subsequent multi-match scan',
        () async {
      // Regression: the notifier snapshotted the scan result with
      // `ref.read` in a non-autoDispose `build()`, which runs once per
      // app lifetime — so every multi-match scan after the first showed
      // the FIRST scan's candidates and barcode.
      const firstBarcode = '5099902894225';
      const secondBarcode = '0602567749455';
      stubScan(firstBarcode, multiMatch(firstBarcode, ['Album A', 'Album B']));
      stubScan(
          secondBarcode, multiMatch(secondBarcode, ['Film X', 'Film Y']));

      final container = createContainer();
      addTearDown(container.dispose);
      container.listen(disambiguationProvider, (_, _) {});

      final scanner = container.read(scannerProvider.notifier);

      await scanner.onBarcodeScanned(firstBarcode);
      expect(container.read(disambiguationProvider).barcode, firstBarcode);

      // User backs out and scans something else.
      scanner.reset();
      await scanner.onBarcodeScanned(secondBarcode);

      final data = container.read(disambiguationProvider);
      expect(data.barcode, secondBarcode);
      expect(data.candidates.map((c) => c.title), ['Film X', 'Film Y']);
    });

    test('candidate removal on null detail survives within one scan',
        () async {
      const barcode = '5099902894225';
      stubScan(barcode, multiMatch(barcode, ['Album A', 'Album B']));
      when(() => mockMetadataRepo.fetchCandidateDetail(any(), barcode, 'ean13'))
          .thenAnswer((_) async => null);

      final container = createContainer();
      addTearDown(container.dispose);
      container.listen(disambiguationProvider, (_, _) {});

      await container.read(scannerProvider.notifier).onBarcodeScanned(barcode);

      final notifier = container.read(disambiguationProvider.notifier);
      final first = container.read(disambiguationProvider).candidates.first;
      final detail = await notifier.selectCandidate(first);

      expect(detail, isNull);
      expect(container.read(disambiguationProvider).candidates.map((c) => c.title),
          ['Album B'],
          reason: 'a failed candidate is removed from the list');
    });
  });

  group('DisambiguationNotifier logic', () {
    test('MetadataCandidate equality works for filtering', () {
      const a = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'Album A',
        mediaType: MediaType.music,
      );
      const b = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'Album A',
        mediaType: MediaType.music,
      );

      expect(a == b, isTrue);
      expect([a, b].where((c) => c != a).isEmpty, isTrue);
    });
  });
}
