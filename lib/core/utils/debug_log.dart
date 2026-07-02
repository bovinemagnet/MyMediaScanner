import 'package:flutter/foundation.dart';

/// Logs [message] in debug builds only.
///
/// `debugPrint` itself is not stripped from release builds, so all
/// diagnostic logging is routed through this guard instead.
void debugLog(String message) {
  if (kDebugMode) debugPrint(message);
}
