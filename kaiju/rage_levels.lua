-- stub: drw_title drw_over drw_hud drw_play drw_bld drw_e drw_k bolt
-- a bot wanders through 12 survive games (it can't die and doesn't chase
-- orbs) to measure how fast skills level up: seconds until slot 2 fills,
-- until the first level 2, the first level 3, and both skills at level 3.
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_levels.lua 500
s={0,0,0,0}
for r=1,4 do for c=1,3 do
 sel,gm=c,2 start() local t={}
 for f=1,5400 do
  local tx,ty=k.x+cos(f/400)*60,k.y+sin(f/530)*60
  press(tx<k.x and 0 or 1,ty<k.y and 2 or 3,f%90<30 and 5 or 9)
  k.hp=k.mhp frames(1)
  local a,b=k.lv[1],k.lv[2] or 0
  t[1]=t[1] or k.sl[2] and secs
  t[2]=t[2] or max(a,b)>1 and secs
  t[3]=t[3] or max(a,b)>2 and secs
  t[4]=t[4] or a+b>5 and secs
  if st=="over" then break end
 end
 for i=1,4 do s[i]+=(t[i] or 180)/12 end
end end
printh("slot2 "..s[1].."  lv2 "..s[2].."  lv3 "..s[3].."  both3 "..s[4])
