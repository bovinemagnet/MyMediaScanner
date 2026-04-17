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
  final _googleBooksController = TextEditingController();
  final _tvdbController = TextEditingController();
  final _fanartController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final keys = ref.read(apiKeysProvider).value ?? {};
    _tmdbController.text = keys['tmdb'] ?? '';
    _discogsController.text = keys['discogs'] ?? '';
    _upcController.text = keys['upcitemdb'] ?? '';
    _googleBooksController.text = keys['google_books'] ?? '';
    _tvdbController.text = keys['tvdb'] ?? '';
    _fanartController.text = keys['fanart'] ?? '';
  }

  @override
  void dispose() {
    _tmdbController.dispose();
    _discogsController.dispose();
    _upcController.dispose();
    _googleBooksController.dispose();
    _tvdbController.dispose();
    _fanartController.dispose();
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
            'Enter your own API keys. They are stored securely on-device.'),
        const SizedBox(height: 4),
        Text(
          'Music scans use MusicBrainz by default — it is built in and '
          'needs no key. Open Library and TheAudioDB also need no keys. '
          'Discogs stays available as a fallback if you add a token below.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 16),

        // Primary sources
        Text('Primary Sources',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
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

        const SizedBox(height: 24),

        // Enrichment sources
        Text('Enrichment (optional)',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'These add extra artwork, scores, and TV metadata.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        _keyField('Google Books API Key', _googleBooksController, (key) {
          ref.read(apiKeysProvider.notifier).setGoogleBooksKey(key);
        }),
        const SizedBox(height: 12),
        _keyField('TVDB API Key', _tvdbController, (key) {
          ref.read(apiKeysProvider.notifier).setTvdbKey(key);
        }),
        const SizedBox(height: 12),
        _keyField('fanart.tv API Key', _fanartController, (key) {
          ref.read(apiKeysProvider.notifier).setFanartKey(key);
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
