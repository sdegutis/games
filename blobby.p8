pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

poke(0x5F36, 0x8)

function _init()
	ents={}

	cx=0
	cy=0

	for y=0,63 do
		for x=0,127 do
			local s = mget(x,y)
			if fget(s, 0) then
				makesolid(s,x*8,y*8)
				mset(x,y,0)
			elseif fget(s, 3) then
				makeplayer(s,x*8,y*8)
				mset(x,y,0)
			elseif fget(s, 7) then
				for i=0,255 do
					if fget(i,7) and s!=i then
						bubblespr=i
						break
					end
				end

				makechest(s,x*8,y*8,tool_bubble)
				mset(x,y,0)
			end
		end
	end

	movecamera()
end

function _update()
	for e in all(ents) do
		if (e.update) e:update()
	end
end

function _draw()
	cls()
	camera(cx,cy)
	map()
	for e in all(ents) do
		if (e.draw) e:draw()
	end
end

function movecamera()
	cx = mid(0, 128*8-128, player.x+4-64)
	cy = mid(0,  64*8-128, player.y+4-64)
end

function makechest(s,x,y,tool)
	add(ents, {
		s=s,x=x,y=y,
		draw=drawsimple,
	})
end

function makeplayer(s,x,y)
	player = {
		s=s,d=1,
		x=x,y=y,
		vx=0,vy=0,
		draw=drawplayer,
		update=updateplayer,
	}
	add(ents, player)
end

function makesolid(s,x,y)
	add(ents, {
		s=s,x=x,y=y,
		draw=drawsimple,
	})
end

function drawplayer(p)
	spr(p.s, p.x, p.y, 1, 1, p.d<0)
	-- rect(p.x, p.y, p.x+7,p.y+7,2)
end

function drawsimple(e)
	spr(e.s, e.x, e.y)
end

speed=0.5
maxspeed=3
gravity=0.80
maxgrav=9
jumpspeed=7

function updateplayer(p)
	    if btn(➡️) then p.d= 1 p.vx=min(p.vx+speed,maxspeed)
	elseif btn(⬅️) then p.d=-1 p.vx=max(p.vx-speed,-maxspeed)
	elseif p.vx > speed then p.vx = p.vx - speed
	elseif p.vx < -speed then p.vx = p.vx + speed
	elseif p.vx != 0 then p.vx=0
	end
	if p.vx then
		if trymove(p, 'x', p.vx) then
			movecamera()
		end
	end

	if p.grounded and btn(🅾️) then
		p.vy = -jumpspeed
	else
		p.vy = min(p.vy + gravity, maxgrav)
	end

	if trymove(p, 'y', p.vy) then
		p.grounded=false
		movecamera();
	else
		p.grounded=p.vy>0
		p.vy = 0
	end
end

function trymove(e,d,v)
	local s = sgn(v)
	for i=s,v,s do
		e[d] += s

		for o in all(ents) do
			if o != e and e.x >= o.x - 7
								and e.y >= o.y - 7
								and e.x < o.x + 8
								and e.y < o.y + 8
			then
				e[d] -= s
				return false
			end
		end
	end
	return true
end

__gfx__
000000000000660000bbbb0000000000666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000010066666600b3333b002222220655555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000066666666b337373b24444442655555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000066666666b331313b22222222655555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000066666666b333333b24499442655555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666660bb333b024444442655555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001000666666000bbbb0024444442655555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666000990099022222222555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000404000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000040400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000404000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040000040400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040400000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404000000000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040400000000000000000
40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000
40400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000400000000000000000
00400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40000000404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000004040004000000000000000000000
00400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040404040000000000000000040
40000000000000000040404040404000000000000000000000000000000000000000000000000000000000000000004040004000000000000000000000000000
00400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
00000000000000000000000000000040404000000000000000000000000000000000000000000000000000000040400000000000000000000000000000000000
00400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000040
00000000000000000000000000000000000040404000000000000000000000000000000000000000000000404000000000000000000000000000000000000000
00400000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404000000000000000000000000000004040
00000000000000000000000000000000000000000040404000000000000000000000000000000040004040000000000000000000000000000000000000000000
00404000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000000404000
00000000000000000000000000000000000000000000004040404040404000000040404040404000000000000000000000000000000000000000000000000000
00004000000000000000000000000000000000000000000000000000000000000000000000000000000040404000000000000000000000000000004040000000
00000000000000000000000000000000000000000000000000000040404040404000000000000000000000000000000000000000000000000000000000000000
00004040000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000040400000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000040000000000000000000000000000000000000000000000000000000000000000000004040404000000000000000000000404040404000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004000000000000000000000000000000000000000000000000000000000000000000000000000004040404040404000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000040400000004040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000404040404040400000000000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000088001000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000004040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000101010100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010100000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000400000000000000000000000100000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000040000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000040000000000000000000000000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000040000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004040404040404040404040404000400000004040000040000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000404040404040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000004040404040404040400040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000040000040004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000400000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000
0000000000040400000000000000000000000004000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000000000000000000000000000000000000000
0000000000000404040404000400040004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000
