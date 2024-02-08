#!/usr/bin/env fish

function reverse --description 'Reverse a list'
    set -l stack
    for v in $argv
        set -p stack $v
    end

    for s in $stack
        echo $s
    end
end

function lastdedup --description 'Remove duplicates from variable'
    set -l newvar
    for v in (reverse $$argv)
        if not contains -- $v $newvar
            set newvar $newvar $v
        end
    end
    set $argv (reverse $newvar)
end

set BUILD_HOST_OS (uname -s)

if [ $BUILD_HOST_OS = Darwin ]
    set NPROCS (sysctl -n hw.physicalcpu)
else
    set NPROCS (nproc)
end

if not command realpath
    set REALPATH_BIN (which realpath)
else
    set REALPATH_BIN realpath
end

set -g BASE_DIR ($REALPATH_BIN (cd (dirname (status -f))/../; pwd))
set -g SRC_DIR "$BASE_DIR/qt"

set -g QT_MODULES

# Core modules
set -ga QT_MODULES qtbase qtsvg qtshadertools qtimageformats qtdeclarative qtlanguageserver qttools qttranslations

# Connection/Network modules
set -ga QT_MODULES qtwebsockets qtnetworkauth qtconnectivity qtserialport qthttpserver qtserialbus

# Optional modules
set -ga QT_MODULES qtremoteobjects qt5compat qtquicktimeline qtgrpc

# Platform-specific modules
set -ga QT_MODULES qtactiveqt qtwayland qtcharts qtlottie qtvirtualkeyboard qtscxml qtspeech qtquick3dphysics qtmultimedia qtquick3d


cd $BASE_DIR
