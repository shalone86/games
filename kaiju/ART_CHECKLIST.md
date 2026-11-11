# Kaiju Rage: art + sound checklist

Everything in `rage.p8` that's a stand-in, with its sprite number, size and
what to keep in mind. Draw over the stand-ins in PICO-8's sprite editor
(the number of the selected sprite shows at the bottom); the game picks them
up as soon as you save (Ctrl+S) and run (Ctrl+R).

**One set of art for both carts.** Draw in `rage.p8` only. The 4-player cart
(`rage4.p8`) uses the same drawings and sounds; when you're done drawing, copy
them over with:

```
python3 tools/cart4.py kaiju/rage4.lua kaiju/rage.p8 kaiju/rage4.p8
```

A 16 × 16 drawing uses a 2 × 2 block of sprites starting at its number (so
sprite 0 also covers 1, 16 and 17).

## Rules for every drawing

- **Face right.** The game mirrors everything for left.
- **Feet / ground on the bottom rows.** Kaiju stand on the bottom of their
  16 × 16 box; buildings sit on their bottom row.
- **Black is see-through.** For dark outlines use dark blue or dark grey.
- **Kaiju colors matter.** The special effects recolor the kaiju by swapping
  six colors: **green, dark green, yellow, orange, brown, light grey**. Rage mode turns them rainbow, the *hide* skill turns
  them stone grey, the gold glow means "can't be hurt", and the rival is
  tinted purple. Parts in other colors (eyes, mouths, outlines) stay as they
  are, which is usually what you want. If you use different main colors,
  tell me (or edit the `stone`, `gold`, `purple` lines and `rainbow()` in
  tab 6).
- **Breath comes out of the mouth**, at the right edge of the box, 6th row
  from the **top** (the `*` below). Rows are counted from the top, so this is
  head height, not near the feet. Make the open mouth touch the right edge
  around there:

```
     column: 0 1 2 3 4 5 6 7 8 9 A B C D E F
  row  0     . . . . . . . . . . . . . . . .
  row  1     . . . . . . . . . . # # # # . .
  row  2     . . . . . . . . . # # # o # # .
  row  3     . . . . . . . . . # # # # # # #
  row  4     . . . . . . . . . # # # # # # #   upper jaw
  row  5     . . . . . . . . # # # # . . . *   open mouth: breath starts here
  row  6     . . . . . . . # # # # # # # # #   lower jaw
  row  7     . . . . . # # # # # # # . . . .
  row  8     . . . # # # # # # # # # # . . .
  row  9     . # # # # # # # # # # . # # . .   arm
  row 10     # # . # # # # # # # # . . . . .
  row 11     # . . # # # # # # # # . . . . .   tail on the left
  row 12     . . . . # # # . # # # . . . . .
  row 13     . . . . # # . . . # # . . . . .
  row 14     . . . . # # . . . # # . . . . .
  row 15     . . . # # # . . # # # . . . . .   feet on the bottom row
```

## Kaiju (16 × 16, three each)

- [ ] **0** Gora: walk 1
- [ ] **2** Gora: walk 2
- [ ] **4** Gora: attacking (mouth open; shown while breathing and while charging forward; landing squashes whatever pose is showing, so leave a little room)
- [ ] **64** Luna: wings up
- [ ] **66** Luna: wings down
- [ ] **68** Luna: attacking
- [ ] **70** Korax: walk 1
- [ ] **72** Korax: walk 2
- [ ] **74** Korax: attacking
- [ ] **100** D-Tron: walk 1
- [ ] **102** D-Tron: walk 2
- [ ] **104** D-Tron: attacking (arm out, firing the beam)

(The rival is one of these, tinted purple; no extra drawing needed.)

## City (16 × 16)

- [ ] **6** house
- [ ] **8** office
- [ ] **10** tower
- [ ] **12** rubble (what's left of any building)

## Army

- [ ] **32** tank (8 × 8)
- [ ] **33** helicopter, frame 1 (8 × 8)
- [ ] **34** helicopter, frame 2 (8 × 8; spin the rotor)
- [ ] **76** big tank (16 × 16)
- [ ] **78** bomber (16 × 16, side view, nose right)

(The mech is D-Tron's two walk drawings in grey: every color turns to a
grey, so give D-Tron bright colors to tell them apart. No extra drawing
needed; 96 and 98 are free now.)

## Small things (8 × 8)

- [ ] **35** tank shell
- [ ] **36** missile (nose right)
- [ ] **37** tree (drawn in the middle of its lot)
- [ ] **40** heart
- [ ] **41** coin

Not drawings: skill orbs are colored circles (each skill's `c=` color in
tab 1), and the rival's fire, bombs, sparks and shockwaves are drawn with
circles. Say if you'd rather draw any of those as sprites.

Not used by Kaiju Rage (skip): 38 car, 39 gem, 46/47 brick and grass, 48/49
little hero (the cookbook uses those).

## Sounds (sound editor)

- [ ] **0** stomp / landing / shockwave
- [ ] **1** breath + zap (plays over and over while breathing, so keep it short)
- [ ] **2** explosion
- [ ] **3** pickup (coin, grab)
- [ ] **4** kaiju hurt
- [ ] **5** roar / rage mode starts
- [ ] **6** whoosh (dash, take off, throw)
- [ ] **7** enemy shot
- [ ] **8** menu blip
- [ ] **9** level up / new skill
- [ ] **10** crunch (small building, mech punch)

## Music

- [ ] **Pattern 0** (sound effects 16 + 17): the main loop. Plays on
  channels 0 and 1 only, so sound effects never cut it off.
- [ ] **Pattern 1** (sound effects 18 + 19): rage mode. Fast and bright
  (a Super Star feel). Must loop on itself.

If you add more channels or patterns, tell me which so the `music()` calls
match.

## Last

- [ ] Title / cart picture: run the game, press **F7** on a nice moment to
  capture the cart's label.
- [ ] Final names for the game and the kaiju (tab 1, `roster`: the first word of each line).
