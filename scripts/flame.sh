#!/bin/bash
flameshot gui -r | xclip -selection clipboard -t image/png

#nohup flameshot >& /tmp/flameshot_workaround.log &
#flameshot gui
