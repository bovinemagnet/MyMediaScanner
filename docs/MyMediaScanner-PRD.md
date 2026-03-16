# PRD: MyMediaScanner

**Version:** 1.0
**Status:** Implemented
**Last Updated:** 2026-03-16

---

## 1. Overview

MyMediaScanner is a cross-platform Flutter application that allows users to build and manage a personal physical media collection — CDs, DVDs, Blu-rays, books, video games, and other barcoded media — by scanning item barcodes with their phone camera or a desktop USB scanner, automatically enriching the record with metadata from specialist APIs, and synchronising the collection across all their devices via a self-hosted PostgreSQL backend.

---

## 2. Problem Statement

Physical media collectors currently have no single tool that:

- Works natively on both mobile (scanning) and desktop (browsing, managing)
- Pulls rich, accurate metadata from multiple domain-specific sources
- Stores data locally for offline use and syncs reliably to a self-hosted backend
- Keeps the user in control of their data (no lock-in to a cloud provider)

Existing apps are either mobile-only, require a proprietary cloud account, or lack metadata quality for specialist categories like vinyl or obscure Blu-rays.

---

## 3. Goals

### Primary Goals (v1)
- [x] Scan a barcode and automatically create an enriched collection item in under 5 seconds
- [x] Work fully offline on mobile with background sync to Postgres when connectivity is available
- [x] Provide a unified collection browser on all five platforms (Android, iOS, macOS, Windows, Linux)
- [x] Allow users to rate, review, and tag every item in their collection

### Secondary Goals (v1)
- [x] Manual barcode / ISBN entry as a fallback on all platforms
- [x] Desktop support for USB barcode scanners via keyboard-wedge input
- [ ] Per-item scan history (when and where it was scanned)

### Out of Scope (v1 — candidates for v2)
- [x] ~~Lending tracker / borrowing management~~ — **Implemented ahead of schedule**
- [ ] Wishlist / want-to-buy lists
- [ ] Social features (sharing, following other collectors)
- [ ] Marketplace integrations (pricing, selling)
- [ ] Public or cloud-hosted backend

---

## 4. Target Users

| Persona | Description |
|---|---|
| **The Collector** | Has hundreds or thousands of physical items; wants a fast way to digitise their catalogue |
| **The Casual Owner** | Owns a modest shelf of films and music; wants to know what they have without digging through the shelf |
| **The Desktop Manager** | Uses a laptop/desktop as their primary device; wants to browse and edit their collection comfortably |
| **The Self-Hoster** | Privacy-conscious; unwilling to use third-party cloud services for their personal data |

---

## 5. Platforms

| Platform | Priority | Scanning Method |
|---|---|---|
| Android | P0 | Device camera (ML Kit) |
| iOS | P0 | Device camera (ML Kit) |
| macOS | P1 | USB barcode scanner (keyboard-wedge) + manual entry |
| Windows | P1 | USB barcode scanner (keyboard-wedge) + manual entry |
| Linux | P1 | USB barcode scanner (keyboard-wedge) + manual entry |

Desktop platforms receive no camera scanning in v1. A USB barcode scanner presents as a keyboard device and types the barcode string followed by Enter — the app intercepts this in a focused text field with a keyboard shortcut to activate scan mode.

---

## 6. Media Types

| Type | Barcode Standard | Primary Metadata Source |
|---|---|---|
| Film / TV (DVD, Blu-ray, 4K UHD) | EAN-13, UPC-A | TMDB |
| Music CD / Vinyl | EAN-13, UPC-A | Discogs |
| Books | ISBN-10, ISBN-13 | Google Books → Open Library (fallback) |
| Video Games | EAN-13, UPC-A | UPC lookup → IGDB (v2) |
| Other / Unknown | Any | General UPC lookup (UPCitemdb) |

---

## 7. Feature Requirements

### 7.1 Barcode Scanning

| ID | Requirement | Priority |
|---|---|---|
| ID | Requirement | Priority | Status |
|---|---|---|---|
| SCAN-01 | Camera scanning on Android and iOS using ML Kit barcode API | P0 | ✅ Done |
| SCAN-02 | Real-time viewfinder overlay with scan confirmation animation | P0 | ✅ Done |
| SCAN-03 | Manual barcode / ISBN entry field on all platforms | P0 | ✅ Done |
| SCAN-04 | Keyboard-wedge USB scanner support on desktop (intercept Enter key in scan field) | P1 | ✅ Done |
| SCAN-05 | Audible and haptic feedback on successful scan | P1 | ✅ Done |
| SCAN-06 | Prevent duplicate scan: warn user if barcode already exists in collection | P0 | ✅ Done |
| SCAN-07 | Batch scan mode: scan multiple items in sequence without returning to the home screen | P1 | ✅ Done |
| SCAN-08 | Bluetooth/USB external scanner mode toggle on mobile | — | ✅ Done (bonus) |
| SCAN-09 | Media type filter toggles on scan screen | — | ✅ Done (bonus) |

