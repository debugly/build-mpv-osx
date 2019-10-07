Mac 平台 MPV 编译脚本.

## 目录结构

```
├── README.md
├── base
│   ├── ffmpeg
│   ├── libressl-2.9.2.tar.gz
│   ├── mpv
│   ├── pkg-config-0.29.2.tar.gz
│   └── yasm-1.3.0.tar.gz
├── build
│   ├── ffmpeg
│   ├── libressl-2.9.2
│   ├── mpv
│   ├── pkg-config-0.29.2
│   └── yasm-1.3.0
├── build.sh
├── dest
│   ├── app
│   ├── bin
│   ├── etc
│   ├── include
│   ├── lib
│   └── share
└── init.sh
```

- *.sh : 编译脚本
- base : 依赖库和 mpv 源码仓库
- build: 构建使用的源码，从 base 解压或者 clone 的
- dest : 构建产物，包括 mpv.app，libmpv.a 和 依赖库生成的 lib 和 bin 可根据情况使用

## 编译步骤

1、下载依赖库和源码

`sh init.sh`
 
2、编译 libmpv 和 mpv.app

`sh build.sh`

## 参考

- https://hexeract.wordpress.com/2016/08/13/compiling-mpv-for-macos-x/
- https://hexeract.wordpress.com/2009/04/12/how-to-compile-ffmpegmplayer-for-macosx/
- https://github.com/mpv-player/mpv/wiki/Compiling-distro-releases-for-OS-X

## 相关源码下载地址

为加快 clone 速度，从 github 做了镜像

- https://gitee.com/mattreach/FFmpeg
- https://gitee.com/mattreach/mpv_fork

- https://yasm.tortall.net/Download.html
- https://pkgconfig.freedesktop.org/releases/
- https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/
- https://waf.io/

## 先关问题

1、support libbluray

```
Checking for Bluray support
['pkg-config', 'libbluray >= 0.3.0', '--libs', '--cflags', 'libbluray']
err: Package libxml-2.0 was not found in the pkg-config search path.
Perhaps you should add the directory containing `libxml-2.0.pc'
to the PKG_CONFIG_PATH environment variable
Package 'libxml-2.0', required by 'libbluray', not found

from /Users/qianlongxu/Documents/GitWorkspace/build-mpv-osx/build/mpv: The configuration failed
no ('libbluray >= 0.3.0' not found)
```

发现系统库找不到lib路径！

```
➜  build-mpv-osx git:(master) ✗ pkg-config --libs libxml-2.0
-lxml2
```

于是通过brew 自行安装

```
brew install libxml2  
Updating Homebrew...
^C==> Downloading https://homebrew.bintray.com/bottles/libxml2-2.9.9_2.mojave.bott
==> Downloading from https://akamai.bintray.com/1e/1e6143e9bfb756fe80e4a1db417b7
######################################################################## 100.0%
==> Pouring libxml2-2.9.9_2.mojave.bottle.tar.gz
==> Caveats
libxml2 is keg-only, which means it was not symlinked into /usr/local,
because macOS already provides this software and installing another version in
parallel can cause all kinds of trouble.

If you need to have libxml2 first in your PATH run:
  echo 'export PATH="/usr/local/opt/libxml2/bin:$PATH"' >> ~/.zshrc

For compilers to find libxml2 you may need to set:
  export LDFLAGS="-L/usr/local/opt/libxml2/lib"
  export CPPFLAGS="-I/usr/local/opt/libxml2/include"

For pkg-config to find libxml2 you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/libxml2/lib/pkgconfig"
```

brew 没有将自行编译的 libxml-2.0 链接到 /usr/local，所以使用时需要指定路径：
```
➜  build-mpv-osx git:(master) ✗ export PKG_CONFIG_PATH="/usr/local/opt/libxml2/lib/pkgconfig"
➜  build-mpv-osx git:(master) ✗ pkg-config --libs libxml-2.0
-L/usr/local/Cellar/libxml2/2.9.9_2/lib -lxml2
```