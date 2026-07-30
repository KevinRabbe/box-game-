# BOX DEFENSE — Architecture

## Goal

The architecture must support two competing needs:

1. The first playable should stay tiny and fast to build.
2. Future community-voted features should be addable without rewriting the game every time.

The answer is a small stable core plus reusable components, not a large framework.

## Architectural principles

### Composition over inheritance

Avoid deep class trees such as:

```text
Enemy
└── FastEnemy
    └── ArmoredFastEnemy
        └── ExplodingArmoredFastEnemy
```

Prefer actors assembled from focused capabilities:

```text
EnemyBox
├── HealthComponent
├── MovementComponent
└── actor script
```

Future examples:

```text
EnemyBox
├── HealthComponent
├── MovementComponent
├── ShieldComponent
├── BurnableComponent
└── ExplodeOnDeathComponent
```

### One responsibility per component

A component should do one thing well and expose a small API.

Initial reusable components:

- `HealthComponent`
- `MovementComponent`
- `TargetingComponent`
- `WeaponComponent`

Initial combat object:

- `Projectile`

Initial actors/services:

- `PlayerBox`
- `EnemyBox`
- `EnemySpawner`

### Actors coordinate; components implement capabilities

An actor script is allowed to coordinate components but should not duplicate their logic.

Example:

```text
PlayerBox
    asks TargetingComponent for a target
    passes target to WeaponComponent
```

The player should not contain its own target search algorithm or fire-rate timer.

### Signals instead of unnecessary hard dependencies

Use Godot signals for important state transitions:

```text
HealthComponent.health_changed
HealthComponent.died
Projectile.hit
```

Later systems can listen without the health component knowing about coins, waves, analytics, achievements, or effects.

## First playable dependency graph

```text
Game
├── PlayerBox
│   ├── TargetingComponent
│   └── WeaponComponent
│
├── EnemySpawner
│   └── creates EnemyBox
│       ├── HealthComponent
│       └── MovementComponent
│
└── ProjectileContainer
    └── receives Projectile instances from WeaponComponent
```

Runtime flow:

```text
EnemySpawner creates enemy
        ↓
Enemy moves toward PlayerBox
        ↓
TargetingComponent finds nearest enemy
        ↓
WeaponComponent fires Projectile
        ↓
Projectile collides with enemy
        ↓
Projectile calls HealthComponent.take_damage()
        ↓
HealthComponent emits died
        ↓
EnemyBox removes itself
```

## Proposed repository structure

```text
box-game-/
├── docs/
│   ├── 01_PRODUCT_VISION.md
│   ├── 02_ARCHITECTURE.md
│   ├── 03_ROADMAP.md
│   ├── 04_FIRST_PLAYABLE_SPEC.md
│   └── 05_COMMUNITY_VOTING.md
│
├── scenes/
│   ├── game/
│   │   └── game.tscn
│   ├── player/
│   │   └── player_box.tscn
│   ├── enemies/
│   │   └── enemy_box.tscn
│   └── combat/
│       └── projectile.tscn
│
├── scripts/
│   ├── components/
│   │   ├── health_component.gd
│   │   ├── movement_component.gd
│   │   ├── targeting_component.gd
│   │   └── weapon_component.gd
│   ├── player/
│   │   └── player_box.gd
│   ├── enemies/
│   │   ├── enemy_box.gd
│   │   └── enemy_spawner.gd
│   ├── combat/
│   │   └── projectile.gd
│   └── game/
│       └── game.gd
│
├── project.godot
└── README.md
```

This structure can grow later with `data/`, `ui/`, `voting/`, `save/`, and `backend/` folders only when those systems actually exist.

## Component contracts

### HealthComponent

Responsibility: own current/max health and death state.

Public API:

```text
take_damage(amount)
heal(amount)
reset_health()
is_dead()
```

Signals:

```text
health_changed(current, maximum)
died
```

Health should not decide what happens after death.

### MovementComponent

Responsibility: calculate movement toward a target position.

Public API:

```text
velocity_toward(from_position, target_position)
```

The actor remains responsible for calling `move_and_slide()` because movement is tied to the actor's body type.

### TargetingComponent

Responsibility: find the nearest valid target inside a configured range.

Initial target source: Godot group `enemies`.

Public API:

```text
find_nearest_target(origin)
```

Later this can be extended with targeting policies without changing the weapon.

### WeaponComponent

Responsibility:

- Track fire cooldown.
- Create projectiles.
- Configure projectile damage/speed.
- Fire toward a target.

Public API:

```text
try_fire(origin, target)
```

The weapon should not search for targets itself.

### Projectile

Responsibility:

- Move in one direction.
- Detect valid collision.
- Apply damage to a target health component.
- Destroy itself on hit or timeout.

## Groups and collision layers

Initial conventions:

### Groups

- `enemies` — any valid enemy target.

### Physics layers

Keep the first playable minimal:

- Enemy bodies live on collision layer 2.
- Projectiles scan collision mask 2.

Additional layers should only be introduced when actual gameplay requires them.

## Data-driven evolution

The first playable can use exported values directly on components. Before the number of enemy/weapon variants grows, migrate repeated configuration into Godot `Resource` definitions.

Likely future resources:

```text
EnemyDefinition
WeaponDefinition
UpgradeDefinition
WaveDefinition
```

Example future `EnemyDefinition` fields:

```text
id
max_health
speed
contact_damage
reward
scale
```

Do not build these resources before they reduce real duplication.

## Global systems later

Only introduce autoload/singleton systems when multiple scenes genuinely need them.

Potential later globals:

- `GameEvents`
- `SaveManager`
- `VoteService`

The first playable does not need them.

## Save compatibility

When persistent progression is introduced, use explicit save versions from day one:

```text
save_version: 1
```

Each breaking save format change must have a migration path.

Never serialize arbitrary live nodes as the long-term save format.

## Voting architecture boundary

Voting is not part of combat and must remain separate.

```text
Godot client
    ↓ HTTPS
Voting API
    ↓
Database
```

The client should receive poll data and submit a vote. It should not contain secret administrative credentials and should not determine final vote totals locally.

## Feature-flag readiness

Once remote features exist, new community-voted systems should be capable of being disabled independently where practical.

Example conceptual flags:

```text
chain_lightning_enabled
bosses_enabled
criticals_enabled
```

Do not implement a full feature-flag platform during the first playable.

## Testing strategy

At this stage, prioritize deterministic component behavior and manual integration checks.

Component-level checks:

- Health never drops below zero.
- Death emits once.
- Movement returns zero velocity at the target.
- Targeting ignores invalid/freed nodes.
- Weapon respects cooldown.
- Projectile times out when it hits nothing.

Integration acceptance:

- Enemies continuously spawn.
- Enemies move toward the central box.
- The player repeatedly shoots the nearest valid enemy.
- Projectile hits reduce health.
- Killed enemies disappear.
- The loop can run for several minutes without errors or accumulating dead references.

## Anti-overengineering rules

Do not create an abstraction merely because a future feature might need it.

Create a reusable system when at least one of these is true:

- It is already used by multiple actors.
- The responsibility is clearly independent.
- We have a concrete near-term feature that needs to swap or extend the behavior.

The architecture should make change cheap, not make the first build slow.
