# BOX DEFENSE

A deliberately minimal 2D defense game built around one rule: **the community decides what gets added next**.

The launch game is intentionally made from simple boxes and basic shapes. The first technical target is a tiny, clean, modular playable build where enemies approach a central box and the central box automatically shoots them.

## Current target

**First Playable (FP-01): A box shoots a box.**

- A player box sits in the center of a portrait arena.
- Enemy boxes spawn around the arena edge.
- Enemies move toward the player.
- The player automatically targets the nearest enemy in range.
- The player automatically fires projectiles.
- Projectiles deal damage.
- Enemies die at zero health.
- The loop continues indefinitely.

No coins, waves, menus, backend, voting, art assets, or progression are required for FP-01.

## Documentation

- [Product vision](docs/01_PRODUCT_VISION.md)
- [Architecture](docs/02_ARCHITECTURE.md)
- [Development roadmap](docs/03_ROADMAP.md)
- [First playable specification](docs/04_FIRST_PLAYABLE_SPEC.md)
- [Community voting plan](docs/05_COMMUNITY_VOTING.md)

## Engine

Godot 4.x / GDScript.

## Project principle

> Keep the core stable. Add future community-voted features as small, replaceable modules whenever possible.
