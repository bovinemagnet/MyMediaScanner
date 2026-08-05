# Releasing MyMediaScanner on Google Play

Author: Paul Snow

This is the runbook for getting MyMediaScanner onto the Google Play Store and
keeping it there. Steps 1–8 are one-off setup. Step 9 is what you repeat for
every subsequent release.

Package name: `com.paulsnow.mymediascanner` (the `prod` flavour; `dev` builds
carry the `.dev` suffix and must never be uploaded).

---

## Before you start: the 14-day gate

Google requires personal developer accounts registered after November 2023 to
run a **closed test with at least 12 testers opted in continuously for 14
days** before you can apply for production access. If that applies to you, the
path is internal testing → closed testing (14 days) → production, so create
the developer account *first* — the wait is the long pole, not the build.
Confirm the current rule in Play Console, as the thresholds change.

---

## 1. Create the Play Developer account

<https://play.google.com/console/signup> — US$25, one-off. Identity
verification takes a day or two. Organisation accounts also need a D-U-N-S
number.

## 2. Publish the privacy policy

Play requires a publicly reachable privacy policy URL for every app. The
policy is already written and describes what the app actually does. It lives
in the Antora docs tree as
`src/docs/modules/ROOT/pages/privacy-policy.adoc`, and is rendered to
`docs/privacy-policy.html` — GitHub Pages cannot render AsciiDoc, so the HTML
is generated and committed:

```bash
gem install asciidoctor -v 2.0.23   # once; CI pins the same version
tools/render-privacy-policy.sh
```

Edit the `.adoc`, re-run the script, and commit both files. CI fails if they
drift apart. The generated page is rendered with `webfonts!` so it makes no
external requests — a privacy policy that phones home to a font CDN is not a
good look.

To publish:

> GitHub → repo **Settings** → **Pages** → Source: *Deploy from a branch* →
> Branch `main`, folder `/docs` → **Save**

The URL is then:

```
https://bovinemagnet.github.io/MyMediaScanner/privacy-policy.html
```

`docs/.nojekyll` is present so Pages serves the file verbatim instead of
running a Jekyll build over the whole `docs/` tree. The repo is public, so
enabling Pages exposes nothing that was not already visible.

Load the URL in a browser and confirm it renders before pasting it into Play
Console — a 404 there is a common review rejection.

## 3. Generate the upload keystore

> **Already done on Paul's Mac.** `android/key.properties` points at
> `/Users/paul/keys/mymediascanner-upload.jks` with alias `upload`, and a
> release bundle built from it carries `CN=Paul Snow, O=Snowed Under
> Productions`. Skip to the verification at the end of this section — do
> **not** regenerate the key.

This key signs bundles you upload. Google re-signs them with its own app
signing key before distribution, so this is your *upload* key.

```bash
keytool -genkey -v \
  -keystore ~/keys/mymediascanner-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Answer the prompts (your name, organisation, country code). Note the store
password and the key password — you will need both.

> **Back this file up somewhere durable, off this machine.** Losing the
> upload key means filing a support request with Google to reset it. Losing
> it with no backup and no reset is how apps get abandoned.

Then create `android/key.properties` (already gitignored via
`android/.gitignore:12`):

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=/Users/paul/keys/mymediascanner-upload.jks
```

`storeFile` is resolved relative to `android/app/`, so use an absolute path
locally.

Verify signing works — this is the check that catches a misconfigured
keystore before Play does:

