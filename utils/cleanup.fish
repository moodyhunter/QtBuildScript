#!/bin/fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

cd $BASE_DIR

echo ""
echo "Current Build Dir: $BUILD_DIR"

set CLEANUP_DIR $BUILD_DIR

if not string match -q "$BASE_DIR/.build/*" "$CLEANUP_DIR"
    echo ""
    echo "Base build directory: $BASE_DIR/.build/"
    read -l -P '--> Did you mean to clean up the base build directory? [y/N] ' confirm
    switch $confirm
        case Y y
            set CLEANUP_DIR "$BASE_DIR/.build/"
        case '' N n
            exit 0
    end
end

set_color yellow
echo "Running cleanup in $CLEANUP_DIR..."
set_color normal

if test -d "$CLEANUP_DIR"
    # Delete folder if exists
    rm -rf $CLEANUP_DIR
end

mkdir -p $CLEANUP_DIR
