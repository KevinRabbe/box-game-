# BOX DEFENSE — Product Vision

## One-sentence pitch

**BOX DEFENSE is a deliberately basic 2D defense game that starts with boxes shooting boxes, then lets players vote inside the game on what the developer adds next.**

## Why the game exists

The core novelty is not graphical complexity. It is visible community ownership of the roadmap.

The game should be publishable while it is still extremely small, because minimalism is part of the product rather than a temporary placeholder. Every major future addition can become a community event and a piece of content for the game's social channels.

The project therefore has two products that reinforce one another:

1. A simple, satisfying mobile game.
2. A public development process where players choose between curated options.

## Product promise

Players should understand this immediately:

> You play the game. You vote. The winning option becomes a real update.

We curate the choices. The community chooses between them.

This keeps scope under control while making the players feel involved.

## Launch identity

### Name

BOX DEFENSE

### Visual language

- Dark background.
- White/light geometric objects.
- One accent color for interactive UI.
- Plain, bold sans-serif typography.
- No detailed character art required.
- No visual element should exist only to imitate a more expensive game.

### Tone

Dry, simple, deadpan, slightly absurd.

Example social post:

> I made a game. It is Box Defense.

Then show several seconds of boxes shooting boxes.

### Branding rule

The brand can evolve when the game evolves. At launch, the square itself is enough.

## Core gameplay fantasy

The player protects a central box from incoming boxes.

The central box automatically attacks. The player's long-term role is to improve the defense, survive increasingly difficult pressure, and participate in votes that change what the game becomes over time.

## Stable core loop

```text
Spawn enemies
    ↓
Enemies approach player
    ↓
Player automatically targets
    ↓
Player attacks
    ↓
Enemy takes damage
    ↓
Enemy dies
    ↓
Reward/progression systems react
    ↓
Pressure increases
```

The first playable only implements the combat portion of this loop. Rewards and progression come later.

## BOX DEFENSE v1.0 target

The intended first store-ready version is still deliberately small.

### Gameplay

- One central player box.
- Basic automatic shooting.
- Three simple enemy archetypes.
- Endless wave progression.
- A large box boss at predictable intervals.
- Coins earned during runs.
- Four run upgrades:
  - Damage.
  - Attack speed.
  - Maximum health.
  - Range.
- Game over and restart flow.
- Local save for persistent records/settings where needed.

### Community

- One active poll at a time.
- Two curated choices.
- One vote per player identity per poll.
- Poll countdown.
- Aggregate result display.
- Previous poll result/history.
- Poll content controlled remotely so a new app build is not required to start a new vote.

## Explicit non-goals for v1.0

Do not add these unless required by a later decision:

- Multiplayer.
- Pets.
- Inventory.
- Equipment rarity.
- Skill tree.
- Multiple maps.
- Story/campaign.
- Quests.
- Clans.
- Chat.
- Large cosmetic system.
- Elaborate enemy art.
- Complex boss scripting.
- Dozens of weapons.
- Prestige/meta progression unless specifically chosen after the basic run loop is proven.

## Design rules

### 1. Minimal does not mean unresponsive

The geometry can remain primitive, but interactions should eventually feel deliberate through timing, hit feedback, sound, particles, small knockback, and clean UI transitions.

### 2. Curate every vote

Never give the community an option we are unwilling or unable to build.

### 3. A vote should produce a visible change

Winning features should be easy for a player to recognize in the next relevant update.

### 4. Prefer systems that compose

A future feature such as burn, shield, split-on-death, or chain lightning should ideally attach to existing actors rather than require a rewrite.

### 5. The roadmap is allowed to stay uncertain

We deliberately decide only enough to ship the current milestone. Future content is supposed to be influenced by players.

## Success criteria

The project is working as intended when:

- A new player understands the game in seconds.
- The first session starts with almost no explanation.
- The game can be updated frequently without destabilizing the core loop.
- A community vote can be changed remotely.
- Social posts can show one concrete player-chosen change with almost no production overhead.
- The game's simplicity feels intentional rather than abandoned.
