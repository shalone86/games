#!/usr/bin/env python3
"""Make a cart from Lua code and another cart's art, sounds and music.

    python3 tools/cart4.py kaiju/rage4.lua kaiju/rage.p8 kaiju/rage4.p8

Kaiju Rage 4 players (rage4.p8) has its own code but the same drawings
and sounds as rage.p8: after redrawing art in rage.p8, run this again so
the 4-player cart gets it too. (Change rage4's code in rage4.lua.)
"""
import sys
code, art, out = sys.argv[1:4]
lua = open(code).read().rstrip("\n")
a = open(art).read()
head, rest = a.split("__lua__\n", 1)
rest = rest[rest.index("\n__gfx__\n"):]
open(out, "w").write(head + "__lua__\n" + lua + rest)
print("wrote", out)
