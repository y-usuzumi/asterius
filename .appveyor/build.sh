#!/usr/bin/sh -e

pacman -S --needed --noconfirm --noprogressbar \
    autoconf \
    automake \
    bsdtar \
    git \
    make \
    mingw-w64-x86_64-binutils \
    mingw-w64-x86_64-ca-certificates \
    mingw-w64-x86_64-curl \
    mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-libtool \
    mingw-w64-x86_64-python2 \
    mingw-w64-x86_64-tools-git \
    mingw-w64-x86_64-xz \
    patch \
    p7zip \
    tar

stack --resolver nightly --skip-msys setup > /dev/null
stack --skip-msys install \
    alex \
    happy \
    hscolour
export PATH=$APPDATA/local/bin:$(stack path --compiler-bin --skip-msys):$PATH

cd ghc
mv ../.appveyor/build.mk mk/
./boot
./configure --enable-tarballs-autodownload
make -j5
XZ_OPT=-0 make binary-dist
