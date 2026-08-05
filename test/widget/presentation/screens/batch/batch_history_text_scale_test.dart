// Large-text layout sweep for BatchHistoryScreen.
//
// Android 14+ lets users scale text to 200%. The session rows must still fit
// a 411dp phone. 1.0 is the control: a failure there is not a text-scale
// defect.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/batch_history_provider.dart';
import 'package:mymediascanner/presentation/screens/batch/batch_history_screen.dart';

class _StubBatchHistoryNotifier extends BatchHistoryNotifier {
  _StubBatchHistoryNotifier(this._sessions);

  final List<BatchSessionSummary> _sessions;

  @override
  Future<List<BatchSessionSummary>> build() async => _sessions;

  @override
  bool get hasMore => false;
}

BatchSessionSummary _session({
  required String id,
  required String status,
}) =>
    BatchSessionSummary(
      id: id,
      createdAt: DateTime(2024, 6, 1, 10, 30),
      status: status,
      itemCount: 12,
      savedCount: 9,
    );

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
            overrides: [
              batchHistoryProvider.overrideWith(
                () => _StubBatchHistoryNotifier([
                  _session(id: 'sess1', status: 'completed'),
                  _session(id: 'sess2', status: 'in_progress'),
                ]),
              ),
            ],
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const MaterialApp(home: BatchHistoryScreen()),
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
