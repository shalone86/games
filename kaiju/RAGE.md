# Kaiju Rage (working title)

The real game, built from the three workshop modes you liked (stomp + breath,
grab + throw, leap + dash) plus a reworked survivor-style skill system.

```
cd games
cd kaiju
load rage
run
```

![kaiju rage](shots/rage_sheet.png)

All art and sounds are stand-ins; the names (Gora, Luna, Korax) are
placeholders too. They're original on purpose: Godzilla, Mothra and the
others are trademarks, so the shipped game needs its own monsters.

---

## Controls

| button | does |
|---|---|
| arrows | walk |
| **X** (hold) | breath, in the direction you face. Drains the bar under your feet; let go to refill |
| **Z** | **dash** (walkers) or **fly** (flyers): Z takes off, Z again dives down and stomps |
| **Z + X** together | **grab** what's in front of you: a tank, helicopter, big tank, or a whole building |
| Z or X while holding something | **throw** it |
| Z or X while standing on a new skill orb | put it in **slot 1** (Z) or **slot 2** (X) |

Z waits 5 frames (a sixth of a second) before dashing or flying, to see if X
comes too. That's what lets Z+X mean "grab" without a third button. Breath
waits the same.

- **Dash:** quick burst, can't be hurt, 3 damage to buildings in the way
  (towers stop you), 1⅓ s cooldown.
- **Fly:** Z takes off; fly over everything for up to 5 s. Tanks, bombs,
  punches and the rival's bite can't reach you up there, but **missiles and
  the rival's fire can**. Z again (or running out of time) dives down:
  whatever you land on is crushed, with a big shockwave. Then a **3 s
  cooldown**. The green "z" in the corner lights up when it's ready.

## The kaiju

| | kaiju | moves | hp | speed | skill orbs |
|---|---|---|---|---|---|
| 1 | **Gora**, big lizard | dash | 10 | medium | flame, stomp, roar, hide, rejuv |
| 2 | **Luna**, giant moth | fly | 8 | fast | gust, spores, zap, dust, cocoon |
| 3 | **Korax**, spiked tank | dash | 13 | slow | spikes, quake, shell, thorns, rock |

Your rule, walkers dash and flyers fly, decides each one's Z move (it's
`z="dash"` or `z="fly"` in the roster, tab 1, so it's one word to change).

## Skill orbs (the survivor part)

Each kaiju has **its own 5 skills**, each a different orb color. They work by
themselves, no buttons. You start with the first one.

- Two **slots**. Step on an orb: an empty slot takes it; the **same skill
  levels up** (up to 3, the dots after its name); otherwise a prompt appears
  ("new rejuv! z:slot 1 x:slot 2"). Press Z or X to swap it in, or **just walk
  off** to leave it there (you can come back for it). Nothing pauses.
- Orbs drop from offices and towers (10%), big enemies (35%), and always from
  a beaten rival.

**Gora** (your list):

| orb | color | what it does (gets stronger each level) |
|---|---|---|
| flame | orange | every 1–2 s, a flame jet at the nearest enemy |
| stomp | brown | a shockwave around you every few seconds |
| roar | lavender | every 5–7 s, everything nearby goes **dizzy** (wanders, shoots the wrong way; shows a "?") |
| hide | grey | always on: stone-grey skin, take 20/40/60% less damage (was "rage"; renamed so only rage mode is rage) |
| rejuv | green | always on: heals over time, but you're slower and take 50% more damage |

**Luna:** gust (pushes enemies away, blows away shots) · spores (circle you,
chew buildings, block shots) · zap (lightning at the nearest enemy) · dust
(leaves a cloud that hurts what's in it) · cocoon (heals while standing
still).

