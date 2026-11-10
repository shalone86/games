-- stub: drw_title drw_over upd_title
-- every skill at level 3 for 8 s with enemies around: no errors, and
-- how many points it made (the kaiju stands still and can't die).
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_skills.lua 200
for id=1,#sk do
 sel,gm=(id-1)\5+1,2 start() frames(80)
 k.sl,k.lv,k.tm={id},{3,0},{0,0}
 local s0=score
 for f=1,240 do
  if f%20==0 then spawn(1+f%3) end
  k.hp=k.mhp frames(1)
 end
 printh(id.." "..sk[id].n.." "..sk[id].a.." points "..pts(score-s0).." arm "..k.arm.." reg "..k.reg)
end
