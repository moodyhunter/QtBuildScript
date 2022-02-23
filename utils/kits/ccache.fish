export CCACHE_DIR=$BASE_DIR/.build-cache
echo "  Using ccache directory: $CCACHE_DIR"
echo -n "  " && ccache -z

set EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DCMAKE_C_COMPILER_LAUNCHER=sccache" $EXTRA_CMAKE_ARGUMENTS)
set EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache" $EXTRA_CMAKE_ARGUMENTS)

set -p EXTRA_CMAKE_ARGUMENTS "-DQT_USE_CCACHE=ON"
set -p EXTRA_CMAKE_ARGUMENTS "-DBUILD_WITH_PCH=OFF"

set -p EXTRA_EXPORT_VARIABLES CCACHE_DIR

# SPECIAL CASE: sccache
set -g BUILD_KITS_DISPLAY (string match -v -- ccache $BUILD_KITS_DISPLAY) || true
