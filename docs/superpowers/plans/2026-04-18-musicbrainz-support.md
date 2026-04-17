# MusicBrainz Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the remaining gaps between the MusicBrainz support currently in `main` and the requirements in issue #51 so music scans default to MusicBrainz with full canonical metadata, polished disambiguation, rate-limit-aware networking, Cover Art Archive artwork, Discogs fallback, and visible source provenance.

**Architecture:** MusicBrainz is already wired as the primary music provider (`_lookupMusic` in `metadata_repository_impl.dart`). This plan fills the remaining PRD gaps: extended metadata persistence (artist MBIDs, release date/country/packaging/track/disc counts), richer disambiguation candidates, a dedicated Cover Art Archive client with release-group fallback, HTTP 503 rate-limit detection with back-off, ranking rules for auto-accept, a dynamic User-Agent with the app version, a source-provenance badge on the review screen, and integration tests.

**Tech Stack:** Flutter 3.x, Dart, Dio, Freezed, Drift, Riverpod 3.x, mocktail, flutter_test. Existing `RateLimiter` utility, existing `DioFactory`, existing `MetadataResult`/`MetadataCandidate` Freezed entities.

---

## Baseline (already in `main`)

Do **not** re-implement these — they exist and work:

- `lib/data/remote/api/musicbrainz/musicbrainz_api.dart` — search by barcode/title, release detail, built-in `RateLimiter(1100ms)`.
- `lib/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart` — DTOs including `MusicBrainzSearchResponseDto`, `MusicBrainzReleaseDto` with `coverUrl` getter (`https://coverartarchive.org/release/<id>/front-250`).
- `lib/data/mappers/musicbrainz_mapper.dart` — maps DTO → `MetadataResult` with `musicbrainz_release_id`, `musicbrainz_release_group_id`, artists (names), catalogue number, label, country, track listing.
- `lib/data/repositories/metadata_repository_impl.dart` — `_lookupMusic` tries MusicBrainz first, Discogs fallback; `_fetchMusicBrainzDetail` for disambiguation; cache rehydration handles `'musicbrainz'` source.
- `lib/presentation/providers/repository_providers.dart:81` — `MusicBrainzApi()` is always instantiated.
- `lib/presentation/screens/settings/widgets/api_key_form.dart:58` — note that MusicBrainz needs no key.
- `test/unit/data/mappers/musicbrainz_mapper_test.dart` — mapper tests.

---

## Files Touched by This Plan

**Created:**
- `lib/core/utils/rate_limit_aware_client.dart` — helper that wraps `RateLimiter` plus 503 Retry-After back-off.
- `lib/data/remote/api/musicbrainz/cover_art_archive_api.dart` — dedicated Cover Art Archive client.
- `lib/data/remote/api/musicbrainz/models/cover_art_archive_dto.dart` — DTOs for Cover Art Archive JSON.
- `test/unit/data/remote/api/musicbrainz/cover_art_archive_api_test.dart`
- `test/unit/core/utils/rate_limit_aware_client_test.dart`
- `test/unit/data/repositories/metadata_repository_musicbrainz_test.dart` — MusicBrainz-path repo tests (happy path, disambiguation, Discogs fallback, 503 back-off, Cover Art Archive integration).

**Modified:**
- `lib/core/constants/api_constants.dart` — add `coverArtArchiveBaseUrl`; swap hardcoded User-Agent for a factory using the app version.
- `lib/data/remote/api/musicbrainz/musicbrainz_api.dart` — share the `RateLimitAwareClient` helper and surface a rate-limited error type; inject the User-Agent string.
- `lib/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart` — add optional `release-group` typing for when `inc=release-groups` returns group-level artist credits; tolerate no-barcode / no-release-group data.
- `lib/data/mappers/musicbrainz_mapper.dart` — extend `fromRelease` with artist MBIDs, release date, release country, packaging, track count, disc count, status, data quality; extend `toCandidate` with country, label, catalogue number, track count, status, packaging.
- `lib/domain/entities/metadata_candidate.dart` — add optional `country`, `label`, `catalogueNumber`, `trackCount`, `status`, `packaging` fields (all nullable, additive).
- `lib/presentation/screens/disambiguation/widgets/candidate_card.dart` — render the new fields when present.
- `lib/data/repositories/metadata_repository_impl.dart` — rank MusicBrainz candidates (prefer Official + physical format + metadata completeness); auto-accept high-confidence single matches; integrate Cover Art Archive fallback when `coverartarchive.org/release/<id>` returns no front image; propagate rate-limit error.
- `lib/presentation/providers/repository_providers.dart` — construct `MusicBrainzApi` and `CoverArtArchiveApi` with the new User-Agent factory; pass `coverArtApi` through.
- `lib/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart` — show a small source badge derived from `initial.sourceApis`.
- `lib/presentation/screens/settings/widgets/api_key_form.dart` — restructure help text so "MusicBrainz — built-in, no key required" is explicit.

---

## Preflight

- [ ] **Step 0.1: Sanity-check baseline**

Run: `gradle21w --version` (confirm the gradle wrapper shim is on PATH)
Run: `flutter test test/unit/data/mappers/musicbrainz_mapper_test.dart`
Expected: All tests pass (baseline green).

If the baseline is red, stop and report.

---

## Task 1: Extend `MetadataCandidate` with music-disambiguation fields

PRD FR-7 requires showing country, label, catalogue number, track count, format, year on each disambiguation candidate. The current `MetadataCandidate` only holds title/subtitle/year/format. Add nullable fields additively so other providers keep compiling.

**Files:**
- Modify: `lib/domain/entities/metadata_candidate.dart`
- Generated: `lib/domain/entities/metadata_candidate.freezed.dart` (regenerated by build_runner)

- [ ] **Step 1.1: Extend the Freezed entity**

Replace the entity definition with:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'metadata_candidate.freezed.dart';

