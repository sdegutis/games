pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- sheep.p8
--
-- both girls are shepherds.
-- the sheep are lost!
-- find them, bring them home.

function _init()
	emap={}
	for y=0,63 do
		for x=0,127 do
			local i = y*128+x
			emap[i] = {}
		end
	end
	
	numsheep=0
	
	_update = updategame
	_draw = drawgame
	
	for y=0,63 do
		for x=0,127 do
			local s = mget(x,y)
			if s==12 then
				sarah=makeplayer(x,y,1)
				replacetile(x,y)
			elseif s==13 then
				abbey=makeplayer(x,y,2)
				replacetile(x,y)
			elseif s==8 then
				makebees(x,y)
				replacetile(x,y)
			elseif s==9 then
				numsheep += 1
				makesheep(x,y)
				replacetile(x,y)
			elseif s==3 then
				makebush(x,y,nil)
				replacetile(x,y)
			elseif s==35 then
				makeseed(x,y)
				replacetile(x,y)
			elseif fget(s,2) then
				local s2 = mget(x+1,y)
				if s2==7 then
					maketree(5,x,y,s,makeapple)
					maketree(0,x+1,y,s+1,makeapple)
				elseif s2==8 then
					maketree(5,x,y,s,makebees)
					maketree(0,x+1,y,s+1,makebees)
				elseif s2==9 then
					maketree(5,x,y,s,makesheep)
					maketree(0,x+1,y,s+1)
					numsheep += 1
				else
					maketree(5,x,y,s)
					maketree(0,x+1,y,s+1)
				end
				replacetile(x,y)
				replacetile(x+1,y)
			elseif s==57 then
				numsheep += 1
				makebush(x,y,makesheep)
				replacetile(x,y)
			elseif s==56 then
				makebush(x,y,makebees)
				replacetile(x,y)
			elseif fget(s,0) then
				makesolid(x,y,s)
				replacetile(x,y)
			elseif fget(s,1) then
				makedecor(x,y,s)
				replacetile(x,y)
			end
		end
	end
end

-- emap: 128 x 64 grid
-- each cell = ent[]
-- cx,cy = floor(px,py / 8)
-- index = cx + cy*128

function emapi(x,y)
	local cx = flr(x/8)
	local cy = flr(y/8)
	return cy*128+cx
end

function add_to_emap(e)
	local i = emapi(e.x, e.y)
	add(emap[i], e)
	e.slots = {emap[i]}
end

function emap_move(e)
	emap_remove(e)
	
	for x=0,1 do
		for y=0,1 do
			local x = e.x + e.w*x
			local y = e.y + e.h*y
			local i = emapi(x,y)
			add(emap[i], e)
			add(e.slots, emap[i])
		end
	end
end

function emap_remove(e)
	for es in all(e.slots) do
		del(es, e)
	end
	e.slots={}
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
	camx=mid(0, cx-64,   8*128-128)
	camy=mid(0, cy-64+4, 8* 64-120)
	
	local cellx=flr(camx/8)
	local celly=flr(camy/8)
	
	-- save emap cell top-left
	emapx = mid(1,cellx,127-16)
	emapy = mid(1,celly,63 -16)
	
	local seen={}
	
	for y=emapy-1,emapy+16 do
		for x=emapx-1,emapx+16 do
			local es = emap[y*128+x]
			for e in all(es) do
				if not seen[e] then
					seen[e]=true
					
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
	
end

function drawgame()
	cls(3)
	
	camera(camx,camy-8)
	
	map()
	
	local drawlast={}
	
	local seen={}
	for y=emapy-1,emapy+16 do
		for x=emapx-1,emapx+16 do
			local es = emap[y*128+x]
			for e in all(es) do
				if not seen[e] then
					seen[e]=true
					
					if e.k!='player' then
						if e.k=='decor' then
							add(drawlast,e)
						else
							e:draw()
						end
					end
				end
			end
		end
	end
	
	sarah:draw()
	abbey:draw()
	
	for e in all(drawlast) do
		e:draw()
	end
	
	camera()
	
	rectfill(0,0,127,7,0)
	
	-- sheep
	print(tostr(numsheep),
	      10,2,7)
	spr(9,0,-1)
