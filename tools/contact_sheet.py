#!/usr/bin/env python3
"""Join screenshots (made by smoke.py's shot()) into one picture.

    python3 tools/contact_sheet.py kaiju/shots/sheet.png kaiju/shots/title.png kaiju/shots/mode*.png
"""
import struct
import sys
import zlib


def read(path):
    d = open(path, "rb").read()
    i, idat, w = 8, b"", 0
    while i < len(d):
        n = struct.unpack(">I", d[i:i + 4])[0]
        t = d[i + 4:i + 8]
        if t == b"IHDR":
            w, h = struct.unpack(">II", d[i + 8:i + 16])
        if t == b"IDAT":
            idat += d[i + 8:i + 8 + n]
        i += 12 + n
    raw = zlib.decompress(idat)
    rows = []
    for y in range(0, h, 2):  # half size
        r = raw[y * (w * 3 + 1) + 1:(y + 1) * (w * 3 + 1)]
        rows.append(b"".join(r[x * 3:x * 3 + 3] for x in range(0, w, 2)))
    return rows


def main(out, paths, cols=4, gap=8):
    imgs = [read(p) for p in paths if not p.endswith(out)]
    size = len(imgs[0])
    rows_n = (len(imgs) + cols - 1) // cols
    bg = b"\x20\x20\x28"
    W = cols * size + (cols - 1) * gap
    lines = []
    for gy in range(rows_n):
        for y in range(size):
            row = b""
            for gx in range(cols):
                k = gy * cols + gx
                row += imgs[k][y] if k < len(imgs) else bg * size
                if gx < cols - 1:
                    row += bg * gap
            lines.append(row)
        if gy < rows_n - 1:
            lines += [bg * W] * gap
    raw = b"".join(b"\0" + r for r in lines)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, len(lines), 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    open(out, "wb").write(png)
    print("wrote", out)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
