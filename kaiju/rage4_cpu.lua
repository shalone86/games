-- stub: drw_title upd_title drw_over over grab throw
-- how busy one frame gets: 4 kaiju in the final wave, all
-- breathing, both skills at level 3, a full army. 1 = all of
-- PICO-8's time for a frame (30 fps).
__pl={[0]={},{},{},{}}
function btn(b,n)
 if not b then return 0 end
 return __pl[n or 0][b] or false
end
function btnp() return false end
js={[0]=1,2,3,4} md=2 start() st="play"
for p in all(ks) do p.sl[2]=p.pk.sk[2] p.lv={3,3} p.hp=999 p.mhp=999 end
for i=0,3 do __pl[i]={[5]=true} end
wave=7
worst,sum=0,0
for f=1,300 do
 if #ens<48 then use(ks[1]) spawn(pick()) end
 for p in all(ks) do p.en=60 p.inv=99 end
 local a=stat(1)
 _update() _draw()
 local d=stat(1)-a
 worst=max(worst,d) sum+=d
end
printh("enemies "..#ens.." worst frame "..worst.." average "..sum/300)
