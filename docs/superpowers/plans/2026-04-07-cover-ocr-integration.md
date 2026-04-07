# Cover OCR Integration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Author:** Paul Snow
**Date:** 2026-04-07
**Version:** 0.0.0

**Goal:** Enhance the existing cover OCR capability so that recognised text is used to improve metadata searches — extracting title/artist text from cover images, using OCR text as supplementary search terms when barcode lookup fails or returns poor results, pre-filling manual entry fields from recognised text, and providing confidence scoring for OCR-derived metadata.

**Architecture:** The current OCR implementation (`CoverOcrHelper`) extracts a single string (the largest text block) from a cover image and passes it directly to `searchByTitle`. This plan enhances OCR to return structured, multi-block results with confidence scores, introduces an `OcrResult` domain entity, adds an `OcrMetadataUseCase` to orchestrate intelligent text extraction and search, and wires OCR-derived text into the metadata confirm screen for pre-filling editable fields.

**Tech Stack:** Flutter, Freezed, Riverpod 3.x (hand-written Notifier), ML Kit text recognition, macOS Vision framework (method channel), Dio/Retrofit API clients

**Current State:** OCR is already functional on Android/iOS (ML Kit) and macOS (Vision framework via `com.mymediascanner/vision_ocr` method channel). The `CoverOcrHelper` class captures/picks an image, extracts the largest text block, cleans it, and returns a single string. The scanner provider has a `coverScan` state and `onCoverTextRecognised` method that feeds extracted text into `searchByTitle`. Desktop uses gallery picker; mobile uses camera capture.

---

## Chunk 1: Domain Layer — OcrResult Entity

### Task 1: Create OcrResult Entity

**Files:**
- Create: `lib/domain/entities/ocr_result.dart`
- Test: `test/unit/domain/ocr_result_test.dart`

The `OcrResult` entity holds structured OCR output: multiple text blocks with bounding-box area (as a proxy for prominence), individual confidence scores, and a derived overall confidence. This replaces the current approach of returning a single raw string.

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/domain/ocr_result_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';

void main() {
  group('OcrTextBlock', () {
    test('creates instance with required fields', () {
      const block = OcrTextBlock(
        text: 'Dark Side of the Moon',
        confidence: 0.95,
        area: 12000.0,
      );

      expect(block.text, 'Dark Side of the Moon');
      expect(block.confidence, 0.95);
      expect(block.area, 12000.0);
    });
  });

  group('OcrResult', () {
    test('creates instance with blocks', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'Dark Side of the Moon', confidence: 0.95, area: 12000.0),
          OcrTextBlock(text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
        ],
      );

      expect(result.blocks.length, 2);
    });

    test('primaryText returns largest block text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
          OcrTextBlock(text: 'Dark Side of the Moon', confidence: 0.95, area: 12000.0),
        ],
      );

      expect(result.primaryText, 'Dark Side of the Moon');
    });

    test('secondaryText returns second-largest block text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'Dark Side of the Moon', confidence: 0.95, area: 12000.0),
          OcrTextBlock(text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
          OcrTextBlock(text: '1973', confidence: 0.70, area: 2000.0),
        ],
      );

      expect(result.secondaryText, 'Pink Floyd');
    });

    test('overallConfidence averages block confidences', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'Title', confidence: 0.90, area: 10000.0),
          OcrTextBlock(text: 'Artist', confidence: 0.80, area: 5000.0),
        ],
      );

      expect(result.overallConfidence, closeTo(0.85, 0.001));
    });

    test('isEmpty returns true when no blocks', () {
      const result = OcrResult(blocks: []);
      expect(result.isEmpty, isTrue);
      expect(result.primaryText, isNull);
      expect(result.secondaryText, isNull);
      expect(result.overallConfidence, 0.0);
    });

    test('inferredTitle returns primary text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'The Matrix', confidence: 0.92, area: 15000.0),
          OcrTextBlock(text: 'Keanu Reeves', confidence: 0.85, area: 5000.0),
        ],
      );

      expect(result.inferredTitle, 'The Matrix');
    });

    test('inferredArtist returns secondary text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'The Matrix', confidence: 0.92, area: 15000.0),
          OcrTextBlock(text: 'Keanu Reeves', confidence: 0.85, area: 5000.0),
        ],
      );

      expect(result.inferredArtist, 'Keanu Reeves');
    });

    test('highConfidenceBlocks filters by threshold', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(text: 'Clear', confidence: 0.95, area: 10000.0),
          OcrTextBlock(text: 'Fuzzy', confidence: 0.40, area: 3000.0),
          OcrTextBlock(text: 'Decent', confidence: 0.75, area: 5000.0),
        ],
      );

      final high = result.highConfidenceBlocks(threshold: 0.70);
      expect(high.length, 2);
      expect(high.map((b) => b.text), containsAll(['Clear', 'Decent']));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/domain/ocr_result_test.dart`
Expected: FAIL — `ocr_result.dart` not found

- [ ] **Step 3: Create the OcrResult entity**

```dart
// lib/domain/entities/ocr_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_result.freezed.dart';

