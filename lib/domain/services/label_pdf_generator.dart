import 'dart:typed_data';

import 'package:mymediascanner/domain/entities/label_sheet_preset.dart';
import 'package:mymediascanner/domain/entities/label_target.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Renders a list of [LabelTarget]s onto one or more pages using the
/// grid defined by a [LabelSheetPreset]. Each label carries a QR of the
/// target's [LabelTarget.qrPayload] and its human-readable title.
///
/// Pure: no I/O, no Flutter dependencies. Returns the rendered PDF as a
/// [Uint8List]; callers are responsible for previewing, saving, or
/// sharing the bytes.
class LabelPdfGenerator {
  const LabelPdfGenerator();

  /// Returns a PDF with [targets] laid out under [preset]. An empty
  /// [targets] still produces a valid single blank page.
  Future<Uint8List> generate({
    required List<LabelTarget> targets,
    required LabelSheetPreset preset,
  }) async {
    final doc = pw.Document();
    final perPage = preset.labelsPerPage;
    final pageSize = PdfPageFormat(preset.pageWidthPt, preset.pageHeightPt);

    // Pre-compute the grid cell geometry once.
    final cellW = preset.labelWidthPt;
    final cellH = preset.labelHeightPt;

    // Chunk targets into pages.
    final totalPages = targets.isEmpty
        ? 1
        : (targets.length + perPage - 1) ~/ perPage;

    for (var page = 0; page < totalPages; page++) {
      final start = page * perPage;
      final end = (start + perPage).clamp(0, targets.length);
      final pageTargets = targets.sublist(start, end);

      doc.addPage(pw.Page(
        pageFormat: pageSize,
        build: (context) => pw.Stack(
          children: [
            for (var i = 0; i < pageTargets.length; i++)
              _positionCell(
                preset: preset,
                index: i,
                cellW: cellW,
                cellH: cellH,
                child: _LabelCell(target: pageTargets[i]),
              ),
          ],
        ),
      ));
    }

    return doc.save();
  }

  pw.Widget _positionCell({
    required LabelSheetPreset preset,
    required int index,
    required double cellW,
    required double cellH,
    required pw.Widget child,
  }) {
    final col = index % preset.columns;
    final row = index ~/ preset.columns;
    final x = preset.marginLeftPt + col * (cellW + preset.gutterXPt);
    final y = preset.marginTopPt + row * (cellH + preset.gutterYPt);

    return pw.Positioned(
      left: x,
      top: y,
      child: pw.SizedBox(
        width: cellW,
        height: cellH,
        child: child,
      ),
    );
  }
}

class _LabelCell extends pw.StatelessWidget {
  _LabelCell({required this.target});

  final LabelTarget target;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.25, color: PdfColors.grey400),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 56,
            height: 56,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: target.qrPayload,
              drawText: false,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  target.title,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                ),
                if (target.subtitle != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    target.subtitle!,
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                    maxLines: 2,
                    overflow: pw.TextOverflow.clip,
                  ),
                ],
                pw.SizedBox(height: 3),
                pw.Text(
                  target.qrPayload,
                  style: const pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.grey500,
                  ),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
