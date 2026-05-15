// Soft-deleted items stream + restore/discard actions.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Stream of items where `deleted == 1`, ordered most-recently-trashed
/// first. Used by the Trash screen.
final deletedItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(mediaItemRepositoryProvider).watchDeleted();
});

/// Restores a previously soft-deleted item by id.
Future<void> restoreDeletedItem(WidgetRef ref, String id) {
  return ref.read(mediaItemRepositoryProvider).restore(id);
}

/// Permanently removes a soft-deleted item from local storage.
Future<void> hardDeleteItem(WidgetRef ref, String id) {
  return ref.read(mediaItemRepositoryProvider).hardDelete(id);
}
