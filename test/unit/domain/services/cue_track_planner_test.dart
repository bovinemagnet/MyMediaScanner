import 'package:dart_cue/dart_cue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/services/cue_track_planner.dart';
import 'package:path/path.dart' as p;

/// #131: CUE import flattened every track onto the sheet's first FILE
/// and dropped the INDEX offsets, so multi-file sheets pointed every
/// track at one file and single-image rips restarted from the top for
/// each track.
void main() {
  final dir = p.join(p.separator, 'music', 'Artist', 'Album');

  test('single-image sheet: every track spans its slice of the file', () {
    final sheet = parseCueSheet('''
PERFORMER "Artist"
TITLE "Album"
FILE "Album.flac" WAVE
  TRACK 01 AUDIO
    TITLE "One"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "Two"
    INDEX 01 03:00:00
  TRACK 03 AUDIO
    TITLE "Three"
    INDEX 01 07:30:00
''')!;

    final plans = planCueTracks(sheet, dir);

    expect(plans.map((t) => t.filePath),
        everyElement(p.join(dir, 'Album.flac')));
    expect(plans.map((t) => t.trackNumber), [1, 2, 3]);
    expect(plans.map((t) => t.title), ['One', 'Two', 'Three']);
    expect(plans.map((t) => t.startMs), [0, 180000, 450000]);
    expect(plans.map((t) => t.endMs), [180000, 450000, null],
        reason: 'the last track plays to the end of its file');
    expect(plans.map((t) => t.durationMs), [180000, 270000, null]);
  });

  test('multi-file sheet: each track points at its own FILE', () {
    final sheet = parseCueSheet('''
FILE "01 - One.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
FILE "02 - Two.flac" WAVE
  TRACK 02 AUDIO
    INDEX 00 00:00:00
    INDEX 01 00:02:00
''')!;

    final plans = planCueTracks(sheet, dir);

    expect(plans.map((t) => t.filePath), [
      p.join(dir, '01 - One.flac'),
      p.join(dir, '02 - Two.flac'),
    ]);
    expect(plans.map((t) => t.startMs), [0, 2000],
        reason: 'INDEX 01 (mm:ss:ff) follows a 2-second INDEX 00 pregap');
    expect(plans.map((t) => t.endMs), [null, null]);
  });

  test('takes the disc number from the sheet', () {
    final sheet = parseCueSheet('''
REM DISCNUMBER 2
FILE "Album.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:00:00
''')!;

    expect(planCueTracks(sheet, dir).single.discNumber, 2);
  });
}
