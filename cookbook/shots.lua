-- plays every recipe and takes a screenshot of each.
-- run: python3 tools/smoke.py cookbook/cookbook.p8 cookbook/shots.lua
frames(2) shot("menu")
local keys={{},{1,3,5},{1,5},{1,2},{1,3},{1,3},{1,4},{4},{4},{0,5},{1,3},{4},{4},{4},{4,5},{4},{4},{4},{4}}
for i=1,#r do
 go(i)
 press(unpack(keys[i])) frames(40)
 shot("r"..i)
end
