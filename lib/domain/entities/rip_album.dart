import 'package:freezed_annotation/freezed_annotation.dart';

part 'rip_album.freezed.dart';

@freezed
sealed class RipAlbum with _$RipAlbum {
  const factory RipAlbum({
    required String id,
    required String libraryPath,
    String? artist,
    String? albumTitle,
    String? barcode,
    required int trackCount,
    @Default(1) int discCount,
    required int totalSizeBytes,
    String? mediaItemId,
    String? cueFilePath,
    String? gnudbDiscId,
    required int lastScannedAt,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _RipAlbum;
}
