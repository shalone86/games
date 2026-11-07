# PICO-8 Cookbook

`cookbook.p8` has 19 recipes. Each one is a single screen you can play
with, and its code is short enough to read in one sitting. This guide goes
with the cart: for each recipe, **what it shows**, **the code that matters**,
and **try this** challenges (good ones to hand to a kid).

Open it in PICO-8:

```
cd games
cd cookbook
load cookbook
run
```

Pick a recipe with the arrows and **Z**. In a recipe, **Enter** (or P)
opens the pause menu: *recipe list*, *next recipe*, *last recipe*.
Press **Esc** to see the code; the recipes live in tabs 2 to 5.

---

## How to use this with a kid

One recipe per session works well. A good loop:

1. **Play it** for a minute. What does it do? What do the buttons do?
2. **Find it** in the code (Esc, then the tab). Read the few lines that matter
   (they're quoted below).
3. **Break it on purpose.** Change one number, run (Ctrl+R), see what
   happened. Change it back. This is the fastest way to learn what a line does.
4. **Do one "try this".** Small wins first.

A good order: 1, 2, 4, 5, 6, 8, 9, 7, 12, then the rest as needed. The kaiju
workshop (`../kaiju`) uses nearly every recipe; once he's done a few, he can
go find them in a real game.

---

## PICO-8 in five minutes

- **The screen** is 128 × 128 pixels. (0,0) is the top-left. **y grows
  downward**: bigger y = lower on the screen.
- **16 colors**, numbered 0 to 15 (recipe 15 shows them all).
- **Buttons**: 0 left, 1 right, 2 up, 3 down, 4 = O (Z key), 5 = X (X key).
- `btn(b)` is true **while** a button is held. `btnp(b)` is true only on the
  frame it's **pressed** (and repeats if held). Walking uses `btn`, jumping
  and menus use `btnp`.
- **Editors** (Esc, then the icons top-right): code, sprites, map, sound
  effects, music. Ctrl+S saves, Ctrl+R runs.
- **Limits** (what makes PICO-8 PICO-8): 8192 *tokens* of code (the count is
  at the bottom right of the code editor), 256 sprites of 8 × 8, 64 sound
  effects. The limits are a feature: games stay small enough to finish.

### The tabs in a .p8 file

The code editor has tabs (0, 1, 2… along the top). They're just one long file
split up to keep it tidy. In the `.p8` text file you'll see `-->8` where each
new tab starts.

---

## 1. The game loop

PICO-8 calls two functions for you, 30 times a second:

- `_update()` changes things (move, check buttons, count).
- `_draw()` paints the screen from scratch.

```lua
function _update()
 bx+=bdx by+=bdy
 if bx<4 or bx>123 then bdx=-bdx end   -- bounce off the sides
end
function _draw()
 cls(1)               -- wipe the screen
 circfill(bx,by,4,10) -- paint the ball
end
```

`_init()` (optional) runs once at the start. Every recipe in the cart has the
same three parts: an init, an update and a draw.

**Why separate them?** Update is the *rules*, draw is the *picture*. If the
game slows down, PICO-8 can skip a draw but never an update, so the rules stay
fair.

**Try this:** make the ball faster. Make it bigger. Change its color every
time it bounces (`c=rnd(16)` then `circfill(bx,by,4,c)`).

---

## 2. Move + diagonals

Read the arrows into a direction `dx,dy`, then move.

```lua
local dx,dy=0,0
if btn(0) then dx-=1 end
if btn(1) then dx+=1 end
if btn(2) then dy-=1 end
if btn(3) then dy+=1 end
if dx!=0 and dy!=0 then dx*=.707 dy*=.707 end  -- the fix
px+=dx*1.5 py+=dy*1.5
```

**The diagonal trap:** holding right + down moves 1 right *and* 1 down, which
is about 1.41 pixels: diagonals are 41% faster. Multiplying both by .707
(that's 1 ÷ √2) brings it back to 1. Press X in the recipe to see the
speed change.

`mid(lo,x,hi)` keeps a number between two others: `px=mid(0,px,120)` stops at
the screen edge.

**Try this:** add a "run" button: hold X to move twice as fast.

---

## 3. Speed + sliding

Instead of moving straight, buttons push a **velocity** (`vx,vy`), and
**friction** shrinks it every frame:

```lua
vx+=dx vy+=dy           -- push
vx*=f vy*=f             -- friction: f=.8 grass, .97 ice
px+=vx py+=vy           -- move
```

Friction .8 keeps 80% of the speed each frame (stops quickly); .97 keeps 97%
(slides for ages). The kaiju's *stampede* mode is exactly this.

**Try this:** make a mud patch on half the screen with friction .5.

---

## 4. Sprites + animation

- `spr(n,x,y)` draws sprite number `n` (8 × 8).
  `spr(n,x,y,2,2)` draws a 2 × 2 block (16 × 16): the kaiju.
- `spr(n,x,y,w,h,flip_x)`: true for `flip_x` mirrors it, so you only draw
  things facing right.
- `sspr(sx,sy,sw,sh,x,y,dw,dh)` draws any rectangle of the sprite sheet at any
  size: that's how the kaiju grows.

**Animation** is just changing which sprite you draw. Count up while walking,
and pick a frame from the count:

```lua
if moving then fr+=.15 end    -- .15 = how fast the legs go
local f=flr(fr)%2*2           -- 0, 2, 0, 2...
sspr(f*8,0,16,16,x,y,w,w,face<0)
```

`flr` rounds down, `%2` gives 0 or 1 (remainder after ÷2), `*2` gives sprite
0 or 2.

**Try this:** draw a third walk frame in sprite 14 and cycle through 3 frames
(`%3`).

---

## 5. Bumping boxes

Two boxes overlap when **all four** of these are true:

```lua
ax < bx+bw and ax+aw > bx and
ay < by+bh and ay+ah > by
```

In words: A's left side is left of B's right side, A's right side is right of
B's left side, and the same up and down. This is "AABB" collision and most
games use nothing fancier.

A cheaper version for things that are roughly round, used all over the kaiju
game: `abs(ax-bx)<r and abs(ay-by)<r`.

**Try this:** make the yellow box unable to move into the purple ones
(hint: recipe 6).

---

## 6. Walls from the map

The map editor paints sprites onto a grid. `mget(tx,ty)` reads the sprite at
a map cell; `fget(n,0)` reads **flag 0** of a sprite (the little dots under
the sprite in the sprite editor). Flag 0 on = "this is a wall".

```lua
function wall(x,y) return fget(mget(x\8,y\8),0) end
```

`x\8` divides and rounds down: pixel 20 is in map cell 2.

**The golden rule: move one axis at a time.**

```lua
if not solid(px+dx,py) then px+=dx end
if not solid(px,py+dy) then py+=dy end
```

If a wall blocks only your sideways move, your up/down move still happens, so
you slide along walls instead of sticking to them.

The recipe builds its map from strings (`#` = brick) with `mset`, so you can
see the whole maze in the code. You can also draw maps in the map editor and
skip `make_map`.

**Try this:** add a door: a `D` in the strings, a new sprite, and a key that
removes it with `mset`.

---

## 7. Jump like a pro

A plain jump is `vy=-3`, then gravity `vy+=.25` every frame. Three small
tricks make jumps feel great (most loved platformers use all three):

```lua
-- 1. jump buffer: a press counts for 6 frames,
--    so pressing a bit early still jumps when you land
if btnp(4) then buf=6 else buf=max(buf-1,0) end
-- 2. coyote time: you can still jump 6 frames
--    after running off a ledge
if ground then coy=6 else coy=max(coy-1,0) end
if buf>0 and coy>0 then vy=-3.2 end
-- 3. variable height: let go early = short hop
if not btn(4) and vy<0 then vy+=.3 end
```

Landing steps one pixel at a time until it touches the floor, so you never
sink in.

**Try this:** set both 6s to 0 and play. Feel the difference? Then add a
double jump (count jumps, reset on the ground).

---

## 8. Lists of things

Bullets, enemies, sparks: keep them in a table (a list) and loop over it.

```lua
parts={}
add(parts,{x=64,y=64,dx=1,dy=0,t=30})  -- make one
for p in all(parts) do                 -- update all
 p.x+=p.dx p.t-=1
 if p.t<0 then del(parts,p) end        -- remove it
end
```

`all()` lets you `del` the thing you're on safely. (With a counting loop
`for i=1,#parts`, deleting skips the next item. Count backwards,
`for i=#parts,1,-1`, if you ever need that kind of loop.)

The recipe's `burst()` makes 40 sparks flying in random directions with
`cos` and `sin`, and gravity pulls them down.

**Try this:** make the fireworks bigger, or leave a trail (don't `cls` the
screen; draw a few dark dots instead).

---

## 9. Aim with atan2

`atan2(dx,dy)` gives the **angle** from one point to another. `cos(a)` and
`sin(a)` turn an angle back into a direction.

```lua
local a=atan2(tx-x,ty-y)       -- angle to the target
bullet.dx=cos(a)*3             -- speed 3 that way
bullet.dy=sin(a)*3
```

PICO-8 angles are in **turns**: 0 = right, .25 = up, .5 = left, .75 = down,
1 = all the way around. (No degrees, no π.) PICO-8's `sin` is upside down
compared to math class, to match the screen's y going down; as long as you
use `atan2`, `cos` and `sin` together, it just works.

**Try this:** fire 3 bullets in a spread (`a-.03`, `a`, `a+.03`).

---

## 10. Chase + run away

The same angle works both ways: move **toward** the player to chase, use a
**negative** speed to flee.

```lua
local a=atan2(px-e.x,py-e.y)
local s=scared and -.8 or .4
e.x+=cos(a)*s e.y+=sin(a)*s
```

The kaiju game's helicopters add a quarter turn (`a+.25`) so they **circle**
you instead of landing on you.

**Try this:** make them circle the kaiju. Make each tank a different speed.

---

## 11. Camera + HUD

`camera(cx,cy)` shifts everything drawn after it: the world can be bigger
than the screen. To follow the player, aim the camera at the player minus
half a screen (64), and **ease** toward it so it glides:

```lua
cx+=(px-64-cx)*.1   -- move 10% of the way each frame
```

**The HUD trap:** after `camera(cx,cy)`, your score would scroll away with the
world. Call `camera()` (no numbers) before drawing the HUD.

**Try this:** change .1 to .5 and to .02. Which feels best? Stop the camera at
the world's edge with `mid(0,cx,512-128)`.

---

## 12. Juice

Same hit, two ways (X turns juice on and off). Juice is three cheap tricks:

- **Screen shake:** `camera(rnd(sh)-sh/2, rnd(sh)-sh/2)` and shrink `sh`
  every frame (`sh*=.8`).
- **Hit-stop:** freeze the update for a few frames on a big hit
  (`if stop>0 then stop-=1 return end`). Fighting games do this.
- **Flash:** `pal(c,7)` for every color draws the sprite all white for a
  couple of frames. Call `pal()` after to put colors back.

Plus particles (recipe 8) and a sound. None of these change the rules, but
the game *feels* completely different.

**Try this:** add a sound with each hit's pitch a bit higher (look at recipe
16).

