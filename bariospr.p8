pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
points = {}
sprs = {6,22,38,54}
x = 0

h = 12
spd = 3
dist = 1
offset = 2

function _init()
end

function _update()
	x += spd
	local my = abs(cos(time())) * h
	local y = 50 - my - 5
	
	push(x,y)
	
	if x > 100 then
		--points = {}
		x = 0
	end
end

function _draw()
	cls()
	rectfill(0, 50, 127, 60, 4)
	for i = 1,4 do
		local s = sprs[i]
		local o = points[(i-1) * dist + 1]
		if o then
			spr(s+offset, o.x, o.y)
		end
	end
	
	pal(3, ceil(time() * 10 % 15) + 1)
	rectfill(108, 20, 108, 49, 3)
	pal()
end

function push(x, y)
	local o = {x=x,y=y}
	for i = #points,1,-1 do
		points[i+1] = points[i]
	end
	points[1] = o
end

__gfx__
000000000000000099999aaa0000000000000000000000000000000000000000000000004dddddd444244444f4f4f4f40088880056666665008788000cccccc0
00000000008880009999999a0000000000000000006660000099990000ccc00000cccc00d424444d44244444f4f4f4f4078788706444444608777880c111111c
007007000888ee0002000020000000000000000006668800099aa9900ccc88000cc77cc0d222222d222222224f4f4f4f888888886444444678878878c12c2c1c
000770000888ee8800d22d000000888880000000066688660999aa900ccc88cc0ccc77c0d444424d444442444f4f4f4f787888876444444677888777c1c2c21c
0007700088f1ff1000d22d00000888888880000066f1ff10099a9a90ccf1ff100cc7c7c0d444424d44444244f4f4f4f4888878886444444678878878c111111c
007007008ffffff00200002000888888888000006ffffff009999990cffffff00cccccc0d222222d22222222f4f4f4f48888887864444446086886800cccccc0
0000000000ff22f0a9999999088888888888000000ff22f00099990000ff22f000cccc00d424444d442444444f4f4f4f08788880644444460067760002022020
0000000000c11c000aa99990048888888888e000006886000000000000c88c00000000004dddddd4442444444f4f4f4f008887005666666500777700002bb200
00bbbb00c1c11c1c0088e70004248fff888ee7886868868600000000c8c88c8c000000007aaaaaa7000000000000000000000000000000000888888007777770
00bbbb00c19cc91c0488ee880424fffff8ee7e886896698600099000c89cc98c000cc000a977779a000440000000000000000000000440008aaaaaa877777777
000bb0007cccccc70f1ff100042fff1cfff1c4007666666700a99a007cccccc7007cc700a979979a055445500000000000000000055445508a9898a877077077
000330007cccccc700f22f0000ffff11fff11000766666670a99a9a07cccccc707cc7c70a999979a071551700000000000000000071551708a8989a870777707
00b330000cc00cc00cc11cc000fffffffffff000066006600a9999a00cc00cc007cccc70a997799a444444440999900000000000444444448aaaaaa877000077
00b330000cc00cc0079cc970000fffff888f00000660066000a99a000cc00cc0007cc700a999999a044444409919900000999000044444600888888007777770
000330000c440c4400c00c00000cccc111ccc00006440644000990000c440c44000cc000a997799a006ff6009999633009191900006ff660030bb03000000000
00033b00044404440044044000cc1cc111cc1c00044404440000000004440444000000007aaaaaa706600660000f4bb3099999b006600000003bb30000000000
00033b00000000000000000000cc1cc111cc1c00000000000000000000000000000000000000000000000000004a463b098889b0000000000000000007677670
00b33000008880000000000000cc19a1119a1c00006660000000000000ccc00000000000000000000000000077aff663099999b000000000000000007cccccc7
00b330000888ee000000000000cc199111991c0006668800000a90000ccc88000007c000003b33000033b3007704446b0777777000000000000000007c1cc1c7
000330000888ee880000000000cc1ccccccc1c000666886600a9a9000ccc88cc007c7c0003b3b3b00b3b3b300009ff637707707700000000000000006cccccc6
00033b0088f1ff1099999aaa00cc1ccccccc1c0066f1ff10009a9a00ccf1ff1000c7c7003b333b3333b333b30090009077077077099990000000000066000066
00033b008ffffff79999999a00711ccccccc17006ffffff00009a000cffffff0000c70007777777777777777009000907777777799199000a099900007777770
0003300000ff22f7222dd2220077cccccccc770000ff22f70000000000ff22f70000000004f00f400400f4f0044004407700007799996330a919190000000000
00b3300000c11c0c0aa999900077ccc11ccc7700006886070000000000c88c0700000000004ff400004f4f004440044007777770000f4bb3a99999b000000000
00033b00c1c11ccc0088e7000000ccc00ccc00006868868800000000c8c88c880000000000999900b3bbbbb30060060000600600004a463b098889b040044004
00b33000c19cc9100488ee880000ccc00ccc00006896698000000000c89cc9800000000009aaaa90bbbb3bbb608868066088680677aff663099999b004666640
00b330007cccccc00f1ff1000000ccc00ccc000076666660000000007cccccc0000000009aa99aa9f4f4f4f408688860086888607704446b0777777006455460
000330007cccccc000f22f700000ccc00ccc0000766666600009a0007cccccc0000c70009aa99aa9f4f4f4f468886888688868880009ff637707707746554564
000330000cc00cc00cc11cc00000ccc00ccc000006600660000990000cc00cc0000cc0009aa99aa94f4f4f4f7777777777777777009000907707707746545564
000bb0000c400cc0079cc900000044c0044c000006600660000000000cc00cc0000000009aa99aa94f4f4f4f919aaaa9919aaaa9009000907777777706455460
00bbbb0004440cc400400400000044440444400006440644000000000c440c440000000009aaaa90f4f4f4f4c9a99990c9a99990044004407700007704666640
00bbbb00004404440040040000004444044440000444044400000000044404440000000000999900f4f4f4f40550055000500500444044400777777040044004
00000000000000000000000000000000000040000b33b33004400440d111111d0000000007600670000000000000000000000000bbbbbbbbbbbbbbbb00000000
00000000000000000999000000000000065444003383383804f004f01d2dddd10000000087706778008778000000000000877800bbbbbbbbbbbb333b09999999
0000000000000000099190000000000006444000833b33b304400440122222210760067088777788078678800760067007867880bbbbbbbbbbb3333b99aaaa90
000000000000000009999700000000000444500004f004f004f004f01dddd2d18770677887888878888778878770677888877887bbbbbbbbbb33333b9aaaaaa9
0999000009990000200aa730099900004446550004400440044004401dddd2d18877778808878880888768888877778888876888bbbbbbbbbb33333b9aaaaaa9
099190000991900022095733099190000400655004f004f004f004f01222222187888878b08bb80b887888888788887888788888bbbbbbbbbb333bbb99aaaa90
09999700099997005455a7b3099997000000065504400440044004401d2dddd1088788803bb33bb308888780088788800888878000bbbbbbbb333b0009999999
200aa730200aa7305009973b455aa730000000650ff00ff00ff00ff0d111111d008bb80003b00b30008bb800008bb800008bb80000bbbbbbbb333b0000000000
22095733220957330000a7300009573300000065b33bb33bdd1ddddd066666600003b000008778000003b0000003b0000003b00000bbbbbbbbb33b0000000000
5455a7b35455a7b30000a0a00455a7b30000065534bffbf3dd1ddddd77077076003bb30087877878003bb300003bb300003bb30000bbbbbbbbb33b0000999900
5009973b5009973b0000a0a00009973b040065503b444fb31111111178777786000b300088877888000b3000000b3000000b300000bbbbbbbb333b0009aaaa90
0000a7300000a730000040400000a73044465500b4f444fbddddd1dd77000076330bb03387877878330bb033000bb000000bb00000bbbbbbbb333b009aaaaaa9
0000a0a00000a0a0000440400000a0a004445000b4f444fbddddd1dd07776660333bb33308888880333bb33300b33b0000b33b0000bbbbbbbb333b009aaaaaa9
0000a0440000a0a0000440400000a0a0064440003b444fb3111111110000000003333330b08bb80b033333300b3003b0003bb30000bbbbbbbb333b0009aaaa90
000440440004404400000000000440440654440034bffbf3dd1ddddd00000000003b33003bb33bb3003b330033b00b3300b33b0000bbbbbbbb333b0000999900
0044400400444044000000000044404400004000b33bb33bdd1ddddd00000000000bb00003b00b30000bb000b300003b003bb30000bbbbbbbb333b0000000000
5544777700066000000660000011111000111111008888880000000000000000000000000000000000000000000000000222eee06dddddd50000000099999999
5464646700777600007776000707707007077070070770700055550000000700000000000000000000000000000000002256668ed644445d00cc11009aaaaaa9
5544444701111110088888800707707007077070070770700555555000007d60011111100444444005555550000000002858868ed464454d0c7777109aa00aa9
000000001111111188888888e111111e0111111008888880055555500007ddd61cccccc14ffffff458888885000000002855668ed446544d0c7c17109a0000a9
00000000777777777777777701155110e110011ee880088e05555550007dddd01c1cccc14f4ffff4588888850000000028868882d445644d0c7777c09a0000a9
00000000919aaaa9919aaaa901111110011001100880088005555550007ddd001cccccc14f4ff4f4588888850000000028866882d464464d0c7cccc09a0000a9
00000000c9a99990c9a9999000111100001111000088880000555500005566001ccc11c14ffff4f4588855850000000022855522d644446d556666660aaaaaa0
0000000005500550055005500ee0ee0000e0ee0000e0ee0000000000055555601ccc11c14ffffff45888558500000000022222206dddddd65555555600999900
00000000000660000006600000111110000000000011111100888888000000001cccccc14fff44f4588888850000000000000000099999900000000088888888
07706700007776000077760007077070000000000707707007077070005555001c111cc14fff44f4588666850000000000999a0099999999000000008eeeeee8
66706670011111100888888007077070000560000707707007077070055566501c1c1cc14ffffff458868685000000000999999099099099000000008e2002e8
055055001111111188888888e111111e00555700e1111110e8888880055556501c111cc14f4ffff4588666859aaaaaa99aaaaaa9990990990000000082000028
0550550077777777777777770c1101c0005555000110011e0880088e055555501c1cccc14ffffff4588868859999999a9999999a990990990000000082000028
05505500919aaaa9919aaaa901100110000550000110011008800880055555501c1cccc14fff44f458886885000000000aaaaaa0990990990000000082000028
05505500c9a99990c9a9999000111100000000000011110000888800005555001cccccc14ffff4f4588866850000000000000000999999995566666602222220
0550550000500500005005000ee0ee00000000000ee0ee000ee0ee00000000001cccccc14ffffff4588888850000000000000000099999905555555600888800
65555556000880000006600000777700077777700777777000000000000cccccccccc00000000000000000000000000000999000000000000099900000000000
522222250088880000677000077777706666666766666667000000000011111111111c0000000000000000000033330009919963733700000991996373370000
57722225008888000181800701c00c1094444440044444400000000001111111111111c000000000000000000332233009999996337330700999999633733070
527766650dddd0007778886701c00c1094a4a44094a4a44000000000111111111111111c00000000000707000320023006999999633373000699999963337300
52222225dddd60007878886707777770066466490664664900000000666661111111111c00111100708888070320333000009999633333300077999963333330
56622225dddd60007778806677777777066766490667664000000000771116111111111c011111100868788000322300009999aa63733777009999aa63733777
52667775dddd60000066000070700707044744400444444007777770771116111111111c17771111877788780003300000000aaa6337333000000aaa63373330
655555560dddd0000000000070700707099009900900009066666667771116111111111c770777777707777700033000006999aa63333337006999aa63333337
edddddde000670000006600000777700000000600000000000000000776661766617111600000000000000000003300000099999637373300009999963737330
d2ee2e2d000670000067700007777770000006050044440000000000771111711617161600111100000000000003320000699999633333370069999963333337
de22e22d0006700001b1b00701c00c100000655004444440000000007711117116177766011111100ffffff00023300000000aaa6633337000000aaa66333370
d22d22ed00067000777bbb67010000100002260094a4a44900000000771111777711716c11111111ffffffff0003300200000999996733000000099999673300
d2e2e22d000670007b7bbb67077777700062e0009667664900000000111111111111111c77777777ff4ff4ff20033202000099aaaaa63700000099aaaaa63700
de22222d00067000777bb066077777700556000006676640000000000111111111111110919aaaa9044444402002303000099900999060700009999999996070
d2e2d2ed0006700000660000077007705060000004444440000000000011111111111100c9a9999004f44f400203320000099900999000000009990099900000
edddddde00067000000000007007700706000000990000990000000000011111111110000500005004f44f400023300000070700707000000007770077700000
cccccccc000670000006600000000000006005000044440011111111444444440000000000000000000000000055555000888880000000000000000099999999
c1ccc1cc00067000006770000006600000600500044444401cccccc144444444000000007077777000000000755575577888788700000000000000009a999a99
cccccccc0006700001919007007776000006600004a4a44911c1c1c1044444400000000076555057000000007555555578888888009999000099990099999999
ccc1ccc1d0d77d0d7779997700c77c000002e0009667664011c1c1c106ff6f6000000000765555050000000075555555788888880999999009999990999a999a
cccccccc222dd2227979996700c77c0000022000066766400000000006fff6f07000000756575555e000000e0555555508888888090990900909909099999999
1ccc1ccc22222222777990660706707000066000044444400000000006ffff607766667776557665e788887e00555550008888800909909009999990a999a999
cccccccc0d2dd2d00066000006000060005006000900009000000000066ffff07706607750555660e70880ee00a00a0000a00a00099999900999999099999999
cc1ccc1c02d22d2000000000000000000050060000000000000000000066660077566577000000007758857700aa0aa000aa0aa0099009900900009099a999a9
00cc0000000670000006600000000000000000000566650000000000000000007757757700000000775775770055555000888880008888800000000000a00000
0cc00cc000067000006770000028280000888800556765500067760000111100706666077077777070888807755575577888788778888888000000000a0a00a0
cccccccc0006700001c1c00708888820028282805566655006066060011111100066660072888287008888007555755778887887788788780000000099999999
ccc1ccccd0d77d0d777ccc67882288888888882870705550067007601111111100666600728888280088880075557557788878877888788700000000999a9999
cccccc1c444dd4447c7ccc678c2c28828c2c288807075550067007607777777700777700828788880077770005555555088888887888788700000000999999a9
1ccc1ccc44444444777cc066d2122dddd2122ddd5555555006066060919aaaa905555550728872280222222000555550008888800088888000000000a999a999
cccccccc0d4dd4d0006600000dddddd0edddddd05555555000677600c9a9999055555555808882202222222200a00a0000a00a0000a000a00000000099999999
cc1ccc1c04d44d4000000000e0e0e00e00e0e0e005555500000000000550055055555555000000002222222200aa00a000aa00a0000aa0aa0000000099a999a9
09919963733700000000000000000000000000000000000000070070070070000007007007007000555555555555555555555555555555555555555555555555
09999996337330700000000000000000000000000000000070666666666666077066666666666607566666666666666556666666666666655666666666666665
06999999633373000000000000000000000000000000000006655555555556600665555555555660566666666666666556666666666666655666666666666665
00009999633333300000000000000000000000000000000006575575575575600657557557557560055555555555555005555555555555500555555555555550
009999aa637337770000000000000000000000000000000076566655556665677655565555655567067666766766676006677667766776607666666666666667
00000aaa633733300000000000000000000000000000000006560265562065600655026556205560766666666666666706666666666666600676667667666760
006999aa633333370000700000070000000007000000000006566665566665600656666556666560006676666667660006766676676667600666666666666660
00099999637373300000037337300000000003333330000076555555555555677655555555555567007007000070070076666666666666677667766776677667
00699999633333370703333333333070000333373333300006555555555555600655555555555560000000000000000000667666666766000666666666666660
00000aaa663333700033373333733300703337333733330706566666666665600655566666655560000000000000000000700700007007000676667667666760
00000999996733000333337337333330033733333333333076567575575765677655567777655567000000000000000000000000000000007666666666666667
000099aaaaa637007337333333337337373333333373373306566666666665600655556666555560000000000000000000000000000000000066766776676600
00099999999960703333337777333333333777733333333306555555555555600655555555555560000000000000000000000000000000000070070000700700
00099990099900007337777007777337377700777333333776655555555556677665555555555667000000000000000000000000000000000000000000000000
00099990099970007777777777777777777777777777777700666666666666000066666666666600000000000000000000000000000000000000000000000000
0007007000707000099a9999a999a990099a9999a999a99000070070070070000007007007007000000000000000000000000000000000000000000000000000
000000000000000000000000000000000005500005666770007ccc0000ccc7000000000000700700555555555555555506766676676667600666666666666660
000000000000000000000000000000000056660005666770077cccc00cccc77000000000877aa778566666666666666576666666666666677676667667666767
0000000000000000000000000006000005666660056666607777cc8888cc77770007700008a88a80566666666666666506677667766776600666666666666660
0000000000000000000000000067000005666660056666608872288888822788009887007a8998a7055555555555555006666666666666600667766776677660
0666600006666000066660000000700005666660056666608882278888722888009987007a8998a7767666766766676776766676676667677666666666666667
66566000665660006656600000000760056666600566666088cc77777777cc880009900008a88a80066666666666666006666666666666600676667667666760
6666655066666550666665500000060005666770005666000cccc770077cccc000000000877aa778066776677667766006677667766776600666666666666660
00077665000776657707766500000000056667700005500000ccc700007ccc000000000000700700766666666666666776666666666666677667766776677667
006dd756006dd75677ddd75600000000088888800c7111c000222200000000000000000000000000067666766766676006766676676667600666666666666660
77d6667577d666750006667500000000888888880c1711c002eeee200dd00dd00400004005400540066666666666666006666666666666600676667667666760
77066676770666760006667600000000888ee8880c1177c002e222200d4004d00000000004500450766776677667766776677667766776677666666666666667
0006667500066675000666750060006088e22e880cccccc0cccccccc000000000000000000000000066666666666666006666666666666600066766776676600
00d000d000d000d000d000d00006760088e22e880c7111c00c7111c0000000000000000000000000067666766766676006766676676667600070070000700700
00d000d000d000d000d000d000600060888ee8880c1711c00c1711c00d4004d00000000005400540766666666666666776666666666666670000000000000000
05500550055005500550055000000000888888880c1177c00c1177c00dd00dd00400004004500450066676677667666006667667766766600000000000000000
55500550555055505550055000000000088888800cccccc00cccccc0000000000000000000000000067666766766676006766676676667600000000000000000
__map__
000000000a190a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000090009000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000003900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110000000000000039000000001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a00000000000000000000000000000000000000570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007d0000000000000000000000
0b0b0b0b0b0b0b0b3a3a3a3a3a3a3a3a3a0a0a0a0a0a45454545450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000486900000000000000000000000000
0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0a0a0a0a0a4646464646454d4e4545450000007d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000587900000000000000000000000000
0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0a0a0a0a0a4646464646465d5e46464600480000000000000000000000000000808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006d6d6d6d6d6d6d0000000081000000
0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0a0a0a0a0a4646464646465d5e464646005800007000760070000000000000008080b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0f6b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b09090000000000000000000000000000000000000000000000000000091000000
555555555555555555555555555555555555555555555555555555556d6d474747565656566060606060606080808080808080a0a080a0a092a092a0a0a0a0a0a0a0a0a0a0a0a0a0f5a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a09090000000000000000000000000000000000000000000000000000091000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080808080808080a0a0a0a0a092a0a0a0a0a0a0a0a0a0a0a0a0a0a0f5a0a0a0a0a0a0a082a0a0a0a0a0a0a0a0a0b2a0a0a0a0a09090000000000000000000000000000000000000000000000089000091000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080a0a0a092a092a0a0a0a0a083a0a0a0a0a0a0a0f5a0a0a0a0a0a0a0a0a082a0a0a0a0a0a0a0a0a0a0a0a0a09090000000000000000000000000000000000000000000000060000091000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a019a0f5a0a0a0a0a0a0a0a0a0a0a082a0a0a0a0a0a0a0a0a090a09090000000000000000000000000000000000000000000000000000091000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080a0a0a0a0a08ba0a0a0a0a0a0a0a0a0a0a0a0a0f5a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a08ba0a0a090a09090909090909090909090909000000000000000000000000000000091000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080a0a0a0a0a09ba0a0a0a0a0a0a0a0a08ba0a0a0f5a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a09ba0a0a090a0a0a0a0a0a0a0a0a0a0a0a069900000000000ad00000000000000000091000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080a0a0a0a0a09ba0a0a0a0a0a0a0a0a09ba0a0a0f5a0a0a0b5b6b69aa0a0a0a0a0a0a0a0a0a09ba0a0a090a0a0a0a0a0a0a0a0a0a0a0a07990000000000000000000000000020000b1000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909080808080808080808080808080808080bfbfbf808080808080808080808080
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090afafafafafafafafafafaf9000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090909090909090909090909000000000000000
