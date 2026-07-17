# Rips Screen Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the desktop Rip Library screen to the new themed design (health stat cards, status filter chips, richer album cards, redesigned detail panel) while keeping all existing features working; then audit the other designed screens and fix small cosmetic gaps.

**Architecture:** New pure-Dart health classification in `domain/`, one new DAO/repository stream (all tracks grouped by album), new Riverpod providers deriving health + aggregate stats, and new/restyled widgets in `presentation/screens/rips/widgets/`. Typography gains bundled Space Grotesk + JetBrains Mono with opt-in `AppTypography` helpers.

**Tech Stack:** Flutter, Riverpod 3 (hand-written Notifier/Provider), Drift, freezed entities, mocktail tests.

**Spec:** `docs/superpowers/specs/2026-07-17-rips-screen-redesign-design.md`

## Global Constraints

- British spelling in all copy and identifiers (e.g. "Analyse", "colour" in comments).
- Author: Paul Snow. No Claude/Anthropic references in code or commits.
- Riverpod 3 hand-written providers only (no riverpod_generator).
- Fonts must be bundled in `assets/fonts/` — no runtime font fetching.
- No app-wide `textTheme` family swap: new typography helpers are opt-in per widget; only `AppTypography.displayNumeric` changes family (to Space Grotesk).
- All existing rips features must keep working: table view, multi-select, batch analysis, tag editing, queue panel, GNUDB lookup, collection linking, playback.
- Soft deletes only; no schema migrations in this plan (sample-rate persistence is explicitly deferred).
- Run `flutter test` after each task; commit after each green task.
- In provider tests, `container.listen` on a provider BEFORE awaiting its `.future` (Riverpod 3 hangs otherwise).

---

### Task 1: Bundle Space Grotesk + JetBrains Mono and extend AppTypography

**Files:**
- Create: `assets/fonts/SpaceGrotesk-{Regular,Medium,SemiBold,Bold}.ttf`, `assets/fonts/JetBrainsMono-{Regular,Medium,SemiBold,Bold,ExtraBold}.ttf`
- Modify: `pubspec.yaml` (fonts section, after the Inter family block)
- Modify: `lib/app/theme/app_typography.dart`
- Test: `test/unit/app/app_typography_test.dart`

**Interfaces:**
- Produces: `AppTypography.displayTitle({required Color color, double fontSize = 34, FontWeight fontWeight = FontWeight.w700}) → TextStyle` (family `SpaceGrotesk`); `AppTypography.monoLabel({required Color color, double fontSize = 10, double letterSpacing = 1.4, FontWeight fontWeight = FontWeight.w700}) → TextStyle` (family `JetBrainsMono`, height 1.0); `AppTypography.monoNumeric({required Color color, double fontSize = 24, FontWeight fontWeight = FontWeight.w700}) → TextStyle` (family `JetBrainsMono`). `displayNumeric` keeps its signature but family becomes `SpaceGrotesk`.

- [ ] **Step 1: Download the font files**

```bash
cd /Users/paul/gitHub/MyMediaScanner/assets/fonts
for w in Regular Medium SemiBold Bold ExtraBold; do
  curl -fsSL -o "JetBrainsMono-$w.ttf" \
    "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-$w.ttf"
done
for w in Regular Medium SemiBold Bold; do
  curl -fsSL -o "SpaceGrotesk-$w.ttf" \
    "https://github.com/floriankarsten/space-grotesk/raw/master/fonts/ttf/SpaceGrotesk-$w.ttf"
done
file SpaceGrotesk-*.ttf JetBrainsMono-*.ttf
```

Expected: every file reports `TrueType Font data`. If a Space Grotesk URL 404s, list the repo's `fonts/ttf/` directory via `curl -s https://api.github.com/repos/floriankarsten/space-grotesk/contents/fonts/ttf` and use the actual static-TTF paths; do NOT ship a variable font.

- [ ] **Step 2: Register the families in pubspec.yaml**

Append to the `fonts:` list (after the Inter family):

```yaml
    - family: SpaceGrotesk
      fonts:
        - asset: assets/fonts/SpaceGrotesk-Regular.ttf
          weight: 400
        - asset: assets/fonts/SpaceGrotesk-Medium.ttf
          weight: 500
        - asset: assets/fonts/SpaceGrotesk-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/SpaceGrotesk-Bold.ttf
          weight: 700
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/JetBrainsMono-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
        - asset: assets/fonts/JetBrainsMono-ExtraBold.ttf
          weight: 800
```

- [ ] **Step 3: Write the failing test**

Create `test/unit/app/app_typography_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';

void main() {
  group('AppTypography new styles', () {
    test('displayTitle uses Space Grotesk with tight tracking', () {
      final style = AppTypography.displayTitle(color: Colors.white);
      expect(style.fontFamily, 'SpaceGrotesk');
      expect(style.fontSize, 34);
      expect(style.letterSpacing, lessThan(0));
    });

    test('monoLabel uses JetBrains Mono, uppercase-ready tracking', () {
      final style = AppTypography.monoLabel(color: Colors.white);
      expect(style.fontFamily, 'JetBrainsMono');
      expect(style.letterSpacing, greaterThan(0));
      expect(style.height, 1.0);
    });

    test('monoNumeric uses JetBrains Mono', () {
      final style = AppTypography.monoNumeric(color: Colors.white);
      expect(style.fontFamily, 'JetBrainsMono');
      expect(style.fontWeight, FontWeight.w700);
    });

    test('displayNumeric switches to Space Grotesk', () {
      final style = AppTypography.displayNumeric(color: Colors.white);
      expect(style.fontFamily, 'SpaceGrotesk');
    });
  });
}
```

- [ ] **Step 4: Run test to verify it fails**

Run: `flutter test test/unit/app/app_typography_test.dart`
Expected: FAIL — `displayTitle` / `monoLabel` / `monoNumeric` are not defined.

- [ ] **Step 5: Implement in app_typography.dart**

Add constants next to `_manrope`/`_inter` and the three helpers after `displayNumeric`; change `displayNumeric`'s `fontFamily:` to `_spaceGrotesk` and update its doc comment (the "if Space Grotesk is added" sentence now describes reality):

```dart
  static const _spaceGrotesk = 'SpaceGrotesk';
  static const _jetBrainsMono = 'JetBrainsMono';

  /// Display style for screen and card titles in the themed redesign.
  /// Space Grotesk with tight tracking — pairs with [monoLabel] eyebrows.
  static TextStyle displayTitle({
    required Color color,
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _spaceGrotesk,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -fontSize * 0.025,
      height: 1.1,
      color: color,
    );
  }

  /// Uppercase letterspaced technical label (eyebrows, section headers,
  /// chips). Callers supply already-uppercased text.
  static TextStyle monoLabel({
    required Color color,
    double fontSize = 10,
    double letterSpacing = 1.4,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _jetBrainsMono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.0,
      color: color,
    );
  }

  /// Monospaced numeric for stat values and counters.
  static TextStyle monoNumeric({
    required Color color,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _jetBrainsMono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -fontSize * 0.03,
      height: 1.0,
      color: color,
    );
  }
```

- [ ] **Step 6: Run tests**

Run: `flutter test test/unit/app/app_typography_test.dart` → PASS, then `flutter test` → all green.

- [ ] **Step 7: Commit**

```bash
git add assets/fonts pubspec.yaml lib/app/theme/app_typography.dart test/unit/app/app_typography_test.dart
git commit -m "feat(theme): bundle Space Grotesk and JetBrains Mono with opt-in typography helpers"
```

