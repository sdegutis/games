pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- blobby

poke(0x5f36, 0x8)

function _init()
	emap={}
	for y=0,63 do
		for x=0,127 do
			emap[y*128+x]={}
		end
	end

	chestspr=findsprite(2)
	bubblespr=findsprite(7)

	for y=0,63 do
		for x=0,127 do
			local s = mget(x,y)
			if     fget(s, 0) then mset(x,y,0) makesolid(s,x*8,y*8)
			elseif fget(s, 1) then mset(x,y,0) makesolid(s,x*8,y*8,true)
			elseif fget(s, 3) then mset(x,y,0) makeplayer(s,x*8,y*8)
			elseif fget(s, 7) then mset(x,y,0) makechest(chestspr,x*8,y*8,'wand')
			end
		end
	end
end

function emap_add(ent)
	emap_add_to(ent, emap_get(ent.x,ent.y))
	emap_add_to(ent, emap_get(ent.x+7,ent.y))
	emap_add_to(ent, emap_get(ent.x,ent.y+7))
	emap_add_to(ent, emap_get(ent.x+7,ent.y+7))
end

function emap_get(x,y)
	local i = flr(y/8)*128+flr(x/8)
	return emap[i]
end

function emap_add_to(ent,ents)
	ents[ent]=true
	ent.slots[ents]=true
end

function emap_rem(e)
	for ents in pairs(e.slots) do
		ents[e]=nil
	end
	e.slots={}
end

function findsprite(f)
	for i=0,255 do
		if fget(i,f) then
			return i
		end
	end
end

function _update()
	cx=flr((player.x+4)/128)*128
	cy=flr((player.y+4)/128)*128

	local seen={}
	for y=0,15 do
		for x=0,15 do
			local mx = (cx/8)+x
			local my = (cy/8)+y
			for e in pairs(emap[my*128+mx]) do
				if not seen[e] then
					seen[e]=true
					if e.update then
						e:update()
					end
				end
			end
		end
	end
end

function _draw()
	cls()
	camera(cx,cy)
	map()
	local seen={}
	for layer=1,3 do
		for y=0,15 do
			for x=0,15 do
				local mx = (cx/8)+x
				local my = (cy/8)+y
				for e in pairs(emap[my*128+mx]) do
					if e.layer == layer then
						if not seen[e] then
							seen[e]=true
							e:draw()
						end
					end
				end
			end
		end
	end
end

function makechest(s,x,y,tool)
	emap_add({
		k='chest',
		slots={},
		s=s,x=x,y=y,
		tool=tool,
		draw=drawsimple,
		layer=1,
	})
end

function makeplayer(s,x,y)
	player={
		k='player',
		slots={},
		s=s,d=1,
		x=x,y=y,
		d=1,
		vx=0,vy=maxgrav,
		draw=drawplayer,
		layer=2,
		update=updateplayer,
		collide=playercollide,
	}
	emap_add(player)
end

function makesolid(s,x,y,semi)
	emap_add({
		k='solid',
		slots={},
		s=s,x=x,y=y,
		semi=semi,
		draw=drawsimple,
		layer=1,
	})
end

function drawplayer(p)
	spr(p.s, p.x, p.y, 1, 1, p.d<0)
	-- rect(p.x, p.y, p.x+7,p.y+7,2)

	if p.chest then
		circfill(p.x+4, p.y-6, 4, 0)
		circ    (p.x+4, p.y-6, 4, 6)
		line(p.x+3,p.y-7,p.x+5,p.y-5,6)
		line(p.x+5,p.y-7,p.x+3,p.y-5,6)
	end
end

function drawsimple(e)
	spr(e.s, e.x, e.y)
end

function updategoing(e)
	e.t += 1
	if e.t == 20 then
		emap_rem(e)
	end
end

function drawgoing(e)
	if e.t % 4 < 2 then
		drawsimple(e)
	end
end

function updatebubble(e)
	-- emap_rem(e)

	e.x += cos(t()%2/2)*0.3
	e.y = e.y-0.2

	-- emap_add(e)
end

function startgoing(e)
	e.kind='going'
	e.t=0
	e.update=updategoing
	e.draw=drawgoing
end

maxgrav=3
jumpvel=-7
grav=0.25

xvel=1
maxvelx=3

function playercollide(e, o, d, v)
	if o.k=='solid' then
		if not o.semi or d=='y' and v>0 and e.y==o.y-7 then
			e[d] -= s
			emap_add(e)
			return false
		end
	elseif o.k=='bubble' then
		if d=='x' then
			o.x += s
		elseif d=='y' then
			if v<0 then
				o.y += s
			elseif v>0 then
				e.y -= s
				o.y += s
				-- emap_add(o)
				return false
			end
		end
	end
	return true
