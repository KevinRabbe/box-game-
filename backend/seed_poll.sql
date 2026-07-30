-- Example first poll. Adjust timestamps before deploying.
-- Store timestamps as UTC in SQLite datetime-compatible format.

INSERT OR REPLACE INTO polls (
  id,
  question,
  option_a_id,
  option_a_text,
  option_b_id,
  option_b_text,
  starts_at,
  ends_at,
  status,
  show_results
) VALUES (
  'poll_001',
  'WHAT SHOULD WE ADD FIRST?',
  'weapons',
  'WEAPONS',
  'new_enemies',
  'NEW ENEMIES',
  '2026-08-01 00:00:00',
  '2026-08-04 00:00:00',
  'draft',
  0
);

-- When ready to publish the poll:
-- UPDATE polls SET status = 'open' WHERE id = 'poll_001';
--
-- When voting ends:
-- UPDATE polls SET status = 'closed', show_results = 1 WHERE id = 'poll_001';
--
-- View results:
-- SELECT option_id, COUNT(*) AS votes
-- FROM votes
-- WHERE poll_id = 'poll_001'
-- GROUP BY option_id
-- ORDER BY votes DESC;
