#!/usr/bin/env fish

if not source (dirname (status --current-filename))/common.fish 2>/dev/null
    set_color red
    echo "Initialization failed."
    exit 1
end

cd $BASE_DIR/nightly

for dir in (ls)
    cd $BASE_DIR/nightly
    set DATE_TO_PACKAGE (ls -d $dir/????-??-?? | sort -r | head -n1 | cut -d'/' -f2)
    set_color green && echo -n "=>" && set_color reset && echo " Packaging $dir ($DATE_TO_PACKAGE)..."
    tar --zstd -cf "$BASE_DIR/nightly/.packaged/$dir-$DATE_TO_PACKAGE.tar.zst" "$dir/$DATE_TO_PACKAGE"
end
