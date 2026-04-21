import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/screens/manual_add/manual_add_screen.dart';

class _MockSaveUseCase extends Mock implements SaveMediaItemUseCase {}

class _MockMetadataRepository extends Mock implements IMetadataRepository {}

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
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    await tester.tap(find.text('Save to Collection'));
    await tester.pumpAndSettle();

    verify(() => mock.execute(
          any(),
          ownershipStatus: OwnershipStatus.owned,
        )).called(1);
  });

  testWidgets(
      'Search online populates form fields from single match',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _MockMetadataRepository();
    when(() => repo.searchByTitle(any(), any(), any(),
            typeHint: any(named: 'typeHint')))
        .thenAnswer(
      (_) async => const ScanResult.single(
        metadata: MetadataResult(
          barcode: 'MANUAL-x',
          barcodeType: 'MANUAL',
          mediaType: MediaType.music,
          title: 'OK Computer',
          subtitle: 'Radiohead',
          year: 1997,
          publisher: 'Parlophone',
          format: 'CD',
          sourceApis: ['musicbrainz'],
        ),
        isDuplicate: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Title'), 'OK Computer');
    await tester.tap(find.text('Search online'));
    await tester.pumpAndSettle();

    // The returned metadata should have populated the form.
    expect(find.widgetWithText(TextField, 'Parlophone'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1997'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Radiohead'), findsOneWidget);
    expect(find.text('Source: MusicBrainz'), findsOneWidget);
  });

  testWidgets('Search online snackbars when no match is found',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _MockMetadataRepository();
    when(() => repo.searchByTitle(any(), any(), any(),
            typeHint: any(named: 'typeHint')))
        .thenAnswer(
      (_) async => const ScanResult.notFound(
        barcode: 'MANUAL-x',
        barcodeType: 'MANUAL',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Title'), 'Zzzzzz');
    await tester.tap(find.text('Search online'));
    await tester.pumpAndSettle();

    expect(find.text('No matches found online'), findsOneWidget);
  });

  testWidgets('Format chip fills the Format field for Film',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Pick Film.
    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Film').last);
    await tester.pumpAndSettle();

    // Format chips should appear.
    expect(find.widgetWithText(ActionChip, 'DVD'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Blu-ray'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '4K Blu-ray'), findsOneWidget);

    // Tapping a chip fills the Format field.
    await tester.tap(find.widgetWithText(ActionChip, '4K Blu-ray'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '4K Blu-ray'), findsOneWidget);
  });

  testWidgets('Platform chip fills the Platform field for Game',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ActionChip, 'PS5'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'PS5'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'PS5'), findsOneWidget);
  });

  testWidgets('Resolution chips appear for Film + DVD and Film + Blu-ray',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ManualAddScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Pick Film.
    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Film').last);
    await tester.pumpAndSettle();

    // No resolution chips until a format is chosen.
    expect(find.widgetWithText(ChoiceChip, '480p'), findsNothing);

    // DVD → 480p / 576p.
    await tester.tap(find.widgetWithText(ActionChip, 'DVD'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, '480p'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '576p'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '720p'), findsNothing);

    // Switch to Blu-ray → 720p / 1080p.
    await tester.tap(find.widgetWithText(ActionChip, 'Blu-ray'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, '720p'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '1080p'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '480p'), findsNothing);

    // Switch to 4K Blu-ray → no resolution chips (resolution implied).
    await tester.tap(find.widgetWithText(ActionChip, '4K Blu-ray'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, '720p'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '1080p'), findsNothing);
  });

  testWidgets(
      'Resolution selection is saved into extraMetadata.resolution',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mock = _MockSaveUseCase();
    MetadataResult? captured;
    when(() => mock.execute(any(),
            ownershipStatus: any(named: 'ownershipStatus')))
        .thenAnswer((inv) async {
      captured = inv.positionalArguments.first as MetadataResult;
      return const MediaItem(
        id: 'x',
        barcode: 'b',
        barcodeType: 'MANUAL',
        mediaType: MediaType.film,
        title: 'Test',
        dateAdded: 0,
        dateScanned: 0,
        updatedAt: 0,
      );
    });

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

    // Pick Film → tap Blu-ray → tap 1080p → Save.
    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Film').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Blu-ray'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '1080p'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save to Collection'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.extraMetadata['resolution'], '1080p');
    expect(captured!.format, 'Blu-ray');
  });
}
