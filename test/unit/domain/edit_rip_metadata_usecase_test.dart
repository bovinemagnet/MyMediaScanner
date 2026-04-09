// Tests for EditRipMetadataUseCase.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/metaflac_writer.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';

class MockRipLibraryRepository extends Mock
    implements IRipLibraryRepository {}

class MockMetaflacWriter extends Mock implements MetaflacWriter {}

void main() {
  late MockRipLibraryRepository mockRepo;
  late MockMetaflacWriter mockWriter;
  late EditRipMetadataUseCase useCase;

  const testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: 'Pink Floyd/Dark Side',
    artist: 'Pink Floyd',
    albumTitle: 'The Dark Side of the Moon',
    trackCount: 2,
    totalSizeBytes: 100000,
    lastScannedAt: 1000,
    updatedAt: 1000,
  );

  const testTracks = [
    RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'Speak to Me',
      filePath: '/music/track01.flac',
      fileSizeBytes: 50000,
      updatedAt: 1000,
    ),
    RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Breathe',
      filePath: '/music/track02.flac',
      fileSizeBytes: 50000,
      updatedAt: 1000,
    ),
  ];

  setUp(() {
    mockRepo = MockRipLibraryRepository();
    mockWriter = MockMetaflacWriter();
    useCase = EditRipMetadataUseCase(
      repository: mockRepo,
      writer: mockWriter,
    );

    registerFallbackValue(testAlbum);

    when(() => mockWriter.setTags(any(), any())).thenAnswer((_) async {});
    when(() => mockWriter.removeTag(any(), any())).thenAnswer((_) async {});
    when(() => mockRepo.updateAlbum(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateTrackTitle(any(), any()))
        .thenAnswer((_) async {});
  });

  group('editAlbumMetadata', () {
    test('writes tags to all FLAC track files', () async {
      await useCase.editAlbumMetadata(
        album: testAlbum,
        tracks: testTracks,
        artist: 'New Artist',
        albumTitle: 'New Album',
      );

      verify(() => mockWriter.setTags(
            '/music/track01.flac',
            {'ALBUMARTIST': 'New Artist', 'ALBUM': 'New Album'},
          )).called(1);
      verify(() => mockWriter.setTags(
            '/music/track02.flac',
            {'ALBUMARTIST': 'New Artist', 'ALBUM': 'New Album'},
          )).called(1);
    });

    test('updates album in database after writing files', () async {
      await useCase.editAlbumMetadata(
        album: testAlbum,
        tracks: testTracks,
        artist: 'New Artist',
      );

      final captured =
          verify(() => mockRepo.updateAlbum(captureAny())).captured;
      final updatedAlbum = captured.first as RipAlbum;
      expect(updatedAlbum.artist, 'New Artist');
      expect(updatedAlbum.albumTitle, 'The Dark Side of the Moon');
    });

    test('removes tag when value is empty string', () async {
      await useCase.editAlbumMetadata(
        album: testAlbum,
        tracks: testTracks,
        artist: '',
      );

      verify(() => mockWriter.removeTag('/music/track01.flac', 'ALBUMARTIST'))
          .called(1);
      verify(() => mockWriter.removeTag('/music/track02.flac', 'ALBUMARTIST'))
          .called(1);

      final captured =
          verify(() => mockRepo.updateAlbum(captureAny())).captured;
      final updatedAlbum = captured.first as RipAlbum;
      expect(updatedAlbum.artist, isNull);
    });

    test('skips non-FLAC files', () async {
      const mp3Track = RipTrack(
        id: 'track-mp3',
        ripAlbumId: 'album-1',
        trackNumber: 3,
        title: 'MP3 Track',
        filePath: '/music/track03.mp3',
        fileSizeBytes: 30000,
        updatedAt: 1000,
      );

      await useCase.editAlbumMetadata(
        album: testAlbum,
        tracks: [...testTracks, mp3Track],
        artist: 'New Artist',
      );

      verifyNever(() => mockWriter.setTags('/music/track03.mp3', any()));
    });

    test('does nothing when no changes provided', () async {
      await useCase.editAlbumMetadata(
        album: testAlbum,
        tracks: testTracks,
      );

      verifyNever(() => mockWriter.setTags(any(), any()));
      verifyNever(() => mockRepo.updateAlbum(any()));
    });
  });

  group('editTrackTitle', () {
    test('writes TITLE tag and updates database', () async {
      await useCase.editTrackTitle(
        track: testTracks.first,
        title: 'New Title',
      );

      verify(() => mockWriter.setTags(
            '/music/track01.flac',
            {'TITLE': 'New Title'},
          )).called(1);
      verify(() => mockRepo.updateTrackTitle('track-1', 'New Title')).called(1);
    });

    test('removes TITLE tag when title is empty', () async {
      await useCase.editTrackTitle(
        track: testTracks.first,
        title: '',
      );

      verify(() => mockWriter.removeTag('/music/track01.flac', 'TITLE'))
          .called(1);
      verify(() => mockRepo.updateTrackTitle('track-1', null)).called(1);
    });

    test('removes TITLE tag when title is null', () async {
      await useCase.editTrackTitle(
        track: testTracks.first,
        title: null,
      );

      verify(() => mockWriter.removeTag('/music/track01.flac', 'TITLE'))
          .called(1);
      verify(() => mockRepo.updateTrackTitle('track-1', null)).called(1);
    });

    test('skips file write for MP3 tracks', () async {
      const mp3Track = RipTrack(
        id: 'track-mp3',
        ripAlbumId: 'album-1',
        trackNumber: 3,
        title: 'MP3 Track',
        filePath: '/music/track03.mp3',
        fileSizeBytes: 30000,
        updatedAt: 1000,
      );

      await useCase.editTrackTitle(
        track: mp3Track,
        title: 'Updated MP3 Title',
      );

      verifyNever(() => mockWriter.setTags(any(), any()));
      // DB is still updated even for MP3
      verify(() => mockRepo.updateTrackTitle('track-mp3', 'Updated MP3 Title'))
          .called(1);
    });

    test('propagates exception when writer throws', () async {
      when(() => mockWriter.setTags(any(), any()))
          .thenThrow(const MetaflacWriteException('Write failed'));

      expect(
        () => useCase.editTrackTitle(
          track: testTracks.first,
          title: 'New Title',
        ),
        throwsA(isA<MetaflacWriteException>()),
      );
    });
  });
}
