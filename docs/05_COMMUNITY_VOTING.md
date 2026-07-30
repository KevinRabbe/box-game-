# BOX DEFENSE — Community Voting Plan

## Purpose

Community voting is the product differentiator, but it is not part of FP-01. This document protects the architectural boundary now so combat does not become coupled to networking later.

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

The exact decision about whether percentages are visible before voting should be made when implementing voting. Hiding live results until after a vote reduces bandwagon effects; showing them immediately creates more social energy. Both are valid product choices.

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
Authenticated admin API
```

## Suggested API shape

The exact backend technology can be chosen later. The client contract should remain small.

### Get active poll

Conceptual response:

```json
{
  "id": "poll_001",
  "question": "What should we add next?",
  "option_a": {
    "id": "weapons",
    "label": "Weapons"
  },
  "option_b": {
    "id": "new_enemies",
    "label": "New Enemies"
  },
  "starts_at": "...",
  "ends_at": "...",
  "status": "open",
  "results": {
    "a": 3812,
    "b": 4921
  },
  "my_vote": null
}
```

### Submit vote

Conceptual request:

```json
{
  "poll_id": "poll_001",
  "option_id": "weapons",
  "player_id": "installation-or-account-id"
}
```

Conceptual response:

```json
{
  "accepted": true,
  "my_vote": "weapons"
}
```

## Identity and duplicate voting

The first release does not require perfect election-grade identity. It requires reasonable protection against accidental/naive duplicate voting.

Possible stages:

### Stage 1 — installation identity

Generate a random persistent installation ID and accept one vote per installation per poll.

Advantages:

- Very low friction.
- No account UI.
- Fast to ship.

Weaknesses:

- Reinstall/reset can create another identity.
- Determined users can vote multiple times.

This may be acceptable for early community feature polls.

### Stage 2 — platform/account identity

If abuse matters later, migrate to platform authentication or an optional BOX DEFENSE account.

Do not add login complexity until it solves a real problem.

## Security rules

- No admin token inside the game binary.
- Validate poll state and option IDs server-side.
- Enforce one recorded vote per chosen identity strategy server-side.
- Rate-limit vote submission endpoints.
- Treat all client-provided vote totals as untrusted; ideally never send totals from client at all.
- Use HTTPS.

## Failure behavior

Voting is optional to moment-to-moment gameplay.

If networking fails:

- Main gameplay remains playable.
- Vote screen shows a simple retry/offline message.
- Never block startup because the poll cannot load.

If submission outcome is uncertain:

- Re-fetch poll/my-vote state before allowing another submission attempt.

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

A full custom admin website is not mandatory. A protected database console or minimal script can be enough initially if it is safe and reliable.

## Poll history

Long term, store immutable completed poll records so the game can show a community history such as:

```text
#001 Weapons vs New Enemies → Weapons
#002 Laser vs Rocket → Laser
#003 Big Box Legs vs Tiny Box Swarm → Big Box Legs
```

This history is part of the game's identity and gives future players context for why strange features exist.

## Implementation timing

Do not start the voting backend before the local core game loop exists.

Recommended order:

1. FP-01 combat simulation.
2. Actual waves/death/restart.
3. Minimal upgrade loop.
4. Application shell.
5. Voting client/backend.
6. Release polish.

The architecture should be ready for voting, but development time should first prove that BOX DEFENSE is a game.
