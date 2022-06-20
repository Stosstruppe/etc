100 '
110 clear ,&hb9ff:defint a-z
120 screen 0,1:console ,,0:cls 3
130 for i=0 to 7:read c:color=(i,c):next
140 data 1,6,0,0,2,2,7,7
150 ps0=&hba00
160 ps1=&hba80
170 gput=&hbb00
180 mx=0:my=0:mt=0:md=1
190 pd0=&hc000
200 ' sprite data
210 p=&hba00
220 for i=0 to 127:poke p+i,0:next
230 p=&hba80
240 for i=0 to 127:read d$:poke p+i,val("&h"+d$):next
300 data ff,ff,ff,ff, 00,00,00,00, ff,ff,ff,ff, a0,00,00,05
310 data a0,00,00,05, a0,00,00,05, a0,00,00,05, a0,00,00,05
320 data a0,00,00,05, a0,00,00,05, a0,00,00,05, a0,00,00,05
330 data a0,00,00,05, ff,ff,ff,ff, 00,00,00,00, ff,ff,ff,ff
340 data 00,00,00,00, ff,ff,ff,ff, ff,ff,ff,ff, 60,00,00,06
350 data 60,00,00,06, 60,00,00,06, 60,00,00,06, 60,00,00,06
360 data 60,00,00,06, 60,00,00,06, 60,00,00,06, 60,00,00,06
370 data 60,00,00,06, ff,ff,ff,ff, ff,ff,ff,ff, 00,00,00,00
400 ' background
410 for i=0 to 16
420 x=639*i\16:y=199*i\16
430 line(0,y)-(x,199),1
440 line(639,y)-(x,0),1
450 next
500 ' main loop
510 if mx=0 then md=1
520 if mx=76 then md=-1
530 mt=mt+1:mx=mx+md:my=92+sin(mt*.1)*90
540 pd1=&hc000+80*my+mx
550 call gput(pd0, ps0)
560 call gput(pd1, ps1)
570 pd0=pd1:goto 510
