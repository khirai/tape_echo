sr=48000
kr=48000
ksmps=1
nchnls=2
0dbfs=1


  gal       init      0
  gar       init      0
  gitlen    init      131072
  giratlen  init      32      
  gkglis    init      127
  gkeykp      init      0   ;; page the kontrol has table

instr 9  ;;sensekey for paging the kontrol hash table
  keyrawold init 0 
  keyraw      sensekey
  if keyrawold == -1 then
    if keyraw >=48 && keyraw <= 57 then ;;digits
      gkeykp      =  keyraw-48
    endif
    if keyraw == 45 then ;; '-' load table
            ftloadk    "konthashtab", 1, 1, 2
    endif
    if keyraw == 61 then ;; '=' save table
            ftsavek    "konthashtab", 1, 1, 2
    endif
  endif
  keyrawold =  keyraw
           printk2    gkeykp
endin

instr 10 
; this instr hashes gkdata1 and gkchan 
; and writes that data at that point in table 2  
ar = 0
al = 0

  kstatus, kchan, kdata1, kdata2                  midiin  
  khash     =  kdata1+(128*(kchan-1))
if (khash > 0 ) then 
            tabw      kdata2,khash , 2

endif
            printks   ,"rd :%i %d %d %d %d %d\n", 1.0, gkeykp, khash, kstatus, kchan, kdata1, kdata2

endin


instr 15;  manages the length of the tape loop
  kfader    init      127
  kpan      init      1
  kfadert   tab       p4, 2, 0
  kpant     tab       p5, 2, 0
  ktop      tab       p6, 2, 0
  kbot      tab       p7, 2, 0
            printks   ,"len:%d %1.4f %1.4f %d %d\n",1,p4,kfader,kpan,ktop,kbot
    ; cleanup zicks
;  kfader    =  ((63*kfader+kfadert/127)/64)
  gkglis    =  kfader
  kpan      =  ((1023*kpan+kpant/127)/1024)
    ;; length of the  segment we are looping on 
  gktlen    =  (kpan*(gitlen-ksmps)+ksmps)/gitlen ;so we always play at least ksmps samples
endin

instr 19; record head 

  kfader    init      1
  kpan      init      1
  ktoptg    init      0 ; top button toggle state
  ktopp     init      0 ; top button prevois state
  kfadert   tab       p4, 2, 0  ;dry volume
  kpant     tab       p5, 2, 0  ;record speed 
  ktop      tab       p6, 2, 0
  kbot      tab       p7, 2, 0

    ; cleanup zicks
  kfader    =  ((63*kfader+kfadert/127)/64)
  kpantr    tab       kpant/128,5,1               ;ratio table
  kpan      =  ((63*kpan+kpantr)/64)

  if ktopp==0 && ktop!=0 then
    ktoptg    =  ~ktoptg
  endif
  ktopp     =  ktop

            printks   ,"rec:%d %1.4f %1.4f %d %d\n",1,p4,kfader,kpantr,ktop,kbot
  al,ar     ins
 
  gat       phasor    kpan*sr/(gitlen*gktlen)     ;gat rec head position
  if ktoptg == 0 then
    ;; adjusteded head position in samples
    aheadpos= gat*gitlen*gktlen
    ;; sound on sound read
    arl       tab       aheadpos,   3
    arr       tab       aheadpos,   4
    ;; set up the mix
    awl       =  arl*kfader+al
    awr       =  arr*kfader+ar
    ;; write to table 
            tabw      awl, aheadpos,   3
            tabw      awr, aheadpos,   4
  endif
;            outs      al*kfader, ar*kfader

endin

instr 20;  pb head
  atoff     init      0  ; offset to sync with record head
  at        init      0  ; position [0-1] of read head 
  ktoptg    init      0 ; top button toggle state
  ktopp     init      0 ; top button prevois state
  kat       init      0
  kfader    init      0
  kpan      init      1
  kfadert   tab       p4, 2, 0 ;pb volume
  kpant     tab       p5, 2, 0 ;pb head speed
  ktop      tab       p6, 2, 0
  kbot      tab       p7, 2, 0

    ; cleanup zicks
  kfader    =  ((63*kfader+kfadert/127)/64)
 kpantr    tab       kpant/128,5,1                   ;ratio table
  kpan      =  ((63*kpan+kpantr)/64)
 
    ; leading edge 
 if ktopp ==0 && ktop !=0 then
  katoff     =  frac (1 + at - gat)        ;setting sync after some dialing in
 endif
  ktopp     =  ktop

            printks   ,"pb :%d %1.4f %1.4f %d %d\n",1,p4,kfader,kpan,ktop,kbot  
    ; sample position control 
  at        phasor kpan*sr/(gktlen*gitlen)
   

  ainl     tab       frac(at+katoff)*gitlen*gktlen,  3
  ainr     tab       frac(at+katoff)*gitlen*gktlen , 4

  ar        =  kfader*ainr  ;*(kpan/128)
  al        =  kfader*ainl  ;*(kpan/128-1)

           outs      al,ar

endin

instr 99 ; file recording
  al, ar    monitor   
            fout      "tape_echo.wav", 14, al, ar

endin