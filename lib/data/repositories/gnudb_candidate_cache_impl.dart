/// Barcode-cache-backed store of resolved GnuDB lookup candidates.
///
/// Entries are keyed `gnudb:<discid>` in the shared `barcode_cache` table
/// and expire after the standard cache duration.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/gnudb_disc.dart';
import 'package:mymediascanner/domain/repositories/i_gnudb_candidate_cache.dart';

class GnudbCandidateCacheImpl implements IGnudbCandidateCache {
  GnudbCandidateCacheImpl(this._cacheDao);

  final BarcodeCacheDao _cacheDao;

  @override
  Future<List<GnudbCandidate>?> read(String discId) async {
    final hit = await _cacheDao.getByBarcode(_cacheKey(discId));
    if (hit == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - hit.cachedAt;
    const maxAgeMs = ApiConstants.cacheDurationDays * 86_400_000;
    if (age > maxAgeMs) return null;
    try {
      final payload = jsonDecode(hit.responseJson) as Map<String, dynamic>;
      return (payload['candidates'] as List)
          .map((c) => GnudbCandidate(
                discId: c['disc_id'] as String,
                category: c['category'] as String,
                disc: GnudbDisc(
                  discId: c['disc_id'] as String,
                  artist: c['artist'] as String,
                  albumTitle: c['album_title'] as String,
                  year: c['year'] as int?,
                  genre: c['genre'] as String?,
                  trackTitles: (c['track_titles'] as List).cast<String>(),
                  extendedAlbum: c['extended_album'] as String?,
                ),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String discId, List<GnudbCandidate> candidates) async {
    final payload = jsonEncode({
      'candidates': [
        for (final c in candidates)
          {
            'disc_id': c.discId,
            'category': c.category,
            'artist': c.disc.artist,
            'album_title': c.disc.albumTitle,
            'year': c.disc.year,
            'genre': c.disc.genre,
            'track_titles': c.disc.trackTitles,
            'extended_album': c.disc.extendedAlbum,
          }
      ],
    });
    await _cacheDao.upsert(BarcodeCacheTableCompanion(
      barcode: Value(_cacheKey(discId)),
      mediaTypeHint: const Value('music'),
      responseJson: Value(payload),
      sourceApi: const Value('gnudb'),
      cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  String _cacheKey(String discId) => 'gnudb:$discId';
}
