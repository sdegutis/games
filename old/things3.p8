pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
bg=1

function _init()
	palt(0,false)
	palt(bg,true)
	cur = cursormode()
	topicmode()
end

-->8
function topicmode()
	poke(0x5f2d, 1)

	local topic = "things "
	local t = 0
	local blinktime=20

	function draw()
		cls(bg)
		print(topic,0,20,10)
		
		if t < blinktime then
			color(2)
			local x = #topic * 4
			local y = 20
			rectfill(x,y,x+3,y+4)
		end
		
		drawlogo()
 	cur.draw()
	end
	
	function update()
		cur.update()
		
		t += 1
		if (t>blinktime*2) t=0
		
		if stat(30) then
			local k = stat(31)
			if k == "\b" then
				// backspace
				topic = sub(topic,0,#topic-1)
			elseif k == "\r" then
				entermode(topic)
			else
				// just add it to answer
				topic = topic .. k
			end
			t=0
		end
	end
	
	_draw=draw
	_update=update
end

-->8
function entermode(topic)
	poke(0x5f2d, 1)
	
	local answers = {}
	local answer = ""
	local done = 0
	local peekmode = 0
	local t = 0
	local typing = 0
	local typingp = 30
	
	local canfinish = false
	
	local doneb = makebutton(
		41,57,
		3,1,
		52,100
	)

	doneb.onclick = function()
		shufflemode(topic,answers)
	end

	function draw()
		cls(bg)
		print(topic,0,20,10)
		color(15)
		print("", 0, 30)
		print(done .. " people done")
		print("")
		if t < peekmode then
 		print(answer, 13, 42)
 		spr(0x10,0,40)
 	else
 		if t < typing then
 			print("typing...")
	 	else
 			print("waiting for input")
 		end
		end
		
		drawlogo()
		if (canfinish) doneb.draw()
 	cur.draw()
	end
	
	function update()
		cur.update()
		if (canfinish) doneb.update()
		t += 1
		if stat(30) then
			local k = stat(31)
			if k == "\b" then
				// backspace
				typing = t + typingp
				answer = sub(answer,0,#answer-1)
			elseif k == "\t" then
				// tab toggles peek mode
				peekmode = t + 10
			elseif k == "\r" then
				if answer != "" then
 			 // submitted answer
 				add(answers, {
 					str=answer,
 					col=#answers+1,
 					got=false,
 					mask=makemask(answer),
 				})
 				answer = ""
 				done += 1
 				peekmode = 0
 				typing = 0
 				
 				if #answers == 2 then
 					canfinish = true
 				end
				end
			else
				if (k==",") k="\n"
				// just add it to answer
				answer = answer .. k
				typing = t + typingp
			end
		end
	end
	
	_draw=draw
	_update=update
end

function makemask(str)
	local s = ""
	for i = 1,#str do
		s = s .. "*"
	end
	return s
end
-->8
function shufflemode(topic,answers)
	shuffle(answers)

	local lh = 12
 local speed = #answers*3
 local waitperiod = 5

	foreach(answers, maskit)

 function maxlen(a)
 	local l=0
 	for i = 1, #a do
 		if (#a[i].str > l) l = #a[i].str
 	end
 	return l
 end
 
 local w = 4 * maxlen(answers)
 local h = lh * #answers
 
 local offy = (100/2)-(h/2)+30
 local offx = (128/2)-(w/2)
 
	local state = 1
 local roty = 0
 local allowed = false
 local next = 1

 function update()
	 cur.update()
 	if state == 1 then
  	speed /= 1.09
  	if speed < 0.5 then
  		if roty == 0 then
  			state = 2
  			speed = 0
  		else
  			speed = 0.5
  		end
  	end
  	roty += speed
  	if (roty>=h)roty=0
  	if (speed==0) roty=0
 	elseif state == 2 then
 	 if stat(30) then
 			if stat(31) == " " then
 				local ans = answers[next]
 				if ans then
  				ans.word = ans.str
  				next += 1
  				if next > #answers then
  					state = 3
  				end
 				end
 			end
			end
 	elseif state == 3 then
 		if stat(34) == 1 then
 		 if allowed then
  		 allowed = false
  			local y = stat(33)
  			local i = round((y-offy)/lh)+1
  			local ans = answers[i]
  			if ans then
		 			ans.got = not ans.got
		 		end
	 		end
	 	else
	 		allowed = true
 		end
 	end
 end
 
 function drawblock(ny)
 	local ah = h - (lh - 6)
 	for i = 1, #answers do
	 	clip(offx, offy, w, ah)
 		local y = (i-1)*lh + offy
 		local x = 0 + offx
 		
 		local adjy = roty+y-(ny*h)
 		
 		local col = 7
 		if answers[i].got then
 			col = 5
 		end
 		
 		print(answers[i].word, x, adjy, col)
 		
 		if answers[i].got and ny==0 then
 			clip()
 			color(13)
 			local lw = 4*#answers[i].word
				line(x-1,adjy+2,x+lw-1,adjy+2)
			end
 	end
 end
 
 function draw()
 	cls(bg)
 	
 	drawbox()
 	
 	drawblock(0)
 	drawblock(1)
 	clip()
 	print(topic,0,20,10)
		drawlogo()
 	cur.draw()
 end
 
 function drawbox()
 	local ah = h - (lh - 6)
 	
 	local p = 5
 	
 	local x1 = offx-4-p
 	local y1 = offy-4-p
 	local x2 = offx+w-4+p
 	local y2 = offy+ah-4+p
 	
 	local which = 0x10
 	
 	for x = x1,x2,8 do
 		spr(0x05+which,x,y1)
 		spr(0x06+which,x,y2)
 	end
 	
 	for y = y1,y2,8 do
 		spr(0x07+which,x1,y)
 		spr(0x08+which,x2,y)
 	end
 	
 	rectfill(x1,y1,x1+7,y1+7,1)
 	rectfill(x2,y1,x2+7,y1+7,1)
 	rectfill(x1,y2,x1+7,y2+7,1)
 	rectfill(x2,y2,x2+7,y2+7,1)
 	
 	spr(0x01+which, x1,y1)
 	spr(0x02+which, x2,y1)
 	spr(0x03+which, x1,y2)
 	spr(0x04+which, x2,y2)
	end

 _update=update
 _draw=draw
end

function maskit(answer)
	answer.word = answer.mask
end

function round(n)
	return flr(n+0.49)
end

function shuffle(l)
	n = 0
	repeat
 	local ai = flr(rnd(#l))+1
 	local bi = flr(rnd(#l))+1
 	if not (ai == bi) then
  	local tmp = l[ai]
  	l[ai]=l[bi]
  	l[bi]=tmp
  	n += 1
 	end
	until n == #l * 10
end
-->8
function drawlogo()
		spr(0x09, 128/2-7*8/2, 0, 7, 2)
end
-->8
function cursormode()
 local cur = 0x2c

	function draw()
		local mx = stat(32)
		local my = stat(33)
		if fget(cur,1) then
			mx -= 4
			my -= 4
		end
		
		spr(cur,mx,my)
	end
	
	function update()
  changecur(stat(36))
	end
 
 function changecur(by)
 	cur += by
 	if not fget(cur,0) then
 		if by > 0 then
 			for i = 1,0x3f do
 				if (trycur(i)) break
 			end
 		else
 			for i = 0x3f,1,-1 do
 				if (trycur(i)) break
 			end
 		end
 	end
 end
 
 function trycur(i)
 	if fget(i,0) then
 		cur = i
 		return true
 	end
 end
 
	return {
		draw=draw,
		update=update,
	}
end
-->8
function makebutton(su,sp,sw,sh,x,y)

	local lastdown=false
	local pressed=false
	local button = {}

 button.draw =	function()
		local s = su
		if (pressed) s = sp
 	spr(s,x,y,sw,sh)
	end
	
	button.update = function()
		local lmouse = stat(34) == 1
		if not lastdown and inside() and not pressed and lmouse then
			pressed = true
		elseif pressed and not lmouse then
			pressed = false
			if inside() then
				button.onclick()
			end
		end
		lastdown = lmouse
	end
	
	function inside()
		local mx = stat(32)
		local my = stat(33)
		
		return	mx >= x 
  			and my >= y
  			and mx < x + sw*8
  			and my < y + sh*8
	end
	
	return button
end
__gfx__
00000000116666666666661165611111111116566666666611111111656111111111165611b1c1e1911aaaaa1e111e1bbbbb1d111d11ccc111fff1191e1c1b11
00000000165555555555556165611111111116565555555511111111656111111111165611b1c1e191111a111e111e111b111dd11d1c111c1f111f191e1c1b11
00700700655666666666655665611111111116566666666611111111656111111111165611b1c1e191111a111e111e111b111d1d1d1c11111f1111191e1c1b11
00077000656111111111165665611111111116561111111111111111656111111111165611b1c1e191111a111eeeee111b111d11dd1c111111ff11191e1c1b11
00077000656111111111165665611111111116561111111111111111656111111111165611b1c1e191111a111e111e111b111d111d1c1ccc1111f1191e1c1b11
00700700656111111111165665566666666665561111111166666666656111111111165611b1c1e191111a111e111e111b111d111d1c111c11111f191e1c1b11
00000000656111111111165616555555555555611111111155555555656111111111165611b1c1e191111a111e111e111b111d111d1c111c1f111f191e1c1b11
00000000656111111111165611666666666666111111111166666666656111111111165611b1c1e191111a111e111e1bbbbb1d111d11ccc111fff1191e1c1b11
11111111189abc2dd2cba98181111111111111188d2cba9811111111811111111111111811b1c1e191111111111111111111111111111111111111191e1c1b11
11ffff11d11111111111111d91111111111111191111111111111111911111111111111911b1c1e119999999999999999999999999999999999999911e1c1b11
1f7777f12111111111111112a11111111111111a1111111111111111a11111111111111a11b1c11e1111111111111111111111111111111111111111e11c1b11
f773b77fc11111111111111cb11111111111111b1111111111111111b11111111111111b11b11c11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11c11b11
f773377fb11111111111111bc11111111111111c1111111111111111c11111111111111c111b1cc111111111111111111111111111111111111111111cc1b111
1f7777f1a11111111111111a211111111111111211111111111111112111111111111112111b111cccccccccccccccccccccccccccccccccccccccccc111b111
11ffff119111111111111119d11111111111111d1111111111111111d11111111111111d1111bb11111111111111111111111111111111111111111111bb1111
111111118111111111111118189abc2dd2cba981111111118d2cba988111111111111118111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111111
0000000011000000000000110111111111111110000000001111111101111111111111101bbbbbbbbbbbbbbbbbbbbbb1100111111ca1aa111111333100000000
000000001011111111111101011111111111111011111111111111110111111111111110b33333333333333333333335107011119aa1a1111113111300000000
000000000111111111111110011111111111111011111111111111110111111111111110b333773377737337377733351077011111aaaa111199991100000000
000000000111111111111110011111111111111011111111111111110111111111111110b333737373737737377733351077701111aaa11119a99a9100000000
000000000111111111111110011111111111111011111111111111110111111111111110b3337373737373773733333510777701111911119aa99aa900000000
000000000111111111111110011111111111111011111111111111110111111111111110b3337733777373373777333510777001111111119999999900000000
000000000111111111111110101111111111110111111111111111110111111111111110b3333333333333333333333510700111111111119a9999a900000000
000000000111111111111110110000000000001111111111000000000111111111111110155555555555555555555551100111111111111119aa9a9100000000
000000000000000000000000000000000000000000000000000000000000000000000000155555555555555555555551b3b3b3b3111011111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000053333333333333333333333b1aa99aa1110701111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000053337733777373373777333b1eeeeee1101110111aa9111100000000
00000000000000000000000000000000000000000000000000000000000000000000000053337373737377373777333b1e1e1ee1071117011919aa9100000000
00000000000000000000000000000000000000000000000000000000000000000000000053337373737373773733333b1eeeeee1101110111919999100000000
00000000000000000000000000000000000000000000000000000000000000000000000053337733777373373777333b1ee22ee1110701111999119100000000
00000000000000000000000000000000000000000000000000000000000000000000000053333333333333333333333b1eeeeee1111011111111111100000000
0000000000000000000000000000000000000000000000000000000000000000000000001bbbbbbbbbbbbbbbbbbbbbb118811881111111111111111100000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010103000000000000000000000000000303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000