sr=48000
kr=4800
ksmps=10
nchnls=2
0dbfs=1


  gal       init      0    ;; global audio 
  gar       init      0
  gitlen    init      131072*2                    ;;p length of the segment of tape we are looping on
 ; giratlen  init      32      
  gkeykp    init      0                           ;; page the kontrol has table
  gkprnctl  init      0

instr 9  ;;sensekey for paging the kontrol hash table
         ;; and string initialization
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

;;string initialization
  ktime     timeinstk   
  gkprnctl  metro     1
if gkprnctl == 1 then   
  gSline1   sprintfk  "%s", {{      1 len  2 rec  3 pb   4      5      6      7      8      9}}
  gSpan     sprintfk "%s",  {{pan: }}
  gSfad     sprintfk "%s",  {{fad: }}  
  gStop     sprintfk "%s",  {{top: }}
  gSbot     sprintfk "%s",  {{bot: }}
endif

;;           printk2    gkeykp
endin

instr 10 
; this instr hashes gkdata1 and gkchan 
; and writes that data at that point in table 2  
ar = 0
al = 0
gkdry  init 0
  kstatus, kchan, kdata1, kdata2                  midiin  
  khash     =  kdata1+(128*(kchan-1))
if (khash > 0 ) then 
            tabw      kdata2,khash , 2

endif
;            printks   ,"rd :%i %d %d %d %d %d\n", 1.0, gkeykp, khash, kstatus, kchan, kdata1, kdata2

endin


instr 15;  manages the length of the tape loop
  kfader    init      1
  kpan      init      1
  kfadert    tab       p4, 2, 0
  kpant     tab       p5, 2, 0
  ktop      tab       p6, 2, 0
  kbot      tab       p7, 2, 0

    ; cleanup zicks
  kfader    =  ((63*kfader+kfadert/127.0)/64)
  kfaderd2  tab kfader,5 ,1
  kpan      =  ((1023*kpan+kpant/127)/1024)
    ;; length of the  segment we are looping on 



  gktlen    =  (kpan*kfaderd2*(gitlen-ksmps)+ksmps)/gitlen ;so we always play at least ksmps samples

if gkprnctl == 1 then
  Span     sprintfk  ,"%s%1.4f ",gSpan,kpan
  Sfad     sprintfk  ,"%s%1.4f ",gSfad,kfaderd2
  Stop     sprintfk  ,"%s%6d ",gStop,ktop
  Sbot      sprintfk  ,"%s%6d ",gSbot,kbot
  gSpan     strcpyk  Span
  gSfad     strcpyk  Sfad
  gStop     strcpyk  Stop
  gSbot     strcpyk  Sbot 
endif


;  gkdry     =  kfader

    endin

instr 19; record head 

  kfader    init      1
  kpan      init      1
  ktoptg    init      0 ; top button toggle state
  ktopp     init      0 ; top button prevois state
  kbottg    init      0 ; top button toggle state
  kbotp     init      0 ; top button prevois state
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
  if kbotp==0 && kbot!=0 then
    kbottg    =  ~kbottg
  endif
  kbotp     =  kbot
  
;            printks   ,"rec:%d %1.4f %1.4f %d %d\n",1,p4,kfader,kpantr,ktoptg,kbottg
if gkprnctl == 1 then
  Span     sprintfk  ,"%s%1.4f ",gSpan,kpantr
  Sfad     sprintfk  ,"%s%1.4f ",gSfad,kfader
  Stop     sprintfk  ,"%s%6d ",gStop,ktoptg
  Sbot      sprintfk  ,"%s%6d ",gSbot,kbottg
  gSpan     strcpyk  Span
  gSfad     strcpyk  Sfad
  gStop     strcpyk  Stop
  gSbot     strcpyk  Sbot 
endif
  ainl,ainr ins
  krecnq    =  sr * kpantr / 2                 ; record nyquist sample rate * pan table ratio /2

if kpantr < 1.0 then
  al        clfilt    ainl, krecnq, 0,6,2     ; 3rd order cheb II filters at nq
  ar        clfilt    ainr, krecnq, 0,6,2
else
  al        =  ainl
  ar        =  ainr
endif
    gat     phasor    kpan*sr/(gitlen*gktlen)     ;gat rec head position

    ;; adjusteded head position in samples
    aheadpos= gat*gitlen*gktlen

;; top and bottom track sound on sound
 
  if ktoptg == 0 then   
    arl       tab   aheadpos,   3       ;; sound on sound read
    awl       =     arl*kfader+al       ;; set up the mix
              tabw  awl, aheadpos,   3  ;; write to table
  endif
  if kbottg == 0 then
    arr       tab   aheadpos,   4       ;; sound on sound read
    awr       =     arr*kfader+ar       ;; set up the mix
              tabw  awr, aheadpos,   4  ;; write to table 
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

;            printks   ,"pb :%d %1.4f %1.4f %d %d\n",1,p4,kfader,kpan,ktop,kbot  
if gkprnctl == 1 then
  Span     sprintfk  ,"%s%1.4f ",gSpan,kpan
  Sfad     sprintfk  ,"%s%1.4f ",gSfad,kfader
  Stop     sprintfk  ,"%s%6d ",gStop,ktop
  Sbot      sprintfk  ,"%s%6d ",gSbot,kbot 
  gSpan     strcpyk  Span
  gSfad     strcpyk  Sfad
  gStop     strcpyk  Stop
  gSbot     strcpyk  Sbot 
endif

    ; sample position control 
  at        phasor kpan*sr/(gktlen*gitlen)
   

  ainl     tab       frac(at+katoff)*gitlen*gktlen,  3
  ainr     tab       frac(at+katoff)*gitlen*gktlen , 4

  ar        =  kfader*ainr  ;*(kpan/128)
  al        =  kfader*ainl  ;*(kpan/128-1)

           outs      al,ar

endin

instr 99 ; file recording
;  al, ar    monitor   
;            fout      "tape_echo.wav", 14, al, ar
            printf "%s\n", gkprnctl,  gSline1
            printf "%s\n", gkprnctl,  gSpan
            printf "%s\n", gkprnctl,    gSfad
            printf "%s\n", gkprnctl,    gStop
            printf "%s\n", gkprnctl,   gSbot       
; if gkprnctl == 1 then
;   gSpan     =  ""
;   gSfad     =  ""
;   gStop     =  ""
;   gSbot     =  ""
;   gkprnctl  =  0
; endif

endin
