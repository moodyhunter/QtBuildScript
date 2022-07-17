#!/usr/bin/env fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

set EXIT_CODE 0

for f in $BASE_DIR/patches/*.patch
    set PATCH_FILE_NAME (basename $f | cut -d'.' -f-1)
    set PATCH_NUMBER (echo $PATCH_FILE_NAME | cut -d'-' -f1)
    set PATCH_MODULE (echo $PATCH_FILE_NAME | cut -d'-' -f2)
    set PATCH_NAME (echo $PATCH_FILE_NAME | cut -d'-' -f3- | sed 's/-/ /g')

    set_color blue
    echo -n "Applying patch: "
    set_color normal
    echo -n "#$PATCH_NUMBER ($PATCH_NAME)"
    set_color blue
    echo -n " in: "
    set_color normal
    echo -n "$PATCH_MODULE"
    cd $BASE_DIR/qt/$PATCH_MODULE

    set GIT_OUTPUT (git apply $f 2>&1)
    if test $status -ne 0
        set EXIT_CODE 1
        echo ""
        set_color yellow
        echo "  Failed:"
        for line in $GIT_OUTPUT
            echo "    $line"
        end
        set_color normal
    else
        set_color green
        echo " -> Success!"
        set_color normal
    end
end

exit $EXIT_CODE
