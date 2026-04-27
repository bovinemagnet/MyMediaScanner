import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/repositories/series_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/series.dart';
import 'package:mymediascanner/domain/repositories/i_series_repository.dart';
import 'package:mymediascanner/domain/usecases/resolve_series_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final seriesRepositoryProvider = Provider<ISeriesRepository>((ref) {
  return SeriesRepositoryImpl(
    dao: ref.watch(seriesDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});

final allSeriesProvider = StreamProvider<List<SeriesWithCounts>>((ref) {
  return ref.watch(seriesRepositoryProvider).watchAllWithCounts();
});

/// Resolves the items currently assigned to [seriesId].
final seriesItemsProvider =
    FutureProvider.family<List<MediaItem>, String>((ref, seriesId) async {
  final ids =
      await ref.watch(seriesRepositoryProvider).getMediaItemIds(seriesId);
  final mediaRepo = ref.watch(mediaItemRepositoryProvider);
  final items = <MediaItem>[];
  for (final id in ids) {
    final item = await mediaRepo.getById(id);
    if (item != null) items.add(item);
  }
  return items;
});

final resolveSeriesUseCaseProvider = Provider<ResolveSeriesUseCase>((ref) {
  return ResolveSeriesUseCase(
    seriesRepository: ref.watch(seriesRepositoryProvider),
    mediaItemRepository: ref.watch(mediaItemRepositoryProvider),
  );
});

/// `SaveMediaItemUseCase` pre-wired with series resolution. Prefer this
/// over constructing the use case inline so saves consistently populate
/// the series table.
final saveMediaItemUseCaseProvider = Provider<SaveMediaItemUseCase>((ref) {
  return SaveMediaItemUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
    resolveSeries: ref.watch(resolveSeriesUseCaseProvider),
  );
});
