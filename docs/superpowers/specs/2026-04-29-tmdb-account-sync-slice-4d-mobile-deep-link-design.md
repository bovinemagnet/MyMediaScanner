# TMDB Account Sync — Slice 4d (Mobile Deep-Link Return) Design Spec

> **Author:** Paul Snow
> **Date:** 2026-04-29
> **Version:** 0.0.0
> **Status:** Approved

## Goal

When a user approves the TMDB request token in the system browser on Android or iOS, the browser bounces back into MyMediaScanner via a custom URL scheme, and the app automatically completes the connection. Today the user must manually return to the app and tap *I've approved it — continue*. After this slice, that button still exists as a fallback (for desktop and for cases where the deep link fails) but the mobile happy path is hands-free.

## Non-goals

- Desktop deep-link return (Linux, Windows, macOS keep the manual button — see "Out of scope" below).
- Universal Links / App Links over https. Slice 4d ships with a custom URL scheme (`mymediascanner://tmdb-callback`). Hardening with a verified-domain App Link is left for a future slice if the app ever ships under a verified domain.
- Persisting the pending request token across app kill. The in-memory pending token is sufficient for the realistic flow; if the OS kills the app while the browser is open, the user starts the flow again. Documented as a known limitation.

## Architecture overview

```
ConnectTmdbAccountUseCase.startConnect()
  └─→ append `?redirect_to=mymediascanner://tmdb-callback` (mobile only)
  └─→ launchUrl(approvalUrl)

User approves on TMDB in browser
  ↓
TMDB redirects to `mymediascanner://tmdb-callback?request_token=<X>&approved=true`
  ↓
Android intent-filter / iOS CFBundleURLTypes routes it to the app
  ↓
app_links stream emits the URI
  ↓
TmdbDeepLinkHandler (singleton) parses + validates
  ├─ token matches pending + approved=true
  │   └─→ ConnectTmdbAccountUseCase.finishConnect() + emit success event
  └─ mismatch / cancelled / no-pending
      └─→ emit corresponding event, do not touch the use case
```

## Components

### `TmdbApprovalCallback` (domain entity, new)

Pure parser of the redirect URL's query params.

```dart
sealed class TmdbApprovalCallback {
  const TmdbApprovalCallback();

