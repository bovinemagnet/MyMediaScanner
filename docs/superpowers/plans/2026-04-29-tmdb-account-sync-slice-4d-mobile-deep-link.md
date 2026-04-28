# TMDB Account Sync — Slice 4d (Mobile Deep-Link Return) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire a `mymediascanner://tmdb-callback` deep link on Android and iOS so the system browser can return to the app after the user approves the TMDB request token, automatically completing `finishConnect()` without the manual button.

**Architecture:** Add an `app_links` URI stream subscription that lives behind a Riverpod-provided `TmdbDeepLinkHandler` singleton. The handler parses the inbound URI into a sealed `TmdbApprovalCallback`, validates the request token against `ConnectTmdbAccountUseCase.pendingRequestToken`, and on match calls `finishConnect()`. The use case grows an optional `redirectTo` callback that appends `?redirect_to=...` only on mobile. `TmdbConnectDialog` listens to the handler's event stream and auto-dismisses on success; a global SnackBar covers the case where the dialog has been dismissed before the link arrives.

**Tech Stack:** Flutter 3.x, Dart 3 sealed classes + switch expressions, Riverpod 3 Notifier/Provider, `app_links: ^6.x` package, mocktail for tests.

**Source spec:** `docs/superpowers/specs/2026-04-29-tmdb-account-sync-slice-4d-mobile-deep-link-design.md`

---

## File Layout

### Create

| Path | Purpose |
|---|---|
| `lib/domain/entities/tmdb_approval_callback.dart` | Sealed parser of the inbound deep-link URI. Pure Dart. |
| `lib/domain/entities/tmdb_deep_link_event.dart` | Sealed event union emitted by the handler. |
| `lib/data/services/tmdb_deep_link_handler.dart` | Long-lived singleton subscribed to `app_links`. |
| `test/unit/domain/entities/tmdb_approval_callback_test.dart` | Parser tests. |
| `test/unit/data/services/tmdb_deep_link_handler_test.dart` | Handler tests with fake URI stream + mocked use case. |

### Modify

| Path | Change |
|---|---|
| `pubspec.yaml` | Add `app_links: ^6.4.0` dependency. |
| `lib/domain/usecases/connect_tmdb_account_usecase.dart` | Add optional `redirectTo` `Uri Function()?`; append `?redirect_to=...` to approval URL when non-null. |
| `lib/presentation/providers/repository_providers.dart` | Wire `redirectTo` on mobile; add `appLinksUriStreamProvider`, `tmdbDeepLinkHandlerProvider`. |
| `lib/presentation/providers/tmdb_account_sync_provider.dart` | Add `tmdbConnectDialogVisibleProvider` boolean Notifier. |
| `lib/app/app.dart` | Add global `ScaffoldMessenger` key; eagerly read `tmdbDeepLinkHandlerProvider` to start it; wrap router in a small listener widget that surfaces SnackBars when the dialog is closed. |
| `lib/presentation/screens/settings/widgets/tmdb_connect_dialog.dart` | Toggle `tmdbConnectDialogVisibleProvider` in init/dispose; subscribe to handler's event stream and react. |
| `android/app/src/main/AndroidManifest.xml` | Add intent-filter for `mymediascanner://tmdb-callback`. |
| `ios/Runner/Info.plist` | Add `CFBundleURLTypes` for the same scheme. |
| `test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart` | Add `redirect_to` injection tests. |
| `test/widget/screens/settings/widgets/tmdb_connect_dialog_test.dart` | Drive fake event stream and assert reactions. (Create if missing.) |
| `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` | Mobile auto-return paragraph. |

---

## Convention notes

- Pure-domain entities (`TmdbApprovalCallback`, `TmdbDeepLinkEvent`) have no Flutter imports.
- The handler uses `unawaited(...).catchError(...)` for the `finishConnect()` call so a network failure cannot crash the URI listener.
- `app_links` is a single dependency that supports Android, iOS, macOS, Linux, and Windows. We only START the handler on mobile (gated by `PlatformCapability.isMobile`) so desktop platforms are untouched.
- TMDB's approval URL is built in `TmdbAccountSyncRepositoryImpl.startConnect()` (today). The plan keeps that unchanged and appends `redirect_to` in the use case via `Uri.replace(queryParameters: ...)` so the platform decision stays in the presentation/provider layer rather than leaking into the data layer.

---

## Task 1: Add the `app_links` dependency

**Files:** Modify: `pubspec.yaml`

- [ ] **Step 1: Add the dependency**

In `pubspec.yaml`, add inside the `dependencies:` block (alphabetical order — find a sensible spot near `app_links` would land alphabetically between any nearby packages):

```yaml
  app_links: ^6.4.0
```

