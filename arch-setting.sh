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
input "type:pointer" {
    scroll_factor 0.5
}

exec waybar

exec swayidle -w         timeout 300 'swaylock -f -c 000000'         timeout 600 'systemctl suspend'         before-sleep 'swaylock -f -c 000000'


exec fcitx5

exec_always swaybg -i ~/.config/sway/background/background.jpg -m fit

exec ~/.config/sway/lid-handler.py

client.focused          #4c7899 #28557788 #ffffff #2e9ef4
client.unfocused        #333333 #22222277 #ffffff #292d3e
client.urgent           #2f343a #900000 #ffffff #900000
client.placeholder      #000000 #0c0c0c #ffffff #000000
client.background       #ffffff


bindsym $mod+Shift+M exec swaylock -c 000000

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
