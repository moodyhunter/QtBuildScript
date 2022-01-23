#!/bin/fish

if not source (dirname (status --current-filename))/utils/common.fish 2>/dev/null
    echo "Initialization failed."
    exit 1
end

cd $BASE_DIR

set BUILD_TYPE $argv[1]
set EXTRA_CMAKE_ARGUMENTS

if source "$BASE_DIR/kits/$BUILD_TYPE.fish" 2>/dev/null
    echo "Succeeded loading build kit: $BUILD_TYPE"
else
    echo "Failed building kit: $BUILD_TYPE"
    exit 1
end

set -g BUILD_DIR "$BASE_DIR/.build/$BUILD_TYPE"
set -g CURRENT_DIR "$BASE_DIR/Current-$BUILD_TYPE"
set -g INSTALL_DIR "$BASE_DIR/nightly-$BUILD_TYPE/"(date -I)

source $BASE_DIR/cleanup.fish

echo "Setting up ccache dir..."
export CCACHE_DIR=$BASE_DIR/.build-cache

echo "Setting up CMake prefix path..."
export CMAKE_PREFIX_PATH=/usr

echo "Extra CMake arguments: $EXTRA_CMAKE_ARGUMENTS"

mkdir -p $BUILD_DIR
cd $BUILD_DIR

set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_INSTALL_PREFIX=$CURRENT_DIR/
set -p EXTRA_CMAKE_ARGUMENTS -DQT_BUILD_SUBMODULES=(string join ';' $QT_MODULES)
set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_BUILD_TYPE=Debug
set -p EXTRA_CMAKE_ARGUMENTS -DQT_USE_CCACHE=ON
set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_CXX_FLAGS='-march=native'
set -p EXTRA_CMAKE_ARGUMENTS -GNinja

for arg in $EXTRA_CMAKE_ARGUMENTS
    echo "CMake arg: $arg"
end

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
