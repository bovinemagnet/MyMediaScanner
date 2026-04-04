import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late MockMediaItemRepository mockRepo;

  setUp(() {
    mockRepo = MockMediaItemRepository();
    registerFallbackValue(MediaItem(
      id: '',
      barcode: '',
      barcodeType: '',
      mediaType: MediaType.unknown,
      title: '',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    ));
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        mediaItemRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  const testMetadata = MetadataResult(
    barcode: '1234567890',
    barcodeType: 'EAN-13',
    title: 'Test Album',
    mediaType: MediaType.music,
  );

  const testSingleResult = ScanResult.single(
    metadata: testMetadata,
    isDuplicate: false,
  );

  const testDuplicateResult = ScanResult.single(
    metadata: testMetadata,
    isDuplicate: true,
  );

  const testMultiMatchResult = ScanResult.multiMatch(
    candidates: [
      MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'Option A',
      ),
      MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '2',
        title: 'Option B',
      ),
    ],
    barcode: '1234567890',
    barcodeType: 'EAN-13',
  );

  const testNotFoundResult = ScanResult.notFound(
    barcode: '9999999999',
    barcodeType: 'UPC-A',
  );

  group('BatchEditorNotifier', () {
    test('initial state is empty', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 0);
      expect(state.items, isEmpty);
      expect(state.isSaving, false);
    });

    test('addScanResult with single match adds confirmed item', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 1);
      expect(state.confirmedCount, 1);
      expect(state.items.first.status, BatchItemStatus.confirmed);
      expect(state.items.first.metadata?.title, 'Test Album');
      expect(state.items.first.barcode, '1234567890');
    });

    test('addScanResult with duplicate adds duplicate item', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testDuplicateResult);

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 1);
      expect(state.duplicateCount, 1);
      expect(state.items.first.status, BatchItemStatus.duplicate);
    });

    test('addScanResult with multi-match adds conflict item', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 1);
      expect(state.conflictCount, 1);
      expect(state.items.first.status, BatchItemStatus.conflict);
      expect(state.items.first.metadata, isNull);
    });

    test('addScanResult with notFound adds notFound item', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 1);
      expect(state.notFoundCount, 1);
      expect(state.items.first.status, BatchItemStatus.notFound);
      expect(state.items.first.barcode, '9999999999');
    });

    test('resolveItem changes conflict to confirmed with metadata', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);
      final itemId = container.read(batchEditorProvider).items.first.id;

      container.read(batchEditorProvider.notifier).resolveItem(itemId, testMetadata);

      final state = container.read(batchEditorProvider);
      expect(state.confirmedCount, 1);
      expect(state.conflictCount, 0);
      expect(state.items.first.metadata?.title, 'Test Album');
    });

    test('removeItem removes item from queue', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      expect(container.read(batchEditorProvider).totalCount, 2);

      final itemId = container.read(batchEditorProvider).items.first.id;
      container.read(batchEditorProvider.notifier).removeItem(itemId);

      expect(container.read(batchEditorProvider).totalCount, 1);
    });

    test('saveItem persists confirmed item and marks as saved', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      final itemId = container.read(batchEditorProvider).items.first.id;

      await container.read(batchEditorProvider.notifier).saveItem(itemId);

      final state = container.read(batchEditorProvider);
      expect(state.savedCount, 1);
      expect(state.confirmedCount, 0);
      verify(() => mockRepo.save(any())).called(1);
    });

    test('saveItem does nothing for non-confirmed items', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      final itemId = container.read(batchEditorProvider).items.first.id;

      await container.read(batchEditorProvider.notifier).saveItem(itemId);

      expect(container.read(batchEditorProvider).savedCount, 0);
      verifyNever(() => mockRepo.save(any()));
    });

    test('saveAllConfirmed saves only confirmed items', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);

      await container.read(batchEditorProvider.notifier).saveAllConfirmed();

      final state = container.read(batchEditorProvider);
      expect(state.savedCount, 1);
      expect(state.notFoundCount, 1);
      expect(state.conflictCount, 1);
      expect(state.isSaving, false);
      verify(() => mockRepo.save(any())).called(1);
    });

    test('clearBatch removes all items', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      container.read(batchEditorProvider.notifier).clearBatch();

      expect(container.read(batchEditorProvider).totalCount, 0);
    });

    test('clearSaved keeps unsaved items', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      final itemId = container.read(batchEditorProvider).items.first.id;
      await container.read(batchEditorProvider.notifier).saveItem(itemId);

      container.read(batchEditorProvider.notifier).clearSaved();

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 1);
      expect(state.notFoundCount, 1);
    });

    test('autoMatchRate calculates correctly', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);
      container.read(batchEditorProvider.notifier).addScanResult(testDuplicateResult);

      final state = container.read(batchEditorProvider);
      // confirmed=1, duplicate=1, notFound=1, conflict=1 → (1+1)/4 = 50%
      expect(state.autoMatchRate, 50.0);
    });

    test('needsReviewCount includes conflicts and notFound', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);
      container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      expect(container.read(batchEditorProvider).needsReviewCount, 2);
    });

    test('multiple items get unique IDs', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      final state = container.read(batchEditorProvider);
      expect(state.totalCount, 2);
      expect(state.items[0].id, isNot(equals(state.items[1].id)));
    });
  });
}
