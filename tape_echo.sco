f1 0 4096 10 1                          ; sines for oscil
f2  0 4096  17    0     0               ; mixer data landing table
; f3 0 16777216 1 "test2.wav" 0 4 0       
f3  0 [131072*8]  2     0     0               ; record
f4  0 [131072*8]  2     0     0               ; record
f5  0 0     -23    "2_3ratios.txt"        ;  ratios for speeds
        ;  midi data reader and table writer
        
; i1 0 1                                  ; global
i9  0 36000
i10 0 36000
;  table interperters
;  hash function: gkdata1+(128*gkchan)
;  order:  fader, pan, top, bottom



; this set is default for scene 1

        ;; len
i15 0 36000 2  14 23 33
        ;; rec
i19 0 36000 3  15 24 34

        ;; pb

i20 0 36000 4  16 25 35
i20 0 36000 5  17 26 36
i20 0 36000 6  18 27 37
i20 0 36000 8  19 28 38
i20 0 36000 9  20 29 39
i20 0 36000 12 21 30 40
i20 0 36000 13 22 31 41

        ;; file record 
;i99 0 36000                             ; 

;  scene  4 table interpreters
