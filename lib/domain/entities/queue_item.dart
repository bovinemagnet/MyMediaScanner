import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

part 'queue_item.freezed.dart';

enum QueueItemSource { album, manual, playlist }

@freezed
sealed class QueueItem with _$QueueItem {
  const factory QueueItem({
    required RipAlbum album,
    required RipTrack track,
    @Default(QueueItemSource.manual) QueueItemSource source,
  }) = _QueueItem;
}
