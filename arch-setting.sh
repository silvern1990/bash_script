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
    sudo pacman -S --noconfirm sway swaybg swayidle
    mkdir -p ~/.config/sway
    cp /etc/sway/config
    cat > ~/.config/sway/my_config << "EOF"
    exec_always waybar

    exec swayidle -w \
        timeout 300 'swaylock -f -c 000000' \
        timeout 600 'systemctl suspend' \
        before-sleep 'swaylock -f -c 000000'

    exec_always swaybg -i ~/.config/sway/background/background.jpg -m fill

    exec fcitx5
    EOF
fi

if [ ! -d '~/.config/fuzzel' ]; then
    sudo pacman -S --noconfirm fuzzel
    cat > ~/.config/fuzzel/fuzzel.ini << "EOF"
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

    cat > ~/.config/foot/foot.ini << "EOF"
    [main]
    font=Unifont:size=12
    EOF

fi

# mako notify setting

if [ ! -d '~/.config/mako' ]; then
    sudo pacman -S --noconfirm mako

    mkdir -p ~/.config/mako

    cat > ~/.config/mako/config << "EOF"
    background-color=#696969
    text-color=#ffffff
    border-color=#555555
    border-size=2
    default-timeout=10000
    EOF
fi
