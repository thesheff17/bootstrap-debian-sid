#!/usr/bin/env bash

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

color "$NC"  "=================================================="
color "$RED" "                   WARNING                        "
color "$NC"  "=================================================="
color "$RED"  "This script is EXTREMELY DESTRUCTIVE."
color "$RED"  "Executing this will format your hard drive and"
color "$RED"  "permanently erase ALL data."
color "$RED"  "You have been warned."
color "$NC"  "=================================================="
printf "\n"

# Prompt the user for confirmation
read -rp "Type 'YES' (all uppercase) to proceed with formatting: " USER_INPUT

# Check if the user entered exactly 'YES'
if [ "$USER_INPUT" != "YES" ]; then
    color "$RED" "Aborting operation. No changes were made."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
  color "$RED" "Please run as root."
  exit 1
fi

# Set default apt cache mirror
APT_MIRROR="${1:-192.168.1.194}"

START_TIME=$SECONDS

apt -y install dosfstools parted debootstrap arch-install-scripts vim wget

# hard drive partitioning
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 2MiB
parted -s /dev/sda set 1 bios_grub on
parted -s /dev/sda mkpart primary linux-swap 2MiB 1538MiB
parted -s /dev/sda mkpart primary ext4 1538MiB 100%
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3

mount  /dev/sda3 /mnt

debootstrap --arch=amd64 sid /mnt http://${APT_MIRROR}:3142/deb.debian.org/debian/

genfstab -U /mnt >> /mnt/etc/fstab

for dir in /dev /dev/pts /proc /sys /run; do mount --bind $dir /mnt$dir; done

# wget stage2.sh script
wget -P /mnt/ https://raw.githubusercontent.com/thesheff17/bootstrap-debian-sid/refs/heads/main/stage2.sh
chmod +x /mnt/stage2.sh

# calling stage2.sh in the chroot env
# you can pass gnome, xfce, or none to the stage2.sh script
# default is xfce

# you can also change the apt mirror if needed
chroot /mnt /bin/bash /stage2.sh

color "$NC" "sleeping 3 seconds then unmounting the file system."
sleep 3

# Unmount all mounted filesystems cleanly
cd /
umount -R /mnt

color "$GREEN" "debian sid install completed."
color "$GREEN" "you should remove the live cd after rebooting."
color "$GREEN" "if the live cd boots again your boot order is set to the live cd first."
color "$GREEN" "please fix and reboot again."

# elasped time
ELASPED_SECONDS=$(( SECONDS - START_TIME ))

# Convert seconds to Minutes, and Seconds
MIN=$(( (ELASPED_SECONDS % 3600) / 60 ))
SEC=$(( ELASPED_SECONDS % 60 ))
printf "Total elapsed time: %02dm:%02ds (%d total seconds)\n" "$MIN" "$SEC" "$ELASPED_SECONDS"

read -r -p "Press [ENTER] to reboot, or Ctrl+C to cancel..."
sudo reboot
