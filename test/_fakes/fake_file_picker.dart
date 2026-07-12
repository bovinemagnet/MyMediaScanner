/// Test fake for the [FilePickerPlatform] interface.
///
/// `FilePickerPlatform.instance` is a static platform singleton,
/// which means tests cannot stub it via the usual mocktail / method-channel
/// patterns — but the package does allow swapping the singleton. This
/// helper extends [FilePickerPlatform], captures the arguments passed to
/// [pickFiles], and returns whatever [FilePickerResult] the test seeds.
///
/// Typical usage in a `testWidgets` body:
/// ```dart
/// final fake = installFakeFilePicker(
///   tester,
///   result: buildBytesResult(name: 'export.csv', bytes: utf8.encode(csv)),
/// );
/// await tester.tap(find.text('Choose file…'));
/// await tester.pumpAndSettle();
/// expect(fake.lastCall?.allowedExtensions, ['csv']);
/// ```
///
/// `installFakeFilePicker` records the previous platform instance via
/// `addTearDown` so the override does not leak between tests.
library;

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captured arguments from a single call to [FakeFilePicker.pickFiles].
class FilePickerCall {
  const FilePickerCall({
    required this.type,
    required this.allowedExtensions,
    required this.withData,
    required this.allowMultiple,
  });

  final FileType type;
  final List<String>? allowedExtensions;
  final bool withData;
  final bool allowMultiple;
}

/// In-memory [FilePicker] implementation used in widget tests.
///
/// Returns [result] from [pickFiles] (use `null` to simulate "user
/// cancelled the dialog") and stores the most recent call's arguments on
/// [lastCall] so tests can assert what the screen requested.
///
/// All other [FilePicker] methods inherit the package default that throws
/// [UnimplementedError] — fail-fast is intentional, so a screen reaching
/// for a method other than [pickFiles] surfaces immediately rather than
/// silently no-oping.
class FakeFilePicker extends FilePickerPlatform {
  FakeFilePicker({this.result});

  /// The canned result returned from [pickFiles]. `null` simulates the
  /// user cancelling the dialog.
  FilePickerResult? result;

  /// The most recent arguments passed to [pickFiles], or `null` if it has
  /// not been called yet.
  FilePickerCall? lastCall;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
    AndroidSAFOptions? androidSafOptions,
  }) async {
    lastCall = FilePickerCall(
      type: type,
      allowedExtensions: allowedExtensions,
      withData: withData,
      allowMultiple: allowMultiple,
    );
    return result;
  }
}

/// Builds a single-file [FilePickerResult] with the given in-memory bytes.
///
/// Builds the shape returned by a platform picker with in-memory data.
FilePickerResult buildBytesResult({
  required String name,
  required List<int> bytes,
}) {
  return FilePickerResult([
    PlatformFile.fromMap({
      'name': name,
      'size': bytes.length,
      'bytes': Uint8List.fromList(bytes),
      'path': null,
      'identifier': null,
    }),
  ]);
}

/// Installs [FakeFilePicker] as `FilePickerPlatform.instance` for the duration of
/// the current widget test, then restores the previous instance during
/// tearDown. Always reach for this helper rather than swapping
/// `FilePickerPlatform.instance` by hand so tests do not leak overrides between
/// each other.
FakeFilePicker installFakeFilePicker(
  WidgetTester tester, {
  FilePickerResult? result,
}) {
  final previous = FilePickerPlatform.instance;
  final fake = FakeFilePicker(result: result);
  FilePickerPlatform.instance = fake;
  addTearDown(() {
    FilePickerPlatform.instance = previous;
  });
  return fake;
}
