/// Tests for ReplayGainService volume calculation.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';

void main() {
  const service = ReplayGainService();

  // Helper tags with both track and album gain/peak
  const fullTags = {
    'REPLAYGAIN_TRACK_GAIN': '-6.0 dB',
    'REPLAYGAIN_TRACK_PEAK': '1.0',
    'REPLAYGAIN_ALBUM_GAIN': '-3.0 dB',
    'REPLAYGAIN_ALBUM_PEAK': '1.0',
  };

  group('ReplayGainService', () {
    // ------------------------------------------------------------------
    // Off mode
    // ------------------------------------------------------------------

    test('returnsUserVolume_whenModeIsOff', () {
      final result = service.calculateVolume(
        rawTags: fullTags,
        mode: ReplayGainMode.off,
        preampDb: 0.0,
        preventClipping: true,
        userVolume: 0.8,
      );

      expect(result, 0.8);
    });

    // ------------------------------------------------------------------
    // Track mode
    // ------------------------------------------------------------------

    test('appliesTrackGain_minusSixDb_yieldsApprox0Point5012', () {
      // 10^(-6/20) ≈ 0.5012
      final result = service.calculateVolume(
        rawTags: fullTags,
        mode: ReplayGainMode.track,
        preampDb: 0.0,
        preventClipping: false,
        userVolume: 1.0,
      );

      expect(result, closeTo(0.5012, 0.001));
    });

    test('appliesAlbumGain_whenModeIsAlbum', () {
      // album gain = -3 dB → 10^(-3/20) ≈ 0.7079
      final result = service.calculateVolume(
        rawTags: fullTags,
        mode: ReplayGainMode.album,
        preampDb: 0.0,
        preventClipping: false,
        userVolume: 1.0,
      );

      expect(result, closeTo(0.7079, 0.001));
    });

    // ------------------------------------------------------------------
    // Preamp
    // ------------------------------------------------------------------

    test('appliesPreampBoost_minusSixDbGainPlusThreeDbPreamp_yieldsApprox0Point7079', () {
      // -6 dB gain + 3 dB preamp = -3 dB → 10^(-3/20) ≈ 0.7079
      final result = service.calculateVolume(
        rawTags: fullTags,
        mode: ReplayGainMode.track,
        preampDb: 3.0,
        preventClipping: false,
        userVolume: 1.0,
      );

      expect(result, closeTo(0.7079, 0.001));
    });

    // ------------------------------------------------------------------
    // Clipping prevention
    // ------------------------------------------------------------------

    test('preventsClipping_whenGainExceedsPeak', () {
      // gain = +6 dB (2.0 linear), peak = 0.6 → linear * peak = 1.2 > 1.0
      // So clipped linear = 1.0 / 0.6 ≈ 1.6667, clamped to 1.0
      final tags = {
        'REPLAYGAIN_TRACK_GAIN': '6.0 dB',
        'REPLAYGAIN_TRACK_PEAK': '0.6',
      };

      final result = service.calculateVolume(
        rawTags: tags,
        mode: ReplayGainMode.track,
        preampDb: 0.0,
        preventClipping: true,
        userVolume: 1.0,
      );

      // 1.0 / 0.6 ≈ 1.6667, then * userVolume 1.0, clamped to 1.0
      expect(result, closeTo(1.0, 0.001));
    });

    test('allowsClipping_whenPreventionDisabled_stillClampsTo1Point0', () {
      // gain = +6 dB linear = 2.0, no clipping prevention → 2.0, clamped to 1.0
      final tags = {
        'REPLAYGAIN_TRACK_GAIN': '6.0 dB',
        'REPLAYGAIN_TRACK_PEAK': '0.6',
      };

      final result = service.calculateVolume(
        rawTags: tags,
        mode: ReplayGainMode.track,
        preampDb: 0.0,
        preventClipping: false,
        userVolume: 1.0,
      );

      expect(result, closeTo(1.0, 0.001));
    });

    // ------------------------------------------------------------------
    // Missing tags
    // ------------------------------------------------------------------

    test('returnsUserVolume_whenTagsAreMissing', () {
      final result = service.calculateVolume(
        rawTags: const {},
        mode: ReplayGainMode.track,
        preampDb: 0.0,
        preventClipping: true,
        userVolume: 0.6,
      );

      expect(result, 0.6);
    });

    // ------------------------------------------------------------------
    // User volume scaling
    // ------------------------------------------------------------------

    test('combinesWithUserVolume_halfUserVolume_yieldsHalfGainedVolume', () {
      // track gain -6 dB → linear ≈ 0.5012; user 0.5 → 0.5012 * 0.5 ≈ 0.2506
      final result = service.calculateVolume(
        rawTags: fullTags,
        mode: ReplayGainMode.track,
        preampDb: 0.0,
        preventClipping: false,
        userVolume: 0.5,
      );

      expect(result, closeTo(0.2506, 0.001));
    });

    // ------------------------------------------------------------------
    // Fallback: album gain used when track gain missing in track mode
    // ------------------------------------------------------------------

    test('fallsBackToAlbumGain_whenTrackGainMissingInTrackMode', () {
      // Only album gain present; track mode should fall back to album gain.
      // album gain = -3 dB → 10^(-3/20) ≈ 0.7079
      const tagsNoTrack = {
        'REPLAYGAIN_ALBUM_GAIN': '-3.0 dB',
        'REPLAYGAIN_ALBUM_PEAK': '1.0',
      };

      final result = service.calculateVolume(
        rawTags: tagsNoTrack,
        mode: ReplayGainMode.track,
        preampDb: 0.0,
        preventClipping: false,
        userVolume: 1.0,
      );

      expect(result, closeTo(0.7079, 0.001));
    });
  });
}
