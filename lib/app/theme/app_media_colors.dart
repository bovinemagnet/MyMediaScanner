import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Theme-aware media-type colour palette.
///
/// Widgets read media colours through [BuildContext.mediaColors] rather than
/// referencing [AppColors.filmColor] etc. directly, so each theme (Classic,
/// Popcorn, future Citrus/Berry) can supply its own tuning without touching
/// call sites.
@immutable
class AppMediaColors extends ThemeExtension<AppMediaColors> {
  const AppMediaColors({
    required this.film,
    required this.tv,
    required this.music,
    required this.book,
    required this.game,
    required this.unknown,
    required this.filmSoft,
    required this.tvSoft,
    required this.musicSoft,
    required this.bookSoft,
    required this.gameSoft,
    required this.unknownSoft,
    required this.filmInk,
    required this.tvInk,
    required this.musicInk,
    required this.bookInk,
    required this.gameInk,
    required this.unknownInk,
  });

  /// Preserves the existing [AppColors] media hues. Used by the Obsidian Lens
  /// and Precision Editorial themes so migrating call sites doesn't change
  /// pixels.
  factory AppMediaColors.classic() => const AppMediaColors(
        film: AppColors.filmColor,
        tv: AppColors.tvColor,
        music: AppColors.musicColor,
        book: AppColors.bookColor,
        game: AppColors.gameColor,
        unknown: AppColors.unknownColor,
        // Soft: solid at ~0.12 alpha (0x1F = 31/255).
        filmSoft: Color(0x1FE53935),
        tvSoft: Color(0x1FFF7043),
        musicSoft: Color(0x1F7E57C2),
        bookSoft: Color(0x1F43A047),
        gameSoft: Color(0x1F1E88E5),
        unknownSoft: Color(0x1F757575),
        // Ink: dark variant for foregrounds on soft backgrounds.
        filmInk: Color(0xFF7A1C1A),
        tvInk: Color(0xFF803319),
        musicInk: Color(0xFF3E2B6B),
        bookInk: Color(0xFF1F4F24),
        gameInk: Color(0xFF0F3F6F),
        unknownInk: Color(0xFF424242),
      );

  /// Warm, saturated Popcorn palette for light backgrounds.
  factory AppMediaColors.popcorn() => const AppMediaColors(
        film: Color(0xFFFF5E3A),
        tv: Color(0xFFFF8A3D),
        music: Color(0xFFA06DFF),
        book: Color(0xFF00C478),
        game: Color(0xFF4A6CF7),
        unknown: Color(0xFF9A8F82),
        filmSoft: Color(0xFFFFE0D4),
        tvSoft: Color(0xFFFFE4CF),
        musicSoft: Color(0xFFEAD9FF),
        bookSoft: Color(0xFFC8F5DF),
        gameSoft: Color(0xFFD6DEFF),
        unknownSoft: Color(0xFFEFE2CF),
        filmInk: Color(0xFF661E10),
        tvInk: Color(0xFF66310F),
        musicInk: Color(0xFF31146B),
        bookInk: Color(0xFF0A4A2C),
        gameInk: Color(0xFF122269),
        unknownInk: Color(0xFF3A332B),
      );

  /// Popcorn palette retuned for dark surfaces.
  factory AppMediaColors.popcornDark() => const AppMediaColors(
        film: Color(0xFFFF7A5C),
        tv: Color(0xFFFFA065),
        music: Color(0xFFB48AFF),
        book: Color(0xFF2AD68F),
        game: Color(0xFF7E98FF),
        unknown: Color(0xFFB8AFA3),
        filmSoft: Color(0x33FF7A5C),
        tvSoft: Color(0x33FFA065),
        musicSoft: Color(0x33B48AFF),
        bookSoft: Color(0x332AD68F),
        gameSoft: Color(0x337E98FF),
        unknownSoft: Color(0x33B8AFA3),
        filmInk: Color(0xFFFF7A5C),
        tvInk: Color(0xFFFFA065),
        musicInk: Color(0xFFB48AFF),
        bookInk: Color(0xFF2AD68F),
        gameInk: Color(0xFF7E98FF),
        unknownInk: Color(0xFFE8DFD3),
      );

  /// Solid hue for a given media type.
  final Color film;
  final Color tv;
  final Color music;
  final Color book;
  final Color game;
  final Color unknown;

  /// Soft/tinted variant for chip backgrounds, highlights, etc.
  final Color filmSoft;
  final Color tvSoft;
  final Color musicSoft;
  final Color bookSoft;
  final Color gameSoft;
  final Color unknownSoft;

