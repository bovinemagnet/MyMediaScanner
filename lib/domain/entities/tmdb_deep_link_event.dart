/// Events emitted by [TmdbDeepLinkHandler] in response to inbound
/// `mymediascanner://tmdb-callback` URIs. The dialog and global
/// SnackBar listener react to these.
sealed class TmdbDeepLinkEvent {
  const TmdbDeepLinkEvent();
}

class TmdbDeepLinkSuccess extends TmdbDeepLinkEvent {
  const TmdbDeepLinkSuccess();
}

class TmdbDeepLinkCancelled extends TmdbDeepLinkEvent {
  const TmdbDeepLinkCancelled();
}

class TmdbDeepLinkMismatch extends TmdbDeepLinkEvent {
  const TmdbDeepLinkMismatch(this.reason);
  final String reason;
}

class TmdbDeepLinkNoPending extends TmdbDeepLinkEvent {
  const TmdbDeepLinkNoPending();
}
