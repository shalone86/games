-- a bot plays whole games (it can't die) to check the pacing:
-- how long each mode takes and how often rage mode goes off.
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_sim.lua 300
for m=1,2 do for c=1,3 do
 sel,gm=c,m start() local r=0
 for f=1,7000 do
  local tx,ty=k.x+cos(f/400)*60,k.y+sin(f/530)*60
  for d in all(drops) do tx,ty=d.x,d.y end
  press(tx<k.x and 0 or 1,ty<k.y and 2 or 3,f%90<30 and 5 or 9)
  k.hp=k.mhp local g=k.rg frames(1)
  if k.rg>g then r+=1 end
  if st=="over" then break end
 end
 printh(m.." "..roster[c].n.." "..clock().." rage "..r.." won "..tostr(won).." "..pts(score))
end end
