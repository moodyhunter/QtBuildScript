if [ "$EMSCRIPTEN_ROOT" = "" ]
    set_color red
    echo "Failed to determine Emscripten Root Path, please define 'EMSCRIPTEN_ROOT' environment variable."
end

set BUILD_KITS (string match -v shared $BUILD_KITS)
set -p BUILD_KITS static

set -p EXTRA_CMAKE_ARGUMENTS "-DCMAKE_TOOLCHAIN_FILE=$EMSCRIPTEN_ROOT/cmake/Modules/Platform/Emscripten.cmake"
set -p EXTRA_CMAKE_ARGUMENTS "-DQT_HOST_PATH=$QT_HOST_PATH"

# Neither QDoc nor clang-based lupdate needs to be built, so setting them off is safe.
set -p EXTRA_CMAKE_ARGUMENTS "-DFEATURE_clangcpp=OFF"
set -p EXTRA_CMAKE_ARGUMENTS "-DFEATURE_clang=OFF"
