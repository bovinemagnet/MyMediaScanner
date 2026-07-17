/// Widget tests for the rip health filter chips row.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_filter_chips.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  testWidgets('chips render with counts and set the filter', (tester) async {
    final repo = MockRipLibraryRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value(const []));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value(const {}));

    await tester.pumpWidget(ProviderScope(
      overrides: [ripLibraryRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: Scaffold(body: RipHealthFilterChips()),
      ),
    ));
    await tester.pump();

    expect(find.textContaining('All'), findsOneWidget);
    expect(find.textContaining('Needs attention'), findsOneWidget);

    await tester.tap(find.textContaining('Mismatch'));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RipHealthFilterChips)),
    );
    expect(container.read(ripHealthFilterProvider), RipHealthFilter.mismatch);
  });
}
