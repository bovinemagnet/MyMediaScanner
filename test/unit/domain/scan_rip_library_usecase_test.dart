/// Unit tests for [ScanRipLibraryUseCase] cover-art wiring.
///
/// Uses a real temporary library directory (the scanner walks the
/// filesystem in an isolate) with a mocked repository.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/scan_rip_library_usecase.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  late MockRipLibraryRepository mockRepo;
  late Directory tempDir;

  setUpAll(() {
    // RipAlbum is a sealed freezed class, so it cannot be implemented by
    // a Fake subclass outside its own library — register a concrete
    // instance instead, matching the convention used elsewhere in the
    // test suite (e.g. edit_rip_metadata_usecase_test.dart).
    registerFallbackValue(const RipAlbum(
      id: 'fallback',
      libraryPath: 'fallback',
      trackCount: 0,
      totalSizeBytes: 0,
      lastScannedAt: 0,
      updatedAt: 0,
    ));
    registerFallbackValue(<RipTrack>[]);
  });

  setUp(() async {
    mockRepo = MockRipLibraryRepository();
    tempDir = await Directory.systemTemp.createTemp('mms_scan_cover_');
    when(() => mockRepo.getAllNonDeleted())
        .thenAnswer((_) async => <RipAlbum>[]);
    when(() => mockRepo.insertAlbumWithTracks(any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<Directory> makeAlbumDir() async {
    final albumDir = await Directory(
            '${tempDir.path}/library/Artist/Album')
        .create(recursive: true);
    // The audio file's contents don't matter for cover extraction from
    // a folder image; an unparseable FLAC still forms an album.
    await File('${albumDir.path}/01 track.flac')
        .writeAsBytes([0, 1, 2, 3]);
    return albumDir;
  }

  test('persists coverPath when a folder image exists and a cache dir '
      'is supplied', () async {
    final albumDir = await makeAlbumDir();
    await File('${albumDir.path}/cover.jpg').writeAsBytes([9, 9, 9]);

    final useCase = ScanRipLibraryUseCase(repository: mockRepo);
    await useCase
        .execute('${tempDir.path}/library',
            coverCacheDir: '${tempDir.path}/cache')
        .drain<void>();

    final album = verify(
      () => mockRepo.insertAlbumWithTracks(captureAny(), any()),
    ).captured.single as RipAlbum;
    expect(album.coverPath, isNotNull);
    expect(File(album.coverPath!).existsSync(), isTrue);
  });

  test('coverPath stays null when no cache dir is supplied', () async {
    final albumDir = await makeAlbumDir();
    await File('${albumDir.path}/cover.jpg').writeAsBytes([9, 9, 9]);

    final useCase = ScanRipLibraryUseCase(repository: mockRepo);
    await useCase.execute('${tempDir.path}/library').drain<void>();

    final album = verify(
      () => mockRepo.insertAlbumWithTracks(captureAny(), any()),
    ).captured.single as RipAlbum;
    expect(album.coverPath, isNull);
  });
}
