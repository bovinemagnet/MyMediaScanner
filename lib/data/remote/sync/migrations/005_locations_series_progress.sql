-- Migration 005: locations, series, progress tracking, and consumed flag
--
-- The Dart client at `MediaItemRepositoryImpl._toSyncPayload` has been
-- pushing these columns since the in-app locations/series/progress
-- features shipped, but the corresponding server-side schema migration
-- was missing — so every save against a server that had only run
-- migrations 001..004 was rejected with `column "..." does not exist`.
--
-- All columns are nullable except `consumed`, which mirrors the local
-- Drift schema's `INTEGER DEFAULT 0` (0 = not consumed, 1 = consumed).
-- IF NOT EXISTS guards make this idempotent so it's safe to re-run on
-- a server that has already had these columns hand-applied.

ALTER TABLE media_items ADD COLUMN IF NOT EXISTS location_id TEXT;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS series_id TEXT;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS series_position INTEGER;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS progress_current INTEGER;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS progress_total INTEGER;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS progress_unit TEXT;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS started_at BIGINT;
ALTER TABLE media_items ADD COLUMN IF NOT EXISTS completed_at BIGINT;
ALTER TABLE media_items
  ADD COLUMN IF NOT EXISTS consumed INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_media_items_location_id
  ON media_items(location_id) WHERE location_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_media_items_series_id
  ON media_items(series_id) WHERE series_id IS NOT NULL;
