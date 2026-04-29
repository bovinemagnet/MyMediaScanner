import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/router.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// Global key so the deep-link handler can show SnackBars without
/// needing a [BuildContext].
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Eagerly construct the handler so the URI listener is alive
    // before any approval URL is launched. Provider's `onDispose`
    // owns teardown.
    //
    // Wrapped in try/catch because the handler chain depends on
    // `tmdbAccountSyncRepositoryProvider`, which throws `StateError`
    // when no TMDB API key is configured. In that case the user has
    // no TMDB connection flow yet, so silently skipping the eager
    // read is correct — the handler will be lazily constructed if
    // and when the API key is supplied later.
    try {
      ref.read(tmdbDeepLinkHandlerProvider);
    } catch (_) {
      // No-op.
    }
  }

  @override
  Widget build(BuildContext context) {
    final choice = ref.watch(themeChoiceProvider);
    final (light, dark) = switch (choice.family) {
      ThemeFamily.classic => (AppTheme.light(), AppTheme.dark()),
      ThemeFamily.popcorn =>
        (AppTheme.popcornLight(), AppTheme.popcornDark()),
    };

    // Surface a SnackBar when the deep link arrives and the dialog
    // is not currently mounted. The dialog handles its own UI when up.
    ref.listen<AsyncValue<TmdbDeepLinkEvent>>(
      _deepLinkEventStreamProvider,
      (_, next) {
        next.whenData((event) {
          final dialogVisible = ref.read(tmdbConnectDialogVisibleProvider);
          if (dialogVisible) return;
          final messenger = rootScaffoldMessengerKey.currentState;
          if (messenger == null) return;
          switch (event) {
            case TmdbDeepLinkSuccess():
              messenger.showSnackBar(const SnackBar(
                  content: Text('Connected to TMDB')));
            case TmdbDeepLinkCancelled():
              messenger.showSnackBar(const SnackBar(
                  content: Text('TMDB approval was denied')));
            case TmdbDeepLinkMismatch():
              // Silent — most common cause is a stale link arriving
              // long after the user dismissed the flow. Don't paper
              // over the screen.
              break;
            case TmdbDeepLinkNoPending():
              messenger.showSnackBar(const SnackBar(
                  content: Text(
                      'Approval link arrived but no connection was in progress — please tap Connect again.')));
          }
        });
      },
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: light,
      darkTheme: dark,
      themeMode: themeModeFrom(choice.brightness),
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Bridges the deep-link handler's broadcast stream into Riverpod so
/// `ref.listen` can observe events.
///
/// `tmdbDeepLinkHandlerProvider` transitively depends on
/// `tmdbAccountSyncRepositoryProvider`, which throws `StateError` when
/// no TMDB Read Access Token is configured. We swallow that here so the
/// app can boot without a token; the handler will be re-evaluated when
/// the user enters one (provider invalidation propagates from the
/// `apiKeysProvider`).
final _deepLinkEventStreamProvider =
    StreamProvider.autoDispose<TmdbDeepLinkEvent>((ref) {
  try {
    return ref.watch(tmdbDeepLinkHandlerProvider).events;
  } on StateError {
    return const Stream<TmdbDeepLinkEvent>.empty();
  }
});
