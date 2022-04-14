100 ' B-Train for PC-8001 + PCG8100
110 defint a-z:width 40,25:console 0,25,1,0:print chr$(12);
120 dim dx(7),dy(7),rd(39,4),mc(31,23)
130 for d=0 to 7:read dx(d),dy(d):next
140 data 0,-1, 1,-1, 1,0, 1,1, 0,1, -1,1, -1,0, -1,-1
150 for c=&h80 to &ha7:print chr$(c);:next:print
160 p=0
170 read d$:if d$="*" then 200
180 out 0,val("&h"+d$):out 1,p mod 256:out 2,p\256 or &h10:out 2,0
190 p=p+1:goto 170

200 ' rail dir
210 for i=0 to 39
220  read d:rd(i,0)=d
230  if d then for j=1 to d:read rd(i,j):next
240 next

300 ' map char
310 read x0,y
320 x=x0:locate x,y
330 read d$
340 if d$="*" then y=y+1:goto 320
350 if d$="**" then 5000
360 c=val("&h"+d$):mc(x,y)=c:x=x+1:print chr$(c);:goto 330

1000 ' pattern table
1010 data 08,08,08,08, 08,08,08,08
1020 data 01,02,04,08, 10,20,40,80
1030 data 00,00,00,00, ff,00,00,00
1040 data 80,40,20,10, 08,04,02,01
1050 data 08,08,08,08, ff,08,08,08
1060 data 81,42,24,18, 18,24,42,81
1070 data 3c,42,81,81, 81,81,42,3c
1080 data 3c,7e,ff,ff, ff,ff,7e,3c

1090 data 08,08,08,08, 08,04,02,01
1100 data 01,02,04,08, 08,08,08,08
1110 data 00,00,00,00, 1f,20,40,80
1120 data 00,00,00,00, f8,04,02,01
1130 data 80,40,20,10, 08,08,08,08
1140 data 08,08,08,08, 10,20,40,80
1150 data 01,02,04,08, f0,00,00,00
1160 data 80,40,20,10, 0f,00,00,00

1170 data 08,08,08,08, 08,0c,0a,09
1180 data 01,02,04,08, 18,28,48,88
1190 data 00,00,00,00, ff,20,40,80
1200 data 80,40,20,10, f8,04,02,01
1210 data 88,48,28,18, 08,08,08,08
1220 data 09,0a,0c,08, 10,20,40,80
1230 data 01,02,04,08, ff,00,00,00
1240 data 80,40,20,10, 0f,04,02,01

1250 data 08,08,08,08, 18,28,48,88
1260 data 01,02,04,08, f0,20,40,80
1270 data 80,40,20,10, ff,00,00,00
1280 data 88,48,28,18, 08,04,02,01
1290 data 09,0a,0c,08, 08,08,08,08
1300 data 01,02,04,08, 1f,20,40,80
1310 data 00,00,00,00, ff,04,02,01
1320 data 80,40,20,10, 08,0c,0a,09

1330 data 08,08,08,08, 3c,00,00,00
1340 data 01,02,24,18, 08,04,00,00
1350 data 00,00,08,08, 0f,08,00,00
1360 data 00,00,04,08, 18,24,02,01
1370 data 00,00,00,00, 3c,08,08,08
1380 data 00,00,20,10, 18,24,40,80
1390 data 00,00,08,08, f8,08,00,00
1400 data 80,40,24,18, 10,20,00,00
1410 data *

2000 ' rail dir
2010 data 2,0,4, 2,1,5, 2,2,6, 2,3,7
2020 data 4,0,4,2,6, 4,1,5,3,7, 0, 0
2030 data 2,0,3, 2,1,4, 2,2,5, 2,3,6
2040 data 2,4,7, 2,5,0, 2,6,1, 2,7,2
2050 data 3,0,4,3, 3,1,5,4, 3,2,6,5, 3,3,7,6
2060 data 3,4,0,7, 3,5,1,0, 3,6,2,1, 3,7,3,2
2070 data 3,0,4,5, 3,1,5,6, 3,2,6,7, 3,3,7,0
2080 data 3,4,0,1, 3,5,1,2, 3,6,2,3, 3,7,3,4
2090 data 1,0, 1,1, 1,2, 1,3
2100 data 1,4, 1,5, 1,6, 1,7

