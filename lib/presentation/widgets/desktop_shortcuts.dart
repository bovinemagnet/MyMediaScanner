import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/widgets/shortcuts_help_overlay.dart';

/// Wraps its [child] with desktop-only global keyboard shortcuts.
///
/// On non-desktop platforms, renders [child] unmodified.
class DesktopShortcuts extends StatelessWidget {
  const DesktopShortcuts({
    super.key,
    required this.child,
    required this.onSwitchTab,
  });

  final Widget child;

  /// Called with a branch index (0–4) to switch navigation tabs.
  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context) {
    if (!PlatformCapability.isDesktop) return child;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Ctrl+N → Scan tab (branch 1)
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            const _SwitchTabIntent(1),
        // Ctrl+F → focus search (handled by collection screen)
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            const _FocusSearchIntent(),
        // Ctrl+, → Settings tab (branch 3)
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            const _SwitchTabIntent(3),
        // F1 → Shortcuts help overlay
        const SingleActivator(LogicalKeyboardKey.f1):
            const _ShowHelpIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SwitchTabIntent: CallbackAction<_SwitchTabIntent>(
            onInvoke: (intent) {
              onSwitchTab(intent.tabIndex);
              return null;
            },
          ),
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) {
              // Dispatch a notification that the collection screen can listen for
              _SearchFocusNotification().dispatch(context);
              return null;
            },
          ),
          _ShowHelpIntent: CallbackAction<_ShowHelpIntent>(
            onInvoke: (_) {
              showDialog<void>(
                context: context,
                builder: (_) => const ShortcutsHelpOverlay(),
              );
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _SwitchTabIntent extends Intent {
  const _SwitchTabIntent(this.tabIndex);
  final int tabIndex;
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _ShowHelpIntent extends Intent {
  const _ShowHelpIntent();
}

/// Notification dispatched when Ctrl+F is pressed.
/// Collection screen listens for this to focus its search bar.
class SearchFocusNotification extends Notification {}

// ignore: library_private_types_in_public_api
class _SearchFocusNotification extends SearchFocusNotification {}
