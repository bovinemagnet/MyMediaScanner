import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
});

final tagIdsForItemProvider =
    FutureProvider.family<List<String>, String>((ref, mediaItemId) {
  return ref.watch(tagRepositoryProvider).getTagIdsForMediaItem(mediaItemId);
});
