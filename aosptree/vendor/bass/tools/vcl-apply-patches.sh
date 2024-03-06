#!/bin/bash

# Project Refactor
#
# Check to see if the options passed math any of the variables:
# --st1 - The first search string ST_1
# --rp1 - The replacement for st1 ST_1_RP
#!/bin/bash
#

SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PARENT_PATH="$(dirname "$SCRIPT_PATH")"
echo "SCRIPT_PATH: $SCRIPT_PATH"
source $PARENT_PATH/includes/core-menu/includes/easybashgui
source $PARENT_PATH/includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Vendor Customization"

do_check_patchsets() 
{
    patchset_type=$1
    # local T=$(gettop)
    # if [ ! "$T" ]; then
    #     echo "[lunch] Couldn't locate the top of the tree.  Try setting TOP." >&2
    #     return
    # fi
    # Find the first folder in $PARENT_PATH/patches/patchsets
    are_patchsets=`ls $PARENT_PATH/patches/patchsets`
    if [ ! "$are_patchsets" ]; then
        echo "[lunch] No patchsets found"
        return
    else
        echo "[lunch] Patchsets found"
        if [ "$patchset_type" != "" ]; then
            if [ -d $patchset_type ]; then
                bash $PARENT_PATH/patches/autopatch.sh $patchset_type
            else
                echo "No patchsets found for $patchset_type"
            fi
        else
            echo "There was an error somewhere"
        fi
    fi
}

# Read folder names of $PARENT_PATH/patches/* to a list
# PATCHSET_NAMES=$(ls $PARENT_PATH/patches)
PATCHSET_NAMES=$(ls $PARENT_PATH/patches )
# PATCHSET_NAMES=$(find $PARENT_PATH/patches -maxdepth 0 -type d -ls)
echo "PATCHSET_NAMES: $PATCHSET_NAMES"
MENU_ITEMS=()
prefix="patchsets-"
# if name in PATCHSET_NAMES == "patchset" then add "Bliss OS" to MENU_ITEMS
for patchset_name in $PATCHSET_NAMES; do
    if [ "$patchset_name" = "patchsets" ]; then
        MENU_ITEMS="$MENU_ITEMS BlissOS"
    elif [ "$patchset_name" == "patchsets--resolutions" -o "$patchset_name" == "autopatch.sh" ]; then
        MENU_ITEMS="$MENU_ITEMS"
    else
        MENU_ITEMS="$MENU_ITEMS ${patchset_name#"$prefix"}"
    fi
done
menu ${MENU_ITEMS[@]}
patchsets_answer=$(0<"${dir_tmp}/${file_tmp}")
if [[ "$patchsets_answer" == "BlissOS" ]]; then
    do_check_patchsets "$PARENT_PATH/patches/patchsets"
else
    do_check_patchsets "$prefix$patchsets_answer"
fi