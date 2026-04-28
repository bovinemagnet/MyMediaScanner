import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

typedef LaunchUrlFn = Future<bool> Function(Uri uri);

/// Returns the URI that TMDB should redirect to after the user
/// approves. Return `null` to suppress the `redirect_to` param
/// (e.g. on desktop where no scheme handler exists).
typedef RedirectToFn = Uri? Function();

class ConnectTmdbAccountUseCase {
  ConnectTmdbAccountUseCase({
    required this.repo,
    required this.launchUrl,
    this.redirectTo,
  });

  final ITmdbAccountSyncRepository repo;
  final LaunchUrlFn launchUrl;
  final RedirectToFn? redirectTo;

  String? _pendingRequestToken;

  String? get pendingRequestToken => _pendingRequestToken;

  /// Step 1 — request a token and open the approval URL in the
  /// system browser.
  Future<void> startConnect() async {
    final r = await repo.startConnect();
    _pendingRequestToken = r.requestToken;
    final approvalUri = _withRedirectTo(r.approvalUrl);
    await launchUrl(approvalUri);
  }

  /// Step 2 — call this after the user clicks "I've approved it".
  /// The pending token from [startConnect] is consumed.
  Future<TmdbConnectionState> finishConnect() async {
    final token = _pendingRequestToken;
    if (token == null) {
      return const TmdbConnectionError(
          'No pending token. Click Connect first.');
    }
    final state = await repo.finishConnect(token);
    if (state is TmdbConnected) _pendingRequestToken = null;
    return state;
  }

  /// Re-open the same approval page if the user closed it.
  Future<void> reopenApproval() async {
    final token = _pendingRequestToken;
    if (token == null) return;
    final base =
        Uri.parse('https://www.themoviedb.org/authenticate/$token');
    await launchUrl(_withRedirectTo(base));
  }

  /// Drop the pending token without calling the repo.
  void cancel() {
    _pendingRequestToken = null;
  }

  // For tests only — sets the pending token without calling the repo.
  void debugSetPendingToken(String token) {
    _pendingRequestToken = token;
  }

  Uri _withRedirectTo(Uri base) {
    final fn = redirectTo;
    if (fn == null) return base;
    final target = fn();
    if (target == null) return base;
    final params = Map<String, String>.from(base.queryParameters)
      ..['redirect_to'] = target.toString();
    return base.replace(queryParameters: params);
  }
}
