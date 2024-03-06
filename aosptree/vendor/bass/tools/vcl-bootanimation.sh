#!/bin/bash
#

SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "SCRIPT_PATH: $SCRIPT_PATH"
source $SCRIPT_PATH/../includes/core-menu/includes/easybashgui
source $SCRIPT_PATH/../includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Vendor Customization"

# Cleanup
rm -rf $SCRIPT_PATH/../tmp/bootanimation

do_package_bootanimation(){
    ba_frames_exist=$(find $SCRIPT_PATH/../tmp/bootanimation -name "*.png")
    if [ "$ba_frames_exist" ]; then
        find $SCRIPT_PATH/../tmp/bootanimation -name "*.png" ;
        cd $SCRIPT_PATH/../tmp/bootanimation
        # tar -uvf $SCRIPT_PATH/../tmp/bootanimation.tar
        tar -cvf $SCRIPT_PATH/../tmp/bootanimation.tar *.png
        cd $PWD
        if [ -f $SCRIPT_PATH/../tmp/bootanimation.tar ]; then
            mv $SCRIPT_PATH/../tmp/bootanimation.tar $SCRIPT_PATH/../branding/bootanimation/
        else
            message "Error: no bootanimation.tar was generated."
        fi
    else
        message "no files found in specified folder."
    fi
}

do_screen_size(){
    input 1 "Please enter the screen width: " "800"
    BT_SWIDTH=$(0<"${dir_tmp}/${file_tmp}")
    input 1 "Please enter the screen height: " "800"
    BT_SHEIGHT=$(0<"${dir_tmp}/${file_tmp}")
    
    # replace line starting with 'TARGET_SCREEN_WIDTH ?=' in ../branding.mk with new value
    sed -i "s/^TARGET_SCREEN_WIDTH ?=.*/TARGET_SCREEN_WIDTH ?= $BT_SWIDTH/g" $SCRIPT_PATH/../branding.mk
    # replace line starting with 'TARGET_SCREEN_HEIGHT ?=' in ../branding.mk with new value
    sed -i "s/^TARGET_SCREEN_HEIGHT ?=.*/TARGET_SCREEN_HEIGHT ?= $BT_SHEIGHT/g" $SCRIPT_PATH/../branding.mk

    echo "BT_SWIDTH = $BT_SWIDTH"
    echo "BT_SHEIGHT = $BT_SHEIGHT"
    echo "screen size set to $BT_SWIDTH x $BT_SHEIGHT"
}

# Select wallpaper
message "Please select folder with all your bootanimation frames: "
dselect 
ba_assets_path=$(0<"${dir_tmp}/${file_tmp}")
echo "ba_assets_path = $ba_assets_path"
if [ -d $ba_assets_path ]; then
    # copy wallpaper to temp folder
    mkdir -p $SCRIPT_PATH/../tmp
    mkdir -p $SCRIPT_PATH/../tmp/bootanimation
    cp -r -f $ba_assets_path/* $SCRIPT_PATH/../tmp/bootanimation/
    # copy background to overlay folders
    do_package_bootanimation
    do_screen_size
    message "bootanimation.tar generated."
else
    message "not a valid path."
fi