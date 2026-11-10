// Turns a parsed CUE sheet into one playable track per CUE TRACK.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:dart_cue/dart_cue.dart';
import 'package:path/path.dart' as p;

/// One CUE track resolved to the audio file that holds it and its span
/// inside that file.
class CueTrackPlan {
  const CueTrackPlan({
    required this.filePath,
    required this.discNumber,
    required this.trackNumber,
    this.title,
    this.startMs,
    this.endMs,
  });

  /// The track's own FILE, resolved against the CUE sheet's directory.
  final String filePath;
  final int discNumber;
  final int trackNumber;
  final String? title;

  /// Position of INDEX 01 within [filePath]; null when the sheet gives
  /// none.
  final int? startMs;

  /// Where the next track in the same file starts; null for the last
  /// track of a file, which plays to the end of the file.
  final int? endMs;

  int? get durationMs =>
      startMs != null && endMs != null ? endMs! - startMs! : null;
}

/// Resolves every track in [sheet] to its own FILE (relative to
/// [cueDirectory]) with its start and end offsets (#131). The previous
/// scan flattened all tracks onto the first FILE without offsets, so
/// multi-file sheets pointed every track at one file and single-image
/// rips restarted from the top for each track.
List<CueTrackPlan> planCueTracks(CueSheet sheet, String cueDirectory) {
  final discNumber = sheet.discNumber ?? 1;
  return [
    for (final file in sheet.files)
      for (final track in file.tracks)
        CueTrackPlan(
          filePath: p.normalize(p.join(cueDirectory, file.filename)),
          discNumber: discNumber,
          trackNumber: track.trackNumber,
          title: track.title,
          startMs: track.startTime?.inMilliseconds,
          endMs: track.endTime?.inMilliseconds,
        ),
  ];
}