- [ ] **Step 2: Fetch packages**

Run: `flutter pub get`
Expected: success.

- [ ] **Step 3: Confirm the package landed**

Run: `flutter pub deps --no-dev | grep app_links`
Expected: `app_links 6.4.x`.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat(tmdb-sync): add app_links dependency for deep-link return"
```

---

## Task 2: `TmdbApprovalCallback` sealed parser

**Files:**
- Create: `lib/domain/entities/tmdb_approval_callback.dart`
- Create: `test/unit/domain/entities/tmdb_approval_callback_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/unit/domain/entities/tmdb_approval_callback_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/tmdb_approval_callback.dart';

void main() {
  group('TmdbApprovalCallback.parse', () {
    test('approved=true yields TmdbApprovalApproved', () {
      final uri = Uri.parse(
          'mymediascanner://tmdb-callback?request_token=abc&approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalApproved>());
      expect((result as TmdbApprovalApproved).requestToken, 'abc');
    });

    test('approved=false yields TmdbApprovalDenied', () {
      final uri = Uri.parse(
          'mymediascanner://tmdb-callback?request_token=abc&approved=false');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalDenied>());
      expect((result as TmdbApprovalDenied).requestToken, 'abc');
    });

    test('approved missing yields TmdbApprovalMalformed', () {
      final uri =
          Uri.parse('mymediascanner://tmdb-callback?request_token=abc');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('request_token missing yields TmdbApprovalMalformed', () {
      final uri =
          Uri.parse('mymediascanner://tmdb-callback?approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('wrong host yields TmdbApprovalMalformed', () {
      final uri = Uri.parse(
          'mymediascanner://other-callback?request_token=abc&approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('wrong scheme yields TmdbApprovalMalformed', () {
      final uri =
          Uri.parse('https://tmdb-callback?request_token=abc&approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('approved value is case-insensitive (TRUE / True)', () {
      for (final v in const ['TRUE', 'True', 'true']) {
        final uri = Uri.parse(
            'mymediascanner://tmdb-callback?request_token=x&approved=$v');
        expect(TmdbApprovalCallback.parse(uri), isA<TmdbApprovalApproved>(),
            reason: 'value=$v should approve');
      }
    });
  });
}
```

- [ ] **Step 2: Run the test (will fail — file does not exist)**

Run: `flutter test test/unit/domain/entities/tmdb_approval_callback_test.dart`
Expected: FAIL — `Target of URI doesn't exist`.

- [ ] **Step 3: Implement the entity**

Create `lib/domain/entities/tmdb_approval_callback.dart`:

```dart
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
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/unit/domain/entities/tmdb_approval_callback_test.dart`
Expected: 7/7 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/domain/entities/tmdb_approval_callback.dart test/unit/domain/entities/tmdb_approval_callback_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities/tmdb_approval_callback.dart \
        test/unit/domain/entities/tmdb_approval_callback_test.dart
git commit -m "feat(tmdb-sync): add TmdbApprovalCallback URI parser"
```

---

## Task 3: `TmdbDeepLinkEvent` union

**Files:** Create: `lib/domain/entities/tmdb_deep_link_event.dart`

No tests — pure data carriers, exercised in Task 4.

- [ ] **Step 1: Create the entity**

Create `lib/domain/entities/tmdb_deep_link_event.dart`:

```dart
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
```

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/domain/entities/tmdb_deep_link_event.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/tmdb_deep_link_event.dart
git commit -m "feat(tmdb-sync): add TmdbDeepLinkEvent union"
```

---

## Task 4: `TmdbDeepLinkHandler` service (TDD)

**Files:**
- Create: `lib/data/services/tmdb_deep_link_handler.dart`
- Create: `test/unit/data/services/tmdb_deep_link_handler_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/unit/data/services/tmdb_deep_link_handler_test.dart`:

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/services/tmdb_deep_link_handler.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';

class _MockConnect extends Mock implements ConnectTmdbAccountUseCase {}

void main() {
  late StreamController<Uri> uriController;
  late _MockConnect connect;
  late TmdbDeepLinkHandler handler;
  late List<TmdbDeepLinkEvent> events;

  setUp(() {
    uriController = StreamController<Uri>.broadcast();
    connect = _MockConnect();
    handler = TmdbDeepLinkHandler(
      connect: connect,
      uriStream: uriController.stream,
    );
    events = [];
    handler.events.listen(events.add);
    handler.start();
  });

  tearDown(() async {
    await handler.dispose();
    await uriController.close();
  });

  Future<void> flush() async {
    // Allow the broadcast stream to deliver to listeners.
    await Future<void>.delayed(Duration.zero);
  }

  test('happy path: matching token + approved=true calls finishConnect', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');
    when(() => connect.finishConnect())
        .thenAnswer((_) async => const TmdbConnected(
              accountName: 'paul',
              sessionId: 'sess',
            ));

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=true'));
    await flush();

    verify(() => connect.finishConnect()).called(1);
    expect(events, [isA<TmdbDeepLinkSuccess>()]);
  });

  test('approved=false emits Cancelled and calls connect.cancel', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');
    when(() => connect.cancel()).thenReturn(null);

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=false'));
    await flush();

    verifyNever(() => connect.finishConnect());
    verify(() => connect.cancel()).called(1);
    expect(events, [isA<TmdbDeepLinkCancelled>()]);
  });

  test('token mismatch emits Mismatch without calling finishConnect', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=other&approved=true'));
    await flush();

    verifyNever(() => connect.finishConnect());
    expect(events, [isA<TmdbDeepLinkMismatch>()]);
  });

  test('no pending token emits NoPending', () async {
    when(() => connect.pendingRequestToken).thenReturn(null);

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=true'));
    await flush();

    verifyNever(() => connect.finishConnect());
    expect(events, [isA<TmdbDeepLinkNoPending>()]);
  });

  test('malformed URI emits Mismatch', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');

    uriController.add(Uri.parse('mymediascanner://wrong-host?foo=bar'));
    await flush();

    verifyNever(() => connect.finishConnect());
    expect(events, [isA<TmdbDeepLinkMismatch>()]);
  });

  test('finishConnect failure emits Mismatch', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');
    when(() => connect.finishConnect()).thenAnswer(
        (_) async => const TmdbConnectionError('upstream rejected'));

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=true'));
    await flush();

    verify(() => connect.finishConnect()).called(1);
    expect(events.single, isA<TmdbDeepLinkMismatch>());
    expect((events.single as TmdbDeepLinkMismatch).reason,
        contains('upstream rejected'));
  });
}
```

- [ ] **Step 2: Run the test (will fail — handler does not exist)**

Run: `flutter test test/unit/data/services/tmdb_deep_link_handler_test.dart`
Expected: FAIL — `Target of URI doesn't exist`.

