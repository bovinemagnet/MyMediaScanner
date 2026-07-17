# Design audit: themed system mock vs. app screens

Author: Paul Snow

Audits the non-Rips frames in the themed design mock
(`media_scanner_themed.dc.html`: Kinetic / Vault / Index palettes) against
the current app screens, following on from the Rips screen redesign
(tasks 1–7). Desktop Rips is out of scope — it was the subject of the
redesign and already matches the mock.

Scope note: only *cosmetic* drift was fixed (label casing, chip shape,
stat-card styling on widgets that already exist). Anything that would
require a new section, a new data source, or a materially different
layout is recorded as **Deferred**. Anything the design shows with no
underlying data in the app at all (fabricated numbers/badges that the
app cannot compute) is recorded as **Design-fiction**.

## Desktop · Library workspace

Corresponds to `lib/presentation/screens/collection/collection_screen.dart`,
`widgets/filter_bar.dart`, `widgets/media_item_card.dart`.

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Desktop Library | Sidebar nav, shelves list, user footer | Present via `AppScaffold` sidebar (nav items differ: app has 8 branches incl. Shelves/Batch/Rips) | Deferred | Sidebar is a shared shell widget, not owned by this screen; the design mock predates several branches. Out of scope. |
| Desktop Library | "Alex Sterling" / "PRO MEMBER" footer badge | Not present | Design-fiction | No user-profile or subscription-tier concept in the app; do not invent one. |
| Desktop Library | Stat row: Total items / Est. value / Scan accuracy | Not present | Deferred / Design-fiction (partial) | "Total items" is populatable but adding a stat-card row is a new section, not a tweak. "Est. value" and "Scan accuracy" have no data source — design-fiction. |
| Desktop Library | Filter chips: "All 1248", "Film 472", pill shape | `FilterChip`s exist with correct labels but rounded-rect shape and no counts | **Fixed** (shape only) | Applied `StadiumBorder` + `showCheckmark:false` to all chips in `filter_bar.dart`, matching the pill-chip precedent already set by `RipHealthFilterChips` in the Rips redesign. Counts (`Film 472`) require per-type aggregation — deferred as a data-plumbing addition, not a cosmetic tweak. |
| Desktop Library | View toggle: grid/table icons | `ViewModeToggle` already uses `grid_view` / `table_rows` icons via `SegmentedButton` | No gap | Matches. |
| Desktop Library | Gallery cards: format badge ("4K UHD", "VINYL", "HARDCOVER") + director/artist byline caption | `MediaItemCard` shows media-type badge (Film/Music/…) and rating, no format badge or byline | Deferred | Swapping the badge's data source and adding a byline line is a layout/data change beyond a small tweak — flagged for a future task, not fixed here. |
| Desktop Library | "Add Media" gradient CTA | Present (`GradientButton`, `screen_header.dart` actions) | No gap | Matches. |

## Desktop · Insights & analytics

Corresponds to `lib/presentation/screens/collection/statistics_screen.dart`.

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Desktop Insights | Eyebrow "Curation" above title | `ScreenHeader` had no eyebrow | **Fixed** | Added `eyebrow: 'CURATION'`, mirroring the `FLAC RIP COLLECTION` eyebrow precedent set on the Rips screen. |
| Desktop Insights | Title "Insights & Analytics" | Desktop title was the shorter "Analytics" (mobile `AppBar` already said "Insights & Analytics") | **Fixed** | Desktop and mobile titles now match. |
| Desktop Insights | 7 DAYS / 30 DAYS segmented control | `TimePeriodSelector` already implements a time-period control | No gap | Present, different period options but same concept; not a cosmetic issue. |
| Desktop Insights | Stat cards: Total valuation / Scan accuracy / Items tracked / Added this month | App's `_HeroBentoGrid` shows a different, already-richer set (Items Catalogued, rating gauge, Rated, Genres) plus a separate Collection Value tile | Deferred | Pre-existing, intentionally different bento layout — not part of this redesign. "Scan accuracy" specifically has no data source anywhere in the app — design-fiction. |
| Desktop Insights | "Content analysis" bar chart + "Integrity score" panel with AI-style hint text | App has `_GenreBarChart` + `MediaTypePieChart` (by media type/genre) and separate lending/rip-coverage cards; no synthetic "system health" hint copy | Deferred | Different, already-implemented analytics layout; the quoted hint text ("Recommend a manual audit of…") is fabricated flavour text with no backing logic — design-fiction if ever considered. |
| Desktop Insights | "Curation portfolio · top valued" gallery | `_TopRatedGallery` shows top-rated items (by user rating), not top-valued | Deferred | Different sort dimension (rating vs. price); `_TopValueItemsCard` already covers top-value separately in list form. Not a cosmetic swap. |