end

function round(n)
	if n % 1 < 0.5 then
		return flr(n)
	else
		return ceil(n)
	end
end


function makesolid(x,y,s)
	add_to_emap({
		k='solid',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		s=s,
		solid=true,
		draw=drawsimple,
	})
end

function makedecor(x,y,s)
	add_to_emap({
		k='decor',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		s=s,
		draw=drawsimple,
	})
end

function drawsimple(e)
	spr(e.s, e.x, e.y)
end

--[[ flags

0 solid
1 draw in front
2 left-tree, check right-tree
3 
4 
5 
6 
7 pasture

--]]

_playerbox=false
_hitbox=false
_hitsearch=false
_sheepbox=false

-->8
-- players

function makeplayer(x,y,n)
	local offx=3
	local offy=2
	e={
		k='player',
		x=x*8+offx,
		y=y*8+offy,
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
  action=nil,
		d=1,
		offx=offx,
		offy=offy,
	}
	add_to_emap(e)
	return e
end

function drawplayer(p)
	local s = 12
	if (p.n==2) s+=1
	
	local f = false
	if (p.d < 0) f=true
	
	if p.sleep then
		s += 48
	elseif p.moving then
		if p.move_t % 10 <= 5 then
			s += 16
		end
	elseif p.action then
		s += 32
	end
	
	local x = p.x - p.offx
	local y = p.y - p.offy
	
	spr(s, x,y, 1,1, f)
	
	if p.sleep then
		local t = 30*5-p.sleep
		local n = flr(t/7)%4
		spr(14+(n*16), x,y, 1,1, f)
	end
	
	if _playerbox then
		color(1)
		rect(p.x,p.y,p.x+p.w,p.y+p.h)
	end
	
	if _hitbox then
		local r = hitrect(p)
		rect(r.x,r.y,r.x+r.w,r.y+r.h,0)
	end
	
	if p.action and
	   p.action.button==❎ then
		local r = hitrect(p)
		local s = p.n+(16*p.action.spr)
		spr(s, r.x-1,r.y-3, 1,1, f)
	end
	
	if p.has=='bees' then
		spr(22,x,y+3,1,1,f)
	elseif p.has=='apple' then
		spr(23,x,y+3,1,1,f)
	end
end

function hitrect(p)
	local x = p.x + 3
	if (p.d<0) x -= 10
	local y = p.y+3
	return {x=x,y=y,w=5,h=2}
end

function tickplayer(p)
	p.mx=0
	p.my=0
	
	if p.sleep then
		p.sleep -= 1
		if (p.sleep==0) p.sleep=nil
		return
	end
	
	-- moving
	if (btn(⬅️,p.n-1)) p.mx=-1
	if (btn(➡️,p.n-1)) p.mx= 1
	if (btn(⬆️,p.n-1)) p.my=-1
	if (btn(⬇️,p.n-1)) p.my= 1
	
	-- animate acting spr
	if p.action then
		p.action = p.action.tick()
	else
		if btnp(❎,p.n-1) then
			p.action=makeaction(p.n,❎,
				function()
					local act=actions[p.n].❎
					return tryaction(p,act)
				end
			)
		elseif btnp(🅾️,p.n-1) then
			p.action=makeaction(p.n,"🅾️")
		end
	end
	
end

function makeaction(n,b,fn)
	local done=false
	local t=3*4
	local a={button=b}
	a.spr=0
	a.tick=function()
		t -= 1
		a.spr = (3-flr(t/3))
		if (t == 0) return nil
		if not done then
			done=fn()
		end
		return a
	end
	return a
end

