import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  return ref.watch(shelfRepositoryProvider).watchAll();
});

final shelfItemIdsProvider =
    FutureProvider.family<List<String>, String>((ref, shelfId) {
  return ref.watch(shelfRepositoryProvider).getMediaItemIdsForShelf(shelfId);
});
