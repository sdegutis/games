pico-8 cartridge // http://www.pico-8.com
version 34
__lua__


--[[

sheep.p8

both girls are shepherds.
the sheep are lost!
find them, bring them home.

top-down zelda-style view.
toggleable split screen.
8 pre-made levels.

one girl has stick.
stick can clear bushes.
stick can shoo bees.

one girl has bag.
bag can carry apples.
bag can carry bees!

clearing bushes is tiring.
sleepiness makes you slow.
apples cure sleepiness!

wolves scare sheep!
shoo them with bees!
find bees in bushes.

lead sheep to their fold.
sheep follow other sheep.
sheep like being fed apples!


---

interactions

bushes
	can contain bees
	can contain apples
	can contain sheep?
	can contain wolves!

trees
	can contain apples
	can contain bees
	release if:
		hit with stick
		hit with bag

stick
	sheep > runs
	wolf  > nothing
	bush  > clear & reveal
	bees  > runs (after 3)
	apple > nothing

bag
 sheep > nothing
 wolf  > nothing
 bush  > nothing
 bees  > captures
 apple > captures

bees sees
	player > gets sleepy
	wolf   > nothing
	sheep  > runs
	bees   > nothing

wolf sees
 player > nothing
 bees   > nothing
 sheep  > runs
 wolf   > nothing

sheep sees
	player > nothing
	bees   > runs
	wolf   > runs
	sheep  > follows

apple
	bees   > nothing
	sheep  > follows player!
	wolf   > runs away! (secret)
	player > less sleepy



---

update game:

loop through visible entities

if e.tick
 e.tick()

if e.shouldact
 e.shouldact=false
 e.act()
 	handle act-collision (how?)
 	e:collide(???)

if e.movable
 move(e)
 foreach entity e2
 	handle move-collision
		e:collide(e2)

def
	p.collide = player_collides
	s.collide = sheep_collides
	w.collide = wolf_collides
	etc


--]]

function _init()
	startgame()
end

function startgame()
	emap={}
	
	_update = updategame
	_draw = drawgame
	
	for y=0,63 do
		for x=0,127 do
			local i = y*128+x
			emap[i] = {}
			
			local s = mget(x,y)
			if s==12 then
				sarah=makeplayer(x,y,1)
				replacetile(x,y)
			elseif s==13 then
				abbey=makeplayer(x,y,2)
				replacetile(x,y)
			elseif s==9 then
				makesheep(x,y)
				replacetile(x,y)
			elseif fget(s,0) then
				makesolid(x,y,s)
				replacetile(x,y)
			end
		end
	end
end

--[[
emap is 128 x 64 grid (0-base)
flattened by row-first
each element is ent[]
cx,cy = floor(px,py / 8)
i = cx + cy*128
--]]

function emapi(e)
	local cx = flr(e.x/8)
	local cy = flr(e.y/8)
	return cy*128+cx
end

function add_to_emap(e)
	local i = emapi(e)
	add(emap[i], e)
	e._emapi = i
end

function emap_maybe_move(e)
	add(emap_moves,e)
end

function replacetile(x,y)
	mset(x,y,0)
end

function updategame()
	
	-- get spot between players
	local cx=(sarah.x+abbey.x)/2+4
	local cy=(sarah.y+abbey.y)/2+4
	
	-- save camera pixel top-left
	camx=mid(0, cx-64, 8*128-128)
	camy=mid(0, cy-64, 8* 64-128)
	
	-- save emap cell top-left
	emapx = min(flr(camx/8),127-16)
	emapy = min(flr(camy/8),63 -16)
	
	emap_moves={}
	
	forvisents(function(e)
		if e.tick then
			e:tick()
		end
		
		if e.movable then
			trymoving(e)
		end
	end)
	
	for e in all(emap_moves) do
		local i = emapi(e)
		local j = e._emapi
		if i != j then
			del(emap[j], e)
			add(emap[i], e)
			e._emapi=i
		end
	end
	