### 7.2 Metadata Lookup

| ID | Requirement | Priority | Status |
|---|---|---|---|
| META-01 | Detect media type from barcode structure (EAN vs ISBN) and user-selectable hint | P0 | ✅ Done |
| META-02 | Tiered lookup: UPCitemdb (general) → specialist API (TMDB / Discogs / Google Books) | P0 | ✅ Done |
| META-03 | Display lookup results for user confirmation before saving | P0 | ✅ Done |
| META-04 | Allow user to manually edit any metadata field before or after saving | P0 | ✅ Done |
| META-05 | Cache API responses locally to avoid repeat lookups for the same barcode | P1 | ✅ Done |
| META-06 | Store which API source(s) provided which fields on each item | P1 | ✅ Done |
| META-07 | Handle lookup failures gracefully: allow saving with barcode-only record | P0 | ✅ Done |
| META-08 | Support re-fetching metadata for an existing item (refresh from API) | P2 | ✅ Done |

#### Metadata Fields (common to all types)

- Title, subtitle
- Cover / artwork image (stored as URL + local cache)
- Year / release date
- Genre(s)
- Description / synopsis
- Publisher / label / studio
- Format (e.g. Blu-ray, CD, Hardcover)
- Barcode value + type
- Date added to collection
- Date scanned

#### Metadata Fields (type-specific)

**Film / TV:** Director, cast, runtime, rating (PG / R etc.), TMDB ID  
**Music:** Artist(s), track listing, label, catalogue number, Discogs release ID  
**Books:** Author(s), ISBN-10/13, page count, publisher, Google Books ID  

### 7.3 Collection Management

| ID | Requirement | Priority | Status |
|---|---|---|---|
| COLL-01 | Browse full collection with search, filter, and sort | P0 | ✅ Done |
| COLL-02 | Filter by media type, genre, year, tag | P0 | ✅ Done |
| COLL-03 | Sort by title, date added, year, rating | P0 | ✅ Done |
| COLL-04 | View item detail with all metadata, cover art, and user notes | P0 | ✅ Done |
| COLL-05 | Edit any field on an existing item | P0 | ✅ Done |
| COLL-06 | Delete item from collection (with confirmation) | P0 | ✅ Done |
| COLL-07 | Star rating (1–5 stars) per item | P0 | ✅ Done |
| COLL-08 | Free-text personal review / notes per item | P0 | ✅ Done |
| COLL-09 | Custom tags: create, assign, and filter by arbitrary user-defined tags | P0 | ✅ Done |
| COLL-10 | Shelves: group items into named, ordered user-defined collections | P1 | ✅ Done |
| COLL-11 | Collection statistics dashboard (total items, by type, by year, etc.) | P2 | ✅ Done |
| COLL-12 | Export collection to CSV or JSON | P2 | ✅ Done |
| COLL-13 | FTS5 full-text search across collection | — | ✅ Done (bonus) |
| COLL-14 | Critic scores from TMDB, Discogs, and Google Books | — | ✅ Done (bonus) |

### 7.4 Sync & Storage

| ID | Requirement | Priority | Status |
|---|---|---|---|
| SYNC-01 | All data stored locally in SQLite (Drift) — app is fully functional offline | P0 | ✅ Done |
| SYNC-02 | Sync to self-hosted PostgreSQL when connectivity is available | P0 | ✅ Done |
| SYNC-03 | Sync is user-initiated or occurs automatically in the background | P1 | ✅ Done |
| SYNC-04 | Sync status indicator (last synced time, pending changes count) | P1 | ✅ Done |
| SYNC-05 | Conflict resolution: last-write-wins with per-field timestamps as v1 strategy | P0 | ✅ Done |
| SYNC-06 | Multiple devices can connect to the same Postgres instance | P0 | ✅ Done |
| SYNC-07 | User configures Postgres connection details in Settings (host, port, db, credentials) | P0 | ✅ Done |
| SYNC-08 | Cover art images synced as URLs (not binary blobs) in v1 | P0 | ✅ Done |
| SYNC-09 | Full re-sync / reset local database option in Settings | P1 | ✅ Done |

### 7.5 Settings

| ID | Requirement | Priority | Status |
|---|---|---|---|
| SET-01 | Configure Postgres connection (host, port, database, username, password) | P0 | ✅ Done |
| SET-02 | Test connection button with clear success / error feedback | P0 | ✅ Done |
| SET-03 | Default media type hint for scanner (to bias metadata lookup) | P1 | ✅ Done |
| SET-04 | API key management for TMDB, Discogs (entered by user) | P0 | ✅ Done |
| SET-05 | Toggle: auto-sync on launch | P1 | ✅ Done |
| SET-06 | Toggle: haptic / sound feedback on scan | P1 | ✅ Done |
| SET-07 | Theme: system / light / dark | P1 | ✅ Done |

---

