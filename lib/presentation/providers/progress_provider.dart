import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/usecases/update_progress_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Live list of items currently being read/watched (started but not
/// completed), ordered by most-recently started.
final inProgressItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(mediaItemRepositoryProvider).watchInProgress();
});

final updateProgressUseCaseProvider = Provider<UpdateProgressUseCase>((ref) {
  return UpdateProgressUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
  );
});
