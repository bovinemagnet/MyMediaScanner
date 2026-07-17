/// Widget tests for [RipCoverThumb].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_cover_thumb.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('shows the disc placeholder when coverPath is null',
      (tester) async {
    await pump(tester, const RipCoverThumb(coverPath: null));

    expect(find.byIcon(Icons.album), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the disc placeholder when the file does not exist',
      (tester) async {
    await pump(
      tester,
      const RipCoverThumb(coverPath: '/nonexistent/cover.jpg'),
    );
    // Image.file errors asynchronously via real file IO, which the fake
    // async test clock does not advance on its own; runAsync lets the
    // real Future settle before the errorBuilder swaps in the icon.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.byIcon(Icons.album), findsOneWidget);
  });

  testWidgets('respects the requested size', (tester) async {
    await pump(tester, const RipCoverThumb(coverPath: null, size: 120));

    final box = tester.getSize(find.byType(RipCoverThumb));
    expect(box.width, 120);
    expect(box.height, 120);
  });
}
