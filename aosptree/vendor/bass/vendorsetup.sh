# Bass OS vendor profile
#
# This is part of the Bliss-Bass vendor template and is
# used to set the customization preferences for your project
#
# SPDX-License-Identifier: BSD-3-Clause

# set -e

# save the official lunch command to aosp_lunch() and source it
tmp_lunch=`mktemp`
TEMP_PATH=$(mktemp -d)

#setup colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
teal=`tput setaf 6`
light=`tput setaf 7`
dark=`tput setaf 8`
ltred=`tput setaf 9`
ltgreen=`tput setaf 10`
ltyellow=`tput setaf 11`
ltblue=`tput setaf 12`
ltpurple=`tput setaf 13`
CL_CYN=`tput setaf 12`
CL_RST=`tput sgr0`
reset=`tput sgr0`

# grab path for this script
SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# define vendor_name as the top directory name
vendor_name=$(basename "$SCRIPT_PATH")

# replace "vendor/branding" with "vendor/$vendor_name" in vendor/$vendor_name/branding/menus/branding-menu/branding-menu.json
sed -i "s/branding/$vendor_name/g" vendor/$vendor_name/branding/menus/branding-menu/branding-menu.json
if sed -i "s/vendor\/branding/vendor\/$vendor_name/g" vendor/$vendor_name/bootanimation/Android.mk; then
    echo -e "${green}Setting vendor name\n${reset}"
else
    echo -e "${yellow}Vendor Customization functions not found. Check license and verify all instructions have been followed, continuing without menu...\n${reset}"
fi

sed -i "s/vendor\/branding/vendor\/$vendor_name/g" vendor/$vendor_name/branding.mk

echo "SCRIPT_PATH: $SCRIPT_PATH"
export PATH="$SCRIPT_PATH/includes/core-menu/includes/:$PATH"
source $SCRIPT_PATH/includes/core-menu/includes/easybashgui
source $SCRIPT_PATH/includes/core-menu/includes/common.sh
export supertitle="Bliss-Bass Vendor Customization"
if source $SCRIPT_PATH/branding/branding_setup.sh; then
    echo -e "${green}Loading vendor customization functions\n${reset}"
else
    echo -e "${yellow}Vendor Customization functions not found. Check license and verify all instructions have been followed, continuing without menu...\n${reset}"
fi

# source the official lunch command
sed '/ lunch()/,/^}/!d'  build/envsetup.sh | sed 's/function lunch/function aosp_lunch/' > ${tmp_lunch}
source ${tmp_lunch}
rm -f ${tmp_lunch}

