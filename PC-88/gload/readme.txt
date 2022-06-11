mon
h] ^w2,0,0,1,c000,c0ff
h] ^w2,0,0,2,b000,b0ff

$b000-$b0ff gload
$c000-$c0ff ipl

sur:0 trk:0 sec:1 ipl
sur:0 trk:0 sec:2 gload

trk:1-4 blue plane
trk:5-8 red plane
trk:9-12 green plane
