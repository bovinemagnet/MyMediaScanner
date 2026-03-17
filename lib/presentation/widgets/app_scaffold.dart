import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/widgets/desktop_shortcuts.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music),
      label: 'Collection',
    ),
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: 'Scan',
    ),
    NavigationDestination(
      icon: Icon(Icons.view_comfy_outlined),
      selectedIcon: Icon(Icons.view_comfy),
      label: 'Shelves',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  static const _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music),
      label: Text('Collection'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: Text('Scan'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.view_comfy_outlined),
      selectedIcon: Icon(Icons.view_comfy),
      label: Text('Shelves'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  static const _ripsRailDestination = NavigationRailDestination(
    icon: Icon(Icons.album_outlined),
    selectedIcon: Icon(Icons.album),
    label: Text('Rips'),
  );

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= AppConstants.compactBreakpoint;
    final isDesktop = PlatformCapability.isDesktop;

    Widget wrapWithShortcuts(Widget scaffold) {
      if (!isDesktop) return scaffold;
      return DesktopShortcuts(
        onSwitchTab: _onDestinationSelected,
        child: scaffold,
      );
    }

    if (useRail) {
      // On desktop, include the Rips destination in the rail.
      final destinations = [
        ..._railDestinations,
        if (isDesktop) _ripsRailDestination,
      ];

      // If on mobile (non-desktop) and the shell is on the rips branch
      // (index 4), redirect to collection (index 0).
      final currentIndex = (!isDesktop && navigationShell.currentIndex >= 4)
          ? 0
          : navigationShell.currentIndex;

      return wrapWithShortcuts(
        Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: _onDestinationSelected,
                labelType: width >= AppConstants.expandedBreakpoint
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.selected,
                destinations: destinations,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    }

    // Mobile bottom nav — always 4 destinations, never show Rips.
    // If somehow on rips branch (index 4), clamp to 0.
    final mobileIndex = navigationShell.currentIndex >= 4
        ? 0
        : navigationShell.currentIndex;

    return wrapWithShortcuts(
      Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: mobileIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: _destinations,
        ),
      ),
    );
  }
}
