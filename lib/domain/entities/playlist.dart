import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist.freezed.dart';

@freezed
sealed class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    String? description,
    String? coverAlbumId,
    required int createdAt,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Playlist;
}
