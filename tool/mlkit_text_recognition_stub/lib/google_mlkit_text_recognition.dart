import 'dart:ui';

/// Pure-Dart no-op stub of the `google_mlkit_text_recognition` plugin.
///
/// Google ML Kit ships no arm64-simulator binary, which forces Flutter to
/// build the iOS simulator app as x86_64 — unrunnable on Apple-Silicon
/// iOS 26+ simulators (no Rosetta simulator). For simulator builds only,
/// `pubspec_overrides.yaml` swaps the real plugin for this stub so the app
/// compiles and links as arm64. Cover OCR then returns no text on the
/// simulator; on real devices the genuine plugin is used (no override) and
/// OCR works fully.
///
/// This mirrors only the API surface consumed by [CoverOcrHelper]; keep it in
/// sync if that usage changes.
class TextRecognizer {
  TextRecognizer({Object? script});

  Future<RecognizedText> processImage(InputImage inputImage) async =>
      const RecognizedText();

  Future<void> close() async {}
}

class RecognizedText {
  const RecognizedText({this.text = '', this.blocks = const []});

  final String text;
  final List<TextBlock> blocks;
}

class TextBlock {
  const TextBlock({this.text = '', this.boundingBox = Rect.zero});

  final String text;
  final Rect boundingBox;
}

class InputImage {
  const InputImage._();

  static InputImage fromFilePath(String path) => const InputImage._();
}
