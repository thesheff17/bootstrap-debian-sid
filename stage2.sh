#!/usr/bin/env bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

USE_COLORS="yes"

color() {
    if [ "$USE_COLORS" = "yes" ]; then
        printf '%b' "$1$2${NC}"
    else
        printf '%b' "$2"
    fi
}

# this script is the 2nd stage of debian sid
# bootstrap setup.  This script should be ran
# inside the chroot env

if [ "$EUID" -ne 0 ]; then
  color "$RED" "Please run as root.\n"
  exit 1
fi

# Set default to xfce if no parameter provided
DESKTOP_ENV="${1:-xfce}"

# Validate input
if [[ ! "$DESKTOP_ENV" =~ ^(xfce|gnome|none)$ ]]; then
  color "$RED" "Error: Invalid desktop environment. Use 'xfce', 'gnome', or 'none'\n"
  exit 1
fi

# generate new sources.list and update
cat <<EOF > /etc/apt/sources.list
deb http://192.168.1.194:3142/deb.debian.org/debian/ sid main contrib non-free non-free-firmware
EOF

apt update

echo "debian-sid" > /etc/hostname
sed -i 's/127\.0\.0\.1[[:space:]]\+localhost$/127.0.0.1   localhost debian-sid/' /etc/hosts

# Set desktop packages based on environment
if [ "$DESKTOP_ENV" = "xfce" ]; then
  DESKTOP_PACKAGES="xfce4 xfce4-goodies lightdm network-manager timeshift firefox"
  DM_SERVICE="lightdm"
elif [ "$DESKTOP_ENV" = "gnome" ]; then
  DESKTOP_PACKAGES="gnome-shell gnome-core gdm3 network-manager timeshift firefox"
  DM_SERVICE="gdm3"
else
  # none option - skip GUI installation
  DESKTOP_PACKAGES=""
  DM_SERVICE=""
fi

# apt install
DEBIAN_FRONTEND=noninteractive apt install -y \
    sudo locales \
    linux-image-amd64 firmware-linux grub-pc \
    $DESKTOP_PACKAGES \
    htop vim ssh git wget curl build-essential python3-venv \
    sysstat qemu-guest-agent tmux btop

# Configure Timezone and Locales
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/default/locale
locale-gen

# Create user and install sudo
useradd -m -G sudo -s /bin/bash debian

# set default passwords
echo "root:debian123123" | chpasswd
echo "debian:debian123123" | chpasswd

# enable services
if [ -n "$DM_SERVICE" ]; then
  systemctl enable "$DM_SERVICE"
  systemctl enable NetworkManager
else
  # we have to setup the network manually if we are not using NetworkManger package
  echo ''  >> /etc/network/interfaces
  echo 'auto ens18' >> /etc/network/interfaces
  echo 'allow-hotplug ens18' >> /etc/network/interfaces
  echo 'iface ens18 inet dhcp' >> /etc/network/interfaces
  systemctl enable networking
fi
systemctl enable ssh

# prep my bash banner script 
mkdir /home/debian/git/
mkdir /home/debian/.virtualenvs
cd /home/debian/git/
git clone https://github.com/thesheff17/bash_banner.git
git clone https://github.com/thesheff17/sheff-ll.git
chown -R debian:debian /home/debian

# Install GRUB to sda
grub-install /dev/sda
update-grub

sync

color "$GREEN" "stage2.sh completed.\n"