- [ ] **Step 3: Implement the handler**

Create `lib/data/services/tmdb_deep_link_handler.dart`:

```dart
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
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/unit/data/services/tmdb_deep_link_handler_test.dart`
Expected: 6/6 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/data/services/tmdb_deep_link_handler.dart test/unit/data/services/tmdb_deep_link_handler_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/data/services/tmdb_deep_link_handler.dart \
        test/unit/data/services/tmdb_deep_link_handler_test.dart
git commit -m "feat(tmdb-sync): add TmdbDeepLinkHandler driving finishConnect on URI"
```

---

## Task 5: Inject `redirect_to` into `ConnectTmdbAccountUseCase` (TDD)

**Files:**
- Modify: `lib/domain/usecases/connect_tmdb_account_usecase.dart`
- Modify: `test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart`

- [ ] **Step 1: Read the existing test file**

Read `test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart` if it exists. If it does not, the file should be created in this task — note the existing pattern from `connect_tmdb_account_usecase.dart` and follow it.

- [ ] **Step 2: Append failing tests**

Append to (or create) `test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  late _MockRepo repo;
  late List<Uri> launchedUris;

  setUp(() {
    repo = _MockRepo();
    launchedUris = [];
    when(() => repo.startConnect()).thenAnswer((_) async => (
          requestToken: 'tok-1',
          approvalUrl: Uri.parse(
              'https://www.themoviedb.org/authenticate/tok-1'),
        ));
  });

  Future<bool> launch(Uri uri) async {
    launchedUris.add(uri);
    return true;
  }

  group('redirect_to injection', () {
    test('with redirectTo null, the approval URL is unchanged', () async {
      final uc = ConnectTmdbAccountUseCase(
        repo: repo,
        launchUrl: launch,
      );
      await uc.startConnect();
      expect(launchedUris.single.toString(),
          'https://www.themoviedb.org/authenticate/tok-1');
    });

    test('with redirectTo set, ?redirect_to=... is appended', () async {
      final uc = ConnectTmdbAccountUseCase(
        repo: repo,
        launchUrl: launch,
        redirectTo: () => Uri.parse('mymediascanner://tmdb-callback'),
      );
      await uc.startConnect();
      final launched = launchedUris.single;
      expect(launched.queryParameters['redirect_to'],
          'mymediascanner://tmdb-callback');
      expect(launched.path, '/authenticate/tok-1');
    });

    test('redirectTo is invoked at startConnect time, not constructor time',
        () async {
      var calls = 0;
      final uc = ConnectTmdbAccountUseCase(
        repo: repo,
        launchUrl: launch,
        redirectTo: () {
          calls++;
          return Uri.parse('mymediascanner://tmdb-callback');
        },
      );
      expect(calls, 0);
      await uc.startConnect();
      expect(calls, 1);
    });
  });
}
```

- [ ] **Step 3: Run the failing tests**

Run: `flutter test test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart`
Expected: FAIL — `redirectTo` is not a parameter on the use case.

- [ ] **Step 4: Modify the use case**

In `lib/domain/usecases/connect_tmdb_account_usecase.dart`, change the class to accept `redirectTo` and apply it inside `startConnect`:

```dart
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

  Future<void> startConnect() async {
    final r = await repo.startConnect();
    _pendingRequestToken = r.requestToken;
    final approvalUri = _withRedirectTo(r.approvalUrl);
    await launchUrl(approvalUri);
  }

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

  Future<void> reopenApproval() async {
    final token = _pendingRequestToken;
    if (token == null) return;
    final base =
        Uri.parse('https://www.themoviedb.org/authenticate/$token');
    await launchUrl(_withRedirectTo(base));
  }

  void cancel() {
    _pendingRequestToken = null;
  }

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
```

- [ ] **Step 5: Run the new tests**

Run: `flutter test test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart`
Expected: 3/3 new tests pass.

- [ ] **Step 6: Run the full test suite (regression check)**

Run: `flutter test test/unit/domain/usecases/`
Expected: all pass — no upstream callers should break, since `redirectTo` is optional.

- [ ] **Step 7: Run analyzer**

Run: `flutter analyze lib/domain/usecases/connect_tmdb_account_usecase.dart test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart`
Expected: zero issues.

- [ ] **Step 8: Commit**

```bash
git add lib/domain/usecases/connect_tmdb_account_usecase.dart \
        test/unit/domain/usecases/connect_tmdb_account_usecase_test.dart
