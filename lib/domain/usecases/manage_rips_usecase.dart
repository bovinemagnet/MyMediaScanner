import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

/// Use case for manual rip album linking and unlinking.
class ManageRipsUseCase {
  const ManageRipsUseCase({
    required IRipLibraryRepository repository,
  }) : _repo = repository;

  final IRipLibraryRepository _repo;

  /// Manually link a rip album to a media item.
  Future<void> linkToMediaItem(String ripAlbumId, String mediaItemId) async {
    await _repo.linkToMediaItem(ripAlbumId, mediaItemId);
  }

  /// Unlink a rip album from its media item.
  Future<void> unlinkFromMediaItem(String ripAlbumId) async {
    await _repo.unlinkFromMediaItem(ripAlbumId);
  }
}
