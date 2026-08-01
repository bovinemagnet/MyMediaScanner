// Unit tests for the shell-branch -> mobile-bottom-nav index mapping.
//
// Four of the eight router branches own a bottom-nav destination. The other
// four are reached from within one of those, and must highlight the tab they
// were entered from rather than falling back to Home.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/app_scaffold.dart';

void main() {
  group('shellIndexToMobileIndex', () {
    test('maps the four branches that own a nav destination', () {
      expect(shellIndexToMobileIndex(0), 0, reason: 'Dashboard -> Home');
      expect(shellIndexToMobileIndex(2), 1, reason: 'Scanner -> Scanner');
      expect(shellIndexToMobileIndex(1), 2, reason: 'Collection -> Library');
      expect(shellIndexToMobileIndex(5), 3, reason: 'Insights -> Insights');
    });

    test('highlights Library for Shelves, entered from the Library AppBar', () {
      expect(shellIndexToMobileIndex(3), 2);
    });

    test('highlights Scanner for Batch, entered from the scan screen', () {
      expect(shellIndexToMobileIndex(4), 1);
    });

    test('highlights Library for Rips, a library-side view', () {
      expect(shellIndexToMobileIndex(7), 2);
    });

    test('highlights Home for Settings, entered from the dashboard', () {
      expect(shellIndexToMobileIndex(6), 0);
    });

    test('highlights Library for the content branches 8-16', () {
      // Wishlist is reachable on mobile from the Library AppBar; the rest
      // are desktop-sidebar views. All of them list media, so Library is
      // the honest tab rather than Home.
      for (var branch = 8; branch <= 16; branch++) {
        expect(
          shellIndexToMobileIndex(branch),
          2,
          reason: 'branch $branch is a library-side content view',
        );
      }
    });

    test('falls back to Home for an unknown branch index', () {
      expect(shellIndexToMobileIndex(99), 0);
    });
  });

  group('shellIndexToBackBranch', () {
    test('returns null on the Dashboard so back exits the app', () {
      expect(shellIndexToBackBranch(0), isNull);
    });

    test('returns Dashboard from the other top-level tabs', () {
      expect(shellIndexToBackBranch(1), 0, reason: 'Collection -> Dashboard');
      expect(shellIndexToBackBranch(2), 0, reason: 'Scanner -> Dashboard');
      expect(shellIndexToBackBranch(5), 0, reason: 'Insights -> Dashboard');
    });

    test('returns the branch each drill-down was entered from', () {
      expect(shellIndexToBackBranch(3), 1, reason: 'Shelves -> Collection');
      expect(shellIndexToBackBranch(4), 2, reason: 'Batch -> Scanner');
      expect(shellIndexToBackBranch(6), 0, reason: 'Settings -> Dashboard');
      expect(shellIndexToBackBranch(8), 1, reason: 'Wishlist -> Collection');
      expect(
        shellIndexToBackBranch(11),
        0,
        reason: 'Wishlist suggestions -> Dashboard',
      );
    });

    test('mirrors the leading back buttons on those screens', () {
      // ShelvesScreen and WishlistScreen send their AppBar back button to
      // /collection; BatchPlaceholderScreen to /scan; SettingsScreen and
      // WishlistSuggestionsScreen to /. System back must agree, or the two
      // gestures land the user in different places.
      expect(shellIndexToBackBranch(3), shellIndexToBackBranch(8));
      expect(shellIndexToBackBranch(6), shellIndexToBackBranch(11));
    });

    test('sends the remaining library-side branches to Collection', () {
      for (final branch in [7, 9, 10, 12, 13, 14, 15, 16]) {
        expect(
          shellIndexToBackBranch(branch),
          1,
          reason: 'branch $branch is reached from the library',
        );
      }
    });

    test('falls back to Dashboard for an unknown branch index', () {
      expect(shellIndexToBackBranch(99), 0);
    });
  });
}
