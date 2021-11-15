pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- teamwork:
--   game that sarah and abbey
--   can play together
--   to practice teamwork
--   in a slightly fun way

skiptitle=true
flipview=false

function _init()
	level=1
	starttitle()
	if(skiptitle)startgame()
end

function starttitle()
	progress = 0
	_draw=drawtitle
	_update=updatetitle
end

function nextlevel()
	level+=1
	starttitle()
end

function drawtitle()
	cls(1)
	print("level "..level,50,50,7)
	local w = progress * (80-45)
	line(45,60,80  ,60,0)
	line(45,60,45+w,60,2)
end

function updatetitle()
	progress += (1/30/3) -- 3 sec
	if progress >= 1 then
		startgame()
	end
end

-->8
-- game

function startgame()
	_draw=drawgame
	_update=updategame
	
	players={}
	add(players, makeplayer(0))
	add(players, makeplayer(1))
	
	parselevel()
end

function drawgame()
	cls(1)
	drawview(players[1])
	drawview(players[2])
end

function drawview(p)
	local x = p.n * 65
	local y = 0
	local w = 63
	local h = 127
	
	if flipview then
		x,y = y,x
		w,h = h,w
	end
	
	clip(x,y,w,h)
	
	-- start where the player is
	local offx = p.x
	local offy = p.y
	
	-- adjust for halfscreen
	offx -= x
	offy -= y
	
	-- center it in view
	offx -= flr(w/2)-2
	offy -= flr(h/2)-2
	
	-- ????
	-- still don't understand this
	-- but it works.
	--offx = mid(-x, offx, 128-x+w)
	--offy = mid(-y, offy, 128-vy)
	
	camera(offx, offy)
	
	map(mapx, mapy,0,0,32,32)
	
	local dplayers = {unpack(players)}
	del(dplayers,p)
	add(dplayers,p)
	foreach(dplayers, drawplayer)
	
	camera()
	clip()
	
	print("x="..x)
	print("y="..y)
end

function updategame()
	foreach(players, updateplayer)
end

function parselevel()
	mapx, mapy = getmapspot()
	
	for y=0,31 do
		for x=0,31 do
			local s = mget(x,y)
			if s == 16 then
				makestartspot(1,x,y)
			elseif s == 32 then
				makestartspot(2,x,y)
			end
		end
	end
end

function makestartspot(pn,x,y)
	players[pn].x = x*8
	players[pn].y = y*8
	mset(x,y, mget(x+1,y))
end

function getmapspot()
	local l = level-1
	if l < 4 then
		return l*32, 0
	else
		return (l-4)*32, 32
	end
end

-->8
-- players

function makeplayer(n)
	return {
		n=n,
		s=(n+1)*16,
		x=0,
		y=0,
	}
end

function drawplayer(p)
	spr(p.s, p.x, p.y)
end

function updateplayer(p)
	if(btn(➡️,p.n)) p.x+=10
	if(btn(⬅️,p.n)) p.x-=10
	if(btn(⬆️,p.n)) p.y-=10
	if(btn(⬇️,p.n)) p.y+=10
	
	if btnp(❎,p.n) then
		flipview=not flipview
	end
end

__gfx__
0000000033bab3333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003a9bab333333333300888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007003abb9b933333333308808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770003bbb9ab33333333308000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000339bbb333333333308808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333453333333333300888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333453333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000334445333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800008888000088880000888800008888000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
08f1f18008f1f18008f1f18008888880088888800888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffffff00ffffff00ffffff00f8888f00f8888f00f8888f000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f88f0000f88f0000f88f0000ffff0000ffff0000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00fccf0000fccf0000fccf0000fccf0000fccf0000fccf0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000440000004400000044000000640000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005d00000005000000d00000005d000000050000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200002222000000000000222200002222000022220000000000000000000000000000000000000000000000000000000000000000000000000000000000
02f1f12002f1f1200022220002222220022222200222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffffff00ffffff002f1f12002222220022222200222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
02f88f2002f88f200ffffff002222220022222200222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
02eeee2002eeee2002f88f2002222220022222200222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
02feef0002feef0002eeee00022eef00022eef00022eef0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeee0000eeee0002feef0000eeee0000e5ee0000ee5e0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050500000050000005000000500500000050000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102100202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202022002020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020202020202020202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
