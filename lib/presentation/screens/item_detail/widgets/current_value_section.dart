// Current-value lookup section for the item detail screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Section that fetches a marketplace price for [item] on demand.
///
/// Currently supports music items with a stored `discogs_release_id`.
/// For other media types, the button is disabled. Persists the result
/// onto the item so the value appears in collection-wide analytics too.
class CurrentValueSection extends ConsumerStatefulWidget {
  const CurrentValueSection({super.key, required this.item});

  final MediaItem item;

  @override
  ConsumerState<CurrentValueSection> createState() =>
      _CurrentValueSectionState();
}

class _CurrentValueSectionState extends ConsumerState<CurrentValueSection> {
  bool _busy = false;
  String? _statusMessage;

  bool get _supported {
    final hasReleaseId =
        widget.item.extraMetadata.containsKey('discogs_release_id');
    return widget.item.mediaType == MediaType.music && hasReleaseId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatter = NumberFormat.simpleCurrency();
    final api = ref.watch(discogsApiProvider);
    final discogsConfigured = api != null;

    final currentValue = widget.item.currentValue;
    final stamp = widget.item.currentValueAsOf;

    return Container(
      key: const Key('current-value-section'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT VALUE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  currentValue != null
                      ? formatter.format(currentValue)
                      : 'Not yet fetched',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: currentValue != null
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                OutlinedButton.icon(
                  onPressed: _supported && discogsConfigured
                      ? _runLookup
                      : null,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Look up'),
                ),
            ],
          ),
          if (stamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Checked ${_formatStamp(stamp)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          if (!_supported)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Current-value lookup is currently available for music '
                'items with a known Discogs release.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else if (!discogsConfigured)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add a Discogs token in Settings → API integrations to '
                'enable current-value lookups.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _statusMessage!,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runLookup() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    try {
      final useCase = ref.read(lookupCurrentValueUseCaseProvider);
      final price = await useCase.execute(widget.item);
      if (!mounted) return;
      setState(() {
        _statusMessage = price == null
            ? 'No marketplace listings available.'
            : '${price.numForSale} listing(s) on Discogs.';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _formatStamp(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat.yMMMd().add_jm().format(dt);
  }
}
