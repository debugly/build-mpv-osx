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