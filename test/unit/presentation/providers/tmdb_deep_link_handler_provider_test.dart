import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

void main() {
  // Regression test for the slice 4d crash where `_AppState.initState`
  // eagerly read `tmdbDeepLinkHandlerProvider` and propagated the
  // `StateError` thrown by `tmdbAccountSyncRepositoryProvider` when no
  // TMDB API key is configured. Riverpod 3 wraps that in a
  // `ProviderException`, so we match by message rather than type — the
  // important contract is "this read can throw, callers must guard it".
  test(
      'tmdbDeepLinkHandlerProvider throws when TMDB API key absent',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(tmdbDeepLinkHandlerProvider),
      throwsA(predicate((Object e) =>
          e.toString().contains('TMDB API key not configured'))),
    );
  });
}
