-- Migration 006: locations and series tables.
--
-- The Dart client at `LocationRepositoryImpl` and `SeriesRepositoryImpl`
-- has been enqueueing sync_log rows with entity_type='location' and
-- 'series' since those features shipped, but the corresponding
-- server-side tables never existed — every push was silently rejected
-- by the client-side allow-list (`location` round-tripped through `+s`
-- pluralisation to `locations`, which passed the allow-list but hit a
-- "relation does not exist" at execution; `series` round-tripped to
-- `seriess` and was rejected outright). Cluster-7 fixes the
-- pluralisation in tableForEntityType; this migration creates the
-- remote tables those pushes now actually need.
--
-- Schema mirrors the local Drift tables `LocationsTable` /
-- `SeriesTable`. `parent_id` is a self-FK with ON DELETE SET NULL so a
-- top-level deletion doesn't cascade away the children — soft delete is
-- the canonical retire path; this is just defence in depth.

CREATE TABLE IF NOT EXISTS locations (
  id TEXT PRIMARY KEY,
  parent_id TEXT REFERENCES locations(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  updated_at BIGINT NOT NULL DEFAULT 0,
  deleted INTEGER NOT NULL DEFAULT 0,
  device_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_locations_parent
  ON locations(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_locations_updated_at
  ON locations(updated_at);

CREATE TABLE IF NOT EXISTS series (
  id TEXT PRIMARY KEY,
  external_id TEXT NOT NULL,
  name TEXT NOT NULL,
  media_type TEXT NOT NULL,
  source TEXT NOT NULL,
  total_count INTEGER,
  updated_at BIGINT NOT NULL DEFAULT 0,
  deleted INTEGER NOT NULL DEFAULT 0,
  device_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- `external_id` is qualified by source (e.g. `tmdb:131635`) so a
-- straight UNIQUE here is safe — the qualifier already namespaces it.
CREATE UNIQUE INDEX IF NOT EXISTS idx_series_external_id
  ON series(external_id);
CREATE INDEX IF NOT EXISTS idx_series_updated_at
  ON series(updated_at);
