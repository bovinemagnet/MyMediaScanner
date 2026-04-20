/// Verifies that [EditableMetadataForm] honours the `primarySaveLabel` /
/// `primarySaveIcon` parameters the `MetadataConfirmScreen` passes based on
/// the scanner's `SaveTarget`. If these ever regress, the scan-time toggle
/// stops controlling the confirm-screen action and a wishlist scan would
/// quietly save to the collection (or vice versa).
library;

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

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

Widget _buildForm({
  required MetadataResult initial,
  required Future<void> Function(MetadataResult) onSave,
  required String primarySaveLabel,
  IconData primarySaveIcon = Icons.save,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: EditableMetadataForm(
          initial: initial,
          onSave: onSave,
          primarySaveLabel: primarySaveLabel,
          primarySaveIcon: primarySaveIcon,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
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

  const metadata = MetadataResult(
    barcode: '9780330258647',
    barcodeType: 'isbn13',
    title: 'Hitchhiker',
    mediaType: MediaType.book,
  );

  testWidgets('primary button shows "Save to Wishlist" + heart icon when '
      'label overridden for wishlist target', (tester) async {
    await tester.pumpWidget(_buildForm(
      initial: metadata,
      onSave: (_) async {},
      primarySaveLabel: 'Save to Wishlist',
      primarySaveIcon: Icons.favorite,
    ));

    expect(find.text('Save to Wishlist'), findsOneWidget);
    expect(find.text('Save to Collection'), findsNothing);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('default label renders as "Save to Collection"', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: EditableMetadataForm(
            initial: metadata,
            onSave: (_) async {},
          ),
        ),
      ),
    ));

    expect(find.text('Save to Collection'), findsOneWidget);
    expect(find.text('Save to Wishlist'), findsNothing);
  });

  testWidgets('pressing primary with wishlist label routes to wishlist save',
      (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.save(any())).thenAnswer((_) async {});
    final useCase = SaveMediaItemUseCase(repository: repo);

    await tester.pumpWidget(_buildForm(
      initial: metadata,
      // Caller (MetadataConfirmScreen) passes the right ownership when the
      // scan-time SaveTarget is wishlist — mirror that here.
      onSave: (edited) =>
          useCase.execute(edited, ownershipStatus: OwnershipStatus.wishlist),
      primarySaveLabel: 'Save to Wishlist',
      primarySaveIcon: Icons.favorite,
    ));

    await tester.ensureVisible(find.text('Save to Wishlist'));
    await tester.tap(find.text('Save to Wishlist'));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.save(captureAny())).captured;
    expect(captured, hasLength(1));
    final saved = captured.single as MediaItem;
    expect(saved.ownershipStatus, OwnershipStatus.wishlist);
    expect(saved.acquiredAt, isNull);
  });
}
