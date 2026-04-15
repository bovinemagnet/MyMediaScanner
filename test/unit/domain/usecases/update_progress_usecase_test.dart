import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/progress_unit.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/update_progress_usecase.dart';

class _MockRepo extends Mock implements IMediaItemRepository {}

void main() {
  late UpdateProgressUseCase usecase;
  late _MockRepo repo;
  late DateTime fixedNow;

  const baseItem = MediaItem(
    id: 'item-1',
    barcode: '123',
    barcodeType: 'EAN13',
    mediaType: MediaType.book,
    title: 'A Book',
    dateAdded: 0,
    dateScanned: 0,
    updatedAt: 0,
  );

  setUpAll(() {
    registerFallbackValue(baseItem);
  });

  setUp(() {
    repo = _MockRepo();
    when(() => repo.update(any())).thenAnswer((_) async {});
    fixedNow = DateTime.utc(2026, 4, 15, 12, 0);
    usecase = UpdateProgressUseCase(repository: repo, clock: () => fixedNow);
  });

  test('start stamps startedAt and unit', () async {
    final result = await usecase.start(
      baseItem,
      unit: ProgressUnit.page,
      total: 320,
    );

    expect(result.startedAt, fixedNow.millisecondsSinceEpoch);
    expect(result.progressUnit, ProgressUnit.page);
    expect(result.progressTotal, 320);
    expect(result.progressCurrent, 0);
    expect(result.completedAt, isNull);
    expect(result.consumed, isFalse);
    verify(() => repo.update(any())).called(1);
  });

  test('start preserves existing startedAt on a re-start', () async {
    final started = baseItem.copyWith(
      startedAt: 1700000000000,
      progressUnit: ProgressUnit.page,
      progressCurrent: 50,
    );
    final result =
        await usecase.start(started, unit: ProgressUnit.chapter, total: 12);

    expect(result.startedAt, 1700000000000);
    expect(result.progressUnit, ProgressUnit.chapter);
    expect(result.progressTotal, 12);
    expect(result.progressCurrent, 50);
  });

  test('updateCurrent caps at progressTotal', () async {
    final started = baseItem.copyWith(
      startedAt: 1,
      progressUnit: ProgressUnit.page,
      progressTotal: 100,
    );
    final result = await usecase.updateCurrent(started, 250);
    expect(result.progressCurrent, 100);
  });

  test('updateCurrent floors at 0', () async {
    final started = baseItem.copyWith(startedAt: 1);
    final result = await usecase.updateCurrent(started, -5);
    expect(result.progressCurrent, 0);
  });

  test('markComplete sets completedAt and consumed', () async {
    final started = baseItem.copyWith(
      startedAt: 1,
      progressTotal: 100,
      progressUnit: ProgressUnit.page,
    );
    final result = await usecase.markComplete(started);

    expect(result.completedAt, fixedNow.millisecondsSinceEpoch);
    expect(result.consumed, isTrue);
    expect(result.progressCurrent, 100); // snapped to total
  });

  test('markComplete leaves current alone when total is unknown', () async {
    final started = baseItem.copyWith(
      startedAt: 1,
      progressCurrent: 42,
      progressUnit: ProgressUnit.page,
    );
    final result = await usecase.markComplete(started);
    expect(result.progressCurrent, 42);
  });

  test('reset clears every progress field', () async {
    final populated = baseItem.copyWith(
      startedAt: 1,
      progressCurrent: 100,
      progressTotal: 200,
      progressUnit: ProgressUnit.page,
      completedAt: 5,
      consumed: true,
    );
    final result = await usecase.reset(populated);
    expect(result.startedAt, isNull);
    expect(result.progressCurrent, isNull);
    expect(result.progressTotal, isNull);
    expect(result.progressUnit, isNull);
    expect(result.completedAt, isNull);
    expect(result.consumed, isFalse);
  });
}