## Mobile · Dashboard (Home)

Corresponds to `lib/presentation/screens/dashboard/dashboard_screen.dart`.

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Mobile Home | Eyebrow "Your vault" + "Good evening, Alex." greeting | App shows "Your Digital Vault." headline, no personalised greeting/name | Deferred | Personalised greeting requires a user-name concept the app doesn't have; pre-existing copy choice, not a regression. |
| Mobile Home | Stat tiles: Items / Value / Added | App shows Total Items / Average Rating (`_StatCard`, already uppercase label via `.toUpperCase()`) | No gap (casing) / Deferred (data) | Casing already matches design. "Value" and "Added" (this-month delta) have no data source in the current stats provider — design-fiction / deferred. |
| Mobile Home | Recently added carousel | Present (`MediaItemCard` horizontal list) | No gap | Matches. |
| Mobile Home | "Scan new item" CTA | Present as "Quick Scan" gradient button | No gap | Wording differs slightly but this is pre-existing product copy, not drift introduced by the redesign — left as-is. |
| Mobile Home | Bottom nav Home/Scan/Library/Insights/Settings | App bottom nav matches (Home, Library, Scan, Insights per `router.dart`; Settings reachable from Dashboard app bar) | No gap | Matches per existing nav design (documented in project CLAUDE.md). |

## Mobile · Library

Corresponds to `lib/presentation/screens/collection/collection_screen.dart` (same screen as Desktop Library, responsive).

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Mobile Library | Title "Library" + item count pill | AppBar title "Library"; no count pill | Deferred | Minor addition, not present; low priority, deferred rather than adding new chrome. |
| Mobile Library | Search field | `SearchBar` present | No gap | Matches. |
| Mobile Library | Filter pills ALL/FILM/MUSIC/BOOKS | `FilterBar` present, same widget as desktop | **Fixed** (shared fix) | Covered by the `filter_bar.dart` pill-shape fix above. |
| Mobile Library | List rows: cover thumb, title, artist/director + year, format badge, star rating | `CollectionTableView`/grid rows already show cover, title, year, rating; format badge partially — same gap as the Desktop Library gallery card | Deferred | Same underlying widget gap noted above (format badge / byline), not duplicated as a separate fix. |
| Mobile Library | Floating scan FAB | Only present under the Popcorn theme (`AppLayoutExtension.floatingNav`); Kinetic/Vault/Index use bottom nav bar instead | No gap | Documented, intentional per-palette behaviour (`AppLayoutExtension` flags) — not a regression for this design's palettes. |

## Mobile · Appearance (theme picker)

Corresponds to `lib/presentation/screens/settings/settings_screen.dart`
(`_PaletteTile`, `_PaletteCard`, `_ThemeModeTile`).

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Mobile Appearance | Palette cards (swatch + name + description) | `_PaletteCard` shows swatch dots, primary pill, and label; no one-line description text ("Electric green · technical") | Deferred | Cosmetic-adjacent but adds new copy per palette (5 new descriptive strings) — small in isolation but out of the "already exists" bar; deferred rather than guessing copy. |
| Mobile Appearance | Selected state: ring + check_circle icon | App uses ring border only (`selected ? 2 : 1` width, primary colour) | No gap | Valid alternative selection affordance already in place; not broken, not touched. |
| Mobile Appearance | Mode segmented control order: Light, Dark, Auto | App's `_ThemeModeTile` uses System, Light, Dark order | No gap | Reordering enum-driven segments for pure visual parity carries no benefit proportional to the risk of touching a settings control; left as-is. |
| Mobile Appearance | "Sync theme across devices" toggle | Not implemented | Design-fiction | No cross-device theme sync feature exists. |
| Mobile Appearance | "True black on OLED" toggle | Not implemented | Design-fiction | No OLED true-black mode exists. |

## Mobile · Scanner

