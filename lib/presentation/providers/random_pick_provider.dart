// Random pick provider — hand-written AsyncNotifier holding the current
// RandomPickFilter and exposing updateFilter(...) and roll().
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/random_pick_filter.dart';
import 'package:mymediascanner/domain/usecases/random_pick_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final randomPickUsecaseProvider = Provider<RandomPickUsecase>((ref) {
  return RandomPickUsecase(ref.watch(mediaItemRepositoryProvider));
});

class RandomPickNotifier extends AsyncNotifier<MediaItem?> {
  RandomPickFilter _filter = const RandomPickFilter();

  RandomPickFilter get filter => _filter;

  @override
  Future<MediaItem?> build() async => null;

  void updateFilter(RandomPickFilter filter) {
    _filter = filter;
  }

  Future<void> roll() async {
    state = const AsyncLoading<MediaItem?>().copyWithPrevious(state);
    state = await AsyncValue.guard<MediaItem?>(() async {
      final uc = ref.read(randomPickUsecaseProvider);
      return uc(_filter);
    });
  }

  void clear() {
    state = const AsyncData<MediaItem?>(null);
  }
}

final randomPickProvider =
    AsyncNotifierProvider<RandomPickNotifier, MediaItem?>(
  RandomPickNotifier.new,
);
