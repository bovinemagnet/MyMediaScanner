import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/apply_gnudb_result_usecase.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

class _MockEdit extends Mock implements EditRipMetadataUseCase {}

class _MockSave extends Mock implements SaveMediaItemUseCase {}

class _MockRepo extends Mock implements IRipLibraryRepository {}

RipAlbum _album({String? mediaItemId}) => RipAlbum(
      id: 'album-1',
      libraryPath: '/lib',
      trackCount: 3,
      discCount: 1,
      totalSizeBytes: 0,
      cueFilePath: 'x.cue',
      lastScannedAt: 0,
      updatedAt: 0,
      mediaItemId: mediaItemId,
    );

List<RipTrack> _tracks() => [
      const RipTrack(
          id: 't1',
          ripAlbumId: 'album-1',
          trackNumber: 1,
          filePath: '/lib/t1.flac',
          fileSizeBytes: 0,
          updatedAt: 0),
      const RipTrack(
          id: 't2',
          ripAlbumId: 'album-1',
          trackNumber: 2,
          title: 'Old Title',
          filePath: '/lib/t2.flac',
          fileSizeBytes: 0,
          updatedAt: 0),
      const RipTrack(
          id: 't3',
          ripAlbumId: 'album-1',
          trackNumber: 3,
          filePath: '/lib/t3.flac',
          fileSizeBytes: 0,
          updatedAt: 0),
    ];

GnudbCandidate _candidate({
  List<String> titles = const ['One', 'Two', 'Three'],
  String category = 'rock',
  String discId = 'abcdef01',
}) =>
    GnudbCandidate(
      discId: discId,
      category: category,
      dto: GnudbDiscDto(
        discId: discId,
        artist: 'Artist',
        albumTitle: 'Album',
        year: 2023,
        genre: 'Rock',
        trackTitles: titles,
      ),
    );

MediaItem _mediaItem(String id) => MediaItem(
      id: id,
      barcode: 'gnudb:abcdef01',
      barcodeType: 'cddb',
      mediaType: MediaType.music,
      title: 'Album',
      ownershipStatus: OwnershipStatus.owned,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const RipTrack(
      id: 'fallback',
      ripAlbumId: 'fallback',
      trackNumber: 0,
      filePath: '',
      fileSizeBytes: 0,
      updatedAt: 0,
    ));
    registerFallbackValue(const MetadataResult(
      barcode: 'fallback',
      barcodeType: 'fallback',
    ));
    registerFallbackValue(const RipAlbum(
      id: 'fallback',
      libraryPath: '',
      trackCount: 0,
      totalSizeBytes: 0,
      lastScannedAt: 0,
      updatedAt: 0,
    ));
    registerFallbackValue(<RipTrack>[]);
  });

  late _MockEdit edit;
  late _MockSave save;
  late _MockRepo repo;
  late ApplyGnudbResultUseCase useCase;

  setUp(() {
    edit = _MockEdit();
    save = _MockSave();
    repo = _MockRepo();
    when(() => edit.editAlbumMetadata(
          album: any(named: 'album'),
          tracks: any(named: 'tracks'),
          artist: any(named: 'artist'),
          albumTitle: any(named: 'albumTitle'),
        )).thenAnswer((_) async {});
    when(() => edit.editTrackTitle(
          track: any(named: 'track'),
          title: any(named: 'title'),
        )).thenAnswer((_) async {});
    when(() => repo.linkToMediaItem(any(), any())).thenAnswer((_) async {});

    useCase = ApplyGnudbResultUseCase(
      editRipMetadata: edit,
      saveMediaItem: save,
      repository: repo,
    );
  });

  test('updates album-level metadata via EditRipMetadataUseCase', () async {
    when(() => save.execute(any())).thenAnswer((_) async => _mediaItem('mi-1'));

    await useCase.execute(
      album: _album(),
      tracks: _tracks(),
      candidate: _candidate(),
    );

    verify(() => edit.editAlbumMetadata(
          album: any(named: 'album'),
          tracks: any(named: 'tracks'),
          artist: 'Artist',
          albumTitle: 'Album',
        )).called(1);
  });

  test('updates each track title except when unchanged or out of range',
      () async {
    when(() => save.execute(any())).thenAnswer((_) async => _mediaItem('mi-1'));

    final outcome = await useCase.execute(
      album: _album(),
      tracks: _tracks(),
      candidate: _candidate(titles: const ['One', 'Old Title', 'Three']),
    );

    // Track 2 kept its existing title; only tracks 1 and 3 are written.
    expect(outcome.tracksUpdated, 2);
    verify(() => edit.editTrackTitle(
          track: any(named: 'track'),
          title: 'One',
        )).called(1);
    verify(() => edit.editTrackTitle(
          track: any(named: 'track'),
          title: 'Three',
        )).called(1);
    verifyNever(() => edit.editTrackTitle(
          track: any(named: 'track'),
          title: 'Old Title',
        ));
  });

  test('creates and links a MediaItem when album is unlinked', () async {
    when(() => save.execute(any())).thenAnswer((_) async => _mediaItem('mi-1'));

    final outcome = await useCase.execute(
      album: _album(),
      tracks: _tracks(),
      candidate: _candidate(),
    );

    expect(outcome.mediaItemCreated, isTrue);
    expect(outcome.mediaItemId, 'mi-1');
    verify(() => save.execute(any())).called(1);
    verify(() => repo.linkToMediaItem('album-1', 'mi-1')).called(1);
  });

  test('skips MediaItem creation when already linked', () async {
    final outcome = await useCase.execute(
      album: _album(mediaItemId: 'existing'),
      tracks: _tracks(),
      candidate: _candidate(),
    );

    expect(outcome.mediaItemCreated, isFalse);
    expect(outcome.mediaItemId, 'existing');
    verifyNever(() => save.execute(any()));
    verifyNever(() => repo.linkToMediaItem(any(), any()));
  });

  test('respects createMediaItemIfUnlinked=false', () async {
    final outcome = await useCase.execute(
      album: _album(),
      tracks: _tracks(),
      candidate: _candidate(),
      createMediaItemIfUnlinked: false,
    );
    expect(outcome.mediaItemCreated, isFalse);
    verifyNever(() => save.execute(any()));
  });

  test('ignores empty trackTitles entries', () async {
    when(() => save.execute(any())).thenAnswer((_) async => _mediaItem('mi-1'));

    final outcome = await useCase.execute(
      album: _album(),
      tracks: _tracks(),
      candidate: _candidate(titles: const ['One', '', 'Three']),
    );
    expect(outcome.tracksUpdated, 2);
  });
}
