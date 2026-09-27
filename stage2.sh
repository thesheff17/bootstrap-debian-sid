#!/bin/bash

# this script is the 2nd stage of debian sid
# bootstrap setup.  This script should be ran
# inside the chroot env

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# generate new sources.list and update
cat <<EOF > /etc/apt/sources.list
deb http://192.168.1.194:3142/deb.debian.org/debian/ sid main contrib non-free non-free-firmware
EOF

apt update

echo "debian-sid" > /etc/hostname
sed -i 's/127\.0\.0\.1[[:space:]]\+localhost$/127.0.0.1   localhost debian-sid/' /etc/hosts

# Configure Timezone and Locales
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
apt install -y locales
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/default/locale
locale-gen

# Create user and install sudo
apt install -y sudo
useradd -m -G sudo -s /bin/bash debian

# set default passwords
echo "root:debian123123" | chpasswd
echo "debian:debian123123" | chpasswd

# Install Linux kernel, boot loader, xfce, and custom tools
# combining these all into a single command
DEBIAN_FRONTEND=noninteractive apt install -y \
    linux-image-amd64 firmware-linux grub-pc \
    xfce4 xfce4-goodies lightdm network-manager \
    htop vim ssh git wget curl build-essential python3-venv \
    sysstat timeshift qemu-guest-agent firefox

# enable services
systemctl enable NetworkManager
systemctl enable lightdm
systemctl enable ssh

# prep my bash banner script 
mkdir /home/debian/git/
mkdir /home/debian/.virtualenvs
cd /home/debian/git/
git clone https://github.com/thesheff17/bash_banner.git
chown -R debian:debian /home/debian

# Install GRUB to sda
grub-install /dev/sda
update-grub

sync

echo "stage2.sh completed."
