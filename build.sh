#!/bin/bash

# Written by Jhuan Reategui <chijure100x100to@gmail.com>

daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
vendor=huawei

export target=y210
export defconfig=Phoenix_defconfig

export compiler=~/arm-eabi-4.4.3/bin/arm-eabi- 

cd $location
export ARCH=arm
export CROSS_COMPILE=$compiler
if [ -z "$clean" ]; then
read -p "do make clean mrproper?(y/n)" clean
fi # [ -z "$clean" ]
case "$clean" in
y|Y ) echo "cleaning..."; make clean mrproper;;
n|N ) echo "continuing...";;
* ) echo "invalid option"; sleep 2 ; build.sh;;
esac

echo "now building the kernel"

make $defconfig
make -j81


if [ -f arch/arm/boot/zImage ]; then

rm -f zip-creator/zImage
rm -rf zip-creator/system/


mkdir -p zip-creator/system/lib/modules

cp arch/arm/boot/zImage zip-creator/

find . -name *.ko | xargs cp -a --target-directory=zip-creator/system/lib/modules/

zipfile="Phoenix-2.6.x-$target-$daytime.zip"
cd zip-creator
rm -f *.zip
zip -r $zipfile * -x *kernel/.gitignore*

echo "zip saved to zip-creator/$zipfile"

else # [ -f arch/arm/boot/zImage ]
echo "the build failed so a zip won't be created"
fi # [ -f arch/arm/boot/zImage ]