end

function drawgame()
	cls(3)
	
	camera(camx,camy)
	
	map()
	
	forvisents(function(e)
		e:draw()
	end)
	
	camera()
end

function forvisents(fn)
	for y=emapy,emapy+16 do
		for x=emapx,emapx+16 do
			local es = emap[y*128+x]
			for i=1,#es do
			 fn(es[i])
			end
		end
	end
end

-->8
-- players

function makeplayer(x,y,n)
	e={
		x=x*8,
		y=y*8,
		w=2,
		h=6,
		n=n,
		isplayer=true,
		draw=drawplayer,
		tick=tickplayer,
		movable=true,
		mx=0,
		my=0,
		d=1,
		offx=3,
		offy=2,
	}
	add_to_emap(e)
	return e
end

function drawplayer(p)
	local s = 12
	if (p.n==2) s+=1
	
	local f = false
	if (p.d < 0) f=true
	
	if p.moving then
		if p.move_t % 10 <= 5 then
			s += 16
		end
	end
	
	local x = p.x - p.offx
	local y = p.y - p.offy
	
	spr(s, x,y, 1,1, f)
end

function tickplayer(p)
	p.mx=0
	p.my=0
	if (btn(⬅️,p.n-1)) p.mx=-1
	if (btn(➡️,p.n-1)) p.mx= 1
	if (btn(⬆️,p.n-1)) p.my=-1
	if (btn(⬇️,p.n-1)) p.my= 1
end

-->8
-- entities

function makesolid(x,y,s)
	add_to_emap({
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		s=s,
		solid=true,
		draw=drawsolid,
	})
end

function drawsolid(e)
	spr(e.s, e.x, e.y)
end

function trymoving(e)
	e.moving = e.mx!=0 or e.my!=0
	
	if e.moving then
		if not e.move_t then
			e.move_t = 0
		end
		e.move_t += 1
		if e.move_t == 30 then
			e.move_t = 0
		end
	else
		e.move_t=nil
	end
	
	local ok=false
	if e.mx != 0 then
		e.d  = e.mx
		e.x += e.mx
		ok=trymovingdir(e, e.mx,0)
	end
	if e.my != 0 then
		e.y += e.my
		ok=trymovingdir(e, 0,e.my)
	end
	
	if ok then
		emap_maybe_move(e)
	end
end

function trymovingdir(e,x,y)
	for i=1,#entities do
		local e2 = entities[i]
		if collided(e,e2) then
			e.x -= x
			e.y -= y
			return false
		end
	end
	return true
end

function collided(e1,e2)
 -- get their distance apart
	local dx = abs(e1.x-e2.x)
	local dy = abs(e1.y-e2.y)
	
	-- keep them both on screen
	if e1.isplayer and e2.isplayer then
		if dx > 128-e1.w or
		   dy > 128-e1.h then
			return true
		end
	end
	
	-- if they're >10 px apart
	-- they can't be colliding!!
	if dx>10 or dy>10 then
		return false
	end
	
	-- if the diff between x1,x2
	-- is less than first's width
	-- and same for height
	-- then they collided
	
	local w = e1.x < e2.x
	          and e1.w or e2.w
	
	local h = e1.y < e2.y
	          and e1.h or e2.h
	
	return dx < w and dy < h
end

-->8
-- sheep

function makesheep(x,y)
	add_to_emap({
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		movable=true,
		draw=drawsheep,
		tick=ticksheep,
		mx=0,
		my=0,
		d=1,
	})
end

function drawsheep(s)
	spr(9,s.x,s.y)
end

function ticksheep(s)
	s.mx = 1
end

