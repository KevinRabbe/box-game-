# BOX DEFENSE — Development Roadmap

## Objective

Reach a **first playable build as quickly as possible**, while establishing a codebase that can accept frequent community-voted additions without turning every update into a rewrite.

The roadmap is intentionally staged. Later phases are described in enough detail to guide architecture, but they are not permission to build them early.

---

# Phase 0 — Repository and technical foundation

## Goal

Create the minimum project structure and documentation required to build safely.

## Deliverables

- Godot 4.x project initializes successfully.
- Mobile-first portrait viewport configured.
- Repository documentation exists.
- Modular component boundaries are documented.
- Basic scene/script directory structure exists.

## Exit criteria

- Opening the project in Godot produces no missing-script or missing-resource errors.
- `game.tscn` can be set as the main scene.

---

# Phase 1 — FP-01: A box shoots a box

## Goal

Produce the first actual playable simulation.

This is the current development target.

## Required systems

### 1. Player box

- Fixed at arena center.
- Visible as a simple square.
- Has a `TargetingComponent`.
- Has a `WeaponComponent`.

### 2. Enemy box

- Visible as a simple square.
- Spawns around the arena perimeter.
- Moves toward the player.
- Has health.
- Joins the `enemies` group.

### 3. Automatic targeting

- Player searches for nearest valid enemy.
- Only targets enemies inside weapon range.
- Handles enemies disappearing without errors.

### 4. Automatic firing

- Weapon obeys fire rate.
- Weapon creates projectiles.
- Projectile direction is fixed when fired for this milestone.

### 5. Projectile damage

- Projectile moves through world space.
- Projectile collides with enemy body.
- Projectile applies damage.
- Projectile removes itself after a hit or lifetime timeout.

### 6. Enemy death

- Enemy reaches zero health.
- Death signal occurs once.
- Enemy removes itself.

### 7. Continuous spawning

- New enemies continue to appear.
- Spawn positions are around the arena edge.
- The simulation does not require player input.

## FP-01 acceptance test

Launch the game and do nothing.

Expected result:

1. Enemy boxes repeatedly appear near the edges.
2. They move toward the center.
3. The center box automatically attacks the nearest enemy in range.
4. Projectiles visibly travel toward enemies.
5. Enemies take multiple hits if configured with enough health.
6. Enemies disappear when killed.
7. New enemies continue spawning.
8. The simulation remains stable for at least several minutes.

## Not included

- Enemy contact damage.
- Player death.
- Waves.
- Coins.
- Upgrade UI.
- Main menu.
- Save system.
- Voting.
- Backend.
- Sound.
- Particles.

## Definition of done

FP-01 is done when the acceptance test passes. Do not expand its scope because another feature looks easy.

---

# Phase 2 — MVP combat loop

## Goal

Turn the simulation into a small game with a beginning, pressure curve, and end.

## Deliverables

### Player health

- Enemy reaching the player deals contact damage.
- Enemy is removed or otherwise resolves the contact after dealing damage.
- Player health is visible.
- Player can die.

### Wave manager

- Explicit wave number.
- Spawn budget/count per wave.
- Delay between waves.
- Difficulty scales by wave.
- Every tenth wave can spawn a Big Box boss.

### Game over

Display at minimum:

- Wave reached.
- Boxes destroyed.
- Restart button.
- Main menu button once a menu exists.

## Exit criteria

A player can start a run, survive multiple waves, lose, and restart without reloading the application.

---

# Phase 3 — Run economy and upgrades

## Goal

Add the minimum decision-making required to make repeated runs interesting.

## Deliverables

### Coins

- Enemies award coins when killed.
- Rewards come from enemy data, not hardcoded UI logic.
- Current run coins are visible.

### Four launch upgrades

- Damage.
- Attack speed.
- Maximum health.
- Range.

### Upgrade rules

- Costs increase predictably.
- Changes apply immediately.
- Upgrade system modifies stats through a controlled API rather than reaching into unrelated scripts.

## Exit criteria

The player regularly makes meaningful upgrade choices during a run and those choices visibly affect combat.

---

# Phase 4 — Minimal application shell

## Goal

Make the game navigable and ready for external testing.

## Deliverables

### Main menu

```text
BOX DEFENSE

[PLAY]
[COMMUNITY VOTE]
[SETTINGS]
```

Voting can initially show a placeholder until its service is ready.

