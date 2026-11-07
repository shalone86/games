-- plays kaiju rage headless.
-- run: python3 tools/smoke.py kaiju/rage.p8 kaiju/rage_smoke.lua
frames(3)
for c=1,#roster do
 sel=c start()
 -- chord grab, then throw
 local b=bump(k.x+12,k.y) 
 press(4,5) frames(2) printh(roster[c].n.." held after z+x: "..tostr(k.held))
 press() frames(2)
 -- a held thing: any button throws
 if not k.held then k.held,k.hw=32,1 end
 press(5) frames(1) press() frames(1)
 printh("  thrown: "..#objs.." objs, held="..tostr(k.held))
 -- z tap = dash/leap
 press() frames(5) press(4) frames(3) press() frames(2)
 printh("  z move: dash="..k.dash.." jump="..k.jt)
 frames(60)
 -- x hold = breath
 press(1,5) frames(20) printh("  breath len="..k.bl.." en="..k.en)
 -- orbs: a second skill, then a swap prompt
 press() frames(15)
 add(drops,{x=k.x,y=k.y,o=roster[c].sk[3]}) frames(2)
 add(drops,{x=k.x,y=k.y,o=roster[c].sk[4]}) frames(2)
 printh("  slots "..sk[k.sl[1]].n.."/"..sk[k.sl[2]].n.." pending="..tostr(k.pend!=nil))
 press(4) frames(1) press() frames(2)
 printh("  after z swap: "..sk[k.sl[1]].n.."/"..sk[k.sl[2]].n)
 -- rage meter
 k.rage=19 add(drops,{x=k.x,y=k.y,s=41}) frames(2)
 printh("  rampage frames="..k.rg)
 -- every skill at level 3 for a while
 for j=1,5,2 do
  k.sl={roster[c].sk[j],roster[c].sk[j+1] or roster[c].sk[1]} k.lv={3,3} k.tm={0,0}
  local pats={{0},{1,5},{2,4},{3},{0,2}}
  for i=1,10 do press(unpack(pats[i%5+1])) k.inv=99 frames(20) end
 end
 -- rival
 rt=1 frames(2) printh("  rival: "..tostr(rival!=nil))
 rival.x,rival.y=k.x+30,k.y k.inv=0
 for i=1,40 do press(1,5) frames(5) if st!="play" then break end end
 printh("  rival hp="..(rival and rival.hp or "beaten").." run="..tostr(rival and rival.run))
 -- late waves + final
 k.hp=99 k.mhp=99 wave=5 secs=239 tm=29 frames(2) printh("  wave "..wave)
 for i=1,30 do press(i%4,5) k.inv=99 frames(10) end
 local n={0,0,0,0,0,0} for e in all(ens) do n[e.k]+=1 end
 printh("  enemies by kind: "..n[1].." "..n[2].." "..n[3].." "..n[4].." "..n[5].." "..n[6])
 wave=7 secs=279 tm=29 frames(2) printh("  wave "..wave.." fin="..fin)
 for e in all(ens) do if e.k==5 then e.hp=.1 hit(e.x,e.y,4,1,true) end end
 printh("  state "..st.." won="..tostr(won).." score="..score)
 press(4) frames(60) press() frames(5)
end
