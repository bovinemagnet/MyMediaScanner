import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _item(String id,
        {String title = 'Title', int? year, String barcode = 'bc'}) =>
    MediaItem(
      id: id,
      barcode: barcode,
      barcodeType: 'ean13',
      mediaType: MediaType.book,
      title: title,
      year: year,
      dateAdded: 100,
      dateScanned: 100,
      updatedAt: 100,
    );

void main() {
  late MockMediaItemRepository repo;
  late DetectDuplicateUsecase usecase;

  setUp(() {
    repo = MockMediaItemRepository();
    usecase = DetectDuplicateUsecase(repo);
  });

  test('returns exactBarcode when barcode already exists', () async {
    final existing = _item('x', barcode: '123', title: 'Foo');
    when(() => repo.findByBarcode('123')).thenAnswer((_) async => [existing]);
    final result = await usecase(barcode: '123', title: 'Foo');
    expect(result.kind, DuplicateKind.exactBarcode);
    expect(result.candidates, [existing]);
  });

  test('returns fuzzyTitle when similar title+year exists', () async {
    final existing = _item('y', title: 'The Lord of the Rings', year: 2001);
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => [existing]);
    final result = await usecase(
      barcode: '999',
      title: 'The Lord of the Rings',
      year: 2001,
    );
    expect(result.kind, DuplicateKind.fuzzyTitle);
    expect(result.candidates, [existing]);
  });

  test('filters fuzzy candidates below 0.85 similarity', () async {
    final existing = _item('z', title: 'Totally Different', year: 2001);
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => [existing]);
    final result =
        await usecase(barcode: '9', title: 'Dune', year: 2001);
    expect(result.kind, DuplicateKind.none);
  });

  test('returns none when no matches found', () async {
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => []);
    final result = await usecase(barcode: 'x', title: 'Nothing', year: 2000);
    expect(result.kind, DuplicateKind.none);
    expect(result.candidates, isEmpty);
  });

  test('fuzzy boundary: similarity 0.9 (>= 0.85) returns fuzzyTitle',
      () async {
    // 'abcdefghij' vs 'abcdefghiX' — 1 substitution on a 10-char string.
    // Levenshtein distance = 1, maxLen = 10, similarity = 1 - 1/10 = 0.9.
    final existing = _item('a', title: 'abcdefghij', year: 2001);
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => [existing]);
    final result =
        await usecase(barcode: 'x', title: 'abcdefghiX', year: 2001);
    expect(result.kind, DuplicateKind.fuzzyTitle);
    expect(result.candidates, [existing]);
  });

  test('fuzzy boundary: similarity 0.8 (< 0.85) returns none', () async {
    // 'abcdefghij' vs 'abcdefghXY' — 2 substitutions on a 10-char string.
    // Levenshtein distance = 2, maxLen = 10, similarity = 1 - 2/10 = 0.8.
    final existing = _item('a', title: 'abcdefghij', year: 2001);
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => [existing]);
    final result =
        await usecase(barcode: 'x', title: 'abcdefghXY', year: 2001);
    expect(result.kind, DuplicateKind.none);
  });

  test('null title skips fuzzy match and returns none', () async {
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    final result = await usecase(barcode: 'x', title: null, year: 2001);
    expect(result.kind, DuplicateKind.none);
    verifyNever(() => repo.findByTitleYear(any(), any()));
  });

  test('empty title skips fuzzy match and returns none', () async {
    when(() => repo.findByBarcode(any())).thenAnswer((_) async => []);
    final result = await usecase(barcode: 'x', title: '', year: 2001);
    expect(result.kind, DuplicateKind.none);
    verifyNever(() => repo.findByTitleYear(any(), any()));
  });

  test('excludeId removes matching candidates', () async {
    final existing = _item('self', barcode: '123', title: 'Foo');
    when(() => repo.findByBarcode('123')).thenAnswer((_) async => [existing]);
    when(() => repo.findByTitleYear(any(), any()))
        .thenAnswer((_) async => []);
    final result = await usecase(
      barcode: '123',
      title: 'Foo',
      excludeId: 'self',
    );
    expect(result.kind, DuplicateKind.none);
  });
}
