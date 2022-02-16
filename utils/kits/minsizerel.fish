set -g EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DCMAKE_BUILD_TYPE=Release" $EXTRA_CMAKE_ARGUMENTS)
set -g EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DCMAKE_BUILD_TYPE=Debug" $EXTRA_CMAKE_ARGUMENTS)
set -g EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DCMAKE_BUILD_TYPE=RelWithDebInfo" $EXTRA_CMAKE_ARGUMENTS)
set -g EXTRA_CMAKE_ARGUMENTS (string match -v -- "-DCMAKE_BUILD_TYPE=MinSizeRel" $EXTRA_CMAKE_ARGUMENTS)

set -g BUILD_KITS_DISPLAY (string match -v -- debug $BUILD_KITS_DISPLAY)
set -g BUILD_KITS_DISPLAY (string match -v -- release $BUILD_KITS_DISPLAY)
set -g BUILD_KITS_DISPLAY (string match -v -- minsizerel $BUILD_KITS_DISPLAY)
set -g BUILD_KITS_DISPLAY (string match -v -- relwithdebinfo $BUILD_KITS_DISPLAY)

set -ag EXTRA_CMAKE_ARGUMENTS -DCMAKE_BUILD_TYPE=MinSizeRel
set -ag BUILD_KITS_DISPLAY minsizerel

exit 0
