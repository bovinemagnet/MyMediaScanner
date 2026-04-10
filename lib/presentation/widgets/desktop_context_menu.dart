import 'package:flutter/material.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

/// An action displayed in a desktop right-click context menu.
class ContextMenuAction {
  const ContextMenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// Wraps its [child] with a secondary-tap (right-click) context menu
/// on desktop platforms. On mobile, renders [child] unmodified.
class DesktopContextMenu extends StatelessWidget {
  const DesktopContextMenu({
    super.key,
    required this.actions,
    required this.child,
  });

  final List<ContextMenuAction> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!PlatformCapability.isDesktop || actions.isEmpty) {
      return child;
    }

    return GestureDetector(
      onSecondaryTapUp: (details) =>
          showDesktopContextMenu(context, details.globalPosition, actions),
      child: child,
    );
  }
}

/// Shows a desktop right-click context menu at [position] with the given
/// [actions]. Safe to call from any widget — it's a no-op if [actions] is
/// empty or no overlay is available.
void showDesktopContextMenu(
  BuildContext context,
  Offset position,
  List<ContextMenuAction> actions,
) {
  if (actions.isEmpty) return;
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;

  showMenu<void>(
    context: context,
    position: RelativeRect.fromRect(
      position & const Size(1, 1),
      Offset.zero & overlay.size,
    ),
    items: actions
        .map(
          (action) => PopupMenuItem<void>(
            onTap: action.onTap,
            child: Row(
              children: [
                Icon(action.icon, size: 18),
                const SizedBox(width: 12),
                Text(action.label),
              ],
            ),
          ),
        )
        .toList(),
  );
}
