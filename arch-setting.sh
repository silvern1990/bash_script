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
    cat > ~/.config/sway/config << EOF
# Default config for sway
#
# Copy this to ~/.config/sway/config and edit it to your liking.
#
# Read `man 5 sway` for a complete reference.

### Variables
#
# Logo key. Use Mod1 for Alt.
set $mod Mod4
# Home row direction keys, like vim
set $left h
set $down j
set $up k
set $right l
# Your preferred terminal emulator
set $term foot
# Your preferred application launcher
set $menu wmenu-run

### Output configuration
#
# Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
output * bg /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill
#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0
#
# You can get the names of your outputs by running: swaymsg -t get_outputs

### Idle configuration
#
# Example configuration:
#
# exec swayidle -w \
#          timeout 300 'swaylock -f -c 000000' \
#          timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
#          before-sleep 'swaylock -f -c 000000'
#
# This will lock your screen after 300 seconds of inactivity, then turn off
# your displays after another 300 seconds, and turn your screens back on when
# resumed. It will also lock your screen before your computer goes to sleep.

### Input configuration
#
# Example configuration:
#
#   input type:touchpad {
#       dwt enabled
#       tap enabled
#       natural_scroll enabled
#       middle_emulation enabled
#   }
#
#   input type:keyboard {
#       xkb_layout "eu"
#   }
#
# You can also configure each device individually.
# Read `man 5 sway-input` for more information about this section.

### Key bindings
#
# Basics:
#
    # Start a terminal
    bindsym $mod+Return exec $term

    # Kill focused window
    bindsym $mod+Shift+q kill

    # Start your launcher
    bindsym $mod+d exec fuzzel

    # Drag floating windows by holding down $mod and left mouse button.
    # Resize them with right mouse button + $mod.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier $mod normal

    # Reload the configuration file
    bindsym $mod+Shift+c reload

    # Exit sway (logs you out of your Wayland session)
    bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'
#
# Moving around:
#
    # Move your focus around
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    # Or use $mod+[up|down|left|right]
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # Move the focused window with the same, but add Shift
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    # Ditto, with arrow keys
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right
#
# Workspaces:
#
    # Switch to workspace
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9
    bindsym $mod+0 workspace number 10
    # Move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9
    bindsym $mod+Shift+0 move container to workspace number 10
    # Note: workspaces can have any name you want, not just numbers.
    # We just use 1-10 as the default.
#
# Layout stuff:
#
    # You can "split" the current object of your focus with
    # $mod+b or $mod+v, for horizontal and vertical splits
    # respectively.
    bindsym $mod+b splith
    bindsym $mod+v splitv

    # Switch the current container between different layout styles
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    # Make the current focus fullscreen
    bindsym $mod+f fullscreen

    # Toggle the current focus between tiling and floating mode
    bindsym $mod+Shift+space floating toggle

    # Swap focus between the tiling area and the floating area
    bindsym $mod+space focus mode_toggle

    # Move focus to the parent container
    bindsym $mod+a focus parent
#
# Scratchpad:
#
    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym $mod+Shift+minus move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym $mod+minus scratchpad show

    bindsym $mod+m [class="vlc"] scratchpad show

    bindsym $mod+Tab exec ~/.config/sway/scratchpad-menu.sh
