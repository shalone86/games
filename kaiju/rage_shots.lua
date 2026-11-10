-- stub: grab throw upd_title
-- screenshots (kept tiny: the cart is near the token limit)
frames(2) shot("r_title")
gm=1 start() frames(20) shot("r_intro1")
press(1,5) frames(150) shot("r_destroy")
gm=2 sel=3 start() frames(20) shot("r_intro2")
k.hp=99 secs=49 tm=29 press(2) frames(20) shot("r_wave")
wave=7 secs=174 tm=29 frames(40) rival.x,rival.y=k.x+36,k.y-10 frames(25) shot("r_boss")
rival.hp=1 hit(rival.x,rival.y,9,9,true) frames(50) shot("r_win")
sel=4 frames(1) st="title" frames(2) shot("r_title4")
gm=2 start() frames(80) k.sl,k.lv={16,18},{3,3}
for i=1,6 do spawn(3) end
press(1) frames(60) press(5) frames(14) shot("r_dtron")
