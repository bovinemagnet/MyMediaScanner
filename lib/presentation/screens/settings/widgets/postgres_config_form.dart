import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class PostgresConfigForm extends ConsumerStatefulWidget {
  const PostgresConfigForm({super.key});

  @override
  ConsumerState<PostgresConfigForm> createState() => _PostgresConfigFormState();
}

class _PostgresConfigFormState extends ConsumerState<PostgresConfigForm> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _dbController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _requireTls = true;
  bool _testing = false;
  String? _testResult;

  /// True once the async secure-storage read has resolved and we have
  /// populated the controllers. Saves and tests stay disabled until
  /// then so a user clicking through a still-loading form can't blank
  /// out a real stored password.
  bool _seeded = false;

  void _seedFrom(PostgresConfig? config) {
    if (config != null) {
      _hostController.text = config.host;
      _portController.text = config.port.toString();
      _dbController.text = config.database;
      _userController.text = config.username;
      _passController.text = config.password;
      _requireTls = config.requireTls;
    }
    _seeded = true;
  }

  Future<void> _save() async {
    final config = PostgresConfig(
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text) ??
          AppConstants.defaultPostgresPort,
      database: _dbController.text.trim(),
      username: _userController.text.trim(),
      password: _passController.text,
      requireTls: _requireTls,
    );
    await ref.read(postgresConfigProvider.notifier).save(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration saved')),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final syncRepo = ref.read(syncRepositoryProvider);
    if (syncRepo == null) {
      setState(() {
        _testing = false;
        _testResult = 'Save configuration first';
      });
      return;
    }

    final success = await syncRepo.testConnection();
    setState(() {
      _testing = false;
      _testResult = success ? 'Connection successful!' : 'Connection failed';
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _dbController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(postgresConfigProvider);

    if (!_seeded) {
      configAsync.whenData(_seedFrom);
    }

    if (configAsync.isLoading && !_seeded) {
      return Scaffold(
        appBar: AppBar(title: const Text('PostgreSQL Configuration')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PostgreSQL Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(labelText: 'Host'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dbController,
              decoration: const InputDecoration(labelText: 'Database'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Require TLS'),
              subtitle: const Text('Recommended for security'),
              value: _requireTls,
              onChanged: (v) => setState(() => _requireTls = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testing ? null : _testConnection,
                    child: _testing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Test Connection'),
                  ),
                ),
              ],
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Text(
                _testResult!,
                style: TextStyle(
                  color: _testResult!.contains('successful')
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