```bash
flutter build appbundle --release --flavor prod
keytool -printcert -jarfile build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

The certificate owner must be the CN you just entered, **not**
`CN=Android Debug`. `android/app/build.gradle.kts` warns loudly when
`key.properties` is missing locally, and fails the build outright on CI.

## 4. Create the app in Play Console

Play Console → **Create app**:

| Field | Value |
|-------|-------|
| App name | MyMediaScanner |
| Default language | English (United Kingdom) |
| App or game | App |
| Free or paid | Free |

Free cannot be changed to paid later. Paid can be made free.

## 5. Complete the declarations

Everything under **Policy and programmes → App content**:

- **Privacy policy** — the URL from step 2.
- **Ads** — no ads. There is no ad SDK in `pubspec.yaml`.
- **App access** — all functionality is available without logging in, but
  metadata lookup returns nothing until the user supplies an API key. Say so,
  and **put a working TMDB key in the reviewer notes**, otherwise the
  reviewer sees an app where scanning appears to do nothing and the review
  fails.
- **Content rating** — complete the questionnaire. Reference/utility app, no
  user-generated content shared between users, no violence, no gambling.
- **Target audience** — 18+ (or 13+); not designed for children.
- **Data safety** — see the next section.
- **Government apps** — no. **Financial features** — none.
- **Health** — none.

### Data safety answers

Based on what the code actually does — no analytics, advertising, or
crash-reporting SDKs are present:

| Question | Answer |
|----------|--------|
| Does your app collect or share user data? | **No** |
| Is data encrypted in transit? | Yes (HTTPS to metadata APIs; the optional PostgreSQL connection is user-configured) |
| Can users request data deletion? | Yes — uninstalling removes the local database |

"Collect" in Play's sense means transmitted off the device to *you*. Barcode
lookups go to third-party APIs but nothing is retained by the developer and
no personal or device identifiers are attached. The camera is used only for
on-device barcode decoding and ML Kit OCR — declare it as such, not as photo
collection.

## 6. Store listing graphics

The listing text is already in the repo and is pushed by Fastlane from
`android/fastlane/metadata/android/en-GB/` (`title.txt`,
`short_description.txt`, `full_description.txt`, `changelogs/`). Graphics must
be uploaded through the Console.

| Asset | Requirement |
|-------|-------------|
| App icon | 512 × 512 PNG, 32-bit |
| Feature graphic | 1024 × 500 PNG or JPEG |
| Phone screenshots | 2–8, 16:9 or 9:16, each side 320–3840 px |
| 7" and 10" tablet screenshots | Optional, but needed to be listed as tablet-optimised |

The 13 PNGs in `src/docs/modules/ROOT/images/screenshots/` are **desktop**
captures produced by `tools/capture-screenshots.sh` running the Linux build —
wrong aspect ratio for a phone listing. Capture fresh ones from an Android
emulator:

```bash
flutter run --flavor dev            # on a phone-sized emulator
# then, per screen:
adb exec-out screencap -p > shot-01-dashboard.png
```

Good candidates: dashboard, collection grid, scanner, item detail, insights.

## 7. Create the Play service account (for automated uploads)

Only needed once you want CI to upload. The first bundle goes up by hand
(step 8) regardless.

1. Play Console → **Setup → API access** → link or create a Google Cloud
   project.
2. In Google Cloud Console, create a **service account** and generate a JSON
   key.
3. Back in Play Console → **Users and permissions** → invite the service
   account address, grant it access to this app with **Release → Release apps
   to testing tracks** (add production later if you want the `release` lane).

Test the credentials without publishing anything:

```bash
cd android
PLAY_JSON_KEY_PATH=/path/to/play-service-account.json fastlane validate
```

The `validate` lane runs the same upload with `validate_only: true`.

## 8. First upload — by hand

Fastlane cannot create the Play Console app entry, and this first upload is
what enrols the app in Play App Signing. Do it through the Console.

```bash
flutter analyze && flutter test
flutter build appbundle --release --flavor prod
```

Before uploading, check the merged manifest for permissions that plugins
injected. `flutter_local_notifications`, `file_picker`, and `image_picker`
all add permissions that are not in
`android/app/src/main/AndroidManifest.xml`, and some of them
(`SCHEDULE_EXACT_ALARM`, any `MANAGE_EXTERNAL_STORAGE`) require a separate
declaration form in Console:

```bash
bundletool dump manifest \
  --bundle=build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### Watch the download size

The `prod` bundle is around 113 MB. That is the whole bundle across every
ABI, not what a user downloads — Play splits it per device — but it is worth
checking the **download size** Play reports after upload. Play caps any
single generated APK set at 200 MB.

