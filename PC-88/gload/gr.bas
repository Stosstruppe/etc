100 clear ,&hafef
110 defint a-z
120 bin=&hb000
140 poke &hec85,1 'curdrv
150 poke &hef5d,3 'curtyp
200 '
210 trk=1
220 for p=&h5c to &h5e
230  poke &haff2,p
240  gvh=&hc0
250  poke &haff3,0 'gvlow
260  for t=0 to 3
270   poke &haff1,trk
280   for sec=1 to 16
290    poke &haff0,sec
300    poke &haff4,gvh
310    call bin
320    gvh=gvh+1
330   next sec
340   trk=trk+1
350  next t
360 next p
