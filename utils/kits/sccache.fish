if [ -z "$DO_NOT_SET_SCCACHE_DIR" ]
    export SCCACHE_DIR=$BASE_DIR/.sccache
    echo "  Using sccache directory: $SCCACHE_DIR"
    set -p EXTRA_EXPORT_VARIABLES SCCACHE_DIR
else
    echo "  DO_NOT_SET_SCCACHE_DIR is set."
end

echo -n "  " && sccache --stop-server 2>/dev/null | head -n1
sleep 1
echo -n "  " && sccache --start-server && sleep 1

echo "  Cache Directory: "(string trim (sccache -s | grep 'Cache location' | cut -d ':' -f2))

if [ -z "$DO_NOT_SET_SCCACHE_DIR" ]
    sccache -z >/dev/null
end

set EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DQT_USE_CCACHE=ON" $EXTRA_CMAKE_ARGUMENTS)
set EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DBUILD_WITH_PCH=OFF" $EXTRA_CMAKE_ARGUMENTS)

set -p EXTRA_CMAKE_ARGUMENTS "-DCMAKE_C_COMPILER_LAUNCHER=sccache"
set -p EXTRA_CMAKE_ARGUMENTS "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache"

set -g BUILD_KITS_DISPLAY (string match -v sccache $BUILD_KITS_DISPLAY) || true
