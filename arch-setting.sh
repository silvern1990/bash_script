#!/bin/sh

# 
# 
#  Arch Linux environment setting for sway
#
#

if [ ! -x '/usr/bin/fcitx5' ]; then
    sudo pacman -S --noconfirm fcitx5 fcitx5-hangul
fi

if [ ! -d '~/.config/sway' ]; then
    sudo pacman -S --noconfirm sway swaybg swayidle waybar
    mkdir -p ~/.config/sway
    cp /etc/sway/config ~/.config/sway/config
    cat > ~/.config/sway/my_config << EOF
exec waybar

exec swayidle -w         timeout 300 'swaylock -f -c 000000'         timeout 600 'systemctl suspend'         before-sleep 'swaylock -f -c 000000'


exec fcitx5

exec_always swaybg -i ~/.config/sway/background/background.jpg -m fit

exec ~/.config/sway/lid-handler.py

input type:touchpad {
    tap enabled
    dwt enabled
    natural_scroll enabled
    pointer_accel 0.3
}

default_border pixel 1

client.focused          #000000cc #000000cc #ffffffff #000000cc #000000cc
client.unfocused        #00000077 #00000077 #ffffff99 #00000000 #00000077
client.focused_inactive #00000077 #00000077 #ffffff99 #00000000 #00000077
client.urgent           #00000077 #00000077 #ffffff99 #00000000 #00000077

EOF

    # sway lid event control
    cat > ~/.config/sway/lid-handler.py << EOF
#!/usr/bin/python3

from evdev import InputDevice, ecodes
import subprocess

dev = InputDevice('/dev/input/event0')

def disable_internal_display():
    subprocess.run(['swaymsg', 'output',  'eDP-1', 'disable'])

def enable_internal_display():
    subprocess.run(['swaymsg',  'output', 'eDP-1', 'enable'])


def main():
    for event in dev.read_loop():
        if event.type == ecodes.EV_SW and event.code == ecodes.SW_LID:
            if event.value == 1:
                disable_internal_display()
            else:
                enable_internal_display()


if __name__ == '__main__':
    main()
EOF

    chmod +x ~/.config/sway/lid-handler.py
    sudo usermod -aG input $USER
fi

if [ ! -d '~/.config/fuzzel' ]; then
    sudo pacman -S --noconfirm fuzzel
    mkdir -p ~/.config/fuzzel
    cat > ~/.config/fuzzel/fuzzel.ini << EOF
[colors]
background=282a36fa
text-color=ffffff
selection-color=3d4474fa
border=fffffffa

[border]
border-width=2
EOF
fi

# foot terminal setting

if [ ! -d '~/.config/foot' ]; then
    mkdir -p ~/.config/foot
    cat > ~/.config/foot/foot.ini << EOF
[main]
font=Unifont:size=12

[colors]
background=000000
alpha=0.8
EOF

fi

# mako notify setting

if [ ! -d '~/.config/mako' ]; then
    sudo pacman -S --noconfirm mako

    mkdir -p ~/.config/mako

    cat > ~/.config/mako/config << EOF
background-color=#696969
text-color=#ffffff
border-color=#555555
border-size=2
default-timeout=10000
EOF
fi
