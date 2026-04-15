import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/convert_wishlist_to_owned_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _wish(String id) => MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: MediaType.book,
      title: 'Title $id',
      dateAdded: 100,
      dateScanned: 100,
      updatedAt: 100,
      ownershipStatus: OwnershipStatus.wishlist,
    );

void main() {
  setUpAll(() {
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

  test('converts item from wishlist to owned and stamps acquiredAt',
      () async {
    final repo = MockMediaItemRepository();
    final item = _wish('x');
    when(() => repo.getById('x')).thenAnswer((_) async => item);
    when(() => repo.update(any())).thenAnswer((_) async {});

    final uc = ConvertWishlistToOwnedUsecase(repo, clock: () => 1700);
    await uc('x');

    final captured =
        verify(() => repo.update(captureAny())).captured.single as MediaItem;
    expect(captured.ownershipStatus, OwnershipStatus.owned);
    expect(captured.acquiredAt, 1700);
    expect(captured.updatedAt, 1700);
  });

  test('no-op when item is already owned', () async {
    final repo = MockMediaItemRepository();
    final owned = _wish('y').copyWith(ownershipStatus: OwnershipStatus.owned);
    when(() => repo.getById('y')).thenAnswer((_) async => owned);

    final uc = ConvertWishlistToOwnedUsecase(repo);
    await uc('y');

    verifyNever(() => repo.update(any()));
  });

  test('no-op when item not found', () async {
    final repo = MockMediaItemRepository();
    when(() => repo.getById('z')).thenAnswer((_) async => null);

    final uc = ConvertWishlistToOwnedUsecase(repo);
    await uc('z');

    verifyNever(() => repo.update(any()));
  });
}
