// Widget tests for PurchaseInfoSection.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/purchase_info_section.dart';

void main() {
  group('PurchaseInfoSection', () {
    const baseItem = MediaItem(
      id: 'i1',
      barcode: '123',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: 'Test Film',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

    Widget harness(MediaItem item, ValueChanged<MediaItem> onChanged) {
      return MaterialApp(
        home: Scaffold(
          // An external focus target we can tap to blur the text fields.
          body: Column(
            children: [
              PurchaseInfoSection(item: item, onChanged: onChanged),
              const TextField(key: Key('outside-sink')),
            ],
          ),
        ),
      );
    }

    testWidgets('renders section label and fields', (tester) async {
      await tester.pumpWidget(harness(baseItem, (_) {}));

      expect(find.text('PURCHASE INFO'), findsOneWidget);
      expect(find.byKey(const Key('condition-dropdown')), findsOneWidget);
      expect(find.byKey(const Key('price-paid-field')), findsOneWidget);
      expect(find.byKey(const Key('retailer-field')), findsOneWidget);
      expect(find.byKey(const Key('acquired-at-tile')), findsOneWidget);
    });

    testWidgets('condition dropdown emits onChanged with selected value',
        (tester) async {
      MediaItem? captured;
      await tester.pumpWidget(harness(baseItem, (m) => captured = m));

      await tester.tap(find.byKey(const Key('condition-dropdown')));
      await tester.pumpAndSettle();
      // "Good" may appear also in dropdown button content area after select,
      // so .last targets the menu entry.
      await tester.tap(find.text('Good').last);
      await tester.pumpAndSettle();

      expect(captured?.condition, ItemCondition.good);
    });

    testWidgets('condition dropdown back to Unspecified emits null',
        (tester) async {
      MediaItem? captured;
      final itemWithCondition =
          baseItem.copyWith(condition: ItemCondition.good);
      await tester.pumpWidget(harness(itemWithCondition, (m) => captured = m));

      await tester.tap(find.byKey(const Key('condition-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unspecified').last);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.condition, isNull);
    });

    testWidgets('price field does NOT emit onChanged per keystroke',
        (tester) async {
      final emissions = <MediaItem>[];
      await tester.pumpWidget(harness(baseItem, emissions.add));

      await tester.enterText(
          find.byKey(const Key('price-paid-field')), '12.50');
      await tester.pump();

      // No blur yet — nothing should have been persisted.
      expect(emissions, isEmpty);
    });

    testWidgets('price field commits parsed value on blur', (tester) async {
      MediaItem? captured;
      await tester.pumpWidget(harness(baseItem, (m) => captured = m));

      await tester.enterText(
          find.byKey(const Key('price-paid-field')), '12.50');
      await tester.tap(find.byKey(const Key('outside-sink')));
      await tester.pump();

      expect(captured?.pricePaid, 12.50);
    });

    testWidgets('price field ignores unparseable "1.2.3" on blur',
        (tester) async {
      final emissions = <MediaItem>[];
      final itemWithPrice = baseItem.copyWith(pricePaid: 5.0);
      await tester.pumpWidget(harness(itemWithPrice, emissions.add));

      await tester.enterText(
          find.byKey(const Key('price-paid-field')), '1.2.3');
      await tester.tap(find.byKey(const Key('outside-sink')));
      await tester.pump();

      // Unparseable — must not emit a null-price change that wipes the value.
      expect(emissions, isEmpty);
    });

    testWidgets('empty price field commits null on blur', (tester) async {
      MediaItem? captured;
      final itemWithPrice = baseItem.copyWith(pricePaid: 5.0);
      await tester.pumpWidget(harness(itemWithPrice, (m) => captured = m));

      await tester.enterText(find.byKey(const Key('price-paid-field')), '');
      await tester.tap(find.byKey(const Key('outside-sink')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.pricePaid, isNull);
    });

    testWidgets('retailer field does NOT emit onChanged per keystroke',
        (tester) async {
      final emissions = <MediaItem>[];
      await tester.pumpWidget(harness(baseItem, emissions.add));

      await tester.enterText(find.byKey(const Key('retailer-field')), 'HMV');
      await tester.pump();

      expect(emissions, isEmpty);
    });

    testWidgets('retailer field commits value on blur', (tester) async {
      MediaItem? captured;
      await tester.pumpWidget(harness(baseItem, (m) => captured = m));

      await tester.enterText(find.byKey(const Key('retailer-field')), 'HMV');
      await tester.tap(find.byKey(const Key('outside-sink')));
      await tester.pump();

      expect(captured?.retailer, 'HMV');
    });
  });
}
