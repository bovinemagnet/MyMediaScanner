import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class ApiKeyForm extends ConsumerStatefulWidget {
  const ApiKeyForm({super.key});

  @override
  ConsumerState<ApiKeyForm> createState() => _ApiKeyFormState();
}

class _ApiKeyFormState extends ConsumerState<ApiKeyForm> {
  final _tmdbController = TextEditingController();
  final _discogsController = TextEditingController();
  final _upcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final keys = ref.read(apiKeysProvider).valueOrNull ?? {};
    _tmdbController.text = keys['tmdb'] ?? '';
    _discogsController.text = keys['discogs'] ?? '';
    _upcController.text = keys['upcitemdb'] ?? '';
  }

  @override
  void dispose() {
    _tmdbController.dispose();
    _discogsController.dispose();
    _upcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('API Keys', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text(
            'Enter your own API keys. These are stored securely on-device.'),
        const SizedBox(height: 12),
        _keyField('TMDB API Key', _tmdbController, (key) {
          ref.read(apiKeysProvider.notifier).setTmdbKey(key);
        }),
        const SizedBox(height: 12),
        _keyField('Discogs Token', _discogsController, (key) {
          ref.read(apiKeysProvider.notifier).setDiscogsKey(key);
        }),
        const SizedBox(height: 12),
        _keyField('UPCitemdb Key', _upcController, (key) {
          ref.read(apiKeysProvider.notifier).setUpcitemdbKey(key);
        }),
      ],
    );
  }

  Widget _keyField(
    String label,
    TextEditingController controller,
    Function(String) onSave,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            onSave(controller.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label saved')),
            );
          },
        ),
      ),
      obscureText: true,
    );
  }
}
