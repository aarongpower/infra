#!/usr/bin/env bash

# User's home and VM directory
USER_HOME=$HOME
VM_DIR=$USER_HOME/.windows-vm
OVMF_VARS_ORIGINAL=__OVMF_VARS.fd__
OVMF_VARS_DESTINATION=$VM_DIR/OVMF_VARS.fd

# Create VM dir if it doesn't exist
mkdir -p $VM_DIR

# Copy OVMF_VARS.fd to VM dir if it doesn't exist
if [ ! -f $OVMF_VARS_DESTINATION ]; then
    cp $OVMF_VARS_ORIGINAL $OVMF_VARS_DESTINATION
fi

echo "Starting Windows VM..."
sudo __qemu-system-x86_64__ \
    -enable-kvm \
    -m 32G \
    -cpu host \
    -drive file=/dev/nvme0n1p3,format=raw \
    -drive if=pflash,format=raw,readonly=on,file=__OVMF_CODE.fd__ \
    -drive if=pflash,format=raw,file=$OVMF_VARS_DESTINATION \
    -net nic \
    -net user \
    -vga virtio