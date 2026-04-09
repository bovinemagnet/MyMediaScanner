/// CUE sheet parser for extracting album and track metadata.
///
/// Parses .cue files to extract album-level metadata (performer, title, barcode)
/// and per-track information (title, performer, timestamps).
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

/// A parsed CUE sheet.
class CueSheet {
  const CueSheet({
    this.performer,
    this.title,
    this.fileName,
    this.barcode,
    this.discNumber,
    this.tracks = const [],
  });

  /// Album-level performer (PERFORMER at top level).
  final String? performer;

  /// Album title (TITLE at top level).
  final String? title;

  /// Audio file referenced by FILE command.
  final String? fileName;

  /// Barcode from CATALOG, REM UPC, or REM BARCODE.
  final String? barcode;

  /// Disc number from REM DISCNUMBER.
  final int? discNumber;

  /// Ordered list of tracks.
  final List<CueTrack> tracks;
}

/// A single track within a CUE sheet.
class CueTrack {
  const CueTrack({
    required this.trackNumber,
    this.title,
    this.performer,
    this.startMs,
    this.endMs,
  });

  final int trackNumber;

  /// Track title (TITLE within TRACK block).
  final String? title;

  /// Track performer (PERFORMER within TRACK block).
  final String? performer;

  /// Start time in milliseconds (from INDEX 01).
  final int? startMs;

  /// End time in milliseconds (derived from next track's INDEX 01, or null for last track).
  final int? endMs;

  /// Duration in milliseconds, or null if end is unknown.
  int? get durationMs =>
      (startMs != null && endMs != null) ? endMs! - startMs! : null;
}

/// Internal mutable builder for a track while parsing.
class _TrackBuilder {
  _TrackBuilder(this.trackNumber);

  final int trackNumber;
  String? title;
  String? performer;
  int? startMs;

  CueTrack build({int? endMs}) => CueTrack(
        trackNumber: trackNumber,
        title: title,
        performer: performer,
        startMs: startMs,
        endMs: endMs,
      );
}

/// Parses CUE sheet files.
class CueParser {
  const CueParser._();

  /// Parse a .cue file from disk.
  static Future<CueSheet?> parse(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      // Try UTF-8 first, fall back to Latin1.
      String content;
      try {
        content = await file.readAsString();
      } catch (_) {
        final bytes = await file.readAsBytes();
        content = String.fromCharCodes(bytes); // Latin1 fallback
      }
      return parseString(content);
    } catch (_) {
      return null;
    }
  }

  /// Parse CUE sheet content from a string (useful for testing).
  static CueSheet? parseString(String content) {
    if (content.trim().isEmpty) return null;

    String? albumPerformer;
    String? albumTitle;
    String? fileName;
    String? barcode;
    int? discNumber;

    final trackBuilders = <_TrackBuilder>[];
    _TrackBuilder? current;

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Detect TRACK block start.
      final trackMatch = RegExp(r'^TRACK\s+(\d+)\s+AUDIO', caseSensitive: false)
          .firstMatch(line);
      if (trackMatch != null) {
        if (current != null) trackBuilders.add(current);
        current = _TrackBuilder(int.parse(trackMatch.group(1)!));
        continue;
      }

      if (current != null) {
        // Inside a TRACK block.
        final titleMatch =
            RegExp(r'^TITLE\s+"(.*)"', caseSensitive: false).firstMatch(line);
        if (titleMatch != null) {
          current.title = titleMatch.group(1);
          continue;
        }

        final performerMatch =
            RegExp(r'^PERFORMER\s+"(.*)"', caseSensitive: false)
                .firstMatch(line);
        if (performerMatch != null) {
          current.performer = performerMatch.group(1);
          continue;
        }

        final index01Match =
            RegExp(r'^INDEX\s+01\s+(\d+):(\d+):(\d+)', caseSensitive: false)
                .firstMatch(line);
        if (index01Match != null) {
          final mm = int.parse(index01Match.group(1)!);
          final ss = int.parse(index01Match.group(2)!);
          final ff = int.parse(index01Match.group(3)!);
          current.startMs = (mm * 60 + ss) * 1000 + (ff * 1000 ~/ 75);
          continue;
        }

        // INDEX 00 (pregap) — ignore.
        // Any other line within the TRACK block is ignored.
      } else {
        // Top-level (before first TRACK or between global commands).
        final performerMatch =
            RegExp(r'^PERFORMER\s+"(.*)"', caseSensitive: false)
                .firstMatch(line);
        if (performerMatch != null) {
          albumPerformer = performerMatch.group(1);
          continue;
        }

        final titleMatch =
            RegExp(r'^TITLE\s+"(.*)"', caseSensitive: false).firstMatch(line);
        if (titleMatch != null) {
          albumTitle = titleMatch.group(1);
          continue;
        }

        final fileMatch =
            RegExp(r'^FILE\s+"(.+)"\s+\w+', caseSensitive: false)
                .firstMatch(line);
        if (fileMatch != null) {
          fileName = fileMatch.group(1);
          continue;
        }

        final catalogMatch =
            RegExp(r'^CATALOG\s+(\d+)', caseSensitive: false).firstMatch(line);
        if (catalogMatch != null) {
          barcode = catalogMatch.group(1);
          continue;
        }

        final remUpcMatch =
            RegExp(r'^REM\s+UPC\s+(\d+)', caseSensitive: false)
                .firstMatch(line);
        if (remUpcMatch != null) {
          barcode = remUpcMatch.group(1);
          continue;
        }

        final remBarcodeMatch =
            RegExp(r'^REM\s+BARCODE\s+(\d+)', caseSensitive: false)
                .firstMatch(line);
        if (remBarcodeMatch != null) {
          barcode = remBarcodeMatch.group(1);
          continue;
        }

        final remDiscMatch =
            RegExp(r'^REM\s+DISCNUMBER\s+(\d+)', caseSensitive: false)
                .firstMatch(line);
        if (remDiscMatch != null) {
          discNumber = int.parse(remDiscMatch.group(1)!);
          continue;
        }
      }
    }

    // Flush the last track builder.
    if (current != null) trackBuilders.add(current);

    if (trackBuilders.isEmpty) return null;

    // Build final tracks, deriving endMs from the next track's startMs.
    final tracks = <CueTrack>[];
    for (var i = 0; i < trackBuilders.length; i++) {
      final endMs =
          i + 1 < trackBuilders.length ? trackBuilders[i + 1].startMs : null;
      tracks.add(trackBuilders[i].build(endMs: endMs));
    }

    return CueSheet(
      performer: albumPerformer,
      title: albumTitle,
      fileName: fileName,
      barcode: barcode,
      discNumber: discNumber,
      tracks: tracks,
    );
  }
}
