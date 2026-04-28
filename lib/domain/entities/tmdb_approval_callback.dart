/// Parsed shape of a `mymediascanner://tmdb-callback?...` deep link
/// that returns from TMDB's approval page.
sealed class TmdbApprovalCallback {
  const TmdbApprovalCallback();

  /// Parses [uri] into one of the concrete subtypes. The URI must use
  /// scheme `mymediascanner` and host `tmdb-callback`; anything else
  /// returns a [TmdbApprovalMalformed].
  factory TmdbApprovalCallback.parse(Uri uri) {
    if (uri.scheme != 'mymediascanner') {
      return const TmdbApprovalMalformed('unexpected scheme');
    }
    if (uri.host != 'tmdb-callback') {
      return const TmdbApprovalMalformed('unexpected host');
    }
    final token = uri.queryParameters['request_token'];
    if (token == null || token.isEmpty) {
      return const TmdbApprovalMalformed('missing request_token');
    }
    final approvedRaw = uri.queryParameters['approved'];
    if (approvedRaw == null) {
      return const TmdbApprovalMalformed('missing approved flag');
    }
    final approved = approvedRaw.toLowerCase() == 'true';
    return approved
        ? TmdbApprovalApproved(requestToken: token)
        : TmdbApprovalDenied(requestToken: token);
  }
}

class TmdbApprovalApproved extends TmdbApprovalCallback {
  const TmdbApprovalApproved({required this.requestToken});
  final String requestToken;
}

class TmdbApprovalDenied extends TmdbApprovalCallback {
  const TmdbApprovalDenied({required this.requestToken});
  final String requestToken;
}

class TmdbApprovalMalformed extends TmdbApprovalCallback {
  const TmdbApprovalMalformed(this.reason);
  final String reason;
}
