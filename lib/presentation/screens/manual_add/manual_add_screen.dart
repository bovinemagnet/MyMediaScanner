// Manual add screen — lets a user add an item without scanning a barcode.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart';
import 'package:uuid/uuid.dart';

class ManualAddScreen extends ConsumerStatefulWidget {
  const ManualAddScreen({super.key});

  @override
  ConsumerState<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends ConsumerState<ManualAddScreen> {
  late final MetadataResult _initial;

  /// Controls where the item is saved when the user presses Save.
  /// Defaults to local-only. Updated by [RemoteFirstSaveModeSelector].
  SaveMode _saveMode = SaveMode.saveLocally;

  /// Tracks the latest edited [MetadataResult] passed to [_handleSave].
  /// Used to resolve the TMDB id and media type for the save-mode selector
  /// gate. Populated after the first save attempt so the selector can appear
  /// on subsequent taps if an online lookup has populated a tmdb_id.
  MetadataResult? _latestEdited;

  @override
  void initState() {
    super.initState();
    // Placeholder barcode keeps uniqueness, sync and dedup logic intact for
    // items the user entered by hand. Prefix signals provenance.
    final placeholder = 'MANUAL-${const Uuid().v7()}';
    _initial = MetadataResult(
      barcode: placeholder,
      barcodeType: 'MANUAL',
      mediaType: MediaType.unknown,
    );
  }

  /// Returns the TMDB integer ID from the latest edited metadata's
  /// extraMetadata, or null if not present.
  int? _resolveTmdbId() {
    final meta = _latestEdited;
    if (meta == null) return null;
    final raw = meta.extraMetadata['tmdb_id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return null;
  }

  /// Returns the TMDB API media-type string ('movie' or 'tv') from the latest
  /// edited metadata's extraMetadata, or null if not present.
  String? _resolveApiMediaType() {
    final meta = _latestEdited;
    if (meta == null) return null;
    final raw = meta.extraMetadata['media_type'];
    if (raw is! String) return null;
    return raw;
  }

  Future<void> _handleSave(MetadataResult edited) async {
    // Capture the latest edited metadata so the selector can be shown on
    // subsequent save attempts when an online lookup has populated a tmdb_id.
    if (_latestEdited != edited) {
      setState(() => _latestEdited = edited);
    }

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final mode = _saveMode;
    switch (mode) {
      case SaveMode.saveLocally:
      case SaveMode.saveLocallyAndSync:
        final useCase = ref.read(saveMediaItemUseCaseProvider);
        await useCase.execute(edited);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Item added to collection')),
        );
        router.go('/collection');
      case SaveMode.tmdbOnly:
        final tmdbId = _resolveTmdbId();
        final mediaType = _resolveApiMediaType();
        if (tmdbId == null || mediaType == null) {
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Cannot save TMDB only — no TMDB ID resolved'),
            ),
          );
          return;
        }
        await ref.read(saveTmdbOnlyUseCaseProvider).call(
              tmdbId: tmdbId,
              mediaType: mediaType,
              title: edited.title ?? '',
              posterPath: edited.coverUrl,
              barcode: null, // manual-add has no scanned barcode
            );
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Saved to TMDB')),
        );
        router.go('/collection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(tmdbAccountSyncSettingsProvider);
    final tmdbId = _resolveTmdbId();
    final apiMediaType = _resolveApiMediaType();
    final showSelector = settings.enabled &&
        settings.remoteFirstSaveEnabled &&
        tmdbId != null &&
        (apiMediaType == 'movie' || apiMediaType == 'tv');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item Manually'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditableMetadataForm(
                initial: _initial,
                onSave: _handleSave,
                primarySaveLabel: 'Save to Collection',
                primarySaveIcon: Icons.save,
                enableOnlineLookup: true,
                showFormatSuggestions: true,
              ),
              // Remote-first save-mode selector — shown when account sync is
              // enabled, remote-first toggle is on, and the item has a TMDB ID
              // with a movie/tv media type (populated after an online lookup).
              if (showSelector)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: RemoteFirstSaveModeSelector(
                    value: _saveMode,
                    onChanged: (v) => setState(() => _saveMode = v),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
