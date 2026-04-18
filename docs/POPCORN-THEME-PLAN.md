# Popcorn Theme — Implementation Plan

**Status:** Implemented (closes issue #55). Kept as historical context — the as-built architecture is described under "Design System" in `CLAUDE.md`.
**Target:** Additive — adds a vibrant "Popcorn" theme (light + dark) alongside the existing Obsidian Lens (dark) and Precision Editorial (light) themes. No existing behaviour is removed.
**Companion prototype:** `My Media Scanner.html` in the design project — open to see the target look, interact with scanner/detail flows, toggle palettes (Popcorn / Citrus / Berry) and compare light+dark.

---

## Decisions (from §15 questions)

1. **Existing themes** — may be tweaked where `AppMediaColors` integration surfaces inconsistencies.
2. **Space Grotesk numerals** — acceptable to add; implemented as `AppTypography.displayNumeric()` using Manrope ExtraBold by default (swap `fontFamily` when the `.ttf` files are dropped into `assets/fonts/`).
3. **`ThemeExtension` strategy** — kept the separate-file convention (`AppDesignExtension`, `AppMediaColors`, `AppLayoutExtension`) so future palettes (Citrus, Berry) drop in as factories.
4. **WCAG AA on Popcorn coral** — accepted the saturated `#FF5E3A`; CTA labels use Manrope weight 700 ≥ 14pt so they qualify as large text.
5. **Scope** — shipped Core + §10 polish in one pass (not three separate PRs).

---

## 1. Goals

1. Offer users a **vibrant, friendly** alternative to the editorial Obsidian Lens / Precision Editorial themes.
2. Keep the existing per-media-type colour semantics (film/music/book/game/tv) but retune saturation and pair them with a warmer neutral stack.
3. Introduce a **per-media-type theme extension** (`AppMediaColors`) so widgets stop reading `AppColors.filmColor` directly — that static lookup becomes a theme-aware one. This unlocks future palettes (Citrus, Berry) without rewrites.
4. No visual regressions to the existing two themes. Every widget must still render correctly under Obsidian Lens and Precision Editorial.

---

## 2. Deliverables

- [ ] Extend `AppColors` with a `popcorn*` token block (light + dark).
- [ ] New file `lib/app/theme/app_media_colors.dart` — `ThemeExtension<AppMediaColors>` with `film/tv/music/book/game` + their soft/ink variants.
- [ ] Register `AppMediaColors` on **all three** themes (Obsidian, Precision, Popcorn) so existing widgets migrating to `Theme.of(context).extension<AppMediaColors>()` keep working on every theme.
- [ ] New file `lib/app/theme/app_shapes.dart` — radius + elevation tokens.
- [ ] Extend `AppTheme` with `popcornLight()` and `popcornDark()` builders.
- [ ] Extend the `AppTheme` enum (currently `system | light | dark` per SET-07) with `popcornLight | popcornDark`, plus a "theme family" concept so the user can pick "Popcorn" and still honour `system` for light/dark.
- [ ] Update the Settings → Theme picker UI (SettingsScreen) to expose the new options with a thumbnail preview swatch.
- [ ] Migrate all call sites that read `AppColors.filmColor` etc. to use the theme extension — list in §7.
- [ ] Snapshot/golden tests updated or regenerated for the three themes.

---

## 3. Design Tokens — Popcorn palette

### 3.1 Light — "Popcorn"
Warm ivory surfaces, coral primary, mint secondary. Saturated but not neon.

| Token | Hex | Role |
|---|---|---|
| `popcornSurface` | `#FFF6EC` | page background |
| `popcornSurfaceDim` | `#FBE9D2` | deeper bg for nav rails |
| `popcornSurfaceContainerLowest` | `#FFFFFFFF` | cards |
| `popcornSurfaceContainerLow` | `#FBE9D2` | inset wells |
| `popcornSurfaceContainer` | `#F5E6D0` | tonal surface |
| `popcornSurfaceContainerHigh` | `#EFDCC2` | hovered surface |
| `popcornSurfaceContainerHighest` | `#E8D3B4` | pressed surface |
| `popcornPrimary` | `#FF5E3A` | coral — buttons, FAB, accents |
| `popcornOnPrimary` | `#FFFFFF` | |
| `popcornPrimaryContainer` | `#FFE0D4` | |
| `popcornOnPrimaryContainer` | `#661E10` | |
| `popcornSecondary` | `#00C4B8` | mint — success, secondary chips |
| `popcornOnSecondary` | `#FFFFFF` | |
| `popcornSecondaryContainer` | `#C6F2EE` | |
| `popcornTertiary` | `#4A6CF7` | periwinkle — links, info |
| `popcornOnTertiary` | `#FFFFFF` | |
| `popcornTertiaryContainer` | `#D6DEFF` | |
| `popcornOnSurface` | `#1D1A17` | ink |
| `popcornOnSurfaceVariant` | `#5A5149` | soft ink |
| `popcornOutline` | `#EFE2CF` | rules, borders |
| `popcornOutlineVariant` | `#E0CFB3` | |
| `popcornError` | `#E53946` | keep red slightly off-primary |
| `popcornErrorContainer` | `#FFD9DE` | |

### 3.2 Dark — "Popcorn Dark"
Warm charcoal (not pure black) + same saturated accents; ink stays warm ivory.

| Token | Hex | Role |
|---|---|---|
| `popcornDarkSurface` | `#161416` | |
| `popcornDarkSurfaceDim` | `#0E0D0F` | |
| `popcornDarkSurfaceContainerLowest` | `#0A090B` | |
| `popcornDarkSurfaceContainerLow` | `#1A171A` | |
| `popcornDarkSurfaceContainer` | `#201E22` | cards |
| `popcornDarkSurfaceContainerHigh` | `#2A272B` | |
| `popcornDarkSurfaceContainerHighest` | `#342F34` | |
| `popcornDarkPrimary` | `#FF7A5C` | slightly lifted coral for dark contrast |
| `popcornDarkOnPrimary` | `#4D140A` | |
| `popcornDarkPrimaryContainer` | `#7A2414` | |
| `popcornDarkOnPrimaryContainer` | `#FFD5C5` | |
| `popcornDarkSecondary` | `#2FDAD0` | |
| `popcornDarkTertiary` | `#8AA0FF` | |
| `popcornDarkOnSurface` | `#F8F4EE` | |
| `popcornDarkOnSurfaceVariant` | `#B8AFA3` | |
| `popcornDarkOutline` | `#2D2A2E` | |
| `popcornDarkOutlineVariant` | `#3E3A3F` | |
| `popcornDarkError` | `#FF8A92` | |

### 3.3 Media-type colours (retuned for Popcorn)
These pair better with the warm neutrals than the current `AppColors.filmColor` etc. Keep the existing constants untouched (backwards compatible), but add these and reference them via `AppMediaColors.popcorn()`.

| Media | Solid (light) | Soft | Ink | Solid (dark) |
|---|---|---|---|---|
| Film | `#FF5E3A` | `#FFE0D4` | `#661E10` | `#FF7A5C` |
| TV | `#FF8A3D` | `#FFE4CF` | `#66310F` | `#FFA065` |
| Music | `#A06DFF` | `#EAD9FF` | `#31146B` | `#B48AFF` |
| Book | `#00C478` | `#C8F5DF` | `#0A4A2C` | `#2AD68F` |
| Game | `#4A6CF7` | `#D6DEFF` | `#122269` | `#7E98FF` |

For Obsidian Lens and Precision Editorial, build `AppMediaColors.obsidian()` and `AppMediaColors.precisionEditorial()` factories that return the **existing** `AppColors.filmColor` etc. — no visual change to those themes.

---

## 4. Shape tokens (`app_shapes.dart`)

Popcorn leans on chunkier radii than the existing themes. Expose as constants so the other themes can opt in later without copy-paste.

```dart
abstract final class AppShapes {
  // Radii
  static const double radiusXs = 6;     // tiny chips, badges
  static const double radiusSm = 10;    // covers, small cards
  static const double radiusMd = 14;    // medium cards
  static const double radiusLg = 20;    // big cards, sheets
  static const double radiusXl = 24;    // hero cards
  static const double radiusPill = 100; // chips, FAB

  // Elevations (all semantic — M3 uses tonal elevation)
  static const double elevCard = 0;
  static const double elevHover = 1;
  static const double elevSheet = 3;
  static const double elevModal = 6;

  // Radius shortcuts
  static const cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
  );
  static const heroShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
  );
  static const coverShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
  );
}
```

Only the Popcorn theme sets these as `cardTheme.shape` etc. Obsidian and Precision keep their current shapes.

---

## 5. File plan

### 5.1 New files

```
lib/app/theme/app_media_colors.dart    # ThemeExtension<AppMediaColors>
lib/app/theme/app_shapes.dart          # radius + elevation tokens
lib/app/theme/popcorn_theme.dart       # ThemeData builders popcornLight/popcornDark
```

### 5.2 Modified files

```
lib/app/theme/app_colors.dart          # add popcorn* tokens (append, don't touch existing)
lib/app/theme/app_theme.dart           # register AppMediaColors on all themes; add popcorn factories
lib/presentation/providers/settings_provider.dart  # extend ThemeMode-style enum
lib/presentation/screens/settings/*.dart           # theme picker UI update
```

### 5.3 Call-site migrations (see §7)

---

## 6. `AppMediaColors` extension — shape

```dart
// lib/app/theme/app_media_colors.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppMediaColors extends ThemeExtension<AppMediaColors> {
  final Color film, tv, music, book, game, unknown;
  final Color filmSoft, tvSoft, musicSoft, bookSoft, gameSoft;
  final Color filmInk, tvInk, musicInk, bookInk, gameInk;

  const AppMediaColors({
    required this.film, required this.tv, required this.music,
    required this.book, required this.game, required this.unknown,
    required this.filmSoft, required this.tvSoft, required this.musicSoft,
    required this.bookSoft, required this.gameSoft,
    required this.filmInk, required this.tvInk, required this.musicInk,
    required this.bookInk, required this.gameInk,
  });

  /// Obsidian Lens / Precision Editorial — preserves existing AppColors.*
  factory AppMediaColors.classic() => const AppMediaColors(
    film: AppColors.filmColor,
    tv: AppColors.tvColor,
    music: AppColors.musicColor,
    book: AppColors.bookColor,
    game: AppColors.gameColor,
    unknown: AppColors.unknownColor,
    // Soft/ink derived with Color.withValues(alpha: 0.12) at call time or precomputed
    filmSoft: Color(0x1FE53935), tvSoft: Color(0x1FFF7043),
    musicSoft: Color(0x1F7E57C2), bookSoft: Color(0x1F43A047),
    gameSoft: Color(0x1F1E88E5),
    filmInk: Color(0xFF7A1C1A), tvInk: Color(0xFF803319),
    musicInk: Color(0xFF3E2B6B), bookInk: Color(0xFF1F4F24),
    gameInk: Color(0xFF0F3F6F),
  );

  factory AppMediaColors.popcorn() => const AppMediaColors(
    film: Color(0xFFFF5E3A),
    tv: Color(0xFFFF8A3D),
    music: Color(0xFFA06DFF),
    book: Color(0xFF00C478),
    game: Color(0xFF4A6CF7),
    unknown: Color(0xFF9A8F82),
    filmSoft: Color(0xFFFFE0D4), tvSoft: Color(0xFFFFE4CF),
    musicSoft: Color(0xFFEAD9FF), bookSoft: Color(0xFFC8F5DF),
    gameSoft: Color(0xFFD6DEFF),
    filmInk: Color(0xFF661E10), tvInk: Color(0xFF66310F),
    musicInk: Color(0xFF31146B), bookInk: Color(0xFF0A4A2C),
    gameInk: Color(0xFF122269),
  );

  factory AppMediaColors.popcornDark() => const AppMediaColors(
    film: Color(0xFFFF7A5C),
    tv: Color(0xFFFFA065),
    music: Color(0xFFB48AFF),
    book: Color(0xFF2AD68F),
    game: Color(0xFF7E98FF),
    unknown: Color(0xFFB8AFA3),
    filmSoft: Color(0x33FF7A5C), tvSoft: Color(0x33FFA065),
    musicSoft: Color(0x33B48AFF), bookSoft: Color(0x332AD68F),
    gameSoft: Color(0x337E98FF),
    filmInk: Color(0xFFFF7A5C), tvInk: Color(0xFFFFA065),
    musicInk: Color(0xFFB48AFF), bookInk: Color(0xFF2AD68F),
    gameInk: Color(0xFF7E98FF),
  );

  Color solidFor(MediaType t) => switch (t) {
    MediaType.film => film, MediaType.tv => tv,
    MediaType.music => music, MediaType.book => book,
    MediaType.game => game, _ => unknown,
  };
  Color softFor(MediaType t)  => /* mirror */;
  Color inkFor(MediaType t)   => /* mirror */;

  @override
  AppMediaColors copyWith({ /* all fields nullable */ }) => /* ... */;

  @override
  AppMediaColors lerp(ThemeExtension<AppMediaColors>? other, double t) {
    if (other is! AppMediaColors) return this;
    return AppMediaColors(
      film: Color.lerp(film, other.film, t)!,
      // ... all fields
    );
  }
}

// Convenience accessor
extension AppMediaColorsContext on BuildContext {
  AppMediaColors get mediaColors => Theme.of(this).extension<AppMediaColors>()!;
}
```

**Important:** adopt `MediaType` enum from `lib/domain/` (already exists). Do not create a new one.

---

## 7. Call-site migration

Anywhere that reads `AppColors.filmColor`, `AppColors.musicColor`, etc. directly. Run:
```
grep -rn 'AppColors\.\(film\|tv\|music\|book\|game\|unknown\)Color' lib/
```

Expected hits (based on repo structure — verify before editing):
- `lib/presentation/screens/collection/widgets/media_item_card.dart`
- `lib/presentation/screens/collection/widgets/media_type_pie_chart.dart`
- `lib/presentation/screens/collection/widgets/filter_bar.dart`
- `lib/presentation/screens/item_detail/*.dart`
- `lib/presentation/screens/scanner/*.dart` (type filter toggles)
- `lib/presentation/widgets/rip_status_badge.dart` / `sync_badge.dart`
- `lib/presentation/screens/dashboard/dashboard_screen.dart`
- Any chart colouring logic

**Migration pattern:**
```dart
// before
color: AppColors.filmColor,
// after
color: context.mediaColors.film,
// or, when the media type is dynamic
color: context.mediaColors.solidFor(item.mediaType),
```

Keep `AppColors.filmColor` constants defined — don't delete them. Older code paths (tests, fallbacks) may still reference them, and keeping them costs nothing.

---

## 8. Theme registration

In `app_theme.dart`:

```dart
static ThemeData obsidianLens() => ThemeData.dark(useMaterial3: true).copyWith(
  // ... existing build ...
  extensions: const [AppMediaColors.classic()],
);

static ThemeData precisionEditorial() => ThemeData.light(useMaterial3: true).copyWith(
  // ... existing build ...
  extensions: const [AppMediaColors.classic()],
);

static ThemeData popcornLight() => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.popcornPrimary,
    onPrimary: AppColors.popcornOnPrimary,
    primaryContainer: AppColors.popcornPrimaryContainer,
    onPrimaryContainer: AppColors.popcornOnPrimaryContainer,
    secondary: AppColors.popcornSecondary,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: AppColors.popcornSecondaryContainer,
    tertiary: AppColors.popcornTertiary,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: AppColors.popcornTertiaryContainer,
    surface: AppColors.popcornSurface,
    onSurface: AppColors.popcornOnSurface,
    onSurfaceVariant: AppColors.popcornOnSurfaceVariant,
    surfaceDim: AppColors.popcornSurfaceDim,
    surfaceContainerLowest: AppColors.popcornSurfaceContainerLowest,
    surfaceContainerLow: AppColors.popcornSurfaceContainerLow,
    surfaceContainer: AppColors.popcornSurfaceContainer,
    surfaceContainerHigh: AppColors.popcornSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.popcornSurfaceContainerHighest,
    outline: AppColors.popcornOutline,
    outlineVariant: AppColors.popcornOutlineVariant,
    error: AppColors.popcornError,
    errorContainer: AppColors.popcornErrorContainer,
    onError: Color(0xFFFFFFFF),
  ),
  textTheme: AppTypography.lightTextTheme,
  scaffoldBackgroundColor: AppColors.popcornSurface,
  cardTheme: CardTheme(
    elevation: 0,
    color: AppColors.popcornSurfaceContainerLowest,
    shape: AppShapes.cardShape,
    margin: EdgeInsets.zero,
  ),
  chipTheme: ChipThemeData(
    shape: const StadiumBorder(),
    side: const BorderSide(color: AppColors.popcornOutline),
    labelStyle: AppTypography.lightTextTheme.labelLarge,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(
        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14,
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(shape: const CircleBorder()),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.popcornSurfaceContainerLowest,
    selectedItemColor: AppColors.popcornPrimary,
    unselectedItemColor: AppColors.popcornOnSurfaceVariant,
  ),
  extensions: [AppMediaColors.popcorn()],
);

static ThemeData popcornDark() => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark( /* popcornDark* tokens */ ),
  textTheme: AppTypography.darkTextTheme,
  // same cardTheme / chipTheme / shapes as popcornLight
  extensions: [AppMediaColors.popcornDark()],
);
```

---

## 9. Settings / theme picker

### 9.1 State model

Replace the current `ThemeMode`-backed setting with a compound value:

```dart
enum ThemeFamily { classic, popcorn }
enum ThemeBrightness { system, light, dark }

class ThemeChoice {
  final ThemeFamily family;
  final ThemeBrightness brightness;
  const ThemeChoice(this.family, this.brightness);
}
```

Persist as two keys in settings (`theme_family`, `theme_brightness`) to stay cleanly migratable. Default existing installs to `ThemeChoice(ThemeFamily.classic, ThemeBrightness.system)` — no visual change on upgrade.

### 9.2 Resolving at app root

In the widget that wires `MaterialApp.theme`/`darkTheme`:

```dart
final choice = ref.watch(themeChoiceProvider);
final (light, dark) = switch (choice.family) {
  ThemeFamily.classic => (AppTheme.precisionEditorial(), AppTheme.obsidianLens()),
  ThemeFamily.popcorn => (AppTheme.popcornLight(),       AppTheme.popcornDark()),
};
return MaterialApp(
  theme: light,
  darkTheme: dark,
  themeMode: switch (choice.brightness) {
    ThemeBrightness.system => ThemeMode.system,
    ThemeBrightness.light => ThemeMode.light,
    ThemeBrightness.dark => ThemeMode.dark,
  },
);
```

### 9.3 Settings UI

In `settings_screen.dart`, split the current theme section into two groups:

- **Palette**: two tappable swatch cards (Classic / Popcorn) showing a tiny preview — a coloured pill, a card, and three media dots (film/music/book) in miniature. 120×80 each.
- **Appearance**: the existing Light / Dark / System segmented control.

Render Palette cards with 3 colour dots from each family:
- Classic: `AppColors.lightPrimary`, `AppColors.darkPrimary`, `AppColors.filmColor`
- Popcorn: `#FF5E3A`, `#00C4B8`, `#A06DFF`

---

## 10. Component-level changes (optional polish)

These only apply when the Popcorn theme is active. They're optional — the basic colour swap alone already lifts the feel — but recommended for parity with the prototype:

1. **Mobile bottom nav (`app_scaffold.dart`)** — Add a variant that renders a floating pill-shaped bar with a raised centre scan button (54px, shadowed). Trigger with `if (theme.extension<AppMediaColors>() is Popcorn-ish)` — or better, add a `bool floatingNavBar` on a separate `AppLayoutExtension` so other themes can opt in.
2. **Hero stat card on dashboard** — Dark ink card on light bg with a radial primary-colour glow top-right (`RadialGradient` with `primary.withValues(alpha: 0.55)`). Space Grotesk for the big number — add that font to `pubspec.yaml` assets if not present.
3. **Cover placeholders** — `CustomPainter` that draws diagonal stripes + monogram + type-tag in top-right. Used whenever `item.coverUrl` is null or fails to load. One painter, size-agnostic.
4. **Chips** — All chips full-pill (`StadiumBorder`). Filter/tag chips: `backgroundColor: context.mediaColors.softFor(type)`, `labelStyle.color: context.mediaColors.inkFor(type)`, `fontWeight: 700`.
5. **Item detail hero** — Large gradient header (matching the item's computed hue) with the cover floating into the content area (half-overlapping). `SliverAppBar.medium` with a `flexibleSpace` gradient works.

---

## 11. Typography

No new fonts required for base theme — Manrope is already wired in `pubspec.yaml`.

**Optional:** add **Space Grotesk** for numeric displays (stats on dashboard, counts in sidebar). Add to `pubspec.yaml`:
```yaml
- family: Space Grotesk
  fonts:
    - asset: assets/fonts/SpaceGrotesk-SemiBold.ttf
      weight: 600
    - asset: assets/fonts/SpaceGrotesk-Bold.ttf
      weight: 700
    - asset: assets/fonts/SpaceGrotesk-ExtraBold.ttf
      weight: 800
```
Then extend `AppTypography` with a `displayNumeric` style that uses `Space Grotesk` for the huge `847` on the dashboard card. If skipped, Manrope ExtraBold reads fine.

---

## 12. Testing

- [ ] `flutter test` passes on existing widget tests.
- [ ] Add a golden test per screen × theme (3 themes × key screens = ~18 goldens). Use `flutter_test`'s `matchesGoldenFile`.
- [ ] Integration tests in `integration_test/` should not care about colour, but run the suite to confirm.
- [ ] Manually verify accessibility: WCAG AA contrast (4.5:1) on Popcorn light for `onSurface` vs `surface` — precomputed: `#1D1A17` on `#FFF6EC` ≈ 14:1 ✓. Primary CTA `onPrimary` `#FFFFFF` on `#FF5E3A` ≈ 3.5:1 — **fails AA for body text**, passes for large text / graphic elements. Keep button copy ≥ 14pt 700-weight so it qualifies as large text, or darken primary to `#E44A26` (4.6:1) for Popcorn if body-text pass is required.
- [ ] Verify Popcorn dark primary `#FF7A5C` on `#161416` ≈ 6.8:1 ✓.

---

## 13. Implementation order (for Claude Code)

Work in this order — each step is independently shippable:

1. **Scaffolding** — create `app_shapes.dart`, `app_media_colors.dart` with `classic()` factory only. Wire `AppMediaColors.classic()` into both existing themes' `extensions:`. Run tests — nothing should change.
2. **Migrate call sites** — replace all `AppColors.filmColor` etc. with `context.mediaColors.film`. Use the convenience extension. Run tests — nothing should change.
3. **Add Popcorn tokens** — append `popcorn*` constants to `AppColors`. No call sites yet. Tests still pass.
4. **Build Popcorn themes** — create `popcorn_theme.dart` with `popcornLight()` and `popcornDark()`. Add `AppMediaColors.popcorn()` and `popcornDark()` factories. Nothing wired yet.
5. **Settings model** — introduce `ThemeFamily` + `ThemeBrightness`, migrate storage, update the root `MaterialApp`. Default remains Classic.
6. **Settings UI** — add the Palette swatch cards.
7. **Manual pass** — click through every screen in Popcorn light + dark; log any hardcoded `Colors.*` or `AppColors.dark*` / `AppColors.light*` that leaked through.
8. **Goldens** — regenerate.
9. **(Optional) Polish components** — floating nav bar, procedural cover placeholder, hero stat card.

Each numbered step is a single PR.

---

## 14. Out of scope (for this pass)

- Citrus and Berry palettes — the prototype demos them but they add three more theme entries. Ship Popcorn first, add the others by copying the Popcorn blocks and changing hex values.
- Animated theme transitions.
- Per-user accent colour picker.
- Replacing the existing themes — keep all three.

---

## 15. Questions for maintainer

Before starting, confirm:

1. Are the Obsidian Lens + Precision Editorial themes considered stable/protected, or open to tweaks if we find inconsistencies while adding `AppMediaColors`? - They can be tweaked
3. Is adding Space Grotesk acceptable, or should we stick to Manrope for numerals? - acceptable to add Space Grotesk
4. Any existing `ThemeExtension` subclasses we should extend rather than add alongside? (Check `app_theme_extensions.dart`.) - What ever is better to implement, and to allow other themes to be added later.
5. WCAG AA body-text contrast on the coral primary — prefer to keep the saturated `#FF5E3A` and ensure all CTA copy is "large text" weight, or darken to `#E44A26`? - what ever looks better, this type of app it not so good as a WCAG AA.