__gfx__
000000000000000000000000000000000665000044444444450450450000bb000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000b4b400065510005555555545045045000bb00000090a0000000000000001000000000000044400000888000000000000000000
0070070000000000000000000bbbbbb06551166000004500445450450000b000000000900000066000000120000000000044f1000088f1000000000000000000
0007700000000000005550000b4b4bbb051106514444444404545004000888000a000000006665101000011100000000004fff00008fff000000000000000000
0007700000004440004455500b4bbb4b006660115455545504504504008ee8800000a000006665501111111700000000004ee000008990000001100000000000
0070070000045554000044550bb4b4b0066551000450045004504504008e888000900000006666000151150000000000000ee000000990000000000000000000
00000000000045540000004400b44bb0065511000450004504504545008888800000009000500500155150000000000000011000000220000000000000000000
00000000000004400000000000444400000110000045004504504545000888000a00a00000500500100500000000000000011000000220000000000000000000
000000b50000000000000000000000000066660000000000b00000000000000000000a0000000000000000000000000000000000000000000000000000000000
00000bb500000000000000000000000006666550000b0bbbbb9b0000000000000090000000000000000001000000000000044400000888000000000000000000
00000b500000000000000000000000000665555100099b9bbbb0000000000000000000090000066000000120000000000044f1000088f1000000000000000000
000000000000000000000000000000006665555100bbb99bbbbbb0000000000000a00000006665101000011100000000004fff00008fff000000111000000000
0b500000000000000000000000000000665555510bbb9b9b9b9b0000000000000000900000666550111111170000000000eee000009990000000000000000000
0bb50000000000000000000000000000665555110999b99bbb9bbb00000000000000000a006666000151150000000000000eee00000999000000000000000000
00b500000000000000000000000bb0000555511100b99b9bb9bbb000000000000900000000500500155150000000000000111000002220000000000000000000
00000000000000000000000000444400001111100bbbbbbb99b9900000000000000a090005005000100500000000000000000100000002000000000000000000
000000000000000000000000000000000000000000b9bbbbbb9bb000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000b9bb949bb9b0000000000000000000000000000000001000000000000044400000888000000001000000000
00000b50000000000000000000000000000000000b999b4b4099000000000000000000000000000000000120000000000044f1000088f1000000011000000000
0000000000000000000000000000000000000000000bb044500b00000000000000000000000006601000011100000000004fff00008fff000000000000000000
000000000000000000000000000000000000000000000044500000000000000000000000006665101111111700000000004ee000008990000000000000000000
000000000000000000000000000000000000000000000044500000000000000000000000006665500151150000000000000eee00000999000000000000000000
00b50000000000000000000000000000000000000000004455000000000000000000000000666600155150000000000000011000000220000000000000000000
00000000000000000000000000000000000000000000044445000000000000000000000005505500100500000000000000011000000220000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000001100000000
00eee00000000000000000000000000000000000000000000000000000000000bbb9babbbbbbbbbbbbbbb1bb0000000000000000000000000000011000000000
00e88e0000000000000000000000000000000000000000000000000000000000bbbbbb9bbbbbb66bbbbbb12b0000000000000000000000000000000000000000
00e8ee0000000000000000000000000000000000000000000000000000000000babbbbbbbb66651b1bbbb1110000000000000000000000000000000000000000
000ee00000000000000000000000000000000000000000000000000000000000bbbbabbbbb66655b111111170000000000000000000000000000000000000000
000bb50000000000000000000000000000000000000000000000000000000000bb9bbbbbbb6666bbb15115bb0000000004ff000008ff00000000000000000000
00bb500000000000000000000000000000000000000000000000000000000000bbbbbb9bbb5bb5bb15515bbb0000000004ffee1108ff99220000000000000000
000b500000000000000000000000000000000000000000000000000000000000babbabbbbb5bb5bb1bb5bbbb0000000004444e11088889220000000000000000
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
41000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000004000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000040400000000000000000000000000000000000004000000000000041
41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000040400000000000400000
00000000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000041
41000000000000000000400040404040404000000000000000000000000000000000000000004000400000000000000000000000000000000000000040000000
00000000000000000000004000000000000000000000000000000000000000000000004040400000000000000000000000000000000000000040000000000041
41000000000000004000000000000000000040400000000000000090909000000000000000004000000000000000000040000000004040000000000040000000
00000000000000000000000040000000000000000000000000000000000000000000004040000000000000000000000000000000000000000040000000000041
41000000000040000000000000000000000000004000000000000000009090009090000000000000400000000000000000000000400000000000004000000000
00000000900000000000000000000000000000000000000000000000000000000000004000000000000000000000909000000000000000000000400000000041
41000000000040000000000000000000000000000040000000000000000000000000000000004000004000000000404000000000004000000000004000000000
00000000900000000000000000000000004040400040404040400000000000000000404000000000000000000000009090000000000000000000400000000041
41000000004000000000000000000000000000000000400000000000000000000000000000004000004000000000004000000040000000000000000000000000
00000000900000000000000000400000400000000040004040000040400000000000404000000000000000000000000090000000000000000000400000000041
41410000004000000000000000000000000000000000000000000000000000000000000000004000000000000000400000004000000000000000004000000000
00000000900000000000000000400040000000004000000000000000004000000000400000000000000000000000000000000000000000000040000000000041
00000000004000000000000000000000000000000000400000000000000000000000000000004000000040404040000000400000000000000000000040000000
00000000000000000000000000004000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000041
41000000404000000000000000000000000000000000400000000000000000000000000000000040000000000040004040000000000000000000000040000000
00000000000000000000000040000000000000000000000000000000000000004040000000000000000000000000000000000000000000000040000000000041
41000000404000000000000000009090000000000000400000000000000000000000000000000040404040400040400000004000404040404000000000400000
00000000000000000000000040400000000000000000000000000000000000000000400000000000000000000000000000000000000000004040000000000041
41000000404000000000000000000000909000000000000000000000404000400000000000000000000000000000000000400000000000004040000000400000
00000000000000000000004000400000000000000090000000000000000000000000400000000000000000000000000000000000000000000000000000000041
41000000400000000000000000000000000000000000400000004040000000404040000000000000000000000000004000000000000000000000400000004000
00000000000000000000400000000000000000009090909000000000000000000000400000000000000000000000000000000000000000000000000000000041
41000000000000000000000000000000000000000000400000400000000000000040400000000000000000000000004000000000000000000000004000000040
00000000000000000040000040000000000000009000000000000000000000000000404000000000000000000000000000000000000000400000000000000041
41000000004000000000000000000000000000000040000040000000000000000000000040400000000000000000400000000000000000000000000040000000
40404000000040004000000000000000000000000000000000000000000000000000004000000000000000000000000000000000004000000000000000000041
41000000004040000000000000000000000000004000004000000000000000000000000000000000000000000040000000009000000000000000000040000000
00000040004000000000000040000000000000000000000000000000000000000000004000400000000000000000000000000000400000000000000000000041
41000000000000400000000000000000000000400000000000000000000000000000000000000040000000000040000000009000000000000000000000400000
00000000000000000000000000000000000000000000000000000000000000000000004000004040404000000000000000404040000000000000000000000041
41000000000000004000000000000000004000000000000000000000000000000000000000000000000000000000000000000090000000000000000000400000
00000000000000000000000040000000000000000000000000000000000000000000004000000000000040404040400040000000000000000000000000000041
41000000000000000040004040004040404000000000400000000000009000000000000000000000400000000040000000000090000000000000000000400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000404000400040000000000000000000000041
41000000000000000000000000000000000000000000000000000000000090900000000000000000000000000040000000000090000000000000000000400000
00000000000000000000000040000000000000000000000000000000000000000000000040000000000040404040000000000000404000000000000000000041
41000000000000000000000000000000000000000040000000000000000000909000000000000000400000000040000000000000000000000000000000000000
00000000000000000000000000000000000000000000000090009000000000000000004000000000004000000000000000000000000000000000000000000041
41000000000000000000000000000000000000000040000000000000000000000000000000000000400000000000400000000000000000000000000000400000
00000000000000000000000000000000000000000000000000000000000000000000004000000000400000000000000000000000000000400000000000000041
41000000000000000000000000900000000000000040000000000000000000000000000000000040000000000000000000000000000000000000000000400000
00000000000000000000000000400000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000041
41000000000000000000009090000000000000000040000000000000000000000000000000000000000000000000400000000000000000000000000040000000
00000000000000000000000000000000000000000000000000000000000000000000004000004000000000000000000000000000000000004000000000000041
41000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000040000000000000000000004000000000
00000000000000000000000000400000000000000000000000000000000000000000004000004000000000000000900000000000000000000000000000000041
41000000000000000000000000000000000000000000400000000000000000000000000000004000000000000000000000004040000000000040400000000000
00000000000000000000000000004000000000000000000000000000000000000000400000004000000000000000000000000000000000400000000000004141
41000000000000000000000000000000000000000000004000000000000000000000000000404000000000000000000000000000404040404000000000000000
00000000000000000000000000000040000000000000000000000000000000000000000000004000000000009000000000000000000000400000000000004141
41000000000000000000000000000000000000000000000040000000000000000000000040000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000040000000004000000000009000000000000000000040000000000000004141
41000000000000000000000000000000000000000000000000004040000000000000404000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000404000000000000000000000000000004000000000000040000000000090000000000000000040000000000000004141
41000000000000000000000000000000000000000000000000000000004000404000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000040000000000000000000000000400000000000000000404000000000000000000040404000000000000000000041
41000000004141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000414141000000000000004141
41414141414141414141414141414100000000404040000000000000000040000000000000000000000040004000410040004000000000000000004141410041
41414141410000000000414141414141414141414141414141414141414141414141414141414141414141414141414141414141004141414141414141414100
41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
__gff__
0000000001010100000000000000000080000000010101000000000000000000800000000001010000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1414141414141414141414141414141414141414141414141414141414141414001414141414141414141414141414141414141414141414141400140000141414141414141414141414141414141414141414141414141414140014141414141414141414141414141414141400040414141414141414141414141414141414
1414140404040404040404040404040404040404040404040404041414141414000000000000000000000000000000040004040004040404040404040000000000000000000000000400040404040004040400000000000000000000000000000000000004000000000000000000000000000400000000000000000000000014
1414040404040400000000000000000000000000000000000004040404141414000000000000000000000000000404040000000404000000040004000404000000000000000000040004000000000000000404040000000000000000000000000000000400000000000000000000000000000000040000000000000000000014
1404040400000000000000000015160000000000000000000000040404041414000000000000000000000000040000000000000000000000000004000004040000000000000004040000000000000000000000000400000000000000000000000000040000000000000000000000000000000000000000000000000000000014
1404040000000c000d0000000025260000000000000000000000000404040414000000000000000900000400000000000000040000000000000000040000040400000000000404000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000040000000000000014
1404000000000000000000000000000000000000000000000000000004040414000000000000000000000400000000000004000000000000000000000400000000000000040000000000000000000000000000000000040000000000000000000004000000000000000000000000000000000000000000000000000000000014
1404000000000000000505050505050500000000000009000000000004040414000000000000000000040000000000000000000000000000000000000400000000000004000400000000000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000400000000000014
1404000000000000000610101010100600000000000000000000000000040414000000000000000004000000000000000004000000000000000000000000000000000000040000000000000000000000000000000000000400000000000000000000000000000000000909090000000000000000000000000004000000000014
1404000000000000000620202030100600000000000000000000000000000414000000000000000000000000000000000004000000000000000000040400000000000400000000000000000000000000000000000000000004000000000000000400000000000000000000000000000000000000000000000000000000000014
14040000000000000006101010201006000a0000000000000000000000000414000000000000000400000000000000000004000000000000000400000000000000000004000000000000000000090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000014
1404000000000000000610201020100000000000000000000000000000000414000000000000000400000000000000000004000000000000040000000400000000040000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000014
1404000000000000000610302020100000000000000000000000000000000414000000000000000000000000000000000004000000000404000000040000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000040000000014
1404000000090000000610101010100600000000000000000000000000000414000000000000000000000000000000090000040404000000000000000000000000040004000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000900000000000000000014
1404040000000000000505050505050500000000000000000000000000040414000000000000000400000000000000000000000000000000000004000000000000040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090000040000000014
1404040000000000000000000000000000000000000000000000090000040414000000000000000400000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000014
1404040000000000000000000000000000000000090000000000000000041414000000000000000004000000000000000000000909000000000000000000000000040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000014
1404040000000000000003030303030300000000000000000000000000041414000000000000000000040000000000000000000000000000040000000000000000040000040000000000000000000000090000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000014
1404040000000000000003033803030300000000000000000000000000041414000000000000000000040000000000000000000000000000000000000000000000040000000400000000000000000000000909000000000000040000000000000004000000000000000000000000000000000000000000000000040000001414
1404040000000000000003030303390300000000000000000000000000041414000000000000000000000004000000000000000000000400000000000000000000000400000000000000000000000000000000000000000000000000000000000004000000000000000000090900000000000000000000000000000000001414
1404040000000000000003030303030300000000000000000000000000041414000000000000090000000000040004040004040004000004000000000000000000000400000400000000000000000000000000000000000000000000000000000000040000000000000000000009090000000000000000000000040000000014
14040400000000000000033a0303030300090000000000000000000000040414000000000000000000000000000000000000000000000404000000000000000000000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000014
1404000000000009000003030303030300000000000000000000000000000414000000000000000000000000000000000004040404000400000000000000000000000000040000000000000000000000000000000000000004000000000000000000000400000000000000000000000000000000000000000000000000001414
1404000000000009000000000000000000000000000000000000000000000414000000000000000000000004000000000000000000040400040000000000000000000000000400000404000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000400000000001414
1404000000000000000000000000000000000000000000000000000000040414000000000000000000000404000004000000000000040400040000000000000000000000000004000000000404000000000000000000000000000000000000000000000004000000000000000000000000000000000000000400000000001414
1404040000000000000000000000000000000000000000000000000004040414000000000000000000000400040000000000000000000400000000000000000000000000000000000400000000000404040000000000040000000000000000000000000000040000000000000000000000000000000000040000000000001414
1414040400000000000000000000000000000000000000000000000004040414000000000000000000040404000000000000000004000400040000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000400000000000000000000000000000404000000000000000014
1414040400000000000000000000000000000000000000000000040404041414000000000000000000040000000000000000000000000400040000000000000000000000000000000000000404000000000000000004000000000000000000000000000000000000000404000000000000000004000000000000000000000014
1414040404000000000000000000000000000000000000000000040404141414000000000000000000000400000000000000000400000000000000000000000000000000000000000000000000040004040004040400000000000000000000000000000000000000000000000400040404040000000000000000000000000014
1414040404040400000000000000000000000000000000040404040414141414000000000000000004040000000000000000000400040000000000000000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000004000404000000000000000000000000000014
1414141404040404040404040404040404040004040404040404041414141414000000000000000000000000000000000000000000000000040000000000000004040400000004040000000000000000000000000000000000000000000000000000000000000000000000040400000000040404040000000000000000000014
1414141414140404040404141414141414040404040404040414141414141414000000000000000000040000000000000000000000000000000000000000000400000000000000040400000000000000000000000000000000000000000000000000000000000004000400000000000000000000000000000000000000000014
1414141414141414141414141414141414141414141414141414141414141414000000000000000400000000000000000000040400000000040000000000040000000000000000000404000000000000000000000000000000000000000000000000000000000400000000000000000000000000000004040000000000000014
