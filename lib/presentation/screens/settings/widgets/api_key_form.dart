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
  final _twitchClientIdController = TextEditingController();
  final _twitchClientSecretController = TextEditingController();

  /// True once the async secure-storage read has resolved and we have
  /// populated the controllers. Used to gate saves so that hitting the
  /// save icon while values are still loading can't overwrite a real
  /// stored secret with an empty string.
  bool _seeded = false;

  void _seedFrom(Map<String, String?> keys) {
    _tmdbController.text = keys['tmdb'] ?? '';
    _discogsController.text = keys['discogs'] ?? '';
    _upcController.text = keys['upcitemdb'] ?? '';
    _googleBooksController.text = keys['google_books'] ?? '';
    _tvdbController.text = keys['tvdb'] ?? '';
    _fanartController.text = keys['fanart'] ?? '';
    _twitchClientIdController.text = keys['twitch_client_id'] ?? '';
    _twitchClientSecretController.text = keys['twitch_client_secret'] ?? '';
    _seeded = true;
  }

  @override
  void dispose() {
    _tmdbController.dispose();
    _discogsController.dispose();
    _upcController.dispose();
    _googleBooksController.dispose();
    _tvdbController.dispose();
    _fanartController.dispose();
    _twitchClientIdController.dispose();
    _twitchClientSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keysAsync = ref.watch(apiKeysProvider);

    // Seed controllers exactly once, when the secure-storage read
    // resolves. Reading from `ref.read(...).value` in initState misses
    // late resolution and leaves the form empty, causing a hasty save
    // to overwrite real keys with ''.
    if (!_seeded) {
      keysAsync.whenData(_seedFrom);
    }

    if (keysAsync.isLoading && !_seeded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
        const SizedBox(height: 4),
        Text(
          'TMDB needs the v4 "API Read Access Token" (a long ~250-char '
          'string starting with "eyJ…") — not the 32-char v3 API Key. '
          'Find it on themoviedb.org → Settings → API → '
          '"API Read Access Token (v4 auth)".',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        _keyField('TMDB Read Access Token (v4)', _tmdbController, (key) {
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

        // IGDB (games) — uses Twitch OAuth
        Text('IGDB / Games',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'IGDB uses Twitch OAuth. Register an app at dev.twitch.tv to get '
          'a Client ID and Client Secret — both are required for online '
          'game lookup.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        _keyField('Twitch Client ID', _twitchClientIdController, (key) {
          ref.read(apiKeysProvider.notifier).setTwitchClientId(key);
        }),
        const SizedBox(height: 12),
        _keyField('Twitch Client Secret', _twitchClientSecretController,
            (key) {
          ref.read(apiKeysProvider.notifier).setTwitchClientSecret(key);
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
    return _ApiKeyField(
      label: label,
      controller: controller,
      onSave: onSave,
    );
  }
}

/// A masked API-key field with a per-field reveal toggle and a save
/// button. Visibility state is local so revealing one key does not
/// expose the others.
class _ApiKeyField extends StatefulWidget {
  const _ApiKeyField({
    required this.label,
    required this.controller,
    required this.onSave,
  });

  final String label;
  final TextEditingController controller;
  final void Function(String) onSave;

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _obscured ? Icons.visibility : Icons.visibility_off,
              ),
              tooltip: _obscured ? 'Reveal' : 'Hide',
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: () {
                widget.onSave(widget.controller.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.label} saved')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
