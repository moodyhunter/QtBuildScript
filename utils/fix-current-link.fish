#!/bin/fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

set_color green && echo -n "=> " && set_color reset && echo "Setting up 'Current' directory..."
for d in $BASE_DIR/nightly/*/
    set DIRNAME (basename $d)
    set TARGET $BASE_DIR/nightly/$DIRNAME/(ls -1 -t $BASE_DIR/nightly/$DIRNAME/ | head -n1)
    rm $BASE_DIR/Current/$DIRNAME 2>&1 >/dev/null || true
    set_color blue && echo -n "  -> " && set_color reset && ln -svf $TARGET $BASE_DIR/Current/$DIRNAME
end
