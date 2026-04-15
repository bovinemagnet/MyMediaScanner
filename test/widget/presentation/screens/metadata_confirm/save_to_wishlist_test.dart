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

  testWidgets(
      'tapping Save to Wishlist saves item with ownershipStatus.wishlist',
      (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.save(any())).thenAnswer((_) async {});
    final useCase = SaveMediaItemUseCase(repository: repo);

    const metadata = MetadataResult(
      barcode: '9780141036144',
      barcodeType: 'isbn13',
      title: '1984',
      mediaType: MediaType.book,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EditableMetadataForm(
              initial: metadata,
              onSave: (edited) async {
                await useCase.execute(edited);
              },
              onSaveToWishlist: (edited) async {
                await useCase.execute(edited,
                    ownershipStatus: OwnershipStatus.wishlist);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Save to Wishlist'), findsOneWidget);
    await tester.ensureVisible(find.text('Save to Wishlist'));
    await tester.tap(find.text('Save to Wishlist'));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.save(captureAny())).captured;
    expect(captured, hasLength(1));
    final item = captured.single as MediaItem;
    expect(item.ownershipStatus, OwnershipStatus.wishlist);
    expect(item.acquiredAt, isNull);
    expect(item.title, '1984');
  });
}
