#!/bin/fish

if not source (dirname (status --current-filename))/utils/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

cd $BASE_DIR

set EXTRA_CMAKE_ARGUMENTS
set BUILD_TYPE (string join '-' (for f in $argv; echo $f; end | sort))

if [ "$BUILD_TYPE" = "" ]
    set BUILD_TYPE default
end

echo "Build Type:" $BUILD_TYPE

for f in $argv
    if source "$BASE_DIR/kits/$f.fish" 2>/dev/null
        set_color green
        echo -n "Loaded build kit: "
        set_color normal
        echo "$f"
    else
        set_color red
        echo "The specified kit '$f' could not be found."
        echo "Possible kits are:"
        for f in (basename -s .fish $BASE_DIR/kits/*)
            echo - $f
        end
        exit 1
    end
end

set -g BUILD_DIR "$BASE_DIR/.build/$BUILD_TYPE"
set -g CURRENT_DIR "$BASE_DIR/Current-$BUILD_TYPE"
set -g INSTALL_DIR "$BASE_DIR/nightly-$BUILD_TYPE/"(date -I)

echo ""
export CCACHE_DIR=$BASE_DIR/.build-cache
echo "Using ccache dir: $CCACHE_DIR"

set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_INSTALL_PREFIX=$CURRENT_DIR/
set -p EXTRA_CMAKE_ARGUMENTS -DQT_USE_CCACHE=ON
set -p EXTRA_CMAKE_ARGUMENTS -DBUILD_WITH_PCH=OFF
set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_CXX_FLAGS='-march=native'
set -p EXTRA_CMAKE_ARGUMENTS -GNinja

echo ""
echo "Qt modules included:"
set_color blue
for m in $QT_MODULES
    echo "  $m"
end | sort
set_color normal

echo ""
echo "CMake arguments:"
set_color blue
for arg in $EXTRA_CMAKE_ARGUMENTS
    echo "  $arg"
end
set_color normal

set -p EXTRA_CMAKE_ARGUMENTS -DQT_BUILD_SUBMODULES=(string join ';' $QT_MODULES)

echo ""
set_color yellow
echo -n "Will start building in 5 seconds, press Ctrl+C to cancel: "
for sec in 5 4 3 2 1
    echo -n "$sec..."
    sleep 1
end
set_color normal
echo ""

source $BASE_DIR/cleanup.fish

mkdir -p $BUILD_DIR
cd $BUILD_DIR

export CMAKE_PREFIX_PATH=/usr
cmake $SRC_DIR $EXTRA_CMAKE_ARGUMENTS

ccache -z
cmake --build . --parallel || exit 1

mv $INSTALL_DIR/ $INSTALL_DIR-backup/
mkdir -p $BUILD_DIR
mkdir -p $INSTALL_DIR
rm $CURRENT_DIR
ln -svf $INSTALL_DIR $CURRENT_DIR

cmake --install . || exit 1

echo "build time:" (date) >$CURRENT_DIR/modules.info

for d in $QT_MODULES
    echo $d "->" (git --git-dir $BASE_DIR/qt/$d/.git/ log -1 --format=%H)
end >>$CURRENT_DIR/modules.info

ccache -sv | tee $CURRENT_DIR/cache.info

rm -rf $INSTALL_DIR-backup/

echo "Done."
