import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

/// Converts a wishlist item to owned, stamping `acquiredAt` and `updatedAt`
/// with the current epoch-ms timestamp. No-op if the item is missing or is
/// not in the wishlist state.
class ConvertWishlistToOwnedUsecase {
  ConvertWishlistToOwnedUsecase(
    this._repo, {
    int Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final IMediaItemRepository _repo;
  final int Function() _clock;

  Future<void> call(String id) async {
    final item = await _repo.getById(id);
    if (item == null || item.ownershipStatus != OwnershipStatus.wishlist) {
      return;
    }
    final now = _clock();
    await _repo.update(item.copyWith(
      ownershipStatus: OwnershipStatus.owned,
      acquiredAt: now,
      updatedAt: now,
    ));
  }
}
