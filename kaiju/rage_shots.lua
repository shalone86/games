-- screenshots of kaiju rage.
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_shots.lua
frames(2) shot("r_title")
-- gora breathing, with flame + stomp, big enemies around
sel=1 start() wave=6
k.sl={1,2} k.lv={2,1}
for i=1,6 do spawn(pick()) end spawn(3) spawn(4) spawn(5)
for e in all(ens) do e.x,e.y=k.x+rnd(100)-50,k.y+rnd(90)-50 end
press(1) frames(20) press(1,5) frames(12) k.inv=0 shot("r_gora")
-- a skill orb prompt + rage meter half full
k.rage=12 press() add(drops,{x=k.x,y=k.y,o=5}) frames(2) shot("r_swap")
-- rage mode
k.rage=19 add(drops,{x=k.x+1,y=k.y,s=41}) del(drops,k.pend) frames(14) shot("r_rampage")
press(1,5) frames(20) shot("r_rage2") press()
-- luna leaping with spores + zap, a rival nearby
sel=2 start() k.sl={7,8} k.lv={3,2}
rt=1 frames(2) rival.x,rival.y=k.x+40,k.y-10
for i=1,5 do spawn(1) end
press(2) frames(20) press(4) frames(8) press(1) frames(20) shot("r_luna")
-- korax holding a building, rival fleeing off screen
sel=3 start() k.sl={11,15} k.lv={2,2}
k.held,k.hw=10,2
rt=1 frames(2) rival.x,rival.y=k.x-120,k.y+20 rival.hp=5 rival.run=true
spawn(5) spawn(3) for e in all(ens) do if e.k!=6 then e.x,e.y=k.x+30+rnd(20),k.y-20+rnd(30) end end
press(3) frames(25) k.inv=0 shot("r_korax")
-- final wave + win
k.hp=99 wave=7 secs=279 tm=29 frames(3)
for e in all(ens) do if e.k==5 then e.x,e.y=k.x+rnd(80)-40,k.y+rnd(60)-40 end end
frames(30) k.inv=0 shot("r_final")
for e in all(ens) do if e.k==5 then e.hp=.1 hit(e.x,e.y,4,1,true) end end
frames(50) shot("r_win")
