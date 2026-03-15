import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class DeleteMediaItemUseCase {
  const DeleteMediaItemUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Future<void> execute(String id) => _repo.softDelete(id);
}
