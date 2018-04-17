# Configure the environment
MSYSTEM=MINGW64
THREADS=5
# SKIP_PERF_TESTS=YES
source /etc/profile || true # a terrible, terrible workaround for msys2 brokenness

# Don't set -e until after /etc/profile is sourced
set -ex
cd $APPVEYOR_BUILD_FOLDER

case "$1" in
    "prepare")
        # Prepare the tree
        # git config remote.origin.url git://github.com/ghc/ghc.git
        # git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/gh
        # c/packages/
        git submodule init
        git submodule --quiet update --recursive
        pacman -S autoconf coreutils make mingw-w64-x86_64-cmake mingw-w86_64-gcc --needed --noconfirm --noprogressbar stack
        cd ghc
        git rev-parse HEAD > git-rev-sha1
        ;;
    "build-ghc")
        # Build the compiler
        if ! [ -f ghc/ghc-compiled ]
        then
          cp -v .appveyor/build.mk ghc/mk/build.mk
          cd ghc
          ./boot
          ./configure --enable-tarballs-autodownload
          make -j$THREADS
        fi
        ;;
    "build-asterius")
        stack --no-terminal --skip-msys setup # > NUL
        # mklink /D %LOCALAPPDATA%\\Programs\\stack\\x86_64-windows\\msys2-20161025 C:\\msys64
        # copy %LOCALAPPDATA%\\Programs\\stack\\x86_64-windows\\ghc-8.5.*.installed %LOCALAPPDATA%\\Programs\\stack\\x86_64-windows\\msys2-20161025.installed
        # stack --no-terminal exec pacman -- -S autoconf coreutils make mingw-w64-x86_64-cmake mingw-w64-x86_64-gcc --needed --noconfirm --noprogressbar
        stack --no-terminal test wasm-toolkit:nir-test
        stack --no-terminal test asterius:fact-dump
        stack --no-terminal exec ahc-boot
        ;;
    *)
        echo "$0: unknown mode $1"
        exit 1
        ;;
esac
