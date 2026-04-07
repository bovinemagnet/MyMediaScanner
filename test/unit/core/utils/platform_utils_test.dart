import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

void main() {
  group('PlatformCapability', () {
    test('canUseCamera equals canUseMobileScanner OR canUseNativeCamera', () {
      expect(
        PlatformCapability.canUseCamera,
        PlatformCapability.canUseMobileScanner ||
            PlatformCapability.canUseNativeCamera,
      );
    });

    test('canUseMobileScanner and canUseNativeCamera are mutually exclusive', () {
      // A platform should not be both mobile_scanner-capable and native-camera-capable
      expect(
        PlatformCapability.canUseMobileScanner &&
            PlatformCapability.canUseNativeCamera,
        isFalse,
      );
    });

    test('hasCoverOcr is true for all platforms', () {
      expect(PlatformCapability.hasCoverOcr, isTrue);
    });

    test('isDesktop and isMobile are mutually exclusive', () {
      expect(
        PlatformCapability.isDesktop && PlatformCapability.isMobile,
        isFalse,
      );
    });

    test('usesKeyboardScanner matches isDesktop', () {
      expect(
        PlatformCapability.usesKeyboardScanner,
        PlatformCapability.isDesktop,
      );
    });
  });
}
