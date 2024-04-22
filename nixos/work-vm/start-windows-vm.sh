#!/usr/bin/env bash

# User's home and VM directory
USER_HOME=$HOME
VM_DIR=/mnt/bigboy/vm/work
TPM_TEMP_DIR=/tmp/worktpm1
TPM_STATE_DIR=$VM_DIR/tpm
OVMF_VARS_ORIGINAL=__OVMF_VARS.fd__
OVMF_VARS_DESTINATION=$VM_DIR/OVMF_VARS.fd

# Create VM dir if it doesn't exist
mkdir -p $VM_DIR

# Copy OVMF_VARS.fd to VM dir if it doesn't exist
if [ ! -f $OVMF_VARS_DESTINATION ]; then
    cp $OVMF_VARS_ORIGINAL $OVMF_VARS_DESTINATION
fi

# # Set up persistent TPM state
# echo "Starting TPM..."
# mkdir -p $TPM_TEMP_DIR
# mkdir -p $TPM_STATE_DIR
# __swtpm__ socket --tpmstate dir=$TPM_STATE_DIR --ctrl type=unixio,path=$TPM_TEMP_DIR/swtpm-sock --log level=20 > $VM_DIR/tpm.log 2>&1 &

# Check for ISO file argument
ISO_FILE=""
if [ "$#" -eq 1 ]; then
    ISO_FILE=$1
    echo "Booting from ISO: $ISO_FILE"
fi

# Construct QEMU Command
# QEMU_CMD="__qemu-system-x86_64__ \
#     -enable-kvm \
#     -m 16G \
#     -smp 8,sockets=1,cores=4,threads=2 \
#     -cpu host \
#     -drive file=$VM_DIR/work_disk.img,format=qcow2 \
#     -drive if=pflash,format=raw,readonly=on,file=__OVMF_CODE.fd__ \
#     -drive if=pflash,format=raw,file=$OVMF_VARS_DESTINATION \
#     -chardev socket,id=chrtpm,path=$TPM_TEMP_DIR/swtpm-sock -tpmdev emulator,id=tpm0,chardev=chrtpm -device tpm-tis,tpmdev=tpm0 \
#     -net nic \
#     -net user \
#     $(if [ -n "$ISO_FILE" ]; then echo "-drive file=$ISO_FILE,index=1,media=cdrom -boot order=d"; fi) \
#     -display sdl"

QEMU_CMD="__qemu-system-x86_64__ \
    -enable-kvm \
    -m 16G \
    -smp 8,sockets=1,cores=4,threads=2 \
    -cpu host \
    -drive file=$VM_DIR/work_disk.img,format=qcow2 \
    -drive if=pflash,format=raw,readonly=on,file=__OVMF_CODE.fd__ \
    -drive if=pflash,format=raw,file=$OVMF_VARS_DESTINATION \
    -tpmdev passthrough,id=tpm0,path=/dev/tpm0 \
    -device tpm-tis,tpmdev=tpm0 \
    -net nic \
    -net user \
    $(if [ -n "$ISO_FILE" ]; then echo "-drive file=$ISO_FILE,index=1,media=cdrom -boot order=d"; fi) \
    -display sdl"

# Echo the command
echo "Executing QEMU command:"
echo $QEMU_CMD

# Execute the command
eval $QEMU_CMD
