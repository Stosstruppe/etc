100 clear ,&hbeff:defint a-z
110 cmd bload "gput.bin"
120 movvm=&hbf00
130 movvv=&hbf24
140 screen 0,0:cls 2
200 '
210 dim a(23),b(1)
220 d=&hfe80:b(0)=d:gosub 400
230 d=d+24:b(1)=d:gosub 400
300 '
310 for y=0 to 199 step 8:for x=0 to 79 step 2
320  d=&hc000+80*y+x:s=b(int(rnd*2)):call movvv(d,s)
330 next x,y
390 end
400 '
410 for i=0 to 23:read x$:a(i)=val("&h"+x$):next
420 call movvm(d,a(0))
430 return
500 '
501 data 0000,ffff,0000,ffff, 0000,ffff,0000,ffff
502 data 0000,0000,ffff,ffff, 0000,0000,ffff,ffff
503 data 0000,0000,0000,0000, ffff,ffff,ffff,ffff
510 '
511 data 5555,5555,5555,5555, 5555,5555,5555,5555
512 data 3333,3333,3333,3333, 3333,3333,3333,3333
513 data 0f0f,0f0f,0f0f,0f0f, 0f0f,0f0f,0f0f,0f0f
