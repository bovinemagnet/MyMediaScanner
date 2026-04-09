/// ReplayGain volume normalisation service.
///
/// Calculates the effective playback volume by applying ReplayGain gain
/// metadata (track or album mode) with optional pre-amplification and
/// clipping prevention.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:math' as math;

/// ReplayGain normalisation mode.
enum ReplayGainMode {
  /// No ReplayGain normalisation applied.
  off,

  /// Apply track-level gain (falls back to album gain if track gain absent).
  track,

  /// Apply album-level gain.
  album,
}

/// Stateless service that computes effective playback volume from ReplayGain
/// tags embedded in audio file metadata.
///
/// All methods are pure and safe to call from any isolate.
class ReplayGainService {
  /// Creates a [ReplayGainService].
  const ReplayGainService();

  /// Calculates the effective volume to pass to the audio player.
  ///
  /// [rawTags] — map of raw tag key/value pairs from the audio file.
  /// [mode] — [ReplayGainMode.off] returns [userVolume] unchanged.
  /// [preampDb] — additional gain in dB applied on top of the tag gain.
  ///   Typical range: -6.0 to +6.0.
  /// [preventClipping] — when true, reduces gain so that
  ///   `linear_gain * peak <= 1.0`.
  /// [userVolume] — the user-selected volume (0.0–1.0) that is multiplied
  ///   with the ReplayGain linear factor.
  ///
  /// Returns a value in [0.0, 1.0].
  double calculateVolume({
    required Map<String, String> rawTags,
    required ReplayGainMode mode,
    required double preampDb,
    required bool preventClipping,
    required double userVolume,
  }) {
    if (mode == ReplayGainMode.off) return userVolume;

    final gainDb = _getGainDb(rawTags, mode);
    if (gainDb == null) return userVolume;

    final peakValue = _getPeak(rawTags, mode);
    final effectiveGain = gainDb + preampDb;
    var linearGain = math.pow(10, effectiveGain / 20).toDouble();

    if (preventClipping && peakValue != null && linearGain * peakValue > 1.0) {
      linearGain = 1.0 / peakValue;
    }

    return (userVolume * linearGain).clamp(0.0, 1.0);
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  /// Returns the gain in dB for the given [mode].
  ///
  /// For [ReplayGainMode.track], falls back to album gain if track gain is
  /// absent.  Returns null if no suitable gain tag is found.
  double? _getGainDb(Map<String, String> tags, ReplayGainMode mode) {
    if (mode == ReplayGainMode.album) {
      return _parseGain(tags['REPLAYGAIN_ALBUM_GAIN']);
    }
    // track mode — prefer track, fall back to album
    return _parseGain(tags['REPLAYGAIN_TRACK_GAIN']) ??
        _parseGain(tags['REPLAYGAIN_ALBUM_GAIN']);
  }

  /// Returns the peak sample value for the given [mode], or null if absent.
  double? _getPeak(Map<String, String> tags, ReplayGainMode mode) {
    if (mode == ReplayGainMode.album) {
      return _parsePeak(tags['REPLAYGAIN_ALBUM_PEAK']);
    }
    return _parsePeak(tags['REPLAYGAIN_TRACK_PEAK']) ??
        _parsePeak(tags['REPLAYGAIN_ALBUM_PEAK']);
  }

  /// Parses a gain string such as "-6.5 dB" or "-6.5" to a [double].
  ///
  /// Returns null if [raw] is null or cannot be parsed.
  double? _parseGain(String? raw) {
    if (raw == null) return null;
    // Strip trailing " dB" (case-insensitive) then parse.
    final cleaned = raw.replaceAll(RegExp(r'[Dd][Bb]'), '').trim();
    return double.tryParse(cleaned);
  }

  /// Parses a peak string such as "0.987654" to a [double].
  ///
  /// Returns null if [raw] is null or cannot be parsed.
  double? _parsePeak(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.trim());
  }
}
