import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_lists_section.dart';

Widget harness({
  required TmdbConnectionState connection,
  required TmdbAccountSyncSettings settings,
  List<TmdbBridgeItem> conflicts = const [],
  List<TmdbBridgeItem> savedRows = const [],
}) {
  return ProviderScope(
    overrides: [
      tmdbAccountConnectionProvider.overrideWith(
          () => _StubConnectionNotifier(connection)),
      tmdbAccountSyncSettingsProvider.overrideWith(
          () => _StubSettingsNotifier(settings)),
      tmdbConflictedRowsProvider.overrideWith(
          (ref) => Stream<List<TmdbBridgeItem>>.value(conflicts)),
      tmdbBridgeBucketProvider(TmdbBridgeBucket.saved).overrideWith(
          (ref) => Stream<List<TmdbBridgeItem>>.value(savedRows)),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: SafeArea(child: TmdbListsSection())),
          ),
          GoRoute(
              path: '/tmdb/watchlist',
              builder: (context, state) =>
                  const Scaffold(body: Text('Watchlist'))),
          GoRoute(
              path: '/tmdb/rated',
              builder: (context, state) =>
                  const Scaffold(body: Text('Rated'))),
          GoRoute(
              path: '/tmdb/favourites',
              builder: (context, state) =>
                  const Scaffold(body: Text('Favourites'))),
          GoRoute(
              path: '/tmdb/conflicts',
              builder: (context, state) =>
                  const Scaffold(body: Text('Conflicts'))),
          GoRoute(
              path: '/tmdb/saved',
              builder: (context, state) =>
                  const Scaffold(body: Text('Saved'))),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('renders nothing when disconnected', (tester) async {
    await tester.pumpWidget(harness(
      connection: const TmdbDisconnected(),
      settings: const TmdbAccountSyncSettings(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('TMDB Watchlist'), findsNothing);
    expect(find.text('TMDB Rated'), findsNothing);
    expect(find.text('TMDB Favourites'), findsNothing);
  });

  testWidgets('renders three tiles when connected', (tester) async {
    await tester.pumpWidget(harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('TMDB Watchlist'), findsOneWidget);
    expect(find.text('TMDB Rated'), findsOneWidget);
    expect(find.text('TMDB Favourites'), findsOneWidget);
    expect(find.textContaining('Resolve Conflicts'), findsNothing);
  });

  testWidgets(
      'shows Resolve Conflicts tile under ask-user policy with conflicts',
      (tester) async {
    const conflict = TmdbBridgeItem(
      id: 'br-1',
      tmdbId: 100,
      mediaType: 'movie',
    );
    await tester.pumpWidget(harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(
        conflictPolicy: TmdbConflictPolicy.askUser,
      ),
      conflicts: [conflict],
    ));
    await tester.pumpAndSettle();
    expect(find.text('Resolve Conflicts (1)'), findsOneWidget);
  });

  testWidgets(
      'hides Resolve Conflicts tile when policy is not askUser even if conflicts exist',
      (tester) async {
    const conflict = TmdbBridgeItem(
      id: 'br-1',
      tmdbId: 100,
      mediaType: 'movie',
    );
    await tester.pumpWidget(harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(
        conflictPolicy: TmdbConflictPolicy.preferLatestTimestamp,
      ),
      conflicts: [conflict],
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Resolve Conflicts'), findsNothing);
  });

  testWidgets('shows TMDB Saved tile when there are saved bucket rows',
      (tester) async {
    const saved = TmdbBridgeItem(
      id: 'br-saved',
      tmdbId: 200,
      mediaType: 'movie',
    );
    await tester.pumpWidget(harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(),
      savedRows: [saved],
    ));
    await tester.pumpAndSettle();
    expect(find.text('TMDB Saved (1)'), findsOneWidget);
  });

  testWidgets('hides TMDB Saved tile when bucket is empty', (tester) async {
    await tester.pumpWidget(harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(),
      savedRows: const [],
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('TMDB Saved'), findsNothing);
  });
}

class _StubConnectionNotifier extends TmdbAccountConnectionNotifier {
  _StubConnectionNotifier(this._initial);
  final TmdbConnectionState _initial;
  @override
  Future<TmdbConnectionState> build() async => _initial;
}

class _StubSettingsNotifier extends TmdbAccountSyncSettingsNotifier {
  _StubSettingsNotifier(this._initial);
  final TmdbAccountSyncSettings _initial;
  @override
  TmdbAccountSyncSettings build() => _initial;
}