function tryaction(p,act)
	-- top left corner in pixels
	local r=hitrect(p)
	
	-- check 4-cell grid
	for x=0,1 do
		for y=0,1 do
			-- get the x/y of corner
			local x1 = r.x + r.w*x
			local y1 = r.y + r.h*y
			
			-- now check this cell
			local i = emapi(x1,y1)
			for e in all(emap[i]) do
				if hitinside(e,r) then
					--local act = acts[p.n]
					if act(p,e) then
						return true
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
	if e2.k=='bees' then
		sting(e2,e)
		return true
	end
end

function act_stick(p,e)
	if e.k=='tree' then
		hittree(e, p.d)
		return true
	elseif e.k=='bush' then
		hitbush(e)
		return true
	elseif e.k=='sheep' then
		hitsheep(e)
		return true
	end
end

function act_bag(p,e)
	if e.k=='apple' then
		p.has='apple'
		emap_remove(e)
		return true
	elseif e.k=='bees' then
		p.has='bees'
		emap_remove(e)
		return true
	elseif e.k=='sheep' then
		hitsheep(e)
		return true
	end
end

actions = {
	-- player 1
	{❎=act_stick,
  🅾️=act_stick},
	
	-- player 2
	{❎=act_bag,
  🅾️=act_throw},
}

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
		   dy > 120-e1.h then
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
	local ei1=emapi(x1,y1)
	local ei2=emapi(x2,y2)
	
	-- get entity arrays in emap
	local ea1 = emap[ei1]
	local ea2 = emap[ei2]
	
	-- combine into one array
	local eas = {ea1}
	if (ei1 != ei2) add(eas,ea2)
	
	local seen={}
	-- loop through each array
	for ea in all(eas) do
		-- loop through each entity
		for e2 in all(ea) do
			if not seen[e2] then
				seen[e2]=true
				if collided(e,e2) then
					if e2.solid then
						return false
					else
						e:collide(e2)
					end
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