@freezed
sealed class MetadataCandidate with _$MetadataCandidate {
  const factory MetadataCandidate({
    required String sourceApi,
    required String sourceId,
    required String title,
    String? subtitle,
    String? coverUrl,
    int? year,
    String? format,
    MediaType? mediaType,
    // Music-specific disambiguation helpers (optional).
    String? country,
    String? label,
    String? catalogueNumber,
    int? trackCount,
    String? status,
    String? packaging,
  }) = _MetadataCandidate;
}
```

- [ ] **Step 1.2: Regenerate Freezed code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: No errors; `metadata_candidate.freezed.dart` updated.

- [ ] **Step 1.3: Confirm nothing else broke**

Run: `flutter analyze lib`
Expected: `No issues found!`

- [ ] **Step 1.4: Commit**

```bash
git add lib/domain/entities/metadata_candidate.dart lib/domain/entities/metadata_candidate.freezed.dart
git commit -m "feat: extend MetadataCandidate with music-disambiguation fields"
```

---

## Task 2: Enrich `MusicBrainzMapper` output (artist MBIDs + extended fields)

PRD FR-14 (artist MBIDs), Section 12.1 (release date/country/packaging/track count/disc count/data quality), and FR-7 (candidate fields) need the mapper to emit these. All additions go through `extra_metadata` to stay schema-safe (Section 12.2).

**Files:**
- Modify: `lib/data/mappers/musicbrainz_mapper.dart`
- Test: `test/unit/data/mappers/musicbrainz_mapper_test.dart`

- [ ] **Step 2.1: Add failing tests for the new mapped fields**

Append inside the existing `group('fromRelease', () { ... })` in `test/unit/data/mappers/musicbrainz_mapper_test.dart`:

```dart
test('persists artist MBIDs, release date, country, packaging, '
    'track count, disc count, status', () {
  const release = MusicBrainzReleaseDto(
    id: 'rel-1',
    title: 'Example',
    status: 'Official',
    date: '2001-06-14',
    country: 'GB',
    packaging: 'Jewel Case',
    artistCredit: [
      MusicBrainzArtistCreditDto(
        name: 'A',
        artist: MusicBrainzArtistDto(id: 'art-1', name: 'A'),
      ),
      MusicBrainzArtistCreditDto(
        name: 'B',
        artist: MusicBrainzArtistDto(id: 'art-2', name: 'B'),
      ),
    ],
    media: [
      MusicBrainzMediaDto(format: 'CD', discCount: 2, trackCount: 12),
    ],
  );

  final result =
      MusicBrainzMapper.fromRelease(release, '1234', 'ean13');

  expect(result.extraMetadata['musicbrainz_artist_ids'],
      ['art-1', 'art-2']);
  expect(result.extraMetadata['release_date'], '2001-06-14');
  expect(result.extraMetadata['release_country'], 'GB');
  expect(result.extraMetadata['packaging'], 'Jewel Case');
  expect(result.extraMetadata['track_count'], 12);
  expect(result.extraMetadata['disc_count'], 2);
  expect(result.extraMetadata['status'], 'Official');
});
```

Append inside the existing `group('toCandidate', () { ... })`:

```dart
test('carries country, label, catalogue number, track count, status', () {
  const release = MusicBrainzReleaseDto(
    id: 'rel-2',
    title: 'With Label',
    status: 'Official',
    country: 'US',
    packaging: 'Digipak',
    labelInfo: [
      MusicBrainzLabelInfoDto(
        catalogNumber: 'ABC-1',
        label: MusicBrainzLabelDto(id: 'lab-1', name: 'Indie Records'),
      ),
    ],
    media: [
      MusicBrainzMediaDto(format: 'CD', trackCount: 10),
    ],
  );

  final candidate = MusicBrainzMapper.toCandidate(release);

  expect(candidate.country, 'US');
  expect(candidate.label, 'Indie Records');
  expect(candidate.catalogueNumber, 'ABC-1');
  expect(candidate.trackCount, 10);
  expect(candidate.status, 'Official');
  expect(candidate.packaging, 'Digipak');
});
```

- [ ] **Step 2.2: Run tests to verify failure**

Run: `flutter test test/unit/data/mappers/musicbrainz_mapper_test.dart`
Expected: The two new tests fail (missing keys / null fields).

- [ ] **Step 2.3: Implement the mapper changes**

Replace `lib/data/mappers/musicbrainz_mapper.dart` with:

```dart
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class MusicBrainzMapper {
  static MetadataResult fromRelease(
    MusicBrainzReleaseDto dto,
    String barcode,
    String barcodeType,
  ) {
    final artistIds = dto.artistCredit
            ?.map((c) => c.artist?.id)
            .whereType<String>()
            .toList() ??
        const <String>[];
    final artistNames = dto.artistCredit
            ?.map((c) => c.name ?? c.artist?.name)
            .whereType<String>()
            .toList() ??
        const <String>[];
    final primaryMedia = dto.media?.firstOrNull;
    final trackListing = dto.media
            ?.expand((m) => m.tracks ?? const <MusicBrainzTrackDto>[])
            .map((t) => <String, dynamic>{
                  'position': t.number,
                  'title': t.title,
                  'duration_ms': t.length,
                })
            .toList() ??
        const <Map<String, dynamic>>[];

    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.music,
      title: dto.title,
      subtitle: dto.effectiveArtist,
      coverUrl: dto.coverUrl,
      year: dto.effectiveYear,
      publisher: dto.effectiveLabel,
      format: dto.effectiveFormat,
      genres: dto.tags?.map((t) => t.name).whereType<String>().toList() ??
          const [],
      extraMetadata: {
        'musicbrainz_release_id': dto.id,
        'musicbrainz_release_group_id': dto.releaseGroupId,
        'musicbrainz_artist_ids': artistIds,
        'artists': artistNames,
        'catalogue_number': dto.labelInfo?.firstOrNull?.catalogNumber,
        'label': dto.effectiveLabel,
        'country': dto.country,
        'release_date': dto.date,
        'release_country': dto.country,
        'packaging': dto.packaging,
        'status': dto.status,
        'track_count': primaryMedia?.trackCount ?? dto.trackCount,
        'disc_count': primaryMedia?.discCount,
        'track_listing': trackListing,
      },
      sourceApis: const ['musicbrainz'],
      seriesExternalId:
          dto.releaseGroupId != null ? 'mb:${dto.releaseGroupId}' : null,
      seriesName: dto.releaseGroup?.title,
    );
  }

  static MetadataCandidate toCandidate(MusicBrainzReleaseDto dto) {
    final primaryMedia = dto.media?.firstOrNull;
    return MetadataCandidate(
      sourceApi: 'musicbrainz',
      sourceId: dto.id ?? '',
      title: dto.title ?? '',
      subtitle: dto.effectiveArtist,
      coverUrl: dto.coverUrl,
      year: dto.effectiveYear,
      format: dto.effectiveFormat,
      mediaType: MediaType.music,
      country: dto.country,
      label: dto.effectiveLabel,
      catalogueNumber: dto.labelInfo?.firstOrNull?.catalogNumber,
      trackCount: primaryMedia?.trackCount ?? dto.trackCount,
      status: dto.status,
      packaging: dto.packaging,
    );
  }
}
```

- [ ] **Step 2.4: Run tests to verify pass**

Run: `flutter test test/unit/data/mappers/musicbrainz_mapper_test.dart`
Expected: All tests pass.

- [ ] **Step 2.5: Commit**

```bash
git add lib/data/mappers/musicbrainz_mapper.dart test/unit/data/mappers/musicbrainz_mapper_test.dart
git commit -m "feat: map artist MBIDs and extended MusicBrainz release fields"
```

---

## Task 3: Show richer information on disambiguation candidate cards

Candidates now carry the extra fields — render them so users can tell regional/packaging variants apart (PRD 13.2).

**Files:**
- Modify: `lib/presentation/screens/disambiguation/widgets/candidate_card.dart`

- [ ] **Step 3.1: Update the card layout**

In `candidate_card.dart`, replace the `Row` that currently renders year/format chip with a layout that also surfaces country, label, catalogue number, and track count when present. Replace the existing `const SizedBox(height: 6), Row(...)` block (lines around 72–111) with:

```dart
const SizedBox(height: 6),
Wrap(
  spacing: 8,
  runSpacing: 4,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    if (candidate.year != null)
      Text(
        '${candidate.year}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    if (candidate.format != null)
      Chip(
        label: Text(candidate.format!),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelStyle: theme.textTheme.labelSmall,
      ),
    if (candidate.country != null)
      Text(
        candidate.country!,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    if (candidate.trackCount != null)
      Text(
        '${candidate.trackCount} tracks',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    if (candidate.label != null)
      Text(
        candidate.label!,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    if (candidate.catalogueNumber != null)
      Text(
        '#${candidate.catalogueNumber}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
  ],
),
const SizedBox(height: 6),
Row(
  children: [
    if (candidate.status != null)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colors.secondaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          candidate.status!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSecondaryContainer,
          ),
        ),
      ),
    const Spacer(),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        candidate.sourceApi,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
),
```

Also extend the accessibility label at the bottom of the widget:

```dart
String get _accessibilityLabel {
  final parts = <String>[candidate.title];
  if (candidate.subtitle != null) parts.add(candidate.subtitle!);
  if (candidate.year != null) parts.add('${candidate.year}');
  if (candidate.format != null) parts.add(candidate.format!);
  if (candidate.country != null) parts.add(candidate.country!);
  if (candidate.label != null) parts.add(candidate.label!);
  if (candidate.catalogueNumber != null) {
    parts.add('catalogue ${candidate.catalogueNumber!}');
  }
  if (candidate.trackCount != null) {
    parts.add('${candidate.trackCount} tracks');
  }
  if (candidate.status != null) parts.add(candidate.status!);
  parts.add('from ${candidate.sourceApi}');
  return parts.join(', ');
}
```

- [ ] **Step 3.2: Verify analysis and tests**

Run: `flutter analyze lib`
Expected: `No issues found!`

Run: `flutter test test/widget/disambiguation/` (only if this directory exists; otherwise skip)
Expected: pass or N/A.

- [ ] **Step 3.3: Commit**

```bash
git add lib/presentation/screens/disambiguation/widgets/candidate_card.dart
git commit -m "feat: show country, label, catalogue number and track count on disambiguation cards"
```

---

## Task 4: Add 503 rate-limit back-off helper

PRD FR-30/FR-31 require detecting MusicBrainz 503 (the server's throttling signal) and backing off. Build a tiny helper so the same logic can wrap MusicBrainz and Cover Art Archive calls.

**Files:**
- Create: `lib/core/utils/rate_limit_aware_client.dart`
- Create: `test/unit/core/utils/rate_limit_aware_client_test.dart`

- [ ] **Step 4.1: Write the failing test first**

Create `test/unit/core/utils/rate_limit_aware_client_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';

void main() {
  group('RateLimitAwareClient', () {
    test('first call passes straight through the inner function', () async {
      final client = RateLimitAwareClient(
        minInterval: const Duration(milliseconds: 10),
      );
      var calls = 0;
      final result = await client.run(() async {
        calls += 1;
        return 'ok';
      });
      expect(result, 'ok');
      expect(calls, 1);
    });

    test('503 response flips rate-limited flag and surfaces typed error',
        () async {
      final client = RateLimitAwareClient(
        minInterval: const Duration(milliseconds: 1),
      );
      expect(client.isRateLimited, isFalse);

      Future<String> failing() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );
      }

      await expectLater(
        client.run<String>(failing),
        throwsA(isA<RateLimitExceededException>()),
      );
      expect(client.isRateLimited, isTrue);
    });

    test('clears rate-limited flag after back-off window', () async {
      final client = RateLimitAwareClient(
        minInterval: const Duration(milliseconds: 1),
        rateLimitCooldown: const Duration(milliseconds: 5),
      );

      Future<String> failing() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );
      }

      await expectLater(
        client.run<String>(failing),
        throwsA(isA<RateLimitExceededException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(client.isRateLimited, isFalse);
    });
  });
}
```

- [ ] **Step 4.2: Run the test to see it fail**

Run: `flutter test test/unit/core/utils/rate_limit_aware_client_test.dart`
Expected: FAIL with "URI doesn't exist" (no implementation yet).

- [ ] **Step 4.3: Implement the helper**

Create `lib/core/utils/rate_limit_aware_client.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:mymediascanner/core/utils/rate_limiter.dart';

