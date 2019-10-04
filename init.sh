vendor='./base';

mkdir -p $vendor;
cd $vendor;

yasmTag='1.3.0'
pkgTag='0.29.2'
resslTag='2.9.2'
ffmpegTag='4.1' ##snapshot
mpvTag='0.29.1'
assTag='0.14.0'
fribidiTag='1.0.7'
freetypeTag='2.10.1'

MPVSourceGit="https://gitee.com/mattreach/mpv_fork.git" # "https://github.com/mpv-player/mpv.git"
FFSourceGit="https://gitee.com/mattreach/FFmpeg.git"

yasm="yasm-${yasmTag}.tar.gz"
if [ ! -f $yasm ];then
    echo "======== download yasm v${yasmTag} ========"
    curl -LO "http://www.tortall.net/projects/yasm/releases/${yasm}"
    if [[ $? != 0 ]];then
        rm "${yasm}"
        exit 1
    fi
else
    echo "✅ ${yasm}"
fi

pkg="pkg-config-${pkgTag}.tar.gz"
if [ ! -f $pkg ];then
    echo "======== download pkg-config v${pkgTag} ========"
    curl -LO "https://pkgconfig.freedesktop.org/releases/${pkg}"
    if [[ $? != 0 ]];then
        rm "${pkg}"
        exit 1
    fi
else
    echo "✅ ${pkg}"
fi

libressl="libressl-${resslTag}.tar.gz"
if [ ! -f $libressl ];then
    echo "======== download libressl v${resslTag} ========"
    curl -LO "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/${libressl}"
    if [[ $? != 0 ]];then
        rm "${libressl}"
        exit 1
    fi
else
    echo "✅ ${libressl}"
fi

fribidi="fribidi-${fribidiTag}.tar.bz2"
if [ ! -f $fribidi ];then
    echo "======== download fribidi v${fribidiTag} ========"
    curl -LO "https://github.com/fribidi/fribidi/releases/download/v1.0.7/${fribidi}"
    if [[ $? != 0 ]];then
        rm "${fribidi}"
        exit 1
    fi
else
    echo "✅ ${fribidi}"
fi

freetype="freetype-${freetypeTag}.tar.xz"
if [ ! -f $freetype ];then
    echo "======== download freetype v${freetypeTag} ========"
    curl -LO "https://downloads.sourceforge.net/project/freetype/freetype2/2.10.1/${freetype}"
    if [[ $? != 0 ]];then
        rm "${freetype}"
        exit 1
    fi
else
    echo "✅ ${freetype}"
fi

libass="libass-${assTag}.tar.gz"
if [ ! -f $libass ];then
    echo "======== download libass v${assTag} ========"
    curl -LO "https://github.com/libass/libass/releases/download/0.14.0/${libass}"
    if [[ $? != 0 ]];then
        rm "${libass}"
        exit 1
    fi
else
    echo "✅ ${libass}"
fi

# ffmpeg=ffmpeg-${ffmpegTag}.tar.gz
# if [ ! -f $ffmpeg ];then
#     echo "======== download ffmpeg v${ffmpegTag}========"
#     curl -LO "http://www.ffmpeg.org/releases/${ffmpeg}"
#     if [[ $? != 0 ]];then
#         rm "${ffmpeg}"
#         exit 1
#     fi
# else
#     echo "✅ ${ffmpeg}"
# fi

function clone_source()
{
    if [[ -z $1 && -z $2 ]];then
        echo 'invidate parameters.'
        exit 1
    else
        folder="$1"
        src="$2"
        if [[ -d "$folder" ]];then
            cd "$folder"
            git fetch --all --tags
            cd -
        else
            git clone "$src" "$folder"
        fi
    fi
}

clone_source "ffmpeg" "$FFSourceGit"
clone_source "mpv" "$MPVSourceGit"

echo "✅ ======== All dependency lib download succeed! ========"
