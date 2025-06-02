# mako notify setting
dnf -y install mako

mkdir -p ~/.config/mako

cat > ~/.config/mako/config << "EOF"
background-color=#696969
text-color=#ffffff
border-color=#555555
border-size=2
default-timeout=10000
EOF


# foot terminal setting

cat > ~/.config/foot/foot.ini << "EOF"
[main]
font=Unifont:size=12
EOF