git commit -m "feat(tmdb-sync): inject redirect_to into TMDB approval URL"
```

---

## Task 6: Wire providers (deep-link handler + redirect-to + dialog visibility)

**Files:**
- Modify: `lib/presentation/providers/repository_providers.dart`
- Modify: `lib/presentation/providers/tmdb_account_sync_provider.dart`

- [ ] **Step 1: Read both files**

Skim `lib/presentation/providers/repository_providers.dart` (where `connectTmdbAccountUseCaseProvider` already lives — around line 265). Skim `lib/presentation/providers/tmdb_account_sync_provider.dart` for the existing notifier patterns.

- [ ] **Step 2: Add the URI stream and handler providers**

In `lib/presentation/providers/repository_providers.dart`, near the top of the TMDB account-sync section (after the existing imports), add:

```dart
import 'package:app_links/app_links.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/data/services/tmdb_deep_link_handler.dart';
```

Then change the existing `connectTmdbAccountUseCaseProvider` to inject `redirectTo` on mobile:

```dart
final connectTmdbAccountUseCaseProvider =
    Provider<ConnectTmdbAccountUseCase>((ref) {
  return ConnectTmdbAccountUseCase(
    repo: ref.watch(tmdbAccountSyncRepositoryProvider),
    launchUrl: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
    redirectTo: PlatformCapability.isMobile
        ? () => Uri.parse('mymediascanner://tmdb-callback')
        : null,
  );
});
```

Then add the two new providers below the use case providers:

```dart
/// Stream of inbound `mymediascanner://...` URIs from the system's
/// deep-link plumbing. Tests override this to drive a fake stream.
final appLinksUriStreamProvider = Provider<Stream<Uri>>((ref) {
  return AppLinks().uriLinkStream;
});

/// Long-lived deep-link handler. Started eagerly on mobile from
/// [App.build] so the URI listener is alive before any approval URL
/// is launched.
final tmdbDeepLinkHandlerProvider = Provider<TmdbDeepLinkHandler>((ref) {
  final handler = TmdbDeepLinkHandler(
    connect: ref.watch(connectTmdbAccountUseCaseProvider),
    uriStream: ref.watch(appLinksUriStreamProvider),
  );
  if (PlatformCapability.isMobile) handler.start();
  ref.onDispose(handler.dispose);
  return handler;
});
```

- [ ] **Step 3: Add `tmdbConnectDialogVisibleProvider`**

In `lib/presentation/providers/tmdb_account_sync_provider.dart`, append:

```dart
/// Tracks whether [TmdbConnectDialog] is currently mounted. The
/// global deep-link SnackBar listener uses this to suppress
/// duplicate notifications when the dialog is up (the dialog will
/// surface its own feedback).
class TmdbConnectDialogVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

final tmdbConnectDialogVisibleProvider =
    NotifierProvider<TmdbConnectDialogVisibleNotifier, bool>(
        TmdbConnectDialogVisibleNotifier.new);
