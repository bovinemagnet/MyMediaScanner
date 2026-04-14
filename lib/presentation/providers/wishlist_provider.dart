import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Streams all items in the collection with `ownershipStatus == wishlist`,
/// ordered by `dateAdded` descending.
final wishlistProvider = StreamProvider<List<MediaItem>>((ref) {
  final repo = ref.watch(mediaItemRepositoryProvider);
  return repo.watchByStatus(OwnershipStatus.wishlist);
});
