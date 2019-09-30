# brew install luajit mujs libass

# use the llvm compiler
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

# set up shortcuts
export MCB=${PWD}
export MES=${MCB}/base
export TARGET=${MCB}/dest
export CMPL=${MCB}/build
export PATH=${TARGET}/bin:$PATH

# extend the python modules path
# export PYTHONPATH="${TARGET}/lib/python2.7/site-packages/"

# set up the directories
mkdir -p ${TARGET}
mkdir -p ${CMPL}

if [[ "$1" == 'clean' ]];then
    if [[ "$2" == 'ressl' ]];then
        rm -rf "${CMPL}/"libressl*
        rm "${TARGET}/bin/openssl"
        rm -r "${TARGET}/include/openssl"
        rm "${TARGET}/include/tls.h"
        rm "${TARGET}/lib/libssl.a" "${TARGET}/lib/libcrypto.a" "${TARGET}/lib/libtls.a"
    fi
fi

echo "\n--------------------"
echo "[*] check ysam"
# next, yasm
if [[ -f "${TARGET}/lib/libyasm.a" && -f "${TARGET}/bin/yasm" ]];then
    echo "ysam exist!"
else
    # should work with yasm-1.3.0.tar.gz
    echo "begin build ysam ...\n"
    cd ${CMPL}
    tar xzpf ${MES}/yasm*.tar.gz
    cd yasm-*
    make clean
    ./configure --prefix=${TARGET} && make -j 8 && make install
    if [[ $? != 0 ]];then
        exit 1
    fi
fi
echo "----------------------"


echo "\n--------------------"
echo "[*] check pkg-config"
# next, pkg-config
if [[ -f "${TARGET}/bin/pkg-config" ]];then
    echo "pkg-config exist!"
else
    # should work with pkg-config-0.29.1.tar.gz
    echo "begin build pkg-config ...\n"
    cd ${CMPL}
    tar xzpf ${MES}/pkg-config-*.tar.gz
    cd pkg-config-*
    make clean
    export LDFLAGS="-framework Foundation -framework Cocoa"
    ./configure --prefix=${TARGET} --with-pc-path=${TARGET}/lib/pkgconfig --with-internal-glib && make -j 8 && make install
    if [[ $? != 0 ]];then
        exit 1
    fi
    unset LDFLAGS
fi
echo "----------------------"


echo "\n--------------------"
echo "[*] check libressl"
# next, libressl
if [[ -f "${TARGET}/lib/libtls.a" && -f "${TARGET}/lib/libssl.a"  && -f "${TARGET}/lib/libcrypto.a" ]];then
    echo "libressl exist!"
else
    # should work with libressl-2.4.2.tar.gz
    echo "begin build libressl ...\n"
    cd ${CMPL}
    tar xzpf ${MES}/libressl-*tar.gz
    cd libressl*
    make clean
    ./configure --prefix=${TARGET} --enable-static && make -j 8 && make -s install
    if [[ $? != 0 ]];then
        exit 1
    fi
fi
echo "----------------------"


echo "\n--------------------"
echo "[*] check ffmpeg"
# next, ffmpeg
# technically, I could simply build a full blown ffmpeg with third party libraries
# but as they are mostly used for encoding and mpv is a media player
# there is no real need to do it. But you could, if you wanted to :-)
if [[ -f "${TARGET}/lib/libavcodec.a" && -f "${TARGET}/lib/libavformat.a" && -f "${TARGET}/lib/libavutil.a" ]];then
    echo "ffmpeg exist!"
else
    # should work with ffmpeg-4.1.tar.gz
    echo "begin build ffmpeg ...\n"
    cd ${CMPL}
    if [[ -d "ffmpeg" ]];then
        cd "ffmpeg"
        git fetch --all --tags
    else
        git clone --reference "${MES}/ffmpeg" "https://gitee.com/mattreach/FFmpeg.git" "ffmpeg"
        cd "ffmpeg"
    fi

    make clean
    ./configure --prefix=${TARGET} \
        --extra-cflags="-I${TARGET}/include" \
        --extra-ldflags="-L${TARGET}/lib" \
        --enable-openssl \
        --enable-static --disable-shared \
        --disable-doc \
        && make -j 8 && make install

    if [[ $? != 0 ]];then
        exit 1
    fi

    if [ ! -e $TARGET/bin/ffmpeg ];then
        echo "Build failed (ffmpeg). KABOOM"
        exit 1
    fi
fi
echo "----------------------"


# and build mpv
cd ${CMPL}

if [[ -d "mpv" ]];then
    cd "mpv"
    git fetch --all --tags
else
    git clone --reference "${MES}/mpv" "https://gitee.com/mattreach/mpv_fork.git" "mpv"
    cd "mpv"
fi

# And mpv just had to use yet another different build system
# people just have too much time reinventing the wheel....
# This time, it is some python hell called 'was'

./bootstrap.py

# Without this the configure line will(!) fail
export PKG_CONFIG=pkg-config

export AR='/usr/bin/ar' #by xql
# something broke finding "ar", this is a crude way to fix it
#sed '/ctx.find_program.ar/d' -i wscript
./waf clean
./waf configure \
    --prefix=${TARGET} \
    --disable-libass \
    --enable-lgpl \
    --enable-libmpv-static \
    --disable-manpage-build

./waf build
./waf install

# check if build was successful
if [ -e $TARGET/bin/mpv ];then
    python TOOLS/osxbundle.py 'build/mpv'
    app_dir="${TARGET}/app"
    rm -rf "$app_dir"
    mkdir -p "$app_dir"
    cp -pRP "build/mpv.app" "${app_dir}/mpv.app"
    echo "Congratulation!"
    echo "Your mpv.app is in ${app_dir}"
else
echo "Build failed."
exit 1
fi
