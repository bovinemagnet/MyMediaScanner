import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/rip_log_parser.dart';

const _eacLog = '''
Exact Audio Copy V1.6 from 23. October 2019

EAC extraction logfile from 15. March 2026

Used drive  : ASUS BW-16D1HT

Track  1

     Filename Z:\\CD\\Various\\Album\\01. Track One.wav

     Peak level 96.2 %
     Track quality 99.8 %
     Copy CRC 882B01BE
     Accurately ripped (confidence 1)  [F4E2268A]
     Copy OK

Track  2

     Filename Z:\\CD\\Various\\Album\\02. Track Two.wav

     Peak level 88.5 %
     Track quality 100.0 %
     Copy CRC AABB1122
     Cannot be verified as accurate  [12345678]
     Copy OK

Track  3

     Filename Z:\\CD\\Various\\Album\\03. Track Three.wav

     Peak level 100.0 %
     Track quality 98.1 %
     Copy CRC DEADBEEF
     Accurately ripped (confidence 12)  [CAFEBABE]
     Copy OK
''';

const _xldLog = '''
X Lossless Decoder version 20230916 (153.8)

XLD extraction logfile from 2026-03-15 14:30:00

Track 01
  Filename : /path/to/01 Track One.flac
  Pre-gap length : 00:00:00

  CRC32 hash               : 882B01BE
  AccurateRip v1 signature : F4E2268A
  AccurateRip v2 signature : A1B2C3D4
    ->Accurately ripped (v1+v2, confidence 3/3)
  Statistics
    Read error                           : 0
    Jitter error (maybe fixed)           : 0
    Peak level                           : 96.2 %
    Track quality                        : 100.0 %

Track 02
  Filename : /path/to/02 Track Two.flac
  Pre-gap length : 00:00:00

  CRC32 hash               : AABB1122
  AccurateRip v1 signature : 12345678
  AccurateRip v2 signature : 56789ABC
    ->Accurately ripped (v1, confidence 5/5)
  Statistics
    Read error                           : 0
    Jitter error (maybe fixed)           : 0
    Peak level                           : 88.5 %
    Track quality                        : 99.9 %
''';

void main() {
  group('RipLogParser', () {
    group('EAC format', () {
      test('parses three tracks from EAC log', () {
        final results = RipLogParser.parse(_eacLog);

        expect(results, hasLength(3));
      });

      test('extracts track 1 fields correctly', () {
        final results = RipLogParser.parse(_eacLog);
        final track1 = results[0];

        expect(track1.trackNumber, equals(1));
        expect(track1.logSource, equals('EAC'));
        expect(track1.peakLevel, closeTo(0.962, 0.001));
        expect(track1.trackQuality, closeTo(0.998, 0.001));
        expect(track1.copyCrc, equals('882B01BE'));
        expect(track1.accurateRipCrc, equals('F4E2268A'));
        expect(track1.accuratelyRipped, isTrue);
        expect(track1.arConfidence, equals(1));
        expect(track1.filename,
            equals('Z:\\CD\\Various\\Album\\01. Track One.wav'));
      });

      test('track 2 is not accurately ripped', () {
        final results = RipLogParser.parse(_eacLog);
        final track2 = results[1];

        expect(track2.trackNumber, equals(2));
        expect(track2.accuratelyRipped, isFalse);
        expect(track2.arConfidence, isNull);
        expect(track2.copyCrc, equals('AABB1122'));
        expect(track2.peakLevel, closeTo(0.885, 0.001));
        expect(track2.trackQuality, closeTo(1.0, 0.001));
      });

      test('track 3 has high AR confidence', () {
        final results = RipLogParser.parse(_eacLog);
        final track3 = results[2];

        expect(track3.trackNumber, equals(3));
        expect(track3.accuratelyRipped, isTrue);
        expect(track3.arConfidence, equals(12));
        expect(track3.accurateRipCrc, equals('CAFEBABE'));
      });
    });

    group('XLD format', () {
      test('parses two tracks from XLD log', () {
        final results = RipLogParser.parse(_xldLog);

        expect(results, hasLength(2));
      });

      test('extracts track 1 fields correctly', () {
        final results = RipLogParser.parse(_xldLog);
        final track1 = results[0];

        expect(track1.trackNumber, equals(1));
        expect(track1.logSource, equals('XLD'));
        expect(track1.peakLevel, closeTo(0.962, 0.001));
        expect(track1.trackQuality, closeTo(1.0, 0.001));
        expect(track1.copyCrc, equals('882B01BE'));
        expect(track1.accurateRipCrc, equals('F4E2268A'));
        expect(track1.accuratelyRipped, isTrue);
        expect(track1.arConfidence, equals(3));
        expect(track1.filename, equals('/path/to/01 Track One.flac'));
      });

      test('extracts track 2 fields correctly', () {
        final results = RipLogParser.parse(_xldLog);
        final track2 = results[1];

        expect(track2.trackNumber, equals(2));
        expect(track2.accuratelyRipped, isTrue);
        expect(track2.arConfidence, equals(5));
        expect(track2.peakLevel, closeTo(0.885, 0.001));
        expect(track2.trackQuality, closeTo(0.999, 0.001));
      });
    });

    group('error handling', () {
      test('malformed log returns empty list', () {
        final results = RipLogParser.parse('This is not a valid log file.');

        expect(results, isEmpty);
      });

      test('empty string returns empty list', () {
        final results = RipLogParser.parse('');

        expect(results, isEmpty);
      });

      test('whitespace-only string returns empty list', () {
        final results = RipLogParser.parse('   \n\n  ');

        expect(results, isEmpty);
      });
    });
  });
}
