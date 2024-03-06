#!/bin/bash
# -*- coding: utf-8; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-

# Bliss-Bass RaspberryPi unfolding profile
#
# SPDX-License-Identifier: BSD-3-Clause

#setup colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
orange=`tput setaf 11`
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

LOCAL_PATH=$(pwd)

res_patch_dir="${LOCAL_PATH}/patches-aosp--resolutions"
top_dir=`readlink -f "$LOCAL_PATH/aosptree"`


echo -e "${ltblue}Init repo tree using AOSP manifest ${reset}"
pushd aosptree
repo init -u https://github.com/BlissRoms-x86/manifest.git -b arcadia-x86 --git-lfs
cd .repo/manifests
rm default.xml
cp ${LOCAL_PATH}/manifests/bliss-static.xml bliss.xml
cp ${LOCAL_PATH}/manifests/bass.xml bass.xml
cp ${LOCAL_PATH}/manifests/default_bliss.xml default.xml
if [ -f ${LOCAL_PATH}/manifests/private.xml ]; then
    mkdir -p ../local_manifests
    cp ${LOCAL_PATH}/manifests/private.xml ../local_manifests/private.xml
fi
git add *
git commit --no-edit -m "Add Bass OS Project"
popd

echo -e "${ltblue}Sync repo tree ${reset}"
if [ "$1" != "-s" ]; then
pushd aosptree
repo sync -c --force-sync -j4 || exit 1
popd
fi

tag_project() {
    pushd aosptree/$1
    git tag -f autopatch/`basename $1` > /dev/null
    popd
}

echo -e "${ltblue}Patch AOSP tree ${reset}"
patch_dir() {
    pushd aosptree/$1
    repo sync -l .
    patches=$(ls ${LOCAL_PATH}/patches-aosp/$1/*.patch)
    stripped_path=${1#./}
    res_patch_dir="${LOCAL_PATH}/patches-aosp--resolutions/"
    for i in ${patches} ; do
        git am -3 $i >& /dev/null
        if [[ $? == 0 ]]; then
            echo -e "        ${green}Applying${reset}          $i"
        else
            echo -e "        ${red}Conflicts${reset}         $i"
            git am --abort >& /dev/null
            echo "           Searching other vendors for patch resolutions..."
            for res_set in ${res_patch_dir}*/$stripped_path ; do
                d=$(dirname $res_set)
                res_set_name=$(echo ${d%%/} | sed 's|.*/||')
                patch_res_name=${i##*/}
                echo "           looking in $res_set for that patch..."
                # echo "${res_set}/${patch_res_name}"
                if [[ -f "${res_set}/${patch_res_name}" ]]; then
                    echo "           Found ${res_set}/${patch_res_name}!!"
                    echo "           trying..."
                    git am -3 "${res_set}/${patch_res_name}" >& /dev/null
                    if [[ $? == 0 ]]; then
                        echo -e "        ${green}Applying${reset}          $i"
                        goodpatch="y"
                        break
                    else
                        echo -e "        ${red}Conflicts${reset}         $i"
                        git am --abort >& /dev/null
                        conflict="y"
                    fi
                fi
            done
            if [[ "$goodpatch" != "y" ]]; then
                echo "           No resolution was found"
                git am --abort >& /dev/null
                echo "           Setting $i as Conflicts"
                conflict="y"
                # Create List of conflicts and add this patch to the list using conflict_list variable
                conflict_list="$conflict_list $i"
            fi
        fi
    done
    
    
    
    popd
}

pushd patches-aosp
directories=$(find -name *patch | xargs dirname | uniq)
# 
popd
echo -e "${orange}Directories to patch:"
echo -e "$directories ${reset}"
echo -e ""
for dir in ${directories}
do
    echo -e "${ltyellow}Patching: $dir ${reset}"
    tag_project $dir
    patch_dir $dir
done

# Hack to avoid rebuilding AOSP from scratch
touch -c -t 200101010101 aosptree/external/libcxx/include/chrono

cd aosptree/external/chromium-webview/prebuilt/arm64
git lfs pull
cd -
cd aosptree/external/chromium-webview/prebuilt/arm
git lfs pull
cd -

echo ""
if [[ "$conflict" == "y" ]]; then
  echo -e "${yellow}===========================================================================${reset}"
  echo -e "${yellow}           ALERT : Conflicts Observed while patch application !!           ${reset}"
  echo -e "${yellow}===========================================================================${reset}"
  for i in `echo $conflict_list | sed -e 's/:/ /g'` ; do echo $i; done | sort -u
  echo -e "${yellow}===========================================================================${reset}"
  echo -e "${yellow}WARNING: Please resolve Conflict(s). You may need to re-run build...${reset}"
  # return 1
else
  echo -e "${green}===========================================================================${reset}"
  echo -e "${green}           INFO : All patches applied fine !!                              ${reset}"
  echo -e "${green}===========================================================================${reset}"
  mkdir -p ${LOCAL_PATH}/.config
  echo "applied" > ${LOCAL_PATH}/.config/patches_applied.cfg
fi

echo -e "${ltgreen}   Done   ${reset}"
