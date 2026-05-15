import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/text_scale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to 1.0 when no value is persisted', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final value = await container.read(textScaleProvider.future);
    expect(value, 1.0);
  });

  test('setFactor persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(textScaleProvider.notifier).setFactor(1.3);
    expect(await container.refresh(textScaleProvider.future), 1.3);
  });

  test('setFactor clamps to [1.0, 1.6]', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(textScaleProvider.notifier).setFactor(0.1);
    expect(await container.read(textScaleProvider.future), 1.0);

    await container.read(textScaleProvider.notifier).setFactor(5.0);
    expect(await container.read(textScaleProvider.future), 1.6);
  });

  test('reset restores default', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(textScaleProvider.notifier).setFactor(1.4);
    await container.read(textScaleProvider.notifier).reset();
    expect(await container.refresh(textScaleProvider.future), 1.0);
  });
}
