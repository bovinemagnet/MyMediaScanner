import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final mediaItemProvider =
    FutureProvider.family<MediaItem?, String>((ref, id) async {
  return ref.watch(mediaItemRepositoryProvider).getById(id);
});
