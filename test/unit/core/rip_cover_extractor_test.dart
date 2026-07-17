/// Unit tests for [RipCoverExtractor].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/rip_cover_extractor.dart';

import '../../helpers/flac_fixtures.dart';

void main() {
  late Directory tempDir;
  late Directory albumDir;
  late Directory cacheDir;

  const relativePath = 'Artist/Album';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mms_cover_');
    albumDir = await Directory('${tempDir.path}/Artist/Album')
        .create(recursive: true);
    cacheDir = Directory('${tempDir.path}/cache');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  String expectedCachePath(String ext) {
    final hash = md5.convert(utf8.encode(relativePath)).toString();
    return '${cacheDir.path}/$hash.$ext';
  }

  Future<String> writeFlacWithArt(List<int> art) async {
    final file = File('${albumDir.path}/01 track.flac');
    await file.writeAsBytes(buildFlacFixture(
      tags: {'ARTIST': 'Artist'},
      pictureData: Uint8List.fromList(art),
      pictureMimeType: 'image/png',
    ));
    return file.path;
  }

  test('prefers a folder image over embedded art', () async {
    final folderArt = [10, 20, 30];
    await File('${albumDir.path}/Cover.JPG').writeAsBytes(folderArt);
    final flacPath = await writeFlacWithArt([1, 2, 3]);

    final result = await RipCoverExtractor.extractCover(
      albumDirPath: albumDir.path,
      relativePath: relativePath,
      audioFilePaths: [flacPath],
      cacheDirPath: cacheDir.path,
    );

    expect(result, expectedCachePath('jpg'));
    expect(await File(result!).readAsBytes(), folderArt);
  });

  test('falls back to the embedded picture when no folder image exists',
      () async {
    final embedded = [7, 8, 9];
    final flacPath = await writeFlacWithArt(embedded);

    final result = await RipCoverExtractor.extractCover(
      albumDirPath: albumDir.path,
      relativePath: relativePath,
      audioFilePaths: [flacPath],
      cacheDirPath: cacheDir.path,
    );

    // image/png in the fixture → .png cache extension.
    expect(result, expectedCachePath('png'));
    expect(await File(result!).readAsBytes(), embedded);
  });

  test('returns null when there is no artwork at all', () async {
    final flac = File('${albumDir.path}/01 track.flac');
    await flac.writeAsBytes(buildFlacFixture(tags: {'ARTIST': 'A'}));

    final result = await RipCoverExtractor.extractCover(
      albumDirPath: albumDir.path,
      relativePath: relativePath,
      audioFilePaths: [flac.path],
      cacheDirPath: cacheDir.path,
    );

    expect(result, isNull);
  });

  test('returns null instead of throwing for unreadable inputs',
      () async {
    final result = await RipCoverExtractor.extractCover(
      albumDirPath: '${tempDir.path}/missing',
      relativePath: relativePath,
      audioFilePaths: ['${tempDir.path}/missing/none.flac'],
      cacheDirPath: cacheDir.path,
    );

    expect(result, isNull);
  });
}
