pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- kaiju rage
-- by shalone cason
-- (working title. stand-in
--  art + sounds: redraw!)
--
-- tab 0 setup, states, buttons
-- tab 1 kaiju + their skills
-- tab 2 the city
-- tab 3 the kaiju moves
-- tab 4 army + rival
-- tab 5 effects + pickups
-- tab 6 drawing + hud

cartdata("sdcason_kaiju_rage")
world=384
-- gm: 1 destroy the city,
--     2 survive the waves
st,sel,gm="title",1,1
-- buildings, by kind+1:
-- tree, house, office, tower
bhp=split"1,1,3,6"
bpts=split"1,10,25,50"
bspr=split"37,6,8,10"
-- enemies: sprite, size,
-- hp, defense (= attack),
-- speed, points. by kind:
-- 1 tank 2 heli 3 big tank
-- 4 bomber 5 mech 6 rival
et={}
for s in all(split("32,1,1,1,.3,20|33,1,1,1,.6,30|76,2,2,2,.25,60|78,2,2,2,1.1,80|96,2,10,2,.4,300|0,2,20,1,.7,500","|")) do
 add(et,split(s))
end

function _update()
 if st=="title" then upd_title()
 elseif st=="play" then upd_play()
 elseif st=="intro" then
  -- the big goal message
  it-=1
  if it<=0 then st="play" end
 else
  ot+=1 upd_fx()
  if ot>45 and (btnp(4) or btnp(5)) then st="title" end
 end
end

function _draw()
 if st=="title" then drw_title() else drw_play() end
end

function upd_title()
 if btnp(0) then sel-=1 sfx(8) end
 if btnp(1) then sel+=1 sfx(8) end
 if btnp(2) or btnp(3) then gm=3-gm sfx(8) end
 sel=(sel-1)%#roster+1
 if btnp(4) or btnp(5) then start() end
end

function start()
 pk=roster[sel]
 make_city()
 -- destroy mode: wreck half
 goal,nd,tb=flr(nb*.5),0
 k={x=world/2,y=world/2,vx=0,vy=0,
  fx=1,fy=0,face=1,fr=0,z=0,
  hp=pk.hp,mhp=pk.hp,inv=0,en=60,bl=0,
  dash=0,dcd=0,fly=0,jcd=0,zt=0,xt=0,
  rage=0,rg=0,shell=0,ang=0,
  -- 2 skill slots: skill,
  -- level, timer
  sl={pk.sk[1]},lv={1,0},tm={0,0}}
 ens,shots,fx,pops,drops,objs,clouds,bolts={},{},{},{},{},{},{},{}
 score,tm,secs,shake,stop,bt,flash=0,0,0,0,0,0,0
 spawn_t,wave,rt,rival,dm=60,1,750,nil,1
 cx,cy=k.x-64,k.y-64
 st,it="intro",75
 music(0,0,3)
end

function over(w)
 st,ot,won="over",0,w
 music(-1) sfx(w and 9 or 2)
 -- destroy: the faster, the
 -- more points. survive: a
 -- bonus for beating the boss
 if w then score=min(score+(gm==1 and max(0,300-secs)*5 or 100),32000)
 else boom(k.x,k.y-8,40) end
 -- best scores: slots 4-6
 -- destroy, 7-9 survive
 best=dget(sel+gm*3)
 if score>best then dset(sel+gm*3,score) end
end

-- x hold: breath
-- z: dash or leap
-- z+x together: grab
-- holding something: any
--  button throws it
function buttons()
 local z,x,pz=btn(4),btn(5),k.zt
 if not (z or x) then k.lock=false end
 k.zt=z and k.zt+1 or 0
 k.xt=x and k.xt+1 or 0
 if k.lock then k.bl=0 return end
 if k.held then
  if btnp(4) or btnp(5) then throw() k.lock=true end
  return
 end
 -- both pressed within 5
 -- frames of each other = grab
 if k.zt>0 and k.xt>0 and k.zt<6 and k.xt<6 then
  grab() k.lock=true return
 end
 -- so z waits 5 frames (or
 -- until let go) before acting
 if k.zt==6 or (not z and pz>0 and pz<6 and k.xt==0) then
  zmove()
 end
 if k.xt>=6 then breath()
 else k.bl=0 k.en=min(k.en+.4,60) end
end

-->8
-- kaiju + their skills

-- z: dash (walkers) or leap
-- (flyers). sp = first sprite
-- (walk 1, walk 2, attack).
-- bc = breath color.
-- sk = its 5 skills below
roster={
 {n="gora",d="big lizard",z="dash",sp=0,hp=10,spd=1.2,bc=12,sk=split"1,2,3,4,5"},
 {n="luna",d="giant moth",z="fly",sp=64,hp=8,spd=1.35,bc=10,sk=split"6,7,8,9,10"},
 {n="korax",d="spiked tank",z="dash",sp=70,hp=13,spd=1.05,bc=9,sk=split"11,12,13,14,15"},
}