Corresponds to `lib/presentation/screens/scanner/mobile_scan_screen.dart`,
`widgets/scan_overlay.dart`, `widgets/media_type_toggles.dart`.

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Mobile Scanner | Reticle with corner brackets + scan line | `ScanOverlay` already paints corner brackets over a dimmed cutout | No gap | Matches closely (no animated scan line, but static reticle already present pre-redesign). |
| Mobile Scanner | "SCANNING METADATA…" status pill | `_StatusStrip` already renders this exact label while looking up | No gap | Matches. |
| Mobile Scanner | Media type pill row (FILM/MUSIC/BOOK/GAME) | `MediaTypeToggles` shows CD/DVD-Blu-ray/TV/Book/Game with icons, rounded-rect `FilterChip` | **Fixed** (shape only) | Applied `StadiumBorder` to match the pill style. Left the richer label set (CD vs. Music, DVD/Blu-ray vs. Film, extra TV type) as-is — collapsing to the design's 4 generic labels would remove real functionality; that's a structural call, deferred. |
| Mobile Scanner | Batch counter badge | `BatchScanCounter` present | No gap | Matches. |
| Mobile Scanner | Flash / camera-switch / keyboard glass buttons | `_GlassActionButton`s present (flash, camera switch, external-scanner toggle, manual entry) | No gap | Matches, plus extra functionality (external scanner toggle) not in the mock. |

## Mobile · Item detail

Corresponds to `lib/presentation/screens/item_detail/item_detail_screen.dart`,
`widgets/cover_art_hero.dart`, `widgets/metadata_section.dart`.

| Screen | Design element | Status in app | Action | Notes |
|---|---|---|---|---|
| Mobile Item Detail | Full-bleed gradient hero with format badges (4K ULTRA HD / HDR10+ / ATMOS) and back/share overlay buttons | App uses an `AppBar` + bounded `CoverArtHero` (contain-fit, no overlay badges) | Deferred | Materially different, pre-existing layout (list-of-sections vs. full-bleed hero); redesigning the whole screen is out of this task's cosmetic scope. |
| Mobile Item Detail | "Edit metadata" primary CTA + favourite icon button | App has separate AppBar icon actions (edit, delete, refresh, shelf, cover-search) instead of an inline CTA row | Deferred | Different but equivalent interaction pattern; not a small tweak to consolidate into one CTA row. |
| Mobile Item Detail | "On loan to Marcus" status banner | App's `_LendingSection` already shows an equivalent "Lent to {name}" card with due date/overdue badge | No gap | Functionally matches; different card chrome but not label casing/shape drift. |
| Mobile Item Detail | "Technical specification" 2×2 grid: Format / Region / Discs / Scanned | App's `MetadataSection` shows label:value rows (Format, Publisher, Year, Barcode, Genres, + per-type fields) | Deferred / Design-fiction (partial) | "Format" already exists; "Region", "Discs" and "Scanned date" have no corresponding fields in `MediaType.metadataFields` — design-fiction. Restructuring the existing rows into a 2×2 grid is a layout change, not a cosmetic tweak — deferred. |

## Summary of fixes made

1. `lib/presentation/screens/collection/statistics_screen.dart` — added `eyebrow: 'CURATION'` and renamed the desktop title from "Analytics" to "Insights & Analytics" to match the mobile app bar and the eyebrow precedent set on the Rips screen.
2. `lib/presentation/screens/collection/widgets/filter_bar.dart` — all `FilterChip`s (All / media type / Lent out / Ripped / rip-status) now use `StadiumBorder` (+ `showCheckmark: false` where a checkmark isn't otherwise meaningful), matching the pill-chip shape used by `RipHealthFilterChips` and the themed design.
3. `lib/presentation/screens/scanner/widgets/media_type_toggles.dart` — media type toggle chips now use `StadiumBorder` for the same reason.

Each fix was verified with its own targeted `flutter test` run, and the full suite was re-run green before committing the audit doc.

## Summary of deferred / design-fiction items

- Sidebar "Rip health" legend, user-profile footer, "PRO MEMBER" badge — explicitly out of scope per the task brief (design-fiction / not part of this app's data model).
- "Est. value" and "Scan accuracy" stats (Desktop Library, Desktop Insights, Mobile Home) — no data source anywhere in the app; design-fiction.
- Filter/gallery card counts ("Film 472"), library stat-card row, palette description copy, mode-segment reordering, format-badge/byline swap on media cards, full item-detail redesign, "Sync theme across devices" and "True black on OLED" toggles — all structural additions, new copy, or layout changes beyond a small tweak; deferred for a future, explicitly-scoped task.
