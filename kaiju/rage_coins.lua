-- stub: drw_title drw_over drw_hud drw_play drw_bld drw_e drw_k bolt upd_title
-- a bot wanders (it can't die, doesn't chase pickups) through 8 games
-- per mode: how long they take, coins picked up, and rage per game.
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_coins.lua 580
r0=rampage
function rampage() rc+=1 r0() end
for m=1,2 do
 local s,c,r=0,0,0
 for g=1,8 do
  sel,gm=g%4+1,m start() rc=0
  for f=1,7000 do
   local tx,ty=k.x+cos(f/400)*60,k.y+sin(f/530)*60
   press(tx<k.x and 0 or 1,ty<k.y and 2 or 3,f%90<30 and 5 or 9)
   k.hp=k.mhp frames(1)
   if st=="over" then break end
  end
  s+=secs/8 c+=(rc*36+k.rage)/8 r+=rc/8
 end
 printh("mode "..m.."  "..s.."s  coins "..c.."  rage "..r)
end
