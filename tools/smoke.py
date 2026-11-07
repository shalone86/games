#!/usr/bin/env python3
"""Play a cart headless for a while with fake button presses and report
any runtime error. Needs PICO-8 installed.

    python3 tools/smoke.py kaiju/kaiju.p8 kaiju/smoke.lua

The second file is Lua that drives the test: it is pasted after the cart's
code and can call _init/_update/_draw itself. It may use press(...) to
choose which buttons are held, and printh() to report.
"""
import os
import re
import subprocess
import sys
import tempfile
import time

PICO8 = os.environ.get("PICO8", "/Applications/PICO-8.app/Contents/MacOS/pico8")

HARNESS = """
-- smoke harness
__held={}
function press(...) __held={} for b in all({...}) do __held[b]=true end end
__real_btn,__real_btnp=btn,btnp
__f=0
-- never touch the real save file
__saves={}
function dset(i,v) __saves[i]=v end
function dget(i) return __saves[i] or 0 end
function btn(b) return __held[b] or false end
__prev={}
-- true only on the frame the button goes down
function btnp(b) return (__held[b] and not __prev[b]) or false end
function shot(name)
 printh("shot:"..name)
 for y=0,127 do
  local r=""
  for x=0,127 do r..=sub("0123456789abcdef",pget(x,y)+1,pget(x,y)+1) end
  printh("px:"..r)
 end
end
function frames(n)
 for i=1,n do
  __f+=1 _update() _draw()
  __prev={} for b,v in pairs(__held) do __prev[b]=v end
 end
end
"""


PAL = ["000000", "1d2b53", "7e2553", "008751", "ab5236", "5f574f", "c2c3c7", "fff1e8",
       "ff004d", "ffa300", "ffec27", "00e436", "29adff", "83769c", "ff77a8", "ffccaa"]


def save_shots(log, folder):
    """shot(name) in the driver saves <folder>/shots/<name>.png at 4x size."""
    import struct, zlib
    name, rows = None, []
    for line in log.split("\n") + ["shot:"]:
        if line.startswith("shot:"):
            if name and len(rows) == 128:
                os.makedirs(os.path.join(folder, "shots"), exist_ok=True)
                raw = b""
                for r in rows:
                    px = b"".join(bytes.fromhex(PAL[int(c, 16)]) * 4 for c in r)
                    raw += (b"\0" + px) * 4
                def chunk(t, d):
                    return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
                png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 512, 512, 8, 2, 0, 0, 0))
                png += chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b"")
                open(os.path.join(folder, "shots", name + ".png"), "wb").write(png)
            name, rows = line[5:].strip(), []
        elif line.startswith("px:"):
            rows.append(line[3:].strip())


def main(cart, driver, wait=60):
    text = open(cart).read()
    drv = open(driver).read()
    text = text.replace("__lua__\n", "__lua__\n", 1)
    parts = re.split(r"(\n__gfx__\n)", text, maxsplit=1)
    body = parts[0] + "\n-->8\n" + HARNESS + "\n" + drv + "\nprinth('smoke: done')\n"
    out = body + "".join(parts[1:])
    with tempfile.TemporaryDirectory() as d:
        path = os.path.join(d, "smoke.p8")
        open(path, "w").write(out)
        logf = open(os.path.join(d, "log.txt"), "w")
        p = subprocess.Popen([PICO8, "-x", path], stdout=logf, stderr=subprocess.STDOUT)
        t0 = time.time()
        while p.poll() is None and time.time() - t0 < wait:
            time.sleep(0.2)
        if p.poll() is None:
            p.kill()
        logf.close()
        log = open(os.path.join(d, "log.txt")).read()
    save_shots(log, os.path.dirname(os.path.abspath(cart)))
    log = "\n".join(l for l in log.split("\n") if not l.startswith("px:"))
    print(log)
    ok = "smoke: done" in log and "error" not in log.lower()
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
