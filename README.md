# bootstrap-debian-sid

### what is this?
These are my personal tools to bootstrap debian sid.  

It is a public repo to make it easier to use on github.com

Feel free to use but use at your own RISK!  These scripts format hard drives.  Your data will be destroyed if you are not careful.  You have been warned.  Do not run `stage1.sh` or `stage2.sh` unless you know what it is doing.

### Why make this?

As I look at it I want the most minimal linux distro package install with a basic GUI.  I picked [xfce](https://www.xfce.org/) env since it is usually pretty lightweight.  Installation times for me are also extremely fast with even the most basic hardware.  See below for apt-cache-ng info.

### Download live standard ISO
I use [debian-live-13.7.0-amd64-standard.iso](https://cdimage.debian.org/debian-cd/13.7.0-live/amd64/iso-hybrid/) and the hash can be find [here](https://cdimage.debian.org/debian-cd/13.7.0-live/amd64/iso-hybrid/SHA256SUMS).


### apt-cache-ng

I prep 1 virtual machine as my apt proxy using [apt-cache-ng](https://www.unix-ag.uni-kl.de/~bloch/acng/).
```bash
sudo apt update
# select yes if you want to listen on http during install
sudo apt install -y apt-cacher-ng
sudo systemctl enable --now apt-cacher-ng
sudo systemctl status apt-cacher-ng
```

### comands to run after live cd boots
```bash
sudo passwd user
sudo apt install -y ssh
sudo systemctl start ssh
ip addr show # get ip address
```

### Run the script after you have ssh into the instance
```bash
wget https://raw.githubusercontent.com/thesheff17/bootstrap-debian-sid/refs/heads/main/stage1.sh
chmod +x ./stage1.sh
./stage1.sh
```

### Where am I testing this?

I am testing this inside a proxmox 9.2.20 env.

### How fast is the install?

I'm consistently getting sub 3 min on a proxmox vm with these specs:
```text
4 core CPU
4 GB of RAM
INLAND 4TB Gaming NVMe SSD
```

during testing:
`duration: - 2 minutes and 26 seconds elapsed.`