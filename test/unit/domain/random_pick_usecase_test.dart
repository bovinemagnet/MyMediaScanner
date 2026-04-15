import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/random_pick_filter.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/random_pick_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _item(
  String id, {
  MediaType mediaType = MediaType.film,
  List<String> genres = const [],
  double? userRating,
  Map<String, dynamic> extraMetadata = const {},
  OwnershipStatus status = OwnershipStatus.owned,
}) =>
    MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: mediaType,
      title: 'Title $id',
      genres: genres,
      userRating: userRating,
      extraMetadata: extraMetadata,
      ownershipStatus: status,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

void main() {
  test('returns null when no items match', () async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(<MediaItem>[]));

    final uc = RandomPickUsecase(repo, rng: Random(0));
    final result = await uc(const RandomPickFilter());
    expect(result, isNull);
  });

  test('returns an item from the filtered subset (deterministic)', () async {
    final repo = MockMediaItemRepository();
    final items = [_item('a'), _item('b'), _item('c')];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(0));
    final result = await uc(const RandomPickFilter());
    expect(result, isNotNull);
    expect(['a', 'b', 'c'], contains(result!.id));
  });

  test('honours mediaType filter', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('film1', mediaType: MediaType.film),
      _item('book1', mediaType: MediaType.book),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result = await uc(const RandomPickFilter(mediaType: MediaType.book));
    expect(result!.id, 'book1');
  });

  test('honours unratedOnly filter', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('rated', userRating: 4.0),
      _item('unrated'),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result = await uc(const RandomPickFilter(unratedOnly: true));
    expect(result!.id, 'unrated');
  });

  test('honours genre filter', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('a', genres: const ['Action']),
      _item('b', genres: const ['Comedy']),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result = await uc(const RandomPickFilter(genre: 'Comedy'));
    expect(result!.id, 'b');
  });

  test('honours maxRuntimeMinutes using runtime_minutes key', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('short', extraMetadata: const {'runtime_minutes': 90}),
      _item('long', extraMetadata: const {'runtime_minutes': 200}),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result =
        await uc(const RandomPickFilter(maxRuntimeMinutes: 120));
    expect(result!.id, 'short');
  });

  test('honours maxPageCount using page_count key', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('slim', extraMetadata: const {'page_count': 150}),
      _item('tome', extraMetadata: const {'page_count': 900}),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result =
        await uc(const RandomPickFilter(maxPageCount: 300));
    expect(result!.id, 'slim');
  });

  test('genre filter is case-insensitive', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('a', genres: const ['Science Fiction']),
      _item('b', genres: const ['Comedy']),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result =
        await uc(const RandomPickFilter(genre: 'science fiction'));
    expect(result!.id, 'a');
  });

  test('maxRuntimeMinutes coerces numeric (double) runtime values', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('short', extraMetadata: const {'runtime_minutes': 90.0}),
      _item('long', extraMetadata: const {'runtime_minutes': 200.0}),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result =
        await uc(const RandomPickFilter(maxRuntimeMinutes: 120));
    expect(result!.id, 'short');
  });

  test('maxPageCount coerces numeric (double) page counts', () async {
    final repo = MockMediaItemRepository();
    final items = [
      _item('slim', extraMetadata: const {'page_count': 150.0}),
      _item('tome', extraMetadata: const {'page_count': 900.0}),
    ];
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc = RandomPickUsecase(repo, rng: Random(1));
    final result =
        await uc(const RandomPickFilter(maxPageCount: 300));
    expect(result!.id, 'slim');
  });

  test('only considers owned items (watchByStatus called with owned)',
      () async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value([_item('a')]));

    final uc = RandomPickUsecase(repo, rng: Random(0));
    await uc(const RandomPickFilter());

    verify(() => repo.watchByStatus(OwnershipStatus.owned)).called(1);
    verifyNever(() => repo.watchByStatus(OwnershipStatus.wishlist));
  });

  test('deterministic selection with seeded Random', () async {
    final repo = MockMediaItemRepository();
    final items = List.generate(5, (i) => _item('i$i'));
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value(items));

    final uc1 = RandomPickUsecase(repo, rng: Random(42));
    final uc2 = RandomPickUsecase(repo, rng: Random(42));
    final a = await uc1(const RandomPickFilter());
    final b = await uc2(const RandomPickFilter());
    expect(a!.id, b!.id);
  });
}
