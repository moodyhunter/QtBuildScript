#!/bin/fish

if not source (dirname (status --current-filename))/utils/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

cd $SRC_DIR

git pull --rebase --verbose --autostash

./init-repository \
    --module-subset=(string join ',' $QT_MODULES) \
    -f \
    --force-hooks \
    $argv
