import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/widgets/duplicate_check_helper.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _item(String id) => MediaItem(
      id: id,
      barcode: 'bc',
      barcodeType: 'ean13',
      mediaType: MediaType.book,
      title: 'Existing',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

Future<bool> _runHelper(
    WidgetTester tester, IMediaItemRepository repo) async {
  late bool result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (ctx) => Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            result = await confirmSaveOrSkipIfDuplicate(
              context: ctx,
              repository: repo,
              barcode: '123',
              title: 'Any',
              year: 2020,
            );
          },
          child: const Text('go'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('returns true when no duplicate — no dialog shown',
      (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => []);
    final result = await _runHelper(tester, repo);
    expect(result, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('duplicate + cancel returns false', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => [_item('a')]);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => []);
    late bool result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              result = await confirmSaveOrSkipIfDuplicate(
                context: ctx,
                repository: repo,
                barcode: '123',
                title: 'Existing',
              );
            },
            child: const Text('go'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('duplicate + save anyway returns true', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => [_item('a')]);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => []);
    late bool result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              result = await confirmSaveOrSkipIfDuplicate(
                context: ctx,
                repository: repo,
                barcode: '123',
                title: 'Existing',
              );
            },
            child: const Text('go'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Different edition'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
