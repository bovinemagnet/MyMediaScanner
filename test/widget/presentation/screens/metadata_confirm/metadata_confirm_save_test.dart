/// Widget tests for the "Save to Collection" path in [EditableMetadataForm].
///
/// The companion file `save_to_wishlist_test.dart` covers the wishlist button.
/// These tests focus on the primary save action, media-type forwarding,
/// in-flight disabled state, source-badge rendering, and error surfacing.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a standalone [EditableMetadataForm] wrapped in enough widget
/// infrastructure so that [ScaffoldMessenger] works and layout constraints
/// are satisfied.
Widget _buildForm({
  required MetadataResult initial,
  required Future<void> Function(MetadataResult) onSave,
  Future<void> Function(MetadataResult)? onSaveToWishlist,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: EditableMetadataForm(
          initial: initial,
          onSave: onSave,
          onSaveToWishlist: onSaveToWishlist,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockMediaItemRepository repo;

  setUpAll(() {
    // Provide a fallback value so mocktail can capture `any()` for MediaItem.
    registerFallbackValue(const MediaItem(
      id: '',
      barcode: '',
      barcodeType: '',
      mediaType: MediaType.unknown,
      title: '',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    ));
  });

  setUp(() {
    repo = MockMediaItemRepository();
    when(() => repo.save(any())).thenAnswer((_) async {});
    // Stubs needed by the duplicate-check inside the MetadataConfirmScreen
    // (not used here since we test EditableMetadataForm directly, but kept
    // for completeness if tests are ever extended to the full screen).
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any())).thenAnswer((_) async => []);
  });

  // -------------------------------------------------------------------------
  // Test 1 — edited title is forwarded to the repository
  // -------------------------------------------------------------------------

  testWidgets(
      'save to collection writes the edited metadata via the repository',
      (tester) async {
    final useCase = SaveMediaItemUseCase(repository: repo);

    const initial = MetadataResult(
      barcode: '5099969545023',
      barcodeType: 'ean13',
      title: 'Original',
      mediaType: MediaType.music,
    );

    await tester.pumpWidget(_buildForm(
      initial: initial,
      onSave: (edited) async => useCase.execute(edited),
    ));

    // Clear the pre-filled title and type the new one.
    final titleField = find.widgetWithText(TextField, 'Original');
    await tester.tap(titleField);
    await tester.pump();
    await tester.enterText(titleField, 'Edited');
    await tester.pump();

    await tester.ensureVisible(find.text('Save to Collection'));
    await tester.tap(find.text('Save to Collection'));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.save(captureAny())).captured;
    expect(captured, hasLength(1));
    final saved = captured.single as MediaItem;
    expect(saved.title, 'Edited');
    expect(saved.ownershipStatus, OwnershipStatus.owned);
  });

  // -------------------------------------------------------------------------
  // Test 2 — changed media type is forwarded
  // -------------------------------------------------------------------------

  testWidgets('save to collection forwards the current mediaType',
      (tester) async {
    final useCase = SaveMediaItemUseCase(repository: repo);

    const initial = MetadataResult(
      barcode: '5099969545023',
      barcodeType: 'ean13',
      title: 'Some Album',
      mediaType: MediaType.music,
    );

    await tester.pumpWidget(_buildForm(
      initial: initial,
      onSave: (edited) async => useCase.execute(edited),
    ));

    // Locate the DropdownButtonFormField and change the value to 'Film'.
    await tester.ensureVisible(find.byType(DropdownButtonFormField<MediaType>));
    await tester.tap(find.byType(DropdownButtonFormField<MediaType>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(MediaType.film.label).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save to Collection'));
    await tester.tap(find.text('Save to Collection'));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.save(captureAny())).captured;
    expect(captured, hasLength(1));
    final saved = captured.single as MediaItem;
    expect(saved.mediaType, MediaType.film);
  });

  // -------------------------------------------------------------------------
  // Test 3 — save button is disabled whilst a save is in flight
  // -------------------------------------------------------------------------

  testWidgets('save disabled while saving', (tester) async {
    final completer = Completer<void>();

    const initial = MetadataResult(
      barcode: '5099969545023',
      barcodeType: 'ean13',
      title: 'Slow Save',
      mediaType: MediaType.music,
    );

    await tester.pumpWidget(_buildForm(
      initial: initial,
      onSave: (_) => completer.future,
    ));

    await tester.ensureVisible(find.text('Save to Collection'));
    await tester.tap(find.text('Save to Collection'));
    // Pump once so setState(() => _saving = true) propagates.
    await tester.pump();

    // The GradientButton passes null to onPressed when disabled.
    // We verify this by confirming the text has changed to "Saving…".
    expect(find.text('Saving\u2026'), findsOneWidget);

    // Also confirm the save icon is gone (replaced by progress indicator).
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Resolve the future so the widget tree can settle cleanly.
    completer.complete();
    await tester.pumpAndSettle();
  });

  // -------------------------------------------------------------------------
  // Test 4 — source badge renders for known source APIs
  // -------------------------------------------------------------------------

  testWidgets('source badge renders when sourceApis is populated',
      (tester) async {
    const initial = MetadataResult(
      barcode: '5099969545023',
      barcodeType: 'ean13',
      title: 'Hounds of Love',
      mediaType: MediaType.music,
      sourceApis: ['musicbrainz'],
    );

    await tester.pumpWidget(_buildForm(
      initial: initial,
      onSave: (_) async {},
    ));

    expect(find.textContaining('MusicBrainz'), findsOneWidget);
    expect(find.textContaining('Source:'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 5 — repository errors surface via SnackBar
  // -------------------------------------------------------------------------

  testWidgets('save surfaces repository errors via a SnackBar', (tester) async {
    when(() => repo.save(any())).thenThrow(Exception('disk full'));

    final useCase = SaveMediaItemUseCase(repository: repo);

    const initial = MetadataResult(
      barcode: '5099969545023',
      barcodeType: 'ean13',
      title: 'Error Album',
      mediaType: MediaType.music,
    );

    await tester.pumpWidget(_buildForm(
      initial: initial,
      onSave: (edited) async => useCase.execute(edited),
    ));

    await tester.ensureVisible(find.text('Save to Collection'));
    await tester.tap(find.text('Save to Collection'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to save'), findsOneWidget);
  });
}
