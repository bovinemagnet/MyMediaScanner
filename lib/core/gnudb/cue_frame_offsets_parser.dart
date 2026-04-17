/// Parses INDEX 01 offsets from a CUE sheet for CDDB Disc ID computation.
///
/// The `dart_cue` package exposes track-level metadata (titles, durations)
/// but does not surface raw `INDEX 01 MM:SS:FF` offsets in a stable way.
/// Those raw offsets are what the CDDB algorithm needs, so this small
/// dedicated parser reads them directly from the CUE text.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

/// A per-track INDEX 01 offset extracted from a CUE sheet.
class CueTrackOffset {
  const CueTrackOffset({
    required this.trackNumber,
    required this.filePath,
    required this.inFileFrameOffset,
  });

  /// 1-based track number as declared in the CUE sheet.
  final int trackNumber;

  /// Path to the audio file this track lives in, relative to the CUE.
  final String filePath;

  /// Frames from the start of [filePath] to the INDEX 01 position.
  /// 75 frames = 1 second.
  final int inFileFrameOffset;

  @override
  String toString() =>
      'CueTrackOffset(track: $trackNumber, file: $filePath, frames: $inFileFrameOffset)';
}

/// Parser for extracting INDEX 01 offsets from CUE sheets.
class CueFrameOffsetsParser {
  const CueFrameOffsetsParser._();

  static final RegExp _fileLine =
      RegExp(r'^\s*FILE\s+(?:"([^"]+)"|(\S+))(?:\s+\w+)?\s*$');
  static final RegExp _trackLine =
      RegExp(r'^\s*TRACK\s+(\d+)\s+(\S+)\s*$');
  static final RegExp _indexLine =
      RegExp(r'^\s*INDEX\s+(\d+)\s+(\d+):(\d+):(\d+)\s*$');

  /// Converts an MM:SS:FF triple (as found in CUE INDEX lines) to absolute
  /// frames. Each second contains 75 frames.
  static int msfToFrames(int minutes, int seconds, int frames) {
    return ((minutes * 60) + seconds) * 75 + frames;
  }

  /// Parses [cueText] and returns the INDEX 01 offset for every audio
  /// track, in declared order.
  ///
  /// Throws a [FormatException] if a TRACK ... AUDIO block lacks an
  /// INDEX 01. Non-AUDIO tracks (data tracks) are skipped.
  static List<CueTrackOffset> parse(String cueText) {
    final result = <CueTrackOffset>[];
    final lines = cueText.split(RegExp(r'\r?\n'));

    String? currentFile;
    int? pendingTrackNumber;
    bool pendingIsAudio = false;
    int? pendingIndex01;

    void flushPending() {
      final trackNumber = pendingTrackNumber;
      final index01 = pendingIndex01;
      final file = currentFile;
      if (trackNumber != null) {
        if (pendingIsAudio) {
          if (index01 == null) {
            throw FormatException(
                'Track $trackNumber has no INDEX 01 entry');
          }
          if (file == null) {
            throw FormatException(
                'Track $trackNumber declared before any FILE');
          }
          result.add(CueTrackOffset(
            trackNumber: trackNumber,
            filePath: file,
            inFileFrameOffset: index01,
          ));
        }
      }
      pendingTrackNumber = null;
      pendingIsAudio = false;
      pendingIndex01 = null;
    }

    for (final rawLine in lines) {
      final line = rawLine;

      final fileMatch = _fileLine.firstMatch(line);
      if (fileMatch != null) {
        flushPending();
        currentFile = fileMatch.group(1) ?? fileMatch.group(2);
        continue;
      }

      final trackMatch = _trackLine.firstMatch(line);
      if (trackMatch != null) {
        flushPending();
        pendingTrackNumber = int.parse(trackMatch.group(1)!);
        pendingIsAudio = trackMatch.group(2)!.toUpperCase() == 'AUDIO';
        continue;
      }

      final indexMatch = _indexLine.firstMatch(line);
      if (indexMatch != null && pendingTrackNumber != null) {
        final indexNum = int.parse(indexMatch.group(1)!);
        if (indexNum == 1) {
          pendingIndex01 = msfToFrames(
            int.parse(indexMatch.group(2)!),
            int.parse(indexMatch.group(3)!),
            int.parse(indexMatch.group(4)!),
          );
        }
        continue;
      }
    }

    flushPending();
    return result;
  }

  /// Reads the CUE file at [cuePath] from disk and parses it.
  static Future<List<CueTrackOffset>> parseFile(String cuePath) async {
    final text = await File(cuePath).readAsString();
    return parse(text);
  }
}
