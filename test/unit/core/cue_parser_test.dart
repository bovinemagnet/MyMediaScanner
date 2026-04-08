// Tests for CueParser.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/cue_parser.dart';

/// Multi-track CUE sheet used across several tests.
const _darkSideCue = '''
PERFORMER "Pink Floyd"
TITLE "The Dark Side of the Moon"
FILE "dark_side.flac" WAVE
CATALOG 0724382975328
  TRACK 01 AUDIO
    TITLE "Speak to Me"
    PERFORMER "Pink Floyd"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "Breathe"
    PERFORMER "Pink Floyd"
    INDEX 01 01:05:37
  TRACK 03 AUDIO
    TITLE "On the Run"
    PERFORMER "Pink Floyd"
    INDEX 01 03:52:25
''';

void main() {
  group('CueParser.parseString', () {
    test('returns null for empty string', () {
      expect(CueParser.parseString(''), isNull);
    });

    test('returns null for blank content', () {
      expect(CueParser.parseString('   \n\n\t  \n'), isNull);
    });

    test('extracts album metadata', () {
      const cue = '''
PERFORMER "David Bowie"
TITLE "Ziggy Stardust"
FILE "ziggy.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Five Years"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.performer, equals('David Bowie'));
      expect(sheet.title, equals('Ziggy Stardust'));
      expect(sheet.fileName, equals('ziggy.flac'));
    });

    test('extracts CATALOG barcode', () {
      const cue = '''
PERFORMER "Test Artist"
TITLE "Test Album"
CATALOG 0602547202888
FILE "test.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Track 1"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.barcode, equals('0602547202888'));
    });

    test('extracts REM UPC barcode', () {
      const cue = '''
PERFORMER "Test Artist"
TITLE "Test Album"
REM UPC 0602547202888
FILE "test.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Track 1"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.barcode, equals('0602547202888'));
    });

    test('extracts REM BARCODE barcode', () {
      const cue = '''
PERFORMER "Test Artist"
TITLE "Test Album"
REM BARCODE 0602547202888
FILE "test.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Track 1"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.barcode, equals('0602547202888'));
    });

    test('extracts disc number from REM DISCNUMBER', () {
      const cue = '''
PERFORMER "Test Artist"
TITLE "Test Album"
REM DISCNUMBER 2
FILE "test.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Track 1"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.discNumber, equals(2));
    });

    test('parses tracks with titles and performers', () {
      final sheet = CueParser.parseString(_darkSideCue);
      expect(sheet, isNotNull);
      expect(sheet!.tracks, hasLength(3));

      expect(sheet.tracks[0].trackNumber, equals(1));
      expect(sheet.tracks[0].title, equals('Speak to Me'));
      expect(sheet.tracks[0].performer, equals('Pink Floyd'));

      expect(sheet.tracks[1].trackNumber, equals(2));
      expect(sheet.tracks[1].title, equals('Breathe'));
      expect(sheet.tracks[1].performer, equals('Pink Floyd'));

      expect(sheet.tracks[2].trackNumber, equals(3));
      expect(sheet.tracks[2].title, equals('On the Run'));
      expect(sheet.tracks[2].performer, equals('Pink Floyd'));
    });

    test('converts INDEX 01 time codes correctly', () {
      // INDEX 01 03:25:50 → (3*60+25)*1000 + (50*1000~/75) = 205000 + 666 = 205666
      const cue = '''
PERFORMER "Artist"
TITLE "Album"
FILE "album.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Track 1"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "Track 2"
    INDEX 01 03:25:50
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.tracks[1].startMs, equals(205666));
    });

    test('derives track end times from next track start', () {
      final sheet = CueParser.parseString(_darkSideCue);
      expect(sheet, isNotNull);

      final t1Start = sheet!.tracks[0].startMs!;
      final t2Start = sheet.tracks[1].startMs!;
      final t3Start = sheet.tracks[2].startMs!;

      // Track 1 ends where Track 2 starts.
      expect(sheet.tracks[0].endMs, equals(t2Start));
      // Track 2 ends where Track 3 starts.
      expect(sheet.tracks[1].endMs, equals(t3Start));
      // Last track has no endMs.
      expect(sheet.tracks[2].endMs, isNull);

      // Sanity: times should increase.
      expect(t1Start, lessThan(t2Start));
      expect(t2Start, lessThan(t3Start));
    });

    test('handles track duration calculation', () {
      final sheet = CueParser.parseString(_darkSideCue);
      expect(sheet, isNotNull);

      final track1 = sheet!.tracks[0];
      final track2 = sheet.tracks[1];

      // Track 1: 00:00:00 → 01:05:37
      // startMs = 0, endMs = (1*60+5)*1000 + (37*1000~/75) = 65000 + 493 = 65493
      expect(track1.startMs, equals(0));
      expect(track1.endMs, equals(track2.startMs));
      expect(track1.durationMs, equals(track2.startMs! - 0));

      // Last track has no durationMs.
      expect(sheet.tracks[2].durationMs, isNull);
    });

    test('handles single-track CUE', () {
      const cue = '''
PERFORMER "Solo Artist"
TITLE "Single Track Album"
FILE "solo.flac" WAVE
  TRACK 01 AUDIO
    TITLE "The Only Track"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.tracks, hasLength(1));
      expect(sheet.tracks[0].trackNumber, equals(1));
      expect(sheet.tracks[0].endMs, isNull);
    });

    test('handles CUE with FILE in quotes', () {
      const cue = '''
PERFORMER "Artist"
TITLE "Album"
FILE "album.flac" WAVE
  TRACK 01 AUDIO
    TITLE "Track 1"
    INDEX 01 00:00:00
''';
      final sheet = CueParser.parseString(cue);
      expect(sheet, isNotNull);
      expect(sheet!.fileName, equals('album.flac'));
    });
  });
}
