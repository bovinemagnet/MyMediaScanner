import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );
    // Just verify the app widget tree builds
    expect(find.byType(App), findsOneWidget);
  });
}
