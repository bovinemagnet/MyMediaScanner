import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late MockMediaItemRepository mockRepo;
  late AppDatabase testDb;

  setUp(() {
    mockRepo = MockMediaItemRepository();
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
    registerFallbackValue(const MediaItem(
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

  tearDown(() async {
    await testDb.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        mediaItemRepositoryProvider.overrideWithValue(mockRepo),
        databaseProvider.overrideWithValue(testDb),
        batchSessionDaoProvider.overrideWithValue(testDb.batchSessionDao),
      ],
    );
  }

  /// Helper: reads the async state, waiting for data to be ready.
  Future<BatchEditorState> readState(ProviderContainer container) async {
    // Wait for the provider to resolve.
    BatchEditorState? result;
    for (var i = 0; i < 50; i++) {
      final asyncVal = container.read(batchEditorProvider);
      if (asyncVal.hasValue) {
        result = asyncVal.requireValue;
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    expect(result, isNotNull, reason: 'Provider did not resolve in time');
    return result!;
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
    test('initial state is empty with a session ID', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = await readState(container);
      expect(state.totalCount, 0);
      expect(state.items, isEmpty);
      expect(state.isSaving, false);
      expect(state.sessionId, isNotNull);
    });

    test('addScanResult with single match adds confirmed item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container); // wait for build
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.confirmedCount, 1);
      expect(state.items.first.status, BatchItemStatus.confirmed);
      expect(state.items.first.metadata?.title, 'Test Album');
      expect(state.items.first.barcode, '1234567890');
    });

    test('addScanResult with duplicate adds duplicate item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testDuplicateResult);

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.duplicateCount, 1);
      expect(state.items.first.status, BatchItemStatus.duplicate);
      expect(state.items.first.duplicateSource, DuplicateSource.collection);
    });

    test('addScanResult with multi-match adds conflict item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.conflictCount, 1);
      expect(state.items.first.status, BatchItemStatus.conflict);
      expect(state.items.first.metadata, isNull);
    });

    test('addScanResult with notFound adds notFound item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.notFoundCount, 1);
      expect(state.items.first.status, BatchItemStatus.notFound);
      expect(state.items.first.barcode, '9999999999');
    });

    test('resolveItem changes conflict to confirmed with metadata', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);
      final itemId = (await readState(container)).items.first.id;

      await container.read(batchEditorProvider.notifier).resolveItem(itemId, testMetadata);

      final state = await readState(container);
      expect(state.confirmedCount, 1);
      expect(state.conflictCount, 0);
      expect(state.items.first.metadata?.title, 'Test Album');
    });

    test('removeItem removes item from queue', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      expect((await readState(container)).totalCount, 2);

      final itemId = (await readState(container)).items.first.id;
      await container.read(batchEditorProvider.notifier).removeItem(itemId);

      expect((await readState(container)).totalCount, 1);
    });

    test('saveItem persists confirmed item and marks as saved', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      final itemId = (await readState(container)).items.first.id;

      await container.read(batchEditorProvider.notifier).saveItem(itemId);

      final state = await readState(container);
      expect(state.savedCount, 1);
      expect(state.confirmedCount, 0);
      verify(() => mockRepo.save(any())).called(1);
    });

    test('saveItem does nothing for non-confirmed items', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      final itemId = (await readState(container)).items.first.id;

      await container.read(batchEditorProvider.notifier).saveItem(itemId);

      expect((await readState(container)).savedCount, 0);
      verifyNever(() => mockRepo.save(any()));
    });

    test('saveAllConfirmed saves only confirmed items', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);

      // Use unique barcodes to avoid batch duplicate detection.
      const singleResult = ScanResult.single(
        metadata: MetadataResult(
          barcode: '1111111111',
          barcodeType: 'EAN-13',
          title: 'Confirmed Item',
          mediaType: MediaType.music,
        ),
        isDuplicate: false,
      );
      const multiMatch = ScanResult.multiMatch(
        candidates: [
          MetadataCandidate(sourceApi: 'test', sourceId: '1', title: 'A'),
          MetadataCandidate(sourceApi: 'test', sourceId: '2', title: 'B'),
        ],
        barcode: '3333333333',
        barcodeType: 'EAN-13',
      );

      await container.read(batchEditorProvider.notifier).addScanResult(singleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      await container.read(batchEditorProvider.notifier).addScanResult(multiMatch);

      await container.read(batchEditorProvider.notifier).saveAllConfirmed();

      final state = await readState(container);
      expect(state.savedCount, 1);
      expect(state.notFoundCount, 1);
      expect(state.conflictCount, 1);
      expect(state.isSaving, false);
      verify(() => mockRepo.save(any())).called(1);
    });

    test('clearBatch removes all items and creates new session', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      final origSession = (await readState(container)).sessionId;

      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      await container.read(batchEditorProvider.notifier).clearBatch();

      final state = await readState(container);
      expect(state.totalCount, 0);
      expect(state.sessionId, isNot(equals(origSession)));
    });

    test('clearSaved keeps unsaved items', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      final itemId = (await readState(container)).items.first.id;
      await container.read(batchEditorProvider.notifier).saveItem(itemId);

      await container.read(batchEditorProvider.notifier).clearSaved();

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.notFoundCount, 1);
    });

    test('autoMatchRate calculates correctly', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testMultiMatchResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testDuplicateResult);

      final state = await readState(container);
      // confirmed=1, duplicate=1 (collection dup) + 1 (batch dup = "1234567890" again)
      // Actually the 4th add has isDuplicate=true from collection AND same barcode
      // in batch. Both testSingleResult and testDuplicateResult use barcode
      // '1234567890'. The 4th item (testDuplicateResult) is a collection dup.
      // But testMultiMatchResult also uses '1234567890' - it will be a batch dup.
      //
      // Item 1: confirmed (single, not dup)
      // Item 2: notFound (barcode 9999999999)
      // Item 3: duplicate (batch dup - barcode 1234567890 already in batch)
      // Item 4: duplicate (collection dup - isDuplicate=true)
      //
      // So: confirmed=1, notFound=1, duplicate=2, conflict=0
      // autoMatchRate = (1 + 0 + 2) / 4 * 100 = 75%
      expect(state.autoMatchRate, 75.0);
    });

    test('needsReviewCount includes conflicts and notFound', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);

      // Add notFound first (unique barcode)
      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);
      // Add single (unique barcode relative to notFound)
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      // testMultiMatchResult has same barcode as testSingleResult → batch dup
      // We need a multi-match with a different barcode to get a conflict
      const uniqueMultiMatch = ScanResult.multiMatch(
        candidates: [
          MetadataCandidate(sourceApi: 'test', sourceId: '1', title: 'A'),
          MetadataCandidate(sourceApi: 'test', sourceId: '2', title: 'B'),
        ],
        barcode: '5555555555',
        barcodeType: 'EAN-13',
      );
      await container.read(batchEditorProvider.notifier).addScanResult(uniqueMultiMatch);

      final state = await readState(container);
      expect(state.needsReviewCount, 2); // 1 notFound + 1 conflict
    });

    test('multiple items get unique IDs', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);

      // Use different barcodes to avoid batch duplicate detection
      const meta1 = MetadataResult(
        barcode: '1111111111',
        barcodeType: 'EAN-13',
        title: 'Item 1',
      );
      const meta2 = MetadataResult(
        barcode: '2222222222',
        barcodeType: 'EAN-13',
        title: 'Item 2',
      );

      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: meta1, isDuplicate: false));
      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: meta2, isDuplicate: false));

      final state = await readState(container);
      expect(state.totalCount, 2);
      expect(state.items[0].id, isNot(equals(state.items[1].id)));
    });
  });

  group('Within-batch duplicate detection', () {
    test('second item with same barcode is marked as batch duplicate', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      final state = await readState(container);
      expect(state.totalCount, 2);
      expect(state.items[0].status, BatchItemStatus.confirmed);
      expect(state.items[1].status, BatchItemStatus.duplicate);
      expect(state.items[1].duplicateSource, DuplicateSource.batch);
    });

    test('duplicate detection is case-insensitive', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      const lower = MetadataResult(
        barcode: 'abc123',
        barcodeType: 'EAN-13',
        title: 'Lower',
      );
      const upper = MetadataResult(
        barcode: 'ABC123',
        barcodeType: 'EAN-13',
        title: 'Upper',
      );

      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: lower, isDuplicate: false));
      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: upper, isDuplicate: false));

      final state = await readState(container);
      expect(state.items[1].status, BatchItemStatus.duplicate);
      expect(state.items[1].duplicateSource, DuplicateSource.batch);
    });

    test('duplicate detection ignores leading zeroes', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      const withZeroes = MetadataResult(
        barcode: '00123',
        barcodeType: 'EAN-13',
        title: 'With Zeroes',
      );
      const withoutZeroes = MetadataResult(
        barcode: '123',
        barcodeType: 'EAN-13',
        title: 'Without Zeroes',
      );

      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: withZeroes, isDuplicate: false));
      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: withoutZeroes, isDuplicate: false));

      final state = await readState(container);
      expect(state.items[1].status, BatchItemStatus.duplicate);
    });

    test('forceKeepDuplicate changes status to confirmed', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);

      final dupId = (await readState(container)).items[1].id;
      await container.read(batchEditorProvider.notifier).forceKeepDuplicate(dupId);

      final state = await readState(container);
      expect(state.items[1].status, BatchItemStatus.confirmed);
    });
  });

  group('Undo/Redo', () {
    test('undo add removes item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      expect((await readState(container)).totalCount, 1);
      expect((await readState(container)).canUndo, true);

      await container.read(batchEditorProvider.notifier).undo();

      final state = await readState(container);
      expect(state.totalCount, 0);
      expect(state.canUndo, false);
      expect(state.canRedo, true);
    });

    test('redo after undo add restores item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).undo();

      await container.read(batchEditorProvider.notifier).redo();

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.canRedo, false);
    });

    test('undo remove restores item', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      final itemId = (await readState(container)).items.first.id;

      await container.read(batchEditorProvider.notifier).removeItem(itemId);
      expect((await readState(container)).totalCount, 0);

      await container.read(batchEditorProvider.notifier).undo();

      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.items.first.status, BatchItemStatus.confirmed);
    });

    test('undo when stack empty is no-op', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).undo();

      final state = await readState(container);
      expect(state.totalCount, 0);
    });

    test('redo when stack empty is no-op', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).redo();

      final state = await readState(container);
      expect(state.totalCount, 0);
    });

    test('new action after undo clears redo stack', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      await container.read(batchEditorProvider.notifier).undo();
      expect((await readState(container)).canRedo, true);

      await container.read(batchEditorProvider.notifier).addScanResult(testNotFoundResult);

      final state = await readState(container);
      expect(state.canRedo, false);
    });
  });

  group('Save progress', () {
    test('saveAllConfirmed tracks progress', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);

      const meta1 = MetadataResult(
        barcode: '1111111111',
        barcodeType: 'EAN-13',
        title: 'Item 1',
      );
      const meta2 = MetadataResult(
        barcode: '2222222222',
        barcodeType: 'EAN-13',
        title: 'Item 2',
      );

      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: meta1, isDuplicate: false));
      await container.read(batchEditorProvider.notifier).addScanResult(
          const ScanResult.single(metadata: meta2, isDuplicate: false));

      await container.read(batchEditorProvider.notifier).saveAllConfirmed();

      final state = await readState(container);
      expect(state.saveProgress, isNull);
      expect(state.isSaving, false);
      expect(state.savedCount, 2);
    });
  });

  group('Queue persistence', () {
    test('items survive notifier rebuild (simulated restart)', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await readState(container);
      await container.read(batchEditorProvider.notifier).addScanResult(testSingleResult);
      expect((await readState(container)).totalCount, 1);

      // Invalidate the provider to trigger a rebuild (simulates restart).
      container.invalidate(batchEditorProvider);

      // Wait for rebuild.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final state = await readState(container);
      expect(state.totalCount, 1);
      expect(state.items.first.barcode, '1234567890');
    });
  });
}
