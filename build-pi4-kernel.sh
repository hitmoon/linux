#!/bin/bash -e

BUILD=PI4
MOD_OUT=$PWD/pi4-mods

echo "Cleaning old out directory ..."

rm -rf $BUILD
rm -rf $MOD_OUT

echo "Start build new kernel ..."

make ARCH=arm64 O=$BUILD bcm2711_defconfig
make ARCH=arm64 O=$BUILD pi4-kvm.config

make ARCH=arm64 CFLAGS='-mtune=cortex-a72' O=$BUILD CROSS_COMPILE=aarch64-linux-gnu- -j8
make ARCH=arm64 O=$BUILD CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$MOD_OUT INSTALL_MOD_STRIP=1 modules_install

echo "Install new kernel to pi4 ..."

sudo rsync -r $MOD_OUT/lib/modules/ /lib/modules
sudo cp $BUILD/arch/arm64/boot/Image /boot/kernel8.img
sudo cp $BUILD/arch/arm64/boot/dts/broadcom/*.dtb /boot

echo "All done!"