-- each skill: name, orb color,
-- f(level): fires, returns
--  frames until it fires again
-- p(level): every frame
-- d(level): extra drawing
sk={
 -- gora
 {n="flame",c=9,f=function(l)
  local e=near(56)
  if not e then return 10 end
  local a=atan2(e.x-k.x,e.y-k.y+6)
  for i=6,30+l*10,5 do
   local x,y=k.x+cos(a)*i,k.y-6+sin(a)*i
   hit(x,y,2+l,1)
   add(fx,{x=x,y=y,dx=rnd()-.5,dy=-rnd(),t=8+rnd(8),c=rnd(split"8,9,10")})
  end
  sfx(1)
  return 80-l*15
 end},
 {n="stomp",c=4,f=function(l)
  nova(14+l*6,1+l,4) return 110-l*20
 end},
 -- dizzy enemies wander and
 -- shoot the wrong way
 {n="roar",c=13,f=function(l)
  dizzy(40+l*12,90+l*30) return 240-l*30
 end},
 -- stone skin: takes less damage
 {n="hide",c=6,p=function(l)
  k.arm*=1-l*.2 k.tint=true
 end},
 -- heals, but slower and
 -- takes more damage
 {n="rejuv",c=11,p=function(l)
  k.reg+=.005*l k.spm*=.8 k.arm*=1.5
 end},
 -- luna
 {n="gust",c=7,f=function(l)
  local r=36+l*8
  for e in all(ens) do
   if dist(e.x,e.y,k.x,k.y)<r then push(e,20) end
  end
  for s in all(shots) do
   if dist(s.x,s.y,k.x,k.y)<r then del(shots,s) end
  end
  ring(k.x,k.y-6,r,7) sfx(6)
  return 150-l*25
 end},
 {n="spores",c=14,p=function(l)
  k.ang+=.012
  for i=0,l do
   local x,y=orbit(i,l+1)
   if tm%5==0 then hit(x,y,3,1) end
   for s in all(shots) do
    if abs(s.x-x)<5 and abs(s.y-y)<5 then del(shots,s) end
   end
  end
 end,d=function(l)
  for i=0,l do
   local x,y=orbit(i,l+1)
   circfill(x,y,2,14) pset(x,y,7)
  end
 end},
 {n="zap",c=12,f=function(l)
  local e=near(70)
  if not e then return 10 end
  add(bolts,{x=e.x,y=e.y,t=5})
  hit(e.x,e.y,3,1+l\2,true) sfx(1)
  return 50-l*10
 end},
 -- leaves a cloud that hurts
 -- what's inside it
 {n="dust",c=10,f=function(l)
  add(clouds,{x=k.x,y=k.y,t=90+l*30,r=10+l*3})
  return 70
 end},
 -- heals while standing still
 {n="cocoon",c=11,p=function(l)
  if k.vx==0 and k.vy==0 then k.reg+=.012*l end
 end},
 -- korax
 {n="spikes",c=6,f=function(l)
  for i=1,l*4 do
   local a=i/(l*4)+k.ang
   add(objs,{x=k.x,y=k.y-4,dx=cos(a)*3,dy=sin(a)*3,t=15,r=3,d=1})
  end
  k.ang+=.06 sfx(7)
  return 70
 end},
 {n="quake",c=4,f=function(l)
  nova(28+l*8,2,4) shake=5 return 160-l*20
 end},
 -- can't be hurt for a moment
 {n="shell",c=12,f=function(l)
  k.shell=45+l*20 sfx(9) return 300-l*40
 end},
 -- getting hit hurts them back
 {n="thorns",c=3,p=function(l) k.thorn=l end},
 {n="rock",c=9,f=function(l)
  local e=near(80)
  if not e then return 10 end
  add(objs,{x=k.x,y=k.y,dx=(e.x-k.x)/20,dy=(e.y-k.y)/20,t=20,r=12+l*4,d=1+l})
  sfx(6)
  return 90-l*10
 end},
}

-- skill helpers
function near(r)
 local tg,td=nil,r
 for e in all(ens) do
  local d=dist(e.x,e.y,k.x,k.y)
  if d<td then tg,td=e,d end
 end
 return tg
end

function nova(r,d,c)
 hit(k.x,k.y,r,d) ring(k.x,k.y,r+4,c)
 shake=max(shake,2) sfx(0)
end

function dizzy(r,t)
 for e in all(ens) do
  if dist(e.x,e.y,k.x,k.y)<r then e.dz=t end
 end
 ring(k.x,k.y-8,r,13) sfx(5)
end

function push(e,d)
 local a=atan2(e.x-k.x,e.y-k.y)
 e.x+=cos(a)*d e.y+=sin(a)*d
end

function orbit(i,n)
 local a=k.ang+i/n
 return k.x+cos(a)*20,k.y-6+sin(a)*14
end

function has(id)
 for i=1,2 do
  if k.sl[i]==id then return i end
 end
end

-- a random skill orb for
-- the kaiju you're playing
function orb() return pk.sk[flr(rnd(5))+1] end

-->8
-- the city

function make_city()
 -- gr: the building on each
 -- 16x16 lot, so we only ever
 -- look at the ones nearby
 gr,nb={},0
 for bx=0,world-1,64 do
  for by=0,world-1,64 do
   for i=0,2 do
    for j=0,2 do
     local x,y,r=bx+16+i*16,by+16+j*16,rnd()
     local kd=r<.25 and 0 or r<.6 and 1 or r<.85 and 2 or 3
     if r<.93 and dist(x+8,y+8,world/2,world/2)>40 then
      gr[x\16+y\16*24]={x=x,y=y,k=kd,hp=bhp[kd+1],fl=0}
      if kd>0 then nb+=1 end
     end
    end
   end
  end
 end
end

-- distance that can't overflow
function dist(x1,y1,x2,y2)
 local dx,dy=(x2-x1)/16,(y2-y1)/16
 return sqrt(dx*dx+dy*dy)*16
end

-- standing buildings within
-- about r of x,y
function near_b(x,y,r)
 local l={}
 for i=(x-r)\16-1,(x+r)\16+1 do
  for j=(y-r)\16-1,(y+r)\16+1 do
   local b=gr[i+j*24]
   if b and not b.dead then add(l,b) end
  end
 end
 return l
end

function bump(x,y)
 for b in all(near_b(x,y,8)) do
  local h=b.k==0 and 7 or 11
  if abs(x-b.x-8)<h and abs(y-b.y-8)<h then
   return b
  end
 end
end

function smash(b)
 b.dead=true
 addscore(bpts[b.k+1],b.x+8,b.y)
 boom(b.x+8,b.y+8,b.k*4+3)
 shake=max(shake,b.k)
 sfx(b.k<2 and 10 or 2)
 if b.k>0 then
  drop(b.x+8,b.y+8,b.k>1 and .2 or .06)
  nd+=1
  if gm==1 and nd>=goal and st=="play" then over(true) end
 end
end

