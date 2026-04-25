import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/widgets/gradient_button.dart';

class EditableMetadataForm extends StatefulWidget {
  const EditableMetadataForm({
    super.key,
    required this.initial,
    required this.onSave,
    this.onSaveToWishlist,
    this.primarySaveLabel = 'Save to Collection',
    this.primarySaveIcon = Icons.save,
    this.enableOnlineLookup = false,
    this.showFormatSuggestions = false,
  });

  final MetadataResult initial;
  final Future<void> Function(MetadataResult edited) onSave;

  /// Optional alternative action that saves the edited metadata to the
  /// wishlist instead of the main collection. When non-null, a secondary
  /// "Save to Wishlist" button is rendered below the primary Save button.
  final Future<void> Function(MetadataResult edited)? onSaveToWishlist;

  /// Label for the primary save button. The scan-time `SaveTarget` toggle
  /// drives this through [MetadataConfirmScreen], so the button reads
  /// "Save to Wishlist" when the scanner is pointed at the wishlist.
  final String primarySaveLabel;

  /// Icon for the primary save button. Paired with [primarySaveLabel].
  final IconData primarySaveIcon;

  /// When true, render a "Search online" button that queries the metadata
  /// repository using the current title + subtitle, routed by media type
  /// (MusicBrainz/Discogs for music, Google Books/Open Library for books,
  /// TMDB for film/TV). Requires an ancestor [ProviderScope].
  final bool enableOnlineLookup;

  /// When true, render tappable suggestion chips for common formats beneath
  /// the Format field (and platform chips beneath the "Platform" field when
  /// media type is game). Tapping a chip populates the field.
  final bool showFormatSuggestions;

  @override
  State<EditableMetadataForm> createState() => _EditableMetadataFormState();
}