/// A single block of text recognised by OCR, with its confidence score
/// and bounding-box area (used as a prominence proxy).
@freezed
sealed class OcrTextBlock with _$OcrTextBlock {
  const OcrTextBlock._();

  const factory OcrTextBlock({
    required String text,
    required double confidence,
    required double area,
  }) = _OcrTextBlock;
}

/// Structured OCR output containing multiple recognised text blocks,
/// ordered by prominence (bounding-box area, descending).
@freezed
sealed class OcrResult with _$OcrResult {
  const OcrResult._();

  const factory OcrResult({
    @Default([]) List<OcrTextBlock> blocks,
  }) = _OcrResult;

  /// Blocks sorted by area descending (most prominent first).
  List<OcrTextBlock> get _sorted =>
      [...blocks]..sort((a, b) => b.area.compareTo(a.area));

  bool get isEmpty => blocks.isEmpty;

  /// The most prominent text block (largest bounding box), likely the title.
  String? get primaryText => _sorted.isEmpty ? null : _sorted.first.text;

  /// The second most prominent text block, likely the artist/author.
  String? get secondaryText => _sorted.length < 2 ? null : _sorted[1].text;

  /// Average confidence across all blocks. Returns 0.0 if empty.
  double get overallConfidence {
    if (blocks.isEmpty) return 0.0;
    return blocks.map((b) => b.confidence).reduce((a, b) => a + b) /
        blocks.length;
  }

  /// Alias for primaryText — the inferred title.
  String? get inferredTitle => primaryText;

  /// Alias for secondaryText — the inferred artist/author/subtitle.
  String? get inferredArtist => secondaryText;

  /// Returns only blocks with confidence at or above [threshold].
  List<OcrTextBlock> highConfidenceBlocks({double threshold = 0.70}) =>
      blocks.where((b) => b.confidence >= threshold).toList();
}
```

- [ ] **Step 4: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `ocr_result.freezed.dart`

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/unit/domain/ocr_result_test.dart`
Expected: PASS — all tests green

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities/ocr_result.dart lib/domain/entities/ocr_result.freezed.dart test/unit/domain/ocr_result_test.dart
git commit -m "feat: add OcrResult and OcrTextBlock Freezed entities"
```

---

## Chunk 2: Enhanced CoverOcrHelper — Structured Output

### Task 2: Refactor CoverOcrHelper to Return OcrResult

**Files:**
- Modify: `lib/core/utils/cover_ocr_helper.dart`
- Test: `test/unit/core/cover_ocr_helper_test.dart`

Refactor `CoverOcrHelper` to return `OcrResult` (with multiple blocks and confidence scores) instead of a plain `String?`. The existing `captureAndExtract`, `pickAndExtract`, and `extractFromFile` methods gain structured-result counterparts. The original string-returning methods are preserved for backward compatibility but marked `@Deprecated`.

- [ ] **Step 1: Write tests for structured OCR extraction**

```dart
// test/unit/core/cover_ocr_helper_test.dart
// Test that extractStructuredFromFile returns OcrResult with blocks.
// Test that cleanTitle static method still works.
// Test that empty recognition returns OcrResult(blocks: []).
// Mock TextRecognizer to return known RecognizedText with blocks.
```

Key test scenarios:
- ML Kit returns multiple blocks → `OcrResult` has multiple `OcrTextBlock` entries sorted by area
- ML Kit returns empty text → `OcrResult.isEmpty` is true
- `cleanTitle` still strips trademark symbols and collapses whitespace
- Vision framework path returns `OcrResult` with a single block (Vision returns a single string)

- [ ] **Step 2: Modify CoverOcrHelper**

Add new methods alongside existing ones:

```dart
/// Returns structured OCR output from a camera capture.
Future<OcrResult> captureAndExtractStructured() async { ... }

