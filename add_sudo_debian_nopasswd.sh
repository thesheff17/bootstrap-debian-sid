#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Define user and output file
TARGET_USER="debian"
SUDOERS_FILE="/etc/sudoers.d/${TARGET_USER}"

# Create the sudoers drop-in file and set strict permissions
echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE"

# Validate syntax using visudo
if sudo visudo -cf "$SUDOERS_FILE"; then
    echo "Sudoers file successfully created and validated."
else
    echo "Syntax error detected! Removing invalid file."
    sudo rm -f "$SUDOERS_FILE"
    exit 1
fi