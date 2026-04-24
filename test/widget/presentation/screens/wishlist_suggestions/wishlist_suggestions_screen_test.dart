import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/screens/wishlist_suggestions/wishlist_suggestions_screen.dart';

class MockSaveMediaItemUseCase extends Mock implements SaveMediaItemUseCase {}

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

WishlistSuggestion _suggestion({
  String id = 'tt001',
  String title = 'Interstellar',
  int? year = 2014,
}) =>
    WishlistSuggestion(
      externalId: id,
      title: title,
      year: year,
      source: 'tmdb',
      score: 0.9,
      reasons: const [
        RecommendationReason(label: 'Sci-Fi', weight: 1.0),
      ],
    );

MediaItem _mediaItem() => const MediaItem(
      id: 'mi1',
      barcode: 'tt001',
      barcodeType: 'TMDB',
      mediaType: MediaType.film,
      title: 'Interstellar',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
      ownershipStatus: OwnershipStatus.wishlist,
    );

Widget _wrap({
  required List<WishlistSuggestion> suggestions,
  required SaveMediaItemUseCase saveUseCase,
}) {
  return ProviderScope(
    overrides: [
      // Override the FutureProvider to return a fixed list synchronously.
      wishlistSuggestionsProvider.overrideWith(
        (ref) async => suggestions,
      ),
      saveMediaItemUseCaseProvider.overrideWithValue(saveUseCase),
    ],
    child: const MaterialApp(
      home: WishlistSuggestionsScreen(),
    ),
  );
}

void main() {
  late MockSaveMediaItemUseCase saveUseCase;

  setUp(() {
    saveUseCase = MockSaveMediaItemUseCase();
  });

  setUpAll(() {
    registerFallbackValue(
      const MetadataResult(
        barcode: 'tt001',
        barcodeType: 'TMDB',
        mediaType: MediaType.film,
        title: 'Interstellar',
        sourceApis: ['tmdb'],
      ),
    );
    registerFallbackValue(OwnershipStatus.owned);
  });

  testWidgets('renders suggestion cards from the provider', (tester) async {
    await tester.pumpWidget(_wrap(
      suggestions: [
        _suggestion(id: 'tt001', title: 'Interstellar', year: 2014),
        _suggestion(id: 'tt002', title: 'Arrival', year: 2016),
      ],
      saveUseCase: saveUseCase,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('Arrival'), findsOneWidget);
    // Reason chip should appear for each suggestion.
    expect(find.text('Sci-Fi'), findsAtLeastNWidgets(1));
  });

  testWidgets('tapping Wishlist button calls save use case', (tester) async {
    when(() => saveUseCase.execute(
          any(),
          ownershipStatus: any(named: 'ownershipStatus'),
        )).thenAnswer((_) async => _mediaItem());

    await tester.pumpWidget(_wrap(
      suggestions: [_suggestion(id: 'tt001', title: 'Interstellar')],
      saveUseCase: saveUseCase,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();

    final captured = verify(() => saveUseCase.execute(
          captureAny(),
          ownershipStatus: captureAny(named: 'ownershipStatus'),
        )).captured;

    final savedMetadata = captured[0] as MetadataResult;
    expect(savedMetadata.title, 'Interstellar');

    final status = captured[1] as OwnershipStatus;
    expect(status, OwnershipStatus.wishlist);
  });
}
