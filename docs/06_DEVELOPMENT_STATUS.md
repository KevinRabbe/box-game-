# BOX DEFENSE — Development Status

## Current milestone

**First Playable — basic survival loop**

## Working rule

Runtime verification and implementation proceed in parallel. We do **not** stop development merely because a manual Godot test is still pending. Validation remains tracked, and any runtime issue found later is fixed before release.

## Implemented in code

### Combat foundation

- [x] Godot 4.x project configuration.
- [x] Portrait reference viewport (720 × 1280).
- [x] Reusable `HealthComponent`.
- [x] Reusable `MovementComponent`.
- [x] Reusable `TargetingComponent`.
- [x] Reusable `WeaponComponent`.
- [x] Reusable `ContactDamageComponent`.
- [x] Projectile scene and behavior.
- [x] Enemy box scene and behavior.
- [x] Player box scene and automatic targeting/firing.
- [x] Perimeter enemy spawner.

### First playable loop

- [x] Player has 100 HP.
- [x] Enemies damage the player when they reach the center.
- [x] Contact resolves by removing the attacking enemy.
- [x] Explicit wave progression.
- [x] Enemy count increases each wave.
- [x] HUD displays player HP, wave, and active enemy count.
- [x] Player can die.
- [x] Game-over overlay displays the reached wave.
- [x] Restart reloads a clean run.

## Runtime verification still pending

These checks are important, but they do not block continued implementation:

- [ ] Open the project in a Godot 4.x editor/runtime.
- [ ] Confirm all scripts parse in the target Godot version.
- [ ] Confirm enemies collide with the central `StaticBody2D` correctly.
- [ ] Confirm waves advance only after the current wave is cleared.
- [ ] Confirm player death stops new waves and shows the game-over UI.
- [ ] Confirm restart produces a clean new run.
- [ ] Let the simulation run for at least five minutes without debugger errors.

## Current playable behavior

```text
Start run
   ↓
Wave begins
   ↓
Boxes spawn around arena
   ↓
Boxes move toward player
   ↓
Player automatically shoots nearest box
   ↓
Killed boxes disappear
   ↓
Surviving boxes hit player
   ↓
Clear wave → next larger wave
   ↓
Player reaches 0 HP
   ↓
GAME OVER
   ↓
RESTART
```

## Next implementation target

Once this basic survival loop is structurally in place, the next useful layer is the minimum run economy:

1. Coins awarded for kills.
2. Damage upgrade.
3. Attack-speed upgrade.
4. Max-HP upgrade.
5. Range upgrade.

Do not add art complexity, inventory, permanent progression, pets, multiple maps, or community-voted gameplay features yet.