### Settings

Only settings we actually support:

- Sound.
- Music if music exists.
- Vibration if vibration exists.

Do not create empty settings just to fill a menu.

### Save foundation

Persist only necessary local information, such as:

- Highest wave.
- Settings.
- Installation/player identifier for voting if this is the chosen identity strategy.
- Save format version.

## Exit criteria

A tester can launch, play, die, restart, close the app, reopen it, and retain the intentionally persistent values.

---

# Phase 5 — Community voting v1

## Goal

Implement the actual differentiating feature before public launch.

## User experience

One active poll with two choices.

Example:

```text
WHAT SHOULD WE ADD NEXT?

[ WEAPONS ]
    VS
[ NEW ENEMIES ]

2d 08h remaining
```

## Client requirements

- Load active poll from remote backend.
- Display question and two options.
- Allow one vote for the current player identity.
- Display vote state after submission.
- Display total/percentage results according to product decision.
- Display poll close time.
- Gracefully handle offline/network errors.

## Backend requirements

- Create/edit polls administratively.
- Open and close polls without app update.
- Store votes server-side.
- Prevent naive duplicate voting.
- Return aggregate results.
- Keep administrative credentials out of the game client.

## Exit criteria

A new poll can be created remotely, players can vote from installed builds, and the poll can close without publishing a new game version.

---

# Phase 6 — Release polish

## Goal

Make primitive visuals feel intentional.

## Priorities

1. Input/navigation reliability.
2. Mobile performance.
3. Hit readability.
4. Small death particles made from boxes.
5. Screen shake for impactful events.
6. Short, clean sound effects.
7. UI spacing and readability.
8. Device aspect-ratio testing.

## Rule

Polish interaction, not asset complexity.

A square may remain a square. It should simply feel good when it is hit.

---

# Phase 7 — Store-ready BOX DEFENSE v1.0

## Required launch content

- Central box combat.
- Three simple enemy archetypes.
- Endless waves.
- Big Box boss.
- Coins.
- Four run upgrades.
- Game over/restart.
- Minimal menu/settings.
- Stable local save.
- Live community poll.
- Previous poll result/history if time permits without threatening launch stability.

## Release checklist

### Technical

- No known crash in normal gameplay.
- Stable on target Android devices.
- Correct app pause/resume behavior.
- Networking failures do not break gameplay.
- Save corruption has a safe fallback.
- Voting backend secrets are not shipped in client.

### Product

- Store icon matches minimal brand.
- Screenshots clearly show gameplay and community vote.
- Store description explains the community-development premise.
- First real poll is ready before launch.

### Social

- YouTube channel branding exists.
- First short can be recorded from the release build.
- The content format remains intentionally simple.

---

# Phase 8 — Community-driven update cycle

Once v1.0 is public, the roadmap becomes deliberately less specific.

## Recurring cycle

```text
Curate two feasible options
        ↓
Open in-game poll
        ↓
Players vote
        ↓
Poll closes
        ↓
Implement winner
        ↓
Test/update
        ↓
Post short showing result
        ↓
Open next poll
```

## Good vote categories

- Weapon.
- Enemy behavior.
- Boss.
- Upgrade mechanic.
- Visual joke.
- Quality-of-life feature.
- New progression system.

## Scope rule

Both options in every poll must have acceptable implementation cost before the poll goes live.

---

# Technical debt policy

Because rapid updates are part of the product, technical debt must be controlled deliberately.

For each community update:

1. Identify whether the feature is a new component, new data, or a core-system change.
2. Prefer component/data additions.
3. Add tests/manual acceptance steps for the new behavior.
4. Avoid special-case branches in central scripts where possible.
5. Refactor when the same workaround appears twice.

---

# Current work queue

## NOW — FP-01

- [x] Product vision documented.
- [x] Architecture documented.
- [x] Roadmap documented.
- [x] First playable spec documented.
- [ ] Godot project configuration.
- [ ] Health component.
- [ ] Movement component.
- [ ] Targeting component.
- [ ] Weapon component.
- [ ] Projectile.
- [ ] Enemy box.
- [ ] Player box.
- [ ] Enemy spawner.
- [ ] Game scene.
- [ ] Manual FP-01 acceptance test in Godot.

## NEXT

Only after FP-01 passes:

- Enemy contact damage.
- Player health/death.
- Waves.
