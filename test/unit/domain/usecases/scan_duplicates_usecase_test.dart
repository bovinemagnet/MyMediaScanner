import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';
import 'package:mymediascanner/domain/usecases/scan_duplicates_usecase.dart';

class _MockRepo extends Mock implements IMediaItemRepository {}

MediaItem _i({
  required String id,
  required String barcode,
  required String title,
  int? year,
  bool deleted = false,
  OwnershipStatus ownership = OwnershipStatus.owned,
}) {
  return MediaItem(
    id: id,
    barcode: barcode,
    barcodeType: 'EAN-13',
    mediaType: MediaType.music,
    title: title,
    year: year,
    ownershipStatus: ownership,
    deleted: deleted,
    dateAdded: 1700000000,
    dateScanned: 1700000000,
    updatedAt: 1700000000,
  );
}

void main() {
  late _MockRepo repo;
  late ScanDuplicatesUseCase useCase;

  setUp(() {
    repo = _MockRepo();
    useCase = ScanDuplicatesUseCase(repository: repo);
  });

  test('groups exact barcode duplicates', () async {
    when(() => repo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value([
          _i(id: 'a', barcode: '111', title: 'Album'),
          _i(id: 'b', barcode: '111', title: 'Album Reissue'),
          _i(id: 'c', barcode: '222', title: 'Other'),
        ]));

    final groups = await useCase.execute();
    expect(groups, hasLength(1));
    expect(groups.first.kind, DuplicateKind.exactBarcode);
    expect(groups.first.items.map((i) => i.id), equals(['a', 'b']));
  });

  test('groups fuzzy title matches within same year', () async {
    when(() => repo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value([
          _i(id: 'a', barcode: '1', title: 'The Wall', year: 1979),
          _i(id: 'b', barcode: '2', title: 'The wall', year: 1979),
          _i(id: 'c', barcode: '3', title: 'Animals', year: 1977),
        ]));

    final groups = await useCase.execute();
    expect(groups, hasLength(1));
    expect(groups.first.kind, DuplicateKind.fuzzyTitle);
    expect(groups.first.items.map((i) => i.id), equals(['a', 'b']));
  });

  test('excludes deleted and wishlist items', () async {
    when(() => repo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value([
          _i(id: 'owned', barcode: '111', title: 'X'),
          _i(id: 'deleted', barcode: '111', title: 'X', deleted: true),
          _i(
            id: 'wish',
            barcode: '111',
            title: 'X',
            ownership: OwnershipStatus.wishlist,
          ),
        ]));

    final groups = await useCase.execute();
    expect(groups, isEmpty);
  });

  test('returns empty list when no duplicates exist', () async {
    when(() => repo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value([
          _i(id: 'a', barcode: '1', title: 'Alpha', year: 2000),
          _i(id: 'b', barcode: '2', title: 'Beta', year: 2001),
        ]));

    final groups = await useCase.execute();
    expect(groups, isEmpty);
  });
}