---

### Task 2: Rip album health classification (domain, TDD)

**Files:**
- Create: `lib/domain/entities/rip_album_health.dart`
- Test: `test/unit/domain/rip_album_health_test.dart`

**Interfaces:**
- Consumes: `RipTrack` (fields `qualityCheckedAt`, `accurateRipStatus`, `totalDefects` extension), `RipAlbum` (`totalSizeBytes`).
- Produces:
  - `enum RipAlbumHealth { verified, attention, mismatch, notAnalysed }`
  - `RipAlbumHealth classifyRipAlbumHealth(List<RipTrack> tracks)`
  - `class RipLibraryHealthStats { Map<RipAlbumHealth, int> counts; int arVerifiedTracks; int totalTracks; int totalSizeBytes; int get totalAlbums; double get arCoverage; }`
  - `RipLibraryHealthStats computeRipLibraryHealthStats({required List<RipAlbum> albums, required Map<String, List<RipTrack>> tracksByAlbum})`

- [ ] **Step 1: Write the failing tests**

Create `test/unit/domain/rip_album_health_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

RipTrack track({
  String id = 't1',
  int? checkedAt = 1,
  String? arStatus,
  int clicks = 0,
  int pops = 0,
}) {
  return RipTrack(
    id: id,
    ripAlbumId: 'a1',
    trackNumber: 1,
    filePath: '/x/$id.flac',
    fileSizeBytes: 1000,
    updatedAt: 0,
    qualityCheckedAt: checkedAt,
    accurateRipStatus: arStatus,
    clickCount: clicks,
    popCount: pops,
  );
}

RipAlbum album(String id, {int size = 100}) => RipAlbum(
      id: id,
      libraryPath: '/lib/$id',
      trackCount: 1,
      totalSizeBytes: size,
      lastScannedAt: 0,
      updatedAt: 0,
    );

void main() {
  group('classifyRipAlbumHealth', () {
    test('empty track list is notAnalysed', () {
      expect(classifyRipAlbumHealth(const []), RipAlbumHealth.notAnalysed);
    });

    test('no track analysed is notAnalysed', () {
      expect(
        classifyRipAlbumHealth([track(checkedAt: null)]),
        RipAlbumHealth.notAnalysed,
      );
    });

    test('any mismatch wins over defects', () {
      expect(
        classifyRipAlbumHealth([
          track(arStatus: 'verified'),
          track(id: 't2', arStatus: 'mismatch', clicks: 3),
        ]),
        RipAlbumHealth.mismatch,
      );
    });

    test('all verified with zero defects is verified', () {
      expect(
        classifyRipAlbumHealth([
          track(arStatus: 'verified'),
          track(id: 't2', arStatus: 'verified'),
        ]),
        RipAlbumHealth.verified,
      );
    });

    test('verified but with defects is attention', () {
      expect(
        classifyRipAlbumHealth([track(arStatus: 'verified', pops: 2)]),
        RipAlbumHealth.attention,
      );
    });

    test('analysed but unverified (AR not found) is attention, not mismatch',
        () {
      expect(
        classifyRipAlbumHealth([track(arStatus: 'notFound')]),
        RipAlbumHealth.attention,
      );
    });

    test('partially analysed album is attention even if analysed ones pass',
        () {
      expect(
        classifyRipAlbumHealth([
          track(arStatus: 'verified'),
          track(id: 't2', checkedAt: null),
        ]),
        RipAlbumHealth.attention,
      );
    });
  });

  group('computeRipLibraryHealthStats', () {
    test('aggregates counts, AR coverage and size', () {
      final stats = computeRipLibraryHealthStats(
        albums: [album('a', size: 100), album('b', size: 200)],
        tracksByAlbum: {
          'a': [track(arStatus: 'verified'), track(id: 't2', arStatus: 'verified')],
          'b': [track(arStatus: 'mismatch')],
        },
      );
      expect(stats.counts[RipAlbumHealth.verified], 1);
      expect(stats.counts[RipAlbumHealth.mismatch], 1);
      expect(stats.counts[RipAlbumHealth.attention], 0);
      expect(stats.counts[RipAlbumHealth.notAnalysed], 0);
      expect(stats.totalAlbums, 2);
      expect(stats.arVerifiedTracks, 2);
      expect(stats.totalTracks, 3);
      expect(stats.arCoverage, closeTo(2 / 3, 0.0001));
      expect(stats.totalSizeBytes, 300);
    });

    test('album with no tracks entry counts as notAnalysed', () {
      final stats = computeRipLibraryHealthStats(
        albums: [album('a')],
        tracksByAlbum: const {},
      );
      expect(stats.counts[RipAlbumHealth.notAnalysed], 1);
    });

    test('empty library has zero coverage, no division by zero', () {
      final stats = computeRipLibraryHealthStats(
        albums: const [],
        tracksByAlbum: const {},
      );
      expect(stats.arCoverage, 0);
      expect(stats.totalAlbums, 0);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/domain/rip_album_health_test.dart`
Expected: FAIL — `rip_album_health.dart` does not exist.

- [ ] **Step 3: Implement lib/domain/entities/rip_album_health.dart**

```dart
// Author: Paul Snow

import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// Derived health classification for a rip album, computed from its
/// tracks' AccurateRip and defect-analysis results. Never persisted —
/// always recomputed so it stays in sync with analysis runs.
enum RipAlbumHealth { verified, attention, mismatch, notAnalysed }

/// Classify an album from its tracks. Precedence (first match wins):
/// notAnalysed → mismatch → attention → verified.
///
/// Unknown or missing `accurateRipStatus` values on analysed tracks are
/// treated as "analysed but unverified" (attention), never as mismatch.
RipAlbumHealth classifyRipAlbumHealth(List<RipTrack> tracks) {
  final analysed =
      tracks.where((t) => t.qualityCheckedAt != null).toList(growable: false);
  if (analysed.isEmpty) return RipAlbumHealth.notAnalysed;
  if (analysed.any((t) => t.accurateRipStatus == 'mismatch')) {
    return RipAlbumHealth.mismatch;
  }
  final allTracksVerified = analysed.length == tracks.length &&
      analysed.every((t) => t.accurateRipStatus == 'verified');
  final anyDefects = analysed.any((t) => t.totalDefects > 0);
  if (anyDefects || !allTracksVerified) return RipAlbumHealth.attention;
  return RipAlbumHealth.verified;
}

/// Library-wide aggregate for the rips header stat cards.
class RipLibraryHealthStats {
  const RipLibraryHealthStats({
    required this.counts,
    required this.arVerifiedTracks,
    required this.totalTracks,
    required this.totalSizeBytes,
  });

  final Map<RipAlbumHealth, int> counts;
  final int arVerifiedTracks;
  final int totalTracks;
  final int totalSizeBytes;

  int get totalAlbums => counts.values.fold(0, (a, b) => a + b);

  /// AR-verified tracks as a fraction of all tracks (0 when empty).
  double get arCoverage =>
      totalTracks == 0 ? 0 : arVerifiedTracks / totalTracks;
}

RipLibraryHealthStats computeRipLibraryHealthStats({
  required List<RipAlbum> albums,
  required Map<String, List<RipTrack>> tracksByAlbum,
}) {
  final counts = {for (final h in RipAlbumHealth.values) h: 0};
  var arVerified = 0;
  var totalTracks = 0;
  var totalSize = 0;
  for (final album in albums) {
    final tracks = tracksByAlbum[album.id] ?? const <RipTrack>[];
    final health = classifyRipAlbumHealth(tracks);
    counts[health] = counts[health]! + 1;
    arVerified +=
        tracks.where((t) => t.accurateRipStatus == 'verified').length;
    totalTracks += tracks.length;
    totalSize += album.totalSizeBytes;
  }
  return RipLibraryHealthStats(
    counts: counts,
    arVerifiedTracks: arVerified,
    totalTracks: totalTracks,
    totalSizeBytes: totalSize,
  );
}
```

