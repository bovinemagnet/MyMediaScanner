import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/app/theme/app_layout_extension.dart';
import 'package:mymediascanner/app/theme/app_theme_extensions.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
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

  static const _wishlistSuggestionsSidebarItem = _SidebarDestination(
      Icons.tips_and_updates_outlined,
      Icons.tips_and_updates,
      'Suggestions');

  static const _tmdbWatchlistSidebarItem = _SidebarDestination(
      Icons.bookmarks_outlined, Icons.bookmarks, 'Watchlist');

  static const _tmdbRatedSidebarItem = _SidebarDestination(
      Icons.star_border, Icons.star, 'TMDB Rated');

  static const _tmdbFavouritesSidebarItem = _SidebarDestination(
      Icons.favorite_border_outlined, Icons.favorite_outlined, 'Favourites');

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
                showSuggestions: isDesktop,
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
              showSuggestions: isDesktop,
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
    final useFloatingNav = context.layoutFlags.floatingNavBar;

    final bottomNav = useFloatingNav
        ? _FloatingPillNav(
            selectedIndex: mobileIndex,
            onSelected: (index) {
              _onDestinationSelected(_mobileIndexToShellIndex(index));
            },
          )
        : ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
              child: NavigationBar(
                backgroundColor: colors.surfaceContainerLow
                    .withValues(alpha: glassOpacity),
                selectedIndex: mobileIndex,
                onDestinationSelected: (index) {
                  _onDestinationSelected(_mobileIndexToShellIndex(index));
                },
                destinations: _mobileDestinations,
              ),
            ),
          );

    return wrapWithShortcuts(
      Scaffold(
        extendBody: true,
        body: Column(
          children: [
            Expanded(child: navigationShell),
            const MiniPlayerBar(),
          ],
        ),
        bottomNavigationBar: bottomNav,
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

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.showRips,
    required this.showWishlist,
    required this.showLocations,
    required this.showSeries,
    required this.showSuggestions,
    required this.isExpanded,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool showRips;
  final bool showWishlist;
  final bool showLocations;
  final bool showSeries;
  final bool showSuggestions;
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final design = theme.extension<AppDesignExtension>();

    final connectionAsync = ref.watch(tmdbAccountConnectionProvider);
    final isTmdbConnected =
        PlatformCapability.isDesktop &&
        connectionAsync.value is TmdbConnected;

    final items = [
      ...AppScaffold._sidebarItems,
      if (showRips) AppScaffold._ripsSidebarItem,
      if (showWishlist) AppScaffold._wishlistSidebarItem,
      if (showLocations) AppScaffold._locationsSidebarItem,
      if (showSeries) AppScaffold._seriesSidebarItem,
      if (showSuggestions) AppScaffold._wishlistSuggestionsSidebarItem,
      if (isTmdbConnected) AppScaffold._tmdbWatchlistSidebarItem,
      if (isTmdbConnected) AppScaffold._tmdbRatedSidebarItem,
      if (isTmdbConnected) AppScaffold._tmdbFavouritesSidebarItem,
    ];

    // Sidebar and shell branch indices are 1:1.
    // Dashboard(0), Library(1), Scanner(2), Shelves(3), Batch(4),
    // Insights(5), Settings(6), Rips(7), Wishlist(8), Locations(9),
    // Series(10), Suggestions(11), Watchlist(12), Rated(13), Favourites(14)
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

/// Rounded-pill bottom nav used by the Popcorn layout. Four destinations
/// with the Scanner entry rendered as a raised centre FAB.
class _FloatingPillNav extends StatelessWidget {
  const _FloatingPillNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Mobile-nav index of the currently selected destination:
  /// 0 = Home, 1 = Scanner, 2 = Library, 3 = Insights.
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _PillNavSlot(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                active: selectedIndex == 0,
                onTap: () => onSelected(0),
                activeColor: colors.primary,
                inactiveColor: colors.onSurfaceVariant,
              ),
              _PillNavFab(
                active: selectedIndex == 1,
                background: colors.primary,
                foreground: colors.onPrimary,
                onTap: () => onSelected(1),
              ),
              _PillNavSlot(
                icon: Icons.library_music_outlined,
                selectedIcon: Icons.library_music,
                label: 'Library',
                active: selectedIndex == 2,
                onTap: () => onSelected(2),
                activeColor: colors.primary,
                inactiveColor: colors.onSurfaceVariant,
              ),
              _PillNavSlot(
                icon: Icons.insights_outlined,
                selectedIcon: Icons.insights,
                label: 'Insights',
                active: selectedIndex == 3,
                onTap: () => onSelected(3),
                activeColor: colors.primary,
                inactiveColor: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillNavSlot extends StatelessWidget {
  const _PillNavSlot({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillNavFab extends StatelessWidget {
  const _PillNavFab({
    required this.active,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final bool active;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Center(
        child: Semantics(
          button: true,
          selected: active,
          label: 'Scanner',
          child: Material(
            color: background,
            shape: const CircleBorder(),
            elevation: 6,
            shadowColor: background.withValues(alpha: 0.45),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(
                  Icons.qr_code_scanner,
                  color: foreground,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
