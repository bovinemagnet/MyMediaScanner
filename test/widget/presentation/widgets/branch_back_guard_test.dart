import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/widgets/branch_back_guard.dart';

/// Drives a system back press through a real `StatefulShellRoute` and
/// asserts where it lands.
///
/// Read this before trusting it: `handlePopRoute` simulates the *legacy*
/// pop channel, and on that path a `PopScope` is consulted wherever it sits
/// — including around the shell. These tests were checked against the
/// earlier shell-level placement and passed, so **they cannot tell the two
/// placements apart**. On Android 15+, where the platform drives back
/// through `OnBackInvokedCallback`, only the in-branch guard is consulted
/// and the shell-level one was never called at all.
///
/// So: these cover the routing behaviour (which branch back lands on, that
/// the root still exits, that nested routes pop first) on the legacy path.
/// They do not prove the guard is reached on a modern device — that needs
/// checking on a real Android 15+ device or emulator.
void main() {
  /// Mirrors the real router's shape closely enough to exercise dispatch:
  /// an indexed-stack shell whose branches each root their own navigator,
  /// with branch 1 owning a nested route.
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              Scaffold(body: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) =>
                      const BranchBackGuard(child: Text('dashboard')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/collection',
                  builder: (_, _) =>
                      const BranchBackGuard(child: Text('collection')),
                  routes: [
                    GoRoute(
                      path: 'item',
                      builder: (_, _) => const Scaffold(
                        body: Text('item detail'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Branch order has to match the real router's, since the guard
            // resolves its target from the shell's current index.
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/scan',
                  builder: (_, _) =>
                      const BranchBackGuard(child: Text('scanner')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/shelves',
                  builder: (_, _) =>
                      const BranchBackGuard(child: Text('shelves')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pumpApp(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  /// Returns true when the app handled the pop itself, false when it let the
  /// press fall through — which on Android closes the app.
  Future<bool> pressSystemBack(WidgetTester tester) async {
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    return handled;
  }

  testWidgets(
    'back from a non-root branch returns to its entry branch, not the OS',
    (tester) async {
      final router = buildRouter();
      await pumpApp(tester, router);

      router.go('/shelves');
      await tester.pumpAndSettle();
      expect(find.text('shelves'), findsOneWidget);

      final handled = await pressSystemBack(tester);

      expect(handled, isTrue,
          reason: 'the press must be consumed, or Android closes the app');
      expect(find.text('collection'), findsOneWidget,
          reason: 'shelves is entered from the library');
      expect(find.text('shelves'), findsNothing);
    },
  );

  testWidgets(
    'back from the dashboard falls through so the OS can close the app',
    (tester) async {
      final router = buildRouter();
      await pumpApp(tester, router);
      expect(find.text('dashboard'), findsOneWidget);

      final handled = await pressSystemBack(tester);

      expect(handled, isFalse,
          reason: 'the dashboard is the root — back should exit');
      expect(find.text('dashboard'), findsOneWidget);
    },
  );

  testWidgets(
    'back from a nested route pops it without leaving the branch',
    (tester) async {
      final router = buildRouter();
      await pumpApp(tester, router);

      router.go('/collection/item');
      await tester.pumpAndSettle();
      expect(find.text('item detail'), findsOneWidget);

      final handled = await pressSystemBack(tester);

      expect(handled, isTrue);
      expect(find.text('collection'), findsOneWidget,
          reason: 'the nested route pops back to its own branch root');
      expect(find.text('item detail'), findsNothing);
    },
  );
}
