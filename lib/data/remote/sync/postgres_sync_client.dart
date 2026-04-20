import 'dart:async';

import 'package:postgres/postgres.dart';

/// Configuration for PostgreSQL connection.
class PostgresConfig {
  const PostgresConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.requireTls = true,
  });

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final bool requireTls;
}

/// Direct PostgreSQL connection client for sync operations.
class PostgresSyncClient {
  PostgresSyncClient({required this.config});

  /// Maximum number of records per batched INSERT statement.
  static const _batchSize = 50;

  /// Whitelist of table names the sync pipeline is allowed to touch.
  /// Table and column names are interpolated into SQL (they can't be bound
  /// as parameters), so we restrict them here to prevent any future code
  /// path from piping user-controlled strings into the DDL surface.
  static const _allowedTables = {
    'media_items',
    'shelves',
    'shelf_items',
    'tags',
    'media_item_tags',
    'borrowers',
    'loans',
    'locations',
    'series',
  };

  /// Matches a valid SQL identifier (column or table name).
  static final _identifierRegex = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  final PostgresConfig config;
  Connection? _connection;

  /// Serialises concurrent calls on the shared [Connection]. The `postgres`
  /// package runs one query at a time per connection; overlapping awaits
  /// from different callers would otherwise interleave and raise.
  final _connectionLock = _AsyncMutex();

  static void _assertSafeTable(String table) {
    if (!_allowedTables.contains(table)) {
      throw ArgumentError.value(
        table,
        'table',
        'Table not in the sync allow-list',
      );
    }
  }

  static void _assertSafeColumns(Iterable<String> columns) {
    for (final c in columns) {
      if (!_identifierRegex.hasMatch(c)) {
        throw ArgumentError.value(
          c,
          'column',
          'Invalid SQL identifier',
        );
      }
    }
  }

  /// Builds a multi-row INSERT ... ON CONFLICT SQL statement for batch upserts.
  ///
  /// Returns the generated SQL string and ordered parameter list.
  /// Exposed as static for testability without requiring a live connection.
  static ({String sql, List<dynamic> params}) buildBatchUpsertSql(
    String table,
    List<Map<String, dynamic>> records,
  ) {
    _assertSafeTable(table);
    final columns = records.first.keys.toList();
    _assertSafeColumns(columns);
    final params = <dynamic>[];
    final valueClauses = <String>[];

    for (var i = 0; i < records.length; i++) {
      final placeholders = <String>[];
      for (var j = 0; j < columns.length; j++) {
        final paramIndex = i * columns.length + j + 1;
        placeholders.add('\$$paramIndex');
        params.add(records[i][columns[j]]);
      }
      valueClauses.add('(${placeholders.join(', ')})');
    }

    final updates = columns
        .where((c) => c != 'id')
        .map((c) => '$c = EXCLUDED.$c')
        .join(', ');

    final sql = 'INSERT INTO $table (${columns.join(', ')}) '
        'VALUES ${valueClauses.join(', ')} '
        'ON CONFLICT (id) DO UPDATE SET $updates';

    return (sql: sql, params: params);
  }

  Future<Connection> _getConnection() async {
    final existing = _connection;
    if (existing != null && existing.isOpen) return existing;

    // Either first connect or the cached Connection was closed by the
    // server (Postgres idle-timeout: 5-30 min). Re-open either way.
    _connection = null;

    final endpoint = Endpoint(
      host: config.host,
      port: config.port,
      database: config.database,
      username: config.username,
      password: config.password,
    );

    final conn = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: config.requireTls ? SslMode.require : SslMode.disable,
      ),
    );
    _connection = conn;
    return conn;
  }

  /// Test connectivity and return true if successful.
  Future<bool> testConnection() async {
    try {
      final conn = await _getConnection();
      final result = await conn.execute('SELECT 1');
      return result.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  /// Push a batch of records to Postgres using multi-row INSERT statements.
  ///
  /// Records are split into chunks of [_batchSize] to avoid overly large
  /// queries whilst still minimising round-trips.
  Future<void> upsertRecords(
    String table,
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return;
    _assertSafeTable(table);
    await _connectionLock.synchronized(() async {
      final conn = await _getConnection();
      for (var i = 0; i < records.length; i += _batchSize) {
        final batch = records.sublist(
          i,
          i + _batchSize > records.length ? records.length : i + _batchSize,
        );
        final (:sql, :params) = buildBatchUpsertSql(table, batch);
        await conn.execute(sql, parameters: params);
      }
    });
  }

  /// Pull all records updated after a given timestamp.
  Future<List<Map<String, dynamic>>> pullRecords(
    String table, {
    int? afterTimestamp,
  }) async {
    _assertSafeTable(table);
    return _connectionLock.synchronized(() async {
      final conn = await _getConnection();
      final Result result;

      if (afterTimestamp != null) {
        result = await conn.execute(
          Sql.named(
            'SELECT * FROM $table WHERE updated_at > @ts',
          ),
          parameters: {'ts': afterTimestamp},
        );
      } else {
        result = await conn.execute('SELECT * FROM $table');
      }

      return result.map((row) => row.toColumnMap()).toList();
    });
  }

  /// Lightweight connectivity check using `SELECT 1` with a 5-second timeout.
  /// Returns a [ConnectionHealth] status.
  Future<ConnectionHealth> ping() async {
    try {
      final conn = await _getConnection().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );
      final result = await conn
          .execute('SELECT 1')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty
          ? ConnectionHealth.connected
          : ConnectionHealth.disconnected;
    } on TimeoutException {
      return ConnectionHealth.timeout;
    } on Exception {
      // Reset connection so next attempt creates a fresh one
      _connection = null;
      return ConnectionHealth.disconnected;
    }
  }

  /// Close the connection.
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}

/// The health status of the PostgreSQL connection.
enum ConnectionHealth {
  connected,
  disconnected,
  timeout,
  unconfigured,
}

/// Minimal single-slot async mutex. Serialises access to the shared
/// `postgres` [Connection] (the package is single-threaded per connection,
/// so overlapping awaits from different callers can't safely interleave).
class _AsyncMutex {
  Future<void>? _head;

  Future<T> synchronized<T>(Future<T> Function() body) {
    final prev = _head;
    final completer = Completer<void>();
    _head = completer.future;

    return () async {
      if (prev != null) {
        try {
          await prev;
        } catch (_) {
          // Ignore prior-block errors; our body runs on a clean slate.
        }
      }
      try {
        return await body();
      } finally {
        completer.complete();
        if (identical(_head, completer.future)) _head = null;
      }
    }();
  }
}
