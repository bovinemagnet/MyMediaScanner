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

  final PostgresConfig config;
  Connection? _connection;

  Future<Connection> _getConnection() async {
    if (_connection != null) return _connection!;

    final endpoint = Endpoint(
      host: config.host,
      port: config.port,
      database: config.database,
      username: config.username,
      password: config.password,
    );

    _connection = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: config.requireTls ? SslMode.require : SslMode.disable,
      ),
    );

    return _connection!;
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

  /// Push a batch of records to Postgres.
  Future<void> upsertRecords(
    String table,
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return;
    final conn = await _getConnection();

    for (final record in records) {
      final columns = record.keys.toList();
      final placeholders =
          List.generate(columns.length, (i) => '\$${i + 1}').join(', ');
      final updates = columns
          .where((c) => c != 'id')
          .map((c) => '$c = EXCLUDED.$c')
          .join(', ');

      await conn.execute(
        Sql.named(
          'INSERT INTO $table (${columns.join(', ')}) '
          'VALUES ($placeholders) '
          'ON CONFLICT (id) DO UPDATE SET $updates',
        ),
        parameters: record,
      );
    }
  }

  /// Pull all records updated after a given timestamp.
  Future<List<Map<String, dynamic>>> pullRecords(
    String table, {
    int? afterTimestamp,
  }) async {
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
  }

  /// Close the connection.
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
