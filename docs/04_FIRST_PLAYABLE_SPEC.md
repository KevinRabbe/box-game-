# BOX DEFENSE — First Playable Specification (FP-01)

## Purpose

FP-01 proves the core technical loop with the smallest possible playable simulation.

The milestone name is deliberately literal:

> **A box shoots a box.**

No product feature that is not required for this sentence belongs in FP-01.

## Target platform assumptions

- Engine: Godot 4.x.
- Language: GDScript.
- Orientation: portrait.
- Reference viewport: 720 × 1280.
- Input: none required for the simulation itself.
- Visuals: primitive geometry only.

## Scene composition

### `game.tscn`

```text
Game (Node2D)
├── PlayerBox (instance)
├── EnemySpawner (Node)
├── ProjectileContainer (Node2D)
└── DebugHUD (CanvasLayer/Control)
```

The debug HUD is allowed to show only information useful to verify the milestone, such as title/instructions and live enemy count.

### `player_box.tscn`

```text
PlayerBox (Node2D)
├── Visual (Polygon2D)
├── TargetingComponent (Node)
└── WeaponComponent (Node)
```

The player does not need health in FP-01 because enemies cannot yet damage it.

### `enemy_box.tscn`

```text
EnemyBox (CharacterBody2D) [group: enemies]
├── Visual (Polygon2D)
├── CollisionShape2D
├── HealthComponent (Node)
└── MovementComponent (Node)
```

### `projectile.tscn`

```text
Projectile (Area2D)
├── Visual (Polygon2D)
└── CollisionShape2D
```

## Default tuning

The exact values can be adjusted while testing, but these are the starting values.

### Arena

- Width: 720 px.
- Height: 1280 px.
- Player position: center of viewport.
- Spawn margin: approximately 40 px from edge.

### Player

- Size: 64 × 64 px.
- Weapon damage: 10.
- Fire rate: 2 shots/second.
- Targeting range: 420 px.

### Enemy

- Size: 44 × 44 px.
- Health: 30.
- Movement speed: 90 px/second.
- Spawn interval: 0.9 seconds.

### Projectile

- Size: 10 × 10 px.
- Speed: 700 px/second.
- Lifetime: 2 seconds.

The starting numbers intentionally make an enemy survive multiple hits so damage/death behavior is visible during testing.

## Runtime behavior

### Game startup

1. `Game` positions the player at viewport center.
2. `EnemySpawner` receives the player as its movement target.
3. `EnemySpawner` starts a repeating spawn timer.

### Enemy spawning

1. Select one of four arena edges.
2. Pick a random coordinate along that edge.
3. Instantiate `enemy_box.tscn`.
4. Place the enemy at the selected spawn position.
5. Assign the player as its target.
6. Add it to the game scene.

### Enemy movement

Every physics frame:

1. `EnemyBox` asks `MovementComponent` for velocity toward player position.
2. `EnemyBox` sets its `velocity`.
3. `EnemyBox` calls `move_and_slide()`.

Enemies are allowed to overlap in FP-01. Separation/avoidance is not part of the milestone.

### Player targeting

Every frame or weapon update:

1. Ask `TargetingComponent` for the nearest node in group `enemies`.
2. Ignore freed/invalid nodes.
3. Ignore nodes farther away than targeting range.
4. Return nearest valid target or `null`.

### Weapon firing

1. `PlayerBox` passes current target to `WeaponComponent`.
2. `WeaponComponent` checks cooldown.
3. If ready and target is valid, instantiate projectile.
4. Set projectile origin to weapon/player world position.
5. Set projectile direction toward target position.
6. Set projectile damage and speed.
7. Add projectile to a configured projectile container.
8. Reset cooldown.

The projectile does not need homing in FP-01.

### Projectile collision

1. Projectile moves every physics frame.
2. Projectile `Area2D` detects enemy body on collision layer 2.
3. Projectile looks for the target's `HealthComponent` through a documented actor method or child lookup.
4. Call `take_damage(damage)`.
5. Remove projectile.

### Enemy death

1. `HealthComponent` clamps health to zero.
2. It emits `died` once.
3. `EnemyBox` handles the signal.
4. `EnemyBox` queues itself for deletion.

No coins, particles, statistics, or score hooks are required yet.

## Failure handling

### Target disappears before shot

Weapon does nothing and waits for the next update.

### Target disappears after projectile is fired

Projectile continues in its original direction until it hits another eligible enemy or expires.

### Projectile hits nothing

Lifetime timer removes it.

### Enemy reaches player center

For FP-01, the enemy may simply continue to occupy/approach the center. Contact damage is explicitly deferred.

## Manual acceptance procedure

### Test A — Spawn and movement

1. Start `game.tscn`.
2. Confirm enemy boxes appear from multiple arena edges.
3. Confirm all enemies move toward the center.

Pass condition: spawning and movement continue with no script errors.

### Test B — Targeting

1. Let several enemies enter range.
2. Observe the player firing.

Pass condition: shots generally aim toward the nearest in-range enemy and switch to another valid enemy after the target dies.

### Test C — Damage and death

1. Observe a fresh enemy taking hits.
2. Confirm it survives until its configured health is exhausted.
3. Confirm it disappears after the lethal hit.

Pass condition: no enemy dies early and no dead enemy remains targetable.

### Test D — Projectile cleanup

1. Observe missed projectiles.
2. Let the game run for several minutes.

Pass condition: projectiles expire and the scene does not accumulate indefinite projectile nodes.

### Test E — Stability

Let the simulation run for at least five minutes.

Pass condition:

- No unhandled errors.
- Enemies continue spawning.
- Player continues targeting/firing.
- Killed enemies are removed.
- Performance remains reasonable for the deliberately simple scene.

## Definition of done

FP-01 is complete when Tests A–E pass in the Godot editor/runtime.

After that, the next milestone is **player health + contact damage + actual waves**, not additional visual polish.
