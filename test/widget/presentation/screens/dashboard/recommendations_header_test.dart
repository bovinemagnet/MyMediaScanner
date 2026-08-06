// The recommendations section header puts a label and a "Suggestions for
// wishlist" button in one Row. On a phone-width screen the two together are
// wider than the card, which overflowed by ~10px on an iPhone 16 Pro.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/screens/dashboard/widgets/recommendations_section.dart';

MediaItem _item() => const MediaItem(
      id: 'r1',
      barcode: '1234567890123',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: 'Blade Runner 2049',
      dateAdded: 1700000000000,
      dateScanned: 1700000000001,
      updatedAt: 1700000000002,
      ownershipStatus: OwnershipStatus.owned,
    );

Widget _wrap(double scale) => ProviderScope(
      overrides: [
        topRecommendationsProvider.overrideWithValue(
          AsyncValue.data([
            Recommendation(
              item: _item(),
              score: 0.82,
              reasons: const [
                RecommendationReason(label: 'Highly rated', weight: 1),
              ],
            ),
          ]),
        ),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const Scaffold(body: RecommendationsSection()),
        ),
      ),
    );

void main() {
  // 402x874 is an iPhone 16 Pro; 390x844 covers the narrower iPhone 13/14/15
  // and 375x667 an iPhone SE, which is the tightest phone still supported.
  for (final size in const [Size(402, 874), Size(390, 844), Size(375, 667)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets(
        'header fits ${size.width.toInt()}dp at textScale $scale',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_wrap(scale));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