class _EditableMetadataFormState extends State<EditableMetadataForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _yearController;
  late final TextEditingController _publisherController;
  late final TextEditingController _formatController;
  late MediaType _mediaType;
  String? _coverUrl;
  late List<String> _sourceApis;
  String? _resolution;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.initial.subtitle ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initial.description ?? '',
    );
    _yearController = TextEditingController(
      text: widget.initial.year?.toString() ?? '',
    );
    _publisherController = TextEditingController(
      text: widget.initial.publisher ?? '',
    );
    _formatController = TextEditingController(
      text: widget.initial.format ?? '',
    );
    _mediaType = widget.initial.mediaType ?? MediaType.unknown;
    _coverUrl = widget.initial.coverUrl;
    _sourceApis = List<String>.from(widget.initial.sourceApis);
    final existingRes = widget.initial.extraMetadata['resolution'];
    _resolution = existingRes is String ? existingRes : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _publisherController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  bool _saving = false;
  bool _lookingUp = false;

  /// Contextual label for the "subtitle" slot — a single string on
  /// `MediaItem` that carries different semantics per media type:
  /// artist for music, author for books, platform for games, etc.
  String _subtitleLabel(MediaType type) => switch (type) {
        MediaType.music => 'Artist',
        MediaType.book => 'Author',
        MediaType.game => 'Platform',
        _ => 'Subtitle',
      };

  /// Common format suggestions shown as chips beneath the Format field.
  /// Tapping a chip fills the field; the user can still type a custom value.
  List<String> _formatSuggestions(MediaType type) => switch (type) {
        MediaType.film || MediaType.tv => const [
            'DVD',
            'Blu-ray',
            '4K Blu-ray',
          ],
        MediaType.music => const ['CD', 'LP', 'Cassette', 'Digital'],
        MediaType.book => const [
            'Hardcover',
            'Paperback',
            'eBook',
            'Audiobook',
          ],
        MediaType.game => const ['Disc', 'Cartridge', 'Digital'],
        _ => const [],
      };

  /// Platform suggestions for games — shown beneath the "Platform" field
  /// (the subtitle slot) when the media type is game.
  List<String> _platformSuggestions() => const [
        'PS5',
        'PS4',
        'Xbox Series X|S',
        'Xbox One',
        'Switch',
        'PC',
      ];

  /// Resolution options that make sense for a given media type and format.
  /// Only film/TV on DVD or Blu-ray — other formats carry their resolution
  /// in the format name itself (4K Blu-ray, 8K) so they get no chips.
  List<String> _resolutionSuggestions(MediaType type, String format) {
    if (type != MediaType.film && type != MediaType.tv) return const [];
    final fmt = format.trim().toLowerCase();
    return switch (fmt) {
      'dvd' => const ['480p', '576p'],
      'blu-ray' || 'bluray' || 'blu ray' => const ['720p', '1080p'],
      _ => const [],
    };
  }

  MetadataResult _buildEdited() {
    // Only persist resolution if it's still a valid choice for the current
    // media type + format — a stale pick after the user switches away from
    // DVD/Blu-ray shouldn't leak into saved metadata.
    final resSuggestions =
        _resolutionSuggestions(_mediaType, _formatController.text);
    final resolution =
        resSuggestions.contains(_resolution) ? _resolution : null;
    final extra = Map<String, dynamic>.from(widget.initial.extraMetadata);
    if (resolution != null) extra['resolution'] = resolution;
    return widget.initial.copyWith(
      title: _titleController.text.isEmpty ? null : _titleController.text,
      subtitle: _subtitleController.text.isEmpty
          ? null
          : _subtitleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      year: int.tryParse(_yearController.text),
      publisher: _publisherController.text.isEmpty
          ? null
          : _publisherController.text,
      format: _formatController.text.isEmpty ? null : _formatController.text,
      mediaType: _mediaType,
      coverUrl: _coverUrl,
      sourceApis: _sourceApis,
      extraMetadata: extra,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(_buildEdited());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatSourceLabel(List<String> apis) {
    const prettyNames = {
      'musicbrainz': 'MusicBrainz',
      'discogs': 'Discogs',
      'tmdb': 'TMDB',
      'tvdb': 'TVDB',
      'google_books': 'Google Books',
      'open_library': 'Open Library',
      'upcitemdb': 'UPCitemdb',
      'theaudiodb': 'TheAudioDB',
      'fanart': 'fanart.tv',
    };
    return apis.map((a) => prettyNames[a] ?? a).join(' + ');
  }

  Future<void> _saveToWishlist() async {
    final callback = widget.onSaveToWishlist;
    if (callback == null || _saving) return;
    setState(() => _saving = true);
    try {
      await callback(_buildEdited());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Returns a message explaining why a type-aware lookup would fail for
  /// [type] given the currently-configured [apiKeys], or `null` if the
  /// lookup can proceed.
  ///
  /// Film/TV title search only routes to TMDB; without a TMDB key the
  /// repository returns `notFound` without trying anything else. Game
  /// search routes to IGDB, which requires a Twitch Client ID + Secret.
  /// Music, book, and unknown always have at least one key-free fallback
  /// (MusicBrainz / Open Library).
  String? _missingApiMessage(MediaType type, Map<String, String?> apiKeys) {
    switch (type) {
      case MediaType.film:
      case MediaType.tv:
        if ((apiKeys['tmdb'] ?? '').isEmpty) {
          return 'TMDB API key required in Settings to search for films and TV.';
        }
        return null;
      case MediaType.game:
        if ((apiKeys['twitch_client_id'] ?? '').isEmpty ||
            (apiKeys['twitch_client_secret'] ?? '').isEmpty) {
          return 'Twitch Client ID and Secret required in Settings to '
              'search for games (IGDB).';
        }
        return null;
      case MediaType.music:
      case MediaType.book:
      case MediaType.unknown:
        return null;
    }
  }

  /// Runs a type-aware online search using the current title + subtitle as
  /// the query. On single match, populates the form directly. On multi
  /// match, opens a bottom sheet of candidates; selecting one fetches its
  /// detail and populates the form.
  Future<void> _lookupOnline(WidgetRef ref) async {
    if (_lookingUp) return;
    final parts = <String>[
      _titleController.text.trim(),
      _subtitleController.text.trim(),
    ].where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title first')),
      );
      return;
    }

    final apiKeys = ref.read(apiKeysProvider).value ?? const {};
    final missing = _missingApiMessage(_mediaType, apiKeys);
    if (missing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(missing)),
      );
      return;
    }

    final query = parts.join(' ');
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _lookingUp = true);
    try {
      final repo = ref.read(metadataRepositoryProvider);
      final result = await repo.searchByTitle(
        query,
        widget.initial.barcode,
        widget.initial.barcodeType,
        typeHint: _mediaType == MediaType.unknown ? null : _mediaType,
      );
      if (!mounted) return;
      switch (result) {
        case SingleScanResult(:final metadata):
          _applyMetadata(metadata);
          messenger.showSnackBar(
            const SnackBar(content: Text('Metadata found')),
          );
        case MultiMatchScanResult(:final candidates):
          await _showCandidatePicker(ref, candidates);
        case NotFoundScanResult():
          messenger.showSnackBar(
            const SnackBar(content: Text('No matches found online')),
          );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Lookup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  Future<void> _showCandidatePicker(
    WidgetRef ref,
    List<MetadataCandidate> candidates,
  ) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final picked = await showModalBottomSheet<MetadataCandidate>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Pick a match',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: candidates.length,
                itemBuilder: (_, i) {
                  final c = candidates[i];
                  final subtitleParts = <String>[
                    if (c.subtitle != null && c.subtitle!.isNotEmpty)
                      c.subtitle!,
                    if (c.year != null) '${c.year}',
                    if (c.format != null && c.format!.isNotEmpty) c.format!,
                  ];
                  return ListTile(
                    leading: c.coverUrl != null
                        ? SizedBox(
                            width: 44,
                            height: 44,
                            child: CachedNetworkImage(
                              imageUrl: c.coverUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.image_outlined),
                          ),
                    title: Text(c.title),
                    subtitle: Text(
                      [
                        if (subtitleParts.isNotEmpty)
                          subtitleParts.join(' · '),
                        _formatSourceLabel([c.sourceApi]),
                      ].join('\n'),
                      maxLines: 2,
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(c),
                  );
                },
              ),
            ),
            Container(
              height: 1,
              color: colors.outlineVariant,
            ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _lookingUp = true);
    try {
      final repo = ref.read(metadataRepositoryProvider);
      final detail = await repo.fetchCandidateDetail(
        picked,
        widget.initial.barcode,
        widget.initial.barcodeType,
      );
      if (!mounted) return;
      if (detail != null) {
        _applyMetadata(detail);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch details')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lookup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  /// Replaces the form contents with a freshly fetched [MetadataResult]
  /// without discarding anything the user has typed where the result is
  /// silent (keeps existing field text when the result leaves the slot
  /// null).
  void _applyMetadata(MetadataResult found) {
    setState(() {
      if (found.title != null && found.title!.isNotEmpty) {
        _titleController.text = found.title!;
      }
      if (found.subtitle != null && found.subtitle!.isNotEmpty) {
        _subtitleController.text = found.subtitle!;
      }
      if (found.description != null && found.description!.isNotEmpty) {
        _descriptionController.text = found.description!;
      }
      if (found.year != null) {
        _yearController.text = found.year!.toString();
      }
      if (found.publisher != null && found.publisher!.isNotEmpty) {
        _publisherController.text = found.publisher!;
      }
      if (found.format != null && found.format!.isNotEmpty) {
        _formatController.text = found.format!;
      }
      if (found.mediaType != null) {
        _mediaType = found.mediaType!;
      }
      if (found.coverUrl != null) {
        _coverUrl = found.coverUrl;
      }
      if (found.sourceApis.isNotEmpty) {
        _sourceApis = found.sourceApis;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cover art preview
        if (_coverUrl != null) ...[
          Center(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.surfaceContainerHighest,
              ),
              child: CachedNetworkImage(
                imageUrl: _coverUrl!,
                height: 200,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => SizedBox(
                  height: 200,
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (_sourceApis.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Source: ${_formatSourceLabel(_sourceApis)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Media type selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TYPE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MediaType>(
                initialValue: _mediaType,
                decoration: const InputDecoration(labelText: 'Media Type'),
                items: MediaType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _mediaType = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Core fields
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'METADATA',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subtitleController,
                decoration: InputDecoration(
                  labelText: _subtitleLabel(_mediaType),
                ),
              ),
              if (widget.showFormatSuggestions &&
                  _mediaType == MediaType.game) ...[
                const SizedBox(height: 8),
                _SuggestionChipsRow(
                  suggestions: _platformSuggestions(),
                  onTap: (value) =>
                      setState(() => _subtitleController.text = value),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _formatController,
                      decoration: const InputDecoration(labelText: 'Format'),
                    ),
                  ),
                ],
              ),
              if (widget.showFormatSuggestions &&
                  _formatSuggestions(_mediaType).isNotEmpty) ...[
                const SizedBox(height: 8),
                _SuggestionChipsRow(
                  suggestions: _formatSuggestions(_mediaType),
                  onTap: (value) => setState(() {
                    _formatController.text = value;
                    // Drop any stale resolution when switching away from a
                    // format that carries one.
                    if (!_resolutionSuggestions(_mediaType, value)
                        .contains(_resolution)) {
                      _resolution = null;
                    }
                  }),
                ),
              ],
              if (widget.showFormatSuggestions &&
                  _resolutionSuggestions(_mediaType, _formatController.text)
                      .isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _resolutionSuggestions(
                          _mediaType, _formatController.text)
                      .map(
                        (r) => ChoiceChip(
                          label: Text(r),
                          selected: _resolution == r,
                          onSelected: (sel) => setState(
                              () => _resolution = sel ? r : null),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: 'Publisher / Studio / Label',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Online lookup button
        if (widget.enableOnlineLookup) ...[
          Consumer(
            builder: (context, ref, _) => OutlinedButton.icon(
              onPressed: _lookingUp ? null : () => _lookupOnline(ref),
              icon: _lookingUp
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.travel_explore, size: 18),
              label: Text(_lookingUp ? 'Searching…' : 'Search online'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DESCRIPTION',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Save button
        GradientButton(
          onPressed: _saving ? null : _save,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_saving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(widget.primarySaveIcon, size: 20),
              const SizedBox(width: 8),
              Text(_saving ? 'Saving…' : widget.primarySaveLabel),
            ],
          ),
        ),
        if (widget.onSaveToWishlist != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _saving ? null : _saveToWishlist,
            icon: const Icon(Icons.favorite_border, size: 18),
            label: const Text('Save to Wishlist'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ],
    );
  }
}

/// Horizontal row of tappable suggestion chips — tapping one fires
/// [onTap] with the chip's text so the caller can populate a field.
class _SuggestionChipsRow extends StatelessWidget {
  const _SuggestionChipsRow({
    required this.suggestions,
    required this.onTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: suggestions
          .map(
            (s) => ActionChip(
              label: Text(s),
              onPressed: () => onTap(s),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }
}
