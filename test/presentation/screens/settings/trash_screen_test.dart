// Widget tests for TrashScreen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/settings/trash_screen.dart';

class _MockRepo extends Mock implements IMediaItemRepository {}

MediaItem _item(String id, String title) => MediaItem(
      id: id,
      barcode: 'b$id',
      barcodeType: 'EAN-13',
      mediaType: MediaType.music,
      title: title,
      dateAdded: 1700000000,
      dateScanned: 1700000000,
      updatedAt: 1700000000,
      deleted: true,
    );

Widget _wrap(IMediaItemRepository repo) {
  return ProviderScope(
    overrides: [
      mediaItemRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: TrashScreen()),
  );
}

void main() {
  group('TrashScreen', () {
    testWidgets('shows empty state when no deleted items', (tester) async {
      final repo = _MockRepo();
      when(() => repo.watchDeleted()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nothing in trash'), findsOneWidget);
    });

    testWidgets('lists deleted items by title', (tester) async {
      final repo = _MockRepo();
      when(() => repo.watchDeleted()).thenAnswer(
        (_) => Stream.value([
          _item('a', 'Album One'),
          _item('b', 'Album Two'),
        ]),
      );

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Album One'), findsOneWidget);
      expect(find.text('Album Two'), findsOneWidget);
      expect(find.text('Restore'), findsNWidgets(2));
      expect(find.text('Delete forever'), findsNWidgets(2));
    });

    testWidgets('tapping Restore calls repository.restore', (tester) async {
      final repo = _MockRepo();
      when(() => repo.watchDeleted()).thenAnswer(
        (_) => Stream.value([_item('a', 'Album One')]),
      );
      when(() => repo.restore(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      verify(() => repo.restore('a')).called(1);
    });

    testWidgets('Delete forever prompts confirmation before hard-delete',
        (tester) async {
      final repo = _MockRepo();
      when(() => repo.watchDeleted()).thenAnswer(
        (_) => Stream.value([_item('z', 'Goodbye')]),
      );
      when(() => repo.hardDelete(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete forever'));
      await tester.pumpAndSettle();

      expect(find.text('Delete forever?'), findsOneWidget);
      expect(find.textContaining('Goodbye'), findsAtLeastNWidgets(1));

      verifyNever(() => repo.hardDelete(any()));

      await tester.tap(find.widgetWithText(FilledButton, 'Delete forever'));
      await tester.pumpAndSettle();

      verify(() => repo.hardDelete('z')).called(1);
    });
  });
}
