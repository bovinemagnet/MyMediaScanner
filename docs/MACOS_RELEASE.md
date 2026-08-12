# Releasing MyMediaScanner on macOS

Author: Paul Snow

macOS is distributed as a DMG from GitHub Releases rather than through the Mac
App Store. The build works today; what stops the DMG being usable by anyone
else is signing, and this is how to fix that.

Bundle identifier: `com.paulsnow.mymediascanner`.

---

## The problem this solves

`flutter build macos --release` ad-hoc signs the app: no team, no certificate.
That runs fine on the machine that built it and is refused everywhere else:

```
$ codesign -dvv MyMediaScanner.app
Signature=adhoc
TeamIdentifier=not set

$ spctl -a -vvv MyMediaScanner.app
MyMediaScanner.app: rejected
```

A user who downloads that DMG is told the app is damaged or from an
unidentified developer. Signing alone is not enough either — a downloaded app
must also be **notarised**, which means submitting it to Apple and stapling the
ticket they return.

`release-macos.yml` performs both, but only when the secrets below exist.
Without them it still builds a DMG so the workflow stays green, and that DMG is
the ad-hoc one — fine for local testing, not for distribution.

---

## 1. Get a Developer ID certificate

This needs the same Apple Developer Program membership as iOS, so if you have
already enrolled for TestFlight you have it.

**Xcode → Settings → Accounts →** select the team **→ Manage Certificates → +
→ Developer ID Application.**

Note that "Developer ID Application" is a different certificate from the
"Apple Distribution" one iOS uses. You need both; they are not
interchangeable.

## 2. Export it for CI

Keychain Access → **My Certificates** → find *Developer ID Application: …* →
right-click → **Export** → `.p12`, and set a password.

Make sure you export the certificate *with* its private key — if the private
key is missing the import will succeed in CI and the signing step will then
fail with "no identity found".

```bash
base64 -i DeveloperID.p12 | pbcopy
```

## 3. Add the secrets

**Settings → Secrets and variables → Actions.**

| Secret | Value |
|---|---|
| `APPLE_TEAM_ID` | your 10-character Team ID (shared with iOS) |
| `MACOS_DEVELOPER_ID_CERT_BASE64` | the base64 from step 2 |
| `MACOS_DEVELOPER_ID_CERT_PASSWORD` | the `.p12` password |
| `APPSTORE_API_KEY_ID` | App Store Connect API key ID (shared with iOS) |
| `APPSTORE_API_ISSUER_ID` | issuer ID (shared with iOS) |
| `APPSTORE_API_PRIVATE_KEY` | the `.p8` contents (shared with iOS) |

Notarisation reuses the App Store Connect API key rather than an Apple ID and
app-specific password, so if iOS is already set up only the two macOS-specific
secrets are new.

With `APPLE_TEAM_ID` and `MACOS_DEVELOPER_ID_CERT_BASE64` present the app is
signed; notarisation additionally needs the three `APPSTORE_API_*` values.

## 4. Release

```bash
git tag v1.1.0
git push origin v1.1.0
```

Or dispatch `release-macos` by hand from the Actions tab.

The workflow signs the nested frameworks before the app bundle — the outer
signature seals the inner ones, so the order matters — enables the hardened
runtime, which notarisation requires, builds the DMG, submits it, staples the
ticket, and then proves the result with:

```bash
spctl -a -t open --context context:primary-signature -vvv <dmg>
```

If that check passes, the DMG opens cleanly on a machine that has never seen
your certificate.

---

## Verifying by hand

Downloading the artefact and checking it yourself is worth doing once:

```bash
hdiutil attach -nobrowse -mountpoint /tmp/mms MyMediaScanner-1.0.0-macOS.dmg
codesign -dvv /tmp/mms/MyMediaScanner.app     # expect Authority=Developer ID Application: …
spctl -a -vvv /tmp/mms/MyMediaScanner.app     # expect accepted
hdiutil detach /tmp/mms
```

## Troubleshooting

**"no identity found"** — the `.p12` was exported without its private key, or
it holds an Apple Distribution certificate rather than a Developer ID one.

**Notarisation rejected, "The signature does not include a secure timestamp"**
— signing ran without `--timestamp`, which needs network access at signing
time.

**Notarisation rejected, "The executable does not have the hardened runtime
enabled"** — `--options runtime` was missing on one of the nested items, not
just the app.

**Still rejected after notarisation succeeds** — the ticket was not stapled, so
the first launch needs to reach Apple. Check `xcrun stapler validate`.

**The App Sandbox** — the app runs sandboxed, and the rip library folder is
only readable through the security-scoped bookmark captured when the user picks
it with Browse…. Signing does not change that, but note that Keychain items do
not survive relaunches of ad-hoc-signed builds, so some storage oddities seen
in local debug builds should disappear once the app is properly signed.

## Related files

- `.github/workflows/release-macos.yml` — build, sign, notarise, staple
- `macos/Runner/Release.entitlements` — sandbox and capability entitlements
- `docs/IOS_RELEASE.md` — the iOS equivalent, and where the shared API key comes from