## 8. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Performance** | Barcode resolved and metadata displayed within 5 seconds on a standard mobile connection |
| **Offline** | All collection browse, view, and edit operations work with no network connection |
| **Sync reliability** | No data loss on sync conflict; all conflicts logged and surfaced to user |
| **Security** | Postgres credentials stored in platform secure storage (Keychain / Keystore / Secret Service) |
| **Privacy** | No telemetry or analytics in v1; all data stays on user's devices and their own Postgres |
| **Accessibility** | Minimum WCAG AA contrast; all interactive elements reachable by keyboard |
| **Localisation** | English only in v1; architecture must support i18n from the start |

---

## 9. API Key Requirements

Users must supply their own API keys for the following services:

| Service | Purpose | Free Tier |
|---|---|---|
| TMDB | Film / TV metadata | Yes (generous) |
| Discogs | Music metadata | Yes (rate-limited) |
| UPCitemdb | General UPC fallback | Yes (limited), paid tiers available |

Google Books and Open Library do not require API keys for read-only metadata lookup.

---

## 10. User Flows

### 10.1 Scan a New Item (Mobile)

```
Home Screen
  → Tap [Scan] FAB
    → Camera viewfinder opens
      → Point at barcode
        → Barcode detected (haptic + sound)
          → Metadata lookup in progress (loading indicator)
            → Metadata result shown (title, cover, fields)
              → User confirms or edits
                → Item saved to local SQLite
                  → Background sync to Postgres (if connected)
                    → Return to collection (new item highlighted)
```

### 10.2 Scan a New Item (Desktop)

```
Home Screen
  → Press [S] keyboard shortcut or click [Scan] button
    → Scan field focused and active
      → User scans with USB scanner (or types barcode + Enter)
        → Same metadata lookup → confirm → save flow as mobile
```

### 10.3 Browse & Filter Collection

```
Collection Screen
  → Search bar (full-text across title, artist, director)
  → Filter chips: [Type ▼] [Genre ▼] [Tag ▼] [Year ▼]
  → Sort selector: [Title | Date Added | Year | Rating]
  → Grid or list view toggle
  → Tap item → Item Detail Screen
```

---

## 11. Release Phases

### Phase 1 — Foundation (v0.1) ✅ Complete
- [x] Project scaffold, Drift schema, Riverpod setup
- [x] TMDB and Discogs API clients
- [x] Camera scanning (Android + iOS)
- [x] Basic collection CRUD (no sync)
- [x] Item detail screen with metadata display

### Phase 2 — Desktop & Sync (v0.2) ✅ Complete
- [x] Desktop platform builds (macOS, Windows, Linux)
- [x] Manual entry + keyboard-wedge scanning on desktop
- [x] PostgreSQL sync (Drift → Postgres mirror)
- [x] Settings screen with connection config

### Phase 3 — Collection Features (v0.3) ✅ Complete
- [x] Star ratings, reviews, tags
- [x] Shelves
- [x] Search, filter, sort
- [x] Google Books / Open Library client
- [x] UPCitemdb fallback

### Phase 4 — Polish (v1.0) ✅ Complete
- [x] Batch scan mode
- [x] Conflict resolution UI
- [x] Collection statistics
- [x] Export (CSV / JSON)
- [ ] Accessibility audit
- [ ] Full platform testing pass

### Beyond v1 — Bonus Features Implemented
- [x] Lending tracker with borrower management and loan tracking
- [x] FTS5 full-text search across collection
- [x] Critic scores from TMDB, Discogs, and Google Books
- [x] FLAC rip library scanner with coverage comparison against physical collection (desktop)
- [x] Audio quality analysis (AccurateRip verification + click/pop detection)
- [x] Bluetooth/USB external scanner mode toggle on mobile
- [x] Media type filter toggles on scan screen
- [x] Material 3 adaptive layout (responsive for mobile/tablet/desktop)

---

## 12. Open Questions

| # | Question | Owner | Resolution |
|---|---|---|---|
| 1 | Should cover art images be stored as local files (synced separately) or API URLs only? Currently scoped as URLs only in v1. | Product | **Resolved:** URLs only in v1 (SYNC-08) |
| 2 | What Postgres sync mechanism — custom REST service, direct Postgres connection from client, or something like Supabase self-hosted? | Architecture | **Resolved:** Direct Postgres connection from client via `postgres` Dart package |
| 3 | Is IGDB (video game metadata) in scope for v1 or v2? | Product | **Deferred to v2:** UPCitemdb fallback used for video games |
| 4 | Should Discogs return multiple release versions of the same album (e.g. remaster, original press) and let the user pick, or auto-select the best match? | Product | **Resolved:** Present multiple matches and let the user pick |
| 5 | Rate limiting strategy for Discogs (60 requests/minute unauthenticated, 25/minute authenticated with user token) — does the user supply OAuth token or app-level key? | Architecture | **Resolved:** User supplies their own API key via Settings |