/// Thrown when the upstream API explicitly signals throttling (HTTP 503).
///
/// Callers should treat this as "back off now, try later" rather than
/// a hard failure — it usually means the provider wants fewer requests
/// per unit time, not that the resource is missing.
class RateLimitExceededException implements Exception {
  const RateLimitExceededException(this.endpoint, {this.retryAfter});

  final String endpoint;
  final Duration? retryAfter;

  @override
  String toString() =>
      'RateLimitExceededException(endpoint: $endpoint, retryAfter: $retryAfter)';
}

/// Wraps a [RateLimiter] with awareness of provider-side 503 responses.
///
/// - Pre-throttles calls to honour the provider's documented rate.
/// - Detects HTTP 503 responses and flips [isRateLimited] for
///   [rateLimitCooldown]; callers can skip non-critical follow-up calls
///   while the flag is set.
class RateLimitAwareClient {
  RateLimitAwareClient({
    required Duration minInterval,
    Duration rateLimitCooldown = const Duration(seconds: 10),
  })  : _limiter = RateLimiter(minInterval: minInterval),
        _cooldown = rateLimitCooldown;

  final RateLimiter _limiter;
  final Duration _cooldown;
  DateTime? _rateLimitedUntil;

  bool get isRateLimited {
    final until = _rateLimitedUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _rateLimitedUntil = null;
      return false;
    }
    return true;
  }

  Future<T> run<T>(Future<T> Function() inner) async {
    await _limiter.throttle();
    try {
      return await inner();
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        _rateLimitedUntil = DateTime.now().add(_cooldown);
        final retryHeader = e.response?.headers.value('retry-after');
        final retryAfter = _parseRetryAfter(retryHeader);
        throw RateLimitExceededException(
          e.requestOptions.path,
          retryAfter: retryAfter,
        );
      }
      rethrow;
    }
  }

  Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final seconds = int.tryParse(header);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }
}
```

- [ ] **Step 4.4: Run the test to verify pass**

Run: `flutter test test/unit/core/utils/rate_limit_aware_client_test.dart`
Expected: All three tests pass.

- [ ] **Step 4.5: Commit**

```bash
git add lib/core/utils/rate_limit_aware_client.dart test/unit/core/utils/rate_limit_aware_client_test.dart
git commit -m "feat: add rate-limit-aware HTTP client helper with 503 back-off"
```

---

## Task 5: Wire the rate-limit-aware helper into `MusicBrainzApi`

**Files:**
- Modify: `lib/data/remote/api/musicbrainz/musicbrainz_api.dart`

- [ ] **Step 5.1: Replace the raw `RateLimiter` with the aware client**

Replace the whole file with:

```dart
import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';