---

## 13. Timers + states

A **timer** is a number you count down. A **cooldown** is a timer that stops
you doing something again too soon:

```lua
cd=max(cd-1,0)
if btnp(4) and cd==0 then cd=45 fire() end  -- 45 frames = 1.5 seconds
```

A **state machine** is a variable saying what's going on now ("go", "slow",
"stop") and rules for what comes next. Whole games are state machines:
`title` → `play` → `over` → `title` (look at `_update` in the kaiju cart).

**Try this:** add a "flashing" state after "stop" where the yellow light
blinks.

---

## 14. Text tricks

- **Outline:** draw the text 8 times in black around the spot, then once in
  color on top (`oprint` in the helpers tab).
- **Centered:** each letter is 4 pixels wide, so start at `64-#s*2`
  (`#s` = number of letters).
- **Typewriter:** `print(sub(msg,1,n))` shows the first `n` letters; count
  `n` up.
- **Wavy:** print letter by letter, moving each up and down with
  `sin(t()+i/8)`.
- **Big text:** `"\^w\^tbig"` = wide and tall. `"\#2"` gives it a
  background color.

**Try this:** make a speech bubble that types out the kaiju's thoughts.

---

## 15. Colors + patterns

- `pal(a,b)` draws color `a` as color `b`. One kaiju drawing becomes red, blue
  or gold monsters. (The kaiju glows gold when it can't be hurt: that's
  `pal(11,10) pal(3,9)`.)
