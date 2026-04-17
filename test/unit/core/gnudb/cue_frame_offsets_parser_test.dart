import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/gnudb/cue_frame_offsets_parser.dart';

void main() {
  group('CueFrameOffsetsParser.parse', () {
    test('extracts INDEX 01 offsets from a single-file image CUE', () {
      const cue = '''
REM GENRE "Rock"
REM DATE "2023"
PERFORMER "Example Artist"
TITLE "Example Album"
FILE "album.flac" WAVE
  TRACK 01 AUDIO
    TITLE "First Song"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "Second Song"
    INDEX 00 03:18:00
    INDEX 01 03:20:00
  TRACK 03 AUDIO
    TITLE "Third Song"
    INDEX 01 06:40:00
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets, hasLength(3));
      expect(offsets[0].trackNumber, 1);
      expect(offsets[0].filePath, 'album.flac');
      expect(offsets[0].inFileFrameOffset, 0);
      expect(offsets[1].trackNumber, 2);
      expect(offsets[1].filePath, 'album.flac');
      // 3:20.00 -> (3*60 + 20)*75 = 15000
      expect(offsets[1].inFileFrameOffset, 15000);
      expect(offsets[2].trackNumber, 3);
      expect(offsets[2].inFileFrameOffset, 30000);
    });

    test('extracts offsets from a multi-file CUE (one file per track)', () {
      const cue = '''
PERFORMER "Foo"
TITLE "Bar"
FILE "track01.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
FILE "track02.flac" WAVE
  TRACK 02 AUDIO
    INDEX 01 00:00:00
FILE "track03.flac" WAVE
  TRACK 03 AUDIO
    INDEX 01 00:00:00
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets, hasLength(3));
      expect(offsets.map((o) => o.filePath).toList(),
          ['track01.flac', 'track02.flac', 'track03.flac']);
      expect(offsets.every((o) => o.inFileFrameOffset == 0), isTrue);
    });

    test('ignores data tracks (non-AUDIO)', () {
      const cue = '''
FILE "album.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
  TRACK 02 MODE1/2352
    INDEX 01 01:00:00
  TRACK 03 AUDIO
    INDEX 01 02:00:00
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets, hasLength(2));
      expect(offsets.map((o) => o.trackNumber).toList(), [1, 3]);
    });

    test('prefers INDEX 01 over INDEX 00 (pregap)', () {
      const cue = '''
FILE "album.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    INDEX 00 01:58:00
    INDEX 01 02:00:00
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets[1].inFileFrameOffset, (2 * 60) * 75); // 9000
    });

    test('handles quoted file paths with spaces', () {
      const cue = '''
FILE "My Album.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets.first.filePath, 'My Album.flac');
    });

    test('handles unquoted single-token file paths', () {
      const cue = '''
FILE album.flac WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets.first.filePath, 'album.flac');
    });

    test('accepts CRLF line endings', () {
      const cue =
          'FILE "album.flac" WAVE\r\n  TRACK 01 AUDIO\r\n    INDEX 01 00:00:00\r\n';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets, hasLength(1));
      expect(offsets.first.inFileFrameOffset, 0);
    });

    test('throws when a track has no INDEX 01', () {
      const cue = '''
FILE "album.flac" WAVE
  TRACK 01 AUDIO
    INDEX 00 00:00:00
''';
      expect(
        () => CueFrameOffsetsParser.parse(cue),
        throwsA(isA<FormatException>()),
      );
    });

    test('returns empty list for a CUE with no audio tracks', () {
      const cue = '''
REM GENRE "Rock"
''';
      final offsets = CueFrameOffsetsParser.parse(cue);
      expect(offsets, isEmpty);
    });
  });

  group('CueFrameOffsetsParser.parseFile', () {
    test('reads from disk and parses', () async {
      final tempDir = await Directory.systemTemp.createTemp('cue_parse_');
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });
      final cueFile = File('${tempDir.path}/sample.cue');
      await cueFile.writeAsString(
        await File(
                'test/fixtures/gnudb/sample.cue')
            .readAsString(),
      );
      final offsets = await CueFrameOffsetsParser.parseFile(cueFile.path);
      expect(offsets, hasLength(3));
      expect(offsets.first.filePath, 'album.flac');
    });
  });

  group('CueFrameOffsetsParser.msfToFrames', () {
    test('converts MM:SS:FF to absolute frames', () {
      expect(CueFrameOffsetsParser.msfToFrames(0, 0, 0), 0);
      expect(CueFrameOffsetsParser.msfToFrames(0, 1, 0), 75);
      expect(CueFrameOffsetsParser.msfToFrames(1, 0, 0), 60 * 75);
      expect(CueFrameOffsetsParser.msfToFrames(3, 20, 0), 15000);
      expect(CueFrameOffsetsParser.msfToFrames(6, 40, 25), 30025);
    });
  });
}