/// MusicBrainz API client.
///
/// Uses manual Dio calls because the MusicBrainz API requires `?fmt=json`
/// on every request and uses hyphenated query syntax. Wraps each request
/// in a [RateLimitAwareClient] so we pre-throttle to 1 req/s and back off
/// when the server returns HTTP 503.
class MusicBrainzApi {
  MusicBrainzApi([Dio? dio, RateLimitAwareClient? client])
      : _dio = dio ??
            DioFactory.createWithUserAgent(
              baseUrl: ApiConstants.musicBrainzBaseUrl,
              userAgent: ApiConstants.musicBrainzUserAgent(),
            ),
        _client = client ??
            RateLimitAwareClient(
              minInterval: const Duration(milliseconds: 1100),
            );

  final Dio _dio;
  final RateLimitAwareClient _client;

  bool get isRateLimited => _client.isRateLimited;

  Future<MusicBrainzSearchResponseDto> searchByBarcode(String barcode) {
    return _client.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/release/',
        queryParameters: {
          'query': 'barcode:$barcode',
          'fmt': 'json',
          'limit': 5,
        },
      );
      if (response.data == null) {
        return const MusicBrainzSearchResponseDto(count: 0, releases: []);
      }
      return MusicBrainzSearchResponseDto.fromJson(response.data!);
    });
  }

  Future<MusicBrainzSearchResponseDto> searchByTitle(String title) {
    return _client.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/release/',
        queryParameters: {
          'query': 'release:$title',
          'fmt': 'json',
          'limit': 5,
        },
      );
      if (response.data == null) {
        return const MusicBrainzSearchResponseDto(count: 0, releases: []);
      }
      return MusicBrainzSearchResponseDto.fromJson(response.data!);
    });
  }

  Future<MusicBrainzReleaseDto?> getRelease(String mbid) {
    return _client.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/release/$mbid',
        queryParameters: {
          'inc': 'recordings+artists+labels+release-groups',
          'fmt': 'json',
        },
      );
      if (response.data == null) return null;
      return MusicBrainzReleaseDto.fromJson(response.data!);
    });
  }
}
```

Note: we reference `ApiConstants.musicBrainzUserAgent()` — **Task 6** converts that constant into a factory.

- [ ] **Step 5.2: Defer compile check**

We will compile at the end of Task 6 once the User-Agent factory lands. Don't commit yet.

---

## Task 6: Use the real app version in the MusicBrainz User-Agent

PRD FR-20 requires a meaningful User-Agent with app name, version and maintainer contact. Version is currently hardcoded to `1.0`.

**Files:**
- Modify: `lib/core/constants/api_constants.dart`
- Modify: `lib/presentation/providers/repository_providers.dart` (if needed — only if wiring requires passing the version)

- [ ] **Step 6.1: Replace the constant with a helper**

Edit `lib/core/constants/api_constants.dart`:

```dart
abstract final class ApiConstants {
  // TMDB
  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Discogs
  static const discogsBaseUrl = 'https://api.discogs.com';

  // Google Books
  static const googleBooksBaseUrl = 'https://www.googleapis.com/books/v1';

  // Open Library
  static const openLibraryBaseUrl = 'https://openlibrary.org';
  static const openLibraryCoverUrl = 'https://covers.openlibrary.org';

  // TVDB
  static const tvdbBaseUrl = 'https://api4.thetvdb.com/v4';

  // TheAudioDB
  static const theAudioDbBaseUrl = 'https://www.theaudiodb.com/api/v1/json';

  // fanart.tv
  static const fanartBaseUrl = 'https://webservice.fanart.tv/v3';

  // MusicBrainz + Cover Art Archive
  static const musicBrainzBaseUrl = 'https://musicbrainz.org/ws/2';
  static const coverArtArchiveBaseUrl = 'https://coverartarchive.org';

  /// App version used in outbound User-Agent strings. Updated by release
  /// tooling; defaults match `pubspec.yaml`.
  static const appVersion = '1.0.0';

  /// MusicBrainz requires identifying the client in a User-Agent string
  /// so the maintainer can be contacted about excessive traffic.
  static String musicBrainzUserAgent() =>
      'MyMediaScanner/$appVersion '
      '(https://github.com/bovinemagnet/MyMediaScanner)';

