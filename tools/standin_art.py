#!/usr/bin/env python3
"""Stand-in art and sounds for the workshop carts.

Writes the __gfx__, __gff__, __sfx__ and __music__ sections of a .p8 cart
from the pictures below (one character per pixel, a PICO-8 color 0-f,
'.' = see-through). The code part of the cart (__lua__) is never touched.

    python3 tools/standin_art.py kaiju/kaiju.p8 --force

It refuses to touch a cart that already has art unless you pass --force,
because it would wipe out drawings made in the PICO-8 sprite editor.
Once you start drawing your own art, stop running this.
"""
import re
import sys

# ---------------------------------------------------------------- sprites
# index: rows. A 16-row picture fills a 2x2 block starting at that index.
S = {}

S[0] = """
................
..........3333..
......7..3bbbb3.
.....737.3bb0bb3
....73b3bbbbbbb3
...73bbbbbbbbb3.
...3bbbbbbbb33..
..73bbbbbaab3...
..3bbbbbaaab3b3.
.3bbbbbbaaab33..
3bbb3bbbaab3....
33..3bbbbbb3....
....3bb33bb3....
....3bb3.3bb3...
...3bb3...3bb3..
...333.....333..
"""  # kaiju walk 1

S[2] = """
................
..........3333..
......7..3bbbb3.
.....737.3bb0bb3
....73b3bbbbbbb3
...73bbbbbbbbb3.
...3bbbbbbbb33..
..73bbbbbaab3...
..3bbbbbaaab3b3.
.3bbbbbbaaab33..
3bbb3bbbaab3....
33..3bbbbbb3....
....3bb33bb3....
.....3bb3bb3....
.....3bb3bb3....
.....333.333....
"""  # kaiju walk 2

S[4] = """
..........3333..
......7..3bbbb3.
.....737.3bb0bb3
....73b3bbbbbbb3
...73bbbbbbb3888
...3bbbbbbb37.7.
..73bbbbbbbb3888
..3bbbbbaab3bb3.
.3bbbbbaaab3b3..
3bbbbbbaaab33...
3bb3bbbaab3.....
33..3bbbbbb3....
....3bb33bb3....
....3bb3.3bb3...
...3bb3...3bb3..
...333.....333..
"""  # kaiju roar / attack

S[6] = """
................
................
.......88.......
......8888......
.....888888.....
....88888888....
...8888888888...
..888888888888..
..ffffffffffff..
..fccff44ffccf..
..fccff44ffccf..
..ffff4444ffff..
..ffff4444ffff..
..ffff4444ffff..
.55555555555555.
................
"""  # house

S[8] = """
................
..555555555555..
..566666666665..
..56c6c6c6c6c5..
..566666666665..
..56c6c6c6c6c5..
..566666666665..
..56c6c6c6c6c5..
..566666666665..
..56c6c6c6c6c5..
..566666666665..
..56c6c6c6c6c5..
..566664466665..
..566664466665..
.55555555555555.
................
"""  # office

S[10] = """
.......8........
.......6........
....55555555....
....5dddddd5....
....5adadad5....
....5dddddd5....
....5dadada5....
....5dddddd5....
....5adadad5....
....5dddddd5....
....5dadada5....
....5dddddd5....
....5adadad5....
....5dd44dd5....
...5555555555...
................
"""  # tower

S[12] = """
................
................
................
................
................
................
................
................
................
......5.........
....5665.6......
...566d65665....
..5665566d665...
.566d6566656d5..
.55555555555555.
................
"""  # rubble

S[32] = """
........
...dd...
..d66555
.dddddd.
d666666d
55555555
50505055
.555555.
"""  # tank

S[33] = """
.555555.
....5...
...8888.
8..8cc88
8888888c
...8888.
...5..5.
..55555.
"""  # heli 1

S[34] = """
...55...
....5...
...8888.
8..8cc88
8888888c
...8888.
...5..5.
..55555.
"""  # heli 2

S[35] = """
........
........
...9a...
..9aa9..
..9aa9..
...9a...
........
........
"""  # shell

S[36] = """
........
........
........
9.6667..
a96666e.
9.6667..
........
........
"""  # missile

S[37] = """
..333...
.3bbb3..
3bbbbb3.
3bb3bb3.
.3bbb3..
..343...
...4....
..444...
"""  # tree

S[38] = """
........
........
..cccc..
.c7cc7c.
cccccccc
.0....0.
........
........
"""  # car

S[39] = """
........
...77...
..7cc7..
.7cccc7.
.1cccc1.
..1cc1..
...11...
........
"""  # gem

S[40] = """
........
.ee.88..
e7888888
e8888888
.888888.
..8888..
...88...
........
"""  # heart

S[46] = """
44442444
44442444
22222222
42444444
42444444
22222222
44442444
44442444
"""  # brick wall (flag 0)

S[47] = """
bbbbbbbb
3b3b3b3b
44444444
44f44444
44444f44
44444444
4f444444
44444444
"""  # grass block (flag 0)

S[48] = """
..8888..
.888888.
.ffff1f.
.ffffff.
..cccc..
.fccccf.
..1..1..
.11..11.
"""  # hero 1

