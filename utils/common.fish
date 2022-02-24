#!/bin/fish

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

set -g BASE_DIR (realpath (cd (dirname (status -f))/../; and pwd))
set -g SRC_DIR "$BASE_DIR/qt"

set -g QT_MODULES qtbase qtsvg qtshadertools qtimageformats \
    qtdeclarative qtmultimedia qt5compat qtlanguageserver \
    qtquicktimeline qtremoteobjects qttools qtactiveqt \
    qttranslations qtwayland qtwebsockets qtquick3d qtpositioning \
    qtcharts qtlottie qtnetworkauth qtvirtualkeyboard qtscxml \
    qtserialbus qtserialport qtconnectivity qtrepotools qtspeech

cd $BASE_DIR
