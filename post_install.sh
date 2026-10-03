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

# install brew
sudo mkdir -p /home/linuxbrew/.linuxbrew
sudo chown -R debian:debian /home/linuxbrew/.linuxbrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /home/debian/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/debian/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# install brew packages
brew install --cask vscodium
brew install -y go ffmpeg-full ansible node fzf openjdk

# install extra python versions if you need them
brew install -y python@3.11 python@3.12 python@3.13

# update locate db
sudo updatedb

# elasped time
ELASPED_SECONDS=$(( SECONDS - START_TIME ))

# Convert seconds to Minutes, and Seconds
MIN=$(( (ELASPED_SECONDS % 3600) / 60 ))
SEC=$(( ELASPED_SECONDS % 60 ))
printf "Total elapsed time: %02dm:%02ds (%d total seconds)\n" "$MIN" "$SEC" "$ELASPED_SECONDS"

color "$GREEN" "post_install.sh completed."