  // UPCitemdb
  static const upcItemDbBaseUrl = 'https://api.upcitemdb.com/prod/trial';

  // GnuDB — CDDB-compatible disc metadata lookup. The service is HTTP only.
  static const gnudbBaseUrl = 'http://gnudb.gnudb.org';
  static const gnudbCgiPath = '/~cddb/cddb.cgi';
  static const gnudbDefaultUser = 'mymediascanner';
  static const gnudbClientName = 'MyMediaScanner';
  static const gnudbClientVersion = '1.0';
  static const gnudbUserAgent =
      'MyMediaScanner/1.0 (https://github.com/bovinemagnet/MyMediaScanner)';

  // Cache
  static const cacheDurationDays = 7;
}
```

- [ ] **Step 6.2: Run analyzer and mapper tests**

Run: `flutter analyze lib`
Expected: `No issues found!`

Run: `flutter test test/unit/data/mappers/musicbrainz_mapper_test.dart test/unit/core/utils/rate_limit_aware_client_test.dart`
Expected: Pass.

- [ ] **Step 6.3: Commit Tasks 5 & 6 together**

```bash
git add lib/data/remote/api/musicbrainz/musicbrainz_api.dart lib/core/constants/api_constants.dart
git commit -m "feat: back off on MusicBrainz 503 and include app version in User-Agent"
```

---

## Task 7: Cover Art Archive client with release-group fallback

PRD FR-16/17/18 require a real Cover Art Archive lookup with release-group fallback when the release itself has no artwork. The DTO currently just hardcodes a `front-250` URL.

**Files:**
- Create: `lib/data/remote/api/musicbrainz/models/cover_art_archive_dto.dart`
- Create: `lib/data/remote/api/musicbrainz/cover_art_archive_api.dart`
- Create: `test/unit/data/remote/api/musicbrainz/cover_art_archive_api_test.dart`

- [ ] **Step 7.1: Write a failing API test**

Create `test/unit/data/remote/api/musicbrainz/cover_art_archive_api_test.dart`. Use mocktail on `Dio` (matches the pattern in `test/unit/data/remote/api/gnudb/gnudb_api_test.dart` — no new deps).

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _jsonResponse(
  String path,
  Map<String, dynamic> body,
) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      data: body,
      statusCode: 200,
    );

DioException _notFound(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  late _MockDio dio;
  late CoverArtArchiveApi api;

  setUp(() {
    dio = _MockDio();
    api = CoverArtArchiveApi(
      dio,
      RateLimitAwareClient(minInterval: const Duration(milliseconds: 1)),
    );
  });

  test('returns large thumbnail when the release has a front image',
      () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenAnswer((_) async => _jsonResponse('/release/rel-1', {
              'images': [
                {
                  'front': true,
                  'image': 'https://example.com/full.jpg',
                  'thumbnails': {
                    'large': 'https://example.com/large.jpg',
                  },
                }
              ],
            }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/large.jpg');
  });

  test('falls back to release group when release returns 404', () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenThrow(_notFound('/release/rel-1'));
    when(() => dio.get<Map<String, dynamic>>('/release-group/rg-1'))
        .thenAnswer(
            (_) async => _jsonResponse('/release-group/rg-1', {
                  'images': [
                    {
                      'front': true,
                      'image': 'https://example.com/rg-full.jpg',
                      'thumbnails': {
                        'large': 'https://example.com/rg-large.jpg',
                      },
                    }
                  ],
                }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/rg-large.jpg');
  });

  test('returns null when both release and release group return 404',
      () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenThrow(_notFound('/release/rel-1'));
    when(() => dio.get<Map<String, dynamic>>('/release-group/rg-1'))
        .thenThrow(_notFound('/release-group/rg-1'));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, isNull);
  });
}
```

- [ ] **Step 7.2: Run test to verify failure**

Run: `flutter test test/unit/data/remote/api/musicbrainz/cover_art_archive_api_test.dart`
Expected: FAIL with "URI doesn't exist".

- [ ] **Step 7.3: Implement the DTO**

Create `lib/data/remote/api/musicbrainz/models/cover_art_archive_dto.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'cover_art_archive_dto.g.dart';

@JsonSerializable()
class CoverArtArchiveResponseDto {
  const CoverArtArchiveResponseDto({this.images});

  factory CoverArtArchiveResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CoverArtArchiveResponseDtoFromJson(json);

  final List<CoverArtArchiveImageDto>? images;

  Map<String, dynamic> toJson() => _$CoverArtArchiveResponseDtoToJson(this);
}

@JsonSerializable()
class CoverArtArchiveImageDto {
  const CoverArtArchiveImageDto({
    this.front,
    this.image,
    this.thumbnails,
    this.types,
  });

  factory CoverArtArchiveImageDto.fromJson(Map<String, dynamic> json) =>
      _$CoverArtArchiveImageDtoFromJson(json);

  final bool? front;
  final String? image;
  final CoverArtArchiveThumbnailsDto? thumbnails;
  final List<String>? types;

  Map<String, dynamic> toJson() => _$CoverArtArchiveImageDtoToJson(this);
}

@JsonSerializable()
class CoverArtArchiveThumbnailsDto {
  const CoverArtArchiveThumbnailsDto({this.small, this.large, this.size250});

  factory CoverArtArchiveThumbnailsDto.fromJson(Map<String, dynamic> json) =>
      _$CoverArtArchiveThumbnailsDtoFromJson(json);

  final String? small;
  final String? large;
  @JsonKey(name: '250')
  final String? size250;

  Map<String, dynamic> toJson() => _$CoverArtArchiveThumbnailsDtoToJson(this);
}
```

- [ ] **Step 7.4: Implement the API client**