/// Returns structured OCR output from a gallery pick.
Future<OcrResult> pickAndExtractStructured() async { ... }

/// Returns structured OCR output from an image file.
Future<OcrResult> extractStructuredFromFile(String path) async { ... }
```

The ML Kit path extracts all text blocks (not just the largest), recording each block's text, confidence, and bounding-box area. The Vision path wraps the single returned string in a one-element `OcrResult` with confidence 1.0 (Vision doesn't provide per-block confidence).

- [ ] **Step 3: Run tests**

Run: `flutter test test/unit/core/cover_ocr_helper_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/core/utils/cover_ocr_helper.dart test/unit/core/cover_ocr_helper_test.dart
git commit -m "feat: add structured OCR extraction returning OcrResult"
```

---

### Task 3: Enhance Vision OCR Channel for Confidence Data

**Files:**
- Modify: `lib/core/utils/vision_ocr_channel.dart`
- Modify: `macos/Runner/VisionOcrPlugin.swift` (if it exists; otherwise note as platform-side work)

Currently the Vision method channel returns a single string. Enhance it to optionally return a structured map with text blocks and confidence values if the native side supports it.

- [ ] **Step 1: Add structured method to VisionOcrChannel**

```dart
/// Returns structured recognition results as a list of maps, each with
/// 'text', 'confidence', and 'area' keys. Falls back to wrapping the
/// plain text result if the native side doesn't support structured output.
static Future<List<Map<String, dynamic>>?> recogniseTextStructured(
    String imagePath) async { ... }
```

- [ ] **Step 2: Update CoverOcrHelper Vision path to use structured channel**

- [ ] **Step 3: Commit**

```bash
git add lib/core/utils/vision_ocr_channel.dart
git commit -m "feat: add structured text recognition to Vision OCR channel"
```

---

## Chunk 3: OCR Metadata Use Case

### Task 4: Create OcrMetadataUseCase

**Files:**
- Create: `lib/domain/usecases/ocr_metadata_usecase.dart`
- Test: `test/unit/domain/ocr_metadata_usecase_test.dart`

This use case orchestrates the OCR-to-metadata pipeline: takes an `OcrResult`, applies heuristics to extract title/artist, builds search queries, and returns `ScanResult`. It encapsulates the intelligence for interpreting OCR text.

- [ ] **Step 1: Write failing tests**

Key test scenarios:
- High-confidence single block → searches by that text as title
- Two prominent blocks → searches with primary as title and secondary as supplementary term
- Low overall confidence (< 0.5) → returns `NotFoundScanResult` with a hint to try manual entry
- Empty OCR result → returns `NotFoundScanResult`
- Year-like text (4-digit number 1900–2099) is extracted and used to filter/rank results
- Common noise words ("Blu-ray", "DVD", "Disc", "Digital") are stripped before searching

- [ ] **Step 2: Create the use case**

```dart
// lib/domain/usecases/ocr_metadata_usecase.dart
class OcrMetadataUseCase {
  const OcrMetadataUseCase({
    required IMetadataRepository metadataRepository,
  });

