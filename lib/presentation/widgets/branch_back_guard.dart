import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/widgets/app_scaffold.dart';

/// Sends the Android back gesture to the branch a screen was entered from,
/// instead of letting it close the app.
///
/// Wraps the *root* screen of each `StatefulShellBranch`. Every branch roots
/// its own navigator, so once a branch's nested routes have popped there is
/// nothing left to pop and back would otherwise fall through to
/// `SystemNavigator.pop()` — closing the app from Settings, Shelves,
/// Wishlist and the rest.
///
/// This has to sit *inside* the branch. An earlier attempt put the same
/// `PopScope` around the shell in `AppScaffold`; on an Android 16 device
/// its callback was never invoked once and back closed the app anyway.
/// Moving it in-branch fixed it. The difference only shows up on the
/// `OnBackInvokedCallback` path that Android 15+ uses by default — on the
/// legacy pop channel (and so in widget tests) a shell-level guard is
/// consulted quite happily, which is why this was merged looking correct.
/// In-branch works on both paths.
///
/// Nested routes (item detail, shelf detail) are unaffected: their branch
/// navigator pops them before the guard is reached.
class BranchBackGuard extends StatelessWidget {
  const BranchBackGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shell = StatefulNavigationShell.of(context);
    final backBranch = shellIndexToBackBranch(shell.currentIndex);
    return PopScope(
      canPop: backBranch == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || backBranch == null) return;
        shell.goBranch(backBranch);
      },
      child: child,
    );
  }
}
