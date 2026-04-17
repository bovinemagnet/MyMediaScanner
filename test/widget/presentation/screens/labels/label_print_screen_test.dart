import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/label_sheet_preset.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_location_repository.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/location_provider.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/labels/label_print_screen.dart';

class MockLocationRepository extends Mock implements ILocationRepository {}

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

Location _location({String id = 'loc1', String name = 'Shelf A'}) => Location(
      id: id,
      name: name,
      updatedAt: 0,
    );

MediaItem _ownedItem({String id = 'item1', String title = 'Test Film'}) =>
    MediaItem(
      id: id,
      barcode: 'bc',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: title,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
      ownershipStatus: OwnershipStatus.owned,
    );

Widget _wrap({
  required ILocationRepository locationRepo,
  required IMediaItemRepository mediaRepo,
}) {
  return ProviderScope(
    overrides: [
      locationRepositoryProvider.overrideWithValue(locationRepo),
      mediaItemRepositoryProvider.overrideWithValue(mediaRepo),
    ],
    child: const MaterialApp(
      home: LabelPrintScreen(),
    ),
  );
}

void main() {
  late MockLocationRepository locationRepo;
  late MockMediaItemRepository mediaRepo;

  setUp(() {
    locationRepo = MockLocationRepository();
    mediaRepo = MockMediaItemRepository();
  });

  setUpAll(() {
    registerFallbackValue(_location());
    registerFallbackValue(_ownedItem());
    registerFallbackValue(OwnershipStatus.owned);
  });

  testWidgets('renders preset picker and selected-count label', (tester) async {
    when(() => locationRepo.watchAll()).thenAnswer(
      (_) => Stream.value([_location()]),
    );
    when(() => mediaRepo.watchByStatus(any())).thenAnswer(
      (_) => Stream.value([]),
    );

    await tester.pumpWidget(_wrap(
      locationRepo: locationRepo,
      mediaRepo: mediaRepo,
    ));
    await tester.pumpAndSettle();

    // The preset dropdown should be showing one of the built-in preset names.
    expect(
      find.text(LabelSheetPresets.a4_24.name),
      findsOneWidget,
    );

    // The "X selected" counter starts at zero.
    expect(find.text('0 selected'), findsOneWidget);
  });

  testWidgets('source toggle switches between Locations and Items',
      (tester) async {
    when(() => locationRepo.watchAll()).thenAnswer(
      (_) => Stream.value([_location(name: 'Living Room')]),
    );
    when(() => mediaRepo.watchByStatus(any())).thenAnswer(
      (_) => Stream.value([_ownedItem(title: 'Blade Runner')]),
    );

    await tester.pumpWidget(_wrap(
      locationRepo: locationRepo,
      mediaRepo: mediaRepo,
    ));
    await tester.pumpAndSettle();

    // Default source is Locations — should show the location name.
    expect(find.text('Living Room'), findsOneWidget);

    // Switch to Items.
    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();

    expect(find.text('Blade Runner'), findsOneWidget);
    expect(find.text('Living Room'), findsNothing);
  });

  // TODO: Testing the actual PDF-generation path requires calling
  // `Printing.layoutPdf`, which is a platform-channel call and cannot be
  // exercised in the headless Flutter test environment without a real
  // platform implementation.  Cover this with an integration test instead.
}
