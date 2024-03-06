#!/bin/bash
#

SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "SCRIPT_PATH: $SCRIPT_PATH"
source $SCRIPT_PATH/../includes/core-menu/includes/easybashgui
source $SCRIPT_PATH/../includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Vendor Customization"

do_copy_wallpaper(){
    if [ -f $SCRIPT_PATH/../branding/wallpaper/* ]; then
    echo -e "Wallpaper branding found. Updating that now..."
    echo ""
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-hdpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-mdpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-nodpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-xhdpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-xxhdpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-xxxhdpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-sw600dp-nodpi/
    cp -r $SCRIPT_PATH/../branding/wallpaper/* $SCRIPT_PATH/../overlay/common/frameworks/base/core/res/res/drawable-sw720dp-nodpi/
    echo -e "Wallpaper branding updated"
fi
}

# Select wallpaper
message "Please select your .png wallpaper: "
fselect 
wallpaper_path=$(0<"${dir_tmp}/${file_tmp}")
echo "wallpaper_path = $wallpaper_path"
if [ -f $wallpaper_path ]; then
    # copy wallpaper to temp folder
    mkdir -p $SCRIPT_PATH/../tmp
    cp -r -f $wallpaper_path $SCRIPT_PATH/../branding/wallpaper/default_wallpaper.png
    # copy wallpaper to overlay folders
    do_copy_wallpaper
    message "Wallpaper copied."
else
    message "Wallpaper not found."
fi