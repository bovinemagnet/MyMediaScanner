import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/tvdb/models/tvdb_series_dto.dart';

/// Manages TVDB API JWT token lifecycle.
///
/// Tokens are valid for 1 month. This manager caches the token in memory
/// and refreshes it lazily when expired or missing.
class TvdbTokenManager {
  TvdbTokenManager({required this.apiKey, Dio? loginDio})
      : _loginDio = loginDio ??
            DioFactory.create(baseUrl: ApiConstants.tvdbBaseUrl);

  final String apiKey;
  final Dio _loginDio;

  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Returns a valid JWT token, refreshing if needed.
  Future<String> getToken() async {
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }

    try {
      final response = await _loginDio.post<Map<String, dynamic>>(
        '/login',
        data: TvdbLoginRequestDto(apikey: apiKey).toJson(),
      );

      final loginResponse =
          TvdbLoginResponseDto.fromJson(response.data ?? {});
      final token = loginResponse.data?.token;

      if (token == null || token.isEmpty) {
        throw Exception('TVDB login returned no token');
      }

      _cachedToken = token;
      // Tokens are valid for 1 month; refresh after 25 days for safety
      _tokenExpiry = DateTime.now().add(const Duration(days: 25));
      return token;
    } on Exception catch (e) {
      debugPrint('TVDB token refresh failed: $e');
      rethrow;
    }
  }

  /// Clears the cached token, forcing a refresh on next call.
  void invalidate() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}
