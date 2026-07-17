/// Widget tests for the rip health status pill and header stat cards.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  testWidgets('RipStatusPill renders label and detail', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: RipStatusPill(
          health: RipAlbumHealth.verified,
          detail: 'AR 16/16',
        ),
      ),
    ));
    expect(find.textContaining('VERIFIED'), findsOneWidget);
    expect(find.textContaining('AR 16/16'), findsOneWidget);
  });

  testWidgets('RipHealthStatCards shows four cards with counts',
      (tester) async {
    final repo = MockRipLibraryRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value(const []));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value(const {}));
    await tester.pumpWidget(ProviderScope(
      overrides: [ripLibraryRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: RipHealthStatCards()),
      ),
    ));
    await tester.pump();
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.text('ATTENTION'), findsOneWidget);
    expect(find.text('AR COVERAGE'), findsOneWidget);
    expect(find.text('TOTAL SIZE'), findsOneWidget);
  });

  testWidgets('RipCoverageStatCards shows the four coverage cards',
      (tester) async {
    final ripRepo = MockRipLibraryRepository();
    when(() => ripRepo.watchAll()).thenAnswer((_) => Stream.value(const []));
    when(() => ripRepo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value(const {}));
    final mediaRepo = MockMediaItemRepository();
    when(() => mediaRepo.watchAll(mediaType: MediaType.music))
        .thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        ripLibraryRepositoryProvider.overrideWithValue(ripRepo),
        mediaItemRepositoryProvider.overrideWithValue(mediaRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: RipCoverageStatCards()),
      ),
    ));
    await tester.pump();
    expect(find.text('RIPPED'), findsOneWidget);
    expect(find.text('TOTAL CDS'), findsOneWidget);
    expect(find.text('COVERAGE'), findsOneWidget);
    expect(find.text('ISSUES'), findsOneWidget);
  });
}
