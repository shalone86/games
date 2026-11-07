-- plays every mode headless.
-- run: python3 tools/smoke.py kaiju/kaiju.p8 kaiju/smoke.lua
frames(5)
for m=1,#modes do
 sel=m start(m)
 local pats={{1},{1,4},{3,5},{0,2,4},{0,5},{2},{1,3,5},{4}}
 for i=1,40 do
  press(unpack(pats[i%#pats+1]))
  frames(30)
  if st=="over" then break end
 end
 printh(modes[m].name..": t="..secs.."s score="..score.." hp="..k.hp.." sz="..k.sz.." ens="..#ens.." left="..#blds.." st="..st.." cpu="..stat(1))
 -- force a death to test game over
 k.inv,k.safe=0,false
 for i=1,30 do if st=="play" then hurt(1) k.inv=0 end end
 press(4) frames(60)
 printh("  after death st="..st)
end