  /// Ink variant — foreground on the soft background.
  final Color filmInk;
  final Color tvInk;
  final Color musicInk;
  final Color bookInk;
  final Color gameInk;
  final Color unknownInk;

  /// Switch helpers keyed by [MediaType] for dynamic lookups.
  Color solidFor(MediaType type) => switch (type) {
        MediaType.film => film,
        MediaType.tv => tv,
        MediaType.music => music,
        MediaType.book => book,
        MediaType.game => game,
        MediaType.unknown => unknown,
      };

  Color softFor(MediaType type) => switch (type) {
        MediaType.film => filmSoft,
        MediaType.tv => tvSoft,
        MediaType.music => musicSoft,
        MediaType.book => bookSoft,
        MediaType.game => gameSoft,
        MediaType.unknown => unknownSoft,
      };

  Color inkFor(MediaType type) => switch (type) {
        MediaType.film => filmInk,
        MediaType.tv => tvInk,
        MediaType.music => musicInk,
        MediaType.book => bookInk,
        MediaType.game => gameInk,
        MediaType.unknown => unknownInk,
      };

  // ── ThemeExtension contract ────────────────────────────────────────

  @override
  AppMediaColors copyWith({
    Color? film,
    Color? tv,
    Color? music,
    Color? book,
    Color? game,
    Color? unknown,
    Color? filmSoft,
    Color? tvSoft,
    Color? musicSoft,
    Color? bookSoft,
    Color? gameSoft,
    Color? unknownSoft,
    Color? filmInk,
    Color? tvInk,
    Color? musicInk,
    Color? bookInk,
    Color? gameInk,
    Color? unknownInk,
  }) {
    return AppMediaColors(
      film: film ?? this.film,
      tv: tv ?? this.tv,
      music: music ?? this.music,
      book: book ?? this.book,
      game: game ?? this.game,
      unknown: unknown ?? this.unknown,
      filmSoft: filmSoft ?? this.filmSoft,
      tvSoft: tvSoft ?? this.tvSoft,
      musicSoft: musicSoft ?? this.musicSoft,
      bookSoft: bookSoft ?? this.bookSoft,
      gameSoft: gameSoft ?? this.gameSoft,
      unknownSoft: unknownSoft ?? this.unknownSoft,
      filmInk: filmInk ?? this.filmInk,
      tvInk: tvInk ?? this.tvInk,
      musicInk: musicInk ?? this.musicInk,
      bookInk: bookInk ?? this.bookInk,
      gameInk: gameInk ?? this.gameInk,
      unknownInk: unknownInk ?? this.unknownInk,
    );
  }

  @override
  AppMediaColors lerp(
      covariant ThemeExtension<AppMediaColors>? other, double t) {
    if (other is! AppMediaColors) return this;
    return AppMediaColors(
      film: Color.lerp(film, other.film, t)!,
      tv: Color.lerp(tv, other.tv, t)!,
      music: Color.lerp(music, other.music, t)!,
      book: Color.lerp(book, other.book, t)!,
      game: Color.lerp(game, other.game, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
      filmSoft: Color.lerp(filmSoft, other.filmSoft, t)!,
      tvSoft: Color.lerp(tvSoft, other.tvSoft, t)!,
      musicSoft: Color.lerp(musicSoft, other.musicSoft, t)!,
      bookSoft: Color.lerp(bookSoft, other.bookSoft, t)!,
      gameSoft: Color.lerp(gameSoft, other.gameSoft, t)!,
      unknownSoft: Color.lerp(unknownSoft, other.unknownSoft, t)!,
      filmInk: Color.lerp(filmInk, other.filmInk, t)!,
      tvInk: Color.lerp(tvInk, other.tvInk, t)!,
      musicInk: Color.lerp(musicInk, other.musicInk, t)!,
      bookInk: Color.lerp(bookInk, other.bookInk, t)!,
      gameInk: Color.lerp(gameInk, other.gameInk, t)!,
      unknownInk: Color.lerp(unknownInk, other.unknownInk, t)!,
    );
  }
}

/// Ergonomic accessor: `context.mediaColors.film` instead of
/// `Theme.of(context).extension<AppMediaColors>()`.
///
/// Falls back to [AppMediaColors.classic] when the current theme has no
/// [AppMediaColors] extension registered. This keeps widgets readable in
/// tests that pump a bare [MaterialApp] without an app theme, and guards
/// against any future theme that forgets to register the extension.
extension AppMediaColorsContext on BuildContext {
  AppMediaColors get mediaColors =>
      Theme.of(this).extension<AppMediaColors>() ?? AppMediaColors.classic();
}
