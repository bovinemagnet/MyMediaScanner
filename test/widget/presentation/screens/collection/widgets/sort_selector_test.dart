// Widget tests for SortSelector.
//
// Regression cover for the unbounded-width layout crash: the selector is
// mounted in a mobile AppBar `actions:` slot, which lays its children out
// with unbounded width. A `Flexible`/`isExpanded` dropdown crashes there
// ("RenderFlex children have non-zero flex but incoming width constraints
// are unbounded"), so the dropdown must carry its own bounded width.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/sort_selector.dart';

void main() {
  group('SortSelector', () {
    testWidgets('lays out in an AppBar actions slot without overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: _ActionsBar(),
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );

      // AppBar `actions` hand children unbounded width; the dropdown must not
      // throw a RenderFlex unbounded-constraints error during layout.
      expect(tester.takeException(), isNull);
      expect(find.byType(SortSelector), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });
  });
}

class _ActionsBar extends StatelessWidget implements PreferredSizeWidget {
  const _ActionsBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Library'),
      actions: const [SortSelector()],
    );
  }
}
