set -p EXTRA_CMAKE_ARGUMENTS "-DFEATURE_cxx20=ON"

set -g BUILD_KITS_DISPLAY (string match -v cpp20 $BUILD_KITS_DISPLAY)
exit 0
