#!/bin/bash
#

SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "SCRIPT_PATH: $SCRIPT_PATH"
source $SCRIPT_PATH/../includes/core-menu/includes/easybashgui
source $SCRIPT_PATH/../includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Vendor Customization"

do_copy_grub(){
    if [ -f $SCRIPT_PATH/../branding/grub/* ]; then
    echo -e "Grub branding found. Updating that now..."
    echo ""
    cp -r $SCRIPT_PATH/../branding/grub/*.png bootable/newinstaller/boot/isolinux/android-x86.png
    echo -e "Grub branding updated"
fi
}

# Select wallpaper
message "Please select your .png grub background: "
fselect 
grub_path=$(0<"${dir_tmp}/${file_tmp}")
echo "grub_path = $grub_path"
if [ -f $grub_path ]; then
    # copy wallpaper to temp folder
    mkdir -p $SCRIPT_PATH/../tmp
    cp -r -f $grub_path $SCRIPT_PATH/../branding/grub/android-x86.png
    # copy background to overlay folders
    do_copy_grub
    message "Grub background copied."
else
    message "Image not found."
fi