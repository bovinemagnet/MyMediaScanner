-- Migration 001: Initial schema bootstrap for the self-hosted PostgreSQL
-- sync database.
--
-- Run this FIRST when spinning up a new server; later migrations
-- (002_*, 003_*, 004_*) ALTER tables that this file creates. Mirrors the
-- fields produced by MediaItemRepositoryImpl._toSyncPayload() so every
-- column the client pushes has a destination here.

CREATE TABLE IF NOT EXISTS media_items (
  id TEXT PRIMARY KEY,
  barcode TEXT NOT NULL DEFAULT '',
  barcode_type TEXT NOT NULL DEFAULT '',
  media_type TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  subtitle TEXT,
  description TEXT,
  cover_url TEXT,
  year INTEGER,
  publisher TEXT,
  format TEXT,
  genres TEXT NOT NULL DEFAULT '[]',
  extra_metadata TEXT NOT NULL DEFAULT '{}',
  source_apis TEXT NOT NULL DEFAULT '[]',
  user_rating DOUBLE PRECISION,
  user_review TEXT,
  critic_score DOUBLE PRECISION,
  critic_source TEXT,
  date_added BIGINT NOT NULL DEFAULT 0,
  date_scanned BIGINT NOT NULL DEFAULT 0,
  updated_at BIGINT NOT NULL DEFAULT 0,
  synced_at BIGINT,
  deleted INTEGER NOT NULL DEFAULT 0,
  device_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_media_items_barcode ON media_items(barcode);
CREATE INDEX IF NOT EXISTS idx_media_items_updated_at ON media_items(updated_at);
CREATE INDEX IF NOT EXISTS idx_media_items_media_type ON media_items(media_type);
CREATE INDEX IF NOT EXISTS idx_media_items_deleted
  ON media_items(deleted) WHERE deleted = 0;

CREATE TABLE IF NOT EXISTS shelves (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  updated_at BIGINT NOT NULL DEFAULT 0,
  deleted INTEGER NOT NULL DEFAULT 0,
  device_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS shelf_items (
  shelf_id TEXT NOT NULL REFERENCES shelves(id) ON DELETE CASCADE,
  media_item_id TEXT NOT NULL REFERENCES media_items(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (shelf_id, media_item_id)
);

CREATE TABLE IF NOT EXISTS tags (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  colour TEXT,
  updated_at BIGINT NOT NULL DEFAULT 0,
  deleted INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS media_item_tags (
  media_item_id TEXT NOT NULL REFERENCES media_items(id) ON DELETE CASCADE,
  tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (media_item_id, tag_id)
);
