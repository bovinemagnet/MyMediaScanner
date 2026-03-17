import 'package:flutter/material.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

/// A generic master-detail split layout for desktop.
///
/// When [detail] is non-null, the screen width is ≥ 900 px, and we are on
/// a desktop platform, renders [master] and [detail] side-by-side with a
/// vertical divider. Otherwise renders only [master].
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.masterMinWidth = 400,
  });

  /// The primary content (list, grid, etc.).
  final Widget master;

  /// The detail panel shown beside [master] on wide desktop windows.
  /// Pass `null` when nothing is selected.
  final Widget? detail;

  /// Minimum width reserved for the master pane.
  final double masterMinWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showDetail = PlatformCapability.isDesktop &&
        detail != null &&
        width >= AppConstants.mediumBreakpoint;

    if (!showDetail) return master;

    return Row(
      children: [
        SizedBox(
          width: width * 0.45 < masterMinWidth
              ? masterMinWidth
              : width * 0.45,
          child: master,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: detail!),
      ],
    );
  }
}
