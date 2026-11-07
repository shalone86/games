-- screenshots of each mode.
-- run: python3 tools/smoke.py kaiju/kaiju.p8 kaiju/shots.lua
frames(3) shot("title")
for m=1,#modes do
 start(m)
 press(1) frames(25) press(1,3) frames(20)
 local hold={{5},{4},{4},{},{},{1}}
 if m==2 then press(4) frames(1) press() frames(1) press(1) frames(5) end
 press(unpack(hold[m])) frames(m==3 and 12 or 6)
 if m==6 then frames(60) end
 k.inv=0
 shot("mode"..m)
end
