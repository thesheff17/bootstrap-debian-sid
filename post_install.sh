#!/usr/bin/env bash

# this script should be ran after you boot into the linux distro
# stage2.sh should be fast as possible.  Anything else that takes
# time should be contained in this script.  

# clear
clear

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

USE_COLORS="yes"

color() {
    if [ "$USE_COLORS" = "yes" ]; then
        printf '%b' "$1$2${NC}\n"
    else
        printf '%b' "$2\n"
    fi
}

if [ "$(id -u)" -eq 0 ]; then
  color "$RED" "Please run as a non root user with sudo access."
  color  "$RED" "This is a requirement of the brew software."
  exit 1
fi

START_TIME=$SECONDS

# run update
sudo apt update

# install my tools - skip if directory exists
DIR1="/home/debian/git/"
if [ ! -d "$DIR1" ]; then
    mkdir /home/debian/git/
    mkdir /home/debian/.virtualenvs
    cd /home/debian/git/
    git clone https://github.com/thesheff17/bash_banner.git
    git clone https://github.com/thesheff17/sheff-ll.git
    git clone https://github.com/thesheff17/bootstrap-debian-sid.git
fi

# install brew - skip if directory exists
DIR2="/home/linuxbrew/.linuxbrew"
if [ ! -d "$DIR2" ]; then
    color "$GREEN" "installing homebrew."

    sudo mkdir -p /home/linuxbrew/.linuxbrew
    sudo chown -R debian:debian /home/linuxbrew/.linuxbrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> /home/debian/.bashrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/debian/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

    # install brew packages
    brew install -y go ffmpeg-full ansible node fzf openjdk

    # install extra python versions if you need them
    brew install -y python@3.11 python@3.12 python@3.13
fi

# vscodium https://vscodium.com - skip if /usr/bin/codium exists
FILE1="/usr/bin/codium"
if [ ! -f "$FILE1" ]; then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

    echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
    | sudo tee /etc/apt/sources.list.d/vscodium.sources
    sudo apt install codium -y
fi 

# extra packages
sudo apt install firefox geany spyder timeshift python3-pylsp python3-pylsp-ruff ruff python3-qtconsole -y

# docker
FILE2="/usr/bin/docker"
if [ ! -f "$FILE2" ]; then
    color "$GREEN" "installing docker."
    sudo apt install ca-certificates gnupg -y
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Docker official repository setup using 'bookworm' fallback for Debian Sid (forky)
    DOCKER_CODENAME="bookworm"

    sudo echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    ${DOCKER_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list

    sudo apt-get update -y

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable --now docker

    sudo usermod -aG docker debian
fi

#permissions 
# fix permissions
sudo chown -R debian:debian /home/debian

# update locate db
sudo updatedb

# elasped time
ELASPED_SECONDS=$(( SECONDS - START_TIME ))

# Convert seconds to Minutes, and Seconds
MIN=$(( (ELASPED_SECONDS % 3600) / 60 ))
SEC=$(( ELASPED_SECONDS % 60 ))
printf "Total elapsed time: %02dm:%02ds (%d total seconds)\n" "$MIN" "$SEC" "$ELASPED_SECONDS"

color "$GREEN" "You should consider rebooting the system."
color "$GREEN" "post_install.sh completed."
read -r -p "Press [ENTER] to reboot, or Ctrl+C to cancel..."
sudo reboot
