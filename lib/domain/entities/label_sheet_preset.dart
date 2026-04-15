import 'package:freezed_annotation/freezed_annotation.dart';

part 'label_sheet_preset.freezed.dart';

/// Physical label sheet layout. All dimensions are in PostScript points
/// (1 pt = 1/72 inch). A4 = 595.28 x 841.89 pt; US Letter = 612 x 792 pt.
///
/// [columns] x [rows] gives the labels per page. Margins and gutter
/// determine how much of the sheet is usable.
@freezed
sealed class LabelSheetPreset with _$LabelSheetPreset {
  const factory LabelSheetPreset({
    required String id,
    required String name,
    required double pageWidthPt,
    required double pageHeightPt,
    required int columns,
    required int rows,
    required double marginLeftPt,
    required double marginTopPt,
    required double gutterXPt,
    required double gutterYPt,
  }) = _LabelSheetPreset;
}

/// Curated set of built-in presets. Custom presets can be added later.
abstract final class LabelSheetPresets {
  /// 3 x 8 = 24 labels on A4. Roughly matches Avery L7159 / L7160.
  static const a4_24 = LabelSheetPreset(
    id: 'a4-24',
    name: 'A4 — 24 labels (3x8)',
    pageWidthPt: 595.28,
    pageHeightPt: 841.89,
    columns: 3,
    rows: 8,
    marginLeftPt: 21.42,
    marginTopPt: 36.85,
    gutterXPt: 7.11,
    gutterYPt: 0,
  );

  /// 2 x 4 = 8 larger labels on A4, ideal for box/shelf labels.
  static const a4_8 = LabelSheetPreset(
    id: 'a4-8',
    name: 'A4 — 8 labels (2x4)',
    pageWidthPt: 595.28,
    pageHeightPt: 841.89,
    columns: 2,
    rows: 4,
    marginLeftPt: 28.35,
    marginTopPt: 42.52,
    gutterXPt: 14.17,
    gutterYPt: 14.17,
  );

  /// 3 x 10 = 30 labels on US Letter. Matches Avery 5160.
  static const letter_30 = LabelSheetPreset(
    id: 'letter-30',
    name: 'US Letter — 30 labels (3x10, Avery 5160)',
    pageWidthPt: 612,
    pageHeightPt: 792,
    columns: 3,
    rows: 10,
    marginLeftPt: 13.5,
    marginTopPt: 36,
    gutterXPt: 9,
    gutterYPt: 0,
  );

  static const builtIn = <LabelSheetPreset>[a4_24, a4_8, letter_30];
}

/// The effective size of a single label cell within the sheet.
extension LabelSheetPresetGeometry on LabelSheetPreset {
  double get labelWidthPt {
    final usable = pageWidthPt - 2 * marginLeftPt - gutterXPt * (columns - 1);
    return usable / columns;
  }

  double get labelHeightPt {
    final usable = pageHeightPt - 2 * marginTopPt - gutterYPt * (rows - 1);
    return usable / rows;
  }

  int get labelsPerPage => columns * rows;
}
