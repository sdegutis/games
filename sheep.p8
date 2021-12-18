pico-8 cartridge // http://www.pico-8.com
version 33
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

loop through all entities

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
	level=1
	startgame()
end

function startgame()
	entities={}
	players={}
	
	_update = updategame
	_draw = drawgame
	
	for y=0,31 do
		for x=0,31 do
			local s = mget(x,y)
			if s==12 then
				makeplayer(x,y,1)
				replacetile(x,y)
			elseif s==13 then
				makeplayer(x,y,2)
				replacetile(x,y)
			elseif fget(s,0) then
				makesolid(x,y,s)
				replacetile(x,y)
			end
		end
	end
end

function replacetile(x,y)
	mset(x,y,0)
end

function updategame()
	for i=1,#entities do
		local e = entities[i]
		if e.tick then
			e:tick()
		end
		
		if e.movable then
			trymoving(e)
		end
	end
end

function drawgame()
	cls(3)
	
	local cx = 0
	local cy = 0
	
	for i=1,#players do
		local p = players[i]
		cx += p.x
		cy += p.y
	end
	
	cx /= #players
	cy /= #players
	
	cx += 4
	cy += 4
	
	camera(
	 mid(0, cx-64, 256-128),
	 mid(0, cy-64, 256-128)
	)
	
	map()
	
	for i=1,#entities do
		local e = entities[i]
		e:draw()
	end
	
	camera()
end

-->8
-- players

function makeplayer(x,y,n)
	e={
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		n=n,
		isplayer=true,
		draw=drawplayer,
		tick=tickplayer,
		movable=true,
		mx=0,
		my=0,
		d=1,
	}
	add(entities,e)
	add(players,e)
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
	
	spr(s, p.x, p.y, 1, 1, f)
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
	add(entities,{
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
	
	if e.mx != 0 then
		e.d  = e.mx
		e.x += e.mx
		trymovingdir(e, e.mx,0)
	end
	if e.my != 0 then
		e.y += e.my
		trymovingdir(e, 0,e.my)
	end
end

function trymovingdir(e,x,y)
	for i=1,#entities do
		local e2 = entities[i]
		local how = collided(e,e2)
		if how then
			if how == 'players' then
				e.x -= x
				e.y -= y
			elseif e2.solid then
				e.x -= x
				e.y -= y
			end
		end
	end
end

function collided(e1,e2)
 -- get their distance apart
	local dx = abs(e1.x-e2.x)
	local dy = abs(e1.y-e2.y)
	
	-- keep them both on screen
	if e1.isplayer and e2.isplayer then
		if dx > 128-e1.w or
		   dy > 128-e1.h then
			return 'players'
		end
	end
	
	-- if they're >10 px apart
	-- they can't be colliding!!
	if dx>10 or dy>10 then
		return false
	end
	
	-- if the diff between x1,x2
	-- is less than max of widths
	-- and same for height
	-- then they collided
	return dx < max(e1.w,e2.w)
	   and dy < max(e1.h,e2.h)
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
__gff__
0000000001010100000000000000000080000000010101000000000000000000800000000001010000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414140404040404040404040404040404040404040404040404041414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414040404040400000000000000000000000000000000000004040404141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040400000000000000000015160000000000000000000000040404041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000c000d0000000025260000000000000000000000000404040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000000000000000000000000000000000000000000000004040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000007000000000505050505050500000000000000000000000004040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000000000610101010100600000000000000000000000000040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000000000620202030100600000000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14040000000000000006101010201006000a0000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000000000610201020100000000000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000000000610302020100000000000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000090000000610101010100600000000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000505050505050500000000000000000000000000040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000000000000000000000000000000000000000000040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000000000000000000000000090000000000000000041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000003030303030300000000000000000000000000041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000003033803030300000000000000000000000000041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000003030303390300000000000000000000000000041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000003030303030300000000000000000000000000041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14040400000000000000033a0303030300090000000000000000000000040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000009000003030303030300000000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000009000000000000000000000000000000000000000000000414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404000000000000000000000000000000000000000000000000000000040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1404040000000000000000000000000000000000000000000000000004040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414040400000000000000000000000000000000000000000000000004040414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414040400000000000000000000000000000000000000000000040404041414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414040404000000000000000000000000000000000000000000040404141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414040404040400000000000000000000000000000000040404040414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141404040404040404040404040404040004040404040404041414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414140404040404141414141414040404040404040414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
