import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';

void main() {
  group('StarRatingWidget', () {
    testWidgets('displays 5 stars', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(rating: 3.0, onChanged: (_) {}),
        ),
      ));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('tapping star calls onChanged', (tester) async {
      double? tappedRating;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(
              rating: 0, onChanged: (r) => tappedRating = r),
        ),
      ));
      await tester.tap(find.byIcon(Icons.star_border).first);
      expect(tappedRating, 1.0);
    });
  });
}
