#!/bin/fish

if not source (dirname (status --current-filename))/utils/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

set -le arg_flag
set -lp arg_flag (fish_opt --short=p --long=platform --required-val)
set -lp arg_flag (fish_opt --short=a --long=arch --required-val)
set -lp arg_flag (fish_opt --short=h --long=host-path --required-val)
set -lp arg_flag (fish_opt --short=j --long=parallel --optional-val)
set -lp arg_flag (fish_opt --short=1 --long=help --long-only)
set -lp arg_flag (fish_opt --short=k --long=skip-cleanup)

argparse $arg_flag -- $argv || exit 1

set SUPPORTED_PLATFORMS (basename -s .fish $BASE_DIR/platforms/* | sort)
set SUPPORTED_KITS (basename -s .fish $BASE_DIR/kits/* | sort)

if set -q _flag_help
    echo (status --current-filename) "--help"
    echo (status --current-filename) "[options] [kits]"
    echo ""
    echo "options:"
    echo "  -p, --platform          The target platform, default value is 'desktop', one of ["(string join ', ' $SUPPORTED_PLATFORMS)"]"
    echo "  -a, --arch              Target architecture, default='x86_64', platform-specific."
    echo "  -h, --host-path         Path to the Qt host build directory, can be automatically detected if unspecified."
    echo "  -j, --parallel          Run N jobs at once, can be automatically detected from nproc if unspecified."
    echo "  -k, --skip-cleanup      Skip cleanup the build directory."
    echo ""
    echo "kits:"
    echo "  combination of:"
    printf '  - %s\n' $SUPPORTED_KITS
    exit 0
end

set VAR_PARALLEL (if test -z "$_flag_parallel"; nproc; else; echo "$_flag_parallel"; end)
set SKIP_CLEANUP (if set -q _flag_skip_cleanup; echo "1"; else; echo "0"; end)
set QT_PLATFORM (if test -z "$_flag_platform"; echo "desktop"; else; echo "$_flag_platform"; end)

if [ "$QT_PLATFORM" != "desktop" ]
    set QT_ARCH (if test -z "$_flag_arch"; echo "x86_64"; else; echo "$_flag_arch"; end)
end


if not contains -- $QT_PLATFORM $SUPPORTED_PLATFORMS
    echo "Platform '$QT_PLATFORM' not supported."
end

for kit in $argv
    if not contains -- $kit $SUPPORTED_KITS
        set_color red
        echo "Build kit '$kit' not supported."
        exit 1
    end
end

if [ "$argv" = "" ]
    set argv shared release
end

set BUILD_TYPE (string join '-' $QT_PLATFORM $QT_ARCH (string join '-' (for k in $argv; echo $k; end | sort | uniq)))

echo "Qt kit identifier: $BUILD_TYPE"
echo ""


if [ "$QT_PLATFORM" != "desktop" ]
    if not set -q _flag_host_path
        set -l desktops $BASE_DIR/Current/desktop-*
        if set -q desktops[1]
            set QT_HOST_PATH $desktops[1]
            set_color green
            echo -n "Detected QT_HOST_PATH: "
            set_color normal
            echo $QT_HOST_PATH
        else
            set_color red
            echo "Cannot automatically detect Qt host path, please specify one using -h option."
            exit 1
        end
    end
end

if source "$BASE_DIR/platforms/$QT_PLATFORM.fish" 2>/dev/null
    set_color green
    echo -n "Platform initialised: "
    set_color normal
    echo "$QT_PLATFORM"
else
    set_color red
    echo "Failed to initialise platform '$QT_PLATFORM'."
    exit 1
end

for kit in $argv
    if not contains -- $kit $SUPPORTED_KITS
        set_color red
        echo "Build kit '$kit' not supported."
        exit 1
    end

    if source "$BASE_DIR/kits/$kit.fish" 2>/dev/null
        set_color green
        echo -n "Loaded kit: "
        set_color normal
        echo "$kit"
    else
        set_color red
        echo "Failed to load '$kit'."
        exit 1
    end
end

cd $BASE_DIR
set -g BUILD_DIR "$BASE_DIR/.build/$BUILD_TYPE"
set -g CURRENT_DIR "$BASE_DIR/Current/$BUILD_TYPE"
set -g INSTALL_DIR "$BASE_DIR/nightly/$BUILD_TYPE/"(date -I)

echo ""
export CCACHE_DIR=$BASE_DIR/.build-cache
echo "Using ccache dir: $CCACHE_DIR"

set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_INSTALL_PREFIX=$CURRENT_DIR/
set -p EXTRA_CMAKE_ARGUMENTS -DQT_USE_CCACHE=ON
set -p EXTRA_CMAKE_ARGUMENTS -DBUILD_WITH_PCH=OFF
set -p EXTRA_CMAKE_ARGUMENTS -GNinja

echo ""
echo "CMake arguments:"
set_color blue
for arg in $EXTRA_CMAKE_ARGUMENTS
    echo "  $arg"
end
set_color normal

set -p EXTRA_CMAKE_ARGUMENTS -DQT_BUILD_SUBMODULES=(string join ';' $QT_MODULES)

echo ""
if [ "$SKIP_CLEANUP" = "1" ]
    set_color yellow
    echo -n "Will not cleanup build directory: "
    set_color normal
    echo "$BUILD_DIR"
end

set_color yellow
echo "Will build with $VAR_PARALLEL concurrent jobs."
echo -n "Will start building in 5 seconds, press Ctrl+C to cancel: "
for sec in 5 4 3 2 1
    echo -n "$sec..."
    sleep 1
end

set_color normal
echo ""

mkdir -p "$BASE_DIR/Current/"
mkdir -p "$BASE_DIR/nightly/"

if [ "$SKIP_CLEANUP" = "0" ]
    source $BASE_DIR/cleanup.fish
end

mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake $SRC_DIR $EXTRA_CMAKE_ARGUMENTS || exit 1

ccache -z
cmake --build . --parallel $VAR_PARALLEL || exit 1

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
