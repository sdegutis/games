pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- core

players={}
bombs={}
bricks={}
debug=nil

-- interactions
--    pl bm it br st xp
-- pl -- sp gt sp sp ot
-- bm sp sp rm sp sp bl
-- xp ot bl rm im sp --

function _init()
	makeplayer(0,8,8)
	makeplayer(1,104,104)
	decodemap()
	spawnbricks()
end

function _draw()
	cls(0)
	map()
	foreach(bricks,drawbrick)
	foreach(bombs,drawbomb)
	foreach(players,drawplayer)
	
	if debug then
	 if debug.pset then
	 	pset(debug.x1, debug.y1, 11)
	 	pset(debug.x2, debug.y2, 11)
	 else
		 local y=1
	 	for k,v in pairs(debug) do
	 	 rectfill(0,y-1,20,y+5,1)
		 	print(tostr(k)..'='..tostr(v), 0, y, 7)
		 	y += 8
		 end
	 end
	end
end

function _update()
	foreach(players,updateplayer)
	foreach(bombs,updatebomb)
end

function didcol(e,x,y)
	return x >= e.x
	   and y >= e.y
	   and x <= e.x+7
	   and y <= e.y+7
end

-->8
-- players


function makeplayer(n,x,y)
	add(players,{
		n=n,
		x=x,
		y=y,
		mx=0,
		my=0,
		dx=0,
		dy=0,
		vx=0,
		vy=0,
		vel=0.5,
		spd=1,
		pwr=2,
		s=n*16+1,
	})
end

function drawplayer(p)
	for i=1,15 do pal(i,1) end
	_drawplayer(p,p.x+1,p.y+1)
	pal()
	_drawplayer(p,p.x,p.y)
end

function _drawplayer(p,x,y)
	spr(p.s,x,y)
end

function updateplayer(p)
	if btnp(❎,p.n) then
		placebomb(p)
	end
	
 -- set moving dir if any
	if     btn(⬅️,p.n)then p.mx=-1
	elseif btn(➡️,p.n)then p.mx=1
	else   p.mx=0 end
	if     btn(⬆️,p.n)then p.my=-1
	elseif btn(⬇️,p.n)then p.my=1
	else   p.my=0 end
	
	-- set action dir if moving
	-- (for actions while still)
	if p.mx != 0 or p.my != 0 then
		p.dx = p.mx
		p.dy = p.my
	end
	
	-- adjust velocity
	if p.mx != 0 then
		p.vx += p.mx * p.vel
		if (p.vx < -p.spd) p.vx=-p.spd
		if (p.vx >  p.spd) p.vx= p.spd
	elseif p.vx != 0 then
		p.vx -= p.vel * sgn(p.vx)
	end
	if p.my != 0 then
		p.vy += p.my * p.vel
		if (p.vy < -p.spd) p.vy=-p.spd
		if (p.vy >  p.spd) p.vy= p.spd
	elseif p.vy != 0 then
		p.vy -= p.vel * sgn(p.vy)
	end
	
	-- try moving
	for x=1,ceil(abs(p.vx)) do
	 local mv = sgn(p.vx)
		p.x += mv
		collideplayer(p,mv,0)
	end
	for y=1,ceil(abs(p.vy)) do
	 local mv = sgn(p.vy)
		p.y += mv
		collideplayer(p,0,mv)
	end
end

function placebomb(p)
	makebomb(p.x, p.y, p.pwr, 3)
end

function collideplayer(p,x,y)
	for i=1,#bricks do
		col_player_solid(p,bricks[i],x,y)
	end
	for i=1,#bombs do
		col_player_solid(p,bombs[i],x,y)
	end
end

function col_player_solid(p,b,x,y)
 -- get center of sprite
	local cx = p.x + 4
	local cy = p.y + 4
	
	-- get center of moving edge
	local chx = cx + x*2
	local chy = cy + y*2
	
	local x1 = chx - y*2
	local x2 = chx + y*2
	
	local y1 = chy - x*2
	local y2 = chy + x*2
	
	debug = {
		pset=true,
	 x1=x1,x2=x2,
	 y1=y1,y2=y2,
	}
	
	if didcol(b,x1,y1)
	or didcol(b,x2,y2)
	then
		p.x += -x
		p.y += -y
	end
end

-->8
-- bombs


function makebomb(x,y,pwr,sec)
	add(bombs,{
		x=x,
		y=y,
		range=pwr,
		exploding=false,
		t=sec*30,
	})
end

function updatebomb(b)
end

function drawbomb(b)
	-- test
	
	if t() < 3.2 then
	
	local s = 4
	if t() % 1 < 0.5 then s=5 end
	local now=t()>3
	if now then s=6 end
	
	if now then
		spr(6,40,40)
		local z = min(4,flr((t()-3)*40))
		for x=1,z do
			spr(22,40+(x*8),40)
			spr(22,40-(x*8),40)
		end
		for y=1,z do
			spr(38,40,40+(y*8))
			spr(38,40,40-(y*8))
		end
	else
		for i=1,15 do pal(i,1) end
		spr(s,41,41)
		pal()
		spr(s,40,40)
	end
	
	end
	-- test
