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
    scroll_factor 0.8
}

input "type:touchpad" {
    scroll_factor 0.2
    natural_scroll enabled
    tap enabled
}

exec waybar

#exec swayidle -w         timeout 300 'swaylock -f -c 000000'    timeout 18000 'systemctl halt'         before-sleep 'swaylock -f -c 000000'


exec fcitx5
#exec ibus start

exec_always swaybg -i ~/.config/sway/background/background.jpg -m fit

exec ~/.config/sway/lid-handler.py

exec swaync

output eDP-1 scale 2
output DP-1 pos 0 0
output DP-2 pos 0 0
output eDP-1 pos 640 1440
output HDMI-A-1 mode 2560x1440@60Hz
output HDMI-A-1 pos 0 0
output eDP-1 mode 2560x1600@120Hz

client.focused          #4c7899 #ffffff88 #000000 #2e9ef4
client.unfocused        #333333 #22222277 #ffffff #292d3e
client.urgent           #2f343a #900000 #ffffff #900000
client.placeholder      #000000 #0c0c0c #ffffff #000000
client.background       #ffffff

bindsym $mod+Shift+M exec swaylock -c 000000
bindsym $mod+Shift+n exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval n"
bindsym $mod+Shift+x exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval d"
bindsym $mod+x exec killall -s 9 wallpaperengine
bindsym $mod+Shift+a exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval al"
bindsym $mod+Shift+d exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval dn"
bindsym $mod+Shift+v exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval vc"
bindsym $mod+Shift+s exec swaync-client -t -sw

#group change
bindsym $mod+Ctrl+h focus parent, focus left, focus child
bindsym $mod+Ctrl+l focus parent, focus right, focus child
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
    width=400
    height=200
    anchor=top-center
    default-timeout=10000

    [urgency=high]
    background-color=#E55561
    border-color=#FF0000
    text-color=#FFFFFF
    width=400
    height=200
    anchor=top-center
EOF
fi

# waybar config
if [ ! -d '~/.config/waybar' ]; then
    cat > ~/.config/waybar/config << EOF