**Korax:** spikes (a ring of spikes in every direction) · quake (a big slow
shockwave) · shell (can't be hurt for 2–3½ s, every 6–9 s) · thorns
(getting hit blasts everything around you) · rock (lobs a boulder at the
nearest enemy).

## Rage mode

About a third of what you smash drops a **coin**. 36 coins fill the **rage** meter (about 1–2 times a game),
and it goes off by itself (think Mario's star, or Super Sonic):

- A white flash, a freeze, three shockwaves and a giant wobbling
  **RAGE MODE!**
- For **10 seconds**: you're 1.5× bigger, glowing, cycling through every
  color, with a sparkle trail and its own fast music.
- **Can't be hurt**, 1.5× speed, **double damage and double points**, and
  anything you touch explodes. Breath is free and almost twice as long, in
  rainbow.
- The meter drains as it runs; in the last 2 seconds you blink, so you know
  it's ending.

## The rival kaiju

At 25 seconds another kaiju (one you didn't pick, tinted purple) arrives.

- It **hunts** you: up close it hits for 2; from a distance it breathes a
  burst of fire at you. It tramples houses as it goes.
- Below **30% hp** it **runs away** and heals; at **70%** it comes back. Its hp
  bar turns blue while it's fleeing.
- Off screen, an **arrow on the edge** points to it: red **!** = hunting,
  blue **+** = running and healing.
- Beat it: 500 points, a pile of coins, and a skill orb. 20 s later a new one
  comes, 10 hp stronger each time.

## Waves

A new wave every 25 seconds (each one also drops a skill orb near you); 8 waves, so the final wave comes at about 3 minutes.

| wave | new |
|---|---|
| 1 | tanks, helicopters |
| 2 | (the rival arrives) |
| 3 | **big tanks**: double size, double attack, double defense (2 hp that takes half damage) |
| 4 | **bombers**: double size; fly straight over you and drop bombs that blow up buildings (and other enemies) too |
| 6 | **mechs**: kaiju-sized, 10 hp at double defense, punch up close, fire 3 missiles |
| 8 | **final wave**: 3 mechs at once. Beat them and the city is yours (+1000) |

Enemies arrive in **squads** (tanks and helicopters come in groups that grow
with the waves), a new group every 2 s at first and every ⅓ s by the end, up
to **13 enemies at once in wave 1, rising to 48 by wave 8**. The game can
handle about 60 at once without slowing down (it only checks the buildings
near each thing instead of all 300), so this can go higher.

Best score saves per kaiju.

---

## Where things are in the code

| tab | what |
|---|---|
| 0 | setup, title/play/over, **`buttons()`** (all of the Z / X / Z+X logic) |
| 1 | **`roster`** (the kaiju) and **`sk`** (the 15 skills), skill helpers |
| 2 | the city, `hit()` (all damage goes through it) |
| 3 | `upd_play` (skills each frame, rage mode, dash, fly), breath, grab/throw, `hurt` |
| 4 | `et` (enemy stats), `pick()` (which enemy each wave), enemies, bombs, **`rival_ai`** |
| 5 | drops (coins, hearts, orbs), pickups and the swap prompt, thrown things, effects |
| 6 | drawing, HUD, title |

### Adding a kaiju

1. Draw 3 sprites of 16 × 16 next to each other (walk 1, walk 2, attack) in a
   free spot, e.g. sprite 100.
2. Add 5 skills to the end of `sk` (copy any; `f` fires and returns the
   frames until the next time, `p` runs every frame).
3. Add a line to `roster` with `sp=100` and its 5 skill numbers.

### Changing an enemy

`et` in tab 0 is one line per enemy: sprite, size, hp, defense (also its
attack), speed, points. Defense 2 means it takes half damage and hits for 2.

### Room left

About **7,400 of 8,192 tokens** are used. A fourth kaiju with simple skills
still fits (a skill is about 30–60 tokens); anything bigger means trimming
something first, which I can do.

## Sprite numbers (new in this cart)

| sprite | what |
|---|---|
| 0 / 2 / 4 | Gora: walk, walk, attack |
| 64 / 66 / 68 | Luna |
| 70 / 72 / 74 | Korax |
| 76 | big tank (16 × 16) · 78 bomber (16 × 16) |
| 96 / 98 | mech walk frames (16 × 16) |
| 41 | coin |

The rest are the same as the workshop (buildings, tank, helicopter, shells,
tree, heart).

## Testing

```bash
python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_smoke.lua
```

plays all three kaiju: the grab-and-throw chord, dash/fly, breath, orb pickups and swaps,
rage mode, every skill at level 3, the rival, the late waves and the final-wave
win. `kaiju/rage_shots.lua` retakes the screenshots.
