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

--]]

_playerbox=false
_hitbox=false
_hitsearch=false
_sheepbox=false

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
			elseif s==3 then
				makebush(x,y,nil)
				replacetile(x,y)
			elseif s==35 then
				makeseed(x,y,nil)
				replacetile(x,y)
			elseif s==57 then
				makebush(x,y,makesheep)
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

function emap_move(e)
	local i = emapi(e)
	local j = e._emapi
	if i != j then
		del(emap[j], e)
		add(emap[i], e)
		e._emapi=i
	end
end

function emap_remove(e)
	local es = emap[e._emapi]
	del(es, e)
end

function replacetile(x,y)
	mset(x,y,0)
end

function updategame()
	
	-- get spot between players
	local w2 = sarah.w/2
	local h2 = sarah.h/2
	local cx=(sarah.x+abbey.x)/2+w2
	local cy=(sarah.y+abbey.y)/2+h2
	
	-- save camera pixel top-left
	camx=mid(0, cx-64, 8*128-128)
	camy=mid(0, cy-64, 8* 64-128)
	
	local cellx=flr(camx/8)
	local celly=flr(camy/8)
	
	-- save emap cell top-left
	emapx = mid(1,cellx,127-16)
	emapy = mid(1,celly,63 -16)
	
	emap_moves={}
	
	for y=emapy-1,emapy+16 do
		for x=emapx-1,emapx+16 do
			local es = emap[y*128+x]
			for e in all(es) do
				if e.tick then
					e:tick()
				end
				
				if e.movable then
					trymoving(e)
				end
			end
		end
	end
	
end

function drawgame()
	cls(3)
	
	camera(camx,camy)
	
	map()
	
	for y=emapy-1,emapy+16 do
		for x=emapx-1,emapx+16 do
			local es = emap[y*128+x]
			for e in all(es) do
				e:draw()
			end
		end
	end
	
	camera()
end

function round(n)
	if n % 1 < 0.5 then
		return flr(n)
	else
		return ceil(n)
	end
end

-->8
-- players

