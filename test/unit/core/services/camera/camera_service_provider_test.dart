import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/services/camera/camera_service_provider.dart';

/// Regression: `cameraServiceProvider` was a keep-alive
/// `Provider<CameraService>` caching one instance for the app's
/// lifetime, while `DesktopScanScreen` (correctly, as the owner)
/// called `dispose()` on it when the webcam was toggled off. The next
/// session then received the same disposed instance: its broadcast
/// barcode controller was closed, so detections were silently dropped
/// on Windows/Linux, and `start()` threw on macOS — scanning was dead
/// until app restart. The provider must hand out a fresh instance per
/// session instead of caching one.
void main() {
  test('each webcam session gets a fresh, usable camera service', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final createService = container.read(cameraServiceFactoryProvider);

    // First session: screen creates, uses, and disposes the service.
    final first = createService();
    await first.dispose();

    // Second session must NOT receive the disposed instance.
    final second = createService();
    addTearDown(second.dispose);
    expect(identical(second, first), isFalse,
        reason: 'a disposed service must never be handed out again');

    // The fresh instance's detection stream must be live (listenable).
    final subscription = second.onBarcodeDetected.listen((_) {});
    await subscription.cancel();
  });
}
