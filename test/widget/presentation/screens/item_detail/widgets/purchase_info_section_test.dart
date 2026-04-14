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
    final baseItem = MediaItem(
      id: 'i1',
      barcode: '123',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: 'Test Film',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

    testWidgets('renders section label and fields', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseInfoSection(
            item: baseItem,
            onChanged: (_) {},
          ),
        ),
      ));

      expect(find.text('PURCHASE INFO'), findsOneWidget);
      expect(find.byKey(const Key('condition-dropdown')), findsOneWidget);
      expect(find.byKey(const Key('price-paid-field')), findsOneWidget);
      expect(find.byKey(const Key('retailer-field')), findsOneWidget);
      expect(find.byKey(const Key('acquired-at-tile')), findsOneWidget);
    });

    testWidgets('condition dropdown emits onChanged with selected value',
        (tester) async {
      MediaItem? captured;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseInfoSection(
            item: baseItem,
            onChanged: (m) => captured = m,
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('condition-dropdown')));
      await tester.pumpAndSettle();
      // "Good" may appear also in dropdown button content area after select,
      // so .last targets the menu entry.
      await tester.tap(find.text('Good').last);
      await tester.pumpAndSettle();

      expect(captured?.condition, ItemCondition.good);
    });

    testWidgets('price paid field parses to double', (tester) async {
      MediaItem? captured;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseInfoSection(
            item: baseItem,
            onChanged: (m) => captured = m,
          ),
        ),
      ));

      await tester.enterText(
          find.byKey(const Key('price-paid-field')), '12.50');
      await tester.pump();

      expect(captured?.pricePaid, 12.50);
    });

    testWidgets('empty price paid becomes null', (tester) async {
      MediaItem? captured;
      final itemWithPrice = baseItem.copyWith(pricePaid: 5.0);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseInfoSection(
            item: itemWithPrice,
            onChanged: (m) => captured = m,
          ),
        ),
      ));

      await tester.enterText(find.byKey(const Key('price-paid-field')), '');
      await tester.pump();

      expect(captured?.pricePaid, isNull);
    });

    testWidgets('retailer field emits onChanged', (tester) async {
      MediaItem? captured;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseInfoSection(
            item: baseItem,
            onChanged: (m) => captured = m,
          ),
        ),
      ));

      await tester.enterText(
          find.byKey(const Key('retailer-field')), 'HMV');
      await tester.pump();

      expect(captured?.retailer, 'HMV');
    });
  });
}
