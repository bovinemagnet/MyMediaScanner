import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/random_pick_filter.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/random_pick_usecase.dart';
import 'package:mymediascanner/presentation/providers/random_pick_provider.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _item(String id, {MediaType mediaType = MediaType.film}) => MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: mediaType,
      title: 'Title $id',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
      ownershipStatus: OwnershipStatus.owned,
    );

void main() {
  test('initial state is AsyncData(null)', () async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value([_item('a')]));

    final c = ProviderContainer(overrides: [
      randomPickUsecaseProvider.overrideWithValue(
        RandomPickUsecase(repo, rng: Random(0)),
      ),
    ]);
    addTearDown(c.dispose);

    // Ensure provider has built.
    final initial = await c.read(randomPickProvider.future);
    expect(initial, isNull);
  });

  test('roll() updates state with a picked item', () async {
    final repo = MockMediaItemRepository();
    final items = [_item('a'), _item('b'), _item('c')];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final c = ProviderContainer(overrides: [
      randomPickUsecaseProvider.overrideWithValue(
        RandomPickUsecase(repo, rng: Random(1)),
      ),
    ]);
    addTearDown(c.dispose);

    await c.read(randomPickProvider.future);
    await c.read(randomPickProvider.notifier).roll();
    final value = c.read(randomPickProvider).value;
    expect(value, isNotNull);
    expect(['a', 'b', 'c'], contains(value!.id));
  });

  test('updateFilter() updates the stored filter and next roll uses it',
      () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('film', mediaType: MediaType.film),
      _item('book', mediaType: MediaType.book),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final c = ProviderContainer(overrides: [
      randomPickUsecaseProvider.overrideWithValue(
        RandomPickUsecase(repo, rng: Random(0)),
      ),
    ]);
    addTearDown(c.dispose);

    await c.read(randomPickProvider.future);
    final notifier = c.read(randomPickProvider.notifier);
    notifier.updateFilter(const RandomPickFilter(mediaType: MediaType.book));
    expect(notifier.filter.mediaType, MediaType.book);

    await notifier.roll();
    final picked = c.read(randomPickProvider).value;
    expect(picked!.id, 'book');
  });

  test('roll() sets state to AsyncData(null) when no items match',
      () async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(<MediaItem>[]));

    final c = ProviderContainer(overrides: [
      randomPickUsecaseProvider.overrideWithValue(
        RandomPickUsecase(repo, rng: Random(0)),
      ),
    ]);
    addTearDown(c.dispose);

    await c.read(randomPickProvider.future);
    await c.read(randomPickProvider.notifier).roll();
    final v = c.read(randomPickProvider);
    expect(v.hasValue, isTrue);
    expect(v.value, isNull);
  });
}