function makeplayer(x,y,n)
	e={
		k='player',
		x=x*8,
		y=y*8,
		w=2,
		h=6,
		n=n,
		speed=1,
		draw=drawplayer,
		tick=tickplayer,
		movable=true,
		collide=player_collide,
		mx=0,
		my=0,
		act= (n==1 and act_stick
	             or act_bag),
		d=1,
		offx=3,
		offy=1,
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
	elseif p.act_t then
		s += 32
	end
	
	local x = p.x - p.offx
	local y = p.y - p.offy
	
	spr(s, x,y, 1,1, f)
	
	if _playerbox then
		color(1)
		rect(p.x,p.y,p.x+p.w,p.y+p.h)
	end
	
	if _hitbox then
		local r = hitrect(p)
		rect(r.x,r.y,r.x+r.w,r.y+r.h,0)
	end
	
	if p.act_t then
		local r = hitrect(p)
		spr(p.n, r.x-1,r.y, 1,1, f)
	end
end

function hitrect(p)
	local x = p.x + 3
	if (p.d<0) x -= 10
	local y = p.y+3
	return {x=x,y=y,w=5,h=2}
end

function hitxy(p)
	local x=p.x+p.w/2+(6*p.d)
	local y=p.y+4
	return x,y
end

function tickplayer(p)
	-- moving
	p.mx=0
	p.my=0
	if (btn(⬅️,p.n-1)) p.mx=-1
	if (btn(➡️,p.n-1)) p.mx= 1
	if (btn(⬆️,p.n-1)) p.my=-1
	if (btn(⬇️,p.n-1)) p.my= 1
	
	-- try action
	if p.act_t then
		p.act_t -= 1
		if (p.act_t==0) then
			p.act_t=nil
		else
			tryaction(p)
		end
	end
	
	-- action timer
	if not p.act_t
    and btnp(❎,p.n-1)
	then
		p.act_t=10
	end
	
end

function tryaction(p)
	-- top left corner in pixels
	local r=hitrect(p)
	local corners = {
		{r.x,r.y},     {r.x+r.w,r.y},
		{r.x,r.y+r.h}, {r.x+r.w,r.y+r.h},
	}
	
	-- check 4-cell grid (sqr)
	for x1=-1,0 do
		for y1=-1,0 do
			for c in all(corners) do
				local x = c[1] + x1*8
				local y = c[2] + y1*8
				local i = emapi({x=x,y=y})
				for e in all(emap[i]) do
					if hitinside(e,r) then
						if p:act(e) then
							p.act_t=nil
							return
						end
					end
				end
			end
		end
	end
end

function hitinside(e,r)
	if _hitsearch then
		camera(camx,camy)
		color(13)
		rect(e.x,e.y,e.x+e.w,e.y+e.h)
		flip()
		camera()
	end
	
	return collided(e,r)
end

function player_collide(e,e2)
	
end

function act_stick(p,e)
	if e.k=='bush' then
		hitbush(e)
		return true
	elseif e.k=='sheep' then
		hitsheep(e)
		return true
	end
end

function act_bag(p,e)
	
end

-->8
-- moving

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
		
		e.x += e.mx * e.speed
		if trymovingdir(e, e.mx,0) then
			emap_move(e)
		else
			e.x -= e.mx * e.speed
		end
	end
	
	if e.my != 0 then
		e.y += e.my * e.speed
		if trymovingdir(e, 0,e.my) then
			emap_move(e)
		else
			e.y -= e.my * e.speed
		end
	end
end

function trymovingdir(e,x,y)
	
	-- keep them both on screen
	if e.k=='player' then
		local e1,e2 = sarah,abbey
		local dx = abs(e1.x-e2.x)
		local dy = abs(e1.y-e2.y)
		if dx > 128-e1.w or
		   dy > 128-e1.h then
			return false
		end
	end
	
 -- get relative points
 -- top-l,   bottom-l, or
 -- right-t, right-b,  etc
	local rx1,rx2=x,x
	local ry1,ry2=y,y
	if x==0 then
		rx1=-1 rx2=1
	elseif y==0 then
		ry1=-1 ry2=1
	end
	
	-- get center of entity
	local w2 = e.w/2
	local h2 = e.h/2
	local cx = e.x + w2
	local cy = e.y + h2
	
	-- get both absolute points
	local x1 = cx + w2*rx1
	local x2 = cx + w2*rx2
	local y1 = cy + h2*ry1
	local y2 = cy + h2*ry2
	
	-- get emap indexes
	local ei1=emapi({x=x1,y=y1})
	local ei2=emapi({x=x2,y=y2})
	
	-- get entity arrays in emap
	local ea1 = emap[ei1]
	local ea2 = emap[ei2]
	
	-- combine into one array
	local eas = {ea1}
	if (ei1 != ei2) add(eas,ea2)
	
	-- loop through each array
	for ea in all(eas) do
		-- loop through each entity
		for e2 in all(ea) do
			if collided(e,e2) then
				if e2.solid then
					return false
				else
					e:collide(e2)
				end
			end
		end
	end
	
	return true
end

function collided(e1,e2)
 -- can't collide with yourself
	if (e1==e2) return false
	
 -- get their distance apart
	local dx = abs(e1.x-e2.x)
	local dy = abs(e1.y-e2.y)
	
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

sheep_speed=0.2

function makesheep(x,y)
	add_to_emap({
		k='sheep',
		x=x*8,
		y=y*8,
		w=5,
		h=5,
		offx=1,
		offy=3,
		t=0,
		speed=sheep_speed,
		movable=true,
		draw=drawsheep,
		tick=ticksheep,
		collide=sheep_collided,
		mx=0,
		my=0,
		d=1,
	})
end

function drawsheep(e)
	local s = 9
	if e.moving then
		if e.move_t % 10 <= 5 then
			s += 16
		end
	end
	
	local f = false
	if (e.d < 0) f=true
	
	local x=e.x-e.offx
	local y=e.y-e.offy
	
	spr(s, x,y, 1,1, f)
	
	if _sheepbox then
		color(2)
		rect(e.x,e.y,e.x+e.w,e.y+e.h)
	end
end

function ticksheep(e)
	-- choose new action when idle
	if e.t == 0 then
		local still=rnd()<0.5
		
		e.speed = sheep_speed
		if still then
			-- stand still for 2-3 sec
			e.t = flr((rnd(1)+2)*30)
			e.mx = 0
			e.my = 0
		else
			-- walk for 1 sec
			e.t = 30
			e.mx = round(rnd(2))-1
			e.my = round(rnd(2))-1
		end
	else
		e.t -= 1
	end
end

function hitsheep(e)
	e.t = 60
	e.speed=sheep_speed*3
	e.mx = round(rnd(2))-1
	e.my = round(rnd(2))-1
end

function sheep_collided(e,e2)
end

-->8
-- entities

function makesolid(x,y,s)
	add_to_emap({
		k='solid',
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

-->8
-- bushes

function makebush(x,y,seeder)
	add_to_emap({
		k='bush',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		solid=true,
		draw=drawbush,
		seeder=seeder,
	})
end

function makeseed(x,y,seeder)
	add_to_emap({
		k='seed',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		t=30*20,
		seeder=seeder,
		draw=drawseed,
		tick=tickseed,
	})
end

function drawbush(e)
	spr(3,e.x,e.y)
end

function hitbush(e)
	local x=e.x/8
	local y=e.y/8
	
	emap_remove(e)
	makeseed(x, y, e.seeder)
	if e.seeder then
		e.seeder(x, y)
	end
end

function drawseed(e)
	spr(35,e.x,e.y)
end

function tickseed(e)
	e.t -= 1
	if e.t == 0 then
		-- todo:
		-- only seed if player
		-- is not in radius.
		-- this will give us
		-- radius checking code
		-- which will help
		-- with sheep and wolves too
		-- (and maybe bees.)
		-- (maybe they chase you.)
		-- (who knows.)
		
		emap_remove(e)
		local x = e.x/8
		local y = e.y/8
		makebush(x,y, e.seeder)
	end
end

__gfx__
000000000555000000444400000000000665000044444444450450450000bb000000000000000000000000000000000000000000000000000000000000000000
00000000044455500455554000b4b400065510005555555545045045000bb00000090a0000000000000001000000000000044400000888000000000000000000
0070070000004440004555400bbbbbb06551166000004500445450450000b000000000900000066000000120000000000044f1000088f1000000000000000000
0007700000000000000444000b4b4bb5051106514444444404545004000888000a000000006665100000011100000000004fff00008fff000000000000000000
0007700000000000000000000b4bbb45006660115455545504504504008ee8800000a000006665500001111700000000004ee000008990000001100000000000
0070070000000000000000000bb4b450066551000450045004504504008e888000900000006666000011150000000000000ee000000990000000000000000000
00000000000000000000000000b44550065511000450004504504545008888800000009000500500101150000000000000011000000220000000000000000000
00000000000000000000000000444500000110000045004504504545000888000a00a00000500500111110000000000000011000000220000000000000000000
000000b50000000000000000000000000066660000000000b00000000000000000000a0000000000000000000000000000000000000000000000000000000000
00000bb50000000000000000004b4b0006666550000b0bbbbb9b0000000000000090000000000000000001000000000000044400000888000000000000000000
00000b5000000000000000000bbbbbb00665555100099b9bbbb0000000000000000000090000066000000120000000000044f1000088f1000000000000000000
000000000000000000000000bbb4b4506665555100bbb99bbbbbb0000000000000a00000006665101000011100000000004fff00008fff000000111000000000
0b5000000000000000000000b4bbb450665555510bbb9b9b9b9b0000000000000000900000666550111111170000000000eee000009990000000000000000000
0bb5000000000000000000000b4b4550665555110999b99bbb9bbb00000000000000000a006666000151150000000000000eee00000999000000000000000000
00b5000000000000000000000bb445000555511100b99b9bb9bbb000000000000900000000500500155150000000000000111000002220000000000000000000
00000000000000000000000000445500001111100bbbbbbb99b9900000000000000a090005005000100500000000000000000100000002000000000000000000
000000000000000000000000000000000000000000b9bbbbbb9bb000000000000000000000000000000010000000000000000000000000000000000000000000
00000000000000000000000000000000000000000b9bb949bb9b0000000000000000000000000000000012000000000000044400000888000000001000000000
00000b50000000000000000000000000000000000b999b4b4099000000000000000000000000000000001110000000000044f1000088f1000000011000000000
0000000000000000000000000000000000000000000bb044500b00000000000000000000000006601001117000000000004fff00008fff000000000000000000
000000000000000000000000000000000000000000000044500000000000000000000000006665100101110000000000004ee000008990000000000000000000
000000000000000000000000000000000000000000000044500000000000000000000000006665500111150000000000000eee00000999000000000000000000
00b500000000000000000000000bb000000000000000004455000000000000000000000000666600110000500000000000011000000220000000000000000000
00000000000000000000000000445500000000000000044445000000000000000000000005505500000000000000000000011000000220000000000000000000
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
1414040404040400000000090900000000000000000000000004040404141414000000000000000000000000000404040000000404000000040004000404000000000000000000040004000000000000000404040000000000000000000000000000000400000000000000000000000000000000040000000000000000000014
1404040400000023002309090915160900090900000000000000040404041414000000000000000000000000040000000000000000000000000004000004040000000000000004040000000000000000000000000400000000000000000000000000040000000000000000000000000000000000000000000000000000000014
1404040009000c00000009090925260909090900000000000000000404040414000000000000000900000400000000000000040000000000000000040000040400000000000404000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000040000000000000014
1404000009000000000009090909000009090909000000000000000004040414000000000000000000000400000000000004000000000000000000000400000000000000040000000000000000000000000000000000040000000000000000000004000000000000000000000000000000000000000000000000000000000014
1404000909090909090505050505050509090909000009000000000004040414000000000000000000040000000000000000000000000000000000000400000000000004000400000000000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000400000000000014
1404000909090909000610101010100609090909000000000000000000040000000000000000000004000000000000000004000000000000000000000000000000000000040000000000000000000000000000000000000400000000000000000000000000000000000909090000000000000000000000000004000000000014
1404000909090909000620202030100600000000000000000000000000000000000000000000000000000000000000000004000000000000000000040400000000000400000000000000000000000000000000000000000004000000000000000400000000000000000000000000000000000000000000000000000000000014
14040009090909090006101010201006000a0000000000000000000000000000000000000000000400000000000000000004000000000000000400000000000000000004000000000000000000090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000014
1404000909090909000610201020100000000000000000000000000000000000000000000000000400000000000000000004000000000000040000000400000000040000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000014
1404000909090900000610302020100000000000000000000000000000000000000000000000000000000000000000000004000000000404000000040000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000040000000014
1404000009090900000610101010100600000000000000000000000000000000000000000000000000000000000000090000040404000000000000000000000000040004000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000900000000000000000014
1404040009090909000505050505050500000000000000000000000000000000000000000000000400000000000000000000000000000000000004000000000000040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090000040000000014
1404040009090909090909090909090000000d00000000000000090000000000000000000000000400000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000014
1404040000090909090909090909090000000000090000000000000000000000000000000000000004000000000000000000000909000000000000000000000000040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000014
1404040000000000000003030303030300000000000000000000000000000000000000000000000000040000000000000000000000000000040000000000000000040000040000000000000000000000090000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000014
1404040000000000000003033803030300000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000040000000400000000000000000000000909000000000000040000000000000004000000000000000000000000000000000000000000000000040000001414
1404040000000000000003030303390300000000000000000000000000000000000000000000000000000004000000000000000000000400000000000000000000000400000000000000000000000000000000000000000000000000000000000004000000000000000000090900000000000000000000000000000000001414
1404040000000000000003030303030300000000000000000000000000000000000000000000090000000000040004040004040004000004000000000000000000000400000400000000000000000000000000000000000000000000000000000000040000000000000000000009090000000000000000000000040000000014
14040400000000000000033a0303030300090000000000000000000000000000000000000000000000000000000000000000000000000404000000000000000000000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000014
1404000000000009000003030303030300000000000000000000000000000000000000000000000000000000000000000004040404000400000000000000000000000000040000000000000000000000000000000000000004000000000000000000000400000000000000000000000000000000000000000000000000001414
1404000000000009000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000040400040000000000000000000000000400000404000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000400000000001414
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000404000004000000000000040400040000000000000000000000000004000000000404000000000000000000000000000000000000000000000004000000000000000000000000000000000000000400000000001414
1404040000000000000000000000000000000000000000000000000004040000000000000000000000000400040000000000000000000400000000000000000000000000000000000400000000000404040000000000040000000000000000000000000000040000000000000000000000000000000000040000000000001414
1414040400000000000000000000000000000000000000000000000004000000000000000000000000040404000000000000000004000400040000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000400000000000000000000000000000404000000000000000014
1414040400000000000000000000000000000000000000000000040404000000000000000000000000040000000000000000000000000400040000000000000000000000000000000000000404000000000000000004000000000000000000000000000000000000000404000000000000000004000000000000000000000014
1414040404000000000000000000000000000000000000000000040400000000000000000000000000000400000000000000000400000000000000000000000000000000000000000000000000040004040004040400000000000000000000000000000000000000000000000400040404040000000000000000000000000014
1414040404040400000000000000000000000000000000040404040400000000000000000000000004040000000000000000000400040000000000000000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000004000404000000000000000000000000000014
1414141404040404040404040404040404040004040404040404041400140000000000000000000000000000000000000000000000000000040000000000000004040400000004040000000000000000000000000000000000000000000000000000000000000000000000040400000000040404040000000000000000000014
1414141414140404040404141414141414040404040404040414141414140014000000000000000000040000000000000000000000000000000000000000000400000000000000040400000000000000000000000000000000000000000000000000000000000004000400000000000000000000000000000000000000000014
1414141414141414141414141414141414141414141414141414141414141414000000000000000400000000000000000000040400000000040000000000040000000000000000000404000000000000000000000000000000000000000000000000000000000400000000000000000000000000000004040000000000000014