Create `lib/data/remote/api/musicbrainz/cover_art_archive_api.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/cover_art_archive_dto.dart';

/// Queries the Cover Art Archive (coverartarchive.org) for front artwork.
///
/// The archive is a CC0 image host maintained by the MetaBrainz
/// Foundation. It is keyed on MusicBrainz release and release-group MBIDs.
class CoverArtArchiveApi {
  CoverArtArchiveApi([Dio? dio, RateLimitAwareClient? client])
      : _dio = dio ??
            DioFactory.createWithUserAgent(
              baseUrl: ApiConstants.coverArtArchiveBaseUrl,
              userAgent: ApiConstants.musicBrainzUserAgent(),
            ),
        _client = client ??
            RateLimitAwareClient(
              minInterval: const Duration(milliseconds: 500),
            );

  final Dio _dio;
  final RateLimitAwareClient _client;

  /// Returns the best available front-cover URL for the release, falling
  /// back to the release group when the release has no artwork.
  Future<String?> findFrontArtwork({
    required String releaseId,
    String? releaseGroupId,
  }) async {
    final releaseUrl = await _fetchFront('/release/$releaseId');
    if (releaseUrl != null) return releaseUrl;
    if (releaseGroupId == null) return null;
    return _fetchFront('/release-group/$releaseGroupId');
  }

  Future<String?> _fetchFront(String path) async {
    try {
      return await _client.run(() async {
        final response = await _dio.get<Map<String, dynamic>>(path);
        if (response.data == null) return null;
        final dto = CoverArtArchiveResponseDto.fromJson(response.data!);
        for (final image in dto.images ?? const <CoverArtArchiveImageDto>[]) {
          if (image.front == true) {
            return image.thumbnails?.large ??
                image.thumbnails?.size250 ??
                image.image;
          }
        }
        return null;
      });
    } on DioException catch (e) {
      // 404 is the normal "no artwork" response — not an error.
      if (e.response?.statusCode == 404) return null;
      debugPrint('Cover Art Archive fetch failed for $path: $e');
      return null;
    } catch (e) {
      debugPrint('Cover Art Archive fetch failed for $path: $e');
      return null;
    }
  }
}
```

- [ ] **Step 7.5: Generate DTO JSON code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `cover_art_archive_dto.g.dart` generated.

- [ ] **Step 7.6: Run API tests to verify pass**

Run: `flutter test test/unit/data/remote/api/musicbrainz/cover_art_archive_api_test.dart`
Expected: All three tests pass.

- [ ] **Step 7.7: Commit**

```bash
git add lib/data/remote/api/musicbrainz/cover_art_archive_api.dart \
        lib/data/remote/api/musicbrainz/models/cover_art_archive_dto.dart \
        lib/data/remote/api/musicbrainz/models/cover_art_archive_dto.g.dart \
        test/unit/data/remote/api/musicbrainz/cover_art_archive_api_test.dart
git commit -m "feat: add Cover Art Archive client with release-group fallback"
```

---

## Task 8: Wire Cover Art Archive + candidate ranking into the repository

Satisfies PRD FR-16/17/18 (actual artwork lookup), Section 15 (ranking/auto-accept rules), and FR-29 (source provenance).

**Files:**
- Modify: `lib/data/repositories/metadata_repository_impl.dart`
- Modify: `lib/presentation/providers/repository_providers.dart`

- [ ] **Step 8.1: Inject `CoverArtArchiveApi` into the repository**

Edit `lib/data/repositories/metadata_repository_impl.dart`:

Add imports near the other MusicBrainz imports:

```dart
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';
```

Extend the constructor and field list:

```dart
class MetadataRepositoryImpl implements IMetadataRepository {
  MetadataRepositoryImpl({
    required BarcodeCacheDao cacheDao,
    this.tmdbApi,
    this.discogsApi,
    this.musicBrainzApi,
    this.coverArtArchiveApi,
    this.tvdbApi,
    this.googleBooksApi,
    this.openLibraryApi,
    this.upcitemdbApi,
    this.theAudioDbApi,
    this.fanartApi,
    ApiCircuitBreaker? googleBooksBreaker,
  })  : _cacheDao = cacheDao,
        googleBooksBreaker = googleBooksBreaker ?? ApiCircuitBreaker();

  final BarcodeCacheDao _cacheDao;
  final TmdbApi? tmdbApi;
  final DiscogsApi? discogsApi;
  final MusicBrainzApi? musicBrainzApi;
  final CoverArtArchiveApi? coverArtArchiveApi;
  final TvdbApi? tvdbApi;
  // ... rest unchanged
```

- [ ] **Step 8.2: Add ranking + auto-accept to `_lookupMusicBrainz`**

Replace the existing `_lookupMusicBrainz` method with:

```dart
Future<ScanResult?> _lookupMusicBrainz(
    String barcode, String barcodeType) async {
  if (musicBrainzApi == null) return null;
  try {
    final response = await musicBrainzApi!.searchByBarcode(barcode);
    final releases = response.releases;
    if (releases == null || releases.isEmpty) return null;

    final ranked = _rankMusicBrainzReleases(releases);
    if (ranked.isEmpty) return null;

    final best = ranked.first;
    final runnerUp = ranked.length > 1 ? ranked[1] : null;
    final autoAccept = ranked.length == 1 ||
        _shouldAutoAccept(best: best, runnerUp: runnerUp!);

    if (autoAccept) {
      final detail = await musicBrainzApi!.getRelease(best.id ?? '') ?? best;
      final result = await _buildMusicBrainzResult(
        detail,
        barcode,
        barcodeType,
      );
      await _cacheResponse(
          barcode, 'music', 'musicbrainz', detail.toJson());
      return ScanResult.single(metadata: result, isDuplicate: false);
    }

    final candidates = ranked
        .take(AppConstants.maxCandidates)
        .map(MusicBrainzMapper.toCandidate)
        .toList();
    return ScanResult.multiMatch(
      candidates: candidates,
      barcode: barcode,
      barcodeType: barcodeType,
    );
  } on RateLimitExceededException catch (e) {
    debugPrint('MusicBrainz rate-limited: $e — falling back to Discogs');
  } on Exception catch (e) {
    debugPrint('Music lookup (MusicBrainz) failed: $e');
  }
  return null;
}

/// Orders MusicBrainz release candidates by descending completeness score.
///
/// See PRD §15 for the rules; the ranking prefers Official releases on
/// common physical formats with label/catalog data and non-zero track
/// counts.
List<MusicBrainzReleaseDto> _rankMusicBrainzReleases(
    List<MusicBrainzReleaseDto> releases) {
  int scoreOf(MusicBrainzReleaseDto r) {
    var score = 0;
    if ((r.status ?? '').toLowerCase() == 'official') score += 40;
    final format = (r.effectiveFormat ?? '').toLowerCase();
    if (format.contains('cd') ||
        format.contains('vinyl') ||
        format.contains('cassette')) {
      score += 20;
    }
    if (r.labelInfo?.firstOrNull?.catalogNumber != null) score += 10;
    if (r.labelInfo?.firstOrNull?.label?.name != null) score += 10;
    final tc = r.media?.firstOrNull?.trackCount ?? r.trackCount ?? 0;
    if (tc > 0) score += 10;
    if ((r.date ?? '').isNotEmpty) score += 5;
    if ((r.country ?? '').isNotEmpty) score += 5;
    return score + (r.score ?? 0);
  }

  final scored = releases
      .map((r) => (release: r, score: scoreOf(r)))
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return scored.map((e) => e.release).toList();
}

bool _shouldAutoAccept({
  required MusicBrainzReleaseDto best,
  required MusicBrainzReleaseDto runnerUp,
}) {
  final bestOfficial = (best.status ?? '').toLowerCase() == 'official';
  final runnerOfficial =
      (runnerUp.status ?? '').toLowerCase() == 'official';
  if (bestOfficial && !runnerOfficial) return true;
  final bestScore = best.score ?? 0;
  final runnerScore = runnerUp.score ?? 0;
  // Accept only when MusicBrainz itself says the top is clearly better.
  return bestScore >= 95 && bestScore - runnerScore >= 20;
}

Future<MetadataResult> _buildMusicBrainzResult(
  MusicBrainzReleaseDto release,
  String barcode,
  String barcodeType,
) async {
  final mapped =
      MusicBrainzMapper.fromRelease(release, barcode, barcodeType);
  final artUrl = await _resolveCoverArt(release);
  return artUrl == null ? mapped : mapped.copyWith(coverUrl: artUrl);
}

Future<String?> _resolveCoverArt(MusicBrainzReleaseDto release) async {
  final api = coverArtArchiveApi;
  if (api == null || release.id == null) return release.coverUrl;
  final archiveUrl = await api.findFrontArtwork(
    releaseId: release.id!,
    releaseGroupId: release.releaseGroupId,
  );
  return archiveUrl ?? release.coverUrl;
}
```

