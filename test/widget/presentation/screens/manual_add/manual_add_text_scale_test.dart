// Large-text layout sweep for ManualAddScreen.
//
// Android 14+ lets users scale text to 200%. The form fields and the media
// type dropdown must still fit a 411dp phone. 1.0 is the control: a failure
// there is not a text-scale defect.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/manual_add/manual_add_screen.dart';

void _configureMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(411, 798);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final scale in const [1.0, 1.3, 1.6, 2.0]) {
    testWidgets(
      'lays out without overflow at textScale $scale',
      (tester) async {
        _configureMobileViewport(tester);

        await tester.pumpWidget(
          ProviderScope(
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const MaterialApp(home: ManualAddScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
}
