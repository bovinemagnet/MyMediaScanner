# Releasing MyMediaScanner on iOS

Author: Paul Snow

This is the runbook for getting MyMediaScanner onto TestFlight and, from
there, the App Store. Steps 1–7 are one-off setup. Step 8 is what you repeat
for every subsequent release.

Bundle identifier: `com.paulsnow.mymediascanner`. Minimum iOS version: 15.5
(set by `google_mlkit_commons`).

---

## What is already done in the repository

You do not need to touch any of this — it is committed and covered by
`test/unit/platform/ios_release_config_test.dart`, which fails if any of it
regresses:

- Purpose strings for camera, photo library and local network. The photo
  library one is not optional: `cover_ocr_helper.dart` calls
  `ImageSource.gallery`, and iOS terminates an app that reaches the picker
  without a string.
- `ITSAppUsesNonExemptEncryption = false`, so App Store Connect stops asking
  the export-compliance question on every upload. The app uses HTTPS and the
  Keychain only, both exempt.
- `ios/Runner/PrivacyInfo.xcprivacy`, wired into the Runner target's resources
  so it actually ships in the bundle. Without it uploads are rejected with
  ITMS-91053.
- `ios/Flutter/Release.xcconfig` optionally includes `Signing.xcconfig`, so
  release builds are unsigned until you supply signing settings.

---

## 1. Enrol in the Apple Developer Program

<https://developer.apple.com/programs/enroll/> — US$99 per year, renewed
annually. Individual enrolment needs photo ID; organisation enrolment needs a
D-U-N-S number and takes longer.

Note your **Team ID** — the 10-character string under Membership details. You
need it in step 3.

## 2. Register the app in App Store Connect

<https://appstoreconnect.apple.com> → **Apps** → **+** → **New App**.

- Platform: iOS
- Bundle ID: `com.paulsnow.mymediascanner` (register it first at
  Certificates, Identifiers & Profiles → Identifiers if it is not offered)
- SKU: anything unique to you, e.g. `mymediascanner`
- Primary language: English (UK)

The name must be unique across the whole App Store. If "MyMediaScanner" is
taken, the store name and the on-device name can differ — only the store name
has to be unique.

### App Information

App Store Connect → your app → **General** → **App Information**. The text
values live in `ios/fastlane/metadata/en-GB/`, so paste from there rather than
inventing new copy — `fastlane release` uploads those same files and would
otherwise overwrite whatever you typed.

| Field | Value | Limit |
|---|---|---|
| Name | `MyMediaScanner` | 30 |
| Subtitle | `Catalogue your physical media` | 30 |
| Privacy Policy URL | `https://bovinemagnet.github.io/MyMediaScanner/privacy-policy.html` | — |
| Primary category | Utilities | — |
| Secondary category | Reference | — |
| Content Rights | Contains third-party content — see below | — |
| Age Rating | answer all "None"; the app rates 4+ | — |
| Licence Agreement | Apple's standard EULA | — |

Two fields live on the **version** page rather than App Information, and one
of them has no file in the repo:

| Field | Value |
|---|---|
| Promotional text / Description | `description.txt` |
| Keywords | `keywords.txt` |
| What's New | `release_notes.txt` |
| **Support URL** (required) | `https://github.com/bovinemagnet/MyMediaScanner/issues` |

**Content Rights.** Cover art and metadata come from third-party APIs (TMDB,
Discogs, MusicBrainz, Google Books, Open Library, TheAudioDB, Fanart,
UPCitemdb), fetched when the user scans an item. Answer that the app contains
third-party content. Note that TMDB's API terms require visible attribution —
wording to the effect of "This product uses the TMDB API but is not endorsed
or certified by TMDB" — and the app does not display it anywhere yet. Worth
settling before submission.

## 3. Configure local signing

```bash
cp ios/Flutter/Signing.xcconfig.example ios/Flutter/Signing.xcconfig
```

Put your Team ID in it and leave `CODE_SIGN_STYLE = Automatic`. The file is
git-ignored — the same arrangement as `android/key.properties` — so your Team
ID never lands in the repository.

Then sign in to Xcode once so it can create and download certificates for
you: **Xcode → Settings → Accounts → +** → Apple ID.

Verify:

```bash
flutter build ipa --release
```

The IPA lands in `build/ios/ipa/`. If Xcode complains it cannot create a
provisioning profile, open `ios/Runner.xcworkspace`, select the Runner target,
and look at Signing & Capabilities — it will say what is missing.

## 4. Create an App Store Connect API key

This is what lets uploads run without a human answering a 2FA prompt.

App Store Connect → **Users and Access** → **Integrations** → **App Store
Connect API** → **+**. Give it the **App Manager** role.

You get three things, and the `.p8` can only be downloaded **once**:

| Value | Where it appears |
|---|---|
| Key ID | the key's row in the table |
| Issuer ID | above the table |
| `.p8` private key | one-time download |

