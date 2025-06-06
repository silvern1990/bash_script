# mako notify setting
pacman -S --noconfirm mako

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


# fuzzel setting
pacman -S --noconfirm fuzzel

cat > ~/.config/fuzzel/fuzzel.ini << "EOF"
[colors]
background=282a36fa
text-color=ffffff
selection-color=3d4474fa
border=fffffffa

[border]
border-width=2
EOF


# swayr & swayrbar setting
if cargo; then
else
	pacman -S --noconfirm cargo
fi

git clone https://git.sr.ht/\~tsdh/swayr ~/swayr
cd ~/swayr && cargo build
cargo install swayr swayrbar

cat > ~/.config/swayr/config.toml << "EOF"
[menu]
executable = "fuzzel"
args = [
	'--dmenu',
	'--lines=5',
	'--prompt=Select window: ',
	'--width=50',
]

[format]
window_format = '{app_name} - {title} - Workspace: {workspace_name}'

[layout]
auto_tile = false
auto_tile_min_window_width_per_output_width = [
    [
    800,
    400,
],
    [
    1024,
    500,
],
    [
    1280,
    600,
],
    [
    1400,
    680,
],
    [
    1440,
    700,
],
    [
    1600,
    780,
],
    [
    1680,
    780,
],
    [
    1920,
    920,
],
    [
    2048,
    980,
],
    [
    2560,
    1000,
],
    [
    3440,
    1200,
],
    [
    3840,
    1280,
],
    [
    4096,
    1400,
],
    [
    4480,
    1600,
],
    [
    7680,
    2400,
],
]

[focus]
lockin_delay = 750

[misc]
seq_inhibit = false

[swaymsg_commands]
include_predefined = true
EOF