-- hurt every building and
-- enemy in a box around x,y.
-- eo = enemies only.
function hit(x,y,r,d,eo)
 local n=0
 d*=dm
 if not eo then
  for b in all(near_b(x,y,r+6)) do
   if abs(b.x+8-x)<r+6 and abs(b.y+8-y)<r+6 then
    n+=1 b.hp-=d b.fl=4
    if b.hp<=0 then smash(b) end
   end
  end
 end
 for e in all(ens) do
  local w=r+e.w*4
  if abs(e.x-x)<w and abs(e.y-y)<w then
   n+=1 e.hp-=d/e.df e.fl=4
   if e.hp<=0 then kill(e) end
  end
 end
 return n
end

-->8
-- the kaiju moves

function upd_play()
 if stop>0 then stop-=1 return end
 tm+=1
 if tm==30 then
  tm,secs=0,secs+1
  -- a new wave every 25 s
  if secs%25==0 and wave<8 then
   wave+=1
   -- and a skill orb near you
   add(drops,{x=k.x+rnd(48)-24,y=k.y+rnd(48)-24,o=orb()})
   if gm==2 then
    -- surviving a wave pays
    addscore(500,k.x,k.y-20)
    if wave==8 then
     if rival then del(ens,rival) end
     spawn(6)
     banner("final wave","beat the boss!")
    else
     banner("wave "..wave,8-wave.." waves left")
    end
   else
    banner("wave "..wave)
   end
  end
 end

 -- skills set these fresh
 -- every frame
 k.arm,k.spm,k.reg,k.tint,k.thorn=1,1,0,false,0
 k.atk,k.safe=false,false
 k.inv=max(k.inv-1,0)
 for i=1,2 do
  local id=k.sl[i]
  if id then
   local s,l=sk[id],k.lv[i]
   if s.p then s.p(l) end
   if s.f then
    k.tm[i]-=1
    if k.tm[i]<=0 then k.tm[i]=s.f(l) end
   end
  end
 end
 if k.shell>0 then k.shell-=1 k.safe=true end
 dm=1
 if k.rg>0 then
  -- rage mode: double damage +
  -- points, faster, can't be
  -- hurt, and anything you
  -- touch blows up
  k.rg-=1 k.safe,dm=true,2 k.spm*=1.5
  if tm%2==0 then hit(k.x,k.y-6,12,3) end
  add(fx,{x=k.x+rnd(20)-10,y=k.y-rnd(24),dx=rnd()-.5,dy=-rnd(),t=12,c=rnd(split"7,10,9,8,14,12,11")})
  if k.rg==0 then music(0,0,3) banner("rage over") end
 end
 k.hp=min(k.hp+k.reg,k.mhp)

 local ix,iy=0,0
 if btn(0) then ix=-1 end
 if btn(1) then ix=1 end
 if btn(2) then iy=-1 end
 if btn(3) then iy=1 end
 if ix!=0 and iy!=0 then ix*=.707 iy*=.707 end
 if ix!=0 or iy!=0 then
  k.fx,k.fy=ix,iy
  if ix!=0 then k.face=sgn(ix) end
  k.fr+=.15
 end
 local s=pk.spd*k.spm
 k.vx,k.vy=ix*s,iy*s

 buttons()
 k.dcd=max(k.dcd-1,0)
 k.jcd=max(k.jcd-1,0)
 if k.dash>0 then
  k.dash-=1 k.safe,k.atk=true,true
  k.vx,k.vy=k.fx*3.5,k.fy*3.5
  hit(k.x,k.y-4,8,2,true)
  add(fx,{x=k.x,y=k.y-8,dx=0,dy=0,t=6,c=9})
 end
 if k.fly>0 then
  k.fly-=1 k.z=min(k.z+2,24)
 elseif k.z>0 then
  k.z=max(k.z-6,0)
  if k.z==0 then
   k.jcd=90
   local b=bump(k.x,k.y)
   while b do smash(b) b=bump(k.x,k.y) end
   hit(k.x,k.y,22,3)
   ring(k.x,k.y,26,7) ring(k.x,k.y,16,10)
   shake,stop=6,3 sfx(0)
  end
 end

 move_k()
 upd_objs()
 upd_army()
 upd_fx()
 pickups()
 -- destroy mode: find the
 -- nearest building left
 if gm==1 and tm%15==0 then
  local bd=999
  for _,b in pairs(gr) do
   if b.k>0 and not b.dead then
    local d=dist(b.x+8,b.y+8,k.x,k.y)
    if d<bd then bd,tb=d,b end
   end
  end
 end
end

function zmove()
 if pk.z=="dash" then
  if k.dcd==0 and k.z==0 then
   k.dash,k.dcd=10,40 sfx(6)
  end
 -- fly: z takes off, z again
 -- (or running out) dives down
 -- and stomps. then a 3 s wait
 elseif k.fly>0 then k.fly=0
 elseif k.jcd==0 and k.z==0 then
  k.fly=150 sfx(6)
 end
end

function breath()
 if k.en<=0 then k.bl=0 return end
 if k.rg==0 then k.en-=1 end
 local m=k.rg>0 and 96 or 56
 k.atk=true
 k.vx*=.4 k.vy*=.4
 k.bl=min(k.bl+5,m)
 if tm%3==0 then
  for i=8,k.bl,8 do
   hit(k.x+k.fx*i,k.y-4+k.fy*i,4,1)
  end
 end
 if tm%6==0 then sfx(1) end
end

-- grab what's in front:
-- a small enemy or a building
function grab()
 local gx,gy=k.x+k.fx*10,k.y+k.fy*10-4
 for e in all(ens) do
  if e.k<4 and abs(e.x-gx)<12 and abs(e.y-gy)<12 then
   del(ens,e) addscore(et[e.k][6],e.x,e.y)
   k.held,k.hw=et[e.k][1],e.w
   sfx(3) return
  end
 end
 for b in all(near_b(gx,gy,12)) do
  if b.k>0 and abs(b.x+8-gx)<12 and abs(b.y+8-gy)<12 then
   k.held,k.hw=bspr[b.k+1],2
   smash(b) return
  end
 end
end

function throw()
 add(objs,{x=k.x,y=k.y,dx=k.fx*4,dy=k.fy*4,t=18,s=k.held,w=k.hw,r=16,d=3})
 k.held=nil sfx(6)
end

