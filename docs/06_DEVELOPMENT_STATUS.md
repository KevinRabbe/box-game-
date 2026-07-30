# BOX DEFENSE — Development Status

## Current milestone

**First Playable — feature-complete implementation pass**

## Working rule

Runtime verification and implementation proceed in parallel. We do **not** stop development merely because a manual Godot test is still pending. Validation remains tracked, and any runtime issue found later is fixed before release.

A GitHub Actions workflow now also attempts a headless Godot parse on every push and pull request.

## Implemented in code

### Combat foundation

- [x] Godot 4.x project configuration.
- [x] Portrait reference viewport (720 × 1280).
- [x] Reusable `HealthComponent`.
- [x] Reusable `MovementComponent`.
- [x] Reusable `TargetingComponent`.
- [x] Reusable `WeaponComponent`.
- [x] Reusable `ContactDamageComponent`.
- [x] Reusable `RewardComponent`.
- [x] Projectile scene and behavior.
- [x] Player box scene and automatic targeting/firing.
- [x] Perimeter enemy spawner.

### Enemies and waves

- [x] Normal Box.
- [x] Fast Box.
- [x] Heavy Box.
- [x] Big Box boss.
- [x] Fast Box starts appearing from later waves.
- [x] Heavy Box starts appearing from later waves.
- [x] Every tenth wave is a Big Box boss wave.
- [x] Explicit wave progression.
- [x] Enemy count increases each normal wave.

### First playable loop

- [x] Player has health.
- [x] Enemies damage the player when they reach the center.
- [x] Contact resolves by removing the attacking enemy.
- [x] HUD displays HP, wave, enemies, coins, destroyed boxes, and combat stats.
- [x] Player can die.
- [x] Game-over summary.
- [x] Restart flow.
- [x] Return-to-menu flow.

### Run economy and upgrades

- [x] Killed enemies award configurable coin rewards.
- [x] Damage upgrade.
- [x] Fire-rate upgrade.
- [x] Max-HP upgrade.
- [x] Range upgrade.
- [x] Upgrade prices scale by level.
- [x] Upgrade buttons enable/disable based on affordability.
- [x] Upgrades operate through a controlled player API instead of reaching into unrelated scene internals.

### Application shell

- [x] Minimal BOX DEFENSE main menu.
- [x] Highest-wave display.
- [x] Versioned local save file.
- [x] Persistent random installation/player ID.
- [x] Main menu links to gameplay and community voting.

### Community voting client

- [x] Dedicated vote screen.
- [x] Dedicated `VoteService` networking boundary.
- [x] Load-active-poll request.
- [x] Submit-vote request.
- [x] Two-option poll UI.
- [x] One persistent installation ID is sent with vote requests.
- [x] Voting failure does not block gameplay.
- [x] Development placeholder shown while no backend URL is configured.
- [ ] Deploy voting backend.
- [ ] Configure production voting API URL.

## Runtime verification still pending

These checks are important, but they do not block continued implementation:

- [ ] Confirm the automated headless Godot workflow passes on the current repository state.
- [ ] Open the project in a Godot editor/runtime for visual verification.
- [ ] Confirm enemy/player collisions behave correctly.
- [ ] Confirm projectiles consistently damage all four enemy archetypes.
- [ ] Confirm coins are awarded only for kills, not enemies that reach the player.
- [ ] Confirm all four upgrades purchase and immediately affect gameplay.
- [ ] Confirm boss wave 10 starts and completes correctly.
- [ ] Confirm player death stops wave progression and shows game over.
- [ ] Confirm restart produces a clean run.
- [ ] Confirm highest wave survives application restart.
- [ ] Let gameplay run for at least five minutes without debugger errors.

## Current intended flow

```text
Launch
   ↓
Main Menu
   ├──────────────→ Community Vote
   │                    ↓
   │              Remote poll when backend exists
   │
   ↓
PLAY
   ↓
Wave begins
   ↓
Normal / Fast / Heavy boxes approach
   ↓
Player auto-shoots
   ↓
Kills award coins
   ↓
Buy Damage / Fire Rate / Max HP / Range
   ↓
Every 10th wave → BIG BOX
   ↓
Eventually player reaches 0 HP
   ↓
GAME OVER
   ↓
Restart or Main Menu
```

## Remaining work before a public test build

1. Fix any failures reported by the Godot validation workflow.
2. Perform one visual/runtime pass in Godot.
3. Tune obvious balance problems rather than deeply balancing the game.
4. Add tiny hit/death feedback only if needed for readability.
5. Deploy and connect the voting backend.

No inventory, permanent skill tree, pets, multiple maps, elaborate art, quests, or unrelated features should be added before the first public build.
