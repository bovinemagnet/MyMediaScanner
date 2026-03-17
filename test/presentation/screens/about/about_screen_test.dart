import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/presentation/screens/about/about_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const MaterialApp(
      home: AboutScreen(),
    );
  }

  testWidgets('renders app name', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
  });

  testWidgets('renders author name', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Paul Snow'), findsOneWidget);
  });

  testWidgets('renders GitHub repository tile', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('GitHub Repository'), findsOneWidget);
    expect(find.text(AppConstants.githubUrl), findsOneWidget);
  });

  testWidgets('GitHub tile is tappable', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final githubTile = find.widgetWithText(ListTile, 'GitHub Repository');
    expect(githubTile, findsOneWidget);

    // Verify the tile has an onTap handler (i.e. is tappable)
    final listTile = tester.widget<ListTile>(githubTile);
    expect(listTile.onTap, isNotNull);
  });

  testWidgets('renders features section', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('renders open-source licences tile', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Open-source licences'),
      100,
    );

    expect(find.text('Open-source licences'), findsOneWidget);
  });

  testWidgets('renders built with Flutter tile', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Built with Flutter'),
      100,
    );

    expect(find.text('Built with Flutter'), findsOneWidget);
    expect(find.byType(FlutterLogo), findsOneWidget);
  });
}
