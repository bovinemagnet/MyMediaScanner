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

  /// True once we have registered ourselves as a [WidgetsBindingObserver].
  /// `build()` re-runs whenever the watched config provider re-emits, but
  /// the [Notifier] instance is preserved — so a naive
  /// `addObserver(this)` in build() registers the same observer N times,
  /// causing `didChangeAppLifecycleState` to fire N times per lifecycle
  /// event. Guarding with this flag keeps it idempotent.
  bool _observerRegistered = false;

  /// Ping interval in seconds (default 60).
  static const _pingIntervalSeconds = 60;

  @override
  ConnectionHealth build() {
    final config = ref.watch(postgresConfigProvider).value;
    if (config == null) return ConnectionHealth.unconfigured;

    if (!_observerRegistered) {
      // First-time setup: register the lifecycle observer, start the
      // periodic ping timer, and wire disposal. `build()` re-runs every
      // time `postgresConfigProvider` re-emits — calling `_startTimer`
      // every time would cancel-and-restart the 60 s window so a
      // burst of config edits (or even one unrelated re-emission) would
      // postpone the next ping indefinitely. Guarding with the same
      // flag we use for observer registration keeps both idempotent.
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
      _startTimer();
      ref.onDispose(() {
        _timer?.cancel();
        _timer = null;
        if (_observerRegistered) {
          WidgetsBinding.instance.removeObserver(this);
          _observerRegistered = false;
        }
      });
    }

    // Always re-ping on rebuild — config may have changed and the new
    // postgresSyncClientProvider value reflects that immediately.
    _ping();

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
    if (!ref.mounted) return;
    // Reuse the long-lived client from `postgresSyncClientProvider` so
    // we hit the cached connection. Building a fresh `PostgresSyncClient`
    // per ping (and `close()`ing it in finally) used to pay a full TLS
    // handshake every 60 s, which dwarfed the cost of the SELECT 1 that
    // is the actual health check.
    final client = ref.read(postgresSyncClientProvider);
    if (client == null) {
      if (ref.mounted) state = ConnectionHealth.unconfigured;
      return;
    }
    try {
      final health = await client.ping();
      if (ref.mounted) state = health;
    } on Exception {
      if (ref.mounted) state = ConnectionHealth.disconnected;
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
