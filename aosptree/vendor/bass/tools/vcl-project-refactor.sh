#!/bin/bash

# Project Refactor
#
# Check to see if the options passed math any of the variables:
# --st1 - The first search string ST_1
# --rp1 - The replacement for st1 ST_1_RP
#!/bin/bash
#

SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "SCRIPT_PATH: $SCRIPT_PATH"
source $SCRIPT_PATH/../includes/core-menu/includes/easybashgui
source $SCRIPT_PATH/../includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Vendor Customization"

do_refactor(){
    ST_1=$1
    echo "ST_1: $ST_1"
    ST_1_RP=$2
    echo "ST_1_RP: $ST_1_RP"
    cd $SCRIPT_PATH/../overlay/
    grep -r -l "$ST_1" | xargs -r -d'\n' sed -i "s/$ST_1/$ST_1_RP/g"
    cd $SCRIPT_PATH
    grep -r -l "$ST_1" ./build-x86.sh | xargs -r -d'\n' sed -i "s/$ST_1/$ST_1_RP/g"
    cd $PWD
}

# Read $SCRIPT_PATH/../.config/brand_name.cfg
while read -r brand_name; do
    BRAND_NAME="$brand_name"
done < $SCRIPT_PATH/../.config/brand_name.cfg

if [ "$BRAND_NAME" == "" -o "$BRAND_NAME" == "BlissBass" ]; then
    input 1 "What name do you want to give the project? " "BlissBass"
    REFACTOR_TO_NAME=$(0<"${dir_tmp}/${file_tmp}")
    if [[ $REFACTOR_TO_NAME != "" ]]; then
        do_refactor "BlissBass" "$REFACTOR_TO_NAME"
        mkdir -p $SCRIPT_PATH/../.config
        echo "$REFACTOR_TO_NAME" > $SCRIPT_PATH/../.config/brand_name.cfg
    else
        echo "Exiting..."
        exit
    fi
else
    input 1 "We found a brand name of $BRAND_NAME. What name do you want to give the project? " "$BRAND_NAME"
    REFACTOR_TO_NAME=$(0<"${dir_tmp}/${file_tmp}")
    if [[ $REFACTOR_TO_NAME != "" ]]; then
        do_refactor "$BRAND_NAME" "$REFACTOR_TO_NAME"
        mkdir -p $SCRIPT_PATH/../.config
        echo "$REFACTOR_TO_NAME" > $SCRIPT_PATH/../.config/brand_name.cfg
    else
        echo "Exiting..."
        exit
    fi  
fi