  /// Minimum overall confidence to attempt a metadata search.
  static const double minConfidenceThreshold = 0.50;

  /// Noise words commonly found on media covers but unhelpful for search.
  static const noiseWords = {
    'blu-ray', 'dvd', 'cd', 'disc', 'digital', 'remastered',
    'special edition', 'deluxe', 'limited edition', 'widescreen',
    'dolby', 'atmos', '4k', 'uhd', 'hdr',
  };

  Future<OcrSearchResult> execute(
    OcrResult ocrResult,
    String barcode,
    String barcodeType, {
    MediaType? typeHint,
  }) async { ... }

  /// Strips noise words and extracts year if present.
  @visibleForTesting
  static OcrTextAnalysis analyseText(OcrResult result) { ... }
}
```

Introduce a small helper class `OcrTextAnalysis` (or use a record) to hold the cleaned title, cleaned artist, extracted year, and confidence assessment.

- [ ] **Step 3: Run tests**

Run: `flutter test test/unit/domain/ocr_metadata_usecase_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/domain/usecases/ocr_metadata_usecase.dart test/unit/domain/ocr_metadata_usecase_test.dart
git commit -m "feat: add OcrMetadataUseCase for OCR-to-search orchestration"
```

---

### Task 5: Add OcrSearchResult Entity

**Files:**
- Create: `lib/domain/entities/ocr_search_result.dart`
- Test: (covered by OcrMetadataUseCase tests)

Wraps a `ScanResult` with additional OCR context: the original `OcrResult`, the cleaned search terms used, and the confidence assessment. This allows downstream UI to show the user what text was recognised and how confident the system is.

- [ ] **Step 1: Create the entity**

```dart
@freezed
sealed class OcrSearchResult with _$OcrSearchResult {
  const factory OcrSearchResult({
    required ScanResult scanResult,
    required OcrResult ocrResult,
    required String searchTermUsed,
    String? inferredArtist,
    int? inferredYear,
    required double confidence,
  }) = _OcrSearchResult;
}
```

- [ ] **Step 2: Run code generation and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/unit/domain/ocr_metadata_usecase_test.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/ocr_search_result.dart lib/domain/entities/ocr_search_result.freezed.dart
git commit -m "feat: add OcrSearchResult entity wrapping scan result with OCR context"
```

---

## Chunk 4: Scanner Provider Integration

### Task 6: Extend ScannerNotifier for Structured OCR

**Files:**
- Modify: `lib/presentation/providers/scanner_provider.dart`
- Modify: `test/unit/presentation/scanner_provider_test.dart` (if exists, otherwise create)

Add a new `onCoverOcrResult` method that accepts an `OcrResult` and delegates to `OcrMetadataUseCase`, replacing the existing `onCoverTextRecognised` flow. The existing `onCoverTextRecognised` is kept for backward compatibility but refactored to construct an `OcrResult` internally.

- [ ] **Step 1: Add `ocrSearchResult` to ScannerState**

```dart
class ScannerState {
  // ... existing fields ...
  final OcrSearchResult? ocrSearchResult;
  // ...
}
```

This allows the metadata confirm screen to access OCR context (recognised text, confidence) for pre-filling fields and showing confidence indicators.

- [ ] **Step 2: Add `onCoverOcrResult` method to ScannerNotifier**

```dart
Future<void> onCoverOcrResult(
  OcrResult ocrResult,
  String barcode,
  String barcodeType,
) async {
  final useCase = OcrMetadataUseCase(
    metadataRepository: ref.read(metadataRepositoryProvider),
  );
  final ocrSearchResult = await useCase.execute(
    ocrResult, barcode, barcodeType,
    typeHint: state.typeHint,
  );
  // Route based on ocrSearchResult.scanResult (found/multiMatch/notFound)
  // Store ocrSearchResult in state for downstream access
}
```

