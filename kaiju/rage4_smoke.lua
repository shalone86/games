-- stub: drw_title upd_title rainbow edge big drw_over drw_hud
-- 4 players in all three modes: random buttons for everyone,
-- late waves, friendly fire knockouts, down + back, and each
-- mode's ending. reports the busiest frame (cpu, 1 = all).
__pl={[0]={},{},{},{}}
function btn(b,n)
 if not b then
  local m=0
  for p=0,3 do for i=0,5 do if __pl[p][i] then m+=1<<(i+p*8) end end end
  return m
 end
 return __pl[n or 0][b] or false
end
function btnp(b,n) return btn(b,n) and rnd()<.2 end
cpu=0
function mash(n)
 for f=1,n do
  for p=0,3 do
   __pl[p]={}
   for i=0,5 do __pl[p][i]=rnd()<(i<4 and .3 or .15) end
  end
  _update() _draw()
  cpu=max(cpu,stat(1))
 end
end
for m=1,3 do
 js={[0]=1,2,3,4} md=m start() mash(120)
 printh(m.." start "..st.." np "..np.." al "..#al)
 wave=6 secs=149 tm=29 mash(400)
 printh(m.." late wave "..wave.." ens "..#ens.." st "..st)
 for p in all(ks) do p.sl[2]=p.pk.sk[2] p.lv={3,3} end
 mash(300)
 if m==2 then
  -- friendly fire: p1 hits p2 hard
  ks[2].hp=1 ks[2].inv=0 ks[2].shell=0 ks[2].rg=0
  use(ks[1]) hit(ks[2].x,ks[2].y-6,4,9)
  printh("ff: p2 down "..tostr(ks[2].dn).." p1 sc "..ks[1].sc)
  mash(100)
  printh("p2 back "..tostr(not ks[2].dn).." stop "..stop)
 end
 if m<3 then
  secs=179 tm=29 mash(2)
  printh(m.." over "..st.." won "..tostr(won).." winner p"..wn.n+1 .." score "..score)
 else
  -- one down, then the next wave brings it back
  use(ks[3]) ks[3].inv=0 ks[3].safe=false ks[3].rg=0 ks[3].hp=.1 hurt(5)
  printh("p3 down "..tostr(ks[3].dn).." al "..#al)
  secs=174 tm=29 mash(40)
  printh("wave "..wave.." p3 back "..tostr(not ks[3].dn).." boss "..tostr(rival and rival.boss))
  use(ks[1]) rival.hp=1 hit(rival.x,rival.y,9,9,true) mash(3)
  printh("boss: "..st.." won "..tostr(won).." team "..score)
  -- and everyone down = over
  js={[0]=1,2} md=3 start() mash(30)
  for p in all(ks) do use(p) p.inv=0 p.rg=0 p.shell=0 p.hp=.1 upd_k() hurt(5) end
  printh("all down: "..st.." won "..tostr(won))
 end
end
printh("cpu max "..cpu)
