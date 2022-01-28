#!/bin/fish

if not source (dirname (status --current-filename))/utils/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

cd $BASE_DIR

set -le arg_flag
set -lp arg_flag (fish_opt --short=p --long=platform --required-val)
set -lp arg_flag (fish_opt --short=a --long=arch --required-val)
set -lp arg_flag (fish_opt --short=h --long=host-path --required-val)
set -lp arg_flag (fish_opt --short=j --long=parallel --optional-val)
set -lp arg_flag (fish_opt --short=1 --long=help --long-only)
set -lp arg_flag (fish_opt --short=k --long=skip-cleanup)

argparse $arg_flag -- $argv || exit 1

set SUPPORTED_PLATFORMS (basename -s .fish $BASE_DIR/utils/platforms/* | sort)
set SUPPORTED_KITS (basename -s .fish $BASE_DIR/utils/kits/* | sort)

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
set QT_ARCH (if test -z "$_flag_arch"; echo "x86_64"; else; echo "$_flag_arch"; end)

if not contains -- "$QT_PLATFORM" $SUPPORTED_PLATFORMS
    set_color red
    echo "Platform '$QT_PLATFORM' not supported."
    exit 1
end

for kit in $argv
    if not contains -- "$kit" $SUPPORTED_KITS
        set_color red
        echo "Build kit '$kit' not supported."
        exit 1
    end
end

# Prepend base-kits if exists
if test -e $BASE_DIR/.base-kits
    set_color green
    echo -n "Applying base kits from: "
    set_color normal
    echo "$BASE_DIR/.base-kits"

    for k in (cat $BASE_DIR/.base-kits)
        set_color green
        echo -n "  Applied: "
        set_color normal
        echo "$k"
        set -p argv "$k"
    end
end

# If kits are empty, apply default kits.
if test -z "$argv"
    set_color blue
    echo -n "Applying default kits from: "
    set_color normal
    echo "$BASE_DIR/.default-kits"
    set argv
    for k in (cat $BASE_DIR/.default-kits)
        set_color green
        echo -n "  Applied: "
        set_color normal
        echo "$k"
        set -p argv "$k"
    end
    set_color normal
end

if [ "$QT_PLATFORM" != "desktop" ]
    if not set -q _flag_host_path
        set -l desktops $BASE_DIR/Current/desktop-*
        if set -q desktops[1]
            set QT_HOST_PATH (realpath $desktops[1])
            set_color green
            echo -n "Detected QT_HOST_PATH: "
            set_color normal
            echo $QT_HOST_PATH
        else
            set_color red
            echo "Cannot automatically detect Qt host path, please specify one using -h option."
            exit 1
        end
    else
        set QT_HOST_PATH $_flag_host_path
    end
end

set BUILD_KITS $argv

if source "$BASE_DIR/utils/platforms/$QT_PLATFORM.fish" 2>/dev/null
    set_color green
    echo -n "Platform initialised: "
    set_color normal
    echo "$QT_PLATFORM"
else
    set_color red
    echo "Failed to initialise platform '$QT_PLATFORM'."
    exit 1
end

# Remove ccache from display kits.
set BUILD_KITS_DISPLAY (string match -v ccache $BUILD_KITS)
set BUILD_TYPE (string join '-' -- "$QT_PLATFORM" $QT_ARCH (string join '-' (for k in $BUILD_KITS_DISPLAY; echo $k; end | sort | uniq)))

echo ""
echo "Kit Identifier: $BUILD_TYPE"
echo ""

set_color green
echo "Loading Kits..."
set_color normal

for kit in $BUILD_KITS
    if not contains -- $kit $SUPPORTED_KITS
        set_color red
        echo "Build kit '$kit' not supported."
        exit 1
    end

    set_color blue
    if source "$BASE_DIR/utils/kits/$kit.fish" 2>/dev/null
        set_color green
        echo -n "  Loaded: "
        set_color normal
        echo "$kit"
    else
        set_color red
        echo "Failed to load '$kit'."
        exit 1
    end
end

set -g BUILD_DIR "$BASE_DIR/.build/$BUILD_TYPE"
set -g INSTALL_DIR "$BASE_DIR/nightly/$BUILD_TYPE/"(date -I)

set -p EXTRA_CMAKE_ARGUMENTS -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/
set -p EXTRA_CMAKE_ARGUMENTS -GNinja

echo ""
echo "CMake arguments:"
set_color blue
for arg in $EXTRA_CMAKE_ARGUMENTS
    echo "  $arg"
end
set_color normal

set -p EXTRA_CMAKE_ARGUMENTS -DQT_BUILD_SUBMODULES=(string join ';' -- $QT_MODULES)

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
    source $BASE_DIR/utils/cleanup.fish
end

mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake $SRC_DIR $EXTRA_CMAKE_ARGUMENTS || exit 1

ccache -z
cmake --build . --parallel $VAR_PARALLEL || exit 1

mv $INSTALL_DIR/ $INSTALL_DIR-backup/
mkdir -p $INSTALL_DIR

cmake --install . || exit 1


echo "build time:" (date) >$INSTALL_DIR/modules.info

for d in $QT_MODULES
    echo $d "->" (git --git-dir $BASE_DIR/qt/$d/.git/ log -1 --format=%H)
end >>$INSTALL_DIR/modules.info

ccache -sv | tee $INSTALL_DIR/cache.info

rm -rf $INSTALL_DIR-backup/

set -g CURRENT_DIR "$BASE_DIR/Current/$BUILD_TYPE"
rm $CURRENT_DIR
ln -svf $INSTALL_DIR $CURRENT_DIR

echo "Done"
