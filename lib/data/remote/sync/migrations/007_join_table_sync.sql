-- Migration 007: sync columns for the join tables.
--
-- Tag assignments (media_item_tags) and shelf memberships (shelf_items)
-- previously never synced: the client wrote no sync_log entries for
-- them and the pull pipeline never read these tables, so the data was
-- silently device-local. The client now pushes and pulls both tables;
-- it needs `updated_at` as the last-write-wins basis and `deleted` as a
-- removal tombstone (mirroring the soft-delete convention used by every
-- other synced table).
--
-- The composite primary keys are unchanged — the client's batch upsert
-- conflicts on (media_item_id, tag_id) / (shelf_id, media_item_id)
-- rather than the `id` column used by the single-key tables.

ALTER TABLE media_item_tags
  ADD COLUMN IF NOT EXISTS updated_at BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS deleted INTEGER NOT NULL DEFAULT 0;

ALTER TABLE shelf_items
  ADD COLUMN IF NOT EXISTS updated_at BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS deleted INTEGER NOT NULL DEFAULT 0;

-- Incremental pulls filter on updated_at (`WHERE updated_at > $ts`).
CREATE INDEX IF NOT EXISTS idx_media_item_tags_updated_at
  ON media_item_tags(updated_at);
CREATE INDEX IF NOT EXISTS idx_shelf_items_updated_at
  ON shelf_items(updated_at);
