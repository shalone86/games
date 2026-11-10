#!/bin/sh
# PICO-8's own token count for a cart: pads it with 600 tokens so it's
# too big, runs it, and reads the count from the error.
#   sh tools/realtokens.sh kaiju/rage.p8
P8=${PICO8:-/Applications/PICO-8.app/Contents/MacOS/pico8}
d=$(mktemp -d)
python3 - "$1" "$d/c.p8" <<'PY'
import sys
t=open(sys.argv[1]).read()
a,b=t.split("\n__gfx__\n",1)
open(sys.argv[2],"w").write(a+"\n"+"\n".join("zz%d=1"%i for i in range(200))+"\n__gfx__\n"+b)
PY
"$P8" -x "$d/c.p8" > "$d/log" 2>&1 & p=$!
sleep 4; kill $p 2>/dev/null
n=$(grep -ao "[0-9]* / 8192" "$d/log" | cut -d' ' -f1)
echo "$1: $((n-600)) of 8192 tokens"
rm -r "$d"
