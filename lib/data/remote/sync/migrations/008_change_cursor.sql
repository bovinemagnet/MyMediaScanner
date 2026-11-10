-- Migration 008: server-side change cursor for incremental pulls (#131).
--
-- Requires PostgreSQL 13 or later (pg_current_xact_id / pg_snapshot_xmin).
--
-- Incremental pulls used to filter on `updated_at > watermark`, but
-- `updated_at` is the client's edit time. An edit made offline at 10:00
-- and uploaded at 12:00 keeps `updated_at = 10:00`, so a device that
-- pulled at 11:00 never fetched it — even with perfectly synchronised
-- clocks. `updated_at` stays the last-write-wins basis for conflict
-- decisions; this migration adds a separate, server-assigned cursor.
--
-- Every insert or update stamps `change_txid` with the id of the
-- writing transaction. A pull first reads the snapshot horizon
-- (`pg_snapshot_xmin(pg_current_snapshot())`): every transaction with
-- an id below it has finished. The next pull fetches rows with
-- `change_txid >= horizon`, so a transaction that was still running —
-- however long it takes to commit — is always picked up later. Some
-- rows are fetched twice; applying them is idempotent.
--
-- Safe to run more than once.

CREATE OR REPLACE FUNCTION mms_stamp_change_txid() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.change_txid := pg_current_xact_id()::text::bigint;
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'media_items', 'tags', 'shelves', 'borrowers', 'loans',
    'locations', 'series', 'media_item_tags', 'shelf_items'
  ] LOOP
    EXECUTE format(
      'ALTER TABLE %I ADD COLUMN IF NOT EXISTS change_txid BIGINT', t);
    -- Existing rows get this migration's transaction id, so the first
    -- pull after upgrading (which starts from no cursor) fetches them.
    EXECUTE format(
      'UPDATE %I SET change_txid = pg_current_xact_id()::text::bigint '
      'WHERE change_txid IS NULL', t);
    EXECUTE format(
      'ALTER TABLE %I ALTER COLUMN change_txid SET NOT NULL', t);
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON %I (change_txid)',
      'idx_' || t || '_change_txid', t);
    EXECUTE format(
      'DROP TRIGGER IF EXISTS mms_stamp_change_txid ON %I', t);
    EXECUTE format(
      'CREATE TRIGGER mms_stamp_change_txid '
      'BEFORE INSERT OR UPDATE ON %I '
      'FOR EACH ROW EXECUTE FUNCTION mms_stamp_change_txid()', t);
  END LOOP;
END;
$$;
