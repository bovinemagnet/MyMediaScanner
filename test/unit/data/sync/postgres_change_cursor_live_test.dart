import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:postgres/postgres.dart';

/// Live check of the transaction-id pull cursor (#131 finding 1) against
/// a real PostgreSQL 13+ server with migrations 001–008 applied.
///
/// Opt-in: skipped unless MMS_TEST_PG_PORT is set. Point it at a
/// throwaway database — the test writes rows to `tags`.
///   MMS_TEST_PG_HOST (default localhost), MMS_TEST_PG_PORT,
///   MMS_TEST_PG_DB (default mms), MMS_TEST_PG_USER (default mms),
///   MMS_TEST_PG_PASSWORD (default empty).
void main() {
  final env = Platform.environment;
  final port = int.tryParse(env['MMS_TEST_PG_PORT'] ?? '');
  final skip = port == null ? 'MMS_TEST_PG_PORT not set' : null;

  late PostgresConfig config;
  late PostgresSyncClient client;
  late Connection other;

  setUp(() async {
    config = PostgresConfig(
      host: env['MMS_TEST_PG_HOST'] ?? 'localhost',
      port: port ?? 5432,
      database: env['MMS_TEST_PG_DB'] ?? 'mms',
      username: env['MMS_TEST_PG_USER'] ?? 'mms',
      password: env['MMS_TEST_PG_PASSWORD'] ?? '',
      requireTls: false,
    );
    client = PostgresSyncClient(config: config);
    // A second connection plays the device uploading in parallel.
    other = await Connection.open(
      Endpoint(
        host: config.host,
        port: config.port,
        database: config.database,
        username: config.username,
        password: config.password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    await other.execute("DELETE FROM tags WHERE id LIKE 'live-%'");
  });

  tearDown(() async {
    await other.execute("DELETE FROM tags WHERE id LIKE 'live-%'");
    await other.close();
    await client.close();
  });

  test('an upload that commits after a pull is fetched by the next pull, '
      'even with an old updated_at', () async {
    // Device A starts uploading an edit it made offline long ago.
    await other.execute('BEGIN');
    await other.execute(
      "INSERT INTO tags (id, name, updated_at) VALUES ('live-late', 'Late', 1)",
    );

    // Device B pulls while A's transaction is still open.
    final horizon = await client.fetchPullHorizon();
    final first = await client.pullRecords('tags');
    expect(first.map((r) => r['id']), isNot(contains('live-late')));

    await other.execute('COMMIT');

    final next = await client.pullRecords('tags', sinceTxid: horizon);
    expect(next.map((r) => r['id']), contains('live-late'));
  }, skip: skip);

  test('rows from transactions finished before the horizon are not '
      're-fetched', () async {
    await other.execute(
      "INSERT INTO tags (id, name, updated_at) VALUES ('live-old', 'Old', 1)",
    );
    final horizon = await client.fetchPullHorizon();

    final next = await client.pullRecords('tags', sinceTxid: horizon);

    expect(next.map((r) => r['id']), isNot(contains('live-old')));
  }, skip: skip);

  test('an update restamps the row so the next pull fetches it', () async {
    await other.execute(
      "INSERT INTO tags (id, name, updated_at) VALUES ('live-edit', 'A', 1)",
    );
    final horizon = await client.fetchPullHorizon();
    await other.execute("UPDATE tags SET name = 'B' WHERE id = 'live-edit'");

    final next = await client.pullRecords('tags', sinceTxid: horizon);

    expect(
      next.where((r) => r['id'] == 'live-edit').map((r) => r['name']),
      ['B'],
    );
  }, skip: skip);
}
