import 'dart:async';

import 'package:mymediascanner/domain/entities/tmdb_approval_callback.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';

/// Long-lived service that listens for `mymediascanner://tmdb-callback`
/// URIs delivered by the system's deep-link plumbing and drives
/// [ConnectTmdbAccountUseCase.finishConnect] when a matching token
/// arrives.
///
/// The handler does not own the URI stream — it accepts one as a
/// constructor dependency so unit tests can drive it with a fake.
/// The Riverpod provider supplies the `app_links` package's stream
/// in production.
class TmdbDeepLinkHandler {
  TmdbDeepLinkHandler({
    required this.connect,
    required this.uriStream,
  });

  final ConnectTmdbAccountUseCase connect;
  final Stream<Uri> uriStream;

  StreamSubscription<Uri>? _sub;
  final _events = StreamController<TmdbDeepLinkEvent>.broadcast();

  /// Stream of high-level events for the dialog and global SnackBar.
  Stream<TmdbDeepLinkEvent> get events => _events.stream;

  /// Subscribe to the URI stream. Idempotent — calling [start] twice
  /// keeps the existing subscription.
  void start() {
    _sub ??= uriStream.listen(_handle);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await _events.close();
  }

  Future<void> _handle(Uri uri) async {
    final parsed = TmdbApprovalCallback.parse(uri);
    switch (parsed) {
      case TmdbApprovalApproved(:final requestToken):
        final pending = connect.pendingRequestToken;
        if (pending == null) {
          _events.add(const TmdbDeepLinkNoPending());
          return;
        }
        if (requestToken != pending) {
          _events.add(const TmdbDeepLinkMismatch(
              'token did not match the pending request'));
          return;
        }
        try {
          final state = await connect.finishConnect();
          if (state is TmdbConnected) {
            _events.add(const TmdbDeepLinkSuccess());
          } else if (state is TmdbConnectionError) {
            _events.add(TmdbDeepLinkMismatch(state.message));
          }
        } catch (e) {
          _events.add(TmdbDeepLinkMismatch(e.toString()));
        }
      case TmdbApprovalDenied():
        connect.cancel();
        _events.add(const TmdbDeepLinkCancelled());
      case TmdbApprovalMalformed(:final reason):
        _events.add(TmdbDeepLinkMismatch(reason));
    }
  }
}
