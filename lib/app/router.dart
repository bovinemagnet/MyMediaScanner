import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_screen.dart';
import 'package:mymediascanner/presentation/screens/item_detail/item_detail_screen.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/metadata_confirm_screen.dart';
import 'package:mymediascanner/presentation/screens/scanner/scanner_screen.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelves_screen.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelf_detail_screen.dart';
import 'package:mymediascanner/presentation/screens/settings/settings_screen.dart';
import 'package:mymediascanner/presentation/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CollectionScreen(),
              routes: [
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scan',
              builder: (context, state) => const ScannerScreen(),
              routes: [
                GoRoute(
                  path: 'confirm',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const MetadataConfirmScreen(),
                ),
              ],
            ),
          ],
        ),
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'postgres',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const Center(child: Text('Postgres config')),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
