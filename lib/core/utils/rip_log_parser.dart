/// Parser for EAC (Exact Audio Copy) and XLD (X Lossless Decoder) rip log
/// files.
///
/// Extracts per-track quality information including AccurateRip status,
/// confidence, CRC values, peak level, and track quality.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

/// Result of parsing a single track from a rip log file.
class RipLogTrackResult {
  RipLogTrackResult({
    required this.trackNumber,
    this.filename,
    this.peakLevel,
    this.trackQuality,
    this.copyCrc,
    this.accurateRipCrc,
    this.accuratelyRipped = false,
    this.arConfidence,
    this.logSource,
  });

  final int trackNumber;
  final String? filename;

  /// Peak level as a fraction 0.0-1.0.
  final double? peakLevel;

  /// Track quality as a fraction 0.0-1.0.
  final double? trackQuality;

  /// Copy CRC hex string from the log.
  final String? copyCrc;

  /// AccurateRip CRC hex string from the log.
  final String? accurateRipCrc;

  /// Whether the track was accurately ripped according to the log.
  final bool accuratelyRipped;

  /// AccurateRip confidence count.
  final int? arConfidence;

  /// Log format source: 'EAC' or 'XLD'.
  final String? logSource;
}

/// Parses rip log files in EAC and XLD formats.
class RipLogParser {
  const RipLogParser._();

  /// Parse a rip log file's content and return per-track results.
  ///
  /// Returns an empty list if the format is unrecognised or the content
  /// is malformed.
  static List<RipLogTrackResult> parse(String logContent) {
    if (logContent.trim().isEmpty) return [];

    try {
      if (logContent.contains('Exact Audio Copy')) {
        return _parseEac(logContent);
      } else if (logContent.contains('X Lossless Decoder')) {
        return _parseXld(logContent);
      }
    } catch (_) {
      return [];
    }

    return [];
  }

  static List<RipLogTrackResult> _parseEac(String content) {
    final results = <RipLogTrackResult>[];

    // Split into track sections
    final trackPattern = RegExp(r'Track\s+(\d+)', multiLine: true);
    final matches = trackPattern.allMatches(content).toList();

    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final trackNumber = int.parse(match.group(1)!);
      final sectionStart = match.start;
      final sectionEnd =
          i + 1 < matches.length ? matches[i + 1].start : content.length;
      final section = content.substring(sectionStart, sectionEnd);

      final filename = _extractEacField(section, r'Filename\s+(.+)');
      final peakStr = _extractEacField(section, r'Peak level\s+([\d.]+)\s*%');
      final qualityStr =
          _extractEacField(section, r'Track quality\s+([\d.]+)\s*%');
      final copyCrc = _extractEacField(section, r'Copy CRC\s+([0-9A-Fa-f]+)');

      // AccurateRip status
      final arMatch = RegExp(
        r'Accurately ripped\s*\(confidence\s+(\d+)\)\s*\[([0-9A-Fa-f]+)\]',
      ).firstMatch(section);

      final accuratelyRipped = arMatch != null;
      final arConfidence =
          arMatch != null ? int.tryParse(arMatch.group(1)!) : null;
      final arCrc = arMatch?.group(2);

      results.add(RipLogTrackResult(
        trackNumber: trackNumber,
        filename: filename?.trim(),
        peakLevel: peakStr != null ? (double.tryParse(peakStr) ?? 0) / 100 : null,
        trackQuality:
            qualityStr != null ? (double.tryParse(qualityStr) ?? 0) / 100 : null,
        copyCrc: copyCrc,
        accurateRipCrc: arCrc,
        accuratelyRipped: accuratelyRipped,
        arConfidence: arConfidence,
        logSource: 'EAC',
      ));
    }

    return results;
  }

  static String? _extractEacField(String section, String pattern) {
    final match = RegExp(pattern).firstMatch(section);
    return match?.group(1);
  }

  static List<RipLogTrackResult> _parseXld(String content) {
    final results = <RipLogTrackResult>[];

    // Split into track sections — XLD uses "Track XX"
    final trackPattern = RegExp(r'^Track\s+(\d+)', multiLine: true);
    final matches = trackPattern.allMatches(content).toList();

    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final trackNumber = int.parse(match.group(1)!);
      final sectionStart = match.start;
      final sectionEnd =
          i + 1 < matches.length ? matches[i + 1].start : content.length;
      final section = content.substring(sectionStart, sectionEnd);

      final filename =
          _extractXldField(section, r'Filename\s*:\s*(.+)');
      final peakStr =
          _extractXldField(section, r'Peak level\s*:\s*([\d.]+)\s*%');
      final qualityStr =
          _extractXldField(section, r'Track quality\s*:\s*([\d.]+)\s*%');
      final copyCrc =
          _extractXldField(section, r'CRC32 hash\s*:\s*([0-9A-Fa-f]+)');

      // AccurateRip v1 signature
      final arV1Crc = _extractXldField(
          section, r'AccurateRip v1 signature\s*:\s*([0-9A-Fa-f]+)');

      // AccurateRip status
      final arMatch = RegExp(
        r'Accurately ripped\s*\(v[12]\+?v?[12]?,\s*confidence\s+(\d+)/?\d*\)',
      ).firstMatch(section);

      final accuratelyRipped = section.contains('Accurately ripped');
      final arConfidence =
          arMatch != null ? int.tryParse(arMatch.group(1)!) : null;

      results.add(RipLogTrackResult(
        trackNumber: trackNumber,
        filename: filename?.trim(),
        peakLevel: peakStr != null ? (double.tryParse(peakStr) ?? 0) / 100 : null,
        trackQuality:
            qualityStr != null ? (double.tryParse(qualityStr) ?? 0) / 100 : null,
        copyCrc: copyCrc,
        accurateRipCrc: arV1Crc,
        accuratelyRipped: accuratelyRipped,
        arConfidence: arConfidence,
        logSource: 'XLD',
      ));
    }

    return results;
  }

  static String? _extractXldField(String section, String pattern) {
    final match = RegExp(pattern).firstMatch(section);
    return match?.group(1);
  }
}