- `fillp(pattern)` fills shapes with a 4 × 4 checker or stripe pattern made of
  16 bits; the color `0x9a` means "10 for the on dots, 9 for the off dots".
  `fillp()` turns it off.

**Try this:** make a "night" mode: `pal(3,1)`, `pal(11,3)`… for every color,
before drawing the world.

---

## 16. Sound

`sfx(n)` plays sound effect `n` (make them in the sound editor).
`music(n)` plays music starting at pattern `n`; `music(-1)` stops it.

There are 4 channels (4 sounds at once). The kaiju game plays music with
`music(0,0,3)`: the `3` keeps channels 0 and 1 for the music, so sound effects
use 2 and 3 and never cut the drums off.

The sounds in this cart are stand-ins; open the sound editor and change them.

**Try this:** make a "pickup" that goes up three notes, and a "hurt" that
slides down.

---

## 17. Saving

```lua
cartdata("sdcason_cookbook")  -- once, at the top: your save file's name
dset(0,score)                 -- save a number in slot 0 (64 slots)
dget(0)                       -- read it back
```

Saves survive turning PICO-8 off. The name must be unique to the game; if two
games share it they share the saves. Call `cartdata` **once only**.

**Try this:** save a high score that only changes when you beat it.

---

## 18. Number traps

