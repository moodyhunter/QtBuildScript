#!/bin/fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

set NIGHTLY_DIR "$BASE_DIR/nightly"

cd $NIGHTLY_DIR/.pulled
rsync --remove-source-files -rP "$QT_BUILDER_REMOTE" . || exit 1

cd $NIGHTLY_DIR
tar xvf $NIGHTLY_DIR/.pulled/*
rm -v $NIGHTLY_DIR/.pulled/*

