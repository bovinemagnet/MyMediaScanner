/// State of the user's TMDB account connection.
sealed class TmdbConnectionState {
  const TmdbConnectionState();
}

class TmdbDisconnected extends TmdbConnectionState {
  const TmdbDisconnected();
}

class TmdbConnecting extends TmdbConnectionState {
  const TmdbConnecting();
}

class TmdbConnected extends TmdbConnectionState {
  const TmdbConnected({
    required this.accountId,
    required this.username,
  });

  final int accountId;
  final String username;
}

class TmdbExpired extends TmdbConnectionState {
  const TmdbExpired({this.previousUsername});
  final String? previousUsername;
}

class TmdbConnectionError extends TmdbConnectionState {
  const TmdbConnectionError(this.message);
  final String message;
}
