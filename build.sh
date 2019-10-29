#brew install docutils libpng libffi pcre glib fontconfig pixman cairo gobject-introspection icu4c harfbuzz lame x264 xvid libtiff little-cms2 libxml2

USE_IJK_FF=1
if [[ "$USE_IJK_FF" == 0 ]];then
    FF_TAG='ff4.0--ijk0.8.25--20191024--001' #'n4.2.1'
    FF_DIR='ffmpeg-ijk'
    FF_GIT='https://github.com/Bilibili/FFmpeg.git'
else
    FF_TAG='n4.2.1'
    FF_DIR='ffmpeg'
    FF_GIT='https://gitee.com/mattreach/FFmpeg.git'
fi

MPV_TAG='v0.30.0'
MPV_DIR='mpv'
MPV_GIT='https://gitee.com/mattreach/mpv_fork.git'


# use the llvm compiler
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

# set up shortcuts
export WORKSPACE=${PWD}
export SOURCE_DIR=${WORKSPACE}/base
export TARGET_DIR=${WORKSPACE}/dest
export BUILD_DIR=${WORKSPACE}/build

export PATH=${TARGET_DIR}/bin:$PATH
export MACOSX_DEPLOYMENT_TARGET='10.10'

export PKG_CONFIG_PATH='/Users/qianlongxu/Documents/GitWorkspace/build-mpv-osx/dest/lib/pkgconfig:/usr/local/opt/libxml2/lib/pkgconfig:/usr/local/lib/pkgconfig'
# extend the python modules path
# export PYTHONPATH="${TARGET_DIR}/lib/python2.7/site-packages/"

# set up the directories
mkdir -p ${TARGET_DIR}
mkdir -p ${BUILD_DIR}

cmdpath="$0"

