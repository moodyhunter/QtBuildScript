#!/bin/fish

if not source (dirname (status --current-filename))/build-utils/common.fish 2>/dev/null
    echo "Initialization failed."
    exit 1
end

cd $SRC_DIR

./init-repository \
    --module-subset=(string join ',' $QT_MODULES) \
    -f \
    --branch
