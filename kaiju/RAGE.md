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

## Two modes

Pick on the title screen with **up / down** (left / right picks the kaiju).
Each mode starts with its goal in big letters.

| | **destroy the city** | **survive 8 waves** |
|---|---|---|
| goal | wreck **50%** of the city's buildings | last through 8 waves and beat the **boss** in wave 8 |
| on screen | a red **destruction bar** under the top bar, the % of the goal, and an orange **house marker** on the screen edge pointing to the nearest building left, whenever none is close | **W3/8** at the top; each new wave announced big with "5 waves left" |
| points | everything you smash, plus a **time bonus**: the faster you finish, the more (5 points a second under 5 minutes, ×10 on screen) | everything you smash, plus **500 for every wave** you survive and 1000 for the boss |
| best score | saved per kaiju, per mode | saved per kaiju, per mode |

The army grows the same way in both (a new wave every 25 s); in destroy
mode the waves are just the clock getting meaner.

---

## Controls

| button | does |
|---|---|
| arrows | walk |
| **X** (hold) | breath, in the direction you face. Drains the bar under your feet; let go to refill |
| **Z** | **stomp** (Gora), **dash** (Korax) or **fly** (Luna): Z takes off, Z again dives down and stomps |
| **Z + X** together | **grab** what's in front of you: a tank, helicopter, big tank, or a whole building |
| Z or X while holding something | **throw** it |

Z waits 5 frames (a sixth of a second) before its move, to see if X
comes too. That's what lets Z+X mean "grab" without a third button. Breath
waits the same.

**Z charges back.** A green bar under your feet (under the breath bar) shows
the charge; it fills while you're on the ground. Z works any time, but only
as strong as the charge (at least 30%): use it again too soon and you get a
shorter dash, a lower hop, a shorter flight and a smaller landing. A full
charge takes about 2 s (Gora), 1⅓ s (Korax), 4 s (Luna).

- **Stomp** (Gora): he rears up (stretches tall, a little off the ground)
  and slams down: crushes what's under him, with a shockwave. He squashes
  wide when he lands. No new drawing needed; if you'd like a "foot up" pose,
  that's a sprite to add later.
- **Dash** (Korax): quick burst, can't be hurt, 3 damage to buildings in the
  way (towers stop you).
- **Fly** (Luna): Z takes off; fly over everything for up to 3 s. Tanks,
  bombs, punches and the rival's bite can't reach you up there, but
  **missiles and the rival's fire can**. Z again (or running out of time)
  dives down: whatever you land on is crushed, with a shockwave.

## The kaiju

| | kaiju | moves | hp | speed | skill orbs |
|---|---|---|---|---|---|
| 1 | **Gora**, big lizard | stomp | 10 | medium | flame, tail, roar, hide, rejuv |
| 2 | **Luna**, giant moth | fly | 8 | fast | gust, spores, zap, dust, cocoon |
| 3 | **Korax**, spiked tank | dash | 13 | slow | spikes, quake, shell, thorns, rock |

Each one's Z move is `z="stomp"`, `"dash"` or `"fly"` in the roster (tab 1),
one word to change; `zr` is how fast it charges back.

## Skill orbs (the survivor part)

Each kaiju has **its own 5 skills**, each a different orb color. They work by
themselves, no buttons. You start with the first one.