Most of the weight is native: `flutter_zxing`'s FFI libraries and the four
extra ML Kit language models (Chinese, Devanagari, Japanese, Korean) that
`android/app/build.gradle.kts` pulls in purely to satisfy R8's missing-class
check. If size ever becomes a problem, those four are the first thing to
look at — the app only uses Latin-script recognition.

### Test the bundle on a device

Install it on real hardware before uploading. `isMinifyEnabled = true`, and
Drift, Retrofit, and ML Kit all use reflection — R8 stripping something is
the classic way a release build breaks when debug builds are fine:

```bash
bundletool build-apks \
  --bundle=build/app/outputs/bundle/prodRelease/app-prod-release.aab \
  --output=/tmp/mms.apks --mode=universal
bundletool install-apks --apks=/tmp/mms.apks
```

Exercise a barcode scan, a metadata lookup, and cover OCR on the device
before uploading.

Finally: Play Console → **Testing → Internal testing** → **Create new
release** → upload the `.aab` → add testers → roll out.

## 9. Every release after that

1. Bump the build number in `pubspec.yaml`. Play requires a strictly
   increasing `versionCode`, and this is where it comes from:

   ```yaml
   version: 1.0.1+2      # versionName 1.0.1, versionCode 2
   ```

2. Add a changelog at
   `android/fastlane/metadata/android/en-GB/changelogs/<versionCode>.txt`.
   The filename must match the new `versionCode`.

3. Commit and tag:

   ```bash
   git tag v1.0.1 && git push origin v1.0.1
   ```

   The tag push builds the APK and AAB and attaches both to a GitHub Release.
   It does **not** upload to Play.

4. To upload to Play, run the workflow manually: Actions → **Release
   Android** → **Run workflow** → `flavor: prod`, `publish_to_play: true`.
   That runs `fastlane beta`, which pushes the bundle and the listing
   metadata to the internal track.

5. Promote internal → closed → production in Play Console when you are ready.

### Required GitHub secrets

Settings → Secrets and variables → Actions:

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i ~/keys/mymediascanner-upload.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` | The store password from step 3 |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | The key password from step 3 |
| `PLAY_SERVICE_ACCOUNT_JSON` | Full contents of the service account JSON from step 7 |

Until `ANDROID_KEYSTORE_BASE64` is set, the release workflow **fails** rather
than producing a debug-signed artefact. That is deliberate: a debug-signed
"release" APK on a GitHub Release is worse than a red build.

---

## Troubleshooting

**"You uploaded an APK that is not signed with the upload certificate"** —
the keystore in CI differs from the one used for the first manual upload.
Compare `keytool -printcert -jarfile <aab>` against the upload certificate
fingerprint shown in Play Console → Setup → App integrity.

**"Version code N has already been used"** — bump the `+N` in
`pubspec.yaml`.

**Fastlane fails on metadata upload for the very first automated run** — the
listing must exist first. Run with `SKIP_METADATA=true` to push only the
bundle.

**App works in debug, crashes or shows empty data in release** — R8. Check
`android/app/proguard-rules.pro` and reproduce with the `bundletool` install
above, not with `flutter run --release`.

## Related files

| File | Purpose |
|------|---------|
| `android/app/build.gradle.kts` | Flavours, signing config, R8 |
| `android/key.properties` | Local keystore credentials (gitignored) |
| `android/fastlane/Fastfile` | `validate`, `beta`, `release` lanes |
| `android/fastlane/Appfile` | Package name, service account key path |
| `android/fastlane/metadata/android/en-GB/` | Store listing text and changelogs |
| `.github/workflows/release-android.yml` | Build, sign, publish |
| `src/docs/modules/ROOT/pages/privacy-policy.adoc` | Privacy policy source |
| `docs/privacy-policy.html` | Generated; published via GitHub Pages |
| `tools/render-privacy-policy.sh` | Renders the `.adoc` to that HTML |
