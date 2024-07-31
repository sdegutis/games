pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- blobby

function _init()
	emap={}
	for y=0,63 do
		for x=0,127 do
			emap[y*128+x]={}
		end
	end

	updatable={}

	chestspr=findsprite(2)
	keyspr=findsprite(4)
	bubblespr=findsprite(7)

	for y=0,63 do
		for x=0,127 do
			local s = mget(x,y)
			if     fget(s, 0) then mset(x,y,0) makesolid(s,x*8,y*8)
			elseif fget(s, 1) then mset(x,y,0) makesolid(s,x*8,y*8,true)
			elseif fget(s, 3) then mset(x,y,0) makeplayer(s,x*8,y*8)
			elseif fget(s, 4) then mset(x,y,0) makekey(s,x*8,y*8)
			elseif fget(s, 5) then mset(x,y,0) makedoor(s,x*8,y*8)
			elseif fget(s, 6) then mset(x,y,0) makeprize(s,x*8,y*8)
			elseif fget(s, 7) then mset(x,y,0) makechest(chestspr,x*8,y*8,'wand')
			end
		end
	end
end

function emap_add(ent)
	if ent.update then
		updatable[ent]=true
	end

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
	if e.update then
		updatable[e]=nil
	end

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

	for e in pairs(updatable) do
		e:update()
	end
end

function _draw()
	cls()
	camera()
	for y=0,15 do
		for x=0,15 do
			spr(0,x*8,y*8)
		end
	end
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

	if gotkey then
		gotkey += 1
		if gotkey==60 then gotkey=nil end

		camera()
		rectfill(1,1,12+8,12,1)
		spr(keyspr,3,3)
		print(player.keys,15,5,6)
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

function makekey(s,x,y)
	emap_add({
		k='key',
		slots={},
		s=s,x=x,y=y,
		draw=drawsimple,
		update=udpatekey,
		layer=2,
	})
end

function makedoor(s,x,y)
	emap_add({
		k='door',
		slots={},
		s=s,x=x,y=y,
		draw=drawsimple,
		layer=2,
	})
end

function makeprize(s,x,y)
	emap_add({
		k='prize',
		slots={},
		s=s,x=x,y=y,
		draw=drawsimple,
		layer=2,
	})
end

function makeplayer(s,x,y)
	player={
		k='player',
		slots={},
		keys=0,
		wand=false,
		s=s,d=1,
		x=x,y=y,
		d=1,
		vx=0,vy=maxgrav,
		draw=drawplayer,
		layer=3,
		update=updateplayer,
		collide=playercollide,
	}
	emap_add(player)
end

function udpatekey(e)
	e.x += cos(t()%2/2)*0.2
	e.y -= sin(t()%2/2)*0.2
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
	e.standing=false
	trymove(e, 'y', -0.2)

	if not e.standing then
		trymove(e, 'x', cos(t()%2/2)*0.3)
	end
end

function bubblecollide(e, o, d, v)
	if o.k=='solid' and not o.semi then
		startgoing(e)
		return 'stop'
	elseif o.k=='player' then
		if d=='y' and v<0 and e.y-v-o.y>=7 then
		-- stop("\#1\fa"..e.y..','..o.y..','..v..','..e.y-v)
			e.standing=true
			return 'stop'
		elseif d=='x' and not o.pushingbubble then
			startgoing(e)
			return 'stop'
		end
	end
	return 'pass'
end

function startgoing(e)
	e.k='going'
	e.t=0
	e.update=updategoing
	e.draw=drawgoing
	updatable[e]=true
end

maxgrav=9
jumpvel=-7
grav=1

xvel=1
maxvelx=3

function playercollide(e, o, d, v)
	if o.k=='solid' then
		if not o.semi then return 'stop' end
		if d=='y' and v>0 and e.y==o.y-7 then
			return 'stop'
		end
	elseif o.k=='prize' then
		_update=function()
			_update=nil
			camera()
			_draw=function()
				print("\#1\fa\^dfyou win!", 50, 60)
			end
		end
	elseif o.k=='key' then
		gotkey = 0
		e.keys += 1
		startgoing(o)
	elseif o.k=='door' then
		if e.keys == 0 then
			return 'stop'
		end

		gotkey = 0
		e.keys -= 1
		startgoing(o)
	elseif o.k=='bubble' then
		if d=='x' then
			e.pushingbubble=true
			trymove(o, 'x', v)
		elseif d=='y' then
			if v<0 then
				trymove(o, 'y', v)
			elseif v>0 then
				trymove(o, 'y', v)
				return 'stop'
			end
		end
	end
	return 'pass'
