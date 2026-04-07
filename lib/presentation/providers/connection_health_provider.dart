import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

/// Notifier that periodically pings the PostgreSQL server to check
/// connection health. Pauses when the app is backgrounded and pings
/// immediately on resume.
class ConnectionHealthNotifier extends Notifier<ConnectionHealth>
    with WidgetsBindingObserver {
  Timer? _timer;

  /// Ping interval in seconds (default 60).
  static const _pingIntervalSeconds = 60;

  @override
  ConnectionHealth build() {
    final config = ref.watch(postgresConfigProvider).value;
    if (config == null) return ConnectionHealth.unconfigured;

    // Start periodic pinging
    _startTimer();

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Trigger initial ping
    _ping();

    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });

    return ConnectionHealth.unconfigured;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: _pingIntervalSeconds),
      (_) => _ping(),
    );
  }

  Future<void> _ping() async {
    final syncRepo = ref.read(syncRepositoryProvider);
    if (syncRepo == null) {
      state = ConnectionHealth.unconfigured;
      return;
    }

    final config = ref.read(postgresConfigProvider).value;
    if (config == null) {
      state = ConnectionHealth.unconfigured;
      return;
    }

    final client = PostgresSyncClient(config: config);
    try {
      final health = await client.ping();
      state = health;
    } on Exception {
      state = ConnectionHealth.disconnected;
    } finally {
      await client.close();
    }
  }

  /// Manually trigger a health check.
  Future<void> checkNow() async {
    await _ping();
  }

  @override
  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _startTimer();
      _ping();
    }
  }
}

final connectionHealthProvider =
    NotifierProvider<ConnectionHealthNotifier, ConnectionHealth>(
  ConnectionHealthNotifier.new,
);