- [ ] **Step 3: Write/update tests**

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/providers/scanner_provider.dart test/unit/presentation/scanner_provider_test.dart
git commit -m "feat: extend scanner provider with structured OCR search flow"
```

---

## Chunk 5: UI — OCR-Assisted Metadata Confirm Screen

### Task 7: Pre-fill Metadata Form from OCR Results

**Files:**
- Modify: `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart`
- Modify: `lib/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart`

When the user arrives at the metadata confirm screen after a cover OCR scan:
1. If `ocrSearchResult` is present on `ScannerState`, use its inferred title/artist to pre-fill the editable form fields (title, subtitle/artist).
2. Show an informational banner indicating the text was extracted via OCR, with the overall confidence percentage.
3. If the barcode lookup returned `notFound` but OCR returned text, pre-populate the `TitleSearchField` with the inferred title.

- [ ] **Step 1: Update MetadataConfirmScreen to read OCR context**

Read `scannerState.ocrSearchResult` and pass inferred values to `EditableMetadataForm` as initial values when the metadata fields are empty.

- [ ] **Step 2: Add OCR confidence banner widget**

Create a small inline widget showing "Text recognised from cover (85% confidence)" with an appropriate icon and tonal container styling, displayed above the form when OCR was used.

- [ ] **Step 3: Pre-populate TitleSearchField from OCR**

When `isNotFound` and `ocrSearchResult?.inferredTitle` is available, set the `TitleSearchField` controller's initial text to the inferred title so the user can immediately search or edit it.

- [ ] **Step 4: Write widget tests**

Test that the OCR banner appears when `ocrSearchResult` is present.
Test that form fields are pre-filled from OCR inferred values.
Test that `TitleSearchField` is pre-populated when available.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart lib/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart test/widget/
git commit -m "feat: pre-fill metadata form fields from OCR-recognised text"
```

---

### Task 8: OCR Confidence Indicator Widget

**Files:**
- Create: `lib/presentation/widgets/ocr_confidence_indicator.dart`
- Test: `test/widget/ocr_confidence_indicator_test.dart`

A reusable widget that displays an OCR confidence score with visual feedback:
- High confidence (≥ 0.80): green tonal container with tick icon
- Medium confidence (0.50–0.79): amber tonal container with info icon
- Low confidence (< 0.50): red tonal container with warning icon

Uses the design system's tonal containers and `surfaceContainerHigh` colour, consistent with the "no-line" rule.

- [ ] **Step 1: Write widget test**

- [ ] **Step 2: Create the widget**