function checkProjectStatus() {
    TARGET_PROJECT_PATH=$1
    cd $TARGET_PROJECT_PATH
    echo -e "${purple}target_project_path:${reset} $TARGET_PROJECT_PATH"
    # Get the list of all repos
    echo "Getting list of repos..."
    repos=$(find -L $TARGET_PROJECT_PATH -type d -name ".git" -o -type l -name ".git" -not -path "$TARGET_PROJECT_PATH/out/*")
    # repos=$(find $TARGET_PROJECT_PATH -type d -name ".git")

    # Create a variable to store repos that need to be pushed
    repos_to_push=""
    repos_array=()

    # Get the current projects manifest file and save it to a temp folder
    echo "Getting current projects manifest..."
    manifest=$(repo manifest -o $TEMP_PATH/manifest.xml)

    # Also get a revisional manifest for top commit ID
    echo "Generating revisional manifest. Please wait..."
    revisional_manifest=$(repo manifest -o $TEMP_PATH/revisional_manifest.xml -r)
    
    # Get the current date and time
    current_date=$(date +"%Y%m%d%H%M%S")
    # Save $repos_to_push to a file and show the user using alert_dialog
    echo "$TARGET_PROJECT_PATH" >$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
    # For each repo
    for repo in $repos; do

        # Change directory to the repo
        cd $repo

        # Get the current remote and branch
        current_remote=$(git remote show -n 1)
        current_branch=$(git branch | sed -n '1p')

        # get the path of $repo relative to $TARGET_PROJECT_PATH
        prefix="$TARGET_PROJECT_PATH/"
        suffix="/.git"
        string="$repo"
        repo_path=${string#"$prefix"}
        repo_path=${repo_path%"$suffix"}

        # check the $TEMP_PATH/manifest.xml for the line containing $repo_path
        # and if it does not exist, add it to $repos_to_push
        isInFile=$(echo "$manifest" | grep -c "$repo_path")

        if [ $isInFile -ne 0 ]; then
            echo -e "${ltred}Project not found in manifest.xml:${reset} $repo_path"
            # repos_to_push="$repos_to_push $repo"
            echo "NOT IN MANIFEST: $repo_path" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
            # Get current revision using git branch --show-current
            revision=$(git --work-tree=$repo branch --show-current)
            # echo "revision: $revision"
        else
            # echo "repo_path already exists in manifest.xml"

            # check for uncommitted changes
            base_repo_path=${repo%"$suffix"}
            if [[ "$base_repo_path" != "$TARGET_PROJECT_PATH" ]] || [[ "$base_repo_path" != "$TARGET_PROJECT_PATH/vendor/bass" ]]; then
                uncommitted_changes=$(git --work-tree=$base_repo_path status --porcelain | grep -c "M ")
                if [[ "$uncommitted_changes" != "" ]] && [[ "$uncommitted_changes" -ne 0 ]] && [[ "$uncommitted_changes" != "nothing to commit, working tree clean" ]]; then 
                    echo -e "${ltred}repo_path:${reset} $repo_path"
                    echo -e "${ltyellow}repo has uncommitted changes${reset}"
                    echo -e "${purple}base_repo_path:${reset} $base_repo_path"
                    echo "UNCOMMITTED CHANGES: $uncommitted_changes : $repo_path" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                    open_git_changes=$(git --work-tree=$base_repo_path status)
                    echo "      $open_git_changes" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                    echo "" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                    echo "" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                fi

                # use git log to get the top commit ID
                top_commit_id=$(git --work-tree=$base_repo_path log -n 1 --pretty=format:%H)
                # echo "top_commit_id: $top_commit_id"
                short_commit_id=$(echo ${top_commit_id:0:10})
                
                # Check if the top commit ID matches up with the revisional_manifest for this repo
                rv_revision_pre=$(cat $TEMP_PATH/revisional_manifest.xml | grep "$repo_path")
                rv_revision_post=$(echo "$rv_revision_pre" | grep -o -P '(?<=revision=")[^"]+')
                short_rev_post=$(echo ${rv_revision_post:0:10})
                

                if [[ "$short_commit_id" != "$short_rev_post" ]] && [[ ! ${#top_commit_id} -gt 25 ]] && [[ "$short_commit_id" != "" ]] && [[ "$short_rev_post" != "" ]] ; then
                    echo -e "${ltyellow}repo_path:${reset} $repo_path"
                    echo "short_commit_id: $short_commit_id"
                    echo "short_rev_post: $short_rev_post"
                    echo "Repo is checked out at a different place than in the manifest: $repo_path"
                    echo "REVISION ID MISMATCH: $repo_path" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                    echo "" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                    echo "" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                fi
                
                # Check if the top commit ID matches up with the revisional_manifest for this repo
                m_branch_pre=$(cat $TEMP_PATH/manifest.xml | grep "$repo_path")
                m_branch_post=$(echo "$m_branch_pre" | grep -o -P '(?<=revision=")[^"]+')
                # echo "m_branch_pre: $m_branch_pre"
                # echo "m_branch_post: $m_branch_post"

                # Get the repo remote URL using git remote show
                repo_remote=$(git --work-tree=$base_repo_path remote show)
                if [ "$DEBUG" == "true" ]; then
                    if [ "$repo_remote" == "" ]; then
                        echo "repo_remote: $repo_remote"
                    fi
                fi
                
                if [ -n "$repo_remote" ]; then
                    git_remote_url=$(git --work-tree=$base_repo_path remote get-url "$repo_remote")
                    if [ "$git_remote_url" == "" ]; then
                        echo -e "${ltyellow}Path is currently checked out at a different branch with no remote URL:${reset} $repo_path"
                        echo "REPO CHECKED OUT AT DIFFERENT BRANCH: $repo_path" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                        echo "" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                        echo "" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                    fi
                fi

                # Get the repo branch name from git branch --show-current
                repo_branch=$(git --work-tree=$base_repo_path branch --show-current)
                # echo "repo_branch: $repo_branch"

                # # Check the upstream remote has the current branched checked out at the same top_commit_id
                # upstream_remote=$(git --work-tree=$base_repo_path ls-remote --heads $git_remote_url)
                # upstream_commit_id=$(echo "$upstream_remote" | grep "refs/heads/$m_branch_post" | cut -f1)
                # # echo "upstream_commit_id: $upstream_commit_id"

                # if ! echo "$upstream_commit_id" | grep -q "$top_commit_id"; then
                #     echo "top_commit_id does not match upstream_commit_id"
                #     echo "repo_path: $repo_path"
                #     echo "TOP COMMIT ID DOES NOT MATCH UPSTREAM: $repo_path" >>$TARGET_PROJECT_PATH/repos_to_push-$current_date.txt
                # fi

            fi

        fi

        cd $TARGET_PROJECT_PATH
        
    done

    # If there are any repos that need to be pushed, display them and ask the user if they would like to push them
    if [[ $(cat $TARGET_PROJECT_PATH/repos_to_push-$current_date.txt | wc -l) -gt 0 ]]; then
        echo "The following repos need to be pushed:"
        cat $TARGET_PROJECT_PATH/repos_to_push-$current_date.txt | text

        # Ask the user if they would like to push the repos
        input 1 "Would you like to push the repos? (y/n) " "n"
        push_repos=$(0<"${dir_tmp}/${file_tmp}")

        # If the user says yes, push the repos
        if [[ $push_repos == "y" ]]; then
            for repo in $(cat $TARGET_PROJECT_PATH/repos_to_push-$current_date.txt); do
            cd $repo
            git push $current_remote $current_branch
            done
        fi
    fi

    # If the user wants to generate a manifest, generate it
    if [[ $push_repos == "y" ]]; then
        input 1 "Would you like to generate a manifest now? (y/n) " "n"
        generate_manifest=$(0<"${dir_tmp}/${file_tmp}")

        # If the user says yes, generate the manifest
        if [[ $generate_manifest == "y" ]]; then
            repo manifest -o $TARGET_PROJECT_PATH/manifest-$current_date.xml -r
        fi
    fi

}

# Override lunch function to filter lunch targets
function lunch
{
    local T=$(gettop)
    if [ ! "$T" ]; then
        echo "[lunch] Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi

    if [ "$BASS_DEBUG" != "true" ] ; then
    if menu_redirect; then
        echo -e "${green}Starting menu redirect\n${reset}"
    else
        echo -e "${yellow}Vendor Customization functions not found. Check license and verify all instructions have been followed, continuing without menu...\n${reset}"
    fi
    if copy_wallpaper; then
        echo -e "${green}Starting wallpaper customization\n${reset}"
    else
        echo -e "${yellow}Vendor Customization functions not found. Check license and verify all instructions have been followed, continuing without wallpaper customization...\n${reset}"
    fi
    if copy_grub_background; then
        echo -e "${green}Starting grub background customization\n${reset}"
    else
        echo -e "${yellow}Vendor Customization functions not found. Check license and verify all instructions have been followed, continuing without grub customization...\n${reset}"
    fi
    
    copy_configs
    add_grub_cmdline_options
    update_apps
    fi
    aosp_lunch $*

}

function launch_menu() 
{
    bash vendor/$vendor_name/includes/core-menu/core-menu.sh --config vendor/$vendor_name/branding/menus/branding-menu/branding-menu.json
}

function update_apps()
{
    if [ "$UPDATE_FOSSAPPS" = "true" ]; then
        if [ "$USE_FOSSAPPS" = "true" ]; then
            echo -e "Updating FOSS apps now..."
            echo ""
            $(cd vendor/foss && bash update.sh 1)
            echo -e "FOSS apps updated"
        fi

        if [ "$USE_BLISS_GARLIC_LAUNCHER" = "true" ]; then
            echo -e "Updating Garlic Player now..."
            echo ""
            $(cd vendor/agp-apps/tools/fossapp-updates && bash update.sh 1 -f garlic_player -r izzy -p com.sagiadinos.garlic.player -b USE_BLISS_GARLIC_LAUNCHER)
            echo -e "Garlic player updated"
        fi

        if [ "$USE_SMARTDOCK" = "true" ]; then
            echo -e "Updating SmartDock now..."
            echo ""
            $(cd vendor/agp-apps/tools/fossapp-updates && bash update.sh 1 -f smart_dock -r fdroid -p cu.axel.smartdock -b USE_SMARTDOCK)
        fi
    fi
}

function copy_configs()
{    
    if [ "$USE_BLISS_KIOSK_LAUNCHER" = "true" ]; then
        if [ ! -f packages/apps/BlissKioskLauncher/build.gradle ]; then
            echo -e "${ltred}Kiosk launcher source not found. Please make sure you have licensed access. Aborting...${reset}"
            exit 1
        fi
        echo -e "Kiosk launcher selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/kiosk/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/kiosk/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/kiosk/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/kiosk/dgc/* device/generic/common/
        sed -i 's/config_freeformWindowManagement">true/config_freeformWindowManagement">false/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">0/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        # sed -i 's/"ENABLE_TASKBAR", true,/"ENABLE_TASKBAR", false,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
        
        echo -e "Grub configs updated"
    fi
    if [[ "$USE_BLISS_RESTRICTED_LAUNCHER_PRO" = "true" ]] || [[ "$USE_BLISS_RESTRICTED_LAUNCHER" = "true" ]]; then
        if [ "$USE_BLISS_RESTRICTED_LAUNCHER_PRO" = "true" ]; then
            # check if user has access to restricted launcher pro apk by checking for the file
            if [ ! -f vendor/agp-apps/private/restricted_app_pro/Android.mk ]; then
                echo -e "${ltred}Restricted launcher pro not found. Please make sure you have licensed access. Aborting...${reset}"
                exit 1
            fi
        fi
        echo -e "Restricted launcher selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/restricted/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/restricted/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/restricted/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/restricted/dgc/* device/generic/common/
        sed -i 's/config_freeformWindowManagement">true/config_freeformWindowManagement">false/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">0/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        # sed -i 's/"ENABLE_TASKBAR", true,/"ENABLE_TASKBAR", false,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
       
        echo -e "Grub configs updated"
    fi

    if [ "$USE_BLISS_GAME_MODE_LAUNCHER" = "true" ]; then
        echo -e "Game-Mode launcher selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/game_mode/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/game_mode/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/game_mode/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/game_mode/dgc/* device/generic/common/
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">2/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        
        echo -e "Grub configs updated"
    fi

    if [ "$USE_TITANIUS_LAUNCHER" = "true" ]; then
        echo -e "Game-Mode launcher selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/game_mode/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/game_mode/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/game_mode/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/game_mode/dgc/* device/generic/common/
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">2/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        
        echo -e "Grub configs updated"
    fi

    if [ "$USE_BLISS_TV_LAUNCHER" = "true" ]; then
        echo -e "TV-Mode launcher selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/tv_mode/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/tv_mode/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/tv_mode/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/tv_mode/dgc/* device/generic/common/
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">2/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        
        echo -e "Grub configs updated"
    fi

    if [ "$USE_BLISS_CROSS_LAUNCHER" = "true" ]; then
        echo -e "Game-Mode CrossLauncher selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/crosslauncher/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/crosslauncher/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/crosslauncher/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/crosslauncher/dgc/* device/generic/common/
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">2/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        
        echo -e "Grub configs updated"
    fi
  
    if [ "$BLISS_SECURE_LOCKDOWN_BUILD" = "true" ]; then
        echo -e "Secure lockdown branding selected. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/lockdown/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/lockdown/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        # cp -r vendor/$vendor_name/configs/config_defaults/kiosk/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/kiosk/dgc/* device/generic/common/
        # sed -i 's/"ENABLE_TASKBAR", true,/"ENABLE_TASKBAR", false,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java# Reset sleep and screen off to default values for normal devices
        
        echo -e "Grub configs updated"
    fi
    if [[ "$USE_SMARTDOCK_B" = "true" ]] || [[ "$USE_SMARTDOCK" = "true" ]]; then
        echo -e "Desktop launcher selected. Copying configs now..."
        echo ""
        if [ "$USE_DESKTOP_MODE_ON_SECONDARY_DISPLAY" = "true" ]; then
            cp -r vendor/$vendor_name/configs/grub_configs/desktop-ext/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
            cp -r vendor/$vendor_name/configs/grub_configs/desktop-ext/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
            # cp -r vendor/$vendor_name/configs/config_defaults/desktop/overlay/* vendor/$vendor_name/overlay/
            cp -r vendor/$vendor_name/configs/config_defaults/desktop-ext/dgc/* device/generic/common/
            sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
            sed -i 's/config_navBarInteractionMode">0/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        else
            cp -r vendor/$vendor_name/configs/grub_configs/desktop/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
            cp -r vendor/$vendor_name/configs/grub_configs/desktop/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
            # cp -r vendor/$vendor_name/configs/config_defaults/desktop/overlay/* vendor/$vendor_name/overlay/
            cp -r vendor/$vendor_name/configs/config_defaults/desktop/dgc/* device/generic/common/
            sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
            sed -i 's/config_navBarInteractionMode">0/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        fi
        echo -e "Grub configs updated"
    fi
    if [ "$USE_ALWAYS_ON_SETTINGS" = "true" ]; then
        echo -e "Using always on settings. Updating configs now..."
        echo ""
        sed -i 's/def_screen_off_timeout">900000/def_screen_off_timeout">600000000/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_sleep_timeout">86400000/def_sleep_timeout">-1/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_screen_off_timeout">900000/def_screen_off_timeout">600000000/g' vendor/$vendor_name/overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_sleep_timeout">86400000/def_sleep_timeout">-1/g' vendor/$vendor_name/overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_lockscreen_disabled">false/def_lockscreen_disabled">true/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        
        echo -e "Configs updated"
    else
        echo -e "Not using always on settings. Updating configs now..."
        sed -i 's/def_screen_off_timeout">600000000/def_screen_off_timeout">900000/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_sleep_timeout">-1/def_sleep_timeout">86400000/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_screen_off_timeout">600000000/def_screen_off_timeout">900000/g' vendor/$vendor_name/overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_sleep_timeout">-1/def_sleep_timeout">86400000/g' vendor/$vendor_name/overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_lockscreen_disabled">true/def_lockscreen_disabled">false/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        
        echo -e "Configs updated"
    fi
    if [ "$USE_SHOW_KEYBOARD" = "true" ]; then
        echo -e "Show IME with hard keyboard selected. Updating configs now..."
        echo ""
        sed -i 's/def_show_ime_with_hard_keyboard">false/def_show_ime_with_hard_keyboard">true/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_show_ime_with_hard_keyboard">false/def_show_ime_with_hard_keyboard">true/g' vendor/$vendor_name/overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml

        echo -e "Configs updated"
    else
        echo -e "Show IME with hard keyboard not selected. Updating configs now..."
        echo ""
        sed -i 's/def_show_ime_with_hard_keyboard">true/def_show_ime_with_hard_keyboard">false/g' device/generic/common/overlay/frameworks/base/packages/SettingsProvider/res/values/defaults.xml
        sed -i 's/def_show_ime_with_hard_keyboard">true/def_show_ime_with_hard_keyboard">false/g' vendor/$vendor_name/overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml

        echo -e "Configs updated"
    fi
    if [ "$USE_PER_DISPLAY_FOCUS" = "true" ]; then
        echo -e "Use per display focus. Updating configs now..."
        echo ""
        sed -i 's/config_perDisplayFocusEnabled">false/config_perDisplayFocusEnabled">true/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_perDisplayFocusEnabled">false/config_perDisplayFocusEnabled">true/g' vendor/$vendor_name/overlay/common/frameworks/base/core/res/res/values/config.xml

        echo -e "Configs updated"
    else
        echo -e "Use per display focus not selected. Updating configs now..."
        echo ""
        sed -i 's/config_perDisplayFocusEnabled">true/config_perDisplayFocusEnabled">false/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_perDisplayFocusEnabled">true/config_perDisplayFocusEnabled">false/g' vendor/$vendor_name/overlay/common/frameworks/base/core/res/res/values/config.xml

        echo -e "Configs updated"
    fi
    if [[ "$USE_BLISS_TV_LAUNCHER" = "false" ]] && [[ "$USE_BLISS_KIOSK_LAUNCHER" = "false" ]] && [[ "$BLISS_SECURE_LOCKDOWN_BUILD" = "false" ]] && [[ "$USE_SMARTDOCK_B" = "false" ]] && [[ "$USE_SMARTDOCK" = "false" ]] && [[ "$USE_BLISS_RESTRICTED_LAUNCHER" = "false" ]] && [[ "$USE_BLISS_RESTRICTED_LAUNCHER_PRO" = "false" ]] && [[ "$USE_BLISS_GARLIC_LAUNCHER" = "false" ]] && [[ "$USE_BLISS_GAME_MODE_LAUNCHER" = "false" ]] && [[ "$USE_BLISS_CROSS_LAUNCHER" = "false" ]]; then
        echo -e "Defaulting to Tablet launcher. Copying configs now..."
        echo ""
        cp -r vendor/$vendor_name/configs/grub_configs/tablet/isolinux.cfg bootable/newinstaller/boot/isolinux/isolinux.cfg
        cp -r vendor/$vendor_name/configs/grub_configs/tablet/android.cfg bootable/newinstaller/install/grub2/efi/boot/android.cfg
        echo -e "Grub configs updated"
    fi
    if [ "$BLISS_TABLET_NAVIGATION" = "true" ]; then
        # cp -r vendor/$vendor_name/configs/config_defaults/tablet/overlay/* vendor/$vendor_name/overlay/
        cp -r vendor/$vendor_name/configs/config_defaults/tablet/dgc/* device/generic/common/
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">2/config_navBarInteractionMode">0/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/"config_navBarInteractionMode">2/"config_navBarInteractionMode">0/' vendor/$vendor_name/overlay/common/frameworks/base/core/res/res/values/config.xml

    fi
    if [ "$BLISS_GESTURE_NAVIGATION" = "true" ]; then
        sed -i 's/config_navBarInteractionMode">1/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/config_navBarInteractionMode">0/config_navBarInteractionMode">2/g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's/"config_navBarInteractionMode">0/"config_navBarInteractionMode">2/' vendor/$vendor_name/overlay/common/frameworks/base/core/res/res/values/config.xml
    fi

    if [ "$BLISS_SEPARATE_RECENTS_ACTIVITY" = "true" ]; then
        sed -i 's/"SEPARATE_RECENTS_ACTIVITY", false,/"SEPARATE_RECENTS_ACTIVITY", true,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
    fi

    if [ "$BLISS_DISABLE_DEVICE_SEARCH" = "true" ]; then
        sed -i 's/"ENABLE_DEVICE_SEARCH", true,/"ENABLE_DEVICE_SEARCH", false,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
    fi
    
    if [ "$BLISS_DISABLE_DEVICE_SEARCH" = "true" ]; then
        sed -i 's/"ENABLE_DEVICE_SEARCH", true,/"ENABLE_DEVICE_SEARCH", false,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
    fi

    if [ "$BLISS_CLEAR_HOTSEAT_FAVORITES" = "true" ]; then
        # Look for all filenames with "default_workspace*.xml" in packages/apps/Launcher3/res/xml/ and add them to WORKSPACE_LIST
        WORKSPACE_LIST=$(find packages/apps/Launcher3/res/xml/ -type f -name "default_workspace*.xml")
        # loop through the files in WORKSPACE_LIST and remove all lines between <favorites xmlns:launcher="http://schemas.android.com/apk/res-auto/com.android.launcher3"> and </favorites>
        for file in $WORKSPACE_LIST
        do
            sed -i '/<resolve/,/<\/resolve>/d' $file
        done

    fi

    if [ "$BLISS_LAUNCHER3_TASKBAR_NAVIGATION" = "true" ]; then
        sed -i 's/"ENABLE_TASKBAR", false,/"ENABLE_TASKBAR", true,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
        sed -i 's/android:key="enable_taskbar" android:defaultValue="false"/android:key="enable_taskbar" android:defaultValue="true"/' packages/apps/Blissify/res/xml/blissify_button.xml || sed -i 's/android:key="enable_taskbar"/android:key="enable_taskbar" android:defaultValue="true"/' packages/apps/Blissify/res/xml/blissify_button.xml
    else
        sed -i 's/"ENABLE_TASKBAR", true,/"ENABLE_TASKBAR", false,/' packages/apps/Launcher3/src/com/android/launcher3/config/FeatureFlags.java
        sed -i 's/android:key="enable_taskbar" android:defaultValue="true"/android:key="enable_taskbar" android:defaultValue="false"/' packages/apps/Blissify/res/xml/blissify_button.xml || sed -i 's/android:key="enable_taskbar"/android:key="enable_taskbar" android:defaultValue="false"/' packages/apps/Blissify/res/xml/blissify_button.xml
    fi

    if [ "$BLISS_REMOVE_KSU" = "true" ]; then
        echo "Removing KSU config from kernel"
        sed -i 's/CONFIG_KSU=y/\# CONFIG_KSU is not set/' kernel/arch/x86/configs/android-x86_64_defconfig
    else
        echo "Adding KSU config to kernel"
        sed -i 's/\# CONFIG_KSU is not set/CONFIG_KSU=y/' kernel/arch/x86/configs/android-x86_64_defconfig
    fi

    if [ "$BLISS_DISABLE_LARGE_SCREEN_SETTINGS" = "true" ]; then
        echo "Disabling large screen settings"
        sed -i 's/DEFAULT_FLAGS.put(SETTINGS_SUPPORT_LARGE_SCREEN, "true");/DEFAULT_FLAGS.put(SETTINGS_SUPPORT_LARGE_SCREEN, "false");/' frameworks/base/core/java/android/util/FeatureFlagUtils.java
    else
        echo "Enabling large screen settings"
        sed -i 's/DEFAULT_FLAGS.put(SETTINGS_SUPPORT_LARGE_SCREEN, "false");/DEFAULT_FLAGS.put(SETTINGS_SUPPORT_LARGE_SCREEN, "true");/' frameworks/base/core/java/android/util/FeatureFlagUtils.java
    fi

    # SystemUI Recents (does not work on Android 12+)
    if [ "$BLISS_USE_SYSTEMUI_RECENTS" = "true" ]; then
        echo "Enabling SystemUI recents"
        sed -i 's#com.android.launcher3/com.android.quickstep.RecentsActivity#com.android.systemui/.recents.RecentsActivity#g' frameworks/base/core/res/res/values/config.xml
        sed -i 's#com.android.launcher3/com.android.quickstep.RecentsActivity#com.android.systemui/.recents.RecentsActivity#g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's#com.android.launcher3/com.android.quickstep.RecentsActivity#com.android.systemui/.recents.RecentsActivity#g' vendor/$vendor_name/overlay/common/frameworks/base/core/res/res/values/config.xml
    else
        echo "Enabling Quickstep recents"
        sed -i 's#com.android.systemui/.recents.RecentsActivity#com.android.launcher3/com.android.quickstep.RecentsActivity#g' frameworks/base/core/res/res/values/config.xml
        sed -i 's#com.android.systemui/.recents.RecentsActivity#com.android.launcher3/com.android.quickstep.RecentsActivity#g' device/generic/common/overlay/frameworks/base/core/res/res/values/config.xml
        sed -i 's#com.android.systemui/.recents.RecentsActivity#com.android.launcher3/com.android.quickstep.RecentsActivity#g' vendor/$vendor_name/overlay/common/frameworks/base/core/res/res/values/config.xml
    fi

    if [ "$INCLUDE_AGPRIVAPPS" = "true" ]; then
        if [ ! -f vendor/ag_privapp/ag_privapp.mk ]; then
            echo -e "${ltred}ag_privapp source not found. Please make sure you have licensed access. Aborting...${reset}"
            exit 1
        fi
    fi
}

function add_grub_cmdline_options()
{
    # add "$GRUB_CMDLINE_OPTIONS" to the the specified grub config files, replacing the word "logo":
    # bootable/newinstaller/boot/isolinux/isolinux.cfg
    # bootable/newinstaller/install/grub2/efi/boot/android.cfg
    if [ "$GRUB_CMDLINE_OPTIONS" != "" ]; then
        sed -i "s/logo/$GRUB_CMDLINE_OPTIONS/g" bootable/newinstaller/boot/isolinux/isolinux.cfg
        sed -i "s/logo/$GRUB_CMDLINE_OPTIONS/g" bootable/newinstaller/install/grub2/efi/boot/android.cfg
    fi
}

function check_patchsets() 
{
    patchset_type=$1
    local T=$(gettop)
    if [ ! "$T" ]; then
        echo "[lunch] Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    # Find the first folder in vendor/$vendor_name/patches/patchsets
    are_patchsets=`ls vendor/$vendor_name/patches/patchsets`
    if [ ! "$are_patchsets" ]; then
        echo "[lunch] No patchsets found"
        return
    else
        echo "[lunch] Patchsets found"
        if [ "$patchset_type" != "" ]; then
            if [ -d vendor/$vendor_name/patches/patchsets-$patchset_type ]; then
                bash vendor/$vendor_name/patches/autopatch.sh vendor/$vendor_name/patches/patchsets-$patchset_type
            else
                echo "No patchsets found for $patchset_type"
            fi
        else
            bash vendor/$vendor_name/patches/autopatch.sh vendor/$vendor_name/patches/patchsets
        fi
    fi
}

function apply_addon_patches() 
{
    patchset_type=$1
    local T=$(gettop)
    if [ ! "$T" ]; then
        echo "[lunch] Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    echo "[lunch] Patchsets found"
    if [ "$patchset_type" != "" ]; then
        if [ -d vendor/$vendor_name/patches/patchsets-$patchset_type ]; then
            echo "Applying addon patchsets: vendor/$vendor_name/patches/patchsets-$patchset_type/$patchset_type"
            bash vendor/$vendor_name/patches/autopatch.sh vendor/$vendor_name/patches/patchsets-$patchset_type/$patchset_type
        else
            echo "No addon patchsets found for $patchset_type"
        fi
    else
        echo "No addon patchsets specified"
    fi
}

# Get the exact value of a build variable.
function get_build_var()
{
    if [ "$1" = "COMMON_LUNCH_CHOICES" ]; then
        valid_targets=`mixinup -t`
        save=`build/soong/soong_ui.bash --dumpvar-mode $1`
        unset LUNCH_MENU_CHOICES
        for t in ${save[@]}; do
            array=(${t/-/ })
            target=${array[0]}
            if [[ "${valid_targets}" =~ "$target" ]]; then
                   LUNCH_MENU_CHOICES+=($t)
            fi
        done
        echo ${LUNCH_MENU_CHOICES[@]}
        return
    else
        if [ "$BUILD_VAR_CACHE_READY" = "true" ]; then
            eval "echo \"\${var_cache_$1}\""
            return
        fi

        local T=$(gettop)
        if [ ! "$T" ]; then
            echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
            return
        fi
        (\cd $T; build/soong/soong_ui.bash --dumpvar-mode $1)
    fi
}

function build-x86()
{
	args=("$@")
    bash vendor/$vendor_name/tools/build-x86.sh "${args[@]}"

}

function bass_check_project()
{
    echo -e "${ltblue}Checking project status...${reset}"
    echo ""
    echo ""

    checkProjectStatus $PWD
}

