# BOX DEFENSE — Community Voting Plan

## Purpose

Community voting is the product differentiator. The local game now has a voting screen and networking boundary; the remaining release task is deploying the small backend that satisfies the client contract below.

## Product rule

Each poll contains exactly two curated options.

The developer controls which options are offered. Players decide which of those options wins.

This gives the community meaningful influence without giving away scope control.

## Player-facing flow

```text
Main Menu
    ↓
Community Vote
    ↓
Active poll with two options
    ↓
Player selects one option
    ↓
Vote submitted
    ↓
Client shows recorded state/results
    ↓
Poll closes remotely
    ↓
Winning option becomes the next planned update
```

## Initial poll UX

Example:

```text
COMMUNITY VOTE #001

WHAT SHOULD WE ADD NEXT?

[ WEAPONS ]
    VS
[ NEW ENEMIES ]

57% / 43%
8,142 votes
Ends in 2d 08h
```

For v1, results should be shown after the player has voted. The API can also set `show_results: true` when results should be visible to everyone.

## v1 constraints

- One active poll at a time.
- Exactly two options.
- One recorded vote per player identity per poll.
- Poll start/end timestamps are server-controlled.
- Poll question/options are remotely configurable.
- Gameplay still works if the voting service is unavailable.

## Backend boundary

The game client must never be the source of truth for vote counts.

```text
Godot client
    ↓
Public voting API
    ↓
Vote service/database

Admin tool
    ↓
Authenticated admin API / protected database console
```

## Implemented client contract

The Godot client currently expects a base URL configured on the `VoteService` node.

### `GET /polls/active?player_id=<installation-id>`

Return the active poll in this shape:

```json
{
  "id": "poll_001",
  "question": "What should we add next?",
  "ends_text": "ENDS IN 2D 08H",
  "show_results": false,
  "player_vote": "",
  "options": [
    {
      "id": "weapons",
      "text": "WEAPONS",
      "votes": 3812
    },
    {
      "id": "new_enemies",
      "text": "NEW ENEMIES",
      "votes": 4921
    }
  ]
}
```

`player_vote` is an empty string when this installation has not voted. After a recorded vote it contains the selected option ID.

The first release can return a preformatted `ends_text`; moving countdown calculation fully into the client is optional later.

### `POST /votes`

Request:

```json
{
  "poll_id": "poll_001",
  "option_id": "weapons",
  "player_id": "persistent-installation-id"
}
```

On success, return the same poll representation used by `GET /polls/active`, now with `player_vote` populated and updated totals.

This keeps the client simple: both loading and voting end by rendering the same data structure.

## Identity and duplicate voting

The first release does not require perfect election-grade identity. It requires reasonable protection against accidental/naive duplicate voting.

### Stage 1 — installation identity

The game now generates a random persistent installation ID and stores it in the versioned local save.

Server rule:

```text
UNIQUE(poll_id, player_id)
```

Advantages:

- Very low friction.
- No account UI.
- Fast to ship.

Weaknesses:

- Reinstall/reset can create another identity.
- Determined users can vote multiple times.

This is acceptable for early feature polls unless abuse becomes a real problem.

### Stage 2 — platform/account identity

If abuse matters later, migrate to platform authentication or an optional BOX DEFENSE account.

Do not add login complexity until it solves a real problem.

## Security rules

- No admin token inside the game binary.
- Validate poll state and option IDs server-side.
- Enforce one recorded vote per poll/player identity server-side.
- Rate-limit vote submission endpoints.
- Ignore client-provided vote totals; the client never needs to submit totals.
- Use HTTPS.
- Admin endpoints or database writes must require credentials unavailable to the game client.

## Failure behavior

Voting is optional to moment-to-moment gameplay.

If networking fails:

- Main gameplay remains playable.
- Vote screen shows a simple error/offline state.
- Never block startup because the poll cannot load.

If submission outcome is uncertain:

- Re-fetch poll/player-vote state before allowing another submission attempt in a future refinement.
- The backend uniqueness rule must remain authoritative.

## Minimal database model

A tiny relational model is enough:

### `polls`

```text
id
question
option_a_id
option_a_text
option_b_id
option_b_text
starts_at
ends_at
status
show_results
created_at
```

### `votes`

```text
poll_id
player_id
option_id
created_at

UNIQUE(poll_id, player_id)
```

Vote totals are derived with a count query. They do not need to be trusted counters stored on the client.

## Admin requirements

A tiny administrative workflow is enough at first.

Need to be able to:

- Draft a question.
- Set option A/B labels.
- Set start/end time.
- Open poll.
- Close poll.
- View totals.
- Mark/record the winning option.

A full custom admin website is not mandatory. A protected database console or small authenticated script is enough initially.

## Poll history

Long term, store immutable completed poll records so the game can show a community history such as:

```text
#001 Weapons vs New Enemies → Weapons
#002 Laser vs Rocket → Laser
#003 Big Box Legs vs Tiny Box Swarm → Big Box Legs
```

This history is part of the game's identity and gives future players context for why strange features exist.

## Current implementation state

Completed in the Godot client:

1. Main-menu vote entry.
2. Two-option vote screen.
3. Persistent installation ID.
4. `VoteService` HTTP boundary.
5. Load-active-poll request.
6. Submit-vote request.
7. Offline/unconfigured fallback that does not block gameplay.

Still required:

1. Deploy backend/database.
2. Configure the production `base_url` in the vote scene.
3. Test duplicate-vote enforcement and failure behavior.
4. Add poll history later only if it does not delay release.
