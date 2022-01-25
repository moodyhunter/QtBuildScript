if [ "$ANDROID_SDK_ROOT" = "" ]
    set_color red
    echo "Failed to determine Android NDK Path, please define 'ANDROID_SDK_ROOT' environment variable."
end

if [ "$ANDROID_NDK_ROOT" = "" ]
    set_color red
    echo "Failed to determine Android NDK Path, please define 'ANDROID_NDK_ROOT' environment variable."
end

if not contains -- $QT_ARCH arm64-v8a armeabi-v7a x86 x86_64
    set_color red
    echo -n "Invalid architecture: "
    set_color normal
    echo $QT_ARCH
    exit 1
end

set -p EXTRA_CMAKE_ARGUMENTS "-DANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
set -p EXTRA_CMAKE_ARGUMENTS "-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake"
set -p EXTRA_CMAKE_ARGUMENTS "-DQT_HOST_PATH=$QT_HOST_PATH"
set -p EXTRA_CMAKE_ARGUMENTS "-DANDROID_PLATFORM=29"
set -p EXTRA_CMAKE_ARGUMENTS "-DANDROID_ABI=$QT_ARCH"