```

If the existing file's imports don't already pull `flutter_riverpod`, add it.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/presentation/providers/repository_providers.dart lib/presentation/providers/tmdb_account_sync_provider.dart`
Expected: zero issues.

- [ ] **Step 5: Run the full test suite (regression)**

Run: `flutter test`
Expected: all tests pass. The handler provider is constructed on-demand; no test should accidentally trigger a real `app_links` stream because none of them read `tmdbDeepLinkHandlerProvider` yet.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/providers/repository_providers.dart \
        lib/presentation/providers/tmdb_account_sync_provider.dart
git commit -m "feat(tmdb-sync): wire deep-link handler + redirect_to providers"
```

---

## Task 7: Hook the dialog to the handler's events

**Files:** Modify: `lib/presentation/screens/settings/widgets/tmdb_connect_dialog.dart`

- [ ] **Step 1: Modify the dialog**

Replace the existing `_TmdbConnectDialogState` with a version that toggles the visibility provider in init/dispose and listens to the handler's event stream:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

class TmdbConnectDialog extends ConsumerStatefulWidget {
  const TmdbConnectDialog({super.key});

  @override
  ConsumerState<TmdbConnectDialog> createState() =>
      _TmdbConnectDialogState();
}

class _TmdbConnectDialogState extends ConsumerState<TmdbConnectDialog> {
  bool _busy = false;
  String? _error;
  StreamSubscription<TmdbDeepLinkEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    // Mark the dialog as visible so the global SnackBar listener
    // suppresses duplicate notifications while we're up.
    Future.microtask(() {
      if (!mounted) return;
      ref.read(tmdbConnectDialogVisibleProvider.notifier).show();
    });
    // Listen to the deep-link handler events for hands-free completion.
    _eventSub = ref
        .read(tmdbDeepLinkHandlerProvider)
        .events
        .listen(_onDeepLinkEvent);
    _start();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    // Hide flag; the read happens before dispose completes.
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(tmdbConnectDialogVisibleProvider.notifier).hide();
    super.dispose();
  }

  void _onDeepLinkEvent(TmdbDeepLinkEvent event) {
    if (!mounted) return;
    switch (event) {
      case TmdbDeepLinkSuccess():
        // The handler already called finishConnect — pop with the
        // connection state pulled from the connection notifier.
        final state =
            ref.read(tmdbAccountConnectionProvider);
        if (state is TmdbConnected) {
          Navigator.of(context).pop(state);
        } else {
          // Handler said success, notifier hasn't caught up yet —
          // just dismiss; the section card will rebuild on the next
          // notifier tick.
          Navigator.of(context).pop();
        }
      case TmdbDeepLinkCancelled():
        setState(() {
          _busy = false;
          _error = 'Approval was denied — try again.';
        });
      case TmdbDeepLinkMismatch(:final reason):
        setState(() {
          _busy = false;
          _error = 'Could not complete connection: $reason';
        });
      case TmdbDeepLinkNoPending():
        // Dialog is up so a pending token must exist; ignore.
        break;
    }
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(connectTmdbAccountUseCaseProvider).startConnect();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = await ref
        .read(connectTmdbAccountUseCaseProvider)
        .finishConnect();
    if (!mounted) return;
    if (state is TmdbConnected) {
      ref.read(tmdbAccountConnectionProvider.notifier).setState(state);
      Navigator.of(context).pop(state);
    } else if (state is TmdbConnectionError) {
      setState(() {
        _busy = false;
        _error = state.message;
      });
    }
  }

  Future<void> _reopen() async {
    await ref.read(connectTmdbAccountUseCaseProvider).reopenApproval();
  }

  void _cancel() {
    ref.read(connectTmdbAccountUseCaseProvider).cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect to TMDB'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We have opened TMDB in your browser. Sign in and approve '
            'MyMediaScanner. On mobile we will detect your approval '
            'automatically; on desktop, return here and click Continue.',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: _busy ? null : _reopen,
            child: const Text('Re-open page')),
        TextButton(
            onPressed: _busy ? null : _cancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy ? null : _continue,
          child: const Text("I've approved it — continue"),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_connect_dialog.dart`
Expected: zero issues.

- [ ] **Step 3: Run the existing widget tests**

