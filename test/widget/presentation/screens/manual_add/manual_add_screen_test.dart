import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/screens/manual_add/manual_add_screen.dart';

class _MockSaveUseCase extends Mock implements SaveMediaItemUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const MetadataResult(barcode: '', barcodeType: ''),
    );
    registerFallbackValue(OwnershipStatus.owned);
  });

  testWidgets('ManualAddScreen shows title field, media type, save button',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Item Manually'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
    expect(find.text('Media Type'), findsOneWidget);
    expect(find.text('Save to Collection'), findsOneWidget);
  });

  testWidgets('subtitle label adapts to the picked media type',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Default type is unknown → generic "Subtitle" label.
    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.text('Artist'), findsNothing);

    // Pick Music: subtitle relabels to Artist.
    await tester.tap(find.text('Media Type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Music').last);
    await tester.pumpAndSettle();
    expect(find.text('Artist'), findsOneWidget);

    // Switch to Book: subtitle relabels to Author.
    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book').last);
    await tester.pumpAndSettle();
    expect(find.text('Author'), findsOneWidget);

    // Switch to Game: subtitle relabels to Platform.
    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game').last);
    await tester.pumpAndSettle();
    expect(find.text('Platform'), findsOneWidget);
  });

  testWidgets('tapping Save to Collection calls SaveMediaItemUseCase.execute',
      (tester) async {
    final mock = _MockSaveUseCase();
    when(() => mock.execute(any(),
            ownershipStatus: any(named: 'ownershipStatus')))
        .thenAnswer(
      (_) async => const MediaItem(
        id: 'x',
        barcode: 'b',
        barcodeType: 'MANUAL',
        mediaType: MediaType.unknown,
        title: 'Dune',
        dateAdded: 0,
        dateScanned: 0,
        updatedAt: 0,
      ),
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ManualAddScreen()),
        GoRoute(
          path: '/collection',
          builder: (_, _) => const Scaffold(body: Text('collection')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveMediaItemUseCaseProvider.overrideWithValue(mock),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Title'), 'Dune');
    await tester.ensureVisible(find.text('Save to Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save to Collection'));
    await tester.pumpAndSettle();

    verify(() => mock.execute(
          any(),
          ownershipStatus: OwnershipStatus.owned,
        )).called(1);
  });
}