end

function updateplayer(p)
	if btnp(❎) then
		if p.chest then
			startgoing(p.chest)
			if p.chest.tool == 'wand' then
				p.wand=true
			end
			p.chest=nil
		elseif p.wand then
			if p.bubble then
				startgoing(p.bubble)
			end
	
			p.bubble = {
				k='bubble',
				slots={},
				x=p.x+16*p.d,
				y=p.y,
				s=bubblespr,
				draw=drawsimple,
				layer=3,
				update=updatebubble,
			}
	
			emap_add(p.bubble)
		end
	end

	if     btn(➡️) then p.d= 1 p.vx=min(p.vx+xvel, maxvelx)
	elseif btn(⬅️) then p.d=-1 p.vx=max(p.vx-xvel,-maxvelx)
	elseif p.vx >  xvel then p.vx = p.vx - xvel
	elseif p.vx < -xvel then p.vx = p.vx + xvel
	elseif p.vx != 0 then p.vx=0
	end

	if p.vx then
		if trymove(p, 'x', p.vx) then
		end
	end

	if p.grounded and btn(🅾️) then
		p.vy = jumpvel
	else
		p.vy = min(p.vy + grav, maxgrav)
	end

	if trymove(p, 'y', p.vy) then
		p.grounded=false
	else
		p.grounded=p.vy>0
		p.vy = 0
	end

	p.chest=nil
	-- for o in pairs(ents) do
	-- 	if o.k=='chest' and overlaps(p,o) then
	-- 		p.chest=o
	-- 		break
	-- 	end
	-- end
end

function overlaps(a,b)
	return a.x >= b.x - 7
	   and a.y >= b.y - 7
	   and a.x < b.x + 8
	   and a.y < b.y + 8
end

function trymove(e,d,v)
	-- local slots = e.slots

	-- emap_rem(e)

	local s = sgn(v)
	for i=s,v,s do
		e[d] += s

		-- local ents1 = emapi[flr(y/8)*128+flr(x/8)]

		-- local ents1 = emap_get(e)

		for emap in pairs(slots) do
			for o in pairs(emap) do
				if overlaps(e,o) then

					if not playercollide(e,o,d,v) then
						return false
					end

				end
			end
		end
	end

	-- emap_add(e)
	return true
end

__gfx__
111111110000660000bbbb0000000000666666651111111111111111011111110000000000000000000000000000000000000000000000000000000000000000
11011111066666600b3333b002222220655555551000000111101111111111100000000000000000000000000000000000000000000000000000000000000000
1111111166666666b337373b24444442655555551000000111111111111110110000000000000000000000000000000000000000000000000000000000000000
1111111166666666b331313b22222222655555551000000110666666666111110000000000000000000000000000000000000000000000000000000000000000
1110111166666666b333333b24499442655555551000000111666666666666110000000000000000000000000000000000000000000000000000000000000000
01111111066666660bb333b024444442655555551000000116666666666666660000000000000000000000000000000000000000000000000000000000000000
111111110666666000bbbb0024444442655555551000000166666666666666660000000000000000000000000000000000000000000000000000000000000000
10110110000666000990099022222222555555551111111166666666666666660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000777700333333337777777766666666666666660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000070333434436060606016666666666666660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070070007444434440000000016666666666666660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070700007444444440000000016666666666666610000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000007444444440000000011666666666666610000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000007444444440000000011116666666661110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000070444444440000000011111166111111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000777700444444440000000010111111111010110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666666616666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000611111116555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000611111116555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000611111116555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000611111116555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000611111116555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000611111116555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000111111115555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
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
42000000000000000000000000000000000000000000000000000000000000004242424242424242424242424242424200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000000002000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004200000000000031000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000004040404040404040404040404040404000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000006070000000000000000000000000000000000000000000404040404000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000006171000000000000000000000000000000000000000000000000000000000000005140
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000006070000000000000000000000000000000000000515151510000404040400000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42404040404040404040000000000000000000006171000000000000000000000000000000000000000000000000000000000000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005140
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42006070000000000000400000000000000000000000000000000000000000000000000000000000515151510000000000000000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42006171000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005140
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000520000000000000000000000000000000000000000000000000000000000515151510000000000000000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005140
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000400000000000000000000000000000310000000000000000000000000000000000000000000000000000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414142
__gff__
0000080401020000000000000000000000000080010200000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424241424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424141414141414242424
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
