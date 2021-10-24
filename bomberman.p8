pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- core

players={}
bombs={}
bricks={}
flames={}
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
	local s = p.s
	if (p.dy < 0) s+=3
	
	if p.mx!=0 or p.my!=0 then
		s+=1
		if (time()%1<0.5) s+=1
	end
	
	local fx = p.dx < 0
	
	spr(s,x,y,1,1,fx)
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
	-- (for d-actions while still)
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
	
	-- you're allowed to move
	--  out of bombs placed on
	--  the spot you were on
	--  before you started moving.
	p.inbomb = getbombon(p)
	
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
 -- todo: limit bombs with "if"
	makebomb(p)
end

function collideplayer(p,x,y)
	for i=1,#bricks do
		col_player_solid(p,bricks[i],x,y)
	end
	for i=1,#bombs do
		local b = bombs[i]
		if b != p.inbomb then
			col_player_solid(p,b,x,y)
		end
	end
end

function col_player_solid(p,b,x,y)
 -- get center of sprite
	local cx = p.x + 4
	local cy = p.y + 4
	
	-- get center of moving edge
	local chx = cx + x*2
	local chy = cy + y*2
	
	-- get two corners
	local x1 = chx - y*2
	local x2 = chx + y*2
	local y1 = chy - x*2
	local y2 = chy + x*2
	
	-- bricks and bombs stop you
	if didcol(b,x1,y1)
	or didcol(b,x2,y2)
	then
		p.x += -x
		p.y += -y
	end
end

function getbombon(p)
 local px = round(p.x/8)*8
 local py = round(p.y/8)*8
 
	for i=1,#bombs do
		local b = bombs[i]
		if b.x==px and b.y==py then
			return b
		end
	end
end

-->8
-- bombs


function makebomb(p)
 local sec=3
 local x = round(p.x/8)*8
 local y = round(p.y/8)*8
	add(bombs,{
		x=x,
		y=y,
		range=p.pwr,
		t=sec*30,
	})
end

function updatebomb(b)
	b.t -= 1
	if b.t == 0 then
		del(bombs,b)
		makeflames(b)
	end
end

function drawbomb(b)
	local s = 7
	if (time()%1 < 0.5) s=8
	spr(s, b.x, b.y)
end

function makeflames(b)
	
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
	if b.stone then return end
	
	spr(16,b.x,b.y)
end

-->8
-- util

function didcol(e,x,y)
	return x >= e.x
	   and y >= e.y
	   and x <= e.x+7
	   and y <= e.y+7
end

function round(n)
 if n%1 < 0.5 then
 	return flr(n)
 else
 	return ceil(n)
 end
end

-->8
-- flames

function drawflame(b)
	spr(9, b.x, b.y)
	
	b.t -= 1
	if b.t == 0 then
		del(bombs, b)
	end
end

