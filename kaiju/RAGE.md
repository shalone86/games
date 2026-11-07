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
| **Z** | **dash** (walkers) or **leap** (flyers) |
| **Z + X** together | **grab** what's in front of you: a tank, helicopter, big tank, or a whole building |
| Z or X while holding something | **throw** it |
| Z or X while standing on a new skill orb | put it in **slot 1** (Z) or **slot 2** (X) |

Z waits 5 frames (a sixth of a second) before dashing or leaping, to see if X
comes too. That's what lets Z+X mean "grab" without a third button. Breath
waits the same.

- **Dash:** quick burst, can't be hurt, 3 damage to buildings in the way
  (towers stop you), 1⅓ s cooldown.
- **Leap:** over a second in the air, can't be hurt, crushes what you land on.
  **4 s cooldown**, since leaping is so strong. The green "z" in the corner
  lights up when it's ready.

## The kaiju

| | kaiju | moves | hp | speed | skill orbs |
|---|---|---|---|---|---|
| 1 | **Gora**, big lizard | dash | 10 | medium | flame, stomp, roar, rage, rejuv |
| 2 | **Luna**, giant moth | leap | 8 | fast | gust, spores, zap, dust, cocoon |
| 3 | **Korax**, spiked tank | dash | 13 | slow | spikes, quake, shell, thorns, rock |

Your rule, walkers dash and flyers leap, decides each one's Z move (it's
`z="dash"` or `z="leap"` in the roster, tab 1, so it's one word to change).

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
| rage | red | always on: you turn red and take 20/40/60% less damage |
| rejuv | green | always on: heals over time, but you're slower and take 50% more damage |

**Luna:** gust (pushes enemies away, blows away shots) · spores (circle you,
chew buildings, block shots) · zap (lightning at the nearest enemy) · dust
(leaves a cloud that hurts what's in it) · cocoon (heals while standing
still).

**Korax:** spikes (a ring of spikes in every direction) · quake (a big slow
shockwave) · shell (can't be hurt for 2–3½ s, every 6–9 s) · thorns
(getting hit blasts everything around you) · rock (lobs a boulder at the
nearest enemy).

## Rage meter

Half of what you smash drops a **coin**. 20 coins fill the **rage** meter,
and it goes off by itself: **RAMPAGE!** A blast around you, then 6 seconds of
double damage, more speed, can't be hurt, and walking through anything breaks
it. You flash red.

(Gora's *rage* orb and the rage meter share a name. Rename either one, e.g.
the meter to "fury", if that gets confusing.)

## The rival kaiju

At 40 seconds another kaiju (one you didn't pick, tinted purple) arrives.

- It **hunts** you: up close it hits for 2; from a distance it breathes a
  burst of fire at you. It tramples houses as it goes.
- Below **30% hp** it **runs away** and heals; at **70%** it comes back. Its hp
  bar turns blue while it's fleeing.
- Off screen, an **arrow on the edge** points to it: red **!** = hunting,
  blue **+** = running and healing.
- Beat it: 500 points, a pile of coins, and a skill orb. 30 s later a new one
  comes, 10 hp stronger each time.

## Waves

A new wave every 40 seconds; 8 waves in all.

| wave | new |
|---|---|
| 1 | tanks, helicopters |
| 2 | (the rival arrives) |
| 3 | **big tanks**: double size, double attack, double defense (2 hp that takes half damage) |
| 4 | **bombers**: double size; fly straight over you and drop bombs that blow up buildings (and other enemies) too |
| 6 | **mechs**: kaiju-sized, 10 hp at double defense, punch up close, fire 3 missiles |
| 8 | **final wave**: 3 mechs at once. Beat them and the city is yours (+1000) |

More helicopters as the waves go on, and more enemies at once.

Best score saves per kaiju.

---

## Where things are in the code

| tab | what |
|---|---|
| 0 | setup, title/play/over, **`buttons()`** (all of the Z / X / Z+X logic) |
| 1 | **`roster`** (the kaiju) and **`sk`** (the 15 skills), skill helpers |
| 2 | the city, `hit()` (all damage goes through it) |
| 3 | `upd_play` (skills each frame, rampage, dash, leap), breath, grab/throw, `hurt` |
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

About **6,900 of 8,192 tokens** are used. A fourth kaiju with simple skills
fits; anything big might need trimming elsewhere first.

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

plays all three kaiju: the grab-and-throw chord, dash/leap, breath, orb pickups and swaps,
rampage, every skill at level 3, the rival, the late waves and the final-wave
win. `kaiju/rage_shots.lua` retakes the screenshots.
