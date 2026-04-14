import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _item(String id, OwnershipStatus status) => MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: MediaType.book,
      title: 'Title $id',
      dateAdded: 1000,
      dateScanned: 1000,
      updatedAt: 1000,
      ownershipStatus: status,
    );

void main() {
  test('collection excludes wishlist items', () async {
    final repo = MockMediaItemRepository();
    final owned = _item('o1', OwnershipStatus.owned);
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value([owned]));

    final c = ProviderContainer(overrides: [
      mediaItemRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);

    // Wait for StreamProvider to emit.
    final completer = Completer<List<MediaItem>>();
    c.listen<AsyncValue<List<MediaItem>>>(
      collectionProvider,
      (prev, next) {
        next.whenData((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
      },
      fireImmediately: true,
    );
    final items = await completer.future.timeout(const Duration(seconds: 5));
    expect(items.map((e) => e.id).toList(), ['o1']);
  });
}