Run: `flutter test test/widget/screens/settings/`
Expected: all existing dialog tests pass. (If none exist for this dialog yet, that's fine — Task 8 adds them.)

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_connect_dialog.dart
git commit -m "feat(tmdb-sync): hook TmdbConnectDialog to deep-link events"
```

---

## Task 8: Widget test for dialog deep-link reactions (TDD)

**Files:**
- Create or modify: `test/widget/screens/settings/widgets/tmdb_connect_dialog_test.dart`

- [ ] **Step 1: Write the test**

Create `test/widget/screens/settings/widgets/tmdb_connect_dialog_test.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/services/tmdb_deep_link_handler.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_connect_dialog.dart';

class _MockConnect extends Mock implements ConnectTmdbAccountUseCase {}

class _FakeHandler implements TmdbDeepLinkHandler {
  final _controller = StreamController<TmdbDeepLinkEvent>.broadcast();

  @override
  Stream<TmdbDeepLinkEvent> get events => _controller.stream;

  void emit(TmdbDeepLinkEvent e) => _controller.add(e);

  @override
  // ignore: unused_element
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _MockConnect connect;
  late _FakeHandler handler;

  setUp(() {
    connect = _MockConnect();
    when(() => connect.startConnect()).thenAnswer((_) async {});
    when(() => connect.cancel()).thenReturn(null);
    handler = _FakeHandler();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        connectTmdbAccountUseCaseProvider.overrideWithValue(connect),
        tmdbDeepLinkHandlerProvider.overrideWithValue(handler),
      ],
      child: const MaterialApp(
        home: Scaffold(body: TmdbConnectDialog()),
      ),
    );
  }

  testWidgets('dismisses on TmdbDeepLinkSuccess', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(); // initState future.microtask

    handler.emit(const TmdbDeepLinkSuccess());
    await tester.pumpAndSettle();

    expect(find.byType(TmdbConnectDialog), findsNothing);
  });

  testWidgets('shows denied message on TmdbDeepLinkCancelled', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();

    handler.emit(const TmdbDeepLinkCancelled());
    await tester.pump();

    expect(find.textContaining('Approval was denied'), findsOneWidget);
  });

  testWidgets('shows mismatch reason on TmdbDeepLinkMismatch', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();

    handler.emit(const TmdbDeepLinkMismatch('bad token'));
    await tester.pump();

    expect(find.textContaining('bad token'), findsOneWidget);
  });
}
```

The `_FakeHandler` uses `noSuchMethod` so it can satisfy `TmdbDeepLinkHandler` without re-implementing `start`, `dispose`, etc. — only `events` is touched in the dialog.

- [ ] **Step 2: Run the new widget tests**

Run: `flutter test test/widget/screens/settings/widgets/tmdb_connect_dialog_test.dart`
Expected: 3/3 pass.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze test/widget/screens/settings/widgets/tmdb_connect_dialog_test.dart`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add test/widget/screens/settings/widgets/tmdb_connect_dialog_test.dart
git commit -m "test(tmdb-sync): cover TmdbConnectDialog deep-link reactions"
```

---

## Task 9: Global ScaffoldMessenger key + SnackBar fallback

**Files:** Modify: `lib/app/app.dart`

- [ ] **Step 1: Replace `app.dart`**

Update `lib/app/app.dart` to add a global `ScaffoldMessenger` key, eagerly start the deep-link handler, and surface SnackBars when the dialog is closed:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/router.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// Global key so the deep-link handler can show SnackBars without
/// requiring a `BuildContext`.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Eagerly construct the handler so the URI listener is alive
    // before any approval URL is launched. Provider's `onDispose`
    // owns teardown.
    ref.read(tmdbDeepLinkHandlerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final choice = ref.watch(themeChoiceProvider);
    final (light, dark) = switch (choice.family) {
      ThemeFamily.classic => (AppTheme.light(), AppTheme.dark()),
      ThemeFamily.popcorn => (AppTheme.popcornLight(), AppTheme.popcornDark()),
    };

    // Surface a SnackBar when the deep link arrives and the dialog
    // is not currently mounted. The dialog handles its own UI when up.
    ref.listen<TmdbDeepLinkEvent?>(
      _deepLinkEventStreamProvider,
      (_, event) {
        if (event == null) return;
        final dialogVisible = ref.read(tmdbConnectDialogVisibleProvider);
        if (dialogVisible) return;
        final messenger = rootScaffoldMessengerKey.currentState;
        if (messenger == null) return;
        switch (event) {
          case TmdbDeepLinkSuccess():
            messenger.showSnackBar(const SnackBar(
                content: Text('Connected to TMDB')));
          case TmdbDeepLinkCancelled():
            messenger.showSnackBar(const SnackBar(
                content: Text('TMDB approval was denied')));
          case TmdbDeepLinkMismatch():
            // Silent — the most common cause is a stale link arriving
            // long after the user dismissed the flow. Don't paper over
            // the screen.
            break;
          case TmdbDeepLinkNoPending():
            messenger.showSnackBar(const SnackBar(
                content: Text(
                    'Approval link arrived but no connection was in progress — please tap Connect again.')));
        }
      },
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: light,
      darkTheme: dark,
      themeMode: themeModeFrom(choice.brightness),
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Bridges the deep-link handler's broadcast stream into Riverpod so
/// `ref.listen` can observe events.
final _deepLinkEventStreamProvider =
    StreamProvider.autoDispose<TmdbDeepLinkEvent>((ref) {
  return ref.watch(tmdbDeepLinkHandlerProvider).events;
});
```