- [ ] **Step 4: Run tests** → PASS. Run full `flutter test` → green.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/rip_album_health.dart test/unit/domain/rip_album_health_test.dart
git commit -m "feat(domain): derive rip album health classification and library stats"
```

---

### Task 3: All-tracks stream (DAO → repository → providers)

**Files:**
- Modify: `lib/data/local/dao/rip_library_dao.dart` (add method after `watchTracksByMediaItem`, ~line 170)
- Modify: `lib/domain/repositories/i_rip_library_repository.dart` (add to interface)
- Modify: `lib/data/repositories/rip_library_repository_impl.dart` (implement; mirror the existing `watchTracksByMediaItem` row→entity mapping)
- Create: `lib/presentation/providers/rip_health_provider.dart`
- Test: `test/unit/presentation/providers/rip_health_provider_test.dart`

**Interfaces:**
- Consumes: `classifyRipAlbumHealth`, `computeRipLibraryHealthStats`, `RipLibraryHealthStats` from Task 2; `allRipAlbumsProvider`, `ripLibraryRepositoryProvider` (existing, `lib/presentation/providers/rip_provider.dart` / `repository_providers.dart`).
- Produces:
  - Repository: `Stream<Map<String, List<RipTrack>>> watchAllTracksByAlbum();` — all tracks of non-deleted albums keyed by `ripAlbumId`.
  - `final ripAllTracksByAlbumProvider = StreamProvider<Map<String, List<RipTrack>>>`
  - `final ripAlbumHealthMapProvider = Provider<Map<String, RipAlbumHealth>>`
  - `final ripLibraryHealthStatsProvider = Provider<RipLibraryHealthStats>`
  - `enum RipHealthFilter { all, verified, attention, mismatch, notAnalysed }` with `bool matches(RipAlbumHealth health)`
  - `final ripHealthFilterProvider = NotifierProvider<RipHealthFilterNotifier, RipHealthFilter>` with `void set(RipHealthFilter value)`

- [ ] **Step 1: Write the failing provider test**

Create `test/unit/presentation/providers/rip_health_provider_test.dart` (follow the existing provider-test style in `test/unit/presentation/providers/`; mock `IRipLibraryRepository` with mocktail and override `ripLibraryRepositoryProvider`):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  late MockRipLibraryRepository repo;
  late ProviderContainer container;

  final albumA = RipAlbum(
    id: 'a', libraryPath: '/a', trackCount: 1, totalSizeBytes: 100,
    lastScannedAt: 0, updatedAt: 0,
  );
  final trackVerified = RipTrack(
    id: 't1', ripAlbumId: 'a', trackNumber: 1, filePath: '/a/1.flac',
    fileSizeBytes: 10, updatedAt: 0,
    qualityCheckedAt: 1, accurateRipStatus: 'verified',
  );

  setUp(() {
    repo = MockRipLibraryRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([albumA]));
    when(() => repo.watchAllTracksByAlbum()).thenAnswer(
      (_) => Stream.value({'a': [trackVerified]}),
    );
    container = ProviderContainer(overrides: [
      ripLibraryRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
  });

  test('health map classifies albums from the tracks stream', () async {
    // Riverpod 3: listen before awaiting .future or the test hangs.
    container.listen(ripAllTracksByAlbumProvider, (_, __) {});
    await container.read(ripAllTracksByAlbumProvider.future);
    final map = container.read(ripAlbumHealthMapProvider);
    expect(map['a'], RipAlbumHealth.verified);
  });

  test('stats provider aggregates albums and tracks', () async {
    container.listen(ripAllTracksByAlbumProvider, (_, __) {});
    container.listen(allRipAlbumsProvider, (_, __) {});
    await container.read(ripAllTracksByAlbumProvider.future);
    await container.read(allRipAlbumsProvider.future);
    final stats = container.read(ripLibraryHealthStatsProvider);
    expect(stats.counts[RipAlbumHealth.verified], 1);
    expect(stats.totalSizeBytes, 100);
  });

  test('filter matches', () {
    expect(RipHealthFilter.all.matches(RipAlbumHealth.mismatch), isTrue);
    expect(
      RipHealthFilter.verified.matches(RipAlbumHealth.verified), isTrue);
    expect(
      RipHealthFilter.verified.matches(RipAlbumHealth.attention), isFalse);
    expect(container.read(ripHealthFilterProvider), RipHealthFilter.all);
    container.read(ripHealthFilterProvider.notifier)
        .set(RipHealthFilter.mismatch);
    expect(container.read(ripHealthFilterProvider), RipHealthFilter.mismatch);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/presentation/providers/rip_health_provider_test.dart`
Expected: FAIL — `rip_health_provider.dart` / `watchAllTracksByAlbum` don't exist.

- [ ] **Step 3: Add the DAO method**

In `lib/data/local/dao/rip_library_dao.dart`, read `watchTracksByMediaItem` (lines ~143–170) and add a sibling directly after it, mirroring its join/filter idioms exactly but grouping by album ID and without the media-item constraint:

```dart
  /// Stream of every track belonging to a non-deleted rip album, grouped
  /// by rip album ID. One query for the whole library — feeds the derived
  /// album-health model on the rips screen.
  Stream<Map<String, List<RipTracksTableData>>> watchAllTracksByAlbum() {
    final query = select(ripTracksTable).join([
      innerJoin(
        ripAlbumsTable,
        ripAlbumsTable.id.equalsExp(ripTracksTable.ripAlbumId),
      ),
    ])
      ..where(ripAlbumsTable.deleted.equals(false));
    return query.watch().map((rows) {
      final grouped = <String, List<RipTracksTableData>>{};
      for (final row in rows) {
        final track = row.readTable(ripTracksTable);
        grouped.putIfAbsent(track.ripAlbumId, () => []).add(track);
      }
      return grouped;
    });
  }
```

Adjust table getter names to whatever `watchTracksByMediaItem` actually uses (e.g. `ripTracksTable` vs `attachedDatabase.ripTracksTable`) — copy its idiom.

- [ ] **Step 4: Extend the repository interface + implementation**

`i_rip_library_repository.dart` — add below `watchTracksByMediaItem`:

```dart
  /// Every track of every non-deleted rip album, grouped by rip album ID.
  Stream<Map<String, List<RipTrack>>> watchAllTracksByAlbum();
```

`rip_library_repository_impl.dart` — implement by delegating to the DAO and mapping each `RipTracksTableData` to `RipTrack` with the same private mapper `watchTracksByMediaItem` uses (find it in the impl — do not write a new mapper):

```dart
  @override
  Stream<Map<String, List<RipTrack>>> watchAllTracksByAlbum() {
    return _dao.watchAllTracksByAlbum().map(
          (grouped) => grouped.map(
            (albumId, rows) =>
                MapEntry(albumId, rows.map(_trackFromRow).toList()),
          ),
        );
  }
```

