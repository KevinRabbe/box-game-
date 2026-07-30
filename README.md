# BOX DEFENSE

A deliberately minimal 2D defense game built around one rule: **the community decides what gets added next**.

The game is intentionally made from boxes and basic shapes. Minimal visuals are part of the identity, not temporary placeholder art.

## Current state

The repository now contains a feature-complete implementation pass for the **first playable**.

Current intended loop:

```text
Main Menu
   ↓
PLAY
   ↓
Boxes attack the center
   ↓
Player auto-shoots
   ↓
Kills earn coins
   ↓
Buy four run upgrades
   ↓
Clear increasingly large waves
   ↓
Every 10th wave → BIG BOX
   ↓
Die
   ↓
Restart / Main Menu
```

Implemented gameplay:

- Central player box with automatic targeting and shooting.
- Normal, Fast, and Heavy enemy boxes.
- Big Box boss every tenth wave.
- Player health and enemy contact damage.
- Endless wave progression.
- Coin rewards for kills.
- Damage, fire-rate, max-HP, and range upgrades.
- Game-over and restart flow.
- Highest-wave local save.

Implemented application shell:

- Minimal main menu.
- Community Vote entry.
- Persistent installation ID.
- Remote voting client boundary.
- Voting backend scaffold under `backend/`.
- Headless Godot validation workflow under `.github/workflows/`.

## Community voting

The Godot vote client is implemented but the production backend URL is intentionally blank until a real backend is deployed.

The backend scaffold provides:

```text
GET  /polls/active
POST /votes
```

See [Community voting](docs/05_COMMUNITY_VOTING.md) and [backend deployment notes](backend/README.md).

## Important development rule

Do not turn the first release into a large game before publishing it.

The point is to ship a small, deliberately basic BOX DEFENSE and let players vote on future additions.

## Documentation

- [Product vision](docs/01_PRODUCT_VISION.md)
- [Architecture](docs/02_ARCHITECTURE.md)
- [Development roadmap](docs/03_ROADMAP.md)
- [First playable specification](docs/04_FIRST_PLAYABLE_SPEC.md)
- [Community voting plan](docs/05_COMMUNITY_VOTING.md)
- [Development status](docs/06_DEVELOPMENT_STATUS.md)

## Engine

Godot 4.x / GDScript.

## Project principle

> Keep the core stable. Add future community-voted features as small, replaceable modules whenever possible.