Note: `ref.listen<TmdbDeepLinkEvent?>` watches an `AsyncValue<TmdbDeepLinkEvent>?`, so the listener actually needs to be `ref.listen<AsyncValue<TmdbDeepLinkEvent>>` — adjust to the form below if the simple version doesn't compile. The intent is to react to each emission once.

```dart
ref.listen<AsyncValue<TmdbDeepLinkEvent>>(
  _deepLinkEventStreamProvider,
  (_, next) {
    next.whenData((event) {
      // ... same switch as above ...
    });
  },
);
```

Use whichever shape compiles cleanly with your Riverpod 3 version. Both are equivalent.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/app/app.dart`
Expected: zero issues.

- [ ] **Step 3: Run the test suite (regression)**

Run: `flutter test`
Expected: all pass. The new `_deepLinkEventStreamProvider` is `autoDispose` so widget tests that don't read it pay no cost.

- [ ] **Step 4: Commit**

```bash
git add lib/app/app.dart
git commit -m "feat(tmdb-sync): start deep-link handler + global SnackBar fallback"
```

---

## Task 10: Android intent-filter

**Files:** Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add the intent-filter**

In `android/app/src/main/AndroidManifest.xml`, find the `<activity android:name=".MainActivity">` block. Inside it, alongside the existing `<intent-filter>` for `action.MAIN`/`category.LAUNCHER`, add:

```xml
<intent-filter android:autoVerify="false">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="mymediascanner"
        android:host="tmdb-callback" />
</intent-filter>
```

- [ ] **Step 2: Build the APK to confirm the manifest is valid**

Run: `flutter build apk --debug --flavor dev`
Expected: build succeeds. The manifest merger should accept the additional intent-filter.

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml
git commit -m "feat(tmdb-sync): register Android intent-filter for tmdb-callback scheme"
```

---

## Task 11: iOS URL scheme

**Files:** Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: Add the CFBundleURLTypes entry**

In `ios/Runner/Info.plist`, add (or extend if a `CFBundleURLTypes` array already exists) this block before the closing `</dict>` of the root dict:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.mymediascanner.tmdb-callback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mymediascanner</string>
        </array>
    </dict>
</array>
```

If a `<key>CFBundleURLTypes</key>` already exists in the file, append a new `<dict>` to its `<array>` rather than declaring the key twice.

- [ ] **Step 2: Validate the plist**

Run: `plutil -lint ios/Runner/Info.plist`
Expected: `OK`. (If `plutil` isn't available — Linux host — skip this step and rely on the build step in the next slice CI.)

If `plutil` is not on the host (Linux), use `python3 -c "import plistlib; plistlib.load(open('ios/Runner/Info.plist','rb'))"` as a structural validator.

- [ ] **Step 3: Commit**

```bash
git add ios/Runner/Info.plist
git commit -m "feat(tmdb-sync): register iOS URL scheme for tmdb-callback"
```

---

## Task 12: Update user docs

**Files:** Modify: `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc`

- [ ] **Step 1: Find the "Connecting Your Account" or equivalent section**

Open `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc`. Find the section that describes the connect flow (likely titled "Connecting Your Account" or "Connect" — match the actual heading).

- [ ] **Step 2: Append a paragraph about mobile auto-return**

Add a paragraph at the end of that section:

```adoc
=== Automatic return on mobile

On Android and iOS the app registers a custom URL scheme (`mymediascanner://tmdb-callback`).
After you approve in the system browser, TMDB redirects back to the app and the connection completes automatically — usually within a couple of seconds — no need to tap *I've approved it — continue*.

The manual button remains as a fallback for desktop and for the rare case where the deep link fails (e.g. the browser blocks the redirect).

