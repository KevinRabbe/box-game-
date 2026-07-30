PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS polls (
  id TEXT PRIMARY KEY,
  question TEXT NOT NULL,
  option_a_id TEXT NOT NULL,
  option_a_text TEXT NOT NULL,
  option_b_id TEXT NOT NULL,
  option_b_text TEXT NOT NULL,
  starts_at TEXT NOT NULL,
  ends_at TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'open', 'closed')),
  show_results INTEGER NOT NULL DEFAULT 0 CHECK (show_results IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  CHECK (option_a_id <> option_b_id)
);

CREATE TABLE IF NOT EXISTS votes (
  poll_id TEXT NOT NULL,
  player_id TEXT NOT NULL,
  option_id TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (poll_id, player_id),
  FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS votes_poll_option_idx
  ON votes (poll_id, option_id);

CREATE INDEX IF NOT EXISTS polls_active_idx
  ON polls (status, starts_at, ends_at);