function move_k()
 if k.z>0 or bump(k.x,k.y) then
  k.x+=k.vx k.y+=k.vy
 else
  try(k.x+k.vx,k.y)
  try(k.x,k.y+k.vy)
 end
 k.x,k.y=mid(8,k.x,world-8),mid(12,k.y,world-4)
end

function try(x,y)
 local b=bump(x,y)
 if b and not crush(b) then return end
 k.x,k.y=x,y
end

-- trees always break. a dash
-- does 3 damage (towers stop
-- it). a rampage breaks all.
function crush(b)
 if b.k==0 or k.rg>0 then smash(b) return true end
 if k.dash>0 then
  b.hp-=3 b.fl=4
  if b.hp>0 then k.dash,shake=0,3 return end
  smash(b) return true
 end
end

function hurt(n)
 if k.safe or k.inv>0 then return end
 k.hp-=n*k.arm
 k.inv,shake=30,4
 sfx(4)
 if k.thorn>0 then nova(24,1+k.thorn,3) end
 if k.hp<=0 then over() end
end

-- the rage meter is full
-- the rage meter is full:
-- rage mode, like a super star
function rampage()
 k.rage,k.rg=0,300
 nova(48,4,7)
 ring(k.x,k.y,70,10) ring(k.x,k.y,90,8)
 shake,stop,flash=8,8,3
 sfx(5) music(1,0,3)
end

-->8
-- army + rival

-- what comes next: bigger
-- things in later waves
function pick()
 local r=rnd()
 if wave>=6 and r<.06 then return 5 end
 if wave>=4 and r<.18 then return 4 end
 if wave>=3 and r<.35 then return 3 end
 return rnd()<.25+wave*.04 and 2 or 1
end

function spawn(kd,a)
 a=a or rnd()
 local q=et[kd]
 local e={k=kd,x=mid(4,k.x+cos(a)*90+rnd(20)-10,world-4),
  y=mid(4,k.y+sin(a)*90+rnd(20)-10,world-4),
  hp=q[3],df=q[4],w=q[2],cd=60+rnd(60),fl=0,dz=0,face=1}
 if kd==4 then
  -- bombers fly straight at
  -- you and keep going
  local b=atan2(k.x-e.x,k.y-e.y)
  e.dx,e.dy=cos(b)*q[5],sin(b)*q[5]
 end
 if kd==6 then
  -- the rival is another
  -- kaiju, tougher each wave.
  -- the last wave of survive:
  -- a giant boss
  e.rk=sel%#roster+1
  e.boss=gm==2 and wave==8
  e.hp=e.boss and 200 or 10+wave*10
  e.mhp=e.hp
  if e.boss then e.w=4 end
  rival=e
  banner("a rival kaiju!")
 end
 add(ens,e)
end

function upd_army()
 spawn_t-=1
 -- squads: tanks and helis
 -- come in groups that grow
 -- with the waves
 if spawn_t<=0 and #ens<10+wave*6 then
  local kd,a=pick(),rnd()
  for i=1,kd<3 and 1+rnd(wave/2+1) or 1 do spawn(kd,a) end
  spawn_t=max(6,50-wave*7)
 end
 if not rival then
  rt-=1
  if rt<=0 then spawn(6) end
 end
 for e in all(ens) do
  local d,a,q=dist(e.x,e.y,k.x,k.y),atan2(k.x-e.x,k.y-e.y),et[e.k]
  local s,kd=q[5],e.k
  e.fl=max(e.fl-1,0) e.cd-=1
  if e.dz>0 then e.dz-=1 a=rnd() end
  if kd==4 then
   e.x+=e.dx e.y+=e.dy
   if d<24 and e.cd<=0 then
    e.cd=12
    add(shots,{x=e.x,y=e.y,dx=0,dy=0,t=30,b=true,d=2})
   end
   if d>160 then del(ens,e) end
  elseif kd==6 then
   rival_ai(e,d,a)
  else
   if d>(kd==5 and 12 or 36) or e.dz>0 then
    e.x+=cos(a)*s e.y+=sin(a)*s
   elseif kd==2 then
    e.x+=cos(a+.25)*s e.y+=sin(a+.25)*s
   end
   if e.cd<=0 and d<80 then
    if kd==5 and d<18 and k.z==0 then
     -- mechs punch up close
     hurt(2) e.cd=40 sfx(10)
    else
     -- mechs fire 3 missiles
     local n=kd==5 and 3 or 1
     e.cd=kd==5 and 150-wave*8 or max(40,110-wave*9)+rnd(40)
     for i=1,n do
      local b=a+(i-(n+1)/2)*.06
      add(shots,{x=e.x,y=e.y,dx=cos(b),dy=sin(b),t=100,s=(kd==2 or kd==5) and 36 or 35,d=e.df})
     end
     sfx(7)
    end
   end
  end
  e.x,e.y=mid(4,e.x,world-4),mid(4,e.y,world-4)
 end

 for s in all(shots) do
  if s.s==36 then
   -- missiles steer a little
   local a=atan2(k.x-s.x,k.y-8-s.y)
   s.dx=s.dx*.98+cos(a)*.04
   s.dy=s.dy*.98+sin(a)*.04
  end
  s.x+=s.dx s.y+=s.dy s.t-=1
  if s.b then
   -- a bomb: blows up where it
   -- fell, buildings and all
   if s.t<0 then
    del(shots,s)
    hit(s.x,s.y,10,2)
    ring(s.x,s.y,14,9) boom(s.x,s.y,8) sfx(2)
    if abs(s.x-k.x)<12 and abs(s.y-k.y+6)<12 and k.z==0 then hurt(2) end
   end
  elseif s.t<0 then
   del(shots,s)
  elseif abs(s.x-k.x)<5 and abs(s.y-k.y+7+k.z)<7 and (k.z==0 or s.s==36 or s.c) then
   del(shots,s) boom(s.x,s.y,5) hurt(s.d)
  end
 end
end