- Two **slots**. **Touch an orb and you take it**, bullet-hell style; to
  skip one, dodge it. The **same skill levels up** (up to 3; the number after
  its name, yellow at max). A new skill fills an empty slot, or else **pushes out your
  weaker skill** (the older one if they're tied), and a banner says what
  happened ("zap for gust").
- **Level 2 and 3 skills are safe.** Once your weaker skill is level 2 or
  more, touching a different orb does nothing by accident. To swap anyway,
  **stand on the orb for one second**: a small bar in the orb's color climbs
  beside you with the skill's name ("roar?"), and when it's full the swap
  happens. Walk off and it resets.
- **Orbs for skills you already have fly to you** from about 3 houses away,
  so a level-up is never lost in the crowd.
- Orbs drop from offices and towers (20%), houses (6%), small enemies (8%),
  big enemies (60%), one near you every new wave, and always from a beaten
  rival. Once you have two skills those chances drop to about a sixth
  (`.15` in `drop()`, tab 5), because orbs that fly to you and skills that
  can't be lost would otherwise level you twice as fast. Measured with a bot:
  both skills reach level 3 at about the same time as before (a bit over
  2 minutes).

**Gora** (your list):

| orb | color | what it does (gets stronger each level) |
|---|---|---|
| flame | orange | every 1–2 s, a flame jet at the nearest enemy |
| tail | brown | a tail sweep: a shockwave around you every few seconds (was 'stomp'; renamed now that stomp is his Z move) |
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

About a third of what you smash drops a **coin** (two thirds in destroy mode, which is shorter, so rage comes there too). 36 coins fill the **rage** meter (about 1–2 times a game),
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

At 25 seconds another kaiju (one you didn't pick, tinted purple) arrives,
and **it gets stronger every wave**: 10 more hp, faster, harder hits
(1 damage, 2 from wave 3, 3 from wave 6) and more frequent fire.

- It **hunts** you: up close it hits; from a distance it breathes a
  burst of fire at you. It tramples houses as it goes.
- Below **30% hp** it **runs away** and heals; at **70%** it comes back. Its hp
  bar turns blue while it's fleeing.
- Off screen, an **arrow on the edge** points to it: red **!** = hunting,
  blue **+** = running and healing.
- Beat it: 500 points, a pile of coins, and a skill orb. 20 s later a new one
  comes, as strong as the wave it arrives in.

### The boss (survive mode, wave 8)

The rival comes back **twice as big** with **200 hp** (a big bar across the
top of the screen). It never runs away, breathes fire **three ways at once**,
and hits for 3. Beat it to win.

## Waves

A new wave every 25 seconds (each one also drops a skill orb near you); 8 waves, so the final wave comes at about 3 minutes.

| wave | new |
|---|---|
| 1 | tanks, helicopters |
| 2 | (the rival arrives) |
| 3 | **big tanks**: double size, double attack, double defense (2 hp that takes half damage) |
| 4 | **bombers**: double size; fly straight over you and drop bombs that blow up buildings (and other enemies) too |
| 6 | **mechs**: kaiju-sized, 10 hp at double defense, punch up close, fire 3 missiles |
| 8 | **final wave** (survive mode): the boss |

Enemies arrive in **squads** (tanks and helicopters come in groups that grow
with the waves), a new group every 2 s at first and every ⅓ s by the end, up
to **13 enemies at once in wave 1, rising to 48 by wave 8**. The game can
handle about 60 at once without slowing down (it only checks the buildings
near each thing instead of all 300), so this can go higher.

Best score saves per kaiju and mode.

---

## Where things are in the code

| tab | what |
|---|---|
| 0 | setup, title/play/over, **`buttons()`** (all of the Z / X / Z+X logic) |
| 1 | **`roster`** (the kaiju) and **`sk`** (the 15 skills), skill helpers |
| 2 | the city, `hit()` (all damage goes through it) |
| 3 | `upd_play` (skills each frame, rage mode, dash, fly, stomp), `zmove`, breath, grab/throw, `hurt` |
| 4 | `et` (enemy stats), `pick()` (which enemy each wave), enemies, bombs, **`rival_ai`** |
| 5 | drops (coins, hearts, orbs), pickups, thrown things, effects |
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

About **8,166 of 8,192 tokens** are used: nearly full. A fourth kaiju or
more skills would mean trimming something first (there's room to: some
helpers can be merged, and the title screen could get simpler). Ask me
when you get there.

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

plays all three kaiju in both modes (grab, breath, the Z move, orbs, rage
mode, the late waves) through to a win: the city destroyed, or the boss
beaten. `kaiju/rage_shots.lua` retakes the screenshots and
`kaiju/rage_sim.lua` (add `300` to the command) has a bot play whole games
to check the pacing, and `kaiju/rage_levels.lua` (add `580`) measures how
fast skills level up, and `kaiju/rage_coins.lua` (add `580`) how many coins and rages a game gives. The test runner adds its code to the cart, and the
cart is near the token limit, so a test's first line can say
`-- stub: name name` to empty functions it doesn't need (only in the test
copy, never in the cart).