__gfx__
00000000008888000088880000000000008888000088880000000000000a8000000a98007cc7c7cc333333330000000000000000000000000000000000000000
0000000008f1f18008f1f1800088880008888880088888800088880000009000000ccc00c7cccc77333333330999999000000000000000000000000000000000
007007000ffffff00ffffff008f1f1800f8888f00f8888f008888880000cc00000c7ccc07cccc7cc33333333099ddd9000000000000000000000000000000000
0007700000f88f0000f88f000ffffff000ffff0000ffff000f8888f000c7cc000c7ccccccccc7cc733333333099d449000000000000000000000000000000000
0007700000cccc000fcccc0000f88f0000cccc000fcccc0000ffff000c7cccc00cccccccc77cc7cc333333330944449000000000000000000000000000000000
0070070000fccf00000ccf0000ccccf000fccf00000ccf0000ccccf00cccccc00ccccccc7ccc7c7c333333330944449000000000000000000000000000000000
00000000000440000054400000f44500000440000054400000f4450000cccc0000ccccc0c777cc7c333333330999999000000000000000000000000000000000
00000000000505000000500000050000000505000000500000050000000cc000000ccc00cc7cccc7333333330000000000000000000000000000000000000000
fffffff4004444000044440000000000004444000044440000000000000000000000000000000000666666650000000000000000000000000000000000000000
ff44444204f1f14004f1f14000444400044444400444444000444400cc777c770000000000000000655555550000000000000000000000000000000000000000
f4fff4420ffffff00ffffff004f1f1400f4444f00f4444f00444444077ccc77c77ccc77c00000000655555550000000000000000000000000000000000000000
f4f4424200f88f0000f88f000ffffff000ffff0000ffff000f4444f07777cccc7777cccc7777cccc655555550000000000000000000000000000000000000000
f4f44242009999000f99990000f88f00009999000f99990000ffff00ccc7c7ccccc7c7ccccc7c7cc655555550000000000000000000000000000000000000000
f442224200f99f0000099f00009999f000f99f0000099f00009999f077ccc77777ccc77700000000655555550000000000000000000000000000000000000000
f4444422000440000054400000f44500000440000054400000f44500cc777cc70000000000000000655555550000000000000000000000000000000000000000
42222222000505000000500000050000000505000000500000050000000000000000000000000000555555550000000000000000000000000000000000000000
000000000022220000222200000000000022220000222200000000000cc77c7000c77c0000077000000000000000000000000000000000000000000000000000
0000000002f1f12002f1f12000222200022222200222222000222200077c7cc0007c7c00000c7000000000000000000000000000000000000000000000000000
000000000ffffff00ffffff002f1f1200f2222f00f2222f00222222007cc7c7000cc7c00000c7000000000000000000000000000000000000000000000000000
0000000000f88f0000f88f000ffffff000ffff0000ffff000f2222f0077c7c70007c7c00000c7000000000000000000000000000000000000000000000000000
0000000000eeee000feeee0000f88f0000eeee000feeee0000ffff0007cc7c7000cc7c00000c7000000000000000000000000000000000000000000000000000
0000000000feef00000eef0000eeeef000feef00000eef0000eeeef007c7cc7000c7cc000007c000000000000000000000000000000000000000000000000000
00000000000440000054400000f44500000440000054400000f445000c7c7c70007c7c00000c7000000000000000000000000000000000000000000000000000
000000000005050000005000000500000005050000005000000500000c7c77c0007c7700000c7000000000000000000000000000000000000000000000000000
00000000008888000088880000000000008888000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008f1f18008f1f18000888800088888800888888000888800000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffffff00ffffff008f1f1800f8888f00f8888f008888880000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f88f0000f88f000ffffff000ffff0000ffff000f8888f0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cccc000fcccc0000f88f0000cccc000fcccc0000ffff00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000fccf00000ccf0000ccccf000fccf00000ccf0000ccccf0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000440000054400000f44500000440000054400000f44500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000505000000500000050000000505000000500000050000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888777777888eeeeee888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88778887788ee888ee88888888888888888888888888888888888888888888ff818ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8777778778eeeee8ee88888e88888888888888888888888888888888888888ff171ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8777888778eeee88ee8888eee8888888888888888888888888888888888888ff1711f188222222888888222888228882888822288888
888eee8e8ee8eeee8eee8777877778eeeee8ee88888e88888888888888888888888888888888888888ff17171718822228888228222888882282888222288888
888eee888ee8eee888ee8777888778eee888ee888888888888888888888888888888888888888888888117777718828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8777777778eeeeeeee888888888888888888888888888888888888888888881717777718888888888888888888888888888888888888
11111e1111ee11ee1eee1e11111116161111111111111bbb1b111bbb117116661111161611171ccc11717777771c111111111111111111111111111111111111
11111e111e1e1e111e1e1e11111116161111177711111b111b111b1b171116161111161611711c1c11171177711c111111111111111111111111111111111111
11111e111e1e1e111eee1e11111111611111111111111bb11b111bb1171116661111116111711ccc1117117771cc111111111111111111111111111111111111
11111e111e1e1e111e1e1e11111116161111177711111b111b111b1b171116111111161611711c1c111711111c1c111111111111111111111111111111111111
11111eee1ee111ee1e1e1eee111116161111111111111b111bbb1b1b117116111171161617111ccc117117171ccc111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e1111ee11ee1eee1e11111116161111111111111bbb1b111bbb117116661111161611171ccc117117171ccc111111111111111111111111111111111111
11111e111e1e1e111e1e1e11111116161111177711111b111b111b1b171116161111161611711c1c111711711c1c111111111111111111111111111111111111
11111e111e1e1e111eee1e11111116661111111111111bb11b111bb1171116661111166611711ccc111717771ccc111111111111111111111111111111111111
11111e111e1e1e111e1e1e11111111161111177711111b111b111b1b171116111111111611711c1c111711711c1c111111111111111111111111111111111111
11111eee1ee111ee1e1e1eee111116661111111111111b111bbb1b1b117116111171166617111ccc117117171ccc111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bb11bb11171166611661666166611661111117711111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1b1b1b1b1b1711161616161666161616111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1b1b1b1b1711166116161616166116661111177111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1b1b1b1b1b1711161616161616161611161171117111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1b1bbb1bbb1171166616611616166616611711117711111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611111616111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161617771616111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111116111111161111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161617771616117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611111616171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611111616111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161617771616111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166611111666111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111617771116117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166611111666171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616111666116616661661166616161111166611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616111616161116111616161616161777161611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616111666161116611616166116661111166611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161116111616161116111616161611161777161111711111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161116661616116616661666166616661111161117111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661661116616661111166611111666161616661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616161116111777161611111616161616161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166116661616161116611111166611111666161616611111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616161616111777161111111611166616161171111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616166616661111161111711611166616161711111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661616166616111166166116661661116611111ccc1ccc1c1111cc1ccc111111111111111111111111111111111111111111111111111111111111
1111111116111616161616111616161611611616161117771c111c1c1c111c111c11111111111111111111111111111111111111111111111111111111111111
1111111116611161166616111616161611611616161111111cc11ccc1c111ccc1cc1111111111111111111111111111111111111111111111111111111111111
1111111116111616161116111616161611611616161617771c111c1c1c11111c1c11117111111111111111111111111111111111111111111111111111111111
1111111116661616161116661661166616661616166611111c111c1c1ccc1cc11ccc171111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666111111661666116617171ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111116117771611161116111171111c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111611111166616611611177711cc1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111116117771116161116111171111c1c1c1171111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111161111116611666116617171ccc1ccc1711111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111771117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111171111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111177111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111171111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111771117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116161666166116661666166616661166166616661171166611711111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161161161116161616166616161711161611171111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161666161616661161166116611616161616611711166111171111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161611161616161161161116161616161616161711161611171111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111111661611166616161161166616661661161616661171166611711111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116611666166616161666116616661666117116661171111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161616161616661616171116161117111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161661166616161661161616161661171116611117111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616661616161616161616171116161117111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616161616661666166116161666117116661171111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bbb1171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1b1b1711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bb11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111b1b111b1b1711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bb11b111b1b1171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228882822282828888888888888888888888888888888888888888888888888222828282288882822282288222822288866688
82888828828282888888888288828828888282828888888888888888888888888888888888888888888888888282828288288828828288288282888288888888
82888828828282288888822282228828822282228888888888888888888888888888888888888888888888888222822288288828822288288222822288822288
82888828828282888888828882888828828888828888888888888888888888888888888888888888888888888282888288288828828288288882828888888888
82228222828282228888822282228288822288828888888888888888888888888888888888888888888888888222888282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

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