end

-->8
-- bricks

function decodemap()
	for y=0,14 do
		for x=0,14 do
			local s=mget(x,y)
			local solid=fget(s,0)
			if solid then
				add(bricks,{
					x=x*8,
					y=y*8,
					stone=true,
				})
			end
		end
	end
end

function spawnbricks()
	for x=3,11 do
		for y=1,13 do
			makebrick(x,y)
		end
	end
	for x=1,13 do
		for y=3,11 do
			makebrick(x,y)
		end
	end
end

function makebrick(x,y)
	if rnd() < 0.8 then
	 local s = mget(x,y)
	 local solid = fget(s,0)
		if not solid then
			add(bricks,{
				x=x*8,
				y=y*8,
			})
		end
	end
end

function drawbrick(b)
	--if b.stone then return end
	
	spr(16,b.x,b.y)
end

__gfx__
00000000008888000088880000888800000000000088880000000000000a8000000a98007cc7c7cc333333330000000000000000000000000000000000000000
0000000008f1f1800888888008f1f18000888800088888800088880000009000000ccc00c7cccc77333333330999999000000000000000000000000000000000
007007000ffffff00f8888f00ffffff008f1f1800f8888f008888880000cc00000c7ccc07cccc7cc33333333099ddd9000000000000000000000000000000000
0007700000f88f0000ffff0000f88f000ffffff000ffff000f8888f000c7cc000c7ccccccccc7cc733333333099d449000000000000000000000000000000000
0007700000cccc0000cccc000fcccc0000f88f000fcccc0000ffff000c7cccc00cccccccc77cc7cc333333330944449000000000000000000000000000000000
0070070000fccf0000fccf00000ccf0000ccccf0000ccf0000ccccf00cccccc00ccccccc7ccc7c7c333333330944449000000000000000000000000000000000
0000000000044000000440000054400000f445000054400000f4450000cccc0000ccccc0c777cc7c333333330999999000000000000000000000000000000000
00000000000505000005050000005000000500000000500000050000000cc000000ccc00cc7cccc7333333330000000000000000000000000000000000000000
fffffff4004444000044440000444400000000000044440000000000000000000000000000000000666666650000000000000000000000000000000000000000
ff44444204f1f1400444444004f1f140004444000444444000444400cc777c770000000000000000655555550000000000000000000000000000000000000000
f4fff4420ffffff00f4444f00ffffff004f1f1400f4444f00444444077ccc77c77ccc77c00000000655555550000000000000000000000000000000000000000
f4f4424200f88f0000ffff0000f88f000ffffff000ffff000f4444f07777cccc7777cccc7777cccc655555550000000000000000000000000000000000000000
f4f4424200999900009999000f99990000f88f000f99990000ffff00ccc7c7ccccc7c7ccccc7c7cc655555550000000000000000000000000000000000000000
f442224200f99f0000f99f0000099f00009999f000099f00009999f077ccc77777ccc77700000000655555550000000000000000000000000000000000000000
f444442200044000000440000054400000f445000054400000f44500cc777cc70000000000000000655555550000000000000000000000000000000000000000
42222222000505000005050000005000000500000000500000050000000000000000000000000000555555550000000000000000000000000000000000000000
000000000022220000222200002222000000000000222200000000000cc77c7000c77c0000077000000000000000000000000000000000000000000000000000
0000000002f1f1200222222002f1f120002222000222222000222200077c7cc0007c7c00000c7000000000000000000000000000000000000000000000000000
000000000ffffff00f2222f00ffffff002f1f1200f2222f00222222007cc7c7000cc7c00000c7000000000000000000000000000000000000000000000000000
0000000000f88f0000ffff0000f88f000ffffff000ffff000f2222f0077c7c70007c7c00000c7000000000000000000000000000000000000000000000000000
0000000000eeee0000eeee000feeee0000f88f000feeee0000ffff0007cc7c7000cc7c00000c7000000000000000000000000000000000000000000000000000
0000000000feef0000feef00000eef0000eeeef0000eef0000eeeef007c7cc7000c7cc000007c000000000000000000000000000000000000000000000000000
0000000000044000000440000054400000f445000054400000f445000c7c7c70007c7c00000c7000000000000000000000000000000000000000000000000000
000000000005050000050500000050000005000000005000000500000c7c77c0007c7700000c7000000000000000000000000000000000000000000000000000
00000000008888000088880000888800000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008f1f1800888888008f1f180008888000888888000888800000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffffff00f8888f00ffffff008f1f1800f8888f008888880000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f88f0000ffff0000f88f000ffffff000ffff000f8888f0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cccc0000cccc000fcccc0000f88f000fcccc0000ffff00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000fccf0000fccf00000ccf0000ccccf0000ccf0000ccccf0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044000000440000054400000f445000054400000f44500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000505000005050000005000000500000000500000050000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a0a0a0a0a0a0a0a0a0a0a0a0a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