3000 ' map
3010 data 5,5
3020 data 20,20,8a,82,82,82,82,82,9e,82,82,82,82,82,82,82,82,82,82,82,8b,*
3030 data 20,81,8a,82,82,82,82,82,82,9a,9e,82,82,82,82,82,82,82,82,8b,20,83,*
3040 data 89,89,20,20,20,20,20,20,20,20,20,83,20,20,20,20,20,20,20,20,83,20,83,*
3050 data 80,80,20,20,20,20,20,20,a4,a4,20,20,97,82,82,82,82,a6,20,20,20,8c,20,8c,*
3060 data 80,80,20,20,20,20,20,20,80,80,20,20,20,8f,82,82,82,a6,20,20,20,80,20,80,*
3070 data 80,80,20,20,20,20,20,20,80,80,20,20,20,20,20,20,20,20,20,20,20,80,20,80,*
3080 data 80,80,20,20,20,20,20,20,88,80,20,20,20,20,20,20,20,20,20,20,20,80,20,80,*
3090 data 80,80,20,20,20,20,20,20,20,94,20,20,20,20,20,20,20,20,20,20,20,80,20,80,*
3100 data 80,80,20,20,20,20,20,20,20,80,20,20,20,20,20,20,20,20,20,20,20,80,20,80,*
3110 data 80,88,20,20,20,20,20,20,20,80,20,20,20,20,20,20,20,20,20,20,20,8d,20,80,*
3120 data 88,20,83,20,20,20,20,20,20,80,20,20,20,20,20,20,20,20,20,20,81,20,20,8d,*
3130 data 20,83,20,8f,82,82,82,82,82,84,82,82,8b,20,8a,82,82,82,82,8e,20,20,81,*
3140 data 20,20,83,20,20,20,20,20,20,8d,20,20,20,85,20,20,20,20,20,20,20,81,*
3150 data 20,20,20,8f,82,82,82,82,96,82,82,82,8e,20,8f,82,82,82,82,82,96,82,82,82,a6,*
3160 data **

5000 ' game init
5010 bx=8:by=5:bd=2:b$=chr$(&h87)
5020 ax=bx+dx(bd):ay=by+dy(bd):ad=2:a$=chr$(&h86)
5030 locate bx,by:print b$;
5040 locate ax,ay:print a$;

6000 ' game loop
6010 for i=1 to 50:next
6020 c=mc(ax,ay)-&h80
6030 k=rd(c,0):d=(ad+4)mod 8
6040 on k goto ,6200,6300,6400
6050 stop

6200 ' 2
6210 if d=rd(c,1) then nd=rd(c,2):goto 7000
6220 if d=rd(c,2) then nd=rd(c,1):goto 7000
6230 stop

6300 ' 3
6310 if d=rd(c,1) then nd=rd(c,int(rnd(1)*2)+2):goto 7000
6320 if d=rd(c,2) then nd=rd(c,1):goto 7000
6330 if d=rd(c,3) then nd=rd(c,1):goto 7000
6340 stop

6400 ' 4
6410 if d=rd(c,1) then nd=rd(c,2):goto 7000
6420 if d=rd(c,2) then nd=rd(c,1):goto 7000
6430 if d=rd(c,3) then nd=rd(c,4):goto 7000
6440 if d=rd(c,4) then nd=rd(c,3):goto 7000
6450 stop

7000 ' move
7010 nx=ax+dx(nd):ny=ay+dy(nd)
7020 c=mc(nx,ny)-&h80:k=rd(c,0)
7030 if k=1 then 7500
7040 locate bx,by:print chr$(mc(bx,by));
7050 locate ax,ay:print b$;
7060 locate nx,ny:print a$;
7070 bx=ax:by=ay:bd=ad
7080 ax=nx:ay=ny:ad=nd
7090 goto 6000

7500 ' switchback
7510 nx=bx:ny=by:nd=(bd+4)mod 8:t$=b$
7520 bx=ax:by=ay:bd=(ad+4)mod 8:b$=a$
7530 ax=nx:ay=ny:ad=nd:a$=t$
7540 goto 6000