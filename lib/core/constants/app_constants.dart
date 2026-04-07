abstract final class AppConstants {
  static const appName = 'MyMediaScanner';
  static const databaseName = 'mymediascanner.db';
  static const githubUrl = 'https://github.com/bovinemagnet/MyMediaScanner';

  // Rating
  static const minRating = 1.0;
  static const maxRating = 5.0;

  // Breakpoints (Material 3)
  static const compactBreakpoint = 600.0;
  static const mediumBreakpoint = 900.0;
  static const expandedBreakpoint = 1200.0;

  // Sync
  static const defaultPostgresPort = 5432;

  // Desktop window
  static const minWindowWidth = 800.0;
  static const minWindowHeight = 600.0;

  // Disambiguation
  static const maxCandidates = 5;
}
