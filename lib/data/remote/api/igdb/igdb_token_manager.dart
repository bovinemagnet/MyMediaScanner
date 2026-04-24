import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/igdb/models/twitch_token_dto.dart';

/// Manages the Twitch OAuth bearer-token lifecycle for IGDB.
///
/// IGDB is gated behind Twitch's `client_credentials` OAuth flow: the
/// user's Client ID + Client Secret are exchanged at
/// `https://id.twitch.tv/oauth2/token` for a bearer token that typically
/// lives around 60 days. This manager caches the token in memory, refreshes
/// it lazily when expired, and de-duplicates concurrent refresh attempts.
class IgdbTokenManager {
  IgdbTokenManager({
    required this.clientId,
    required this.clientSecret,
    Dio? authDio,
  }) : _authDio = authDio ??
            DioFactory.create(baseUrl: ApiConstants.twitchOAuthBaseUrl);

  final String clientId;
  final String clientSecret;
  final Dio _authDio;

  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// De-duplicates concurrent `getToken()` calls. Without this, parallel
  /// callers whose cached token has expired would each issue their own
  /// `POST /oauth2/token`, wasting quota and racing each other's writes.
  Future<String>? _inFlight;

  /// Returns a valid bearer token, refreshing if needed.
  Future<String> getToken() async {
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }

    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _exchange();
    _inFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight, future)) _inFlight = null;
    }
  }

  Future<String> _exchange() async {
    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        '/oauth2/token',
        queryParameters: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      final dto = TwitchTokenDto.fromJson(response.data ?? {});
      final token = dto.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('Twitch token exchange returned no access_token');
      }

      _cachedToken = token;
      // Refresh one hour before the advertised expiry to avoid racing the
      // boundary. `expiresIn` is seconds; fall back to 24 hours if the
      // response omits it (it shouldn't).
      final lifetime = Duration(
        seconds: (dto.expiresIn ?? 86400) - 3600,
      );
      _tokenExpiry = DateTime.now().add(
        lifetime.isNegative ? const Duration(seconds: 60) : lifetime,
      );
      return token;
    } on Exception catch (e) {
      debugPrint('Twitch OAuth token exchange failed: $e');
      rethrow;
    }
  }

  /// Clears the cached token, forcing a refresh on next call. Use when the
  /// API returns 401 — the token was likely revoked server-side before its
  /// advertised expiry.
  void invalidate() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}
