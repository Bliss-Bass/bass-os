#!/bin/bash -e

trap 'echo -e "\napply_addon_patches.sh interrupted"; exit 1' SIGINT

echo -e "\033[1;34mApplying Addon Patches\033[0m"
pushd aosptree
. build/envsetup.sh
apply_addon_patches $@
popd