If you force-quit MyMediaScanner while the browser is still open, the in-memory request token is lost and you will see *Approval link arrived but no connection was in progress — please tap Connect again.* when the deep link fires; restart the connect flow to recover.
```

Match the prose tone of the surrounding page (calm, instructional, British spelling).

- [ ] **Step 3: Validate the Antora build**

Run: `npx antora local-antora-playbook-search.yml`
Expected: clean exit, no warnings.

- [ ] **Step 4: Commit**

```bash
git add src/docs/modules/ROOT/pages/tmdb-account-sync.adoc
git commit -m "docs: note automatic return on mobile after TMDB approval"
```

---

## Task 13: Final verification

**Files:** none (read-only)

- [ ] **Step 1: Branch + HEAD check**

Run: `git branch --show-current` — must be `feat/tmdb-account-sync-slice-4d-mobile-deep-link`.
Run: `git log --oneline main..HEAD | wc -l` — expect 13 commits (one per task plus the design + plan docs that should already be on the branch from before execution started).

- [ ] **Step 2: Analyzer**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 3: Test suite**

Run: `flutter test`
Expected: all pass. The slice 4a baseline was 1395 passing; this slice adds ~16 new tests across the parser (7), handler (6), use case (3), and dialog widget (3) → expect ~1411 passing.

- [ ] **Step 4: Linux build**

Run: `flutter build linux --debug`
Expected: succeeds. (Linux is a desktop platform so the deep-link handler stays inert; this is mostly a smoke test that the new providers don't break the build on platforms where `app_links` isn't actively used.)

- [ ] **Step 5: Android build**

Run: `flutter build apk --debug --flavor dev`
Expected: succeeds. The new intent-filter must merge cleanly.

- [ ] **Step 6: iOS / macOS**

Skip on Linux host. Document as `SKIPPED (host is Linux)`.

- [ ] **Step 7: Manual inspection (read-only)**

Confirm:

1. `lib/domain/entities/tmdb_approval_callback.dart` — sealed parser with three concrete subclasses.
2. `lib/domain/entities/tmdb_deep_link_event.dart` — four event subclasses.
3. `lib/data/services/tmdb_deep_link_handler.dart` — `start()`, `dispose()`, `events`, `_handle()`.
4. `lib/domain/usecases/connect_tmdb_account_usecase.dart` — `redirectTo` ctor param + `_withRedirectTo` helper.
5. `lib/presentation/providers/repository_providers.dart` — `appLinksUriStreamProvider`, `tmdbDeepLinkHandlerProvider`, `redirectTo` injection.
6. `lib/presentation/providers/tmdb_account_sync_provider.dart` — `tmdbConnectDialogVisibleProvider`.
7. `lib/app/app.dart` — global `scaffoldMessengerKey`, eager handler read, `ref.listen` SnackBar fallback.
8. `lib/presentation/screens/settings/widgets/tmdb_connect_dialog.dart` — visibility flag toggle, event-stream subscription, switch on `TmdbDeepLinkEvent`.
9. `android/app/src/main/AndroidManifest.xml` — new intent-filter with `mymediascanner` / `tmdb-callback`.
10. `ios/Runner/Info.plist` — `CFBundleURLTypes` entry with `mymediascanner` scheme.
11. `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` — auto-return paragraph.

- [ ] **Step 8: Final report**

Branch: `feat/tmdb-account-sync-slice-4d-mobile-deep-link`
HEAD: `<SHA>`
Commits since main: `<count>`
Test results: `<summary>`
Linux build: `<PASS/FAIL>`
Android build: `<PASS/FAIL>`
iOS build: `SKIPPED (Linux host)`
macOS build: `SKIPPED (Linux host)`
Manual inspection: `<PASS/FAIL with notes>`

Status:
- DONE — all green.
- DONE_WITH_CONCERNS — list any failing or skipped checks.

---

## Self-review

- **Spec coverage:** Each spec section maps to a task. Parser (Task 2), event union (Task 3), handler (Task 4), redirect_to (Task 5), provider wiring (Task 6), dialog hookup (Task 7), dialog tests (Task 8), global SnackBar (Task 9), Android (Task 10), iOS (Task 11), docs (Task 12), verification (Task 13). The `app_links` dependency add is Task 1.
- **Placeholder scan:** No `TBD`, `TODO`, or "implement later". Every step contains the actual code or command. The Riverpod `ref.listen` block in Task 9 includes a fallback shape because the exact compile shape can vary slightly between Riverpod 3 versions; both forms are spelled out.
- **Type consistency:** `TmdbApprovalCallback`, `TmdbDeepLinkEvent` (and concrete subtypes), `TmdbDeepLinkHandler`, `RedirectToFn`, `tmdbDeepLinkHandlerProvider`, `appLinksUriStreamProvider`, `tmdbConnectDialogVisibleProvider`, `_deepLinkEventStreamProvider`, `rootScaffoldMessengerKey` are all named consistently across tasks.
- **Test coverage:** Parser 7 cases, handler 6 cases, use case 3 cases, dialog widget 3 cases, plus build/analyze/regression checks. Hits every branch in the handler `switch`.
- **No new domain *concepts* leaking out of scope:** the only new domain types are the parser and the event union — both narrowly scoped to this feature. No schema migration. No changes to existing repository behaviour.
