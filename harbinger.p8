pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- init

x=0
y=0
items={}
hp=3
debug=true
heartanim=0
t=0
dx=1
dy=1
moving=false
vx=0
vy=0
maxv=2
movv=0.5
blinkmode=0


function _init()
	get_initial()
 load_items()
 music()
end

function get_initial()
	for x1 = 0, 127 do
	 for y1 = 0, 63 do
	 	local s = mget(x1,y1)
	 	if s == 1 then
	 		local rs = mget(x1+1,y1)
	 	 mset(x1,y1,rs)
	 		x = x1 * 8
	 		y = y1 * 8
	 		return
	 	end
	 end
	end
end

function load_items()
	for x1 = 0, 127 do
	 for y1 = 0, 63 do
	 	local s = mget(x1,y1)
	 	if fget(s, 2) then
	 		local rs = mget(x1+1,y1)
	 	 mset(x1,y1,rs)
	 	 add(items,{
	 	  x=x1*8,
	 	  y=y1*8,
	 	  t='heart',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	elseif fget(s, 3) then
	 		local rs = mget(x1+1,y1)
	 	 mset(x1,y1,rs)
	 	 add(items,{
	 	  x=x1*8,
	 	  y=y1*8,
	 	  dx=0,
	 	  dy=0,
	 	  t='enemy',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	elseif fget(s, 4) then
	 		local rs = mget(x1+1,y1)
	 	 mset(x1,y1,rs)
	 	 add(items,{
	 	  x=x1*8,
	 	  y=y1*8,
	 	  dx=0,
	 	  dy=0,
	 	  t='powerup',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	end
	 end
	end
end

-->8
-- draw

function _draw()
	local mx = mid(0, x-60, (128-16)*8)
	local my = mid(-8, y-60, (64 -16)*8)
	camera(mx,my)
	
	cls(3)
	map(0,0,0,0,128,64)
	
	for i=1,#items do
	 local s = items[i]
	 local sp = s.s1
	 if time() % 1 < .5 then sp=s.s2 end
	 spr(sp, s.x, s.y)
	end
	
	drawguy()
	
	camera()
	
	drawbanner()
end

function drawbanner()
	color(0)
	rectfill(0,0,127,7)
	for i = 1,hp do
	 local s = 10
	 local p = false
	 if heartanim>0 and i==hp then
	  pal(8, 2)
	  p = true
	  if heartanim % 2 == 0 then
	  	s = 9
	  end
	 end
		spr(s,(i-1)*7,0)
		if p then pal() end
	end
end

function drawguy()
 local fl=false
	local s = 1
	if (dx==-1) fl=true

	if moving then
		s=32
		if (dy==-1) s=48
		if (t%15<8) s+=1
	else
		if (dy==-1) s=17
	end	
	
	if blinkmode == 0
	or t % 3 < 1 then
 	spr(s,x,y,1,1,fl)
	end
end

-->8
-- update

function _update()
	t+=1
	if t == 30 then t = 0 end
	
	handlecontrols()
 moveenemies()
 docollide()

 if heartanim > 0 then
	 if t % 3 == 0 then
		 heartanim-=1
		end
 end
 
 if blinkmode > 0 then
  blinkmode -= 1
 end
end

function moveenemies()
	if t == 0 then
	 for i = 1, #items do
	  local e = items[i]
	  if e.t == 'enemy' then
	   local s = 1
	   if rnd(10) < 5 then s=-1 end
	   if rnd(10) < 5 then
		   e.dx=s
		   e.dy=0
	   else
		   e.dx=0
		   e.dy=s
	   end
	  end
	 end
	elseif t > 29-8 then
	 for i = 1, #items do
	  local e = items[i]
	  if e.t == 'enemy' then
	   e.x += e.dx
	   e.y += e.dy
	  end
	 end
 end
end

function handlecontrols()
 handlemoving()
end

function handlemoving()
	moving=false
	
	if btn(⬅️) then
		dx=-1
	elseif btn(➡️) then
		dx=1
	end
	
	if btn(⬆️) then
		dy=-1
	elseif btn(⬇️) then
		dy=1
	elseif btn(⬅️) or btn(➡️) then
		dy=1
	end
	
	if btn(⬅️) then
	 vx -= movv
	 if (vx<-maxv) vx=-maxv
	elseif btn(➡️) then
	 vx += movv
	 if (vx>maxv) vx=maxv
	else
	 if vx != 0 then
		 vx -= movv * sgn(vx)
	 end
	end

	if vx < 0 then
	 local canskirt =
	  not btn(⬆️) and not btn(⬇️)
	 for i = 1,ceil(-vx) do
		 local s1 = sprat(-1,0)
		 local s2 = sprat(-1,7)
		 trymove(s1,s2,-1,0,canskirt)
		end
	elseif vx > 0 then
	 local canskirt =
	  not btn(⬆️) and not btn(⬇️)
	 for i = 1,flr(vx) do
		 local s1 = sprat(8,0)
		 local s2 = sprat(8,7)
		 trymove(s1,s2,1,0,canskirt)
		end
	end
	
	if btn(⬆️) then
	 vy -= movv
	 if (vy<-maxv) vy=-maxv
	elseif btn(⬇️) then
	 vy += movv
	 if (vy>maxv) vy=maxv
	else
	 if vy != 0 then
		 vy -= movv * sgn(vy)
	 end
 end
 
 if vy < 0 then
	 local canskirt =
	  not btn(⬅️) and not btn(➡️)
  for i = 1, ceil(-vy) do
		 local s1 = sprat(0,-1)
	  local s2 = sprat(7,-1)
		 trymove(s1,s2,0,-1,canskirt)
		end
 elseif vy > 0 then
	 local canskirt =
	  not btn(⬅️) and not btn(➡️)
  for i = 1, flr(vy) do
		 local s1 = sprat(0,8)
	  local s2 = sprat(7,8)
		 trymove(s1,s2,0,1,canskirt)
		end
 end
end

function trymove(s1,s2,x1,y1,canskirt)
 local moved = false
 
 if slowarea() then
 	x1/=2
 	y1/=2
 end
 
 if air(s1) and air(s2) then
  moved = true
  x += x1
  y += y1
 elseif canskirt then
	 if air(s1) then
	 	moved=true
	 	if x1==0 then x-=1
	 	elseif y1==0 then y-=1
	 	end
	 elseif air(s2) then
	 	moved=true
	 	if x1==0 then x+=1
	 	elseif y1==0 then y+=1
	 	end
	 end
	end
 
 if moved then
  moving=true
 end
end

-->8
-- util

function getitem()
 for i = 1, #items do
  local item = items[i]

  local x1 = item.x-4
  local y1 = item.y-4
  local x2 = item.x+4
  local y2 = item.y+4

  if x>=x1 and x<=x2 and
     y>=y1 and y<=y2 then
   return item
  end
 end
end

function sprat(x1,y1)
 local tx = flr((x+x1) / 8)
 local ty = flr((y+y1) / 8)
 return mget(tx,ty)
end

function slowarea()
	return slow(sprat(0,0))
	    or slow(sprat(7,0))
	    or slow(sprat(0,7))
	    or slow(sprat(7,7))
end

function slow(s)
 return fget(s,1)
end

function air(s)
	return not fget(s,0)
end

function heart(s)
	return fget(s,2)
end

-->8
-- collide

function docollide()
	local f = getitem()
	if f then
		if f.t == 'heart' then
		 hp += 1
		 del(items, f)
		 sfx(0)
		 heartanim=7
		elseif f.t == 'powerup' then
		 blinkmode = 400
		 del(items, f)
		 sfx(0)
		elseif f.t == 'enemy' then
		 if blinkmode == 0 then
			 blinkmode=15
			 hp -= 1
			 sfx(4)
			 
			 local x1 = 0
			 if(x<f.x-2) x1=-1
			 if(x>f.x+2) x1=1
			 
			 local y1 = 0
			 if(y<f.y-2) y1=-1
			 if(y>f.y+2) y1=1
			 
			 vx = x1*4
			 vy = y1*4
			end
		end
	end
end

__gfx__
0000000000888800555555550000000076600000444444445555555500bab0005555555508800880000000000000000000000000000000005555555500000000
0000000008f1f18057777765065000007766000045555554544444450a9bab00577777658ee88e8800800800000000000000000000000000544f4f4500000000
007007000ffffff057666665055006500776600044444444544444450abb9b90576666658e88888808ee8e80000aaa0000000000000000005f4444f500000000
0007700000f88f0057666665000005500077661044555555544444450bbb9ab0576666658888888808e888800000baa00000000000000000544ff44500000000
0007700000cccc005766666500000000000771104444444454455445009bbb005766666588888888088888800090b00000000000000000005555555500000000
007007000f0cc0f0576666650060065000001140555555445444444500044000576666650888888000888800000b000000000000000000000005500000000000
0000000000044000566666650550055000000444444444445444444500044000566666650088880000088000000b000000000000000000000005500000000000
00000000005005005555555500000000000000445555555554444445004444005555555500088000000000000000b00000000000000000000005500000000000
00000000008888009900000017711771000000000000000000000000000bbbb0000000000000000000000ccccc000000cc111c11cccccccccc111111111111cc
000000000888888099ddd000165117710000000000000000000000000bb333bbbbbbb00000000000000cccccccccc000c1111c11cc111cccc11111111111111c
000000000f8888f055e8ed00155116510000000008188180088888800b333bbbbb3bbb000088800000c1111111cccc00c1111c11111111111111111111111111
0000000000ffff00558e8d001771155100cccc0008788780081881800b3bbb33bbbb3b00088b00000c1111111111ccc0c11c1c11111111111111111111111111
0000000000cccc0055ddd000177117710cc77cc0088cc880087887800bbb333bb333bb00000b0ee0cc111cc111111cccc11c1c11c1cccccc1111111111111111
000000000f0cc0f055000000176116510c6666c008888880088cc8800bb33bb33bbb3b000000b0e0cc11cccccc1111cccc1c1111111111111111111111111111
000000000004400055000000155115510c6776c008dddd8008dddd800bb3bb33bb33bb000000b000c111cc111ccc111cc1111c111ccccc111111111111111111
000000000050050055000000111111110c6666c008888880088888800bb3b33bb3bbb000000b0000c111cc11111cc11ccc111111111111111111111111111111
0088880000000000000000000000000000000000000000000000000000bbb3bb3bbb000011111111c1111c111111c1cc11111111111111cc1111111111111111
08f1f180008888000000000000000000000000000000000000000000000bbbbbbbbb000011111111cc111c11111cc1cccc1ccc111111c1cc1111111111111111
0ffffff008f1f1800000000000000000000000000088800000000000000000445000000011111111cc111cc111cc11cc1111111111c1c11c1111111111111111
00f88f000ffffff0000000000000000000000000088b0000008880000000004450000000111111110c1111ccccc11ccccccc1cc111c1c11c1111111111111111
0fcccc0000f88f00000000000000000000000000000b0ee0088b00000000004450000000111111110cc1111111111cc01111111111c1111c1111111111111111
000ccf0000ccccf00000000000000000000000000000b0e0000b0ee0000004445000000011111111000c11111111cc001111111111c1c11c1111111111111111
0004400000f440000000000000000000000000000000b0000000b0e0000044444500000011111111000cccccccccc00011cccc111111c1ccc11111111111111c
0050500000050500000000000000000000000000000b0000000b000000004444445000001111111100000ccccc000000cccccccc1111c1cccc111111111111cc
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f8888f0088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ffff000f8888f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fcccc0000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ccf0000ccccf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004400000f440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70707000000000000000000000000000000000000070707070707070000000000000000000007070707070707070707070707070707070707070700000700000
00000000000000000000000070700000000000000070707070707000707000000000000000007070000070707070700070707070000000000000000000007070
70707070707070707070707070707070707070707070707070000070707070707070707070707070700070007070007070007070000000707070707070707070
70707070707070707070707070707070707070707070000000007070707070707070707070707070707070707070707070700070707070707070707070707070
__gff__
0000010200000001000400000000010000000001000900010100020202020101000000000010100101010202020201010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0707070707070707070707070707070707070707070707070707070707070707070700070707070707070000000007070707070707070000000000000707070700070707070707070707070707070707070707000000000000000007070707070707070707070707070707070707070707070707070707070707070000070707
0707070707070707070707070003030000000000000000070000000000000007070707070707000000000707070700000000000007070707070707070000000007000000000000000000000000000000000000070707070707070700000000000000000007070707070000000000000000000000000000000000000707070007
0703030303030303030303030303001500000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070707
0703030903030303030303020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
07030303030303030303020203000001000000000000190b190b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
070303030303030303000203030000000202020202000b191925000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070700
07020202020203030302030300000e00060509050200190b190b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
0700001718000000000200000000000002050505020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
07000027280000000007000300000000020802020200001200000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
0700001718000000000700030303000000000000000000000000000000000000001900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
0700002728171800070700000003030000000015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
0700000000272800000000000000000003000000000000000019000000000000000017180000000000001a1d1d1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
07000000000000000000000000000000000300000000000000000000000000000000272800000000001a1e29291f1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
070000000000250000000000000000000000000300000000000000000000000000000000000000001a1e292929291f1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
070000000000000000001313131313130000000000000003000000000000000000000000000000001c2929292929292d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
070000190000000000001314000000131313131300000000000300000000000000000000000000001c2929292929292d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
070000000000000000001300000000130000001313131313000003000003000000000000000000002a2e292929292f2b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
07070000000000000000131313130000000000000000001313000000000303030000000000000000001c292929292d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
07070000000000002500000000131313130000130000001413000000000000000303030303030300001c292929292d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
07070000000000000000000000001300131300130000000013000000000000000000000000000000002a2e29292f2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
0707000000000000000000000000130000000000130000001300000000000000000000000000030000002a2c2c2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000000000000000131313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000130000000000000013000000000000000000000000000000000003030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000131300000000001313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000001313000000001300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000000000131313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707
0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707
0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707
0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
0707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
0707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
__sfx__
000200000a0500f05015050190501c0501e0501c05018050160501605017050170501a0501e050210502405026050270502705023050210501f0501f0501f05022050260502a0502c0502f05035050380503e050
0010000018010180100000000000210102101000000000001c0101c01000000000002401024010000000000022010230100000000000270102701000000000002501026010250000000029010290102900000000
0010000000010000100001000010000000000000000000000501005010050100501000000000000000004000040100401004010040100000000000150001400007010070100701007010070000b0000b00000000
001000000151001510006000560000000000000151001510186001c60001510015102b6002e600316003660000510005103c60000000000000000001510015100000000000005100051000000000000000000000
00010000291502c1502e1502e1502e1502c15029150231502115021150221502415025150261502515024150201501b150171501315011150111501115013150141501515014150131500f1500b1500915004150
__music__
02 01020344

