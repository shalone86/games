-- stub: grab throw zmove breath rival_ai fire skill pickups crush
-- screenshots: the title with 4 joined, play in each mode, the end.
__pl={[0]={},{},{},{}}
function btn(b,n)
 if not b then
  local m=0
  for p=0,3 do for i=0,5 do if __pl[p][i] then m+=1<<(i+p*8) end end end
  return m
 end
 return __pl[n or 0][b] or false
end
__pv={[0]={},{},{},{}}
function btnp(b,n) n=n or 0 return __pl[n][b] and not __pv[n][b] or false end
cpu=0
function fr(n)
 for i=1,n do
  _update() _draw() flip() cpu=max(cpu,stat(1))
  for p=0,3 do __pv[p]={} for b,v in pairs(__pl[p]) do __pv[p][b]=v end end
 end
end
function pp(n,...) __pl[n]={} for b in all({...}) do __pl[n][b]=true end end
-- p2-p4 join, p3 picks the next kaiju, mode 2
fr(2) pp(1,5) pp(2,5) pp(3,5) fr(1) pp(1) pp(2) pp(3) fr(1)
pp(2,1) fr(1) pp(2) pp(0,3) fr(1) pp(0) fr(10)
printh("joined "..tostr(js[1]).." "..tostr(js[2]).." "..tostr(js[3]).." md "..md)
shot("rage4_title")
pp(0,5) fr(1) pp(0) fr(40) shot("rage4_intro")
for p=0,3 do pp(p,p%2,p<2 and 2 or 3) end
fr(200) shot("rage4_versus")
wave=7 for i=1,40 do spawn(pick()) end
for p in all(ks) do p.sl[2]=p.pk.sk[2] p.lv={2,3} end
ks[2].rg=200 fr(90) shot("rage4_late")
ks[3].hp=-1 use(ks[3]) down() fr(20) shot("rage4_down")
cpu=0 fr(120) printh("cpu late wave, 4 kaiju: "..cpu)
secs=179 tm=29 fr(50) shot("rage4_over")
