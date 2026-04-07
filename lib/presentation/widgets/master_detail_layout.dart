import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/split_ratio_provider.dart';

/// A generic master-detail split layout for desktop.
///
/// When [detail] is non-null, the screen width is >= 900 px, and we are on
/// a desktop platform, renders [master] and [detail] side-by-side with a
/// resizable vertical divider. Otherwise renders only [master].
class MasterDetailLayout extends ConsumerStatefulWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.masterMinWidth = 400,
    this.detailMinWidth = 300,
  });

  /// The primary content (list, grid, etc.).
  final Widget master;

  /// The detail panel shown beside [master] on wide desktop windows.
  /// Pass `null` when nothing is selected.
  final Widget? detail;

  /// Minimum width reserved for the master pane.
  final double masterMinWidth;

  /// Minimum width reserved for the detail pane.
  final double detailMinWidth;

  @override
  ConsumerState<MasterDetailLayout> createState() =>
      _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends ConsumerState<MasterDetailLayout> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showDetail = PlatformCapability.isDesktop &&
        widget.detail != null &&
        width >= AppConstants.mediumBreakpoint;

    if (!showDetail) return widget.master;

    final ratio = ref.watch(splitRatioProvider);

    // Calculate master width from ratio, respecting minimum constraints.
    final masterMinRatio = widget.masterMinWidth / width;
    final detailMinRatio = (width - widget.detailMinWidth) / width;
    final clampedRatio = ratio.clamp(masterMinRatio, detailMinRatio);
    final masterWidth = (width * clampedRatio).clamp(
      widget.masterMinWidth,
      width - widget.detailMinWidth,
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: masterWidth,
          child: widget.master,
        ),
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              final newRatio =
                  (masterWidth + details.delta.dx) / width;
              final clamped = newRatio.clamp(
                widget.masterMinWidth / width,
                (width - widget.detailMinWidth) / width,
              );
              ref.read(splitRatioProvider.notifier).setRatio(clamped);
            },
            onHorizontalDragEnd: (_) {
              // Ratio is already persisted on each setRatio call;
              // this callback kept for potential future debouncing.
            },
            child: SizedBox(
              width: 8,
              child: Center(
                child: Container(
                  width: 2,
                  color: _isHovering
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.outlineVariant
                          .withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.detail!),
      ],
    );
  }
}
