csound -+rtmidi=alsa -M hw:${1},0,0 -+rtaudio=alsa -i adc:hw:${2},1 -o dac:hw:${2},0 tape_echo.orc tape_echo.sco
