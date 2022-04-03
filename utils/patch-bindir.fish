#!/bin/fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

set REPLACEMENT "/var/lib/gitlab-runner/QtBuildScript/nightly/"

for f in $BASE_DIR/nightly/*/*/bin/qmake $BASE_DIR/nightly/*/*/bin/qtpaths $BASE_DIR/nightly/*/*/lib/cmake/Qt6/qt.toolchain.cmake
    grep -q "$REPLACEMENT" $f && echo -n "Patching $f..." && sed -i "s,$REPLACEMENT,$BASE_DIR/nightly/,g" $f && echo " Done."
end
