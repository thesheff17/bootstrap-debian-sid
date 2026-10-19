#!/usr/bin/env bash

# this script will help bootstrap a live cd 

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root privileges exiting..."
    exit 1
fi

# install ssh
apt get install ssh -y
systemctl start ssh

echo "sleeping 3 seconds..."
sleep 3

# get my keys file from a webserver
mkdir -p /root/.ssh/
wget -P /root/.ssh/ http://192.168.1.3/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "Configuring SSH to allow root login..."
# Use a drop-in configuration file if /etc/ssh/sshd_config.d exists (recommended for modern Linux),
# otherwise fallback to modifying sshd_config directly.
if [[ -d /etc/ssh/sshd_config.d ]]; then
    cat << 'EOF' > /etc/ssh/sshd_config.d/01-allow-root.conf
PermitRootLogin yes
PasswordAuthentication yes
EOF
    echo "Created drop-in configuration at /etc/ssh/sshd_config.d/01-allow-root.conf"
else
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "Updated /etc/ssh/sshd_config directly."
fi

echo "Restarting SSH service..."
systemctl restart ssh

echo "pre_setup.sh completed"