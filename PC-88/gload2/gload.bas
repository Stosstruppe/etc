100 CLEAR ,&HBEFF:DEFINT A-Z
110 BLOAD "gload.bin"
120 M=&HBF00:V=&HBFF0
130 '
140 SCREEN 0,0:CLS 2
150 OPEN "test.dat" AS #1
160 P=VARPTR(#1)+9:Q=VARPTR(P)
170 POKE V+3,PEEK(Q):POKE V+4,PEEK(Q+1)
180 FOR J=0 TO 2
190  POKE V,&H5C+J
200  POKE V+1,0:POKE V+2,&HC0
210  FOR I=0 TO 63:GET #1:CALL M:NEXT
220 NEXT
230 CLOSE
