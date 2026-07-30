# BOX DEFENSE — Development Status

## Current milestone

**FP-01 — A box shoots a box**

## Status

The first implementation pass is now in the repository.

### Implemented in code

- [x] Godot 4.x project configuration.
- [x] Portrait reference viewport (720 × 1280).
- [x] `HealthComponent`.
- [x] `MovementComponent`.
- [x] `TargetingComponent`.
- [x] `WeaponComponent`.
- [x] Projectile scene and behavior.
- [x] Enemy box scene and behavior.
- [x] Player box scene and automatic targeting/firing.
- [x] Continuous perimeter enemy spawner.
- [x] First playable game scene.
- [x] Minimal debug HUD with enemy count.

### Still required before FP-01 can be called complete

- [ ] Open the project in a Godot 4.x editor/runtime.
- [ ] Confirm all scripts parse without errors in the target Godot version.
- [ ] Run the manual acceptance tests in `04_FIRST_PLAYABLE_SPEC.md`.
- [ ] Fix any runtime/scene issues found by that test.
- [ ] Let the simulation run for at least five minutes without errors.

## Important scope note

Do **not** begin waves, coins, player death, upgrades, menus, or voting until the FP-01 acceptance test has passed.

The repository has reached **implementation-ready first playable**, not yet **verified first playable**, because this environment does not currently provide a Godot executable to run the project.

## Next action in Godot

1. Clone/open the repository.
2. Open `project.godot` in Godot 4.x.
3. Run the project (`F6/F5` as appropriate).
4. Verify:
   - enemies appear near all four edges;
   - enemies move toward the center;
   - the center box targets automatically;
   - projectiles travel visibly;
   - three 10-damage hits kill a 30-health enemy;
   - dead enemies disappear;
   - projectiles eventually clean themselves up;
   - enemy count continues updating;
   - no debugger errors accumulate.

## After FP-01 passes

The next milestone is deliberately limited to:

1. Enemy contact damage.
2. Player health/death.
3. Explicit wave progression.
4. Restart flow.

Nothing else is required yet.
