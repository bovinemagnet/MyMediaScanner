import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/screens/batch/batch_placeholder_screen.dart';
import 'package:mymediascanner/presentation/screens/batch/batch_history_screen.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_screen.dart';
import 'package:mymediascanner/presentation/screens/collection/statistics_screen.dart';
import 'package:mymediascanner/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mymediascanner/presentation/screens/disambiguation/disambiguation_screen.dart';
import 'package:mymediascanner/presentation/screens/import/import_screen.dart';
import 'package:mymediascanner/presentation/screens/item_detail/item_detail_screen.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/metadata_confirm_screen.dart';
import 'package:mymediascanner/presentation/screens/rips/rips_screen.dart';
import 'package:mymediascanner/presentation/screens/scanner/scanner_screen.dart';
import 'package:mymediascanner/presentation/screens/settings/settings_screen.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/postgres_config_form.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_log_viewer.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelf_detail_screen.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelves_screen.dart';
import 'package:mymediascanner/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:mymediascanner/presentation/screens/locations/location_browser_screen.dart';
import 'package:mymediascanner/presentation/screens/series/series_list_screen.dart';
import 'package:mymediascanner/presentation/screens/series/series_detail_screen.dart';
import 'package:mymediascanner/presentation/screens/about/about_screen.dart';
import 'package:mymediascanner/presentation/screens/borrowers/borrowers_screen.dart';
import 'package:mymediascanner/presentation/screens/borrowers/borrower_detail_screen.dart';
import 'package:mymediascanner/presentation/widgets/app_scaffold.dart';

/// Fade + slide up transition for detail/modal routes.
CustomTransitionPage<void> _fadeSlideTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      final slideUp = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(fadeIn);
      return FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(position: slideUp, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Route branches (indices must match sidebar/bottom-nav mapping in
/// [AppScaffold]):
///
///   0 = Dashboard      (desktop sidebar + mobile bottom nav)
///   1 = Collection     (desktop sidebar + mobile bottom nav as "Library")
///   2 = Scanner        (mobile bottom nav only)
///   3 = Shelves        (desktop sidebar only)
///   4 = Batch Editor   (desktop sidebar only)
///   5 = Insights       (desktop sidebar + mobile bottom nav)
///   6 = Settings       (desktop sidebar only)
///   7 = Rips           (desktop sidebar only)
///   8 = Wishlist       (desktop sidebar only)
final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        // 0 — Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // 1 — Collection / Library
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/collection',
              builder: (context, state) => const CollectionScreen(),
              routes: [
                GoRoute(
                  path: 'statistics',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fadeSlideTransition(state, const StatisticsScreen()),
                ),
                GoRoute(
                  path: 'item/:id',
                  builder: (context, state) => ItemDetailScreen(
                    itemId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => Center(
                        child: Text(
                            'Edit item ${state.pathParameters['id']}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // 2 — Scanner
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scan',
              builder: (context, state) => const ScannerScreen(),
              routes: [
                GoRoute(
                  path: 'confirm',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeSlideTransition(
                      state, const MetadataConfirmScreen()),
                ),
                GoRoute(
                  path: 'disambiguate',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeSlideTransition(
                      state, const DisambiguationScreen()),
                ),
              ],
            ),
          ],
        ),

        // 3 — Shelves
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shelves',
              builder: (context, state) => const ShelvesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ShelfDetailScreen(
                    shelfId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // 4 — Batch Editor
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/batch',
              builder: (context, state) =>
                  const BatchPlaceholderScreen(),
              routes: [
                GoRoute(
                  path: 'history',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeSlideTransition(
                      state, const BatchHistoryScreen()),
                ),
              ],
            ),
          ],
        ),

        // 5 — Insights (Statistics)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),

        // 6 — Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'postgres',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeSlideTransition(
                      state, const PostgresConfigForm()),
                ),
                GoRoute(
                  path: 'sync-log',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fadeSlideTransition(state, const SyncLogViewer()),
                ),
                GoRoute(
                  path: 'about',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fadeSlideTransition(state, const AboutScreen()),
                ),
                GoRoute(
                  path: 'borrowers',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fadeSlideTransition(state, const BorrowersScreen()),
                ),
                GoRoute(
                  path: 'import',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fadeSlideTransition(state, const ImportScreen()),
                ),
              ],
            ),
          ],
        ),

        // 7 — Rips
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rips',
              builder: (context, state) => const RipsScreen(),
            ),
          ],
        ),

        // 8 — Wishlist (desktop sidebar only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wishlist',
              builder: (context, state) => const WishlistScreen(),
            ),
          ],
        ),

        // 9 — Locations (desktop sidebar only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/locations',
              builder: (context, state) => const LocationBrowserScreen(),
            ),
          ],
        ),

        // 10 — Series (desktop sidebar only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/series',
              builder: (context, state) => const SeriesListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => SeriesDetailScreen(
                    seriesId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/borrowers/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _fadeSlideTransition(
        state,
        BorrowerDetailScreen(
          borrowerId: state.pathParameters['id']!,
        ),
      ),
    ),
  ],
);