end

function updateplayer(p)
	p.pushingbubble=false

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
				layer=2,
				update=updatebubble,
				collide=bubblecollide,
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

	if p.vx != 0 then
		if trymove(p, 'x', p.vx) then
		end
	end

	if p.grounded and btn(🅾️) then
		p.vy = jumpvel

		if p.bubble and p.bubble.standing then
			startgoing(p.bubble)
			p.bubble=nil
		end
		
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
	for ents in pairs(p.slots) do
		for o in pairs(ents) do
			if o.k=='chest' and overlaps(p,o) then
				p.chest=o
				break
			end
		end
	end
end

function overlaps(a,b)
	return a.x >= b.x - 7
	   and a.y >= b.y - 7
	   and a.x < b.x + 8
	   and a.y < b.y + 8
end

function trymove(e,d,v)
	local s = sgn(v)
	while v != 0 do
		local m = s*min(1,abs(v))
		v -= m

		emap_rem(e)
		e[d] += m
		emap_add(e)

		local seen={}

		for ents in pairs(e.slots) do
			for o in pairs(ents) do
				if not seen[o] and e!=o then
					seen[o]=true

					if overlaps(e,o) then

						if e:collide(o,d,m)=='stop' then
							emap_rem(e)
							e[d] -= m
							emap_add(e)
							return false
						end

					end
				end
			end
		end
	end

	return true
end

__gfx__
cccccccc0000660000bbbb0000000000666666651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc066666600b3333b002222220655555551000000100000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc66666666b337373b24444442655555551000000100000000000000000001000000000000000000000000000000000000000000000000000000000000
cccccccc66666666b331313b22222222655555551000000100666666666000000001000000000000000000000000000000000000000000000000000000000000
cccccccc66666666b333333b24499442655555551000000100666666666666000001000000000000000000000000000000000000000000000000000000000000
cccccccc066666660bb333b024444442655555551000000106666666666666660001000000000000000000000000000000000000000000000000000000000000
cccccccc0666666000bbbb0024444442655555551000000166666666666666660001000000000000000000000000000000000000000000000000000000000000
cccccccc000666000990099022222222555555551111111166666666666666660001000000000000000000000000000000000000000000000000000000000000
0000a000000000000444444000777700333333337777777766666666666666660001000000000000000000000000000000000000000000000000000000000000
000aa000000000000455554007000070333434436060606006666666666666660101010000000000000000000000000000000000000000000000000000000000
aaaaaaaa099999900455554070070007444434440000000006666666666666660111110000000000000000000000000000000000000000000000000000000000
aaaaaaaa090909000455554070700007444444440000000006666666666666600011100000000000000000000000000000000000000000000000000000000000
00aaaa00090000000455954070000007444444440000000000666666666666600001000000000000000000000000000000000000000000000000000000000000
00aaaa00090000000455554070000007444444440000000000006666666660000000000000000000000000000000000000000000000000000000000000000000
0aa00aa0000000000455554007000070444444440000000000000066000000000000000000000000000000000000000000000000000000000000000000000000
0a000aa0000000000444444000777700444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066666660666666606666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060000000600000006555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060777700607777006555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060700000607000006555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060700000607000006555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060000000600000006555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060000000600000006555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
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
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000425151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000000000000000000060700001000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000607000000000000061714040400000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000425151000000000000000000000000000000000000000000000000617100000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000000000000000000000000000000000006070000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000010000000000000000000000000000000000000000000000000000000000000000000000000006171000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000425151000000000000000000000000000000000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000060700000000000000000004200000000000000000000515151000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000001000000000000061710000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000425151000000000000000000000000000000000000000000000000000000004200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000000032004200000000000000800000000051510000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000420000000000000000000000000000000000000000000000000000000032004200000000000000810000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000425151000000000000000000000000000000000000000000000020000032002100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000404040404040404040404040404040404040404040404040404040404040404040404040404000000000000040404040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000515100000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060700051510042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061710000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006070000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006171000000000000000051510042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051510042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000310000000000000000000000000000000000000000000000000051510042
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414142
__gff__
0000080401020000000000000000000040102080010200000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
2400000000000000000000000000000024242424242424242424242424242424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000060700000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000161700000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000607000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000001617000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000024000000000000001100000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
2400000000000000000000000000000004151504040404040404040400000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024
