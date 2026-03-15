import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';

MediaItem _createItem({
  MediaType mediaType = MediaType.film,
  String title = 'Test Title',
  String? coverUrl,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return MediaItem(
    id: '1',
    barcode: '1234567890123',
    barcodeType: 'ean13',
    mediaType: mediaType,
    title: title,
    coverUrl: coverUrl,
    dateAdded: now,
    dateScanned: now,
    updatedAt: now,
  );
}

void main() {
  group('MediaItemCard', () {
    testWidgets('renders title and media type badge', (tester) async {
      final item = _createItem(
        title: 'Fight Club',
        mediaType: MediaType.film,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 200,
            child: MediaItemCard(item: item, onTap: () {}),
          ),
        ),
      ));

      expect(find.text('Fight Club'), findsOneWidget);
      expect(find.text('Film'), findsOneWidget);
    });

    testWidgets('renders Lent badge when isLent is true', (tester) async {
      final item = _createItem();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 200,
            child: MediaItemCard(item: item, onTap: () {}, isLent: true),
          ),
        ),
      ));

      expect(find.text('Lent'), findsOneWidget);
    });

    testWidgets('does not render Lent badge when isLent is false',
        (tester) async {
      final item = _createItem();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 200,
            child: MediaItemCard(item: item, onTap: () {}, isLent: false),
          ),
        ),
      ));

      expect(find.text('Lent'), findsNothing);
    });

    testWidgets('renders Ripped icon when isRipped is true', (tester) async {
      final item = _createItem();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 200,
            child: MediaItemCard(item: item, onTap: () {}, isRipped: true),
          ),
        ),
      ));

      expect(find.byIcon(Icons.album), findsOneWidget);
    });

    testWidgets('does not render Ripped icon when isRipped is false',
        (tester) async {
      final item = _createItem();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 200,
            child: MediaItemCard(item: item, onTap: () {}, isRipped: false),
          ),
        ),
      ));

      // The album icon should not be present as a ripped indicator
      // (it may appear elsewhere, so we check specifically in the Positioned area)
      final rippedIcons = find.byIcon(Icons.album);
      expect(rippedIcons, findsNothing);
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;
      final item = _createItem();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 200,
            child: MediaItemCard(item: item, onTap: () => tapped = true),
          ),
        ),
      ));

      await tester.tap(find.byType(MediaItemCard));
      expect(tapped, isTrue);
    });
  });
}
