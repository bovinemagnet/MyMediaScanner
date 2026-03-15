import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

/// Matches unlinked rip albums to media items in the collection.
class MatchRipsUseCase {
  const MatchRipsUseCase({
    required IRipLibraryRepository ripRepository,
    required IMediaItemRepository mediaItemRepository,
  })  : _ripRepo = ripRepository,
        _mediaItemRepo = mediaItemRepository;

  final IRipLibraryRepository _ripRepo;
  final IMediaItemRepository _mediaItemRepo;

  /// Attempts to match all unlinked rip albums to collection items.
  ///
  /// Returns the number of newly matched albums.
  Future<int> execute() async {
    final allRips = await _ripRepo.getAllNonDeleted();
    final unmatchedRips =
        allRips.where((r) => r.mediaItemId == null).toList();

    if (unmatchedRips.isEmpty) return 0;

    // Get all music items from the collection
    final musicItems = await _mediaItemRepo
        .watchAll(mediaType: MediaType.music)
        .first;

    var matchCount = 0;

    for (final rip in unmatchedRips) {
      final match = _findMatch(rip, musicItems);
      if (match != null) {
        await _ripRepo.linkToMediaItem(rip.id, match.id);
        matchCount++;
      }
    }

    return matchCount;
  }

  MediaItem? _findMatch(RipAlbum rip, List<MediaItem> items) {
    // Strategy 1: Barcode match
    if (rip.barcode != null && rip.barcode!.isNotEmpty) {
      final barcodeMatch = items
          .where((item) => item.barcode == rip.barcode)
          .firstOrNull;
      if (barcodeMatch != null) return barcodeMatch;
    }

    // Strategy 2: Normalised title + artist match
    final normRipTitle = normalise(rip.albumTitle);
    final normRipArtist = normalise(rip.artist);

    if (normRipTitle.isEmpty) return null;

    for (final item in items) {
      final normItemTitle = normalise(item.title);
      if (normItemTitle != normRipTitle) continue;

      // Compare artist
      final itemArtist = _extractArtist(item);
      final normItemArtist = normalise(itemArtist);

      if (normRipArtist.isEmpty || normItemArtist.isEmpty) {
        // If either artist is missing, match on title alone
        return item;
      }

      if (normItemArtist == normRipArtist) {
        return item;
      }
    }

    return null;
  }

  /// Extract artist string from a media item.
  ///
  /// Uses `extraMetadata['artists']` (joined) or `publisher` as fallback.
  String? _extractArtist(MediaItem item) {
    final artists = item.extraMetadata['artists'];
    if (artists is List && artists.isNotEmpty) {
      return artists.join(', ');
    }
    if (artists is String && artists.isNotEmpty) {
      return artists;
    }
    return item.publisher;
  }

  /// Normalise a string for matching: lowercase, strip leading "the ",
  /// remove punctuation, trim whitespace.
  static String normalise(String? value) {
    if (value == null) return '';
    var result = value.toLowerCase().trim();
    // Strip leading "the "
    if (result.startsWith('the ')) {
      result = result.substring(4);
    }
    // Remove punctuation
    result = result.replaceAll(RegExp(r'[^\w\s]'), '');
    // Collapse whitespace
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result;
  }
}
