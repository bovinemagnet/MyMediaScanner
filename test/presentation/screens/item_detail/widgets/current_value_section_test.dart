// Widget tests for CurrentValueSection.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/current_value_section.dart';

MediaItem _music({
  Map<String, dynamic>? meta,
  double? currentValue,
  int? currentValueAsOf,
  double? pricePaid,
}) {
  return MediaItem(
    id: 'item-1',
    barcode: 'b1',
    barcodeType: 'EAN-13',
    mediaType: MediaType.music,
    title: 'Album',
    extraMetadata: meta ?? const {},
    currentValue: currentValue,
    currentValueAsOf: currentValueAsOf,
    pricePaid: pricePaid,
    dateAdded: 1700000000,
    dateScanned: 1700000000,
    updatedAt: 1700000000,
  );
}

Widget _wrap(Widget child, {DiscogsApi? api}) {
  return ProviderScope(
    overrides: [
      discogsApiProvider.overrideWithValue(api),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('CurrentValueSection', () {
    testWidgets('shows "Not yet fetched" placeholder when no currentValue',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CurrentValueSection(
            item: _music(meta: const {'discogs_release_id': 1})),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CURRENT VALUE'), findsOneWidget);
      expect(find.text('Not yet fetched'), findsOneWidget);
    });

    testWidgets('renders formatted currentValue when present', (tester) async {
      await tester.pumpWidget(_wrap(
        CurrentValueSection(
          item: _music(
            meta: const {'discogs_release_id': 1},
            currentValue: 42.0,
            currentValueAsOf: 1700000000000,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('42'), findsOneWidget);
      expect(find.textContaining('Checked'), findsOneWidget);
    });

    testWidgets(
        'shows unsupported-media notice when item lacks Discogs release id',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CurrentValueSection(item: _music()),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('currently available for music items'),
          findsOneWidget);
    });

    testWidgets('renders value delta badge when both prices are known',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CurrentValueSection(
          item: _music(
            meta: const {'discogs_release_id': 1},
            pricePaid: 20.0,
            currentValue: 25.0,
            currentValueAsOf: 1700000000000,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('value-delta-badge')), findsOneWidget);
      expect(find.textContaining('+25.0%'), findsOneWidget);
    });

    testWidgets('omits delta badge when pricePaid is null', (tester) async {
      await tester.pumpWidget(_wrap(
        CurrentValueSection(
          item: _music(
            meta: const {'discogs_release_id': 1},
            currentValue: 25.0,
            currentValueAsOf: 1700000000000,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('value-delta-badge')), findsNothing);
    });

    testWidgets('shows Settings hint when Discogs is not configured',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CurrentValueSection(
            item: _music(meta: const {'discogs_release_id': 1})),
        // api is null by default in override above
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Add a Discogs token'), findsOneWidget);
    });
  });
}
