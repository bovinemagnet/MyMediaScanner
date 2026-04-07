import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

/// Wraps its [child] with keyboard navigation for table/list views.
///
/// On non-desktop platforms, renders [child] unmodified.
class TableKeyboardNavigation extends StatefulWidget {
  const TableKeyboardNavigation({
    super.key,
    required this.child,
    required this.onMoveUp,
    required this.onMoveDown,
    this.onMoveToFirst,
    this.onMoveToLast,
    this.onSelect,
    this.onDelete,
    this.onClearSelection,
    this.autofocus = true,
  });

  final Widget child;

  /// Called when the up arrow key is pressed.
  final VoidCallback onMoveUp;

  /// Called when the down arrow key is pressed.
  final VoidCallback onMoveDown;

  /// Called when the Home key is pressed.
  final VoidCallback? onMoveToFirst;

  /// Called when the End key is pressed.
  final VoidCallback? onMoveToLast;

  /// Called when Enter is pressed on the selected row.
  final VoidCallback? onSelect;

  /// Called when Delete or Backspace is pressed on the selected row.
  final VoidCallback? onDelete;

  /// Called when Escape is pressed to clear the current selection.
  final VoidCallback? onClearSelection;

  /// Whether the widget should request focus when mounted.
  final bool autofocus;

  @override
  State<TableKeyboardNavigation> createState() =>
      _TableKeyboardNavigationState();
}

class _TableKeyboardNavigationState extends State<TableKeyboardNavigation> {
  final _focusNode = FocusNode(debugLabel: 'TableKeyboardNavigation');

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformCapability.isDesktop) return widget.child;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _MoveUpIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _MoveDownIntent(),
        const SingleActivator(LogicalKeyboardKey.home):
            const _MoveToFirstIntent(),
        const SingleActivator(LogicalKeyboardKey.end):
            const _MoveToLastIntent(),
        const SingleActivator(LogicalKeyboardKey.enter):
            const _SelectIntent(),
        const SingleActivator(LogicalKeyboardKey.delete):
            const _DeleteIntent(),
        const SingleActivator(LogicalKeyboardKey.backspace):
            const _DeleteIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const _ClearSelectionIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveUpIntent: CallbackAction<_MoveUpIntent>(
            onInvoke: (_) {
              widget.onMoveUp();
              return null;
            },
          ),
          _MoveDownIntent: CallbackAction<_MoveDownIntent>(
            onInvoke: (_) {
              widget.onMoveDown();
              return null;
            },
          ),
          _MoveToFirstIntent: CallbackAction<_MoveToFirstIntent>(
            onInvoke: (_) {
              widget.onMoveToFirst?.call();
              return null;
            },
          ),
          _MoveToLastIntent: CallbackAction<_MoveToLastIntent>(
            onInvoke: (_) {
              widget.onMoveToLast?.call();
              return null;
            },
          ),
          _SelectIntent: CallbackAction<_SelectIntent>(
            onInvoke: (_) {
              widget.onSelect?.call();
              return null;
            },
          ),
          _DeleteIntent: CallbackAction<_DeleteIntent>(
            onInvoke: (_) {
              widget.onDelete?.call();
              return null;
            },
          ),
          _ClearSelectionIntent: CallbackAction<_ClearSelectionIntent>(
            onInvoke: (_) {
              widget.onClearSelection?.call();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: widget.child,
        ),
      ),
    );
  }
}

class _MoveUpIntent extends Intent {
  const _MoveUpIntent();
}

class _MoveDownIntent extends Intent {
  const _MoveDownIntent();
}

class _MoveToFirstIntent extends Intent {
  const _MoveToFirstIntent();
}

class _MoveToLastIntent extends Intent {
  const _MoveToLastIntent();
}

class _SelectIntent extends Intent {
  const _SelectIntent();
}

class _DeleteIntent extends Intent {
  const _DeleteIntent();
}

class _ClearSelectionIntent extends Intent {
  const _ClearSelectionIntent();
}
