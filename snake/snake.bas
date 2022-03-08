100 ' THE SNAKE for N-BASIC
110 defint a-z:i=rnd(-time)
120 def fnr(a,b)=int(rnd(1)*a)+b
130 def fnv(x,y)=peek(&hf300+y*120+x*2)
140 dim dx(3),dy(3):dx(1)=1:dx(3)=-1:dy(0)=-1:dy(2)=1
150 m=100:dim mx(m-1),my(m-1)

1000 ' title
1010 width 40,25:console 0,25,0,0:print chr$(12);
1020 x=4:locate 0,5
1030 print tab(x);"### # # ###   ## ##   #  # # ###"
1040 print tab(x);" #  # # #    #   # # # # # # #  "
1050 print tab(x);" #  ### ##    #  # # ### ##  ## "
1060 print tab(x);" #  # # #      # # # # # # # #  "
1070 print tab(x);" #  # # ###  ##  # # # # # # ###"
1080 locate 14,12:print "Hit any key";
1090 if inkey$="" then 1090

2000 ' game init
2010 print chr$(12);
2020 print " ";string$(38,"#")
2030 for y=1 to 23:print "#";tab(39);"#";:next
2040 print " ";string$(38,"#");
2100 ' snake
2110 x=16:y=12
2120 for i=0 to 3
2130  mx(i)=x:my(i)=y:locate x,y:print chr$(&hed);:x=x+1
2140 next
2150 mx(i)=x:my(i)=y:locate x,y:print chr$(&hec);
2160 h=i:t=0:d=1:qn=20:qc=0:ta=0
2200 '
2210 for i=1 to qn
2220  x=fnr(36,2):y=fnr(21,2):if fnv(x,y)<>&h20 then 2220
2230  locate x,y:print "$";
2240 next
2250 for i=1 to 10
2260  x=fnr(36,2):y=fnr(21,2):if fnv(x,y)<>&h20 then 2260
2270  locate x,y:print "#";
2280 next

3000 ' game loop
3010 for i=1 to 100:next
3020 i=inp(0)
3030 if i=&hfb then d=2
3040 if i=&hef then d=3
3050 if i=&hbf then d=1
3060 i=inp(1)
3070 if i=&hfe then d=0
3100 '
3110 x=mx(h):y=my(h):locate x,y:print chr$(&hed);
3120 x=x+dx(d):y=y+dy(d)
3130 v=fnv(x,y)
3140 if v=&h20 then 3200
3150 if v=&h24 then qc=qc+1:ta=ta+3:goto 3200
3160 locate x,y:print "*";:goto 4000
3200 '
3210 locate x,y:print chr$(&hec);:h=(h+1)mod m:mx(h)=x:my(h)=y
3220 if qc>=qn then locate 11,10:print " Congratulations! ";:goto 4000
3230 if ta then ta=ta-1:beep 1:beep 0:goto 3000
3240 locate mx(t),my(t):print " ";:t=(t+1)mod m
3250 goto 3000

4000 ' game over
4010 locate 11,12:print " Try again? [y/n] ";:beep
4020 k$=inkey$
4030  if k$="y" then 2000
4040  if k$="n" then end
4050 goto 4020
