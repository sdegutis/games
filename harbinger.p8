pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- init

--[[

ideas for later:

* make enemies randomly spawn.
  should they spawn anywhere?
  or only where placed on map?
  maybe they should only spawn
  when you reveal them on the
  map? unclear.
  
* energy bar on banner right.
  apples/etc increase energy.
  what uses energy up? maybe
  running? throwing swords?
  we'd also need to have apples
  respawn so you don't run out
  of energy for basic needs.

* turn the blue treasure chest
  into a cape since sarah thinks
  it looks like one when the guy
  walks over it.
  what can it do? maybe fly over
  solid objects for 400 ticks?

--]]

hero = {
	hp=3,
	x=0,
	y=0,
	mx=0,
	my=0,
	dx=0,
	dy=1,
	vx=0,
	vy=0,
	maxv=1,
	maxv1=1,
	maxv2=2,
	movv=0.5,
	boat=false,
	moving=false,
	blinkmode=0,
	invincible=false,
}

fairie=nil

items={}
debug=true
heartanim=0
t=0
shot=nil

message = nil
signs = {
 {14,7,'hai how are you doing sarah girl?'},
 {11,11,'hi'},
 {23,10,'this is a super long message with lots of really long words and things'},
 {21,22,'😐 < wanted: link the wanted soldier!'},
}

function _init()
	get_initial()
 load_items()
 music()
end

function get_initial()
	for x = 0, 127 do
	 for y = 0, 63 do
	 	local s = mget(x,y)
	 	if s == 1 then
	 		local rs = mget(x+1,y)
	 	 mset(x,y,rs)
	 		hero.x = x * 8
	 		hero.y = y * 8
	 		return
	 	end
	 end
	end
end

