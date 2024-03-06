#!/bin/bash
#

SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "SCRIPT_PATH: $SCRIPT_PATH"
source $SCRIPT_PATH/../includes/core-menu/includes/easybashgui
source $SCRIPT_PATH/../includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Fdroid-based app update"

function update_foss_apps()
{
    echo -e "Updating FOSS apps now..."
    echo ""
    $(cd vendor/foss && bash update.sh 1)
    echo -e "FOSS apps updated"
}

update_foss_apps