  sr        =  48000
  kr        =  480
  nchnls    =  2
  gisec     =  16
gitabl ftgen 0, 0, sr*gisec, 2, 0
gitabend tableng gitabl

    instr 1
  arecpos   init      0
  ainl, ainr   ins    
  aph       phasor    1/gisec
  arecpos   =  aph*gitabend
            tabw      ainl, arecpos, gitabl
    endin
    instr 2 
  kpbr      =  p4
  kbeg      line      0,p3,1

  aoutl     lposcil3   1, 1,kbeg*sr , kbeg*2*sr, gitabl   
            outs      aoutl,aoutl

    endin 