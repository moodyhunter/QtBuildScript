if [ "$EMSCRIPTEN_ROOT" = "" ]
    set_color red
    echo "Failed to determine Emscripten Root Path, please define 'EMSCRIPTEN_ROOT' environment variable."
    exit 1
end

if not source (realpath "$EMSCRIPTEN_ROOT/../../emsdk_env.fish")
    set_color red
    echo "Failed to source emsdk_env"
    exit 1
end

set -e QT_ARCH
set BUILD_KITS (string match -v shared $BUILD_KITS)
set -p BUILD_KITS static

set -p EXTRA_CMAKE_ARGUMENTS "-DCMAKE_TOOLCHAIN_FILE=$EMSCRIPTEN_ROOT/cmake/Modules/Platform/Emscripten.cmake"
set -p EXTRA_CMAKE_ARGUMENTS "-DQT_HOST_PATH=$QT_HOST_PATH"

# Neither QDoc nor clang-based lupdate needs to be built, so setting them off is safe.
set -p EXTRA_CMAKE_ARGUMENTS "-DFEATURE_clangcpp=OFF"
set -p EXTRA_CMAKE_ARGUMENTS "-DFEATURE_clang=OFF"

set -p EXTRA_EXPORT_VARIABLES EMSCRIPTEN_ROOT
set -p EXTRA_EXPORT_VARIABLES EM_CONFIG
set -p EXTRA_EXPORT_VARIABLES EMSDK_NODE
set -p EXTRA_EXPORT_VARIABLES EMSDK
