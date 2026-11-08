# Angels game (after Kaiju Rage)

Same engine as Kaiju Rage, new goal: angels **bring light to the city**
instead of wrecking it, against **demons** (palette-swapped angels, which
fits: demons are fallen angels). Nothing is built yet; these are notes for
when Kaiju Rage is done.

## Four playable choirs

The nine choirs (Pseudo-Dionysius, *The Celestial Hierarchy*; St Thomas,
*Summa* I q.108) come in three triads: **Seraphim, Cherubim, Thrones** ·
Dominions, Virtues, **Powers** · Principalities, **Archangels**, Angels.

| choir | look | plays like (from the kaiju) |
|---|---|---|
| **Seraphim** | six wings, fire ("the burning ones", Isaiah 6) | flyer: flies like Luna; light comes as flame |
| **Cherubim** | four wings, guards Eden with a flaming sword (Genesis 3:24) | guardian: shield and sword, slow and tough like Korax |
| **Archangels** | Michael with sword and spear | warrior: dash, like Gora |
| fourth: **Thrones** or **Powers** | see below | |

For the fourth:

- **Thrones** look the best in pixel art: popular art draws them as the
  fiery "wheels full of eyes" from Ezekiel 1 (that link is a later tradition,
  not from Dionysius). A rolling wheel is a great move: a long roll-dash
  that lights everything it passes.
- **Powers** fit the story best: St Gregory the Great describes them as the
  angels who hold back the evil spirits. A Powers angel could be the
  "demon fighter" (strongest against demons, weakest at lighting buildings).

Thrones for looks and a new move, Powers for the theme. (Or five choirs: the
roster is just a list.)

## What each one looks like

The key for 16 × 16 sprites is that each one has a **different shape**
(silhouette), so you can tell them apart at a glance even when they're
recolored as demons:

| | shape | look (from Scripture) | colors | plays like |
|---|---|---|---|---|
| **Archangel** (Michael) | upright person | a man in armor with two wings, sword raised, a shield; he throws down the dragon (Revelation 12:7–9) | white, gold, blue | **Gora**: walks, Z = charge (dash); X = light from the raised sword |
| **Seraph** | an X of wings | **six wings**: two cover the face, two cover the feet, two to fly (Isaiah 6:2). Mostly wings, barely a body; "seraph" means *burning one* | red, orange, gold | **Luna**: flies (Z takes off, Z again swoops down); X = fire |
| **Cherub** | wide, low, beast-like | **four faces** (man, lion, ox, eagle), four wings, straight legs with calf's feet, gleaming like bronze (Ezekiel 1:5–10); guards Eden with a **flaming sword turning every way** (Genesis 3:24). At 16 × 16, draw the lion face forward and hint at the eagle's wings | bronze, gold, blue-white | **Korax**: slow and tough, Z = dash; the turning sword circles it |
| **Throne** | a circle | **wheels within wheels**, rims full of eyes, moving in any direction without turning (Ezekiel 1:15–21) | fire orange, gold rim, white eyes | new: Z = roll (a long dash that lights every building it passes) |

A note on cherubim: the chubby baby angels in Renaissance paintings (putti)
are often called "cherubs", but the cherubim in the Bible are fierce
guardians. The game should use the Bible's version, which also makes the
better fighter. (A cute little guardian angel could be a fifth, kid-friendly
character later: the "Angels" choir.)

**Demons** are the same four sprites recolored: purple and black instead of
white and gold, red eyes, and maybe a version with ragged wings. The tint
code already does recoloring (the rival kaiju is a purple tint), so this is
nearly free.

### Their skills, renamed from the kaiju

| kaiju | angel version |
|---|---|
| breath | a beam of light (Seraph: fire) |
| rage mode | **glory**: the same Super Star effect in white and gold |
| roar (makes dizzy) | Seraph's **"Holy, holy, holy"** (Isaiah 6:3): demons are stunned |
| rejuv | Seraph's **live coal** (Isaiah 6:6–7): heals |
| spores (circling) | Cherub's **turning flaming sword** |
| shell | Cherub's guard / Michael's **shield** |
| zap | Michael's **spear** |
| stomp / quake | Michael **casting down** (a shockwave) |
| gust | wings |
| a new one for Thrones | **eyes**: shows where the demons are (like the rival arrow, for all of them) |

## The two modes, angel version

- **Brighten the city** (= destroy the city): light up half the buildings,
  faster = more points. The ratchet idea below keeps demons from undoing
  everything.
- **Protect the city** (= survive the waves): hold off the hordes for 8 waves;
  the last one is a fallen-angel boss.

## The back-and-forth problem

Your wife is right: if you light a building and a demon darkens it again, the
game can feel like treading water. Ways to make progress stick:

1. **Light that ratchets.** Each building has light 0 to 3. Passing by
   raises it; demons only lower it by one. At 3 it's **blessed for good** and
   can't be darkened. Progress you've finished is never lost; only work in
   progress is at risk.
2. **Consecrate whole blocks.** Light every building in a city block and the
   block is consecrated (a bell rings, the street glows). Demons can't enter
   it. The demons' space shrinks as you go, like filling in Pac-Man's maze.
3. **Light fights back.** Blessed buildings shine and hurt or slow demons
   nearby, so a lit area protects itself and the city helps you more the
   more you light.
4. **Stop the source.** Demons come out of a few dark "nests". Shutting a
   nest is a goal you can see, instead of chasing every demon.
5. **Win before perfect.** "Light 75% of the city before dawn", so one
   darkened corner doesn't block the win.

My suggestion: **1 + 2 + 3 together**. Then demons are a threat to *defend*
against, not a reset button, and the game speeds up as you win, like rage
mode in Kaiju Rage. 4 and 5 are good extras for later waves.

## Reusing Kaiju Rage

Most of the code carries over. These swaps change the goal:

| Kaiju Rage | Angels |
|---|---|
| `hit()` lowers building hp | raises building light (on demons: damage) |
| `smash()` (rubble, coins) | blessed (glow, coins) |
| army waves | demon waves; palette-swapped angels of each choir |
| rival kaiju | a fallen angel boss who flees and comes back |
| rage mode | a "glory" mode: the same idea in white and gold |

Because these swap one thing for another, the token budget stays about the
same.
