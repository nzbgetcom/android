#!/bin/sh
set -e

BUSYBOX_VERSION=1.28.3
TOOLCHAIN_PATH=/build/android
ALL_ARCHS="i686 x86_64 armhf aarch64"

mkdir -p build/busybox
cd build/busybox
rm -rf *

rm -rf "busybox-$BUSYBOX_VERSION"
if [ ! -f "busybox-$BUSYBOX_VERSION.tar.bz2" ]; then
    curl -O "https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2"
fi

for ARCH in $ALL_ARCHS; do

    tar xf "busybox-$BUSYBOX_VERSION.tar.bz2"

    cd busybox-$BUSYBOX_VERSION
    cp ../../../app/src/main/jniLibs/busybox.config .config

    case $ARCH in
        i686)
            CONFIG_CROSS_COMPILER_PREFIX="i686-linux-android"
            ;;
        x86_64)
            CONFIG_CROSS_COMPILER_PREFIX="x86_64-linux-android"
            ;;
        armhf)
            CONFIG_CROSS_COMPILER_PREFIX="arm-linux-androideabi"
            ;;
        aarch64)
            CONFIG_CROSS_COMPILER_PREFIX="aarch64-linux-android"
            ;;
    esac

    sed -i "s|^CONFIG_CROSS_COMPILER_PREFIX=.*|CONFIG_CROSS_COMPILER_PREFIX=\"$CONFIG_CROSS_COMPILER_PREFIX-\"|" -i .config
    if [ "$ARCH" == "i686" ]; then
        sed -i "s|^CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS=\"-D__ANDROID_API__=21\"|" -i .config
    fi

    _PATH=$PATH
    export PATH="$TOOLCHAIN_PATH/$ARCH-ndk/output/host/usr/bin/:$PATH"
    make -j 4
    make install -j 4

    mkdir -p ../$ARCH
    cp _install/bin/busybox ../$ARCH/libbusybox.so

    export PATH=$_PATH
    cd ..
    rm -rf busybox-$BUSYBOX_VERSION
done

# rename archs
mv aarch64 arm64-v8a
mv armhf armeabi
mv i686 x86
