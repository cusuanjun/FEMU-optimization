#!/bin/bash

IODA_IMGDIR="./images/"
# IODA_KERNEL="src/iodaLinux-5.4.121/arch/x86/boot/bzImage"
IODA_FEMU="src/iodaFEMU-b13b482/build-femu/x86_64-softmmu/qemu-system-x86_64"

echo 2 | sudo tee /sys/kernel/mm/ksm/run >/dev/null 2>&1
echo "===> Booting the IODA Virtual Machine..."

# 创建共享目录（如果不存在）
mkdir -p ~/ioda-shared

sudo ${IODA_FEMU} \
    -name "iodaVM" \
    -cpu host \
    -smp 8 \
    -m 4G \
    -enable-kvm \
    -boot menu=on \
    -drive file=${IODA_IMGDIR}/ioda.qcow2,if=virtio,cache=none,format=qcow2 \
    -device femu,devsz_mb=12288,femu_mode=1 \
    -netdev user,id=user0,hostfwd=tcp::10101-:22 \
    -device virtio-net-pci,netdev=user0 \
    -virtfs local,path=/home/mengjingxuan/ioda-shared,mount_tag=hostshare,security_model=none,id=hostshare \
    -serial mon:stdio \
    -nographic | tee ./ioda-femu.log 2>&1