// -*- mode: jsonc -*-
{
    "layer": "top", // Waybar at top layer
    // "position": "bottom", // Waybar position (top|bottom|left|right)
    "height": 20, // Waybar height (to be removed for auto height)
    // "width": 1280, // Waybar width
    "spacing": 4, // Gaps between modules (4px)
    // Choose the order of the modules
    "modules-left": [
        "sway/workspaces",
        "sway/mode",
        "sway/scratchpad",
    ],
    "modules-center": [
        "custom/playtime",
    ],
    "modules-right": [
        "custom/kakaoTalk",
        "mpd",
        "idle_inhibitor",
        "pulseaudio",
        //"network",
        "power-profiles-daemon",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        //"keyboard-state",
        "sway/language",
        "battery",
        "battery#bat2",
        "clock",
        "tray",
        "custom/power"
    ],
    // Modules configuration
    // "sway/workspaces": {
    //     "disable-scroll": true,
    //     "all-outputs": true,
    //     "warp-on-scroll": false,
    //     "format": "{name}: {icon}",
    //     "format-icons": {
    //         "1": "",
    //         "2": "",
    //         "3": "",
    //         "4": "",
    //         "5": "",
    //         "urgent": "",
    //         "focused": "",
    //         "default": ""
    //     }
    // },
    "keyboard-state": {
        "numlock": true,
        "capslock": true,
        "format": "{name} {icon}",
        "format-icons": {
            "locked": "",
            "unlocked": ""
        }
    },
    "sway/mode": {
        "format": "<span style=\"italic\">{}</span>"
    },
    "sway/scratchpad": {
        "format": "{icon} {count}",
        "show-empty": false,
        "format-icons": ["", ""],
        "tooltip": true,
        "tooltip-format": "{app}: {title}"
    },
    "mpd": {
        "format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ",
        "format-disconnected": "Disconnected ",
        "format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ",
        "unknown-tag": "N/A",
        "interval": 5,
        "consume-icons": {
            "on": " "
        },
        "random-icons": {
            "off": "<span color=\"#f53c3c\"></span> ",
            "on": " "
        },
        "repeat-icons": {
            "on": " "
        },
        "single-icons": {
            "on": "1 "
        },
        "state-icons": {
            "paused": "",
            "playing": ""
        },
        "tooltip-format": "MPD (connected)",
        "tooltip-format-disconnected": "MPD (disconnected)"
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    "tray": {
        // "icon-size": 21,
        "spacing": 10,
        // "icons": {
        //   "blueman": "bluetooth",
        //   "TelegramDesktop": "$HOME/.local/share/icons/hicolor/16x16/apps/telegram.png"
        // }
    },
    "clock": {
        // "timezone": "America/New_York",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    "memory": {
        "format": "{}% "
    },
    "temperature": {
        // "thermal-zone": 2,
        // "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
        "critical-threshold": 80,
        // "format-critical": "{temperatureC}°C {icon}",
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["\uf2cb", "", "\uf2c7"]
    },
    "backlight": {
        // "device": "acpi_video1",
        "format": "{percent}% {icon}",
        "format-icons": ["", "", "", "", "", "", "", "", ""]
    },
    "battery": {
        "states": {
            // "good": 95,
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-full": "{capacity}% {icon}",
        "format-charging": "{capacity}% \u0084",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        // "format-good": "", // An empty format will hide the module
        // "format-full": "",
        "format-icons": ["", "", "", "", ""]
    },
    "battery#bat2": {
        "bat": "BAT2"
    },
    "power-profiles-daemon": {
      "format": "{icon}",
      "tooltip-format": "Power profile: {profile}\nDriver: {driver}",
      "tooltip": true,
      "format-icons": {
        "default": "",
        "performance": "",
        "balanced": "",
        "power-saver": ""
      }
    },
    "network": {
        // "interface": "wlp2*", // (Optional) To force the use of this interface
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    "pulseaudio": {
        // "scroll-step": 1, // %, can be a float
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": "\ueb24 {icon} {format_source}",
        "format-muted": "\ueb24 {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    "custom/media": {
        "format": "{icon} {text}",
        "return-type": "json",
        "max-length": 40,
        "format-icons": {
            "spotify": "",
            "default": "🎜"
        },
        "escape": true,
        "exec": "$HOME/.config/waybar/mediaplayer.py 2> /dev/null" // Script in resources folder
        // "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" // Filter player based on name
    },
    "custom/power": {
        "format" : "⏻ ",
		"tooltip": false,
		"menu": "on-click",
		"menu-file": "$HOME/.config/waybar/power_menu.xml", // Menu file in resources folder
		"menu-actions": {
			"shutdown": "shutdown",
			"reboot": "reboot",
			"suspend": "systemctl suspend",
			"hibernate": "systemctl hibernate"
		}
    },
    "cffi/mediaplayer": {
    	"module_path": "/home/zero/.config/waybar/scripts/waybar_mediaplayer.so",
		"scroll-title": true,
		"scroll-interval": 200,
		"scroll-before-timeout":5,
		"title-max-width": 100,
		"scroll-step": 5,
		"tooltip": false,
		"tooltip-image-width": 200,
		"tooltip-image-height": 200,
		"btn-play-icon": "",
		"btn-pause-icon": "",
		"btn-prev-icon": "",
		"btn-next-icon": ""
    },
    "custom/next": {
        "format": "",
        "on-click": "bash -c 'shopt -s expand_aliases && source ~/alias/.env && eval n'",
        "tooltip": false
    },
    "custom/prev": {
        "format": "",
        "on-click": "notify-send test",
        "tooltip": false
    },
    "custom/delete": {
        "format": "󰗨",
        "on-click": "bash -c 'shopt -s expand_aliases && source ~/alias/.env && eval d'",
        "tooltip": false
    },
    "custom/exit": {
        "format": "󰅖",
        "on-click": "killall wallpaperengine",
        "tooltip": false
    },
    "custom/playtime": {
        "exec": "echo \"$(tail -n1 /tmp/log.txt | awk '{print $2 \"/\" $4}') $(sqlite3 file:~/wallpaper.db?mode=ro \"select resolution from gid_list order by play_time asc, resolution desc limit 1 \")\"",
        "interval": 1,
        "format": "{}",
        "tooltip": false
    },
    "custom/kakaoTalk": {
        "format": "",
        "on-click": "bash -c 'WINEPREFIX=$HOME/.wine LANG=ko_KR.UTF-8 wine \"$HOME/.wine/drive_c/Program Files (x86)/Kakao/KakaoTalk/KakaoTalk.exe\"'",
        "tooltip": false,
    }

}
EOF
fi
