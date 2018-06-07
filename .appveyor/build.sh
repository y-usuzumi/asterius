#!/bin/sh -e

mkdir -p ~/.local/bin
stack --skip-msys install \
    alex \
    happy \
    hscolour
export PATH=~/.local/bin:$(stack path --compiler-bin):$PATH

cd /tmp/.appveyor/ghc
mv ../build.mk mk/
./boot
./configure --enable-tarballs-autodownload
make -j5
make binary-dist
