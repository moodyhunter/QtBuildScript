#!/bin/fish

if not source (dirname (status --current-filename))/build-utils/common.fish 2>/dev/null
    echo "Initialization failed."
    exit 1
end

cd $BASE_DIR

echo "Current Build Dir: $BUILD_DIR"
echo "Base Build Dir: $BASE_DIR/.build/"

set CLEANUP_DIR $BUILD_DIR

if not string match -q "$BASE_DIR/.build/*" "$CLEANUP_DIR"
    echo ""
    read -l -P '--> Did you mean to clean up the base build directory? [y/N] ' confirm
    switch $confirm
        case Y y
            set CLEANUP_DIR "$BASE_DIR/.build/"
        case '' N n
            exit 0
    end
end

echo "Running cleanup in $CLEANUP_DIR..."

rm -rf $CLEANUP_DIR
mkdir -p $CLEANUP_DIR
