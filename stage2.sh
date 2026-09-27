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

# Install Linux kernel and GRUB bootloader
# apt install -y linux-image-amd64 grub-efi-amd64 firmware-linux
DEBIAN_FRONTEND=noninteractive apt install -y linux-image-amd64 firmware-linux grub-pc

# Install Xfce desktop, display manager, and NetworkManager
apt install -y xfce4 xfce4-goodies lightdm network-manager

# install some other base packages
apt install -y tmux htop vim ssh git wget curl build-essential python3-venv sysstat timeshift qemu-guest-agent

# enable services
systemctl enable NetworkManager
systemctl enable lightdm
systemctl enable ssh

# prep my bash banner script
mkdir ~/git/
mkdir ~/.virtualenvs
cd ~/git/
git clone https://github.com/thesheff17/bash_banner.git

# Install GRUB to sda
grub-install /dev/sda
update-grub

# output telling the user to type exit to return to stage1.sh
# and exit the chroot env.
echo "stage2.sh completed."
echo "type exit to return to stage1.sh."
echo "this will exist the chroot env."
