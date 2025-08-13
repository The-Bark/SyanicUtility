#!/bin/bash
# Syanic Utility (Lite) 

# Script made with <3 by Syanic XD (YouTube)

# Kya dekh rahe ho bhai? Naam change krke apne channel par daloge?? 
# Don't steal my code bruhh, this took hours to make.

setup() {
    echo ""
    echo "### SUL: Starting setup..."

    echo "keyboard-configuration keyboard-configuration/layoutcode string us" | sudo debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/xkb-keymap select us" | sudo debconf-set-selections

    echo "### SUL: Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y openbox feh conky lxterminal chromium-browser wget xserver-xorg-video-dummy

    echo "### SUL: Installing Discord PTB..."
    wget -O discord-ptb.deb "https://discordapp.com/api/download/ptb?platform=linux&format=deb"
    sudo apt install ./discord-ptb.deb -y
    rm discord-ptb.deb

    echo "### SUL: Installing Chrome Remote Desktop..."
    wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    sudo apt install ./chrome-remote-desktop_current_amd64.deb -y
    rm chrome-remote-desktop_current_amd64.deb

    echo "### SUL: Creating 2GB swap for stability..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    echo "### SUL: Disabling unnecessary services..."
    sudo systemctl disable cups.service
    sudo systemctl disable bluetooth.service
    sudo apt-get purge -y snapd || true

    echo "### SUL: Configuring Openbox..."
    mkdir -p "$HOME/Pictures/backgrounds"
    wget -O "$HOME/Pictures/backgrounds/bgr.jpg" https://syanic.github.io/files/su-lite/bgr.jpg
    chmod 644 "$HOME/Pictures/backgrounds/bgr.jpg"

    mkdir -p "$HOME/.config/openbox"
    cat <<EOL > "$HOME/.config/openbox/autostart"
xset -dpms
xset s off
feh --bg-fill "$HOME/Pictures/backgrounds/bgr.jpg" &
conky &
discord-ptb --disable-gpu --disable-smooth-scrolling --disable-features=UseOzonePlatform &
EOL

    mkdir -p "$HOME/.config/conky"
    cat <<EOL > "$HOME/.config/conky/conky.conf"
conky.config = {
    background = true,
    update_interval = 1,
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = true,
    alignment = 'top_left',
    gap_x = 10,
    gap_y = 10,
    use_xft = true,
    font = 'DejaVu Sans Mono:size=10',
    color1 = 'white',
};
conky.text = [[
Syanic Utility loaded successfully.
]];
EOL

    echo "### SUL: Openbox configured. Starting CRD setup..."
    remotedesktop
}

remotedesktop() {
    echo "### SUL: Paste your Chrome Remote Desktop's Debian SSH Command below >"
    read ssh_command

    echo "### SUL: Stopping any existing CRD sessions..."
    sudo pkill -f chrome-remote-desktop || true
    sleep 2

    echo "### SUL: Removing any existing CRD hosts..."
    existing_hosts=$(sudo /opt/google/chrome-remote-desktop/chrome-remote-desktop --list-hosts 2>/dev/null | grep -oP '(?<=\`)[a-f0-9\-]+(?=\`)')
    if [ -n "$existing_hosts" ]; then
        for host in $existing_hosts; do
            sudo /opt/google/chrome-remote-desktop/chrome-remote-desktop --remove-host="$host"
            echo "### SUL: Removed host: $host"
        done
    else
        echo "### SUL: No existing hosts found."
    fi

    random_number=$(( RANDOM % 101 + 1 ))
    modified_command=${ssh_command//DISPLAY=/}
    modified_command=${modified_command/--name=\$(hostname)/--name=\"Sub to Syanic XD ($random_number)\"}
    modified_command+=" --pin=111111 --size=1280x720"
    export CHROME_REMOTE_DESKTOP_DEFAULT_FRAME_RATE=30

    echo "### SUL: Starting CRD host..."
    output=$(eval "$modified_command" 2>&1)
    sleep 5
    echo "$output"

    if echo "$output" | grep -q "OAuth error"; then
        echo "### SUL: Error (OAuth) -> Please provide a new SSH command."
        ./syanic_utility_lite.sh
    elif echo "$output" | grep -q "Host started successfully."; then
        echo "### SUL: Machine is ready! Name: [Sub to Syanic XD ($random_number)], PIN: 111111"
    fi
}

main() {
    echo ""
    echo "===== SYANIC UTILITY LITE (SUL) ====="
    echo "Made by Syanic XD on YouTube <3"
    echo ""
    echo "Options:"
    echo "1. Setup Minimal Openbox + CRD + Discord PTB (Lite)"
    echo "2. Start CRD (if already setup)"
    echo "3. Exit"
    echo ""
    read -p "Select an option (1/2/3): " option

    case $option in
        1) setup ;;
        2) remotedesktop ;;
        3) echo "### SUL: Exiting..."; exit 0 ;;
        *) echo "SUL: Invalid option."; main ;;
    esac
}

main
 