- [ ] **Step 3: Integrate into metadata confirm screen (from Task 7)**

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/ocr_confidence_indicator.dart test/widget/ocr_confidence_indicator_test.dart
git commit -m "feat: add OCR confidence indicator widget"
```

---

## Chunk 6: Scanner Screen Wiring

### Task 9: Update Mobile Scan Screen for Structured OCR

**Files:**
- Modify: `lib/presentation/screens/scanner/mobile_scan_screen.dart`

Update `_scanCover` to use `CoverOcrHelper.captureAndExtractStructured()` and pass the `OcrResult` to `ScannerNotifier.onCoverOcrResult()` instead of the plain string path.

- [ ] **Step 1: Update _scanCover method**

```dart
Future<void> _scanCover(NotFoundScanResult? notFound) async {
  if (notFound == null) { _resumeScanning(); return; }
  final ocr = CoverOcrHelper();
  try {
    final ocrResult = await ocr.captureAndExtractStructured();
    if (!ocrResult.isEmpty && mounted) {
      await ref.read(scannerProvider.notifier).onCoverOcrResult(
        ocrResult, notFound.barcode, notFound.barcodeType,
      );
    } else if (mounted) {
      context.go('/scan/confirm');
    }
  } catch (_) {
    if (mounted) _resumeScanning();
  } finally {
    await ocr.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/scanner/mobile_scan_screen.dart
git commit -m "feat: wire mobile scanner to structured OCR flow"
```

---

### Task 10: Update Desktop Scan Screen for Structured OCR

**Files:**
- Modify: `lib/presentation/screens/scanner/desktop_scan_screen.dart`

Same change as Task 9 but using `pickAndExtractStructured()` (gallery picker for macOS).

- [ ] **Step 1: Update _scanCover method**

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/scanner/desktop_scan_screen.dart
git commit -m "feat: wire desktop scanner to structured OCR flow"
```

---

## Chunk 7: Supplementary OCR Search on Poor Barcode Results

### Task 11: Add OCR Fallback to ScanBarcodeUseCase

**Files:**
- Modify: `lib/domain/usecases/scan_barcode_usecase.dart`
- Test: `test/unit/domain/scan_barcode_usecase_test.dart`

Add an optional `ocrResult` parameter to `ScanBarcodeUseCase.execute()`. When a barcode lookup returns `NotFoundScanResult` and an `OcrResult` is available (from a prior cover scan), automatically attempt OCR-based search before giving up.

This enables a workflow where the user scans a barcode, it fails, they scan the cover, and the system uses both the barcode (for duplicate detection) and OCR text (for metadata search) together.

- [ ] **Step 1: Write failing test**

Test that when barcode lookup returns `notFound` and `ocrResult` is provided, the use case calls `searchByTitle` with the OCR-inferred title.

- [ ] **Step 2: Add optional ocrResult parameter**

```dart
Future<ScanResult> execute(
  String barcode, {
  MediaType? typeHint,
  bool forceIsbn = false,
  OcrResult? ocrResult, // NEW
}) async {
  // ... existing barcode lookup ...
  // If notFound and ocrResult available, try OCR-based search
  if (result is NotFoundScanResult && ocrResult != null && !ocrResult.isEmpty) {
    final ocrTitle = ocrResult.inferredTitle;
    if (ocrTitle != null) {
      return _metadataRepo.searchByTitle(
        ocrTitle, barcode, barcodeType, typeHint: typeHint,
      );
    }
  }
  return result;
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/unit/domain/scan_barcode_usecase_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/domain/usecases/scan_barcode_usecase.dart test/unit/domain/scan_barcode_usecase_test.dart
git commit -m "feat: add OCR fallback to barcode use case for failed lookups"
```

---

## Chunk 8: Text Analysis Heuristics

### Task 12: OCR Text Analysis Utilities

**Files:**
- Create: `lib/core/utils/ocr_text_analysis.dart`
- Test: `test/unit/core/ocr_text_analysis_test.dart`

Utility functions for interpreting OCR text from media covers:

1. **Year extraction:** Finds 4-digit numbers between 1900 and 2099 in text blocks
2. **Noise word removal:** Strips common media format words (Blu-ray, DVD, CD, etc.)
3. **Title/artist splitting:** Heuristic to separate title from artist when they appear in the same block (common patterns: "Artist - Title", "Title by Artist")
4. **Media type inference:** Guesses media type from OCR text clues (e.g., "Blu-ray" → film, "CD" → music, "ISBN" → book)

- [ ] **Step 1: Write tests for each utility function**

Key scenarios:
- "Dark Side of the Moon (Remastered 2011) CD" → title: "Dark Side of the Moon", year: 2011, inferred type: music
- "The Shawshank Redemption Blu-ray" → title: "The Shawshank Redemption", inferred type: film
- "Pink Floyd - The Wall" → title: "The Wall", artist: "Pink Floyd"
- "978-0-14-103614-4" → detected as ISBN, inferred type: book
- Empty/whitespace-only → returns null analysis

- [ ] **Step 2: Implement utility functions**

- [ ] **Step 3: Integrate into OcrMetadataUseCase (Task 4)**

Update `OcrMetadataUseCase.analyseText` to use these utilities.

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/ocr_text_analysis.dart test/unit/core/ocr_text_analysis_test.dart lib/domain/usecases/ocr_metadata_usecase.dart
git commit -m "feat: add OCR text analysis heuristics for title/artist/year extraction"
```

---

## Chunk 9: Full Verification

### Task 13: Integration Testing and Final Verification

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass (existing ~472 + new tests)

- [ ] **Step 2: Run code analysis**

Run: `flutter analyze`
Expected: No issues

- [ ] **Step 3: Run code generation to ensure consistency**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: No changes needed (all generated files up to date)

- [ ] **Step 4: Manual smoke test on available platform**

Verify:
- Barcode scan → not found → cover scan → OCR extracts text → metadata search → confirm screen shows results with OCR banner
- Metadata confirm form fields are pre-filled from OCR text
- Confidence indicator displays correct colour band
- Manual title search still works as before
- Batch mode with OCR is not broken

- [ ] **Step 5: Final commit (if any fixes were needed)**

```bash
git add -A
git commit -m "fix: resolve issues from cover OCR integration testing"
```

---

## Architecture Notes

### Data Flow

```
Cover Image
    │
    ▼
CoverOcrHelper.captureAndExtractStructured()
    │
    ▼
OcrResult (multiple OcrTextBlock with confidence + area)
    │
    ▼
ScannerNotifier.onCoverOcrResult()
    │
    ▼
OcrMetadataUseCase.execute()
    ├── OcrTextAnalysis: extract title, artist, year, media type
    ├── Strip noise words
    ├── Confidence check (skip if < 0.50)
    └── IMetadataRepository.searchByTitle()
            │
            ▼
        OcrSearchResult (ScanResult + OCR context)
            │
            ▼
        MetadataConfirmScreen
            ├── Pre-fill form from OCR inferred fields
            ├── Show confidence banner
            └── User edits and saves
```

### Backward Compatibility

- Existing `CoverOcrHelper` string-returning methods (`captureAndExtract`, `pickAndExtract`, `extractFromFile`) are preserved but marked `@Deprecated`
- Existing `ScannerNotifier.onCoverTextRecognised` is preserved, internally wrapping the string in an `OcrResult`
- Existing `TitleSearchField` API is unchanged; only its initial value is optionally pre-populated
- No database schema changes required
- No new API keys or external dependencies required

### Confidence Scoring Strategy

| Source | Confidence Source | Notes |
|--------|------------------|-------|
| ML Kit (Android/iOS) | Per-block confidence from `TextBlock.recognizedLanguages` and recognition confidence | Native confidence values |
| Vision (macOS) | Fixed 1.0 per block | Vision framework VNRecognizedTextObservation has confidence; requires native-side update to pass it through |
| Overall | Weighted average of block confidences | Blocks with larger area weighted more heavily |

### Known Constraints

- ML Kit `TextBlock.confidence` is not exposed in the `google_mlkit_text_recognition` Dart package as of v0.14.x; we may need to use the block's recognised languages as a proxy or inspect the raw platform channel data
- Vision framework confidence requires a native-side update to `VisionOcrPlugin.swift` to return structured data; Task 3 addresses this
- OCR text analysis heuristics are inherently imperfect — the confidence indicator sets user expectations appropriately

---

## Summary

| Task | Description | Files Changed |
|------|-------------|---------------|
| 1 | OcrResult + OcrTextBlock entities | 1 create, 1 test |
| 2 | CoverOcrHelper structured output | 1 modify, 1 test |
| 3 | Vision OCR channel structured data | 1 modify |
| 4 | OcrMetadataUseCase | 1 create, 1 test |
| 5 | OcrSearchResult entity | 1 create |
| 6 | ScannerNotifier OCR integration | 1 modify, 1 test |
| 7 | Metadata confirm pre-fill from OCR | 2 modify, widget tests |
| 8 | OCR confidence indicator widget | 1 create, 1 test |
| 9 | Mobile scan screen wiring | 1 modify |
| 10 | Desktop scan screen wiring | 1 modify |
| 11 | Barcode use case OCR fallback | 1 modify, 1 test |
| 12 | OCR text analysis utilities | 1 create, 1 test |
| 13 | Full verification | — |