PICO-8 numbers go from **-32768 to 32767** (with 4 decimal places).

- Go past 32767 and it **wraps around** to minus. A score can suddenly become
  negative! The kaiju game uses `min(score+n,32000)`.
- **Distances overflow too:** `200*200` is 40000, too big, so
  `sqrt(200*200)` comes out wrong. Shrink first: divide by 16, do the math,
  multiply by 16 after (`dist` in the kaiju cart).
- `-7%3` is 2 (not -1); `flr(-1.5)` is -2; `7\2` is 3 (divide and round
  down); `1/3*3` isn't quite 1.

**Try this:** count frames in a variable for 20 minutes. When does it break?
(18 minutes: 32767 ÷ 30.) That's why the kaiju game counts frames only
up to 29, then adds one to a *seconds* counter (`secs`).

---

## 19. Random worlds

`rnd()` gives a random number from 0 to 1. `srand(seed)` restarts the random
numbers from a **seed**: the same seed gives the same "random" world every
time. That's how games share a level with just one number.

```lua
srand(seed)
for x=0,7 do for y=0,6 do
 if rnd()<.6 then draw a building end
end end
```

**Try this:** add a "lake" that's random too. Find a seed you like and make it
the first level.

---

## Gotchas worth knowing

- `tonumber()` doesn't exist: use `tonum()`. `split"1,2,3"` already gives
  numbers.
- Lua lists start at **1**, not 0.
- In a table like `{[1]="a","b"}`, the `"b"` is item 1 too and wins: write
  either all keys or none.
- A number right before `..` needs a space: `s\60 ..":"`, not `s\60..":"`.
- `local` variables only live inside their function. Everything else is
  global, which is handy for small games.
- Don't draw in `_update` or change the rules in `_draw`.
- `print` with no x, y continues below the last line, like a terminal.

## Where to look things up

- The PICO-8 manual: in PICO-8, type `help`, or pico-8.com/manual.
- The PICO-8 cheat sheet (search "pico-8 cheat sheet"): one page with every
  command.
- Other people's carts on the BBS (splore inside PICO-8): Esc shows their
  code.
