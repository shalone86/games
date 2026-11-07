-- a bot plays 3.5 minutes per kaiju (can't die) to check the pacing:
-- when the 2nd skill slot fills, how many orbs and rage modes happen.
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_sim.lua
for c=1,#roster do
 sel=c start()
 local slot2,orbs,rages,lastw,wt=nil,0,0,1,""
 for f=1,30*210 do
  -- walk toward the nearest drop, else wander; breathe now and then
  local tx,ty=k.x+cos(f/400)*60,k.y+sin(f/530)*60
  local bd=999
  for d in all(drops) do local dd=dist(d.x,d.y,k.x,k.y) if dd<bd then bd,tx,ty=dd,d.x,d.y end end
  local b={}
  if tx<k.x-2 then add(b,0) elseif tx>k.x+2 then add(b,1) end
  if ty<k.y-2 then add(b,2) elseif ty>k.y+2 then add(b,3) end
  if f%90<30 then add(b,5) end
  if f%70==0 then add(b,4) end
  press(unpack(b))
  local no,rg=#drops,k.rg
  k.hp=k.mhp
  frames(1)
  if k.rg>rg then rages+=1 end
  if not slot2 and k.sl[2] then slot2=secs end
  if wave!=lastw then lastw=wave wt=wt.." w"..wave.."@"..secs end
  if st!="play" then break end
 end
 printh(roster[c].n..": slot 2 at "..tostr(slot2).."s, rage modes "..rages..", skills "..sk[k.sl[1]].n..k.lv[1].."/"..sk[k.sl[2]].n..k.lv[2]..", state "..st..", score "..score)
 printh("  "..wt)
end