S[49] = """
..8888..
.888888.
.ffff1f.
.ffffff.
..cccc..
.fccccf.
...11...
..11.11.
"""  # hero 2

FLAGS = {46: 1, 47: 1}  # flag 0 = solid wall

# ---------------------------------------------------------------- sounds
# each sound: (speed, [(pitch, wave, volume, effect), ...])
# waves: 0 tri 1 tilted saw 2 saw 3 square 4 pulse 5 organ 6 noise 7 phaser
# effects: 0 none 1 slide 2 vibrato 3 drop 4 fade in 5 fade out
def notes(*n):
    return list(n)

SFX = {
    0: (4, notes((20, 6, 7, 3), (14, 6, 6, 0), (10, 6, 5, 0), (8, 6, 3, 5))),          # stomp
    1: (1, notes((40, 7, 4, 0), (44, 7, 4, 0), (38, 7, 3, 0), (46, 7, 3, 0), (42, 7, 2, 5))),  # zap / beam
    2: (3, notes((30, 6, 7, 0), (24, 6, 7, 0), (20, 6, 6, 0), (16, 6, 5, 0), (12, 6, 4, 0), (10, 6, 3, 0), (8, 6, 2, 5))),  # boom
    3: (4, notes((36, 3, 5, 0), (40, 3, 5, 0), (43, 3, 5, 0), (48, 3, 4, 5))),          # pickup
    4: (3, notes((30, 2, 6, 1), (24, 2, 6, 1), (18, 2, 5, 1), (12, 2, 4, 5))),          # hurt
    5: (8, notes((22, 7, 7, 2), (20, 6, 6, 2), (19, 7, 6, 2), (18, 6, 4, 5))),          # roar
    6: (2, notes((44, 6, 2, 0), (38, 6, 3, 0), (32, 6, 3, 0), (26, 6, 2, 5))),          # whoosh
    7: (2, notes((46, 3, 3, 3), (40, 3, 2, 5))),                                       # enemy shot
    8: (3, notes((48, 0, 4, 0), (55, 0, 3, 5))),                                       # menu blip
    9: (4, notes((36, 0, 5, 0), (40, 0, 5, 0), (43, 0, 5, 0), (48, 0, 5, 0), (52, 0, 5, 0), (55, 0, 4, 5))),  # level up
    10: (3, notes((26, 6, 5, 0), (22, 6, 4, 0), (20, 6, 2, 5))),                       # crunch
}

# music: an ominous little march. 16 = bass, 17 = drums.
_bass = []
for p in [12, 12, 15, 12, 19, 17, 15, 14]:
    _bass += [(p, 1, 5, 0), (0, 0, 0, 0), (p, 1, 3, 0), (0, 0, 0, 0)]
SFX[16] = (16, _bass)
_drum = []
for i in range(32):
    if i % 8 == 0:
        _drum.append((10, 6, 6, 3))
    elif i % 8 == 4:
        _drum.append((34, 6, 4, 5))
    elif i % 2 == 0:
        _drum.append((52, 6, 1, 5))
    else:
        _drum.append((0, 0, 0, 0))
SFX[17] = (16, _drum)

MUSIC = ["03 10114243"]  # pattern 0: loop on itself, channels 0+1


# ---------------------------------------------------------------- writers
def gfx():
    sheet = [["0"] * 128 for _ in range(128)]
    for idx, pic in S.items():
        rows = [r for r in pic.strip("\n").split("\n")]
        h = len(rows)
        for r in rows:
            assert len(r) == h, f"sprite {idx}: row {r!r} is {len(r)} wide, want {h}"
        x0, y0 = (idx % 16) * 8, (idx // 16) * 8
        for y, r in enumerate(rows):
            for x, c in enumerate(r):
                sheet[y0 + y][x0 + x] = "0" if c == "." else c
    return "\n".join("".join(r) for r in sheet)


def gff():
    f = ["00"] * 256
    for i, v in FLAGS.items():
        f[i] = f"{v:02x}"
    return "\n".join("".join(f[i * 128:(i + 1) * 128]) for i in range(2))


def sfx():
    lines = []
    for i in range(64):
        spd, ns = SFX.get(i, (16, []))
        ns = (ns + [(0, 0, 0, 0)] * 32)[:32]
        body = "".join(f"{p:02x}{w:x}{v:x}{e:x}" for p, w, v, e in ns)
        lines.append(f"00{spd:02x}0000" + body)
    return "\n".join(lines)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    force = "--force" in sys.argv
    for path in args:
        text = open(path).read()
        if "__gfx__" in text and not force:
            sys.exit(f"{path} already has art; pass --force to replace it")
        text = re.split(r"\n__(?:gfx|gff|label|map|sfx|music)__\n", text)[0].rstrip("\n")
        text += "\n__gfx__\n" + gfx() + "\n__gff__\n" + gff()
        text += "\n__sfx__\n" + sfx() + "\n__music__\n" + "\n".join(MUSIC) + "\n"
        open(path, "w").write(text)
        print("art + sounds written to", path)


if __name__ == "__main__":
    main()