function makesheep(x,y,d)
	local offx=1
	local offy=3
	add_to_emap({
		k='sheep',
		x=x*8+offx,
		y=y*8+offy,
		w=5,
		h=5,
		offx=offx,
		offy=offy,
		t=d and 30 or 0,
		speed=sheep_speed,
		movable=true,
		draw=drawsheep,
		tick=ticksheep,
		collide=sheep_collided,
		mx=d or 0,
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
	
	e.mx, e.my = randommoves()
end

function randommoves()
	local a,b
	a = rnd()<0.5 and 1 or -1
	b = rnd()<0.5 and 1 or -1
	if (rnd()<0.5) b=0
	if (rnd()<0.5) a,b = b,a
	return a,b
end

function sheep_collided(e,e2)
	if e2.k == 'bees' then
		hitsheep(e)
	end
end

-->8
-- enemies

function makebees(x,y)
	add_to_emap({
		k='bees',
		x=x*8,
		y=y*8,
		w=6,
		h=6,
		offx=1,
		offy=1,
		t=0,
		movable=true,
		mx=0,
		my=0,
		speed=0.3,
		animt=0,
		collide=bees_collide,
		draw=drawbees,
		tick=tickbees,
	})
end

function drawbees(e)
	local s=8
	s += (flr(e.animt/5)%3) * 16
	spr(s, e.x-e.offx, e.y-e.offy)
end

function tickbees(e)
	e.animt += 1
	if (e.animt==30) e.animt=0
	
	if e.t > 0 then
		e.t-=1
		if e.t==0 then
			e.chase=nil
			e.flee=nil
			e.mx=0
			e.my=0
		end
	end
	
	if e.chase then
		if e.t > 30 then
			e.mx = sgn(e.chase.x-e.x)
			e.my = sgn(e.chase.y-e.y)
		else
			e.mx=0
			e.my=0
		end
	elseif not e.flee then
		trystinging(e)
	end
	
end

function bees_collide(e,e2)
	if e2.k == 'sheep' then
		hitsheep(e2)
	elseif e2.k=='player' then
		if not e.flee then
			sting(e,e2)
		end
	end
end

function sting(e,e2)
	e.chase=nil
	e.flee=true
	e.mx, e.my = randommoves()
	e.t=30*5
	
	e2.sleep=30*5
end

function trystinging(e)
	
	for x=-2,2 do
		for y=-2,2 do
			
			local x1=e.x+x*8
			local y1=e.y+y*8
			local i=emapi(x1,y1)
			
			for e2 in all(emap[i]) do
				if e2.k=='player' then
					e.t=60
					e.chase=e2
					return
				end
			end
			
		end
	end
	
end

-->8
-- greenery

function makebush(x,y,seeder)
	add_to_emap({
		k='bush',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		t=0,
		solid=true,
		draw=drawbush,
		tick=tickbush,
		seeder=seeder,
		shaker=seeder and makeshaker()
	})
end

function makeseed(x,y)
	add_to_emap({
		k='seed',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		t=30*20,
		draw=drawseed,
		tick=tickseed,
	})
end

function makeshaker()
	local t=0
	return {
		tick=function()
			if t == 0 then
				t = ceil(rnd(5)+5)*30
			else
				t -= 1
			end
		end,
		shake=function()
		 -- shake every 5-10 sec
			return t < 20 and t%8 < 4
		end,
	}
end

function tickbush(e)
	if e.dying then
		e.dying -= 1
		if e.dying==0 then
			e.dying = nil
		end
	elseif e.shaker then
		e.shaker.tick()
	end
end

function drawbush(e)
	local s=3
	if e.dying then
		s+=32
	elseif e.shaker then
		if (e.shaker.shake()) s+=16
	end
	spr(s,e.x,e.y)
end

function hitbush(e)
	if e.dying then
		local x=e.x/8
		local y=e.y/8
		
		emap_remove(e)
		makeseed(x, y)
		if e.seeder then
			e.seeder(x, y)
		end
	else
		e.dying = 30*5
	end
end

function drawseed(e)
	spr(51,e.x,e.y)
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
		makebush(x,y)
	end
end

function maketree(offx,x,y,s,itemfn)
	add_to_emap({
		k='tree',
		x=x*8+offx,
		y=y*8,
		w=3,
		h=8,
		offx=offx,
		solid=true,
		itemfn=itemfn,
		s=s,
		draw=drawtree,
		shaker=itemfn and makeshaker(),
	})
end

function drawtree(e)
	spr(e.s, e.x-e.offx, e.y)
end

function hittree(e, d)
	if e.itemfn then
		local x=e.x/8
		local y=e.y/8-1
		e.itemfn(x,y,d)
		e.itemfn=nil
	end
end

function makeapple(x,y,d)
	add_to_emap({
		k='apple',
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		d=-d,
		vy=rnd(2),
		t=flr(rnd(20))+10,
		draw=drawapple,
		tick=tickapple,
	})
end

function drawapple(e)
	spr(7,e.x,e.y)
end

function tickapple(e)
	if e.t then
		e.t -= 1
		if e.t == 0 then
			emap_move(e)
		elseif e.t > 0 then
			e.y -= e.vy
			e.vy -= 0.1
			
			e.x -= e.d
		elseif e.t == -(30*20) then
			emap_remove(e)
		end
	end
end

__gfx__
000000000000055000044400000000000665000044444444450450450000bb000000000000000000000000000000000000000000000000000000000000000000
00000000005544400045554000b4b400065510005555555545045045000bb00000090a0000000000000001000000000000044400000888000000000000000000
0070070005440000004555400bbbbbb06551166000004500445450450000b000000000900000066000000120000000000044f1000088f1000000000000000000
0007700000000000044554000b4b4bb5051106514444444404545004000888000a0a0000006665100000011100000000004fff00008fff000000000000000000
0007700000000000004440000b4bbb45006660115455545504504504008ee88000000000006665500001111700000000004ee000008990000001100000000000
0070070000000000000000000bb4b450066551000450045004504504008e888000900000006666000011150000000000000ee000000990000000000000000000
00000000000000000000000000b44550065511000450004504504545008888800000009000500500101150000000000000011000000220000000000000000000
00000000000000000000000000444500000110000045004504504545000888000a00a00000500500111110000000000000011000000220000000000000000000
000000b5000000000000000000000000006666000000000000000000b000000000000a0000000000000000000000000000000000000000000000000000000000
00000bb50000000000044400004b4b0006666550000000009a000000ee0000000090000000000000000001000000000000044400000888000000000000000000
00000b5000555400004555400bbbbbb00665555100000000a9000000e8000000000000090000066000000120000000000044f1000088f1000000010000000000
000000000544000004555540bbb4b4506665555100000000000000000000000000a00000006665101000011100000000004fff00008fff000000100000000000
0b5000000000000000455540b4bbb450665555510000000000000000000000000000900000666550111111170000000000eee000009990000000000000000000
0bb5000000000000000444000b4b4550665555110000000000000000000000000000000a006666000151150000000000000eee00000999000000000000000000
00b5000000000000000000000bb44500055551110000000000000000000000000900000000500500155150000000000000111000002220000000000000000000
0000000000000000000000000044550000111110000000000000000000000000000a090005005000100500000000000000000100000002000000000000000000
0000000000000000000000000000000000000000b000000000000000b0000000000000a000000000000010000000000000000000000000000000000000000000
00000000000000000000000000000000000b0bbbbb9b0000000b0bbbbbbb00000000000000000000000012000000000000044400000888000000001000000000
00000b5000000000004440000000000000099b9bbbb00000000bbaabbaa000000a0000000000000000001110000000000044f1000088f1000000011000000000
000000000055500004555400000b400000bbb99bbbbbb00000bbbababbbbb00000090a00000006601001117000000000004fff00008fff000000000000000000
000000000004450004555400004bbb000bbb9b9b9b9b00000bbbbbbbbabb000000000000006665100101110000000000004ee000008990000000000000000000
00000000000004400045540000b4b4500999b99bbb9bbb000bbaabbabbabbb000a000000006665500111150000000000000eee00000999000000000000000000
00b50000000000000004400000b4455000b99b9bb9bbb00000bbbbbbbbbbb0000000900000666600110000500000000000011000000220000000000000000000
000000000000000000000000004445000bbbbbbb99b990000bbbabaababbb0000000000a05505500000000000000000000011000000220000000000000000000
0000000000000000000000000000000000b9bbbbbb9bb00000baabbabbbab000bbbbbbbbbbbbbbbb000000000000000000000000000000000000001100000000
00eee0000000000000000000000000000b9bb949bb9b00000bbbbbbbbbbb0000bbb9babbbbbbbbbb000000000000000000000000000000000000011000000000
00e88e000000000000000000000000000b999b4b409900000bbbbb4b40bb0000bbbbbb9bbbbbb66b000000000000000000000000000000000000000000000000
00e8ee00000000000444000000000000000bb044500b0000000bb044500b0000babbbbbbbb66651b000000000000000000000000000000000000000000000000
000ee00004500000045540000000000000000044500000000000004450000000bbbbabbbbb66655b000111110000000000000000000000000000000000000000
000bb50000450000045540000000000000000044500000000000004450000000bb9bbbbbbb6666bb001115200000000004ff000008ff00000000000000000000
00bb50000004500004554000000bb00000000044550000000000004455000000bbbbbb9bbb5bb5bb101157100000000004ffee1108ff99220000000000000000
000b500000000000004400000044550000000444450000000000044445000000babbabbbbb5bb5bb111110000000000004444e11088889220000000000000000
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
41404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010102020202020202
02030202020302020201020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041
41404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600101010102020202030202
02030202020202020101600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041
41404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600101010102020202020202
02020202020102020101600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041
41404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505001010101020302020202
02020202010102010150500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041
41414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006001010101010303020202
02030301010201010160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
41414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050010101010102020202
02010101010101015050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
41414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500101020101010101
01010101010101505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
41414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600101010101010101
01010101015050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004140
41414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505001010102
50505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
41414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050000100
00505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
41404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
41404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
41404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
41404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
41404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004141
41400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004141
41400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041
40400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004141
40400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
40400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041
41400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
41400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
40400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
40404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040
41404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040
41404040000000000000000000404040404000000000000000000000000000000000000040404040404040400000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000000000000000000000000000000040404041
41404040404040000000004040404040404040404040400000000000000000000040404040404040404040404040004040400000000000000000000000000000
00404040404040404040404040000000000000000000000000000000000000000000404040404040404000000000000000000000000000000000004040404041
41414040404040404040404040404040404141414040404040404040404040404040404040404040404040404040404040404040404000404040404000404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000000000404040404040404040404141
41414141414141414141414141414141414141414141414141414141414141414141414141414140414141414141414141414141414141414141414040414141
41414141414141414141414141414140404141414141414141414141414140414141414141414141414140414141404040404040404040404040414141414141
__gff__
0000000001010100000000000000000080000000010000000000000000000000800000000202020200000000000000008000000004010401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1414141414141404041414040404141414141414040404040404040404041414141414141414140404141414141414141414141414141414141414141414141414141414140404141404141414141414141414140404040404040414141414141414141414141414141414141414141414141414141414141414141414141414
1414140404040404040404040004040404040404040404040404000000000000000000000000000404040404040404040414141404040400000000000000000000000000000004040404041414040404040404040400000014141400000004040404040404040404040404040404040404040404040404040404141414141414
1414040404040000000000000000040404040400000000000000000000000000000000000000000000040404040404040404040400000000000000000000000000000000000000000404040404000000000000000000000000000000000000000000040404040404040404040404040000000000000004040404040414141414
1404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404040400000000000000000000000000000004040404041414
0404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404041414
1404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404041414
1404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040414
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003030300000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000404
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303030300000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000039393939393939393900000000000000000000000000000000000000000000000000000000000000000000000014
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000038383838383838383838383839393900000000000000000000000000000000000000000000000000000000000000000000000014
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090038383838383838383838383838393900000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500000005050000000000000000000038383838383838383838383838393900000000000000000000000000000000000000000000000000000000000000000000000404
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505051010101005050505000000000000000038383838383838383838383838393900000000000000000000000000000000000000000000000000000000000000000000000414
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050510101010101010101010050505000000000038383838383800383838383838393900000000000000000000000000000000000000000000000000000000000000000000000414
140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050510101010102020202010101010100505000000003838383838380c380038383838393900000000000000000000000000000000000000000000000000000000000000000000000414
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000610101030202020202030202010101005050500000038383838383800380d00383838393900000000000000000000000000000000000000000000000000000000000000000000000414
0404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050510101020202020202020202020101020050505000038383838383838380000383838393900000000000000000000000000000000000000000000000000000000000000000000040414
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061010102020202020303020202020201010100505000039393939383838383838383839393900000000000000000000000000000000000000000000000000000000000000000000000414
140400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006101030302020202020202020202020201010200600003939393939390a003939393939393900000000000000000000000000000000000000000000000000000000000000000000000404
1404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061010202020202020202020202030302020101005050039393939393939393939393939393900000000000000000000000000000000000000000000000000000000000000000000000404
1404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005051010202020302020202020202020202020201020060039393939393939393939393939390000000000000000000000000000000000000000000000000000000000000000000000000404
1404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006101010202020202020202020202020202020201020060000000000393939390039000000000000000000000000000000000000000000000000000000000000000000000000000000000414
1404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010302020202020202020202020203020201010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014
