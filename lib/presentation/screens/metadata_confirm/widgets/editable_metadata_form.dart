import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/presentation/widgets/gradient_button.dart';

class EditableMetadataForm extends StatefulWidget {
  const EditableMetadataForm({
    super.key,
    required this.initial,
    required this.onSave,
    this.onSaveToWishlist,
    this.primarySaveLabel = 'Save to Collection',
    this.primarySaveIcon = Icons.save,
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

  /// Contextual label for the "subtitle" slot — a single string on
  /// `MediaItem` that carries different semantics per media type:
  /// artist for music, author for books, platform for games, etc.
  String _subtitleLabel(MediaType type) => switch (type) {
        MediaType.music => 'Artist',
        MediaType.book => 'Author',
        MediaType.game => 'Platform',
        _ => 'Subtitle',
      };

  MetadataResult _buildEdited() => widget.initial.copyWith(
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
  );

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cover art preview
        if (widget.initial.coverUrl != null) ...[
          Center(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.surfaceContainerHighest,
              ),
              child: CachedNetworkImage(
                imageUrl: widget.initial.coverUrl!,
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

        if (widget.initial.sourceApis.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Source: ${_formatSourceLabel(widget.initial.sourceApis)}',
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
              Text(_saving ? 'Saving\u2026' : widget.primarySaveLabel),
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
