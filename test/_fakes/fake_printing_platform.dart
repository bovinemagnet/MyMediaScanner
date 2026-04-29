/// Test fake for the [PrintingPlatform] platform interface.
///
/// `Printing.layoutPdf` ultimately delegates to
/// `PrintingPlatform.instance.layoutPdf`, which on the default
/// `MethodChannelPrinting` implementation calls into a platform plugin.
/// Headless widget tests have no such plugin, so any code that reaches
/// `Printing.layoutPdf` blows up. Swapping the platform instance for this
/// fake captures the arguments and returns a successful future.
///
/// Typical usage:
/// ```dart
/// final fake = installFakePrintingPlatform();
/// await tester.tap(find.text('Preview / print'));
/// await tester.pumpAndSettle();
///
/// expect(fake.layoutPdfCalls, hasLength(1));
/// expect(fake.layoutPdfCalls.single.name, 'mymediascanner-labels');
/// expect(fake.layoutPdfCalls.single.bytes, isNotEmpty);
/// ```
///
/// Methods other than `layoutPdf` throw [UnimplementedError] — extend
/// this class in a test if you need them.
library;

import 'dart:typed_data';

import 'package:flutter/rendering.dart' show Rect;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
// PrintingPlatform is the package's plugin interface and is intentionally
// kept under src/ — but the only way to mock platform-channel printing
// from a test is to extend that class. Using the implementation import is
// deliberate.
// ignore: implementation_imports
import 'package:printing/src/interface.dart';

/// One captured invocation of [FakePrintingPlatform.layoutPdf].
class LayoutPdfCall {
  const LayoutPdfCall({
    required this.name,
    required this.bytes,
    required this.format,
  });

  /// The document name passed to `Printing.layoutPdf(name: ...)`.
  final String name;

  /// The PDF bytes produced by the screen's `onLayout` callback.
  final Uint8List bytes;

  /// The page format the layout callback was invoked with.
  final PdfPageFormat format;
}

/// In-memory [PrintingPlatform] used in widget tests. Captures every call
/// to [layoutPdf] (including the bytes returned from the supplied
/// `onLayout` callback) and reports success.
///
/// Unimplemented methods throw — fail-fast surfaces accidental use of
/// printer enumeration or PDF→bitmap rasterisation in a test that has not
/// stubbed those paths.
class FakePrintingPlatform extends PrintingPlatform {
  FakePrintingPlatform({this.layoutResult = true});

  /// The captured calls to [layoutPdf], in order.
  final List<LayoutPdfCall> layoutPdfCalls = [];

  /// Return value for [layoutPdf]. Defaults to `true` (printed).
  bool layoutResult;

  @override
  Future<bool> layoutPdf(
    Printer? printer,
    LayoutCallback onLayout,
    String name,
    PdfPageFormat format,
    bool dynamicLayout,
    bool usePrinterSettings,
    OutputType outputType,
    bool forceCustomPrintPaper,
  ) async {
    final bytes = await onLayout(format);
    layoutPdfCalls.add(LayoutPdfCall(
      name: name,
      bytes: bytes,
      format: format,
    ));
    return layoutResult;
  }

  @override
  Future<PrintingInfo> info() async => throw UnimplementedError(
      'FakePrintingPlatform.info is not stubbed.');

  @override
  Future<List<Printer>> listPrinters() async => throw UnimplementedError(
      'FakePrintingPlatform.listPrinters is not stubbed.');

  @override
  Future<Printer?> pickPrinter(Rect bounds) async => throw UnimplementedError(
      'FakePrintingPlatform.pickPrinter is not stubbed.');

  @override
  Future<bool> sharePdf(
    Uint8List bytes,
    String filename,
    Rect bounds,
    String? subject,
    String? body,
    List<String>? emails,
  ) async =>
      throw UnimplementedError(
          'FakePrintingPlatform.sharePdf is not stubbed.');

  @override
  Future<Uint8List> convertHtml(
    String html,
    String? baseUrl,
    PdfPageFormat format,
  ) async =>
      throw UnimplementedError(
          'FakePrintingPlatform.convertHtml is not stubbed.');

  @override
  Stream<PdfRaster> raster(
    Uint8List document,
    List<int>? pages,
    double dpi,
  ) =>
      Stream.error(UnimplementedError(
          'FakePrintingPlatform.raster is not stubbed.'));
}

/// Installs a [FakePrintingPlatform] as `PrintingPlatform.instance` for
/// the lifetime of the current test, restoring the previous instance via
/// `addTearDown` so the override does not leak between tests.
FakePrintingPlatform installFakePrintingPlatform({bool layoutResult = true}) {
  final previous = PrintingPlatform.instance;
  final fake = FakePrintingPlatform(layoutResult: layoutResult);
  PrintingPlatform.instance = fake;
  addTearDown(() => PrintingPlatform.instance = previous);
  return fake;
}
