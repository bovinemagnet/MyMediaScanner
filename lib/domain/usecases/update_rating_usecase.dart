import 'package:mymediascanner/core/errors/app_exception.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class UpdateRatingUseCase {
  const UpdateRatingUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Future<void> execute(
    String itemId, {
    double? rating,
    String? review,
  }) async {
    final item = await _repo.getById(itemId);
    if (item == null) throw const DatabaseException('Item not found');

    final now = DateTime.now().millisecondsSinceEpoch;
    await _repo.update(item.copyWith(
      userRating: rating ?? item.userRating,
      userReview: review ?? item.userReview,
      updatedAt: now,
    ));
  }
}