Also add the missing import at the top:

```dart
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
```

- [ ] **Step 8.3: Use the art resolver in `_fetchMusicBrainzDetail` too**

Replace the existing `_fetchMusicBrainzDetail` method body with:

```dart
Future<MetadataResult?> _fetchMusicBrainzDetail(
  MetadataCandidate candidate,
  String barcode,
  String barcodeType,
) async {
  if (musicBrainzApi == null) return null;
  try {
    final release = await musicBrainzApi!.getRelease(candidate.sourceId);
    if (release != null) {
      await _cacheResponse(
          barcode, 'music', 'musicbrainz', release.toJson());
      return _buildMusicBrainzResult(release, barcode, barcodeType);
    }
  } on RateLimitExceededException catch (e) {
    debugPrint('MusicBrainz rate-limited during detail fetch: $e');
  } on Exception catch (e) {
    debugPrint('MusicBrainz detail fetch failed: $e');
  }
  return null;
}
```

- [ ] **Step 8.4: Provide `CoverArtArchiveApi` in the Riverpod graph**

Edit `lib/presentation/providers/repository_providers.dart`:

Add an import:

```dart
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';
```

Extend the `MetadataRepositoryImpl` construction:

```dart
return MetadataRepositoryImpl(
  cacheDao: ref.watch(barcodeCacheDaoProvider),
  // ... existing providers unchanged ...
  musicBrainzApi: MusicBrainzApi(),
  coverArtArchiveApi: CoverArtArchiveApi(),
  // ... rest unchanged ...
);
```

- [ ] **Step 8.5: Run analyzer**

Run: `flutter analyze lib`
Expected: `No issues found!`

- [ ] **Step 8.6: Commit**

```bash
git add lib/data/repositories/metadata_repository_impl.dart lib/presentation/providers/repository_providers.dart
git commit -m "feat: rank MusicBrainz candidates and resolve Cover Art Archive artwork"
```

---

## Task 9: Source badge on the review screen

PRD §13.3 requires a source badge (e.g. `MusicBrainz`, `MusicBrainz + Discogs`) on the review screen. Drive it from `MetadataResult.sourceApis`.

**Files:**
- Modify: `lib/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart`

- [ ] **Step 9.1: Render the badge above the metadata section**

In `editable_metadata_form.dart`, between the `// Cover art preview` block and `// Media type selector` block, insert:

```dart
if (widget.initial.sourceApis.isNotEmpty) ...[
  Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Source: ${_formatSourceLabel(widget.initial.sourceApis)}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
  const SizedBox(height: 12),
],
```

Add this private method to the state class:

```dart
String _formatSourceLabel(List<String> apis) {
  const prettyNames = {
    'musicbrainz': 'MusicBrainz',
    'discogs': 'Discogs',
    'tmdb': 'TMDB',
    'tvdb': 'TVDB',
    'google_books': 'Google Books',
    'open_library': 'Open Library',
    'upcitemdb': 'UPCitemdb',
    'theaudiodb': 'TheAudioDB',
    'fanart': 'fanart.tv',
  };
  return apis
      .map((a) => prettyNames[a] ?? a)
      .join(' + ');
}
```

- [ ] **Step 9.2: Verify analysis**

Run: `flutter analyze lib`
Expected: `No issues found!`

- [ ] **Step 9.3: Commit**

```bash
git add lib/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart
git commit -m "feat: show metadata source badge on the review screen"
```

---

## Task 10: Tighten settings help text

PRD FR-21 wants explicit wording that MusicBrainz is built in and is the default music source.

**Files:**
- Modify: `lib/presentation/screens/settings/widgets/api_key_form.dart`

- [ ] **Step 10.1: Update the help text**

Replace the two `Text` blocks at the top of the form (the "Enter your own…" description and the "MusicBrainz…" note) with:

```dart
const Text(
  'Enter your own API keys. They are stored securely on-device.',
),
const SizedBox(height: 4),
Text(
  'Music scans use MusicBrainz by default — it is built in and '
  'needs no key. Open Library and TheAudioDB also need no keys. '
  'Discogs stays available as a fallback if you add a token below.',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.outline,
      ),
),
```

- [ ] **Step 10.2: Verify analysis**

Run: `flutter analyze lib`
Expected: `No issues found!`

- [ ] **Step 10.3: Commit**

