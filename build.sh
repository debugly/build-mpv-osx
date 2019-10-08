#brew install docutils libpng libffi pcre glib fontconfig pixman cairo gobject-introspection icu4c harfbuzz lame x264 xvid libtiff little-cms2 libxml2


# use the llvm compiler
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

# set up shortcuts
export MCB=${PWD}
export MES=${MCB}/base
export TARGET=${MCB}/dest
export CMPL=${MCB}/build
export PATH=${TARGET}/bin:$PATH
export MACOSX_DEPLOYMENT_TARGET='10.11'

export PKG_CONFIG_PATH='/Users/qianlongxu/Documents/GitWorkspace/build-mpv-osx/dest/lib/pkgconfig:/usr/local/opt/libxml2/lib/pkgconfig:/usr/local/lib/pkgconfig'
# extend the python modules path
# export PYTHONPATH="${TARGET}/lib/python2.7/site-packages/"

# set up the directories
mkdir -p ${TARGET}
mkdir -p ${CMPL}

cmdpath="$0"

function read_input(){
    if [[ "$1" == 'clean' ]];then

        if [[ "$2" == '--all' ]];then
            rm -rf "${CMPL}"/*
            rm -rf "${TARGET}"/*
            echo "all lib clean succeed."
            exit 0
        elif [[ "$2" == '--yasm' ]];then
            rm -rf "${CMPL}/"ysam*
            rm "${TARGET}/bin/yasm" \
            "${TARGET}/bin/vsyasm" \
            "${TARGET}/bin/ytasm"
            rm "${TARGET}/lib/libyasm.a"
            rm -rf "${TARGET}/include/libyasm"
            rm "${TARGET}/include/libyasm.h" \
            "${TARGET}/include/libyasm-stdint.h"
            echo 'yasm clean succeed.'
            exit 0
        elif [[ "$2" == '--pkg-config' ]];then
            rm -rf "${CMPL}/"pkg-config*
            rm "${TARGET}/bin/"*pkg-config
            echo 'pkg-config clean succeed.'
            exit 0
        elif [[ "$2" == '--libressl' ]];then
            rm -rf "${CMPL}/"libressl*
            rm "${TARGET}/bin/openssl" "${TARGET}/bin/ocspcheck"
            rm -rf "${TARGET}/etc"
            rm -rf "${TARGET}/include/openssl"
            rm "${TARGET}/include/tls.h"
            rm "${TARGET}/lib/"libcrypto.* "${TARGET}/lib/"libssl* "${TARGET}/lib/"libtls.*
            echo 'libressl clean succeed.'
            exit 0
        elif [[ "$2" == '--libfreetype' ]];then
            rm -rf "${CMPL}/"freetype*
            rm -rf "${TARGET}/include/"freetype*
            rm "${TARGET}/lib/"libfreetype.*
            echo 'libfreetype clean succeed.'
            exit 0
        elif [[ "$2" == '--libfribidi' ]];then
            rm -rf "${CMPL}/"fribidi*
            rm -rf "${TARGET}/include/"fribidi*
            rm "${TARGET}/lib/"libfribidi.*
            rm "${TARGET}/bin/"fribidi*
            echo 'libfribidi clean succeed.'
            exit 0
        elif [[ "$2" == '--libass' ]];then
            rm -rf "${CMPL}/"libass*
            rm -rf "${TARGET}/include/"ass*
            rm "${TARGET}/lib/"libass.*
            echo 'libass clean succeed.'
            exit 0
        elif [[ "$2" == '--lua' ]];then
            rm -rf "${CMPL}/"lua-*
            rm "${TARGET}/include/lua.h" "${TARGET}/include/lua.hpp" "${TARGET}/include/luaconf.h" "${TARGET}/include/lualib.h" "${TARGET}/include/lauxlib.h"
            rm "${TARGET}/lib/"liblua.*
            rm "${TARGET}/bin/lua" "${TARGET}/bin/luac"
            echo 'lua clean succeed.'
            exit 0
        elif [[ "$2" == '--luajit' ]];then
            rm -rf "${CMPL}/"LuaJIT-*
            rm -rf "${TARGET}/include/"luajit-*
            rm "${TARGET}/lib/"libluajit-*
            rm "${TARGET}/bin/"luajit*
            echo 'luajit clean succeed.'
            exit 0
        elif [[ "$2" == '--ffmpeg' ]];then
            cd "${CMPL}/ffmpeg"
            git reset --hard HEAD && git clean -dfx
            cd -
            rm "${TARGET}/bin/ffmpeg" "${TARGET}/bin/ffprobe"
            rm -rf "${TARGET}/include/libavcodec" \
                "${TARGET}/include/libavformat" \
                "${TARGET}/include/libavutil" \
                "${TARGET}/include/libavdevice" \
                "${TARGET}/include/libswresample" \
                "${TARGET}/include/libswscale" \
                "${TARGET}/include/libavfilter" \

            rm "${TARGET}/include/tls.h"
            rm "${TARGET}/lib/"libavcodec.* \
            "${TARGET}/lib/"libavformat.* \
            "${TARGET}/lib/"libavutil.* \
            "${TARGET}/lib/"libavdevice.* \
            "${TARGET}/lib/"libswresample.* \
            "${TARGET}/lib/"libswscale.* \
            "${TARGET}/lib/"libavfilter.*
            echo 'ffmpeg clean succeed.'
            exit 0
        elif [[ "$2" == '--mpv' ]];then
            cd "${CMPL}/mpv"
            git reset --hard HEAD && git clean -dfx
            cd -
            rm -rf "${TARGET}/app"
            rm "${TARGET}/lib/"libmpv.*
            rm -rf "${TARGET}/bin/"mpv*
            rm -rf "${TARGET}/etc/"mpv*
            rm -rf "${TARGET}/include/"mpv*
            echo 'mpv clean succeed.'
            exit 0
        elif [[ ! "$2" || "$2" == '--help' ]];then
            echo 'Usage:'
            echo '\t$ sh '$cmdpath 'clean'
            echo 'Options:'
            echo "\t--all          clean all libs、bins、headers."
            echo "\t--mpv          just clean libmpv/mpv."
            echo "\t--yasm         just clean yasm bin and lib."
            echo "\t--pkg-config   just clean pkg-config bin."
            echo "\t--ffmpeg       just clean ffpmeg libs."
            echo "\t--libfreetype  just clean libfreetype."
            echo "\t--libfribidi   just clean fribidi bin and lib."
            echo "\t--libass       just clean libass."
            echo "\t--lua          just clean lua."
            echo "\t--luajit       just clean luaJIT."
            echo "\t--libressl     just clean libressl."
            
            exit 0
        else
            echo 'unknown cmd:'$2
            read_input 'clean' '--help'
            exit 0
        fi
    elif [[ "$1" == '--help' ]];then
        echo 'Usage:'
        echo '\t$ sh '$cmdpath 'COMMAND'
        echo 'Commands:'
        echo "\t+ clean  clean build workspace."
        echo "\t+ build build your target."
        exit 0
    elif [[ "$1" == 'build' ]];then

        if [[ "$2" == '--help' ]];then
            echo 'Usage:'
            echo '\t$ sh '$cmdpath 'build'
            echo 'Options:'
            echo "\t--dep build dependent libs except mpv."
            exit 0
        elif [[ "$2" == '--dep' ]];then
            build_denpendents
        elif [[ "$2" ]];then
            echo 'unknown cmd:'$2
            read_input 'build' '--help'
            exit 0
        else
            build_denpendents
            build_mpv
        fi
    else
        read_input '--help'
    fi
}

function build_denpendents(){

    echo "\n--------------------"
    echo "[*] check pkg-config"
    # next, pkg-config
    if [[ -f "${TARGET}/bin/pkg-config" ]];then
        echo "✅pkg-config already exist!"
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
    echo "[*] check ysam"
    # next, yasm
    if [[ -f "${TARGET}/lib/libyasm.a" && -f "${TARGET}/bin/yasm" ]];then
        echo "✅ysam already exist!"
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
    echo "[*] check libressl"
    # next, libressl
    if [[ -f "${TARGET}/lib/libtls.a" && -f "${TARGET}/lib/libssl.a"  && -f "${TARGET}/lib/libcrypto.a" ]];then
        echo "✅libressl already exist!"
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
    echo "[*] check fribidi"
    # next, fribidi
    if [[ -f "${TARGET}/lib/libfribidi.a" ]];then
        echo "✅fribidi already exist!"
    else
        # should work with fribidi-1.0.7.tar.bz2
        # https://github.com/Homebrew/homebrew-core/blob/master/Formula/fribidi.rb
        echo "begin build fribidi ...\n"
        cd ${CMPL}
        tar xzpf ${MES}/fribidi-*tar.bz2
        cd fribidi*
        make clean
        ./configure --prefix=${TARGET} \
            --disable-debug \
            --disable-dependency-tracking \
            --disable-silent-rules \
            --disable-shared \
            --enable-static \
            && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        fi
    fi
    echo "----------------------"


    echo "\n--------------------"
    echo "[*] check freetype"
    # next, freetype
    if [[ -f "${TARGET}/lib/libfreetype.a" ]];then
        echo "✅freetype already exist!"
    else
        # should work with freetype-2.10.1.tar.xz
        # https://github.com/Homebrew/homebrew-core/blob/master/Formula/freetype.rb
        echo "begin build freetype ...\n"
        cd ${CMPL}
        tar xzpf ${MES}/freetype-*tar.xz
        cd freetype*
        make clean
        ./configure --prefix=${TARGET} \
            --disable-debug \
            --disable-dependency-tracking \
            --disable-silent-rules \
            --disable-shared \
            --enable-static \
            && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        fi
    fi
    echo "----------------------"


    echo "\n--------------------"
    echo "[*] check libass"
    # next, libass
    if [[ -f "${TARGET}/lib/libass.a" ]];then
        echo "✅libass already exist!"
    else
        # should work with libass-0.14.0.tar.gz
        echo "begin build libass ...\n"
        cd ${CMPL}
        tar xzpf ${MES}/libass-*tar.gz
        cd libass*
        make clean
        ./configure --prefix=${TARGET} --disable-fontconfig --disable-shared --enable-static && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        fi
    fi
    echo "----------------------"

    echo "\n--------------------"
    echo "[*] check lua"
    # next, lua
    if [[ -f "${TARGET}/lib/liblua.a" ]];then
        echo "✅lua already exist!"
    else
        # should work with lua-5.3.5.tar.gz
        echo "begin build lua ...\n"
        cd ${CMPL}
        tar xzpf ${MES}/lua-*tar.gz
        cd lua-*
        make macosx  INSTALL_TOP="${TARGET}" INSTALL_INC="${TARGET}/include/lua" INSTALL_MAN="${TARGET}/man/man1"
        make install INSTALL_TOP="${TARGET}" INSTALL_INC="${TARGET}/include/lua" INSTALL_MAN="${TARGET}/man/man1"
        if [[ $? != 0 ]];then
            exit 1
        fi

        dest="${TARGET}/lib/pkgconfig/lua.pc"
        cp "${MES}/lua.pc" "${dest}"

    fi
    echo "----------------------"

    echo "\n--------------------"
    echo "[*] check luaJIT"
    # next, lua
    r=$(ls "${TARGET}/lib/"libluajit*.a)
    if [[ $? == 0 ]];then
        echo "✅luaJIT already exist!"
    else
        # should work with LuaJIT-2.0.5.tar.gz
        echo "begin build luaJIT ...\n"
        cd ${CMPL}
        tar xzpf ${MES}/LuaJIT-*tar.gz
        cd LuaJIT-*
        make clean
        make amalg PREFIX=${TARGET}
        make install PREFIX=${TARGET}
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
        echo "✅ffmpeg already exist!"
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

    # get rid of the dynamically loadable libraries
    # to force it to use the static version for compilation
    rm ${TARGET}/lib/*.dylib

    echo 
    echo "Okey, all dependent bins/libs is ready!"
    echo
}

# build mpv

function build_mpv(){
    echo "begin build mpv"
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

    CONF_FLAGS="$CONF_FLAGS --enable-lgpl"
    CONF_FLAGS="$CONF_FLAGS --enable-libmpv-static"
    CONF_FLAGS="$CONF_FLAGS --disable-manpage-build"
    CONF_FLAGS="$CONF_FLAGS --disable-tvos"
    # CONF_FLAGS="$CONF_FLAGS --disable-cplayer"
    # CONF_FLAGS="$CONF_FLAGS -vvv"

    if [[ ! -f "${TARGET}/lib/libass.a" ]];then
        CONF_FLAGS="$CONF_FLAGS --disable-libass"
    fi

    # echo "$CONF_FLAGS"

    ./waf clean
    ./waf configure \
        --prefix=${TARGET} \
        $CONF_FLAGS

    if [[ $? != 0 ]];then
            exit 1
    fi
    ./waf build
    if [[ $? != 0 ]];then
            exit 1
    fi
    ./waf install

    # check if mpv exist ?
    if [ -e $TARGET/bin/mpv ];then
        python TOOLS/osxbundle.py $TARGET/bin/mpv
        app_dir="${TARGET}/app"
        rm -rf "$app_dir"
        mkdir -p "$app_dir"
        cp -pRP "$TARGET/bin/mpv.app" "${app_dir}/mpv.app"
        rm -rf "$TARGET/bin/mpv.app"
        echo "Your mpv.app is in ${app_dir}"
    fi

    echo
    echo "Congratulation!"
}

read_input $*