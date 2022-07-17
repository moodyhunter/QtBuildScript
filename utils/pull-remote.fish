#!/usr/bin/env fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

set NIGHTLY_DIR "$BASE_DIR/nightly"

set_color green && echo -n "=> " && set_color reset && echo "Pulling remote files..."
cd $NIGHTLY_DIR/.pulled
rsync -rP "$QT_BUILDER_REMOTE" . || exit 1

cd $NIGHTLY_DIR

set_color green && echo -n "=> " && set_color reset && echo "Extracting files..."
for file in $NIGHTLY_DIR/.pulled/*
    set_color blue && echo -n "  -> " && set_color reset && echo "Extracting '$file'..."
    tar xf $file || exit 1
    rm $file
end

echo ""
"$BASE_DIR"/utils/patch-bindir.fish

echo ""
"$BASE_DIR"/utils/fix-current-link.fish
