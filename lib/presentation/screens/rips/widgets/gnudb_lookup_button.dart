/// Icon button that triggers a GnuDB metadata lookup for a rip album.
///
/// Placed in the rip album detail dialog beside the edit and close
/// actions. The button is disabled when the album has no CUE sheet or
/// is a multi-disc set, since both are preconditions for a per-disc
/// CDDB Disc ID lookup.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/gnudb_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/gnudb_candidate_picker_dialog.dart';

class GnudbLookupButton extends ConsumerStatefulWidget {
  const GnudbLookupButton({
    super.key,
    required this.album,
  });

  final RipAlbum album;

  @override
  ConsumerState<GnudbLookupButton> createState() =>
      _GnudbLookupButtonState();
}

class _GnudbLookupButtonState extends ConsumerState<GnudbLookupButton> {
  GnudbLookupStatus? _lastSeenStatus;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gnudbLookupNotifierProvider);
    _handleStateChanges(state);

    final isBusy = state.status == GnudbLookupStatus.computing ||
        state.status == GnudbLookupStatus.fetching ||
        state.status == GnudbLookupStatus.applying;

    final disabledReason = _disabledReason();
    final onPressed = (disabledReason != null || isBusy)
        ? null
        : () => _start();

    if (isBusy) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.cloud_download_outlined, size: 20),
      tooltip: disabledReason ?? 'Look up on GnuDB',
      onPressed: onPressed,
    );
  }

  String? _disabledReason() {
    if (widget.album.cueFilePath == null) {
      return 'GnuDB needs a CUE sheet (none found for this album)';
    }
    if (widget.album.discCount != 1) {
      return 'GnuDB lookup is per-disc; multi-disc sets are not supported';
    }
    return null;
  }

  Future<void> _start() async {
    final tracks =
        ref.read(ripTracksProvider(widget.album.id)).value ?? const [];
    if (tracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracks not loaded yet — try again')),
      );
      return;
    }
    final notifier = ref.read(gnudbLookupNotifierProvider.notifier);
    notifier.reset();
    await notifier.lookup(widget.album, tracks);
  }

  /// Reacts to state transitions into terminal states (complete, noMatch,
  /// error) and to ambiguous (opens the picker dialog). Uses
  /// _lastSeenStatus to fire side effects only on transitions.
  void _handleStateChanges(GnudbLookupState state) {
    if (state.status == _lastSeenStatus) return;
    _lastSeenStatus = state.status;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      switch (state.status) {
        case GnudbLookupStatus.ambiguous:
          final selected = await showGnudbCandidatePicker(
            context: context,
            candidates: state.candidates,
          );
          if (!mounted) return;
          if (selected != null) {
            final tracks = ref
                    .read(ripTracksProvider(widget.album.id))
                    .value ??
                const [];
            await ref
                .read(gnudbLookupNotifierProvider.notifier)
                .selectCandidate(widget.album, tracks, selected);
          } else {
            ref.read(gnudbLookupNotifierProvider.notifier).reset();
          }
        case GnudbLookupStatus.complete:
          final updated = state.outcome?.tracksUpdated ?? 0;
          final created = state.outcome?.mediaItemCreated ?? false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                created
                    ? 'Metadata applied from GnuDB. $updated tracks updated and added to collection.'
                    : 'Metadata applied from GnuDB. $updated tracks updated.',
              ),
            ),
          );
          ref.read(gnudbLookupNotifierProvider.notifier).reset();
        case GnudbLookupStatus.noMatch:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('GnuDB found no match for this disc')),
          );
          ref.read(gnudbLookupNotifierProvider.notifier).reset();
        case GnudbLookupStatus.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'GnuDB lookup failed: ${state.error ?? 'unknown error'}'),
            ),
          );
          ref.read(gnudbLookupNotifierProvider.notifier).reset();
        case GnudbLookupStatus.idle:
        case GnudbLookupStatus.computing:
        case GnudbLookupStatus.fetching:
        case GnudbLookupStatus.applying:
          // Transient states — no side effect.
          break;
      }
    });
  }
}
