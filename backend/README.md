# BOX DEFENSE voting backend

This directory contains the intentionally tiny backend needed for the first public community vote.

The implementation is a Cloudflare Worker using D1 (SQLite). It is separate from the Godot game so backend credentials never need to ship in the app.

## Public API

```text
GET  /health
GET  /polls/active?player_id=<persistent-installation-id>
POST /votes
```

The exact JSON contract is documented in `docs/05_COMMUNITY_VOTING.md`.

## Why this is small

For v1 we need only:

- one active poll;
- two options;
- one vote per persistent installation ID;
- aggregate totals;
- remote poll open/close control.

There is deliberately no custom admin website yet. Polls can be managed through D1/Wrangler or the provider console.

## Deployment outline

Requires a Cloudflare account and Wrangler.

1. Create a D1 database named `box-defense-votes`.
2. Copy `wrangler.toml.example` to `wrangler.toml`.
3. Put the real D1 database ID in `wrangler.toml`.
4. Apply `schema.sql` to the database.
5. Optionally edit/apply `seed_poll.sql`.
6. Deploy the Worker.
7. Test `/health` and `/polls/active`.
8. Put the deployed HTTPS Worker URL into `VoteService.base_url` in `scenes/ui/community_vote.tscn`.

Typical Wrangler commands are conceptually:

```bash
npx wrangler d1 create box-defense-votes
npx wrangler d1 execute box-defense-votes --remote --file=./schema.sql
npx wrangler d1 execute box-defense-votes --remote --file=./seed_poll.sql
npx wrangler deploy
```

Run those commands from this `backend/` directory after the real configuration exists.

## Opening the first poll

The seed poll defaults to `draft` so it cannot accidentally become a live vote.

After correcting its timestamps:

```sql
UPDATE polls
SET status = 'open'
WHERE id = 'poll_001';
```

## Closing a poll

```sql
UPDATE polls
SET status = 'closed', show_results = 1
WHERE id = 'poll_001';
```

## Results

```sql
SELECT option_id, COUNT(*) AS votes
FROM votes
WHERE poll_id = 'poll_001'
GROUP BY option_id
ORDER BY votes DESC;
```

## Duplicate vote behavior

`votes` uses `(poll_id, player_id)` as its primary key. Re-submitting for the same installation does not create a second vote and does not switch the existing vote.

This is intentionally lightweight anti-abuse protection. It is sufficient for early feature polls but not meant to provide election-grade identity.

## Before public release

- Add basic provider-side rate limiting if abuse becomes visible.
- Verify CORS/HTTPS behavior from an Android export.
- Verify closed/expired polls cannot receive votes.
- Never add admin credentials to the Godot project.
