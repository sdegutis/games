pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	poke(0x5f2d, 1)
	memset(0x1000, 0, 0x1000)
end

function openaddr()
	for i = 0x1000,0x1fff,4 do
		local n = peek4(i)
		if n == 0 then return i end
	end
end

function set(addr,x,y,c,m)
	local bx = band(0b01111111, x)
	local by = rotl(band(0b01111111, y), 7)
	local bc = rotl(band(0b00001111, c), 14)
	local bm = rotl(band(0b00000001, m and 1 or 0), 18)
		print(shl(band(0b00000001, m and 1 or 0), 18))
		flip()
	poke4(addr, bor(bc,bor(by,bx)))
end

function get(addr)
	local n = peek4(addr)
	local x = band(0b01111111,n)
	local y = band(0b01111111,rotr(n,7))
	local c = band(0b00001111,rotr(n,14))
	local m = band(0b00000001,rotr(n,18)) == 0b1
	return x,y,c,m
end

function makenew(x,y,c,m)
	set(openaddr(), x,y,c,m)
end

function _draw()
	cls(1)
	
	for i = 0x1000, openaddr()-1, 4 do
		local x,y,c,m = get(i)
		pset(x,y,c)
	end
	
	spr(1,mx,my)
	
	color(2)
	print(openaddr())
end

function _update()
	mx=stat(32)
	my=stat(33)
	down=stat(34)==1
	pressed=down and not lastdown
	lastdown=down
	
	if down then
		makenew(mx,my,flr(rnd(16)),true)
	end
	
	for i = 0x1000, openaddr()-1, 4 do
		local x,y,c,m = get(i)
		if m then
	 	y += 1
			set(i, x,y,c,m)
		end
	end
end
__gfx__
00000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000