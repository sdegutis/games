pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
poke(0x5f2d, 1)

t=0
lems={}
walls={}
mx=0
my=0

for y=1,64 do
	walls[y]={}
	for x=1,64 do
		walls[y][x]=0
	end
end

function _draw()
	cls()
	
	for l in all(lems) do
		drawdot(l.x,l.y,10)
	end
 
 for y=1,64 do
 	for x=1,64 do
 		local w = walls[y][x]
 		if w == 1 then
 			drawdot(x,y,2)
 		end
 	end
 end
	
	spr(1,mx,my)
end

function drawdot(x,y,c)
 local px = x*2
 local py = y*2
 rectfill(px,py,px+1,py+1,c)
end

function _update()
	t+=1
	t%=30
	
	mx=stat(32)
	my=stat(33)
	
	if t==0 then
		add(lems,{x=32,y=0})
	end
	
	for l in all(lems) do
		if outside(l) then
			del(lems,l)
		else
 		local w = walls[flr(l.y)+1][flr(l.x)]
 		if w == 0 then
  		l.y += 0.1
  	elseif w == 1 then
  		l.x += 0.1
  	end
 	end
	end
	
	local butt = stat(34)
	
	if butt == 1 then
		local x = flr(mx/2)
		local y = flr(my/2)
		
		walls[y][x] = 1
	elseif butt == 2 then
		for y=1,64 do
  	for x=1,64 do
  		walls[y][x]=0
  	end
  end
	end
end

function outside(l)
	return l.x < 0
	    or l.y < 0
	    or l.x > 63
	    or l.y > 63
end

__gfx__
00000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700577500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000577750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000577775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700577755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000575500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
