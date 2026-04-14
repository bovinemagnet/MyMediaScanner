import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/wishlist_provider.dart';

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
  test('wishlistProvider emits only wishlist items', () async {
    final repo = MockMediaItemRepository();
    final wish = _item('w1', OwnershipStatus.wishlist);
    when(() => repo.watchByStatus(OwnershipStatus.wishlist))
        .thenAnswer((_) => Stream.value([wish]));

    final c = ProviderContainer(overrides: [
      mediaItemRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);

    final completer = Completer<List<MediaItem>>();
    c.listen<AsyncValue<List<MediaItem>>>(
      wishlistProvider,
      (prev, next) {
        next.whenData((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
      },
      fireImmediately: true,
    );
    final items = await completer.future.timeout(const Duration(seconds: 5));
    expect(items.map((e) => e.id).toList(), ['w1']);
  });
}
