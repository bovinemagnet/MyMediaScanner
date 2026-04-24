import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_token_manager.dart';
import 'package:mymediascanner/data/remote/api/igdb/models/igdb_game_dto.dart';

/// Thin wrapper around the IGDB `/v4/games` endpoint.
///
/// IGDB speaks [Apicalypse](https://api-docs.igdb.com/#apicalypse-1) — a
/// text body format where you list fields, filters, and limits in a single
/// string. We build the query here and send it as the POST body; IGDB
/// returns a JSON array of matching games.
///
/// Auth is a Twitch Client-ID header plus a bearer token sourced from
/// [IgdbTokenManager]. On a 401 the token is invalidated and the request
/// retried exactly once.
class IgdbApi {
  IgdbApi({
    required this.tokenManager,
    Dio? dio,
  }) : _dio = dio ??
            DioFactory.create(
              baseUrl: ApiConstants.igdbBaseUrl,
              defaultHeaders: const {'Content-Type': 'text/plain'},
            );

  final IgdbTokenManager tokenManager;
  final Dio _dio;

  /// Fields requested on every game lookup. Kept centralised so the shape
  /// of the returned DTO and the shape of the query can't drift.
  static const _fields = 'name, summary, cover.url, platforms.name, '
      'involved_companies.company.name, involved_companies.developer, '
      'involved_companies.publisher, genres.name, first_release_date, '
      'aggregated_rating, rating';

  /// Search IGDB by free-text title. Results are ordered by IGDB's default
  /// relevance for `search`.
  Future<List<IgdbGameDto>> searchByTitle(String title, {int limit = 10}) {
    final query = 'fields $_fields; search "${_escape(title)}"; limit $limit;';
    return _postGames(query);
  }

  /// Fetch a single game by its IGDB id.
  Future<IgdbGameDto?> getById(int id) async {
    final query = 'fields $_fields; where id = $id;';
    final results = await _postGames(query);
    return results.isEmpty ? null : results.first;
  }

  Future<List<IgdbGameDto>> _postGames(String apicalypse) async {
    try {
      return await _send(apicalypse);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token likely revoked server-side — clear the cache and try once
        // more with a fresh exchange.
        tokenManager.invalidate();
        return _send(apicalypse);
      }
      debugPrint('IGDB games lookup failed: $e');
      rethrow;
    }
  }

  Future<List<IgdbGameDto>> _send(String apicalypse) async {
    final token = await tokenManager.getToken();
    final response = await _dio.post<List<dynamic>>(
      '/games',
      data: apicalypse,
      options: Options(
        headers: {
          'Client-ID': tokenManager.clientId,
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(IgdbGameDto.fromJson)
        .toList(growable: false);
  }

  /// Escapes embedded double-quotes in a search term so the Apicalypse
  /// `search "..."` literal stays well-formed.
  static String _escape(String raw) => raw.replaceAll('"', r'\"');
}