(`_trackFromRow` is a stand-in — use the impl's actual row→entity function name.)

- [ ] **Step 5: Create lib/presentation/providers/rip_health_provider.dart**

```dart
// Author: Paul Snow

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// All tracks of non-deleted rip albums, grouped by album ID.
final ripAllTracksByAlbumProvider =
    StreamProvider<Map<String, List<RipTrack>>>((ref) {
  return ref.watch(ripLibraryRepositoryProvider).watchAllTracksByAlbum();
});

/// Derived health per album ID. Albums without a track entry are
/// classified [RipAlbumHealth.notAnalysed] by the lookup helper below.
final ripAlbumHealthMapProvider = Provider<Map<String, RipAlbumHealth>>((ref) {
  final tracksByAlbum =
      ref.watch(ripAllTracksByAlbumProvider).value ?? const {};
  return {
    for (final entry in tracksByAlbum.entries)
      entry.key: classifyRipAlbumHealth(entry.value),
  };
});

/// Health for one album, defaulting to notAnalysed when unknown.
RipAlbumHealth ripAlbumHealthOf(
  Map<String, RipAlbumHealth> healthMap,
  String albumId,
) =>
    healthMap[albumId] ?? RipAlbumHealth.notAnalysed;

/// Library-wide aggregate stats for the header cards.
final ripLibraryHealthStatsProvider = Provider<RipLibraryHealthStats>((ref) {
  final albums = ref.watch(allRipAlbumsProvider).value ?? const [];
  final tracksByAlbum =
      ref.watch(ripAllTracksByAlbumProvider).value ?? const {};
  return computeRipLibraryHealthStats(
    albums: albums,
    tracksByAlbum: tracksByAlbum,
  );
});

/// Health filter chips selection on the rips Library view.
enum RipHealthFilter { all, verified, attention, mismatch, notAnalysed }

extension RipHealthFilterMatch on RipHealthFilter {
  bool matches(RipAlbumHealth health) => switch (this) {
        RipHealthFilter.all => true,
        RipHealthFilter.verified => health == RipAlbumHealth.verified,
        RipHealthFilter.attention => health == RipAlbumHealth.attention,
        RipHealthFilter.mismatch => health == RipAlbumHealth.mismatch,
        RipHealthFilter.notAnalysed => health == RipAlbumHealth.notAnalysed,
      };
}

class RipHealthFilterNotifier extends Notifier<RipHealthFilter> {
  @override
  RipHealthFilter build() => RipHealthFilter.all;

  void set(RipHealthFilter value) => state = value;
}

final ripHealthFilterProvider =
    NotifierProvider<RipHealthFilterNotifier, RipHealthFilter>(
  RipHealthFilterNotifier.new,
);
```

Check where `ripLibraryRepositoryProvider` actually lives (`repository_providers.dart`) and import accordingly.

- [ ] **Step 6: Run tests** → the new test PASSES; run `flutter test` → all green (fix the placeholder listen noted in Step 1).

- [ ] **Step 7: Commit**

```bash
git add lib/data lib/domain/repositories lib/presentation/providers/rip_health_provider.dart test/unit/presentation/providers/rip_health_provider_test.dart
git commit -m "feat(rips): stream all rip tracks grouped by album and derive health providers"
```

---

### Task 4: Shared health widgets (pill, stat cards) + screen header eyebrow

**Files:**
- Create: `lib/presentation/screens/rips/widgets/rip_health_widgets.dart`
- Modify: `lib/presentation/widgets/screen_header.dart` (optional `eyebrow` param)
- Modify: `lib/presentation/screens/rips/rips_screen.dart`
- Test: `test/widget/rips/rip_health_widgets_test.dart`

**Interfaces:**
- Consumes: Task 2 enum/stats, Task 3 `ripLibraryHealthStatsProvider`, Task 1 `AppTypography.monoLabel/monoNumeric`, `context.mediaColors` (`app_media_colors.dart`).
- Produces:
  - `Color ripHealthColour(BuildContext context, RipAlbumHealth health)` — verified → `mediaColors.book`, attention → `mediaColors.tv`, mismatch → `colorScheme.error`, notAnalysed → `colorScheme.outline`.
  - `String ripHealthLabel(RipAlbumHealth health)` — `'VERIFIED' | 'ATTENTION' | 'MISMATCH' | 'NOT ANALYSED'`.
  - `IconData ripHealthIcon(RipAlbumHealth health)` — `Icons.verified | Icons.warning_amber | Icons.error | Icons.help_outline`.
  - `class RipStatusPill extends StatelessWidget { const RipStatusPill({required this.health, this.detail, super.key}); final RipAlbumHealth health; final String? detail; }` — pill with icon + label (+ optional ` · detail` suffix, e.g. `AR 16/16`).
  - `class RipHealthStatCards extends ConsumerWidget` — Row of four compact cards (VERIFIED, ATTENTION, AR COVERAGE, TOTAL SIZE).

- [ ] **Step 1: Write the failing widget test**

`test/widget/rips/rip_health_widgets_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  testWidgets('RipStatusPill renders label and detail', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(), // use the project's actual dark theme factory
      home: const Scaffold(
        body: RipStatusPill(
          health: RipAlbumHealth.verified,
          detail: 'AR 16/16',
        ),
      ),
    ));
    expect(find.textContaining('VERIFIED'), findsOneWidget);
    expect(find.textContaining('AR 16/16'), findsOneWidget);
  });

  testWidgets('RipHealthStatCards shows four cards with counts',
      (tester) async {
    final repo = MockRipLibraryRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value(const []));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value(const {}));
    await tester.pumpWidget(ProviderScope(
      overrides: [ripLibraryRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: RipHealthStatCards()),
      ),
    ));
    await tester.pump();
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.text('ATTENTION'), findsOneWidget);
    expect(find.text('AR COVERAGE'), findsOneWidget);
    expect(find.text('TOTAL SIZE'), findsOneWidget);
  });
}
```

Check how existing widget tests construct the theme (search `test/widget/` for `AppTheme`) and copy that idiom; the factory name above is a stand-in.

- [ ] **Step 2: Run test to verify it fails** — file/widgets don't exist.

- [ ] **Step 3: Implement rip_health_widgets.dart**

```dart
// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';

Color ripHealthColour(BuildContext context, RipAlbumHealth health) {
  final colors = Theme.of(context).colorScheme;
  final mediaColors = context.mediaColors;
  return switch (health) {
    RipAlbumHealth.verified => mediaColors.book,
    RipAlbumHealth.attention => mediaColors.tv,
    RipAlbumHealth.mismatch => colors.error,
    RipAlbumHealth.notAnalysed => colors.outline,
  };
}

String ripHealthLabel(RipAlbumHealth health) => switch (health) {
      RipAlbumHealth.verified => 'VERIFIED',
      RipAlbumHealth.attention => 'ATTENTION',
      RipAlbumHealth.mismatch => 'MISMATCH',
      RipAlbumHealth.notAnalysed => 'NOT ANALYSED',
    };

IconData ripHealthIcon(RipAlbumHealth health) => switch (health) {
      RipAlbumHealth.verified => Icons.verified,
      RipAlbumHealth.attention => Icons.warning_amber,
      RipAlbumHealth.mismatch => Icons.error,
      RipAlbumHealth.notAnalysed => Icons.help_outline,
    };

/// Small rounded status pill: icon + uppercase label, optionally suffixed
/// with a mono detail such as `AR 16/16`.
class RipStatusPill extends StatelessWidget {
  const RipStatusPill({required this.health, this.detail, super.key});

  final RipAlbumHealth health;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colour = ripHealthColour(context, health);
    final label = detail == null
        ? ripHealthLabel(health)
        : '${ripHealthLabel(health)} · $detail';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ripHealthIcon(health), size: 12, color: colour),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.monoLabel(color: colour)),
        ],
      ),
    );
  }
}

/// Four compact header stat cards: verified / attention / AR coverage /
/// total size. Reads [ripLibraryHealthStatsProvider].
class RipHealthStatCards extends ConsumerWidget {
  const RipHealthStatCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(ripLibraryHealthStatsProvider);
    final theme = Theme.of(context);
    final mediaColors = context.mediaColors;

    String formatSize(int bytes) {
      if (bytes >= 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatCard(
          label: 'VERIFIED',
          value: '${stats.counts[RipAlbumHealth.verified] ?? 0}',
          dotColour: mediaColors.book,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'ATTENTION',
          value: '${stats.counts[RipAlbumHealth.attention] ?? 0}',
          dotColour: mediaColors.tv,
          valueColour: mediaColors.tv,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'AR COVERAGE',
          value: '${(stats.arCoverage * 100).round()}%',
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'TOTAL SIZE',
          value: formatSize(stats.totalSizeBytes),
          valueColour: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.dotColour,
    this.valueColour,
  });

  final String label;
  final String value;
  final Color? dotColour;
  final Color? valueColour;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColour != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColour,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.monoLabel(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: AppTypography.monoNumeric(
              color: valueColour ?? colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Add the eyebrow to ScreenHeader**

`lib/presentation/widgets/screen_header.dart` — add `this.eyebrow` param (`final String? eyebrow;`) and render before the title inside the title `Column`:

```dart
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!,
                        style: AppTypography.monoLabel(
                          color: colors.primary,
                          letterSpacing: 2.4,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
```

Import `app_typography.dart`. Also render the title with `AppTypography.displayTitle` **only when an eyebrow is provided** (so other screens are untouched):

```dart
                    Text(
                      title,
                      style: eyebrow != null
                          ? AppTypography.displayTitle(
                              color: colors.onSurface)
                          : theme.textTheme.headlineLarge,
                      softWrap: true,
                    ),
```

- [ ] **Step 5: Wire into rips_screen.dart**

Replace the `const ScreenHeader(...)` with:

```dart
          const ScreenHeader(
            title: 'Rip Library',
            eyebrow: 'FLAC RIP COLLECTION',
            subtitle:
                'Manage your FLAC rip collection and compare coverage '
                'against physical media.',
            actions: [RipHealthStatCards()],
          ),
```

Import `rip_health_widgets.dart`. (Drop the `const` if the analyser complains.)

- [ ] **Step 6: Run tests** → new widget test PASSES; `flutter test` green.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/screens/rips lib/presentation/widgets/screen_header.dart test/widget/rips/rip_health_widgets_test.dart
git commit -m "feat(rips): health status pill, header stat cards and screen eyebrow"
```

---

### Task 5: Health filter chips wired into grid and table

**Files:**
- Create: `lib/presentation/screens/rips/widgets/rip_health_filter_chips.dart`
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` (toolbar area lines ~83–230)
- Test: `test/widget/rips/rip_health_filter_chips_test.dart`

**Interfaces:**
- Consumes: `ripHealthFilterProvider`, `ripLibraryHealthStatsProvider`, `ripAlbumHealthMapProvider`, `ripAlbumHealthOf`, `ripHealthColour`.
- Produces: `class RipHealthFilterChips extends ConsumerWidget` — a horizontal chip row; selecting a chip sets `ripHealthFilterProvider`.

- [ ] **Step 1: Write the failing widget test**

```dart
// test/widget/rips/rip_health_filter_chips_test.dart
// Pump RipHealthFilterChips inside ProviderScope with the mocked
// repository from Task 4's test (empty streams). Expect:
//  - five chips: 'All', 'Verified', 'Needs attention', 'Mismatch',
//    'Not analysed', each with a count suffix ('All 0' etc.).
//  - tapping 'Mismatch' updates ripHealthFilterProvider to
//    RipHealthFilter.mismatch (read via a ProviderContainer obtained
//    from tester.element + ProviderScope.containerOf).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_filter_chips.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  testWidgets('chips render with counts and set the filter', (tester) async {
    final repo = MockRipLibraryRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value(const []));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value(const {}));

    await tester.pumpWidget(ProviderScope(
      overrides: [ripLibraryRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: Scaffold(body: RipHealthFilterChips()),
      ),
    ));
    await tester.pump();

    expect(find.textContaining('All'), findsOneWidget);
    expect(find.textContaining('Needs attention'), findsOneWidget);

    await tester.tap(find.textContaining('Mismatch'));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RipHealthFilterChips)),
    );
    expect(container.read(ripHealthFilterProvider), RipHealthFilter.mismatch);
  });
}
```

- [ ] **Step 2: Run to verify it fails.**

- [ ] **Step 3: Implement rip_health_filter_chips.dart**

```dart
// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

