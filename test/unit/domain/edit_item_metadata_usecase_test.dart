import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/edit_item_metadata_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late MockMediaItemRepository mockRepo;
  late EditItemMetadataUseCase useCase;

  const original = MediaItem(
    id: 'item-1',
    barcode: '5099902894225',
    barcodeType: 'ean13',
    mediaType: MediaType.music,
    title: 'Old Title',
    subtitle: 'Old Subtitle',
    description: 'Old description',
    year: 1999,
    publisher: 'Old Label',
    genres: ['Rock'],
    userRating: 4.5,
    userReview: 'Loved it',
    ownershipStatus: OwnershipStatus.owned,
    dateAdded: 1000,
    dateScanned: 1000,
    updatedAt: 1000,
  );

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = EditItemMetadataUseCase(repository: mockRepo);
    registerFallbackValue(original);
    when(() => mockRepo.update(any())).thenAnswer((_) async {});
  });

  group('toMetadataResult', () {
    test('maps an item into the form-initial shape', () {
      final result = EditItemMetadataUseCase.toMetadataResult(original);

      expect(result.barcode, original.barcode);
      expect(result.barcodeType, original.barcodeType);
      expect(result.mediaType, MediaType.music);
      expect(result.title, 'Old Title');
      expect(result.subtitle, 'Old Subtitle');
      expect(result.year, 1999);
      expect(result.publisher, 'Old Label');
      expect(result.genres, ['Rock']);
    });
  });

  group('execute', () {
    test('applies edited fields and persists via repository.update',
        () async {
      const edited = MetadataResult(
        barcode: '5099902894225',
        barcodeType: 'ean13',
        mediaType: MediaType.music,
        title: 'New Title',
        subtitle: 'New Subtitle',
        year: 2001,
        publisher: 'New Label',
        genres: ['Rock', 'Indie'],
      );

      final updated = await useCase.execute(original, edited);

      expect(updated.title, 'New Title');
      expect(updated.subtitle, 'New Subtitle');
      expect(updated.year, 2001);
      expect(updated.publisher, 'New Label');
      expect(updated.genres, ['Rock', 'Indie']);
      verify(() => mockRepo.update(updated)).called(1);
    });

    test('user edits are authoritative — a cleared field clears the item',
        () async {
      // The form omits subtitle/description → they come through null and
      // must clear the stored values (unlike refresh-from-API merging).
      const edited = MetadataResult(
        barcode: '5099902894225',
        barcodeType: 'ean13',
        mediaType: MediaType.music,
        title: 'New Title',
      );

      final updated = await useCase.execute(original, edited);

      expect(updated.subtitle, isNull);
      expect(updated.description, isNull);
      expect(updated.year, isNull);
    });

    test('preserves identity and user data, bumps updatedAt', () async {
      const edited = MetadataResult(
        barcode: '5099902894225',
        barcodeType: 'ean13',
        mediaType: MediaType.music,
        title: 'New Title',
      );

      final updated = await useCase.execute(original, edited);

      expect(updated.id, 'item-1');
      expect(updated.barcode, original.barcode);
      expect(updated.userRating, 4.5);
      expect(updated.userReview, 'Loved it');
      expect(updated.ownershipStatus, OwnershipStatus.owned);
      expect(updated.dateAdded, 1000);
      expect(updated.updatedAt, greaterThan(original.updatedAt));
    });

    test('falls back to the original title when the edit blanks it',
        () async {
      const edited = MetadataResult(
        barcode: '5099902894225',
        barcodeType: 'ean13',
        mediaType: MediaType.music,
      );

      final updated = await useCase.execute(original, edited);

      expect(updated.title, 'Old Title');
    });
  });
}
