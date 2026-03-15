-- Migration 002: Lending Tracker tables
-- Run against the self-hosted PostgreSQL instance.

CREATE TABLE borrowers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  notes TEXT,
  updated_at BIGINT NOT NULL,
  deleted INTEGER NOT NULL DEFAULT 0,
  device_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE loans (
  id TEXT PRIMARY KEY,
  media_item_id TEXT NOT NULL REFERENCES media_items(id),
  borrower_id TEXT NOT NULL REFERENCES borrowers(id),
  lent_at BIGINT NOT NULL,
  returned_at BIGINT,
  notes TEXT,
  updated_at BIGINT NOT NULL,
  deleted INTEGER NOT NULL DEFAULT 0,
  device_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_loans_media_item ON loans(media_item_id);
CREATE INDEX idx_loans_borrower ON loans(borrower_id);
CREATE INDEX idx_loans_active ON loans(returned_at) WHERE returned_at IS NULL;
