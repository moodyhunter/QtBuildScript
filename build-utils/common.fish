#!/bin/fish

set -g BASE_DIR (cd (dirname (status -f))/../; and pwd)
set -g SRC_DIR "$BASE_DIR/qt"

set -g QT_MODULES qtbase qtsvg qtshadertools qtimageformats \
    qtdeclarative qtmultimedia qt5compat qtlanguageserver \
    qtquicktimeline qtremoteobjects qttools qtactiveqt \
    qttranslations qtwayland qtwebsockets

cd $BASE_DIR