/// Health status filter chips for the rips Library view. The selected
/// value filters both the album grid and the table.
class RipHealthFilterChips extends ConsumerWidget {
  const RipHealthFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(ripHealthFilterProvider);
    final stats = ref.watch(ripLibraryHealthStatsProvider);

    int countFor(RipHealthFilter filter) => switch (filter) {
          RipHealthFilter.all => stats.totalAlbums,
          RipHealthFilter.verified =>
            stats.counts[RipAlbumHealth.verified] ?? 0,
          RipHealthFilter.attention =>
            stats.counts[RipAlbumHealth.attention] ?? 0,
          RipHealthFilter.mismatch =>
            stats.counts[RipAlbumHealth.mismatch] ?? 0,
          RipHealthFilter.notAnalysed =>
            stats.counts[RipAlbumHealth.notAnalysed] ?? 0,
        };

    Color? dotFor(RipHealthFilter filter) => switch (filter) {
          RipHealthFilter.all => null,
          RipHealthFilter.verified =>
            ripHealthColour(context, RipAlbumHealth.verified),
          RipHealthFilter.attention =>
            ripHealthColour(context, RipAlbumHealth.attention),
          RipHealthFilter.mismatch =>
            ripHealthColour(context, RipAlbumHealth.mismatch),
          RipHealthFilter.notAnalysed => null,
        };

