csound -realtime -+rtmidi=alsa -M hw:${1},0,0 -+rtaudio=alsa -b 256 -i adc:hw:${2},0 -o dac:hw:${2},0 tape_echo.orc tape_echo.sco
