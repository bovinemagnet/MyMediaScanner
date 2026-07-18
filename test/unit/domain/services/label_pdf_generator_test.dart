import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/label_sheet_preset.dart';
import 'package:mymediascanner/domain/entities/label_target.dart';
import 'package:mymediascanner/domain/services/label_pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const generator = LabelPdfGenerator();

  test('a4_24 preset reports 24 labels per page', () {
    expect(LabelSheetPresets.a4_24.labelsPerPage, 24);
  });

  test('a4_24 cell width splits the usable area equally across columns', () {
    const preset = LabelSheetPresets.a4_24;
    final total = preset.labelWidthPt * preset.columns +
        preset.gutterXPt * (preset.columns - 1) +
        preset.marginLeftPt * 2;
    // Should recover the page width within rounding.
    expect(total, closeTo(preset.pageWidthPt, 0.01));
  });

  test('letter_30 cell height splits usable area across rows', () {
    const preset = LabelSheetPresets.letter_30;
    final total = preset.labelHeightPt * preset.rows +
        preset.gutterYPt * (preset.rows - 1) +
        preset.marginTopPt * 2;
    expect(total, closeTo(preset.pageHeightPt, 0.01));
  });

  test('labelPayload helpers produce canonical prefixes', () {
    expect(LabelTarget.itemPayload('abc'), 'item:abc');
    expect(LabelTarget.locationPayload('xyz'), 'location:xyz');
  });

  test('empty target list still produces a valid single-page PDF',
      () async {
    final bytes = await generator.generate(
      targets: const [],
      preset: LabelSheetPresets.a4_8,
    );
    expect(bytes.length, greaterThan(100));
    // PDFs start with "%PDF-".
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
  });

  test('single page PDF is generated when targets fit on one page',
      () async {
    final targets = [
      for (var i = 0; i < 5; i++)
        LabelTarget(
          qrPayload: 'item:$i',
          title: 'Item $i',
          subtitle: 'Shelf A',
        ),
    ];
    final bytes = await generator.generate(
      targets: targets,
      preset: LabelSheetPresets.a4_8,
    );
    expect(bytes.length, greaterThan(500));
  });

  test('multi-page PDF is generated when targets exceed labelsPerPage',
      () async {
    const preset = LabelSheetPresets.a4_8; // 8 labels/page
    final targets = [
      for (var i = 0; i < 20; i++)
        LabelTarget(qrPayload: 'item:$i', title: 'Item $i'),
    ];
    final bytes = await generator.generate(
      targets: targets,
      preset: preset,
    );
    // Heuristic: 3-page PDF is materially larger than a 1-page PDF.
    final onePage = await generator.generate(
      targets: targets.sublist(0, 1),
      preset: preset,
    );
    expect(bytes.length, greaterThan(onePage.length));
  });

  test(
      'renders accented Latin and non-Latin Unicode label text without '
      'Helvetica Unicode warnings', () async {
    final targets = [
      const LabelTarget(
        qrPayload: 'item:cafe',
        title: 'Café Tacvba',
        subtitle: 'Русская полка',
      ),
      const LabelTarget(
        qrPayload: 'item:jp',
        title: 'こんにちは世界',
        subtitle: '日本語のサブタイトル',
      ),
    ];

    final prints = <String>[];
    late Uint8List bytes;
    await runZoned(
      () async {
        bytes = await generator.generate(
          targets: targets,
          preset: LabelSheetPresets.a4_8,
        );
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => prints.add(line),
      ),
    );

    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    expect(
      prints.where((line) => line.contains('has no Unicode support')),
      isEmpty,
      reason: 'Helvetica fallback fonts should not be instantiated once '
          'Unicode-capable fonts are embedded',
    );
  });
}
