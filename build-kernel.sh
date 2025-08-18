#!/bin/sh

set -eE
export ARCH=arm
# ==================================================================
#export COMPILE_PATH="/opt/data/rv1126/sdk/rv1126_rv1109_sdk"
export COMPILE_PATH=".."
export CROSS_COMPILE="${COMPILE_PATH}/prebuilts/gcc/linux-x86/arm/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
export DEFCONFIG=rv1126_ubuntu_defconfig
export KERNEL_DTS=rv1126-nano
# ==================================================================
export DTB_PATH=arch/$ARCH/boot/dts/$KERNEL_DTS.dtb
export ROOTFS_PATH=rootfs.cpio.gz

echo "CONFIG_BLK_DEV_INITRD=y" > arch/$ARCH/configs/rd-temporary.config
make $DEFCONFIG rd-temporary.config
make $KERNEL_DTS.img -j$(nproc)
rm -f arch/$ARCH/configs/rd-temporary.config

rm -rf /tmp/lib/
make modules_install INSTALL_MOD_PATH=/tmp
cd /tmp/
tar czvf /tmp/lib_modules.tar.gz lib
cd -
cp /tmp/lib_modules.tar.gz ./

sed -i "/fdt {/ {n; s|data = .*|data = /incbin/(\"$DTB_PATH\");|}" boot4recovery.its
sed -i "/ramdisk {/ {n; s|data = .*|data = /incbin/(\"$ROOTFS_PATH\");|}" boot4recovery.its
./mk-fitimage.sh boot4recovery.its $ROOTFS_PATH arch/arm/boot/zImage $DTB_PATH resource.img boot.img arm $DTB_PATH
