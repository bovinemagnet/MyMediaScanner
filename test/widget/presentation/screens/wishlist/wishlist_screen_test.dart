import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/wishlist/wishlist_screen.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  testWidgets('WishlistScreen shows items and convert button',
      (tester) async {
    final repo = MockMediaItemRepository();
    final item = MediaItem(
      id: 'w1',
      barcode: 'bc',
      barcodeType: 'isbn13',
      mediaType: MediaType.book,
      title: 'A Book',
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      ownershipStatus: OwnershipStatus.wishlist,
    );
    when(() => repo.watchByStatus(OwnershipStatus.wishlist))
        .thenAnswer((_) => Stream.value([item]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaItemRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: WishlistScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A Book'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });
}
