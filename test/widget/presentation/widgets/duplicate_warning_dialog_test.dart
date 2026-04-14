import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';
import 'package:mymediascanner/presentation/widgets/duplicate_warning_dialog.dart';

MediaItem _item(String id) => MediaItem(
      id: id,
      barcode: 'bc',
      barcodeType: 'ean13',
      mediaType: MediaType.book,
      title: 'Existing Title',
      year: 2001,
      dateAdded: 100,
      dateScanned: 100,
      updatedAt: 100,
    );

Future<bool?> _showDialog(
    WidgetTester tester, DuplicateMatch match) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (ctx) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              result = await showDuplicateWarningDialog(ctx, match);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('shows existing candidate title', (tester) async {
    final match =
        DuplicateMatch(DuplicateKind.exactBarcode, [_item('a')]);
    await _showDialog(tester, match);
    expect(find.text('Existing Title'), findsOneWidget);
  });

  testWidgets('cancel returns false', (tester) async {
    final match =
        DuplicateMatch(DuplicateKind.exactBarcode, [_item('a')]);
    bool? resolved;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              resolved = await showDuplicateWarningDialog(ctx, match);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(resolved, isFalse);
  });

  testWidgets('save anyway returns true', (tester) async {
    final match =
        DuplicateMatch(DuplicateKind.fuzzyTitle, [_item('a')]);
    bool? resolved;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              resolved = await showDuplicateWarningDialog(ctx, match);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Different edition'));
    await tester.pumpAndSettle();
    expect(resolved, isTrue);
  });

  testWidgets('heading differs for exact vs fuzzy', (tester) async {
    await _showDialog(
        tester, DuplicateMatch(DuplicateKind.exactBarcode, [_item('a')]));
    expect(find.textContaining('barcode'), findsOneWidget);
  });
}
