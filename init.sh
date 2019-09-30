vendor='./base';

mkdir -p $vendor;
cd $vendor;

yasmTag='1.3.0';
pkgTag='0.29.2'
resslTag='2.9.2';
ffmpegTag='4.1'; ##snapshot
mpvTag='0.29.1';

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
