# PRD: MyMediaScanner

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** 2026-03-15  

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
- Scan a barcode and automatically create an enriched collection item in under 5 seconds
- Work fully offline on mobile with background sync to Postgres when connectivity is available
- Provide a unified collection browser on all five platforms (Android, iOS, macOS, Windows, Linux)
- Allow users to rate, review, and tag every item in their collection

### Secondary Goals (v1)
- Manual barcode / ISBN entry as a fallback on all platforms
- Desktop support for USB barcode scanners via keyboard-wedge input
- Per-item scan history (when and where it was scanned)

### Out of Scope (v1 — candidates for v2)
- Lending tracker / borrowing management
- Wishlist / want-to-buy lists
- Social features (sharing, following other collectors)
- Marketplace integrations (pricing, selling)
- Public or cloud-hosted backend

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
| SCAN-01 | Camera scanning on Android and iOS using ML Kit barcode API | P0 |
| SCAN-02 | Real-time viewfinder overlay with scan confirmation animation | P0 |
| SCAN-03 | Manual barcode / ISBN entry field on all platforms | P0 |
| SCAN-04 | Keyboard-wedge USB scanner support on desktop (intercept Enter key in scan field) | P1 |
| SCAN-05 | Audible and haptic feedback on successful scan | P1 |
| SCAN-06 | Prevent duplicate scan: warn user if barcode already exists in collection | P0 |
| SCAN-07 | Batch scan mode: scan multiple items in sequence without returning to the home screen | P1 |

### 7.2 Metadata Lookup

| ID | Requirement | Priority |
|---|---|---|
| META-01 | Detect media type from barcode structure (EAN vs ISBN) and user-selectable hint | P0 |
| META-02 | Tiered lookup: UPCitemdb (general) → specialist API (TMDB / Discogs / Google Books) | P0 |
| META-03 | Display lookup results for user confirmation before saving | P0 |
| META-04 | Allow user to manually edit any metadata field before or after saving | P0 |
| META-05 | Cache API responses locally to avoid repeat lookups for the same barcode | P1 |
| META-06 | Store which API source(s) provided which fields on each item | P1 |
| META-07 | Handle lookup failures gracefully: allow saving with barcode-only record | P0 |
| META-08 | Support re-fetching metadata for an existing item (refresh from API) | P2 |

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

| ID | Requirement | Priority |
|---|---|---|
| COLL-01 | Browse full collection with search, filter, and sort | P0 |
| COLL-02 | Filter by media type, genre, year, tag | P0 |
| COLL-03 | Sort by title, date added, year, rating | P0 |
| COLL-04 | View item detail with all metadata, cover art, and user notes | P0 |
| COLL-05 | Edit any field on an existing item | P0 |
| COLL-06 | Delete item from collection (with confirmation) | P0 |
| COLL-07 | Star rating (1–5 stars) per item | P0 |
| COLL-08 | Free-text personal review / notes per item | P0 |
| COLL-09 | Custom tags: create, assign, and filter by arbitrary user-defined tags | P0 |
| COLL-10 | Shelves: group items into named, ordered user-defined collections | P1 |
| COLL-11 | Collection statistics dashboard (total items, by type, by year, etc.) | P2 |
| COLL-12 | Export collection to CSV or JSON | P2 |

### 7.4 Sync & Storage

| ID | Requirement | Priority |
|---|---|---|
| SYNC-01 | All data stored locally in SQLite (Drift) — app is fully functional offline | P0 |
| SYNC-02 | Sync to self-hosted PostgreSQL when connectivity is available | P0 |
| SYNC-03 | Sync is user-initiated or occurs automatically in the background | P1 |
| SYNC-04 | Sync status indicator (last synced time, pending changes count) | P1 |
| SYNC-05 | Conflict resolution: last-write-wins with per-field timestamps as v1 strategy | P0 |
| SYNC-06 | Multiple devices can connect to the same Postgres instance | P0 |
| SYNC-07 | User configures Postgres connection details in Settings (host, port, db, credentials) | P0 |
| SYNC-08 | Cover art images synced as URLs (not binary blobs) in v1 | P0 |
| SYNC-09 | Full re-sync / reset local database option in Settings | P1 |

### 7.5 Settings

| ID | Requirement | Priority |
|---|---|---|
| SET-01 | Configure Postgres connection (host, port, database, username, password) | P0 |
| SET-02 | Test connection button with clear success / error feedback | P0 |
| SET-03 | Default media type hint for scanner (to bias metadata lookup) | P1 |
| SET-04 | API key management for TMDB, Discogs (entered by user) | P0 |
| SET-05 | Toggle: auto-sync on launch | P1 |
| SET-06 | Toggle: haptic / sound feedback on scan | P1 |
| SET-07 | Theme: system / light / dark | P1 |

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

### Phase 1 — Foundation (v0.1)
- Project scaffold, Drift schema, Riverpod setup
- TMDB and Discogs API clients
- Camera scanning (Android + iOS)
- Basic collection CRUD (no sync)
- Item detail screen with metadata display

### Phase 2 — Desktop & Sync (v0.2)
- Desktop platform builds (macOS, Windows, Linux)
- Manual entry + keyboard-wedge scanning on desktop
- PostgreSQL sync (Drift → Postgres mirror)
- Settings screen with connection config

### Phase 3 — Collection Features (v0.3)
- Star ratings, reviews, tags
- Shelves
- Search, filter, sort
- Google Books / Open Library client
- UPCitemdb fallback

### Phase 4 — Polish (v1.0)
- Batch scan mode
- Conflict resolution UI
- Collection statistics
- Export (CSV / JSON)
- Accessibility audit
- Full platform testing pass

---

## 12. Open Questions

| # | Question | Owner |
|---|---|---|
| 1 | Should cover art images be stored as local files (synced separately) or API URLs only? Currently scoped as URLs only in v1. | Product |
| 2 | What Postgres sync mechanism — custom REST service, direct Postgres connection from client, or something like Supabase self-hosted? | Architecture |
| 3 | Is IGDB (video game metadata) in scope for v1 or v2? | Product |
| 4 | Should Discogs return multiple release versions of the same album (e.g. remaster, original press) and let the user pick, or auto-select the best match? | Product |
| 5 | Rate limiting strategy for Discogs (60 requests/minute unauthenticated, 25/minute authenticated with user token) — does the user supply OAuth token or app-level key? | Architecture |