  /// Parses [uri] into one of the concrete subtypes. Returns
  /// [TmdbApprovalMalformed] for any URI that doesn't match the expected
  /// shape (host != tmdb-callback, missing request_token, etc.).
  factory TmdbApprovalCallback.parse(Uri uri) { ... }
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

Located at `lib/domain/entities/tmdb_approval_callback.dart`. No dependencies on Flutter — pure Dart.

### `TmdbDeepLinkEvent` (domain entity, new)

Discriminated union emitted by the handler so the dialog and global SnackBar can react.

```dart
sealed class TmdbDeepLinkEvent {}
class TmdbDeepLinkSuccess extends TmdbDeepLinkEvent {}
class TmdbDeepLinkCancelled extends TmdbDeepLinkEvent {}
class TmdbDeepLinkMismatch extends TmdbDeepLinkEvent {
  TmdbDeepLinkMismatch(this.reason);
  final String reason;
}
class TmdbDeepLinkNoPending extends TmdbDeepLinkEvent {}
```

Located at `lib/domain/entities/tmdb_deep_link_event.dart`.

### `TmdbDeepLinkHandler` (service, new)

Long-lived singleton subscribed to the `app_links` URI stream once on app startup. Mobile-only — on desktop the handler is constructed but its `start()` method is a no-op.

```dart
class TmdbDeepLinkHandler {
  TmdbDeepLinkHandler({
    required this.connect,
    required this.uriStream, // injected so tests can drive the stream
  });

  final ConnectTmdbAccountUseCase connect;
  final Stream<Uri> uriStream;

  StreamSubscription<Uri>? _sub;
  final _events = StreamController<TmdbDeepLinkEvent>.broadcast();

  Stream<TmdbDeepLinkEvent> get events => _events.stream;

  void start() { ... } // subscribe to uriStream, call _handle on each
  Future<void> dispose() async { ... }
  Future<void> _handle(Uri uri) async { ... } // parse + dispatch
}
```

Located at `lib/data/services/tmdb_deep_link_handler.dart`.

The handler:

1. Parses the URI via `TmdbApprovalCallback.parse(uri)`.
2. Skips the URI silently if it isn't a `mymediascanner://tmdb-callback` (defensive — `app_links` only emits URIs the app registered, but a malformed payload is possible).
3. For `TmdbApprovalApproved`:
   - If `connect.pendingRequestToken == null` → emit `TmdbDeepLinkNoPending`.
   - If `requestToken != connect.pendingRequestToken` → emit `TmdbDeepLinkMismatch('token did not match the pending request')`.
   - Else → `await connect.finishConnect()` → on `TmdbConnected` emit `TmdbDeepLinkSuccess`; on error emit `TmdbDeepLinkMismatch(error.message)`.
4. For `TmdbApprovalDenied` → emit `TmdbDeepLinkCancelled` and call `connect.cancel()` to drop the pending token.
5. For `TmdbApprovalMalformed` → emit `TmdbDeepLinkMismatch(reason)`.

### `app_links` package integration

Add `app_links: ^6.x` to `pubspec.yaml`. Wire it in a Riverpod provider:

```dart
final appLinksUriStreamProvider = Provider<Stream<Uri>>((ref) {
  return AppLinks().uriLinkStream; // re-emits a stream of Uri events
});

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

The handler is started by reading the provider eagerly from `App.build()` (see *App startup* below).

### `ConnectTmdbAccountUseCase` (modified)

Two changes:

1. Inject a `String? Function()? redirectTo` callback (defaults to null on desktop). When non-null, append `&redirect_to=<encoded>` to the approval URL via `Uri.parse(...).replace(queryParameters: {...})`. This keeps the use case platform-agnostic — the provider supplies the callback that returns the mobile redirect URI on mobile, null elsewhere.

2. No change to `finishConnect()`, `cancel()`, or `pendingRequestToken` — the deep-link handler reuses the existing API.

The provider in `repository_providers.dart`:

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

### `TmdbConnectDialog` (modified)

While the dialog is open it subscribes to `tmdbDeepLinkHandlerProvider`'s event stream and reacts:

- `TmdbDeepLinkSuccess` → close the dialog with `Navigator.pop(true)`, show a SnackBar via the global `ScaffoldMessenger`: *"Connected to TMDB"*.
- `TmdbDeepLinkCancelled` → show inline text *"Approval was denied — try again."* on the dialog. The Connect button re-enables.
- `TmdbDeepLinkMismatch(reason)` → show inline text *"Could not complete connection: \<reason\>"*. Dialog stays open with the manual button as fallback.
- `TmdbDeepLinkNoPending` → ignored (the dialog is up, so a pending token must exist; this branch only fires when the dialog isn't up).

### Global SnackBar fallback

When the deep link fires while no dialog is up (e.g. user backgrounded the app and tapped home before the link arrived), the success / failure feedback needs a place to land.

- Add a top-level `GlobalKey<ScaffoldMessengerState>` in `lib/app/app.dart` and pass it to `MaterialApp.router(scaffoldMessengerKey: ...)`.
- A small startup widget (e.g. a `ConsumerWidget` wrapping the router) listens to `tmdbDeepLinkHandlerProvider.events` and, when the dialog is **not** up, surfaces a SnackBar through that key.
- "Dialog up" is determined by tracking a route observer or, simpler, by routing all deep-link events through the global SnackBar and letting the dialog also react — duplicate notifications would be tolerable, but to avoid them the handler exposes a `bool isDialogActive` setter that the dialog flips while open. When `true`, the global listener skips the SnackBar.

(Simplest workable plan: dialog listener wins when up, global listener runs when down. Implement the gate via a small `tmdbConnectDialogVisibleProvider` Riverpod boolean toggled in `initState` / `dispose`.)

### Platform configuration

#### Android

Add to `android/app/src/main/AndroidManifest.xml`, inside the existing `<activity android:name=".MainActivity">`:

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

`autoVerify="false"` because this is a custom scheme, not an https App Link. Android will not try to verify a `Digital Asset Links` association.

#### iOS

Add to `ios/Runner/Info.plist`:

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

#### Desktop (Linux / Windows / macOS)

No platform configuration. `PlatformCapability.isMobile` returns false on these platforms, so:

- The `redirect_to` query param is not appended to the approval URL.
- The deep-link handler's `start()` is a no-op.
- The existing manual *"I've approved it — continue"* button drives the flow.

## Data flow — happy path

1. User taps *Connect TMDB* in `TmdbAccountSyncSection`.
2. `TmdbConnectDialog` appears; on first frame it sets `tmdbConnectDialogVisibleProvider` to `true`.
3. User taps *Connect*. `ConnectTmdbAccountUseCase.startConnect()` runs:
   - Repository creates a request token.
   - On mobile, the use case appends `?redirect_to=mymediascanner%3A%2F%2Ftmdb-callback` to the TMDB authenticate URL.
   - `url_launcher` opens the URL in the system browser; the app is backgrounded.
4. User approves on TMDB. The browser is redirected to `mymediascanner://tmdb-callback?request_token=<token>&approved=true`.
5. Android / iOS routes the URI to MyMediaScanner. The app is foregrounded.
6. `app_links` emits the URI on its stream.
7. `TmdbDeepLinkHandler._handle(uri)` parses it as `TmdbApprovalApproved`. Token matches the pending one. The handler calls `connect.finishConnect()`, which succeeds, and emits `TmdbDeepLinkSuccess`.
8. The dialog's listener pops with `Navigator.pop(true)`. `tmdbConnectDialogVisibleProvider` flips to `false` on dispose. The global listener does not duplicate the SnackBar because it observed the dialog was open at the time the event fired.
9. Connection state updates throughout the app (settings card now shows the connected account name).

## Data flow — error and edge cases

| Scenario | Handler emits | Dialog reaction | Global reaction |
|---|---|---|---|
| User denies on TMDB (`approved=false`) | `TmdbDeepLinkCancelled` | Inline error: "Approval was denied — try again." | (gated — dialog is up) |
| Token mismatch | `TmdbDeepLinkMismatch(reason)` | Inline error | gated |
| Malformed URI | `TmdbDeepLinkMismatch(reason)` | Inline error | gated |
| `finishConnect()` itself fails | `TmdbDeepLinkMismatch(reason)` | Inline error | gated |
| Deep link arrives but dialog was dismissed | `TmdbDeepLinkSuccess` | (n/a — dialog gone) | SnackBar: "Connected to TMDB" |
| Deep link arrives, no pending token (app killed) | `TmdbDeepLinkNoPending` | (n/a) | SnackBar: "Approval link arrived but no connection was in progress — please tap Connect again." |

## Testing

### Unit tests

- `TmdbApprovalCallback.parse` — happy path (approved), denied path, missing `request_token`, missing `approved`, wrong host, wrong scheme.
- `TmdbDeepLinkHandler._handle` — drive a fake URI stream and a fake `ConnectTmdbAccountUseCase`. Assert correct event emission per the table above. Verify `connect.finishConnect()` called only on the happy path.
- `ConnectTmdbAccountUseCase.startConnect` — with `redirectTo` non-null, the approval URL contains `?redirect_to=mymediascanner%3A%2F%2Ftmdb-callback`. With `redirectTo` null, the URL is unchanged from today.

### Widget tests

- `TmdbConnectDialog` — fake stream emits each event type, assert dialog dismisses on success, shows the appropriate inline error on cancel / mismatch, manual button still works as fallback.
- App-level: a `ConsumerWidget` wraps the router and reacts to `TmdbDeepLinkSuccess` while the dialog is closed — assert SnackBar via the global `ScaffoldMessenger` key.

### Manual smoke (mobile)

1. Connect TMDB on Android/iOS, approve in browser, verify the app foregrounds and the dialog auto-closes with a SnackBar within ~2 seconds.
2. Connect TMDB on mobile, deny in browser, verify the dialog shows "Approval was denied".
3. Start connect, force-kill the app while the browser is open, then re-open the app via the deep link — verify the SnackBar reads "Approval link arrived but no connection was in progress".

## Out of scope

- Desktop deep-linking (no Linux / Windows / macOS scheme handlers).
- Universal Links / App Links over https.
- Persisting the pending request token across app kill.
- Showing a connection-progress spinner during the in-flight `finishConnect()` call (the call typically resolves in under a second on a connected network; can be added in a follow-up).
- Replacing the manual *"I've approved it"* button on mobile. It stays as a fallback for the rare case where the deep link fails (browser blocked, user copy-pasted the URL, etc.).

## Risks

- **`app_links` plugin lifecycle:** the package's stream emits both warm-start and cold-start URIs. Need to confirm cold-start is captured (i.e. the URI that launched the app from a killed state). This is the case in app_links 6.x — verify in the implementation phase.
- **Multiple parallel approvals:** if the user starts two approvals from two devices (or two browser tabs), the second deep-link event would carry a token that doesn't match `_pendingRequestToken`. The handler emits `TmdbDeepLinkMismatch` and silently drops it. Acceptable.
- **Custom scheme hijacking:** another app could register `mymediascanner://` and intercept the redirect. Risk is low because the redirect payload is non-secret (the request token is already in app memory; an attacker capturing it gains nothing without also being inside the app's process). Documented as a known limitation; future App Link migration would close the gap.

## Acceptance criteria

- On Android, after approving TMDB in the browser, the user lands back in the app within ~2s and the connection is complete without tapping any button.
- On iOS, same behaviour (the system "Open in MyMediaScanner?" prompt is acceptable).
- On Linux / Windows / macOS, behaviour is unchanged from today (manual button drives the flow).
- Token mismatch, denial, and no-pending cases produce correct user-facing feedback per the table above.
- Existing tests continue to pass; ~10–15 new unit + widget tests are added covering parser, handler, modified use case, and dialog reactions.
- `flutter analyze` clean. Linux + Android builds succeed.
