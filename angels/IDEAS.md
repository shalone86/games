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