    String labelFor(RipHealthFilter filter) => switch (filter) {
          RipHealthFilter.all => 'All',
          RipHealthFilter.verified => 'Verified',
          RipHealthFilter.attention => 'Needs attention',
          RipHealthFilter.mismatch => 'Mismatch',
          RipHealthFilter.notAnalysed => 'Not analysed',
        };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in RipHealthFilter.values) ...[
            ChoiceChip(
              selected: selected == filter,
              showCheckmark: false,
              shape: const StadiumBorder(),
              avatar: dotFor(filter) == null
                  ? null
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotFor(filter),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
              label: Text('${labelFor(filter)} ${countFor(filter)}'),
              onSelected: (_) =>
                  ref.read(ripHealthFilterProvider.notifier).set(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Wire into RipLibraryView**

In `rip_library_view.dart`:

1. After the toolbar `Padding` (the Row with SearchBar/Scan/Analyse All, ends ~line 164), insert:

```dart
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: RipHealthFilterChips(),
        ),
```

2. In the `data:` callback (~line 214), extend filtering — watch the providers at the top of `build` (`final healthMap = ref.watch(ripAlbumHealthMapProvider); final healthFilter = ref.watch(ripHealthFilterProvider);`) and replace the `filtered` computation with:

```dart
              var filtered = _searchQuery.isEmpty
                  ? albums
                  : albums.where((a) {
                      final artist = (a.artist ?? '').toLowerCase();
                      final title = (a.albumTitle ?? '').toLowerCase();
                      return artist.contains(_searchQuery) ||
                          title.contains(_searchQuery);
                    }).toList();
              if (healthFilter != RipHealthFilter.all) {
                filtered = filtered
                    .where((a) => healthFilter
                        .matches(ripAlbumHealthOf(healthMap, a.id)))
                    .toList();
              }
```

3. Adjust the empty state: when `filtered.isEmpty && albums.isNotEmpty`, show message `'No albums match the current filter.'` instead of the scan hint.

Add imports for `rip_health_provider.dart` and `rip_health_filter_chips.dart`.

- [ ] **Step 5: Run tests** → new test PASSES; `flutter test` green.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/rips test/widget/rips/rip_health_filter_chips_test.dart
git commit -m "feat(rips): health filter chips filtering grid and table views"
```

---

### Task 6: Album card redesign

**Files:**
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` — `_RipAlbumCard` (lines ~346–534) and the `GridView.builder` delegate (~lines 239–246)
- Test: `test/widget/rips/rip_album_card_test.dart`

**Interfaces:**
- Consumes: `RipStatusPill`, `ripHealthColour`, `ripAlbumHealthMapProvider`, `ripAlbumHealthOf`, `classifyRipAlbumHealth` (via map), `ripTracksProvider`, `AppTypography`, `qualityAnalysisNotifierProvider` (existing, for the Analyse chip).
- Produces: `_RipAlbumCard` keeps its constructor signature (`album`, `onTap`, `onLongPress`, `isSelected`, `showCheckbox`) so call sites don't change.

- [ ] **Step 1: Write the failing widget test**

`test/widget/rips/rip_album_card_test.dart` — because `_RipAlbumCard` is private, test through `RipLibraryView` is heavyweight; instead promote the card to a public widget: rename `_RipAlbumCard` → `RipAlbumCard` in a new file `lib/presentation/screens/rips/widgets/rip_album_card.dart` and update `rip_library_view.dart` to import and use it. The test pumps `RipAlbumCard` directly with mocked repository (streams: one album, tracks all verified) and expects:

```dart
// - find.text('VERIFIED') (status pill)
// - find.textContaining('ACCURATERIP') and find.text('16 / 16') given 16
//   verified tracks
// - find.text('FLAC') format chip
// - find.textContaining('0 defects')
// Also a second pumpWidget with unanalysed tracks expecting
// find.text('NOT ANALYSED') and find.text('Analyse').
```

Write the full test with the same mocktail scaffolding as Task 5 (override `ripLibraryRepositoryProvider`; `ripTracksProvider` reads the repository's `getTracksForAlbum`, so stub `when(() => repo.getTracksForAlbum('a'))` too).

- [ ] **Step 2: Run to verify it fails.**

- [ ] **Step 3: Implement the card**

Create `lib/presentation/screens/rips/widgets/rip_album_card.dart`, moving the widget out of `rip_library_view.dart`. Full build:

```dart
// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_album_detail_dialog.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_cover_thumb.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

/// Redesigned album card: cover, artist eyebrow, title, health pill,
/// meta row, AccurateRip progress and detail chips.
class RipAlbumCard extends ConsumerWidget {
  const RipAlbumCard({
    required this.album,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showCheckbox = false,
    super.key,
  });

  final RipAlbum album;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tracks =
        ref.watch(ripTracksProvider(album.id)).whenOrNull(data: (t) => t) ??
            const <RipTrack>[];
    final healthMap = ref.watch(ripAlbumHealthMapProvider);
    final health = ripAlbumHealthOf(healthMap, album.id);
    final healthColour = ripHealthColour(context, health);
    final nowPlayingAlbumId =
        ref.watch(nowPlayingProvider.select((s) => s.album?.id));
    final isNowPlaying = nowPlayingAlbumId == album.id;

    final arVerified =
        tracks.where((t) => t.accurateRipStatus == 'verified').length;
    final totalDefects =
        tracks.fold<int>(0, (sum, t) => sum + t.totalDefects);
    final totalDurationMs =
        tracks.fold<int>(0, (sum, t) => sum + (t.durationMs ?? 0));
    final hasCue = album.cueFilePath != null;
    final hasLog = tracks.any((t) => t.ripLogSource != null);
    final format = _formatOf(tracks);

    final highlight = isSelected || isNowPlaying;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: highlight
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ??
            () => showDialog<void>(
                  context: context,
                  builder: (_) => RipAlbumDetailDialog(album: album),
                ),
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RipCoverThumb(coverPath: album.coverPath, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (album.artist ?? 'UNKNOWN ARTIST')
                                  .toUpperCase(),
                              style: AppTypography.monoLabel(
                                color: colors.onSurfaceVariant,
                                fontSize: 8.5,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              album.albumTitle ?? 'Unknown Album',
                              style: AppTypography.displayTitle(
                                color: colors.onSurface,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      RipStatusPill(health: health),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.music_note,
                          size: 13, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${album.trackCount}', style: _metaStyle(colors)),
                      const SizedBox(width: 15),
                      Text(_formatSize(album.totalSizeBytes),
                          style: _metaStyle(colors)),
                      if (totalDurationMs > 0) ...[
                        const SizedBox(width: 15),
                        Text(_formatTotalDuration(totalDurationMs),
                            style: _metaStyle(colors)),
                      ],
                      const Spacer(),
                      if (isNowPlaying)
                        Icon(Icons.volume_up,
                            size: 14, color: colors.primary),
                      if (album.mediaItemId != null)
                        Padding(
                          padding:
                              EdgeInsets.only(left: isNowPlaying ? 6 : 0),
                          child: Icon(Icons.link,
                              size: 14, color: colors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACCURATERIP',
                        style: AppTypography.monoLabel(
                          color: colors.outline,
                          fontSize: 8.5,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        health == RipAlbumHealth.notAnalysed
                            ? '— / ${tracks.length}'
                            : '$arVerified / ${tracks.length}',
                        style: AppTypography.monoLabel(
                          color: healthColour,
                          fontSize: 8.5,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: tracks.isEmpty ? 0 : arVerified / tracks.length,
                      minHeight: 5,
                      backgroundColor: colors.surfaceContainerHighest,
                      color: healthColour,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (format != null)
                        _MiniChip(label: format),
                      if (health == RipAlbumHealth.notAnalysed)
                        _MiniChip(
                          label: 'Analyse',
                          icon: Icons.analytics,
                          colour: colors.primary,
                          onTap: () => ref
                              .read(qualityAnalysisNotifierProvider.notifier)
                              .analyse(album.id),
                        )
                      else
                        _MiniChip(
                          label: totalDefects == 0
                              ? '0 defects'
                              : '$totalDefects defects',
                          colour: totalDefects == 0
                              ? ripHealthColour(
                                  context, RipAlbumHealth.verified)
                              : ripHealthColour(
                                  context, RipAlbumHealth.attention),
                        ),
                      if (hasCue || hasLog)
                        _MiniChip(
                          label: hasCue && hasLog
                              ? 'CUE + LOG'
                              : hasCue
                                  ? 'CUE'
                                  : 'LOG',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (showCheckbox)
              Positioned(
                top: 6,
                right: 6,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _metaStyle(ColorScheme colors) => AppTypography.monoLabel(
        color: colors.onSurfaceVariant,
        fontSize: 10,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w600,
      );

  String? _formatOf(List<RipTrack> tracks) {
    if (tracks.isEmpty) return null;
    final path = tracks.first.filePath.toLowerCase();
    if (path.endsWith('.flac')) return 'FLAC';
    if (path.endsWith('.mp3')) return 'MP3';
    return null;
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }

  String _formatTotalDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.icon, this.colour, this.onTap});

  final String label;
  final IconData? icon;
  final Color? colour;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = colour ?? colors.onSurfaceVariant;
    final bg = colour != null
        ? colour!.withValues(alpha: 0.12)
        : colors.surfaceContainerHighest;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.monoLabel(
              color: fg,
              fontSize: 9.5,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: chip,
    );
  }
}
```

Check `RipCoverThumb`'s constructor for the size param name (`size:`); adapt if different.

- [ ] **Step 4: Update rip_library_view.dart**

- Remove the old `_RipAlbumCard` class and its `_formatSize`; import and use `RipAlbumCard` (same arguments).
- Update the grid delegate for the taller card:

```dart
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisExtent: 208,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
```

- [ ] **Step 5: Run tests** → new test PASSES; `flutter test` green (fix any existing tests that referenced the old card layout).

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/rips test/widget/rips/rip_album_card_test.dart
git commit -m "feat(rips): redesigned album card with health pill, AR progress and chips"
```

---

### Task 7: Detail panel restyle

**Files:**
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart` — `_RipAlbumDetailPanel` (lines ~605–997)
- Create: `lib/presentation/screens/rips/widgets/rip_quality_report.dart`
- Test: `test/widget/rips/rip_quality_report_test.dart`

**Interfaces:**
- Consumes: `RipStatusPill`, `ripHealthColour`, health providers, `AppTypography`, existing `InlinePlayerControls`, `QualityAnalysisSection`, `QualityIcon`, `formatPlaybackDurationMs`.
- Produces:
  - `class RipQualityReport extends StatelessWidget { const RipQualityReport({required this.tracks, super.key}); final List<RipTrack> tracks; }` — the 2×2 metric grid.
  - `class RipSourceSection extends StatelessWidget { const RipSourceSection({required this.album, required this.tracks, super.key}); }` — the Source rows. Both live in `rip_quality_report.dart`.

- [ ] **Step 1: Write the failing widget test**

`test/widget/rips/rip_quality_report_test.dart` — pump `RipQualityReport` with two verified tracks (`trackQuality: 0.98` and `1.0`, `accurateRipConfidence: 156` and `142`, `peakLevel: 0.996`, zero defects) and expect:

```dart
// find.text('QUALITY SCORE') and find.textContaining('99')   (avg 0.99 → 99)
// find.text('AR CONFIDENCE') and find.text('142')            (minimum)
// find.text('PEAK LEVEL') and find.textContaining('99.6')    (0.996 → 99.6%)
// find.text('DEFECTS') and find.text('0')
// And RipSourceSection with album(cueFilePath set), tracks with
// ripLogSource 'XLD': find.text('XLD'), find.text('CUE + LOG'),
// find.text('—') for missing gnudbDiscId.
```

Write the complete test using the entity constructors from Task 2's test helpers.

- [ ] **Step 2: Run to verify it fails.**

- [ ] **Step 3: Implement rip_quality_report.dart**

```dart
// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// 2×2 grid of album-level quality metrics derived from analysed tracks.
class RipQualityReport extends StatelessWidget {
  const RipQualityReport({required this.tracks, super.key});

  final List<RipTrack> tracks;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final qualities = tracks
        .map((t) => t.trackQuality)
        .whereType<double>()
        .toList(growable: false);
    final avgQuality = qualities.isEmpty
        ? null
        : qualities.reduce((a, b) => a + b) / qualities.length;

    final confidences = tracks
        .where((t) => t.accurateRipStatus == 'verified')
        .map((t) => t.accurateRipConfidence)
        .whereType<int>()
        .toList(growable: false);
    final minConfidence = confidences.isEmpty
        ? null
        : confidences.reduce((a, b) => a < b ? a : b);

    final peaks = tracks
        .map((t) => t.peakLevel)
        .whereType<double>()
        .toList(growable: false);
    final maxPeak =
        peaks.isEmpty ? null : peaks.reduce((a, b) => a > b ? a : b);

    final totalDefects =
        tracks.fold<int>(0, (sum, t) => sum + t.totalDefects);

    String peakText(double p) =>
        p <= 1 ? '${(p * 100).toStringAsFixed(1)}%' : p.toStringAsFixed(2);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 2.6,
      children: [
        _MetricTile(
          label: 'QUALITY SCORE',
          value: avgQuality == null
              ? '—'
              : '${(avgQuality * 100).round()}',
          suffix: avgQuality == null ? null : '/100',
        ),
        _MetricTile(
          label: 'AR CONFIDENCE',
          value: minConfidence?.toString() ?? '—',
        ),
        _MetricTile(
          label: 'PEAK LEVEL',
          value: maxPeak == null ? '—' : peakText(maxPeak),
        ),
        _MetricTile(
          label: 'DEFECTS',
          value: '$totalDefects',
          valueColour: totalDefects > 0 ? colors.error : null,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.suffix,
    this.valueColour,
  });

  final String label;
  final String value;
  final String? suffix;
  final Color? valueColour;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.monoLabel(
              color: colors.onSurfaceVariant,
              fontSize: 8.5,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text.rich(
            TextSpan(
              text: value,
              style: AppTypography.monoNumeric(
                color: valueColour ?? colors.onSurface,
                fontSize: 21,
              ),
              children: [
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: AppTypography.monoNumeric(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Provenance rows: rip tool, CUE/LOG presence, GNUDB disc ID.
class RipSourceSection extends StatelessWidget {
  const RipSourceSection({
    required this.album,
    required this.tracks,
    super.key,
  });

  final RipAlbum album;
  final List<RipTrack> tracks;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ripTool = tracks
        .map((t) => t.ripLogSource)
        .whereType<String>()
        .firstOrNull;
    final hasCue = album.cueFilePath != null;
    final hasLog = ripTool != null;
    final cueLog = hasCue && hasLog
        ? 'CUE + LOG'
        : hasCue
            ? 'CUE only'
            : hasLog
                ? 'LOG only'
                : 'None';

    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            children: [
              Icon(icon, size: 16, color: colors.outline),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTypography.monoLabel(
                  color: colors.onSurface,
                  fontSize: 11,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        row(Icons.album, 'Ripped with', ripTool ?? '—'),
        row(Icons.verified_user, 'CUE + LOG', cueLog),
        row(Icons.travel_explore, 'GNUDB disc', album.gnudbDiscId ?? '—'),
      ],
    );
  }
}
```

- [ ] **Step 4: Restyle _RipAlbumDetailPanel**

In `rip_library_view.dart`, modify the **non-edit** build path only (edit mode stays as-is):

1. Header toolbar Row (lines ~826–860): replace the two-line artist/title column with cover + eyebrow + title + pill. Compute above the return: `final tracks = tracksAsync.whenOrNull(data: (t) => t) ?? <RipTrack>[]; final healthMap = ref.watch(ripAlbumHealthMapProvider); final health = ripAlbumHealthOf(healthMap, widget.album.id); final arVerified = tracks.where((t) => t.accurateRipStatus == 'verified').length;`

```dart
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RipCoverThumb(
                        coverPath: widget.album.coverPath, size: 76),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.album.artist ?? 'UNKNOWN ARTIST')
                                .toUpperCase(),
                            style: AppTypography.monoLabel(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 9,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.album.albumTitle ?? 'Unknown Album',
                            style: AppTypography.displayTitle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 9),
                          RipStatusPill(
                            health: health,
                            detail: tracks.isEmpty
                                ? null
                                : 'AR $arVerified/${tracks.length}',
                          ),
                        ],
                      ),
                    ),
                    PlayAlbumButton(album: widget.album),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit metadata',
                      onPressed: () => setState(() => _editing = true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Close panel',
                      onPressed: () =>
                          ref.read(selectedRipAlbumProvider.notifier).clear(),
                    ),
                  ],
                ),
```

2. Delete the standalone 140 px `RipCoverThumb` block (lines ~873–882) — the cover now lives in the header.
3. Between `InlinePlayerControls` and the `TRACKS` label, insert the new sections:

```dart
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(context, 'QUALITY REPORT'),
              const SizedBox(height: 8),
              RipQualityReport(
                tracks: tracksAsync.whenOrNull(data: (t) => t) ??
                    const <RipTrack>[],
              ),
              const SizedBox(height: 14),
              _sectionLabel(context, 'SOURCE'),
              const SizedBox(height: 8),
              RipSourceSection(
                album: widget.album,
                tracks: tracksAsync.whenOrNull(data: (t) => t) ??
                    const <RipTrack>[],
              ),
            ],
          ),
        ),
```

with a small helper in the State class:

```dart
  Widget _sectionLabel(BuildContext context, String text) => Text(
        text,
        style: AppTypography.monoLabel(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 9.5,
          letterSpacing: 1.5,
        ),
      );
```

Replace the existing `'TRACKS'` Text with `_sectionLabel(context, 'TRACKS')`.

4. Track list rows: keep the `ListTile` but restyle — leading stays (`QualityIcon`/volume icon); title row gains a mono track number prefix and trailing AR confidence + duration. Replace the `ListTile` with:

```dart
                  final isVerified = track.accurateRipStatus == 'verified';
                  return Material(
                    color: isThisTrackPlaying
                        ? theme.colorScheme.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () {
                        if (!ref.read(playOnSelectProvider)) return;
                        final np = ref.read(nowPlayingProvider);
                        final actions =
                            ref.read(playbackActionProvider.notifier);
                        if (np.album?.id == widget.album.id) {
                          actions.seekToIndex(index);
                        } else {
                          actions.playAlbum(
                            album: widget.album,
                            tracks: tracks,
                            startIndex: index,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            isThisTrackPlaying
                                ? Icon(Icons.volume_up,
                                    color: theme.colorScheme.primary,
                                    size: 16)
                                : QualityIcon(track: track),
                            const SizedBox(width: 10),
                            Text(
                              track.trackNumber.toString().padLeft(2, '0'),
                              style: AppTypography.monoLabel(
                                color: isThisTrackPlaying
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                fontSize: 10,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                track.title ?? 'Track ${track.trackNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: track.title == null
                                      ? FontStyle.italic
                                      : null,
                                  color: isThisTrackPlaying
                                      ? theme.colorScheme.primary
                                      : (track.title == null
                                          ? theme.colorScheme.onSurfaceVariant
                                          : null),
                                ),
                              ),
                            ),
                            if (isVerified &&
                                track.accurateRipConfidence != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'AR ${track.accurateRipConfidence}',
                                style: AppTypography.monoLabel(
                                  color: theme.colorScheme.outline,
                                  fontSize: 9,
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            Text(
                              formatPlaybackDurationMs(track.durationMs),
                              style: AppTypography.monoLabel(
                                color: isThisTrackPlaying
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
```

Wrap the whole panel body (everything below the toolbar) in a `ListView`/`SingleChildScrollView` if the added sections overflow — the current layout relies on `Expanded` for the track list; keep `Expanded(child: tracksAsync.when(...))` and let the new sections sit above it (they are compact); if `flutter analyze`/runtime shows overflow on short panels, convert the Column body to a `CustomScrollView` as a follow-up fix in this task. Keep the disc-number information: when any track has `discNumber > 1`, prefix the number cell with `'${track.discNumber}-'`.

- [ ] **Step 5: Run tests** → new test PASSES; `flutter test` green.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/rips test/widget/rips/rip_quality_report_test.dart
git commit -m "feat(rips): detail panel quality report, source section and restyled tracks"
```

---

### Task 8: Audit other screens against the design; fix small gaps

**Files:**
- Modify (only if a small gap is found): files under `lib/presentation/screens/{dashboard,collection,insights,scanner,item_detail,settings}/` and `lib/presentation/widgets/`
- Create: `docs/superpowers/specs/2026-07-17-design-audit.md`

**Interfaces:** none produced; consumes the design reference at
`/private/tmp/claude-501/-Users-paul-gitHub-MyMediaScanner/930eedc7-9bb4-4bef-9ca2-d3a46860f0f1/scratchpad/media_scanner_themed.dc.html` (design frames: Desktop Library, Desktop Rips, Desktop Insights, Mobile Home, Mobile Library, Mobile Appearance, Mobile Scanner, Mobile Item Detail).

- [ ] **Step 1: Audit each screen**

For each design frame, read the corresponding screen source and record in a table: element in design → present in app? → cosmetic drift? → fixed / deferred / design-fiction. Rules:
- Fix ONLY low-risk cosmetic drift (label casing, chip shape, stat-card caption/value styling where the widget already exists).
- Defer anything structural (new sections, new nav entries, sidebar "Rip health" legend, user-profile footer, "PRO MEMBER" badge, "Est. value"/"Scan accuracy" stats that have no data source — mark these design-fiction).
- Every fix gets its own minimal diff; run `flutter test` after each.

- [ ] **Step 2: Write the audit report**

Create `docs/superpowers/specs/2026-07-17-design-audit.md` with the table (columns: Screen | Design element | Status in app | Action | Notes).

- [ ] **Step 3: Run full test suite** → green.

- [ ] **Step 4: Commit**

```bash
git add -A docs lib test
git commit -m "docs(design): audit screens against themed design and fix cosmetic drift"
```

---

### Task 9: Verification — analyse, full tests, manual smoke

- [ ] **Step 1: Static analysis**

Run: `flutter analyze` → no new warnings/errors.

- [ ] **Step 2: Full test suite**

Run: `flutter test` → all ~1,713+ tests pass.

- [ ] **Step 3: Manual smoke via Marionette (macOS debug build)**

Run `flutter run -d macos`, connect Marionette MCP with the VM service URI, then verify on the Rips screen:
- Stat cards show real counts; chips filter grid AND table; empty-filter message correct.
- Card: pill, AR bar, chips render; Analyse chip triggers analysis on an unanalysed album.
- Detail panel: quality report values, source rows, track rows, playback highlight; edit mode still saves; GNUDB button present.
- Switch theme family Kinetic → Vault → Index (Settings → Appearance), light + dark: no unreadable text, health colours track the palette.
- Table mode, multi-select (long-press), batch analysis, queue panel all still work.
- Take screenshots for the PR.
(Remember: after `hot_restart` via Marionette, the app may need a `tap` to recover; `get_logs` is unreliable — use console output.)

- [ ] **Step 4: Final commit if smoke fixes were needed; otherwise proceed to branch finishing (superpowers:finishing-a-development-branch).**