function read_input(){
    if [[ "$1" == 'clean' ]];then

        if [[ "$2" == '--all' ]];then
            rm -rf "${BUILD_DIR}"/*
            rm -rf "${TARGET_DIR}"/*
            echo "all lib clean succeed."
            exit 0
        elif [[ "$2" == '--yasm' ]];then
            rm -rf "${BUILD_DIR}/"ysam*
            rm "${TARGET_DIR}/bin/yasm" \
            "${TARGET_DIR}/bin/vsyasm" \
            "${TARGET_DIR}/bin/ytasm"
            rm "${TARGET_DIR}/lib/libyasm.a"
            rm -rf "${TARGET_DIR}/include/libyasm"
            rm "${TARGET_DIR}/include/libyasm.h" \
            "${TARGET_DIR}/include/libyasm-stdint.h"
            echo 'yasm clean succeed.'
            exit 0
        elif [[ "$2" == '--pkg-config' ]];then
            rm -rf "${BUILD_DIR}/"pkg-config*
            rm "${TARGET_DIR}/bin/"*pkg-config
            echo 'pkg-config clean succeed.'
            exit 0
        elif [[ "$2" == '--libressl' ]];then
            rm -rf "${BUILD_DIR}/"libressl*
            rm "${TARGET_DIR}/bin/openssl" "${TARGET_DIR}/bin/ocspcheck"
            rm -rf "${TARGET_DIR}/etc"
            rm -rf "${TARGET_DIR}/include/openssl"
            rm "${TARGET_DIR}/include/tls.h"
            rm "${TARGET_DIR}/lib/"libcrypto.* "${TARGET_DIR}/lib/"libssl* "${TARGET_DIR}/lib/"libtls.*
            echo 'libressl clean succeed.'
            exit 0
        elif [[ "$2" == '--libfreetype' ]];then
            rm -rf "${BUILD_DIR}/"freetype*
            rm -rf "${TARGET_DIR}/include/"freetype*
            rm "${TARGET_DIR}/lib/"libfreetype.*
            echo 'libfreetype clean succeed.'
            exit 0
        elif [[ "$2" == '--libfribidi' ]];then
            rm -rf "${BUILD_DIR}/"fribidi*
            rm -rf "${TARGET_DIR}/include/"fribidi*
            rm "${TARGET_DIR}/lib/"libfribidi.*
            rm "${TARGET_DIR}/bin/"fribidi*
            echo 'libfribidi clean succeed.'
            exit 0
        elif [[ "$2" == '--libass' ]];then
            rm -rf "${BUILD_DIR}/"libass*
            rm -rf "${TARGET_DIR}/include/"ass*
            rm "${TARGET_DIR}/lib/"libass.*
            echo 'libass clean succeed.'
            exit 0
        elif [[ "$2" == '--lua' ]];then
            rm -rf "${BUILD_DIR}/"lua-*
            rm "${TARGET_DIR}/include/lua.h" "${TARGET_DIR}/include/lua.hpp" "${TARGET_DIR}/include/luaconf.h" "${TARGET_DIR}/include/lualib.h" "${TARGET_DIR}/include/lauxlib.h"
            rm "${TARGET_DIR}/lib/"liblua.*
            rm "${TARGET_DIR}/bin/lua" "${TARGET_DIR}/bin/luac"
            echo 'lua clean succeed.'
            exit 0
        elif [[ "$2" == '--luajit' ]];then
            rm -rf "${BUILD_DIR}/"LuaJIT-*
            rm -rf "${TARGET_DIR}/include/"luajit-*
            rm "${TARGET_DIR}/lib/"libluajit-*
            rm "${TARGET_DIR}/bin/"luajit*
            echo 'luajit clean succeed.'
            exit 0
        elif [[ "$2" == '--ffmpeg' ]];then
            if [[ -d "${BUILD_DIR}/ffmpeg" ]];then
                cd "${BUILD_DIR}/ffmpeg"
                git reset --hard HEAD && git clean -dfx
                cd -
            fi

            rm "${TARGET_DIR}/bin/ffmpeg" "${TARGET_DIR}/bin/ffprobe"
            rm -rf "${TARGET_DIR}/include/libavcodec" \
                "${TARGET_DIR}/include/libavformat" \
                "${TARGET_DIR}/include/libavutil" \
                "${TARGET_DIR}/include/libavdevice" \
                "${TARGET_DIR}/include/libswresample" \
                "${TARGET_DIR}/include/libswscale" \
                "${TARGET_DIR}/include/libavfilter" \

            rm "${TARGET_DIR}/lib/"libavcodec.* \
            "${TARGET_DIR}/lib/"libavformat.* \
            "${TARGET_DIR}/lib/"libavutil.* \
            "${TARGET_DIR}/lib/"libavdevice.* \
            "${TARGET_DIR}/lib/"libswresample.* \
            "${TARGET_DIR}/lib/"libswscale.* \
            "${TARGET_DIR}/lib/"libavfilter.*

            echo 'ffmpeg clean succeed.'
            exit 0
        elif [[ "$2" == '--mpv' ]];then
            if [[ -d "${BUILD_DIR}/mpv" ]];then
                cd "${BUILD_DIR}/mpv"
                git reset --hard HEAD && git clean -dfx
                cd -
            fi

            rm -rf "${TARGET_DIR}/app"
            rm "${TARGET_DIR}/lib/"libmpv.*
            rm -rf "${TARGET_DIR}/bin/"mpv*
            rm -rf "${TARGET_DIR}/etc/"mpv*
            rm -rf "${TARGET_DIR}/include/"mpv*
                
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
        echo "\t+ build build your TARGET_DIR."
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

function clean_dylib(){
    # get rid of the dynamically loadable libraries
    # to force it to use the static version for compilation
    rm ${TARGET_DIR}/lib/*.dylib
    rm ${TARGET_DIR}/lib/*.la
}

function copy_extenstion_lib(){
    lib="$1"
    p=$(pkg-config --libs-only-L --silence-errors $lib)
    if [[ $? == 0 ]];then
        echo "copied: $lib"
        p=$(echo "$p" | sed 's/-L//' )
        cp -pf "$p"/*.a "${TARGET_DIR}/lib"

        dir=$(dirname "$p")
        p="$dir/include"
        cp -pfr "$p" "${TARGET_DIR}"

    else
        echo "❌can't find $lib."
    fi
}

function copy_extenstion_libs(){
    libs=('libjpeg' 'x264' 'fribidi' 'harfbuzz' 'freetype2' 'libass' )

    for lib in ${libs[@]};do
        copy_extenstion_lib $lib
    done

}

function build_denpendents_extensiton(){

    echo "\n--------------------"
    echo "[*] check fribidi"
    # next, fribidi
    pkg-config --libs fribidi
    if [[ $? == 0 ]];then
        echo "✅fribidi already exist!"
    else
        # should work with fribidi-1.0.7.tar.bz2
        # https://github.com/Homebrew/homebrew-core/blob/master/Formula/fribidi.rb
        echo "begin build fribidi ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/fribidi-*tar.bz2
        cd fribidi*
        make clean
        ./configure --prefix=${TARGET_DIR} \
            --disable-debug \
            --disable-dependency-tracking \
            --disable-silent-rules \
            --disable-shared \
            --enable-static \
            && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        else
            clean_dylib
        fi
    fi
    echo "----------------------"


    echo "\n--------------------"
    echo "[*] check freetype"
    # next, freetype
    pkg-config --libs freetype2
    if [[ $? == 0 ]];then
        echo "✅freetype already exist!"
    else
        # should work with freetype-2.10.1.tar.xz
        # https://github.com/Homebrew/homebrew-core/blob/master/Formula/freetype.rb
        echo "begin build freetype ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/freetype-*tar.xz
        cd freetype*
        make clean
        ./configure --prefix=${TARGET_DIR} \
            --disable-debug \
            --disable-dependency-tracking \
            --disable-silent-rules \
            --disable-shared \
            --enable-static \
            && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        else
            clean_dylib
        fi
    fi
    echo "----------------------"


    echo "\n--------------------"
    echo "[*] check libass"
    # next, libass
    pkg-config --libs libass
    if [[ $? == 0 ]];then
        echo "✅libass already exist!"
    else
        # should work with libass-0.14.0.tar.gz
        echo "begin build libass ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/libass-*tar.gz
        cd libass*
        make clean
        ./configure --prefix=${TARGET_DIR} --disable-fontconfig --disable-shared --enable-static && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        else
            clean_dylib
        fi
    fi
    echo "----------------------"

    echo "\n--------------------"
    echo "[*] check lua"
    # next, lua
    pkg-config --libs lua
    if [[ $? == 0 ]];then
        echo "✅lua already exist!"
    else
        # should work with lua-5.3.5.tar.gz
        echo "begin build lua ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/lua-*tar.gz
        cd lua-*
        make macosx  INSTALL_TOP="${TARGET_DIR}" INSTALL_INC="${TARGET_DIR}/include/lua" INSTALL_MAN="${TARGET_DIR}/man/man1"
        make install INSTALL_TOP="${TARGET_DIR}" INSTALL_INC="${TARGET_DIR}/include/lua" INSTALL_MAN="${TARGET_DIR}/man/man1"
        if [[ $? != 0 ]];then
            exit 1
        else
            clean_dylib
        fi

        dest="${TARGET_DIR}/lib/pkgconfig/lua.pc"
        cp "${SOURCE_DIR}/lua.pc" "${dest}"

    fi
    echo "----------------------"

    echo "\n--------------------"
    echo "[*] check luaJIT"
    # next, lua
    pkg-config --libs luajit
    if [[ $? == 0 ]];then
        echo "✅luaJIT already exist!"
    else
        # should work with LuaJIT-2.0.5.tar.gz
        echo "begin build luaJIT ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/LuaJIT-*tar.gz
        cd LuaJIT-*
        make clean
        make amalg PREFIX=${TARGET_DIR}
        make install PREFIX=${TARGET_DIR}
        if [[ $? != 0 ]];then
            exit 1
        else
            clean_dylib
        fi
    fi
    echo "----------------------"
}

function build_denpendents(){

    echo "\n--------------------"
    echo "[*] check pkg-config"
    # next, pkg-config
    which pkg-config

    if [[ $? == 0 ]];then
        echo "✅pkg-config already exist!"
    else
        # should work with pkg-config-0.29.1.tar.gz
        echo "begin build pkg-config ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/pkg-config-*.tar.gz
        cd pkg-config-*
        make clean
        export LDFLAGS="-framework Foundation -framework Cocoa"
        ./configure --prefix=${TARGET_DIR} --with-pc-path=${TARGET_DIR}/lib/pkgconfig --with-internal-glib && make -j 8 && make install
        if [[ $? != 0 ]];then
            exit 1
        fi
        unset LDFLAGS
    fi
    echo "----------------------"


    echo "\n--------------------"
    echo "[*] check ysam"
    # next, yasm
    which yasm
    if [[ $? == 0 ]];then
        echo "✅ysam already exist!"
    else
        # should work with yasm-1.3.0.tar.gz
        echo "begin build ysam ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/yasm*.tar.gz
        cd yasm-*
        make clean
        ./configure --prefix=${TARGET_DIR} && make -j 8 && make install
        if [[ $? != 0 ]];then
            exit 1
        fi
    fi
    echo "----------------------"


    echo "\n--------------------"
    echo "[*] check libressl"
    # next, libressl
    # pkg-config --libs openssl
    if [[ -f "${TARGET_DIR}/lib/libtls.a" && -f "${TARGET_DIR}/lib/libssl.a"  && -f "${TARGET_DIR}/lib/libcrypto.a" ]];then
        echo "✅libressl already exist!"
    else
        # should work with libressl-2.4.2.tar.gz
        echo "begin build libressl ...\n"
        cd ${BUILD_DIR}
        tar xzpf ${SOURCE_DIR}/libressl-*tar.gz
        cd libressl*
        make clean
        ./configure --prefix=${TARGET_DIR} --enable-static && make -j 8 && make -s install
        if [[ $? != 0 ]];then
            exit 1
        else
            clean_dylib
        fi
    fi
    echo "----------------------"

    echo "\n--------------------"
    echo "will find extenstion libs use pkg-config"
    copy_extenstion_libs
    echo "----------------------"

    echo "\n--------------------"
    echo "[*] check ffmpeg"
    echo '-----------------'
    echo "will use $FF_DIR $FF_TAG [$FF_GIT]"
    echo '-----------------'
    # next, ffmpeg
    # technically, I could simply build a full blown ffmpeg with third party libraries
    # but as they are mostly used for encoding and mpv is a media player
    # there is no real need to do it. But you could, if you wanted to :-)

    # pkg-config --libs libavcodec
    # e_libavcodec=$?

    # pkg-config --libs libavformat
    # e_libavformat=$?

    # pkg-config --libs libavutil
    # e_libavutil=$?

    # pkg-config --libs libavdevice
    # e_libavdevice=$?

    # pkg-config --libs libavfilter
    # e_libavfilter=$?

    # pkg-config --libs libswresample
    # e_libswresample=$?

    # pkg-config --libs libswscale
    # e_libswscale=$?

    # if [[ $e_libavcodec == 0 && $e_libavformat == 0 && $e_libavutil == 0 && $e_libavdevice == 0 && $e_libavfilter == 0 && $e_libswresample == 0 && $e_libswscale == 0 ]];then
    if [[ -f "${TARGET_DIR}/lib/libavcodec.a" && -f "${TARGET_DIR}/lib/libavformat.a" && -f "${TARGET_DIR}/lib/libavutil.a" && -f "${TARGET_DIR}/lib/libavdevice.a" && -f "${TARGET_DIR}/lib/libavfilter.a" && -f "${TARGET_DIR}/lib/libswresample.a" && -f "${TARGET_DIR}/lib/libswscale.a" ]];then
        echo "✅ffmpeg already exist!"
    else
        # should work with ffmpeg-4.1.tar.gz
        echo "begin build ${FF_DIR} ...\n"
        cd ${BUILD_DIR}

        if [[ ! -d "${FF_DIR}" ]];then
            git clone --reference "${SOURCE_DIR}/${FF_DIR}" "${FF_GIT}" "${FF_DIR}"
            cd "${FF_DIR}"
            git checkout "$FF_TAG" -B mr_ffmpeg
            cd -
        fi

        #echo "copy ffmepg patch"
        #cp -r "${SOURCE_DIR}/patch/ffmpeg" "${BUILD_DIR}"

        cd "${FF_DIR}"
        make clean  
        ./configure --prefix=${TARGET_DIR} \
            --target-os=darwin \
            --arch=x86_64 \
            --extra-cflags="-I${TARGET_DIR}/include" \
            --extra-ldflags="-L${TARGET_DIR}/lib" \
            --enable-openssl \
            --enable-static --disable-shared \
            --disable-doc \
            && make -j 8 && make install

        if [[ $? != 0 ]];then
            exit 1
        fi

    fi
    echo "----------------------"

    echo 
    echo "Okey, all dependent bins/libs is ready!"
    echo
}

# build mpv

function build_mpv(){
    echo "begin build mpv"

    echo '-----------------'
    echo "will use $MPV_DIR $MPV_TAG [$MPV_GIT]"
    echo '-----------------'

    cd ${BUILD_DIR}

    if [[ ! -d "${MPV_DIR}" ]];then
        git clone --reference "${SOURCE_DIR}/${MPV_DIR}" "${MPV_GIT}" "${MPV_DIR}"
        cd "${MPV_DIR}"
        git checkout "$MPV_TAG" -B mr_mpv
        cd -
    fi

    # And mpv just had to use yet another different build system
    # people just have too much time reinventing the wheel....
    # This time, it is some python hell called 'was'
    
    cd "${MPV_DIR}"
    ./bootstrap.py

    # Without this the configure line will(!) fail
    export PKG_CONFIG=pkg-config
    
    export AR='/usr/bin/ar'

    CONF_FLAGS="$CONF_FLAGS --enable-lgpl"
    CONF_FLAGS="$CONF_FLAGS --enable-libmpv-static"
    CONF_FLAGS="$CONF_FLAGS --disable-manpage-build"
    CONF_FLAGS="$CONF_FLAGS --disable-tvos"
    CONF_FLAGS="$CONF_FLAGS --disable-swift"
    CONF_FLAGS="$CONF_FLAGS --disable-lua"
    CONF_FLAGS="$CONF_FLAGS --disable-javascript"
    CONF_FLAGS="$CONF_FLAGS --disable-libass"
    CONF_FLAGS="$CONF_FLAGS --disable-libass-osd"
    CONF_FLAGS="$CONF_FLAGS --disable-libbluray"
    CONF_FLAGS="$CONF_FLAGS --disable-cplayer"
    # CONF_FLAGS="$CONF_FLAGS -vvv"

    if [[ ! -f "${TARGET_DIR}/lib/libass.a" ]];then
        CONF_FLAGS="$CONF_FLAGS --disable-libass"
    fi

    # echo "$CONF_FLAGS"

    ./waf clean
    ./waf configure \
        --prefix=${TARGET_DIR} \
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
    if [ -e $TARGET_DIR/bin/mpv ];then
        python TOOLS/osxbundle.py $TARGET_DIR/bin/mpv
        app_dir="${TARGET_DIR}/app"
        rm -rf "$app_dir"
        mkdir -p "$app_dir"
        cp -pRP "$TARGET_DIR/bin/mpv.app" "${app_dir}/mpv.app"
        rm -rf "$TARGET_DIR/bin/mpv.app"
        echo "Your mpv.app is in ${app_dir}"
    fi

    echo
    echo "Congratulation!"
}

read_input $*