## 5. First upload — by hand

Do the first one locally so any signing problem surfaces with a readable error
rather than inside a CI log:

```bash
flutter build ipa --release

export APPSTORE_API_KEY_ID=XXXXXXXXXX
export APPSTORE_API_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export APPSTORE_API_PRIVATE_KEY="$(cat ~/Downloads/AuthKey_XXXXXXXXXX.p8)"

cd ios && fastlane beta
```

Processing in App Store Connect takes 5–30 minutes. When it finishes you get
an email, and the build appears under **TestFlight**.

## 6. Answer the App Privacy questionnaire

App Store Connect → your app → **App Privacy**. TestFlight external testing
will not open until this is answered.

The honest answers for this app:

- **Data collection:** none. The catalogue is local SQLite; optional sync goes
  to a PostgreSQL server the user runs themselves; API keys live in the
  Keychain on device.
- **Tracking:** no. There is no advertising identifier and no analytics.
- Metadata lookups do send a barcode or title to third-party APIs (TMDB,
  Discogs, MusicBrainz, Google Books, Open Library, TheAudioDB, Fanart,
  UPCitemdb) when the user scans something. That is a user-initiated query
  rather than collection on our behalf, which is why
  `NSPrivacyCollectedDataTypes` is empty — but review may ask about it, so be
  ready to describe it.

## 7. Set up automated uploads (optional)

`release-ios.yml` builds unsigned unless the signing secrets exist, so CI
stays green while you decide whether to bother. Add these to
**Settings → Secrets and variables → Actions** to switch it on:

| Secret | How to produce it |
|---|---|
| `APPLE_TEAM_ID` | the 10-character Team ID |
| `IOS_DISTRIBUTION_CERT_BASE64` | export the Apple Distribution certificate *with its private key* from Keychain Access as `.p12`, then `base64 -i cert.p12 \| pbcopy` |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | the password you set on the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | download the App Store profile from the developer portal, then `base64 -i profile.mobileprovision \| pbcopy` |
| `IOS_PROVISIONING_PROFILE_NAME` | the profile's name, exactly as shown in the portal |
| `APPSTORE_API_KEY_ID` | from step 4 |
| `APPSTORE_API_ISSUER_ID` | from step 4 |
| `APPSTORE_API_PRIVATE_KEY` | the whole `.p8` file contents, including the BEGIN/END lines |

With `APPLE_TEAM_ID` and `IOS_DISTRIBUTION_CERT_BASE64` present the workflow
signs; the upload step additionally needs the three `APPSTORE_API_*` values.

CI switches the build to **manual** signing, because automatic signing needs
an interactive Apple ID session that a runner does not have.

## 8. Every release after that

```bash
# 1. Bump the version. The build number must increase on every upload.
#    Edit pubspec.yaml: version: 1.1.0+2

# 2. Land it on main, then tag:
git tag v1.1.0
git push origin v1.1.0
```

The tag triggers `release-all.yml`, which runs the iOS job among the others.

CI passes `--build-number=${{ github.run_number }}`, so the uploaded build
number comes from the run counter rather than pubspec and can never repeat.
The version *name* still comes from pubspec, so that is the one to bump.

For a local release instead, repeat step 5.

---

## Troubleshooting

**"No profiles for 'com.paulsnow.mymediascanner' were found"** — the bundle ID
is not registered, or Xcode is not signed in to the team that owns it. Register
it under Identifiers, then re-open the workspace.

**Upload rejected, ITMS-91053: Missing API declaration** — a dependency
reaches a required-reason API that `PrivacyInfo.xcprivacy` does not declare.
The rejection email names the API category; add it to
`ios/Runner/PrivacyInfo.xcprivacy` with the appropriate reason code from
Apple's list, and add it to `_requiredApiReasons` in the test so it stays
declared.

**"The bundle version must be higher than the previously uploaded version"** —
TestFlight has seen that build number. Re-run the workflow (the run number
advances) or bump `+N` in pubspec for a local build.

**App crashes when picking a cover image** — a purpose string has gone
missing from `Info.plist`. `flutter test test/unit/platform/ios_release_config_test.dart`
names which one.

**Simulator builds fail or will not launch on Apple Silicon** — expected, and
unrelated to release. Google ML Kit ships no arm64-simulator slice; use
`scripts/ios_sim.sh`, or a physical device. Release builds for devices are
arm64 and unaffected.

## Related files

- `.github/workflows/release-ios.yml` — build, sign and upload
- `ios/fastlane/Fastfile` — TestFlight and App Store lanes
- `ios/fastlane/metadata/en-GB/` — store listing text
- `ios/Flutter/Signing.xcconfig.example` — local signing template
- `ios/Runner/PrivacyInfo.xcprivacy` — privacy manifest
- `test/unit/platform/ios_release_config_test.dart` — guards all of the above
- `docs/PLAY_STORE_RELEASE.md` — the Android equivalent
