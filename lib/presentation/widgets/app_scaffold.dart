import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/app/theme/app_theme_extensions.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/widgets/desktop_shortcuts.dart';
import 'package:mymediascanner/presentation/widgets/mini_player_bar.dart';
import 'package:mymediascanner/presentation/widgets/sync_badge.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  // ── Desktop sidebar destinations ───────────────────────────────────
  static const _sidebarItems = [
    _SidebarDestination(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _SidebarDestination(
        Icons.library_music_outlined, Icons.library_music, 'Library'),
    _SidebarDestination(
        Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'Scanner'),
    _SidebarDestination(Icons.view_comfy_outlined, Icons.view_comfy, 'Shelves'),
    _SidebarDestination(
        Icons.dynamic_feed_outlined, Icons.dynamic_feed, 'Batch Editor'),
    _SidebarDestination(Icons.insights_outlined, Icons.insights, 'Insights'),
    _SidebarDestination(
        Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  static const _ripsSidebarItem =
      _SidebarDestination(Icons.album_outlined, Icons.album, 'Rips');

  static const _wishlistSidebarItem = _SidebarDestination(
      Icons.favorite_border, Icons.favorite, 'Wishlist');

  static const _locationsSidebarItem = _SidebarDestination(
      Icons.place_outlined, Icons.place, 'Locations');

  static const _seriesSidebarItem = _SidebarDestination(
      Icons.collections_bookmark_outlined,
      Icons.collections_bookmark,
      'Series');

  // ── Mobile bottom nav destinations ─────────────────────────────────
  static const _mobileDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: 'Scanner',
    ),
    NavigationDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music),
      label: 'Library',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Insights',
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useSidebar = width >= AppConstants.compactBreakpoint;
    final isDesktop = PlatformCapability.isDesktop;

    Widget wrapWithShortcuts(Widget scaffold) {
      if (!isDesktop) return scaffold;
      return DesktopShortcuts(
        onSwitchTab: _onDestinationSelected,
        child: scaffold,
      );
    }

    if (useSidebar) {
      return wrapWithShortcuts(
        Scaffold(
          body: Row(
            children: [
              _DesktopSidebar(
                currentIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                showRips: isDesktop,
                showWishlist: isDesktop,
                showLocations: isDesktop,
                showSeries: isDesktop,
                isExpanded: width >= AppConstants.expandedBreakpoint,
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: navigationShell),
                    const MiniPlayerBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Desktop at narrow width — use drawer instead of bottom nav.
    if (isDesktop) {
      return wrapWithShortcuts(
        Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          drawer: Drawer(
            child: _DesktopSidebar(
              currentIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                Navigator.of(context).pop(); // close drawer
                _onDestinationSelected(index);
              },
              showRips: isDesktop,
              showWishlist: isDesktop,
              showLocations: isDesktop,
              showSeries: isDesktop,
              isExpanded: true,
            ),
          ),
          body: Column(
            children: [
              Expanded(child: navigationShell),
              const MiniPlayerBar(),
            ],
          ),
        ),
      );
    }

    // Mobile bottom nav — 4 destinations.
    // Map shell branch indices to mobile nav indices:
    // Branch 0 = Dashboard (Home), 1 = Collection (Library),
    // 2 = Scanner, 3 = Shelves, 4 = Batch, 5 = Insights, 6 = Settings, 7 = Rips
    // Mobile shows: Home(0), Scanner(2), Library(1), Insights(5)
    final mobileIndex = _shellIndexToMobileIndex(navigationShell.currentIndex);

    final design = Theme.of(context).extension<AppDesignExtension>();
    final colors = Theme.of(context).colorScheme;
    final glassBlur = design?.glassBlur ?? 12.0;
    final glassOpacity = design?.glassOpacity ?? 0.6;

    return wrapWithShortcuts(
      Scaffold(
        extendBody: true,
        body: Column(
          children: [
            Expanded(child: navigationShell),
            const MiniPlayerBar(),
          ],
        ),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
            child: NavigationBar(
              backgroundColor:
                  colors.surfaceContainerLow.withValues(alpha: glassOpacity),
              selectedIndex: mobileIndex,
              onDestinationSelected: (index) {
                _onDestinationSelected(_mobileIndexToShellIndex(index));
              },
              destinations: _mobileDestinations,
            ),
          ),
        ),
      ),
    );
  }

  int _shellIndexToMobileIndex(int shellIndex) {
    return switch (shellIndex) {
      0 => 0, // Dashboard -> Home
      1 => 2, // Collection -> Library
      2 => 1, // Scanner -> Scanner
      5 => 3, // Insights -> Insights
      _ => 0, // Default to Home
    };
  }

  int _mobileIndexToShellIndex(int mobileIndex) {
    return switch (mobileIndex) {
      0 => 0, // Home -> Dashboard
      1 => 2, // Scanner -> Scanner
      2 => 1, // Library -> Collection
      3 => 5, // Insights -> Insights
      _ => 0,
    };
  }
}

// ── Desktop sidebar ──────────────────────────────────────────────────

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.showRips,
    required this.showWishlist,
    required this.showLocations,
    required this.showSeries,
    required this.isExpanded,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool showRips;
  final bool showWishlist;
  final bool showLocations;
  final bool showSeries;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final design = theme.extension<AppDesignExtension>();

    final items = [
      ...AppScaffold._sidebarItems,
      if (showRips) AppScaffold._ripsSidebarItem,
      if (showWishlist) AppScaffold._wishlistSidebarItem,
      if (showLocations) AppScaffold._locationsSidebarItem,
      if (showSeries) AppScaffold._seriesSidebarItem,
    ];

    // Sidebar and shell branch indices are now 1:1.
    // Both: Dashboard(0), Library(1), Scanner(2), Shelves(3), Batch(4),
    //       Insights(5), Settings(6), Rips(7), Wishlist(8)
    int sidebarToShellIndex(int sidebarIndex) => sidebarIndex;

    int shellToSidebarIndex(int shellIndex) => shellIndex;

    final activeSidebarIndex = shellToSidebarIndex(currentIndex);

    return Container(
      width: isExpanded ? 220 : 72,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 20 : 12,
                vertical: 20,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dataset,
                    color: colors.primary,
                    size: 28,
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'MyMediaScanner',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Navigation items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 12 : 8,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isActive = index == activeSidebarIndex;

                  return _SidebarNavItem(
                    icon: isActive ? item.selectedIcon : item.icon,
                    label: item.label,
                    isActive: isActive,
                    isExpanded: isExpanded,
                    activeBackground:
                        design?.sidebarActiveBackground ??
                            colors.primary.withValues(alpha: 0.1),
                    activeColor: colors.primary,
                    inactiveColor: colors.onSurfaceVariant,
                    onTap: () =>
                        onDestinationSelected(sidebarToShellIndex(index)),
                  );
                },
              ),
            ),
            // Sync badge in sidebar footer
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 20 : 0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const SyncBadge(),
                  if (isExpanded) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Sync',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isExpanded,
    required this.activeBackground,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final Color activeBackground;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 0,
            ),
            decoration: isActive
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: activeColor,
                        width: 3,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination {
  const _SidebarDestination(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
