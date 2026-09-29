#!/usr/bin/env bash

# clear
clear

echo "=================================================="
echo "                   WARNING                        "
echo "=================================================="
echo "This script is EXTREMELY DESTRUCTIVE."
echo "Executing this will format your hard drive and"
echo "permanently erase ALL data."
echo "You have been warned."
echo "=================================================="
echo

# Prompt the user for confirmation
read -rp "Type 'YES' (all uppercase) to proceed with formatting: " USER_INPUT

# Check if the user entered exactly 'YES'
if [ "$USER_INPUT" != "YES" ]; then
    echo "Aborting operation. No changes were made."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

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

debootstrap --arch=amd64 sid /mnt http://192.168.1.191:3142/deb.debian.org/debian/

genfstab -U /mnt >> /mnt/etc/fstab

for dir in /dev /dev/pts /proc /sys /run; do mount --bind $dir /mnt$dir; done

# wget stage2.sh script
wget -P /mnt/ https://raw.githubusercontent.com/thesheff17/bootstrap-debian-sid/refs/heads/main/stage2.sh
chmod +x /mnt/stage2.sh

# calling stage2.sh in the chroot env
# you can pass gnome, xfce, or none to the stage2.sh script
# default is xfce
chroot /mnt /bin/bash /stage2.sh

echo "sleeping 3 seconds then unmounting the file system."
sync
sleep 3

# Unmount all mounted filesystems cleanly
cd /
sync
umount -R /mnt

echo "debian sid install completed."
echo "you should remove the live cd after rebooting."
echo "if the live cd boots again your boot order is set to the live cd first."
echo "please fix and reboot again."

# elasped time
ELASPED_SECONDS=$(( SECONDS - START_TIME ))

# Convert seconds to Minutes, and Seconds
MIN=$(( (ELASPED_SECONDS % 3600) / 60 ))
SEC=$(( ELASPED_SECONDS % 60 ))
printf "Total elapsed time: %02dm:%02ds (%d total seconds)\n" "$MIN" "$SEC" "$ELASPED_SECONDS"

read -r -p "Press [ENTER] to reboot, or Ctrl+C to cancel..."
sudo reboot