-- hunt you; below 30% hp run
-- away and heal; come back
-- at 70%
function rival_ai(e,d,a)
 -- faster + harder hitting
 -- every wave. bosses never run
 local s,p=.6+wave*.04,1+wave\3
 if not e.boss then
  if e.hp<e.mhp*.3 then e.run=true end
  if e.hp>=e.mhp*.7 then e.run=false end
 end
 if e.run and e.dz==0 then
  a+=.5 s+=.2 e.hp+=.04
 end
 if d>12 or e.run then
  e.x+=cos(a)*s e.y+=sin(a)*s
 end
 e.face=sgn(k.x-e.x)
 if not e.run and e.cd<=0 and e.dz==0 then
  if d<10+e.w*2 and k.z==0 then
   hurt(p) push(e,14) e.cd=45 sfx(10)
  elseif d<48+e.w*8 then
   -- fire! bosses breathe
   -- three ways at once
   for j=-1,1 do
    if e.boss or j==0 then
     local b=a+j*.07
     for i=0,3 do
      add(shots,{x=e.x+cos(b)*i*6,y=e.y+sin(b)*i*6,dx=cos(b)*2.5,dy=sin(b)*2.5,t=40,c=8,d=p})
     end
    end
   end
   e.cd=max(50,150-wave*12) sfx(1)
  end
 end
 -- it tramples small things
 for b in all(near_b(e.x,e.y,10)) do
  if b.k<2 and abs(b.x+8-e.x)<10 and abs(b.y+8-e.y)<10 then
   b.dead=true boom(b.x+8,b.y+8,4)
  end
 end
end

function kill(e)
 del(ens,e)
 boom(e.x,e.y,8*e.w)
 addscore(et[e.k][6],e.x,e.y)
 sfx(2)
 for i=1,e.k>4 and 6 or 1 do
  drop(e.x+rnd(16)-8,e.y+rnd(16)-8,e.w>1 and .6 or .08)
 end
 if e.k==6 then
  rival,rt=nil,600
  add(drops,{x=e.x,y=e.y,o=orb()})
  banner("rival beaten!")
  if e.boss then over(true) end
 end
end

-->8
-- effects + pickups

-- coins (half the time),
-- hearts, sometimes an orb
function drop(x,y,po)
 local r=rnd()
 if r<.3 then add(drops,{x=x,y=y,s=41})
 elseif r<.36 then add(drops,{x=x,y=y,s=40}) end
 if rnd()<po then add(drops,{x=x,y=y+3,o=orb()}) end
end

