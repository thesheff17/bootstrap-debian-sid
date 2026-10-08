# bootstrap-debian-sid

### what is this?
These are my personal tools to bootstrap debian sid.  

It is a public repo to make it easier to use on github.com

Feel free to use but use at your own RISK!  These scripts format hard drives.  Your data will be destroyed if you are not careful.  You have been warned.  Do not run `stage1.sh` or `stage2.sh` unless you know what it is doing.

### Why make this?

As I look at it I want a minimal linux distro package install with a basic GUI.  You can pick either the xfce, gnome, or none for the desktop env.  Right now it defaults to xfce.  Installation times for me are also extremely fast with even the most basic hardware.  See below for a custom apt cache mirror setup(apt-cache-ng).

### Overview of scripts in repo

* `stage1.sh` - runs most of the basic prepare commands to install linux.  Should be as fast as possible.
* `stage2.sh` - runs inside the chroot env to bootstrap linux. Should be as fast as possible.  `stage2.sh` is called by `stage1.sh` so you don't have to call it directly.
* `add_sudo_debian_nopasswd.sh` - run this after the system boots to exclude debian user from entering a sudo password.
* `post_install.sh` - Should be ran after the linux system boots.  Everything else that is time consuming.  I don't care about speed in this script.  Run when you have time on your system.

### Download live standard ISO
I use [debian-live-13.7.0-amd64-standard.iso](https://cdimage.debian.org/debian-cd/13.7.0-live/amd64/iso-hybrid/) and the hash can be find [here](https://cdimage.debian.org/debian-cd/13.7.0-live/amd64/iso-hybrid/SHA256SUMS).


### apt-cache-ng

I prep 1 virtual machine as my apt proxy using [apt-cache-ng](https://www.unix-ag.uni-kl.de/~bloch/acng/).  I also give a decent amount of hard drive space.
```bash
sudo apt update
# select yes if you want to listen on http during install
sudo apt install -y apt-cacher-ng
sudo systemctl enable --now apt-cacher-ng
sudo systemctl status apt-cacher-ng
```

### comands to run after live cd boots.  I embed this in the iso as `run.sh` script and run as root.

Example of `run.sh`
```bash
#!/bin/bash 
passwd user
apt install -y ssh
systemctl start ssh
wget https://raw.githubusercontent.com/thesheff17/bootstrap-debian-sid/refs/heads/main/stage1.sh
chmod +x ./stage1.sh
ip addr show # get ip address
```

### Run `stage1.sh` once you ssh into the instance.
```bash
./stage1.sh
```

### Faster testing (Unsafe)

For even faster testing I change a proxmox disk cache setting to: `Write Back (Unsafe)` during setup.  This can reduce the time another 45 seconds or so with this setting.  Use at your own risk though it is Unsafe for a reason.  You can read more about them [here](https://forum.proxmox.com/threads/disk-cache-wiki-documentation.125775/).

### make a custom ISO with a `run.sh` bash script (still testing)

install tools
```bash
apt update
apt install xorriso squashfs-tools
```

extract the ISO
```bash
mkdir -p ~/iso_unpack ~/squashfs_root
xorriso -osirrox on -indev debian-live-13.7.0-amd64-standard.iso -extract / ~/iso_unpack
unsquashfs -d ~/squashfs_root ~/iso_unpack/live/filesystem.squashfs
```

add your custom bash script:
```bash
cd ~/squashfs_root/usr/local/bin/
wget http://xxx.xx.xx.xx/run.sh
chmod +x ./run.sh
```

repack
```bash
rm ~/iso_unpack/live/filesystem.squashfs
mksquashfs ~/squashfs_root ~/iso_unpack/live/filesystem.squashfs -comp xz
```

generate new ISO:
```bash
xorriso -indev debian-live-13.7.0-amd64-standard.iso \
        -outdev debian-live-custom.iso \
        -blank as_needed \
        -boot_image any replay \
        -map ~/iso_unpack / \
        -commit
```

This is what my `run.sh` looks like this:
```bash
#!/bin/bash

sudo passwd user
sudo apt install -y ssh
sudo systemctl start ssh
wget https://raw.githubusercontent.com/thesheff17/bootstrap-debian-sid/refs/heads/main/stage1.sh
chmod +x stage1.sh
ip addr show | grep 192
```