#
# Resizing containers:
#
mode "resize" {
    # left will shrink the containers width
    # right will grow the containers width
    # up will shrink the containers height
    # down will grow the containers height
    bindsym $left resize shrink width 10px
    bindsym $down resize grow height 10px
    bindsym $up resize shrink height 10px
    bindsym $right resize grow width 10px

    # Ditto, with arrow keys
    bindsym Left resize shrink width 50px
    bindsym Down resize grow height 50px
    bindsym Up resize shrink height 50px
    bindsym Right resize grow width 50px

    # Return to default mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"
#
# Utilities:
#
    # Special keys to adjust volume via PulseAudio
    bindsym --locked XF86AudioMute exec pactl set-sink-mute \@DEFAULT_SINK@ toggle
    bindsym --locked XF86AudioLowerVolume exec pactl set-sink-volume \@DEFAULT_SINK@ -5%
    bindsym --locked XF86AudioRaiseVolume exec pactl set-sink-volume \@DEFAULT_SINK@ +5%
    bindsym --locked XF86AudioMicMute exec pactl set-source-mute \@DEFAULT_SOURCE@ toggle
    # Special keys to adjust brightness via brightnessctl
    bindsym --locked XF86MonBrightnessDown exec brightnessctl set 5%-
    bindsym --locked XF86MonBrightnessUp exec brightnessctl set 5%+
    # Special key to take a screenshot with grim
    bindsym Print exec grim

#
# Status Bar:
#
# Read `man 5 sway-bar` for more information about this section.
include my_config
include /etc/sway/config.d/*
EOF

    cat > ~/.config/sway/my_config << EOF
input "type:pointer" {
    scroll_factor 0.4
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
output DP-2 scale 1
output DP-2 pos -1280 1440
output DP-1 pos 0 0
output eDP-1 pos 640 1440
#output HDMI-A-1 mode 2560x1440@60Hz
#output HDMI-A-1 pos 0 0
output eDP-1 mode 2560x1600@120Hz

output DP-2 disable

client.focused          #4c7899 #ffffff88 #000000 #2e9ef4
client.unfocused        #333333 #22222277 #ffffff #292d3e
client.urgent           #2f343a #900000 #ffffff #900000
client.placeholder      #000000 #0c0c0c #ffffff #000000
client.background       #ffffff

bindsym $mod+Shift+M exec swaylock -c 000000
bindsym $mod+Shift+x exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval d && killall -s 9 mpv"
bindsym $mod+x exec bash -c "killall -s 9 wallpaperengine ; killall -s 9 mpv"
bindsym $mod+Shift+a exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval al && killall -s 9 mpv"
bindsym $mod+Shift+d exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval dn && killall -s 9 mpv"
bindsym $mod+Shift+v exec bash -c "shopt -s expand_aliases && source ~/alias/.env && eval vc"
bindsym $mod+Shift+s exec swaync-client -t -sw

#group change
bindsym $mod+Ctrl+h focus parent, focus left, focus child
bindsym $mod+Ctrl+l focus parent, focus right, focus child


#window resize
bindsym $mod+Ctrl+Shift+i floating enable, resize set width 50 ppt height 50 ppt, move position 0 ppt 0 ppt
bindsym $mod+Ctrl+Shift+o floating enable, resize set width 50 ppt height 50 ppt, move position 50 ppt 0 ppt
bindsym $mod+Ctrl+Shift+k floating enable, resize set width 50 ppt height 50 ppt, move position 0 ppt 50 ppt
bindsym $mod+Ctrl+Shift+l floating enable, resize set width 50 ppt height 50 ppt, move position 50 ppt 50 ppt
bindsym $mod+Ctrl+Shift+semicolon floating enable, resize set width 30 ppt height 40 ppt, move position 70 ppt 0 ppt

exec insync start
exec mega-sync
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

    cat > ~/.config/sway/scratchpad-menu.sh << EOF
#!/usr/bin/env bash

tree=$(swaymsg -t get_tree)

# scratchpad window 목록 추출 (id + title)
list=$(echo "$tree" | jq -r '
.. | objects |
select(.name=="__i3_scratch") |
.floating_nodes[] |
"\(.id)\t\(.name)"
')

# fuzzel 에서 선택
choice=$(echo "$list" | fuzzel --dmenu --prompt "scratchpad")

[ -z "$choice" ] && exit

id=$(echo "$choice" | cut -f1)

# 해당 window 표시
swaymsg "[con_id=$id]" scratchpad show
swaymsg "[con_id=$id]" focus
EOF

    cat > ~/.config/sway/alt-tab.sh << EOF
#!/usr/bin/env bash

tree=$(swaymsg -t get_tree)

windows=$(echo "$tree" | jq -r '
def nodes: .nodes[]?, .floating_nodes[]?;
recurse(nodes)
| select(.type=="con" and .name!=null)
| select(.app_id!=null or .window_properties.class!=null)
| "\(.id)\t\(.app_id // .window_properties.class)\t\(.name)"
')

choice=$(echo "$windows" | \
fuzzel --dmenu \
        --prompt "switch" \
        --lines 15 \
        --width 60)

[ -z "$choice" ] && exit

id=$(echo "$choice" | cut -f1)

swaymsg "[con_id=$id]" focus
swaymsg "[con_id=$id]" scratchpad show
EOF

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

[key-bindings]
next=Tab Down
prev=Shift+Tab Up
cancel=Escape
accept=Return
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

if [ ! -d '~/.config/mpv' ]; then
    cat > ~/.config/mpv/config << EOF
keepaspect-window=no
keepaspect=yes
video-unscaled=no
panscan=0
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

#swaync config
if [ ! -d '~/.config/swaync' ]; then
    cat > ~/.config/swaync/config << EOF
{
  "$schema": "/etc/xdg/swaync/configSchema.json",
  "ignore-gtk-theme": true,
  "positionX": "right",
  "positionY": "top",
  "layer": "overlay",
  "control-center-layer": "top",
  "layer-shell": true,
  "layer-shell-cover-screen": true,
  "cssPriority": "highest",
  "control-center-margin-top": 0,
  "control-center-margin-bottom": 0,
  "control-center-margin-right": 0,
  "control-center-margin-left": 0,
  "notification-2fa-action": true,
  "notification-inline-replies": false,
  "notification-body-image-height": 100,
  "notification-body-image-width": 200,
  "timeout": 10,
  "timeout-low": 5,
  "timeout-critical": 0,
  "fit-to-screen": true,
  "relative-timestamps": true,
  "control-center-width": 500,
  "control-center-height": 600,
  "notification-window-width": 500,
  "keyboard-shortcuts": true,
  "notification-grouping": true,
  "image-visibility": "when-available",
  "transition-time": 200,
  "hide-on-clear": false,
  "hide-on-action": true,
  "text-empty": "No Notifications",
  "script-fail-notify": true,
  "scripts": {
    "example-script": {
      "exec": "echo 'Do something...'",
      "urgency": "Normal"
    },
    "example-action-script": {
      "exec": "echo 'Do something actionable!'",
      "urgency": "Normal",
      "run-on": "action"
    }
  },
  "notification-visibility": {
    "example-name": {
      "state": "muted",
      "urgency": "Low",
      "app-name": "Spotify"
    }
  },
  "widgets": [
    "inhibitors",
    "title",
    "dnd",
    "backlight",
    "volume",
    "label#chargelimit",
    "menubar#chargelimit",
    "label#outputsink",
    "menubar#outputsink",
    "label#scale",
    "menubar#scale",
    "notifications"
  ],
  "widget-config": {
    "notifications": {
      "vexpand": true
    },
    "inhibitors": {
      "text": "Inhibitors",
      "button-text": "Clear All",
      "clear-all-button": true
    },
    "title": {
      "text": "Notifications",
      "clear-all-button": true,
      "button-text": "Clear All"
    },
    "dnd": {
      "text": "Do Not Disturb"
    },
    "label#chargelimit": {
      "max-lines": 5,
      "text": "충전제한"
    },
    "label#outputsink": {
      "max-lines": 5,
      "text": "출력장치"
    },
    "label#scale": {
      "max-lines": 5,
      "text": "스케일"
    },
    "mpris": {
      "blacklist": [],
      "autohide": false,
      "show-album-art": "always",
      "loop-carousel": false
    },
    "buttons-grid": {
      "buttons-per-row": 7,
      "actions": [
        {
          "label": "直",
          "type": "toggle",
          "active": true,
          "command": "sh -c '[[ $SWAYNC_TOGGLE_STATE == true ]] && nmcli radio wifi on || nmcli radio wifi off'",
          "update-command": "sh -c '[[ $(nmcli radio wifi) == \"enabled\" ]] && echo true || echo false'"
        }
      ]
    },
    "volume": {
      "label": "`"
    },
    "backlight": {
      "label": "󰃠",
      "subsystem": "backlight",
      "device": "amdgpu_bl1"
    },
    "menubar#outputsink": {
      "buttons#outputsink": {
        "position": "left",
        "actions": [
          {
            "label": "내장",
            "command": "pactl set-default-sink alsa_output.pci-0000_c4_00.6.HiFi__Speaker__sink"
          },
          {
            "label": "buds",
            "command": "pactl set-default-sink bluez_output.C4:77:64:AD:7F:1C"
          }
        ]
      }
    },
    "menubar#scale": {
      "buttons#scale": {
        "position": "left",
        "actions": [
          {
            "label": "1.0",
            "command": "swaymsg output eDP-1 scale 1"
          },
          {
            "label": "2.0",
            "command": "swaymsg output eDP-1 scale 2"
          }
        ]
      }
    },
    "menubar#chargelimit": {
      "menu#power": {
        "label": "출력장치",
        "position": "right",
        "actions": [
          {
            "label": "스피커",
            "command": "pactl set-default-sink alsa_output.pci-0000_c4_00.6.HiFi__Speaker__sink"
          },
          {
            "label": "buds3",
            "command": "pactl set-default-sink bluez_output.C4_77_64_AD_7F_1C.1"
          }
        ]
      },
      "buttons#chargelimit": {
        "position": "left",
        "actions": [
          {
            "label": "85%",
            "command": "asusctl -c 85"
          },
          {
            "label": "95%",
            "command": "asusctl -c 95"
          },
          {
            "label": "100%",
            "command": "asusctl -c 100"
          }
        ]
      }
    }
  }
}
EOF
fi
