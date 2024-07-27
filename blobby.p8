pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

cam=2

poke(0x5F36, 0x8)

function _init()
	player=nil
	walls={}
	chests={}
	bubbles={}
	going={}

	chestspr=findsprite(2)
	bubblespr=findsprite(7)

	cx=0 cy=0

	for y=0,63 do
		for x=0,127 do
			local s = mget(x,y)
			if fget(s, 0) then
				makesolid(s,x*8,y*8)
				mset(x,y,0)
			elseif fget(s, 1) then
				makesolid(s,x*8,y*8,true)
				mset(x,y,0)
			elseif fget(s, 3) then
				makeplayer(s,x*8,y*8)
				mset(x,y,0)
			elseif fget(s, 7) then
				makechest(chestspr,x*8,y*8,'wand')
				mset(x,y,0)
			end
		end
	end

	movecamera()
end

function findsprite(f)
	for i=0,255 do
		if fget(i,f) then
			return i
		end
	end
end

function _update()
	updateplayer()
	for e in all(bubbles) do updatebubble(e) end
	for e in all(going)   do updategoing(e) end
end

function _draw()
	cls()
	camera(cx,cy)
	map()
	for e in all(walls)   do drawsimple(e) end
	for e in all(chests)  do drawsimple(e) end
	for e in all(bubbles) do drawsimple(e) end
	for e in all(going)   do drawgoing(e) end
	drawplayer()
end

function movecamera()
	if cam==1 then
		cx = mid(0, 128*8-128, player.x+4-64)
		cy = mid(0,  64*8-128, player.y+4-64)
	elseif cam==2 then
		cx = flr(player.x/128)*128
		cy = flr(player.y/128)*128
	end
end

function makechest(s,x,y,tool)
	add(chests, {
		k='chest',
		s=s,x=x,y=y,
		tool=tool,
	})
end

function makeplayer(s,x,y)
	player = {
		k='player',
		s=s,d=1,
		x=x,y=y,
		vx=0,vy=0,
	}
end

function makesolid(s,x,y,semi)
	add(walls, {
		k='solid',
		s=s,x=x,y=y,
		semi=semi,
	})
end

function drawplayer()
	local p = player
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
	e.t = e.t or 1
	e.t += 1
	if e.t == 20 then
		del(going,e)
	end
end

function drawgoing(e)
	if e.t % 4 < 2 then
		drawsimple(e)
	end
end

function updatebubble(e)
	e.x += cos(t()%2/2)*0.3
	e.y = e.y-0.2
end

function updateplayer()
	local p = player

	if btnp(❎) then
		if p.chest then
			del(chests,p.chest)
			add(going,p.chest)
			if p.chest.tool == 'wand' then
				p.wand=true
			end
			p.chest=nil
		elseif p.wand then
			if p.bubble then
				add(going, p.bubble)
				del(bubbles, p.bubble)
			end
	
			p.bubble = {
				x=p.x+10*p.d,
				y=p.y,
				s=bubblespr,
			}
	
			add(bubbles, p.bubble)
		end
	end

	if     btn(➡️) then p.d= 1 p.vx=min(p.vx+1, 3)
	elseif btn(⬅️) then p.d=-1 p.vx=max(p.vx-1,-3)
	elseif p.vx >  1 then p.vx = p.vx - 1
	elseif p.vx < -1 then p.vx = p.vx + 1
	elseif p.vx != 0 then p.vx=0
	end
	if p.vx then
		if trymove(p, 'x', p.vx) then
		end
	end

	if p.grounded and btn(🅾️) then
		p.vy = -7
	else
		p.vy = min(p.vy + 1, 9)
	end

	if trymove(p, 'y', p.vy) then
		p.grounded=false
	else
		p.grounded=p.vy>0
		p.vy = 0
	end

	p.chest=nil
	for o in all(chests) do
		if overlaps(p,o) then
			p.chest=o
			break
		end
	end

	movecamera()
end

function overlaps(a,b)
	return a.x >= b.x - 7
	   and a.y >= b.y - 7
	   and a.x < b.x + 8
	   and a.y < b.y + 8
end

function trymove(e,d,v)
	local s = sgn(v)
	for i=s,v,s do
		e[d] += s

		for o in all(walls) do
			if overlaps(e,o) then
				if not o.semi or d=='y' and v>0 and e.y==o.y-7 then
					e[d] -= s
					return false
				end
			end
		end
	end
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
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042
42000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
42000000000000000000520000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000040
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
