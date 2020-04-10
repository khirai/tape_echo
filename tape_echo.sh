csound  -realtime -+rtmidi=alsa -M hw:${1},0,0 \
       -+rtaudio=jack -b 200   -+jack_client=tape${1} -i adc -o dac  \
       tape_echo.orc tape_echo.sco

 #-i adc:hw:${2},0 -o dac:hw:${2},0 \
