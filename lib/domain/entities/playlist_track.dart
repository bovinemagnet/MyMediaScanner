import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_track.freezed.dart';

@freezed
sealed class PlaylistTrack with _$PlaylistTrack {
  const factory PlaylistTrack({
    required String id,
    required String playlistId,
    required String ripTrackId,
    required int sortOrder,
    required int addedAt,
  }) = _PlaylistTrack;
}