function load_items()
	for x = 0, 127 do
	 for y = 0, 63 do
	 	local s = mget(x,y)
	 	if fget(s, 2) then
	 		local rs = mget(x+1,y)
	 	 mset(x,y,rs)
	 	 add(items,{
	 	  x=x*8,
	 	  y=y*8,
	 	  t='heart',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	elseif fget(s, 3) then
	 		local rs = mget(x+1,y)
	 	 mset(x,y,rs)
	 	 add(items,{
	 	  x=x*8,
	 	  y=y*8,
					mx=0,
					my=0,
					dx=0,
					dy=1,
					vx=0,
					vy=0,
					maxv=3,
					movv=1,
	 	  t='enemy',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	elseif fget(s, 4) then
	 		local rs = mget(x+1,y)
	 	 mset(x,y,rs)
	 	 add(items,{
	 	  x=x*8,
	 	  y=y*8,
	 	  t='powerup',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	elseif fget(s, 5) then
	 		local rs = mget(x+1,y)
	 	 mset(x,y,rs)
	 	 add(items,{
	 	  x=x*8,
	 	  y=y*8,
	 	  t='boat',
	 	  s1=s,
	 	  s2=s+1,
	 	 })
	 	elseif fget(s, 7) then
	 		local rs = mget(x+1,y)
	 	 mset(x,y,rs)
	 	 add(items,{
	 	  x=x*8,
	 	  y=y*8,
	 	  t='portal',
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
	local mx = mid(0, hero.x-60, (128-16)*8)
	local my = mid(-8, hero.y-60, (64 -16)*8)
	camera(mx,my)
	
	cls(3)
	map(0,0,0,0,128,64)
	
	for i=1,#items do
	 local s = items[i]
	 local sp = s.s1
	 if time() % 1 < .5 then sp=s.s2 end
	 
	 for i=1,15 do pal(i,1) end
	 spr(sp, s.x+1, s.y+1)
	 pal()
	 spr(sp, s.x, s.y)
	end
	
	if shot then
	 spr(4,shot.x,shot.y)
	end
	
	drawguy()
	drawfairie()
	
	camera()
	
	drawbanner()
	drawmessage()
end

function drawfairie()
	if fairie then
	 local x1 = fairie.x+sin(fairie.t/30)*fairie.t/2
	 local y1 = fairie.y+cos(fairie.t/20)*fairie.t/2
		
	 local x2 = fairie.x+sin(fairie.t/(30*1.05))*fairie.t/2
	 local y2 = fairie.y+cos(fairie.t/(20*1.05))*fairie.t/2
		
		for i=1,15 do pal(i,1) end
		spr(fairie.s+2, x2+1, y2+1)
		spr(fairie.s, x1+1, y1+1)
		pal()
		spr(fairie.s+2, x2, y2)
		spr(fairie.s, x1, y1)
	end
end

function drawbanner()
	color(0)
	rectfill(0,0,127,7)
	for i = 1,hero.hp do
	 local s = 10
	 local p = false
	 if heartanim>0 and i==hero.hp then
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
	_drawguy(true)
	_drawguy(false)
	
	if hero.boat then
		for i=1,15 do pal(i,1) end
		drawboat(hero.x, hero.y+1)
		pal()
		drawboat(hero.x, hero.y)
	end
end

function drawboat(x,y)
 local s = 57
 if t < 15 then s=58 end
	spr(s,x,y+1)
end

function _drawguy(shadow)
 local fl=false
	local s = 1
	if (hero.dx==-1) fl=true

	if hero.moving then
		s=32
		if (hero.dy==-1) s=48
		if (t%15<8) s+=1
	else
		if (hero.dy==-1) s=17
	end
	
	if shadow then
		for i=1,15 do pal(i,1) end
		local j = 1
		spr(s,hero.x+j,hero.y+j,1,1,fl)
		pal()
	else
		if hero.invincible then
		 if t % 15 < 5 then
	   for i=1,15 do
			 	pal(i,(i+3)%3+10)
	   end
			end
			spr(s,hero.x,hero.y,1,1,fl)
			pal()
		elseif hero.blinkmode > 0 then
		 if t % 3 < 1 then
				spr(s,hero.x,hero.y,1,1,fl)
			end
		else
			spr(s,hero.x,hero.y,1,1,fl)
		end
	end
end

function drawmessage()
	if (not message) return
	
	local x1=20
	local y1=20
	local x2=108
	
	local w = x2-x1-4
	local h = 8
	local lines = {""}
	local words = split(message," ")
	
	for i=1,#words do
	 local word = words[i]
	 local newline = lines[#lines] .. " " .. word
	 if #newline * 4 <= w then
	  lines[#lines] = newline
	 else
	 	add(lines, word)
	 end
	end
	lines[1] = sub(lines[1], 2)
	
	local y2=y1+(h*#lines)+2
	
	rectfill(x1,y1,x2,y2,1)
	rect(x1,y1,x2,y2,6)
	
	for i=1,#lines do
	 local msg = lines[i]
		local y = h*(i-1)
		print(msg,x1+3,y1+3+y,7)
	end
	
end

-->8
-- update

function _update()
	t+=1
	if t == 30 then t = 0 end
	
	handlecontrols()
 handlemoving(hero)
 moveenemies()
 docollide()
 
 if shot then
 	handlemoving(shot)
  shot.t -= 1
  if shot.t == 0 then
  	shot = nil
  end
 end

 if heartanim > 0 then
	 if t % 3 == 0 then
		 heartanim-=1
		end
 end
 
 if hero.blinkmode > 0 then
  hero.blinkmode -= 1
  if hero.blinkmode==0 and hero.invincible then
  	hero.invincible=false
  	music()
  end
 end
end

function moveenemies()
	for i=1,#items do
		local e = items[i]
		if e.t == 'enemy' then
			if t == 0 then
				-- pick direction
				e.mx=0
				e.my=0
				if rnd() < .5 then
					e.mx=-1
					if (rnd()<0.5) e.mx=1
				else
					e.my=-1
					if (rnd()<0.5) e.my=1
				end
			elseif t == 5 then
				e.mx=0
				e.my=0
			end
			handlemoving(e)
		end
	end
end

function handlecontrols()
 hero.maxv=hero.maxv1
 if btn(❎) then
  hero.maxv=hero.maxv2
 end
 
 if btnp(🅾️) then
 	shot = {
 	 x=hero.x,
 	 y=hero.y,
			mx=hero.dx,
			my=hero.dy,
 	 dx=hero.dx,
 	 dy=hero.dy,
			vx=0,
			vy=0,
			maxv=2,
			movv=1,
 	 t=30,
 	}
 end
 
 if     btn(⬅️) then	hero.mx=-1
	elseif btn(➡️) then	hero.mx=1
	else                hero.mx=0	end
	if     btn(⬆️) then	hero.my=-1
	elseif btn(⬇️) then	hero.my=1
	else                hero.my=0	end
end

-->8
-- util

function getitem(e)
 for i = 1, #items do
  local item = items[i]

  local x1 = item.x-4
  local y1 = item.y-4
  local x2 = item.x+4
  local y2 = item.y+4

  if e.x>=x1 and e.x<=x2 and
     e.y>=y1 and e.y<=y2 then
   return item, i
  end
 end
end

function sprat(x,y,e)
 local tx = flr((e.x+x) / 8)
 local ty = flr((e.y+y) / 8)
 return mget(tx,ty), tx, ty
end

function slowarea(e)
	return slow(sprat(0,0,e))
	    or slow(sprat(7,0,e))
	    or slow(sprat(0,7,e))
	    or slow(sprat(7,7,e))
end

function notwater()
	return not water(sprat(0,0,hero))
	   and not water(sprat(7,0,hero))
	   and not water(sprat(0,7,hero))
	   and not water(sprat(7,7,hero))
end

function onsign()
	return issign(sprat(3,3,hero))
	    or issign(sprat(4,3,hero))
	    or issign(sprat(3,4,hero))
	    or issign(sprat(4,4,hero))
end

function issign(s, x, y)
	if s == 14 then
		 return {x, y}
 end
end

function slow(s)
 return fget(s,1)
end

function water(s)
	return (s>=26 and s<=31)
	    or (s>=41 and s<=47)
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
	local f, fi = getitem(hero)
	if f then
		if f.t == 'heart' then
			if not hero.invincible then
			 hero.hp += 1
			 del(items, f)
			 sfx(0)
			 heartanim=7
			end
		elseif f.t == 'powerup' then
			if not hero.invincible then
			 music(1)
			 hero.blinkmode = 400
			 hero.invincible=true
			 del(items, f)
			 sfx(0)
			end
		elseif f.t == 'boat' then
			if hero.blinkmode==0 then
			 hero.boat = true
			 del(items, f)
			end
		elseif f.t == 'portal' then
			if hero.blinkmode==0 then
				local i = fi
				local nxt
				repeat
					i+=1
					if (i > #items) i = 1
					nxt=items[i]
				until nxt.t=='portal'
				
				sfx(5)
				
				--[[
				for i=0,3 do
					for j=1,4 do
						pal(i*4+j,0)
						_draw()
						flip()
					end
				end
				pal()
				--]]
				
				for i=1,90 do
					circ(64,64,90-i,1)
					if (i%5==0)	flip()
				end
				
				hero.x=nxt.x+8
				hero.y=nxt.y
				
				for i=1,90 do
					_draw()
					for j=i,90 do
						circ(64,64,j,1)
					end
					if (i%5==0)	flip()
				end
				
			 hero.blinkmode=30
			end
		elseif f.t == 'enemy' then
		 if hero.blinkmode == 0 then
			 hero.hp -= 1
			 
			 if hero.hp == 0 then
			 
			 	music(-1)
			 	
			 	sfx(10)
			 	for i=1,2 do
			 		for x=-1,1 do
			 			for y=-1,0 do
			 				hero.dx=x
			 				hero.dy=y
			 				_draw()
								flip()
								flip()
								flip()
			 			end
			 		end
			 	end
			 	
			 	for i=1,15 do flip() end
			 	
			 	fairie={
			 	 x=hero.x,
			 	 y=hero.y,
			 	 t=0,
			 	 s=53,
			 	}
			 	
			 	for i=1,7 do
			 		
			 		sfx(9)
			 		hero.hp+=1
			 		
			 		for j=1,10 do
				 		heartanim=0
				 		if (j<=5) heartanim=2
				 		_draw()
			 		 fairie.t += 1
			 		 fairie.s = 53
			 		 if (j<5) fairie.s=54
			 		 flip()
			 		end
			 		
			 	end
			 	
			 	fairie=nil
		 		heartanim=0
			 	hero.blinkmode=30
			 	music()
			 
			 else
				 hero.blinkmode=15
				 sfx(4)
				 
				 local x = 0
				 if(hero.x<f.x-2) x=-1
				 if(hero.x>f.x+2) x=1
				 
				 local y = 0
				 if(hero.y<f.y-2) y=-1
				 if(hero.y>f.y+2) y=1
				 
				 hero.vx = x*4
				 hero.vy = y*4
			 end
			end
		end
	end
end

-->8
-- moving

function handlemoving(e)
	e.moving=false
	
	if e.mx != 0 or
	   e.my != 0 then
	 e.dx = e.mx
	 e.dy = e.my
	end
	
	if e.mx < 0 then
	 e.vx -= e.movv
	 if (e.vx<-e.maxv) e.vx=-e.maxv
	elseif e.mx > 0 then
	 e.vx += e.movv
	 if (e.vx>e.maxv) e.vx=e.maxv
	else
	 if e.vx != 0 then
		 e.vx -= e.movv * sgn(e.vx)
	 end
	end

	if e.vx < 0 then
	 local canskirt = e.my==0
	 for i = 1,ceil(-e.vx) do
		 local s1 = sprat(-1,0,e)
		 local s2 = sprat(-1,7,e)
		 trymove(e,s1,s2,-1,0,canskirt)
		end
	elseif e.vx > 0 then
	 local canskirt = e.my==0
	 for i = 1,flr(e.vx) do
		 local s1 = sprat(8,0,e)
		 local s2 = sprat(8,7,e)
		 trymove(e,s1,s2,1,0,canskirt)
		end
	end
	
	if e.my < 0 then
	 e.vy -= e.movv
	 if (e.vy<-e.maxv) e.vy=-e.maxv
	elseif e.my > 0 then
	 e.vy += e.movv
	 if (e.vy>e.maxv) e.vy=e.maxv
	else
	 if e.vy != 0 then
		 e.vy -= e.movv * sgn(e.vy)
	 end
 end
 
 if e.vy < 0 then
	 local canskirt = e.mx==0
  for i = 1, ceil(-e.vy) do
		 local s1 = sprat(0,-1,e)
	  local s2 = sprat(7,-1,e)
		 trymove(e,s1,s2,0,-1,canskirt)
		end
 elseif e.vy > 0 then
	 local canskirt = e.mx==0
  for i = 1, flr(e.vy) do
		 local s1 = sprat(0,8,e)
	  local s2 = sprat(7,8,e)
		 trymove(e,s1,s2,0,1,canskirt)
		end
 end
end

function trymove(e,s1,s2,x,y,canskirt)
 local moved = false
 
 if slowarea(e) then
 	x/=2
 	y/=2
 end
 
 if e==hero then
	 if hero.boat and notwater() then
			hero.boat=false
		 add(items,{
	   x=hero.x,
	   y=hero.y+1,
	   t='boat',
	   s1=57,
	   s2=58,
	  })
	  hero.blinkmode=15
	 end
	 
	 local gotsign = onsign()
	 if gotsign then
	 	local sx, sy =
	 		gotsign[1], gotsign[2]
	 	
	 	for i = 1,#signs do
	 		local x1,y1,msg = unpack(signs[i])
	 		if sx==x1 and sy==y1 then
	 			message = msg
		 		break
	 		end
	 	end
	 else
	 	message = nil
	 end
 end
 
 if e.boat or air(s1) and air(s2) then
  moved = true
  e.x += x
  e.y += y
 elseif canskirt then
	 if air(s1) then
	 	moved=true
	 	if     x==0 then e.x-=1
	 	elseif y==0 then e.y-=1	end
	 elseif air(s2) then
	 	moved=true
	 	if     x==0 then e.x+=1
	 	elseif y==0 then e.y+=1	end
	 end
	end
 
 if moved then
  e.moving=true
 end
end

__gfx__
0000000000888800666666610000000076600000222222225555555500bab00000000000088008800000000000000000000bb0000000b0005555555500000000
0000000008f1f18067777761065000007766000022222222544444450a9bab00000000008ee88e880080080000000000000400000000bb00544f4f4500000000
007007000ffffff067666661055006500776600022222222544444450abb9b90000000008e88888808ee8e80000aaa0000888000000040005f4444f500000000
0007700000f88f0067666661000005500077661022222222544444450bbb9ab0000000008888888808e888800000baa008ee880000088800544ff44500000000
0007700000cccc006766666100000000000771102222222254455445009bbb000000000088888888088888800090b11008e88800008ee8805555555500000000
0070070000fccf00676666610060065000001140222222225444444500045000000000000888888000888800000b100008888800008e88800005500000000000
0000000000044000666666610550055000000444222222225444444500045000000000000088880000088000000b100000888000008888800005500000000000
00000000000505001111111100000000000000442222222254444445004445000000000000088000000000000000b10000000000000888000005500000000000
00000000008888009900000017711771000000000000000000000000000ba9a0000000000000000000000ccccc000000cc111c11cccccccccc111111111111cc
000000000888888099ddd0001651177100000000000000000000000009ab9b9bbabbb00000000000000cccccccccc000c1111c11cc111cccc11111111111111c
000000000f8888f055e8ed00155116510000000008188180088888800bbabab8a9abab000088800000c1111111cccc00c1111c11111111111111111111111111
0000000000ffff00558e8d001771155100cccc0008788780081881800abaa9a9ba99bb00088b10000c1111111111ccc0c11c1c11111111111111111111111111
0000000000cccc0055ddd000177117710cc77cc0088cc8800878878009b99b9b99baa900001b0ee0cc111cc111111cccc11c1c11c1cccccc1111111111111111
0000000000fccf0055000000176116510c6666c008888880088cc8800bab8ba9aa9b9b000000b1e0cc11cccccc1111cccc1c1111111111111111111111111111
000000000004400055000000155115510c6776c008dddd8008dddd800a99baba9b8abb000000b010c111cc111ccc111cc1111c111ccccc111111111111111111
000000000005050055000000111111110c6666c008888880088888800baba9b9b9abb000000b1000c111cc11111cc11ccc111111111111111111111111111111
0088880000000000000000000000700000060000000000000000000000b99bababab000011111111c1111c111111c1cc11111111111111cc1111111111111111
08f1f180008888000000000000060000000060000000000000000000000bbb9abbbb000011111111cc111c11111cc1cccc1ccc111111c1cc1111111111111111
0ffffff008f1f1800000000000006000000555000088800000000000000000445000000011111111cc111cc111cc11cc1111111111c1c11c1111111111111111
00f88f000ffffff00000000000055500005ddd50088b0000008880000000004450000000111111110c1111ccccc11ccccccc1cc111c1c11c1111111111111111
0fcccc0000f88f0000000000005ddd5005ddddd5000b0ee0088b00000000004450000000111111110cc1111111111cc01111111111c1111c1111111111111111
000ccf0000ccccf00000000005ddddd505d1dd150000b0e0000b0ee0000004445000000011111111000c11111111cc001111111111c1c11c1111111111111111
0054400000f445000000000005d1dd1505dcccc50000b0000000b0e0000044444500000011111111000cccccccccc00011cccc111111c1ccc11111111111111c
00005000000500000000000005dcccc500000000000b0000000b000000004444445000001111111100000ccccc000000cccccccc1111c1cccc111111111111cc
00888800000000000000000000222200002222000044444000444440000a00000000900000000000000000000000000000000000000000000000000000000000
088888800088880000000000021111200211112000fcfcf000fcfcf0a0000a000000000900000000000000000000000000000000000000000000000000000000
0f8888f0088888800000000021ccc11221cc1112664fff46004fff400000000a9090900000000000000999000000000000000000000000000000000000000000
00ffff000f8888f00000000021c1111221c11112664f8f46064f8f40000a00000000000000000000000999000000000000000000000000000000000000000000
0fcccc0000ffff00000000002111111221c1111206fcccf666fcccf6000000a00900000900000000000090000000000000000000000000000000000000000000
000ccf0000ccccf0000000002111111221111112000fcf00666fcf660a0000000009000044449444444494440000000000000000000000000000000000000000
0054400000f44500000000000211112002111120000ccc00000ccc000000a00a9000090004449440044494400000000000000000000000000000000000000000
000050000005000000000000002222000022220000ccccc000ccccc0a00000000009000000499900004444000000000000000000000000000000000000000000
00000000000000001111111166666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001ee4e4e1644444444444444655555555dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000014eeee4164555555555555465d6d6d65d8d8d8dd000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001ee44ee164444444444444465ddd6d65d888d8dd000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111164555555555555465d6d6d65d8d8d8dd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000011000644444444444444655555555dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000011000645555555555554600055000000dd000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000011000644444444444444600055000000dd000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000064444444444444460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000644446000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000644446000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000644446000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000b644446b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000b6b4bb6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
70700000000000000000007000000000707070707070707070707070707070707070000000000000007070700000000000000000000070707070707070707070
70707070707070700070700070007070707070000000000070707070000000707000000070707000000000000000000070707070000000000000000000000070
70000000000000000000000070707070700000000000000000000000000000700000000000000000000000707070700000007070707000000000000000000000
00700000000000000000000000000000000000707070707070000000000000007000000000007070707070707070707070000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000070700000000000000000000000000000707070700000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000007070000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
70700000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000007070000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
70707000000000000000000000000000000000000070707070707070000070700000000000007070707070707070707070707070707070707070700000700070
00000000000000000000000070700000000000000070707070707000707000000000000000007070000070707070700070707070000000000000000000007070
70707070707070707070707070707070707070707070707070000070707070707070707070707070700070007070007070007070000000707070707070707070
70707070707070707070707070707070707070707070000000007070707070707070707070707070707070707070707070700070707070707070707070707070
__gff__
0000010200000001000400000400000000000001000800010100020202020303000000080010000101030202020203030000008000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0707070707070707070707070707070707070707070707070707070707070707070700070707070707070000000007070707070707070000000000000707070700070707070707070707070707070707070707000000000000000007070707070707070707070707070707070707070707070707070707070707070000070707
0707070707070707070707070017180000000000001718070000000000000007070707070707000000000707070700000000000007070707070707070000000007000000000000000000000000000000000000070707070707070700000007070000000007070707070000000000000000000000000000000000000707070007
0703030303030303030303030327281500000009002728000000000000000000070700000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070707
07030309030303030303030203000000000c0000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000700
07030303030303030303020203330001000000000000190b190b000000000000000700000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000700
070303030303030303000203030000000202020202000b191925000000000000000700000000000000000000000000000000000000000000000000000000000007070000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000070700
07020202020203030302030300000000060509050200190b190b000000000000070700000000000000000000000000000000000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000070000
07330017180000000002000000000e0002050505020000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000070000
07000027280000000007000300000000020002020200001200230000000b0007070000000000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000070000
0700001718000000000700030303000000000000000000000000000000000007001900000000330000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000070000
07000027281718000707000000030300000000150000000e0000000000000007000000000000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000700
07000000002728000000000e0000000003000000000000000019000000000007070017180000000000001a391d1b00000000000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000700
07000000000000000000000000000000000300000000000000000000000000000700272800000000001a1e29291f1b000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000700
070000000000250000000000000000000000000300000000000000000000000007000000000000001a1e292929291f1b0000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000007
070000000000000000001313131313130000000000000003000000000000000007000000000000001c2929292929292d0000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000007
070000190000000000001314000000131313131300000000000300000000000000000000000000001c2929292929292d0000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000007
070000000000000000001300000000130000001313131313000003000003000000000000000000002a2e292929292f2b0000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000007
07070000000000000000131313130000000000000000001313000000000303030000000000000000001c292929292d000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
07070000000000002500000000131313130000130000001413000000000000000303030303030300001c292929292d000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
07070000000000000000000000001300131300130000000013000000000000000700000000000000002a2e29292f2b000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
0707000000000000000000000000130000000000130000001300000000000000070000000000030000002a2c2c2b00000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000330000000000000000131313130000000000000000070000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000130000000000000e13000000000000000000070000000000000003030303030303000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000131300000000001313000000000000000000070000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000001313000000001300000000000000000000070000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007
0700000000000000000000000000000000131313130000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000707
0700000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000707
0700000000000000000000000000000000000000004242424200000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000707
0700000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070700000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000700
0707000000000000000000000000000000000000004543444600000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000700
0707000000000000000000000000000000000000004553544600000000000007070000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000070707000000000700
0707070707070707070707070000000000000000000000000000000000000007000707070707070707070000000000000000000000000000000000000000000007070700000000070707070707070700000000000000000000000007070707070707070707000000000000000000000000000000070707000000070700000007
__sfx__
000200000a0500f05015050190501c0501e0501c05018050160501605017050170501a0501e050210502405026050270502705023050210501f0501f0501f05022050260502a0502c0502f05035050380503e050
0010000018010180100000000000210102101000000000001c0101c01000000000002401024010000000000022010230100000000000270102701000000000002501026010250000000029010290102900000000
0010000000010000100001000010000000000000000000000501005010050100501000000000000000004000040100401004010040100000000000150001400007010070100701007010070000b0000b00000000
001000000151001510006000560000000000000151001510186001c60001510015102b6002e600316003660000510005103c60000000000000000001510015100000000000005100051000000000000000000000
00010000291502c1502e1502e1502e1502c15029150231502115021150221502415025150261502515024150201501b150171501315011150111501115013150141501515014150131500f1500b1500915004150
00030000090500b0500d0500f0500e05009050080500a0501105015050180501905017050130501305014050160501a05020050250502605024050210501f0501e0501f05023050270502a0502e0503105034050
300800001d0201d0201d0201d02024020240202402024020200202002020020200202502025020250202502020020200202002020020240202402024020240202202022020220202202027020270202702027020
310800003015030150231502315030150301502315023150302503025023250232502f2502f25023250232501a3501a3500e3500e35019350193500d3500d35019450194500d4500d45018450184500d4500d450
010800001105011050110501105011050110501105011050050500505005050050500505005050050500505016050160501605016050160501605016050160501305013050130501305013050130501305013050
000100000a05009050090500905009050090500a0500b0500c0500d0500f0501005013050170501c05021050260502a05037000390002100022000250002600027000290002c0002d00030000330003500036000
00050000335503455034550325502d5502e5502f5502d5502655028550295502955023550245502555026550235501e5501b5501c5501c5501a55014550165501655015550105500e5500f5500c5500955003550
000100003655036550365503655036550005002e5502e5502e5502e5502e5502e5002855028550285502855028550285002155021550215502155021550215002150021500215000040000400004000040000400
__music__
02 01020344
03 06084344

