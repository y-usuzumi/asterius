#!/usr/bin/sh -e

pacman -S --noconfirm --noprogressbar \
    mingw-w64-x86_64-python2-sphinx

stack --resolver nightly --skip-msys setup > /dev/null
stack --skip-msys install \
    alex \
    happy \
    hscolour
export PATH=~/.local/bin:$(stack path --compiler-bin --skip-msys):$PATH

cd /tmp/.appveyor/ghc
mv ../build.mk mk/
./boot
./configure --enable-tarballs-autodownload
make -j5
make binary-dist
