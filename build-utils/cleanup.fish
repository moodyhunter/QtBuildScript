#!/bin/fish

echo "Cleaning up: $BUILD_DIR"

if not string match -e "$BASE_DIR/.build/" "$BUILD_DIR" >/dev/null
    echo "BUILD_DIR is invalid"
    exit 1
end

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
