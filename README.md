# bootstrap-debian-sid

### what is this?
These are my personal tools to bootstrap debian sid.  

It is a public repo to make it easier to use on github.com

Feel free to use but use at your own RISK!  These scripts format hard drives.  Your data will be destroyed if you are not careful.  You have been warned.  Do not run `stage1.sh` or `stage2.sh` unless you know what it is doing.

### Why make this?

As I look at it I want the most minimal linux distro package install with a basic GUI.  I picked [xfce](https://www.xfce.org/) env since it is usually pretty lightweight.  Installation times for me are also extremely fast with even the most basic hardware.  See below for apt-cache-ng info.

### apt-cache-ng

I prep 1 virtual machine as my apt proxy using [apt-cache-ng](https://www.unix-ag.uni-kl.de/~bloch/acng/).
```bash
sudo apt update
# select yes if you want to listen on http during install
sudo apt install -y apt-cacher-ng
sudo systemctl enable --now apt-cacher-ng
sudo systemctl status apt-cacher-ng
```

After running this the first time: `/var/cache/apt-cacher-ng/` directory was 682MB. What is nice is this a mirror between your vm and the debian mirror.  It should work with any distro and any setup.  Replace with your own IP address in the shell scripts of your new apt-cacher-ng proxy.

### Where am I testing this?

I am testing this inside a proxmox 9.2.20 env.

### How fast is the install

I'm still testing but so far seems very fast.

### Run the script after you have ssh setup
```
wget
chmod +x ./stage1.sh
./stage1.sh
```