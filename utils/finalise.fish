#!/bin/fish

if test -z "$QT_BUILDSCRIPT_EXPORTED"
    set_color red
    echo "ERROR:"
    echo "  By invoking finalise.fish, you should be expecting this to perform finalisation for your Qt build."
    echo "  However it seems that you are not in a valid build environment"
    echo ""
    echo "See `./build-qt.fish --help`, option `-E` for more information."
    set_color normal
    exit 1
end

cd $BUILD_DIR

if test -d "$INSTALL_DIR"
    mv "$INSTALL_DIR" "$INSTALL_DIR-"(random)
end

mkdir -p $INSTALL_DIR

cmake --install . || exit 1

echo "build time:" (date) >$INSTALL_DIR/modules.info

if type -q git
    for d in (string split ' ' $QT_MODULES)
        echo $d "->" (git --git-dir $BASE_DIR/qt/$d/.git/ log -1 --format=%H)
    end >>$INSTALL_DIR/modules.info
end

if string match -qr sccache $BUILD_KITS
    sccache --show-stats | tee $INSTALL_DIR/cache.info || true
else if string match -qr ccache $BUILD_KITS
    ccache -sv | tee $INSTALL_DIR/cache.info || true
end

set CURRENT_DIR "$BASE_DIR/Current/$BUILD_TYPE"
rm $CURRENT_DIR
ln -svf $INSTALL_DIR $CURRENT_DIR

echo Done
