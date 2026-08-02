#!/bin/bash

# Written by Jhuan Reategui <reateguisolisjm@gmail.com>

daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
vendor=huawei

export target=y210
export defconfig=${defconfig:-y210_defconfig}
# export defconfig=Phoenix_defconfig
# export defconfig=y210_twrp_defconfig

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

# Start time tracking
start_time=$(date +%s)

rm -f arch/arm/boot/zImage
make $defconfig
defconfig_status=$?
set -o pipefail
if [ "$defconfig_status" -eq 0 ]; then
	make -j$(nproc --all) 2>&1 | tee build.log
	build_status=${PIPESTATUS[0]}
else
	build_status=$defconfig_status
fi
set +o pipefail


# Calculate compilation time
end_time=$(date +%s)
compilation_time=$((end_time - start_time))
minutes=$((compilation_time / 60))
seconds=$((compilation_time % 60))


if [ "$build_status" -eq 0 ] && [ -f arch/arm/boot/zImage ]; then

rm -f zip-creator/zImage
rm -rf zip-creator/system/


mkdir -p zip-creator/system/lib/modules

cp arch/arm/boot/zImage zip-creator/

rm -f zip-creator/system/lib/modules/*.ko
if [ "${package_modules:-0}" = "1" ] && [ -f modules.order ]; then
	while read -r module; do
		module="${module#kernel/}"
		if [ -f "$module" ]; then
			cp -a "$module" zip-creator/system/lib/modules/
		fi
	done < modules.order
elif [ "${package_modules:-0}" = "1" ]; then
	find . -path './zip-creator' -prune -o -name '*.ko' -print \
		| xargs -r cp -a --target-directory=zip-creator/system/lib/modules/
fi

zipfile="$defconfig-2.6.x-$target-$daytime.zip"
cd zip-creator
rm -f *.zip
zip -r $zipfile * \
	-x *kernel/.gitignore* \
	-x META-INF/CERT.RSA \
	-x META-INF/CERT.SF \
	-x META-INF/MANIFEST.MF

echo "==============================================="
echo "Compilation successful!"
echo "Time elapsed: ${minutes} minutes and ${seconds} seconds"
echo "==============================================="


echo "zip saved to zip-creator/$zipfile"

else # [ -f arch/arm/boot/zImage ]
echo "==============================================="
echo "Build failed after ${minutes} minutes and ${seconds} seconds"
echo "==============================================="
echo "the build failed so a zip won't be created"
fi # [ -f arch/arm/boot/zImage ]
