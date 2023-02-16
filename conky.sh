if [ -x /usr/bin/conky ]; then
    echo "/usr/bin/conky"
else
    if [ -x /usr/bin/apt ]; then
	sudo apt-get install conky-all
    elif [ -x /usr/bin/yum ]; then
	sudo yum -y install conky-all
    fi
fi

cat > ~/.conkyrc << "EOF"
conky.config = {
    xinerama_head = 0,
    background = yes,
    font = 'Sans:size=9',
    use_xft = true,
    xftalpha = 0.9,
    update_interval = 1.2,
    total_run_times = 0,
    own_window = true,
    own_window_type = 'panel',
    own_window_argb_visual = true,
    own_window_transparent = true,
    own_window_class = 'conky',
    own_window_hints = 'undecorated,above,sticky,skip_taskbar,skip_pager',
    double_buffer = true,
    minimum_width = 400,
    maximum_width = 400,
    draw_shades = true,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = true,
    default_color = 'CDE0E7',
    color1 = 'ff0000',
    color2 = 'a7faeb',
    default_shade_color = 'black',
    default_outline_color = 'green',
    gap_x = 10,
    gap_y = 0,
    alignment = 'mr',
    no_buffers = true,
    uppercase = false,
    cpu_avg_samples = 2,
    override_utf8_locale = true,
    uppercase = true,
}

conky.text = [[
${color2}
${alignr} ${time %Y.%m.%d %H:%M}
${alignr} kernel ${kernel}

#Sytem temp: ${alignr}${acpitemp}${iconv_start UTF-8 ISO_8859-1}°${iconv_stop}C
#CPU temp: ${alignr}${hwmon 2 temp 1}${iconv_start UTF-8 ISO_8859-1}°${iconv_stop}C
#Fan: ${alignr}${hwmon 1 fan 1} RPM
${alignc}${font Sans:bold:size=12}- ${execi 1000 cat /proc/cpuinfo | grep 'model name' | sed -e 's/model name.*: //'| uniq | cut -c 1-17} -${font Sans:size=9}

CPU ${cpu cpu0}% ${alignr} 
${cpubar 20}
Core0 ${cpu cpu1}% ${alignr} Core8 ${cpu cpu9}%
${cpubar cpu1 10,180} ${alignr} ${cpubar cpu9 10,180}
Core1 ${cpu cpu2}% ${alignr} Core9 ${cpu cpu10}%
${cpubar cpu2 10,180} ${alignr} ${cpubar cpu10 10,180}
Core2 ${cpu cpu3}% ${alignr} Core10 ${cpu cpu11}%
${cpubar cpu3 10,180} ${alignr} ${cpubar cpu11 10,180}
Core3 ${cpu cpu4}% ${alignr} Core11 ${cpu cpu12}%
${cpubar cpu4 10,180} ${alignr} ${cpubar cpu12 10,180}
Core4 ${cpu cpu5}% ${alignr} Core12 ${cpu cpu13}%
${cpubar cpu5 10,180} ${alignr} ${cpubar cpu13 10,180}
Core5 ${cpu cpu6}% ${alignr} Core13 ${cpu cpu14}%
${cpubar cpu6 10,180} ${alignr} ${cpubar cpu14 10,180}
Core6 ${cpu cpu7}% ${alignr} Core14 ${cpu cpu15}%
${cpubar cpu7 10,180} ${alignr} ${cpubar cpu15 10,180}
Core7 ${cpu cpu8}% ${alignr} Core15 ${cpu cpu16}%
${cpubar cpu8 10,180} ${alignr} ${cpubar cpu16 10,180}

Ram ${alignr}$mem / $memmax ($memperc%)
${membar 10}
swap ${alignr}$swap / $swapmax ($swapperc%)
${swapbar 10}

${alignc}${font Sans:bold:size=12}- ${exec nvidia-smi --query-gpu=gpu_name --format=csv,noheader,nounits} -${font Sans:size=9}

GPU ${nvidia gpuutil}%  ${alignr} ${nvidia gpufreqcur} MHz(${nvidia gputemp}°C)
${nvidiabar 10 gpuutil}
MEM ${alignr} ${nvidia memused} MB / ${nvidia memmax} MB
${nvidiabar 10 memused}

Highest CPU $alignr PID   CPU MEM
${color1}${top name 1}$alignr${top pid 1}${top cpu 1}${top mem 1}${color2}
${top name 2}$alignr${top pid 2}${top cpu 2}${top mem 2}
${top name 3}$alignr${top pid 3}${top cpu 3}${top mem 3}
${top name 4}$alignr${top pid 4}${top cpu 4}${top mem 4}

#Highest MEM $alignr CPU% MEM%
#${color1}
#${top_mem name 1}$alignr${top_mem cpu 1}${top_mem mem 1}
#${color2}
#${top_mem name 2}$alignr${top_mem cpu 2}${top_mem mem 2}

SSD: ${alignr}${fs_used /} / ${fs_size /}
${fs_bar 10 /}
IO-R: ${diskio_read /dev/sda} ${alignr}IO-W: ${diskio_write}
${diskiograph_read /dev/sda 15,107} ${alignr}${diskiograph_write /dev/sda 15,107}

ENP4S0: ${addr enp4s0}
Signal: ${alignr}${wireless_link_qual enp4s0}%
Down ${downspeed enp4s0}/s ${alignr}Up ${upspeed enp4s0}/s
${downspeedgraph enp4s0 15,107} ${alignr}${upspeedgraph enp4s0 15,107}
Total ${totaldown enp4s0} ${alignr}Total ${totalup enp4s0}
]]
EOF

if [ -d ~/.config/autostart ]; then
    echo ""
else
    mkdir -p ~/.config/autostart
fi

cat > ~/.config/autostart/sh.desktop << "EOF"
[Desktop Entry]
Type=Application
Exec=sh -c "sleep 10; exec conky"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[ko]=conky
Name=conky
Comment[ko]=
Comment=
EOF

