-- stub: drw_title drw_over upd_title bolt rainbow edge
-- every kaiju in both modes: grab, breath, z move, orbs,
-- rage, late waves, then a win (city / boss).
-- (kept tiny: the cart is near the token limit)
for c=1,4 do for m=1,2 do
 sel,gm=c,m start() frames(80)
 press(4,5) frames(2) press(1,5) frames(30) press(4) frames(3) press() frames(20)
 k.rage=35 add(drops,{x=k.x,y=k.y,s=41}) add(drops,{x=k.x,y=k.y,o=pk.sk[3]}) frames(60)
 k.hp=99 wave=7 secs=174 tm=29 frames(30)
 if m==1 then nd=goal-1 hit(k.x,k.y,60,9) else rival.hp=1 hit(rival.x,rival.y,9,9,true) end
 frames(5) printh(c.." "..m.." "..st.." "..tostr(won).." "..pts(score))
end end
