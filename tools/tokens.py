#!/usr/bin/env python3
"""Rough PICO-8 token count for a .p8 cart (within a few % of PICO-8's own).

    python3 tools/tokens.py kaiju/kaiju.p8

PICO-8 counts every name, number, string and operator as one token, but
these are free: , . : ; ) ] } end local, and comments. The limit is 8192.
"""
import re
import sys

FREE = {",", ".", ":", ";", "::", ")", "]", "}", "end", "local"}
TOK = re.compile(r"""
    \[(=*)\[.*?\]\1\]          # long string
  | "(?:\\.|[^"\\])*"          # "string"
  | '(?:\\.|[^'\\])*'          # 'string'
  | 0x[0-9a-fA-F.]+ | 0b[01.]+ | \d+\.?\d*(?:e-?\d+)? | \.\d+
  | [A-Za-z_][A-Za-z_0-9]*
  | \.\.\.|\.\.=|\.\.|::|==|~=|!=|<=|>=|\+=|-=|\*=|/=|\\=|%=|\^=|<<|>>
  | \S
""", re.S | re.X)


def lua_of(path):
    text = open(path).read()
    m = re.search(r"__lua__\n(.*?)(?:\n__\w+__\n|\Z)", text, re.S)
    return m.group(1) if m else text


def count(src):
    src = re.sub(r"--\[(=*)\[.*?\]\1\]", "", src, flags=re.S)  # block comments
    src = re.sub(r"--[^\n]*", "", src)                          # line comments
    n = 0
    for m in TOK.finditer(src):
        if m.group(0) not in FREE:
            n += 1
    return n


if __name__ == "__main__":
    for p in sys.argv[1:]:
        lua = lua_of(p)
        print(f"{p}: ~{count(lua)} tokens of 8192, {len(lua)} chars of 65535")