function pickups()
 for d in all(drops) do
  if abs(d.x-k.x)<8 and abs(d.y-k.y+4)<8 then
   if d.o then
    -- touch it, you take it
    -- (dodge the ones you
    -- don't want)
    del(drops,d) sfx(9)
    local i=has(d.o)
    if i then
     -- same skill: level up
     k.lv[i]=min(k.lv[i]+1,3)
     banner(sk[d.o].n.." level "..k.lv[i])
    else
     -- both full: it pushes out
     -- the weaker skill (the
     -- older one if they tie).
     -- slot 2 is always newest
     if k.sl[2] then
      local o=k.lv[1]<=k.lv[2] and 1 or 2
      banner(sk[d.o].n.." for "..sk[k.sl[o]].n)
      if o==1 then
       k.sl[1],k.lv[1],k.tm[1]=k.sl[2],k.lv[2],k.tm[2]
      end
     else
      banner(sk[d.o].n.."!")
     end
     k.sl[2],k.lv[2],k.tm[2]=d.o,1,0
    end
   else
    del(drops,d) sfx(3)
    if d.s==40 then k.hp=min(k.hp+2,k.mhp)
    else
     k.rage+=1
     if k.rage>=36 then rampage() end
    end
   end
  end
 end
end

-- thrown things, spikes, rocks
function upd_objs()
 for o in all(objs) do
  o.x+=o.dx o.y+=o.dy o.t-=1
  if o.t<0 or hit(o.x,o.y,2,0,true)>0 then
   del(objs,o)
   hit(o.x,o.y,o.r,o.d)
   if o.r>4 then
    ring(o.x,o.y,o.r+4,9) boom(o.x,o.y,8)
    shake=max(shake,3) sfx(2)
   end
  end
 end
end

function boom(x,y,n)
 for i=1,n do
  add(fx,{x=x,y=y,dx=rnd(3)-1.5,dy=rnd(3)-2,
   t=10+rnd(15),c=rnd(split"7,10,9,8,5")})
 end
end

function ring(x,y,r,c)
 add(fx,{x=x,y=y,dx=0,dy=0,t=10,r=r,c=c})
end

function upd_fx()
 for p in all(fx) do
  p.x+=p.dx p.y+=p.dy
  p.dx*=.9 p.dy*=.9
  p.t-=1
  if p.t<0 then del(fx,p) end
 end
 for l in all({pops,bolts,clouds}) do
  for p in all(l) do
   p.t-=1
   if p.t<0 then del(l,p) end
  end
 end
 for p in all(pops) do p.y-=.5 end
 for c in all(clouds) do
  if tm%10==0 then hit(c.x,c.y,c.r,1) end
 end
end

function addscore(n,x,y)
 n*=dm
 -- score is kept in tens
 -- (shown with a 0 on the end)
 -- so it can pass 32767
 score=min(score+n/10,32000)
 if n>=10 then add(pops,{x=x,y=y,t=30,s="+"..n}) end
end

-- s2: a big message with s2
-- underneath
function banner(s,s2) bn,bn2,bt=s,s2,s2 and 75 or 60 end

function clock()
 local s=secs
 return s\60 ..":"..(s%60<10 and "0" or "")..s%60
end

function pts(s) return s<1 and "0" or flr(s).."0" end

-->8
-- drawing + hud

function drw_play()
 cls(3)
 cx+=(mid(0,k.x-64,world-128)-cx)*.2
 cy+=(mid(0,k.y-72,world-128)-cy)*.2
 local sx,sy=0,0
 if shake>0 then
  sx,sy=rnd(shake*2)-shake,rnd(shake*2)-shake
  shake=shake>.5 and shake*.85 or 0
 end
 camera(cx+sx,cy+sy)

 for i=0,world-1,64 do
  rectfill(i,0,i+15,world,5)
  rectfill(0,i,world,i+15,5)
 end
 for i=0,world-1,64 do
  for j=cy\8*8,cy+128,8 do line(i+7,j,i+7,j+3,6) end
  for j=cx\8*8,cx+128,8 do line(j,i+7,j+3,i+7,6) end
 end
 -- dust clouds (see-through)
 fillp(0b0101101001011010.1)
 for c in all(clouds) do circfill(c.x,c.y,c.r,10) end
 fillp()

 for pass=0,1 do
  for j=cy\16-1,(cy+128)\16 do
   for i=max(cx\16-1,0),(cx+128)\16 do
    local b=gr[i+j*24]
    if b and (b.y+10<k.y)==(pass==0) then drw_bld(b) end
   end
  end
  if pass==0 then
   for d in all(drops) do
    local y=d.y-4+sin(t()+d.x/50)*1.5
    if d.o then
     circfill(d.x,y,3,sk[d.o].c)
     pset(d.x-1,y-1,7)
    else
     spr(d.s,d.x-4,y-4)
    end
   end
   drw_k()
  end
 end

 for e in all(ens) do drw_e(e) end
 for o in all(objs) do
  if o.s then spr(o.s,o.x-o.w*4,o.y-o.w*4-6,o.w,o.w)
  elseif o.r>4 then circfill(o.x,o.y-4,3,4) circ(o.x,o.y-4,3,5)
  else line(o.x,o.y,o.x-o.dx,o.y-o.dy,7) end
 end
 for s in all(shots) do
  if s.b then
   circ(s.x,s.y,12*(1-s.t/30),8)
   pset(s.x,s.y,t()*8%2<1 and 8 or 7)
  elseif s.c then
   circfill(s.x,s.y,2,s.c) pset(s.x,s.y,7)
  else
   spr(s.s,s.x-4,s.y-4,1,1,s.dx<0)
  end
 end

 if k.bl>0 then
  local mx,my=k.x+k.face*7,k.y-11
  for i=0,k.bl,3 do
   circfill(mx+k.fx*i,my+k.fy*i,1+rnd(k.rg>0 and 4 or 2),k.rg>0 and 8+(i/3+t()*20)%7 or pk.bc)
  end
  line(mx,my,mx+k.fx*k.bl,my+k.fy*k.bl,7)
 end
 for i=1,2 do
  local id=k.sl[i]
  if id and sk[id].d then sk[id].d(k.lv[i]) end
 end
 for b in all(bolts) do
  bolt(k.x+k.face*6,k.y-12,b.x,b.y)
 end
 for p in all(fx) do
  if p.r then circ(p.x,p.y,p.r*(1-p.t/10),p.c)
  else circfill(p.x,p.y,p.t/6,p.c) end
 end
 for p in all(pops) do
  oprint(p.s,p.x-#p.s*2,p.y,10)
 end

 camera()
 drw_hud()
 if st=="over" then drw_over() end
 if flash>0 then flash-=1 rectfill(0,0,127,127,7) end
end

function drw_bld(b)
 if b.dead then
  if b.k>0 then spr(12,b.x,b.y,2,2) end
  return
 end
 if b.fl>0 then b.fl-=1 white() end
 if b.k==0 then spr(37,b.x+4,b.y+4)
 else spr(bspr[b.k+1],b.x,b.y,2,2) end
 pal()
end

-- color swaps as "old,new,..."
function tint(s)
 local p=split(s)
 for i=1,#p,2 do pal(p[i],p[i+1]) end
end
stone="11,6,3,5,10,6,9,5,4,5,6,7"
gold="11,10,3,9,10,7,9,10,4,10,6,7"
purple="11,14,3,2,10,14,9,2,4,14,6,13"

function drw_k()
 ovalfill(k.x-6,k.y-2,k.x+6,k.y+2,1)
 if k.inv%4<2 then
  if k.tint then tint(stone) end
  local w=16
  if k.rg>0 then
   -- rage mode: big, glowing,
   -- every color of the rainbow
   w=24
   fillp(0b0101101001011010.1)
   circfill(k.x,k.y-12-k.z,15+sin(t()*2)*2,10)
   fillp()
   if k.rg>60 or t()*6%2<1 then rainbow() end
  elseif k.safe then tint(gold) end
  local f=pk.sp+(k.atk and 4 or flr(k.fr)%2*2)
  sspr(f%16*8,f\16*8,16,16,k.x-w/2,k.y-w-k.z,w,w,k.face<0)
  pal()
 end
 if k.held then
  spr(k.held,k.x-k.hw*4,k.y-18-k.hw*8-k.z,k.hw,k.hw)
 end
 if k.shell>0 then circ(k.x,k.y-8-k.z,11,12) end
 -- breath left, under the feet
 if k.en<60 then
  line(k.x-6,k.y+4,k.x-6+12*k.en/60,k.y+4,pk.bc)
 end
end

function drw_e(e)
 local w=e.w
 if e.fl>0 then white()
 elseif e.k==6 then tint(purple) end
 if e.k==6 then
  local f,h=roster[e.rk].sp+flr(t()*4)%2*2,w*4
  sspr(f%16*8,f\16*8,16,16,e.x-h,e.y-h,h*2,h*2,e.face<0)
  pal()
  line(e.x-h,e.y-h-3,e.x+h,e.y-h-3,2)
  line(e.x-h,e.y-h-3,e.x-h+2*h*e.hp/e.mhp,e.y-h-3,e.run and 12 or 8)
 else
  local s=et[e.k][1]
  if e.k==2 then s+=t()*10%2
  elseif e.k==5 then s+=flr(t()*4)%2*2 end
  local fl=e.x>k.x
  if e.k==4 then fl=e.dx<0 end
  spr(s,e.x-w*4,e.y-w*4,w,w,fl)
  pal()
 end
 if e.dz>0 then print("?",e.x-1,e.y-w*4-7,10) end
end

function bolt(x1,y1,x2,y2)
 local px,py=x1,y1
 for i=1,4 do
  local x,y=x1+(x2-x1)*i/4+rnd(6)-3,y1+(y2-y1)*i/4+rnd(6)-3
  if i==4 then x,y=x2,y2 end
  line(px,py,x,y,i%2==0 and 7 or 12)
  px,py=x,y
 end
end

function rainbow()
 local c=split"8,9,10,11,12,14,7"
 for i,p in pairs(split"11,3,10,9,4,6") do
  pal(p,c[(flr(t()*20)+i)%7+1])
 end
end

function white()
 for i=1,15 do pal(i,7) end
end

function oprint(s,x,y,c)
 for i=-1,1 do
  for j=-1,1 do print(s,x+i,y+j,0) end
 end
 print(s,x,y,c)
end

-- a marker on the edge of the
-- screen pointing at a spot
-- that's off screen
function edge(wx,wy,c,s,o)
 local rx,ry=wx-cx,wy-cy
 if rx<0 or rx>127 or ry<8 or ry>118 then
  local a=atan2(rx-64,ry-64)
  local x,y=64+cos(a)*56,64+sin(a)*48
  circfill(x,y,4,c)
  print(s,x-o,y-2,7)
 end
end

function drw_hud()
 rectfill(0,0,127,7,0)
 for i=1,k.mhp do
  rectfill(i*4-3,1,i*4-1,5,i<=k.hp+.99 and 8 or 2)
 end
 print(pts(score),56,1,7)
 if gm==1 then
  -- how wrecked the city is
  print(flr(nd/goal*100).."%",88,1,8)
  rectfill(0,8,127*min(nd/goal,1),9,8)
 else
  print("w"..wave.."/8",86,1,9)
 end
 print(clock(),108,1,6)
 if rival and rival.boss then
  print("boss",2,11,8)
  rect(20,11,125,15,2)
  rectfill(21,12,21+103*rival.hp/rival.mhp,14,8)
 end

 -- arrow to the rival when
 -- it's off the screen
 if rival then
  edge(rival.x,rival.y,rival.run and 12 or 8,rival.run and "+" or "!",1)
 end
 -- destroy mode: the nearest
 -- building, when none is near
 if tb and not tb.dead then
  edge(tb.x+8,tb.y+8,9,"\138",3)
 end

 rectfill(0,119,127,127,0)
 -- the 2 skill slots
 for i=1,2 do
  local x,id=(i-1)*40,k.sl[i]
  if id then
   local s=sk[id]
   circfill(x+3,123,2,s.c)
   print(s.n,x+7,121,s.c)
   -- level number (yellow = max)
   print(k.lv[i],x+8+#s.n*4,121,k.lv[i]==3 and 10 or 7)
  else
   print("- empty",x+7,121,5)
  end
 end
 -- rage meter
 print("rage",80,121,8)
 rect(97,121,115,125,5)
 rectfill(98,122,98+16*(k.rg>0 and k.rg/300 or k.rage/36),124,k.rg>0 and 8+t()*15%7 or 8)
 if k.rg>210 then
  oprint("\^w\^trage mode!",24,40+sin(t()*2)*3,8+t()*15%7)
 end
 -- z move ready?
 local rdy=k.dcd==0 and k.jcd==0
 print("z",121,121,rdy and 11 or 5)

 if k.held then print("throw: z or x",38,112,10) end
 if bt>0 then
  bt-=1
  if bn2 then
   oprint("\^w\^t"..bn,64-#bn*4,24,10)
   oprint(bn2,64-#bn2*2,40,7)
  else
   oprint(bn,64-#bn*2,30,10)
  end
 end
 if st=="intro" then
  local a,b,c=unpack(split(gm==1 and "destroy,the city!,faster = more points" or "survive,8 waves!,longer = more points"))
  oprint("\^w\^t"..a,64-#a*4,34,8)
  oprint("\^w\^t"..b,64-#b*4,50,8)
  oprint(c,64-#c*2,70,7)
 end
end

function drw_over()
 rectfill(20,40,107,84,0)
 rect(20,40,107,84,won and 11 or 8)
 local m=won and (gm==1 and "city destroyed!" or "boss beaten!") or "rampage over"
 oprint(m,64-#m*2,44,won and 11 or 8)
 print("score "..pts(score),36,54,7)
 print("best  "..pts(max(best,score)),36,62,6)
 if score>best then print("new!",88,62,10) end
 print(gm==1 and "time "..clock() or "wave "..wave.." of 8",36,70,9)
 if ot>45 then print("z: menu",50,77,6) end
end

function drw_title()
 cls(1)
 for i=0,15 do
  local h=4+(i*37)%10
  rectfill(i*8,127-h,i*8+7,127,0)
 end
 oprint("kaiju rage",44,3,8)
 for i=1,#roster do
  local r,x=roster[i],(i-1)*42+5
  if i==sel then rect(x-2,12,x+36,52,10) end
  local f=r.sp+(i==sel and flr(t()*4)%2*2 or 0)
  sspr(f%16*8,f\16*8,16,16,x+2,14,32,32)
  print(r.n,x+18-#r.n*2,46,i==sel and 10 or 6)
 end
 local r=roster[sel]
 print(r.d.."   z: "..r.z,4,57,7)
 print("x: breath  z+x: grab",4,64,6)
 print("skill orbs:",4,74,5)
 for j=1,5 do
  local s=sk[r.sk[j]]
  local x,y=4+(j-1)%3*42,82+(j-1)\3*8
  circfill(x+2,y+2,2,s.c)
  print(s.n,x+7,y,s.c)
 end
 print("best "..pts(dget(sel+gm*3)),4,102,6)
 oprint("\148\131 "..(gm==1 and "destroy the city" or "survive 8 waves"),4,111,10)
 print("\139\145 choose  z: go",56,102,6)
end
__gfx__
00000000000000000000000000000000000000000033330000000000000000000000000000000000000000080000000000000000000000000000000000000000
000000000033330000000000003333000000007003bbbb3000000000000000000055555555555500000000060000000000000000000000000000000000000000
0000007003bbbb300000007003bbbb300000073703bb0bb300000008800000000056666666666500000055555555000000000000000000000000000000000000
0000073703bb0bb30000073703bb0bb3000073b3bbbbbbb300000088880000000056c6c6c6c6c50000005dddddd5000000000000000000000000000000000000
000073b3bbbbbbb3000073b3bbbbbbb300073bbbbbbb38880000088888800000005666666666650000005adadad5000000000000000000000000000000000000
00073bbbbbbbbb3000073bbbbbbbbb300003bbbbbbb3707000008888888800000056c6c6c6c6c50000005dddddd5000000000000000000000000000000000000
0003bbbbbbbb33000003bbbbbbbb33000073bbbbbbbb38880008888888888000005666666666650000005dadada5000000000000000000000000000000000000
0073bbbbbaab30000073bbbbbaab3000003bbbbbaab3bb3000888888888888000056c6c6c6c6c50000005dddddd5000000000000000000000000000000000000
003bbbbbaaab3b30003bbbbbaaab3b3003bbbbbaaab3b30000ffffffffffff00005666666666650000005adadad5000000000000000000000000000000000000
03bbbbbbaaab330003bbbbbbaaab33003bbbbbbaaab3300000fccff44ffccf000056c6c6c6c6c50000005dddddd5000000000050000000000000000000000000
3bbb3bbbaab300003bbb3bbbaab300003bb3bbbaab30000000fccff44ffccf00005666666666650000005dadada5000000005665060000000000000000000000
33003bbbbbb3000033003bbbbbb3000033003bbbbbb3000000ffff4444ffff000056c6c6c6c6c50000005dddddd50000000566d6566500000000000000000000
00003bb33bb3000000003bb33bb3000000003bb33bb3000000ffff4444ffff00005666644666650000005adadad50000005665566d6650000000000000000000
00003bb303bb3000000003bb3bb3000000003bb303bb300000ffff4444ffff00005666644666650000005dd44dd500000566d6566656d5000000000000000000
0003bb30003bb300000003bb3bb300000003bb30003bb30005555555555555500555555555555550000555555555500005555555555555500000000000000000
00033300000333000000033303330000000333000003330000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000555555000055000000000000000000000333000000000000000000000000000000000000000000000000000000000000000000044442444bbbbbbbb
000dd0000000500000005000000000000000000003bbb30000000000000770000ee0880000aaaa0000000000000000000000000000000000444424443b3b3b3b
00d6655500088880000888800009a000000000003bbbbb3000cccc00007cc700e78888880aa7aaa0000000000000000000000000000000002222222244444444
0dddddd08008cc888008cc88009aa900906667003bb3bb300c7cc7c007cccc70e88888880a7aa9a0000000000000000000000000000000004244444444f44444
d666666d8888888c8888888c009aa900a96666e003bbb300cccccccc01cccc10088888800aaaa9a0000000000000000000000000000000004244444444444f44
5555555500088880000888800009a000906667000034300000000000001cc100008888000aa99aa0000000000000000000000000000000002222222244444444
50505055000500500005005000000000000000000004000000000000000110000008800000aaaa0000000000000000000000000000000000444424444f444444
05555550005555500055555000000000000000000044400000000000000000000000000000000000000000000000000000000000000000004444244444444444
00888800008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffff1f00ffff1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffffff00ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fccccf00fccccf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100100000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110001101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a0000000000a90000000000000000009a0000000000a9000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa9000000009aa900000000000000009aa9000000009aa900000000000000000000000000000000000000000000000000000000000000000000000000000000
9a8a90000009a8a900000005500000009a8a90000009a8a900000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaaa905509aaaa900990004400099009aaaa905509aaaa900000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa9449aaaa9009aa90044009aa9009aaaa9449aaaa9000006060606000000000606060600000000060606060000000000dddddd000000550000000000000
009aaa9449aaa9009a8aa994499aa8a9009aaa9449aaa9000006464646460000000646464646000000064646464600000000d666666d55550565000005555000
00099a9449a990009aaaaa9449aaaaa900099a9449a990000044444444440000004444444444000000444444444400000000d668866d00000566500056665000
000009f44f90000009aaa9f44f9aaa90000009f44f90000004445444544445500444544454444550044454445444455000dddddddddddd0005666666666666c0
0000097447900000009999744799990000000988889000006444444444444505644444444444450564444444444445080d666666666666d0005888888866666c
00009a9449a900000009aa9449aa900000009a9449a90000464444444444555546444444444455554644444444445888d66666666666666d0005666666666655
0009aa9449aa9000009aaa9449aaa9000009aa9449aa900004499999999445000449999999944500044999999994450055555555555555550000005666500000
009a8a9449a8a90009a8aa9449aa8a90009a8a9449a8a90000499999994400000049999999440000004999999944000050050050050050050000005555000000
009aaa9009aaa90009aaaa9009aaaa90009aaa9009aaa90000545000054500000005450054500000005450000545000055555555555555550000000000000000
00099900009990000099990000999900000999000099900000545000054500000005450054500000005450000545000005555555555555500000000000000000
00000000000000000000000000000000000000000000000000550000055000000005500055000000005500000550000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000066666cc60000000066666cc60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000000666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550566665055000055056666505500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05665666666566500566566666656650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05665669665666500566566966566650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05650666666056500565066666605650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05500666666005500550066666600550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555555000000000055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000660066000000000660000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000660066000000000660000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000550055000000000550000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660066600000006660000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660066600000006660000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000146730e6600a6500863500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000287402c740267302e7302a725000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001e6701867014660106500c6400a6300862500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000024350283502b3503034500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001e26118261122510c24500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001677214662137621264500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c62026630206301a62500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002e33328325000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003004037035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000024050280502b0503005034050370450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001a65016640146250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c150000000c130000000c150000000c130000000f150000000f130000000c150000000c1300000013150000001313000000111500000011130000000f150000000f130000000e150000000e13000000
001000000a663000003461500000226450000034615000000a663000003461500000226450000034615000000a663000003461500000226450000034615000000a66300000346150000022645000003461500000
00070000243403042528340344252b3403742530340304252b340374252834034425263403242529340354252d3402d42532340324252d3402d425293403542528340344252b340374252f3402f4253434034425
000700000c6630000028625000000c6630000028625000000c6630000028625000000c6630000028625000000c6630000028625000000c6630000028625000000c6630000028625000000c663000002862500000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 10114243
03 12134243
