#!/bin/bash

VM_ID="$1"
SSH_ALIAS="$2"
DESKTOP_ENV="$3"
PROXMOX_ALIAS="proxmox"

# proxmox commands
echo "shutting down $VM_ID"
ssh $PROXMOX_ALIAS "qm stop $VM_ID -skiplock 1"
echo 'sleeping 3 seconds...'
sleep 3

ssh proxmox "qm rollback $VM_ID basic_setup_before_stage01"
echo 'sleeping 3 seconds..'
sleep 3

# commands inside the vm
ssh $SSH_ALIAS 'wget -P /root/ https://raw.githubusercontent.com/thesheff17/bootstrap-debian-sid/refs/heads/main/stage1.sh'
ssh $SSH_ALIAS 'chmod +x /root/stage1.sh'
scp sync_time.py $SSH_ALIAS:/root/
ssh $SSH_ALIAS '/root/sync_time.py'
sleep 3
ssh -t $SSH_ALIAS "TERM=xterm-256color echo YES | /root/stage1.sh $DESKTOP_ENV"