```bash
git add lib/presentation/screens/settings/widgets/api_key_form.dart
git commit -m "docs: clarify MusicBrainz is default for music scans in settings"
```

---

## Task 11: Repository integration tests for the MusicBrainz path

PRD §20 requires tests for MusicBrainz happy path, multi-candidate disambiguation, no-result Discogs fallback, and rate-limit handling. Existing `metadata_repository_impl_test.dart` covers Discogs only.

**Files:**
- Create: `test/unit/data/repositories/metadata_repository_musicbrainz_test.dart`

- [ ] **Step 11.1: Write the failing tests**

Create the test file. Use the existing Discogs test as a template — same mocktail fallbacks, same setup pattern.

```dart
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/musicbrainz_api.dart';
import 'package:mymediascanner/data/repositories/metadata_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

class _MockBarcodeCacheDao extends Mock implements BarcodeCacheDao {}
class _MockMusicBrainzApi extends Mock implements MusicBrainzApi {}
class _MockDiscogsApi extends Mock implements DiscogsApi {}
class _MockCoverArtArchiveApi extends Mock implements CoverArtArchiveApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(BarcodeCacheTableCompanion(
      barcode: const Value(''),
      mediaTypeHint: const Value(null),
      responseJson: const Value('{}'),
      sourceApi: const Value(''),
      cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  });

  late _MockBarcodeCacheDao cacheDao;
  late _MockMusicBrainzApi mbApi;
  late _MockDiscogsApi discogsApi;
  late _MockCoverArtArchiveApi coverArtApi;
  late MetadataRepositoryImpl repo;

  const barcode = '5099902894225';

  setUp(() {
    cacheDao = _MockBarcodeCacheDao();
    mbApi = _MockMusicBrainzApi();
    discogsApi = _MockDiscogsApi();
    coverArtApi = _MockCoverArtArchiveApi();

    when(() => cacheDao.getByBarcode(any()))
        .thenAnswer((_) async => null);
    when(() => cacheDao.upsert(any())).thenAnswer((_) async => 0);

    repo = MetadataRepositoryImpl(
      cacheDao: cacheDao,
      musicBrainzApi: mbApi,
      discogsApi: discogsApi,
      coverArtArchiveApi: coverArtApi,
    );
  });

  test('auto-accepts a single Official MusicBrainz match', () async {
    const release = MusicBrainzReleaseDto(
      id: 'rel-1',
      title: 'Live Album',
      status: 'Official',
      date: '2001-01-01',
      country: 'GB',
      media: [MusicBrainzMediaDto(format: 'CD', trackCount: 12)],
    );
    when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const MusicBrainzSearchResponseDto(
        count: 1,
        releases: [release],
      ),
    );
    when(() => mbApi.getRelease('rel-1')).thenAnswer((_) async => release);
    when(() => coverArtApi.findFrontArtwork(
          releaseId: any(named: 'releaseId'),
          releaseGroupId: any(named: 'releaseGroupId'),
        )).thenAnswer((_) async => 'https://example.com/front.jpg');

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<SingleScanResult>());
    final single = result as SingleScanResult;
    expect(single.metadata.title, 'Live Album');
    expect(single.metadata.sourceApis, contains('musicbrainz'));
    expect(single.metadata.coverUrl, 'https://example.com/front.jpg');
  });

  test('presents disambiguation when multiple releases match', () async {
    when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const MusicBrainzSearchResponseDto(
        count: 2,
        releases: [
          MusicBrainzReleaseDto(
              id: 'rel-a', title: 'A', status: 'Official', country: 'GB'),
          MusicBrainzReleaseDto(
              id: 'rel-b', title: 'B', status: 'Official', country: 'US'),
        ],
      ),
    );

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<MultiMatchScanResult>());
    final multi = result as MultiMatchScanResult;
    expect(multi.candidates.length, 2);
    expect(multi.candidates.map((c) => c.country), containsAll(['GB', 'US']));
  });

  test('falls back to Discogs when MusicBrainz returns no results',
      () async {
    when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
      (_) async =>
          const MusicBrainzSearchResponseDto(count: 0, releases: []),
    );
    when(() => discogsApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const DiscogsSearchResponseDto(
        results: [DiscogsSearchResultDto(id: 42, title: 'Discogs Album')],
      ),
    );
    when(() => discogsApi.getRelease(42)).thenAnswer(
      (_) async => const DiscogsReleaseDto(id: 42, title: 'Discogs Album'),
    );

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<SingleScanResult>());
    expect((result as SingleScanResult).metadata.sourceApis,
        contains('discogs'));
  });

  test('falls back to Discogs when MusicBrainz reports rate-limit',
      () async {
    when(() => mbApi.searchByBarcode(barcode)).thenThrow(
      const RateLimitExceededException('/release/'),
    );
    when(() => discogsApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const DiscogsSearchResponseDto(
        results: [DiscogsSearchResultDto(id: 1, title: 'Fallback')],
      ),
    );
    when(() => discogsApi.getRelease(1)).thenAnswer(
      (_) async => const DiscogsReleaseDto(id: 1, title: 'Fallback'),
    );

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<SingleScanResult>());
    expect((result as SingleScanResult).metadata.title, 'Fallback');
  });
}
```

- [ ] **Step 11.2: Run the tests**

Run: `flutter test test/unit/data/repositories/metadata_repository_musicbrainz_test.dart`
Expected: All tests pass.

- [ ] **Step 11.3: Commit**

```bash
git add test/unit/data/repositories/metadata_repository_musicbrainz_test.dart
git commit -m "test: cover MusicBrainz happy path, disambiguation, and Discogs fallback"
```

---

## Final Verification

- [ ] **Step F.1: Regenerate everything**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: No errors.

- [ ] **Step F.2: Static analysis**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step F.3: Full test suite**

Run: `flutter test`
Expected: All tests pass, no regressions (acceptance criteria §19.8).

- [ ] **Step F.4: Summarise the change set**

Report:
- Artist MBIDs + extended MusicBrainz fields persisted.
- Candidate cards carry country/label/catalog/track count/status.
- 503 back-off in place via `RateLimitAwareClient`.
- Cover Art Archive client with release-group fallback wired into the repo.
- Ranking + auto-accept rules for MusicBrainz candidates.
- Dynamic User-Agent with app version.
- Source badge on the review screen.
- Settings help text clarified.
- New repo tests for the MusicBrainz path.
